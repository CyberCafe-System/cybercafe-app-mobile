import 'dart:convert';

import '../config/api_config.dart';
import '../models/dashboard_admin.dart';
import '../models/equipo.dart';
import '../models/reporte_admin.dart';
import 'auth_service.dart';

class ReporteAdminService {
  ReporteAdminService({AuthService? auth})
    : _auth = auth ?? AuthService.instance;

  static final ReporteAdminService instance = ReporteAdminService();

  final AuthService _auth;

  ReporteAdminData? _cache;
  DashboardAdminData? _dashboardCache;

  void limpiarCache() {
    _cache = null;
    _dashboardCache = null;
  }

  Future<ReporteAdminData> cargarReportes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    final resultados = await Future.wait([
      _getAllList(ApiConfig.ventasPath, 'No se pudieron cargar las ventas.'),
      _getAllList(ApiConfig.rentasPath, 'No se pudieron cargar las rentas.'),
      _getAllList(ApiConfig.productosPath, 'No se pudo cargar el inventario.'),
      _getAllListOrEmpty(
        ApiConfig.clientesPath,
        'No se pudieron cargar los clientes.',
      ),
      _getAllListOrEmpty(
        ApiConfig.categoriasPath,
        'No se pudieron cargar las categorías.',
      ),
      _getAllListOrEmpty(
        ApiConfig.equiposPath,
        'No se pudieron cargar los equipos.',
      ),
      _getAllListOrEmpty(
        ApiConfig.usuariosPath,
        'No se pudieron cargar los usuarios.',
      ),
    ]);

    final ventasJson = resultados[0];
    final rentasJson = resultados[1];
    final productosJson = resultados[2];
    final clientesJson = resultados[3];
    final categoriasJson = resultados[4];
    final equiposJson = resultados[5];
    final usuariosJson = resultados[6];

    final clientesPorId = <int, ClienteReporte>{};
    for (final item in clientesJson) {
      final cliente = ClienteReporte.fromJson(item);
      final id = cliente.clienteId;
      if (id != null) clientesPorId[id] = cliente;
    }

    final categoriasPorId = <int, String>{};
    for (final item in categoriasJson) {
      final id = _parseInt(item['categoria_id']);
      final nombre = _parseNullableString(item['nombre']);
      if (id != null && nombre != null) categoriasPorId[id] = nombre;
    }

    final productosPorId = <int, ProductoReporte>{};
    final productos = <ProductoReporte>[];
    for (final item in productosJson) {
      var producto = ProductoReporte.fromJson(item);
      final categoria = categoriasPorId[producto.categoriaId];
      if (categoria != null) producto = producto.conCategoria(categoria);
      final id = producto.productoId;
      if (id != null) productosPorId[id] = producto;
      productos.add(producto);
    }
    productos.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );

    final equiposPorId = <int, Equipo>{};
    for (final item in equiposJson) {
      try {
        final equipo = Equipo.fromJson(item);
        final id = equipo.equipoId;
        if (id != null) equiposPorId[id] = equipo;
      } catch (_) {
        continue;
      }
    }

    final usuariosPorId = <int, String>{};
    for (final item in usuariosJson) {
      final id = _parseInt(item['usuario_id']);
      final nombre = _parseNullableString(item['nombre']);
      final username = _parseNullableString(item['username']);
      final etiqueta = nombre ?? username;
      if (id != null && etiqueta != null) usuariosPorId[id] = etiqueta;
    }

    final ventas = <VentaReporte>[];
    for (final item in ventasJson) {
      final base = VentaReporte.fromJson(item);
      ventas.add(_enriquecerVenta(base, clientesPorId, usuariosPorId));
    }
    ventas.sort(_compararFechaVenta);

    final rentas = <RentaReporte>[];
    for (final item in rentasJson) {
      final base = RentaReporte.fromJson(item);
      rentas.add(_enriquecerRenta(base, clientesPorId, usuariosPorId));
    }
    rentas.sort(_compararFechaRenta);

    final data = ReporteAdminData(
      ventas: ventas,
      rentas: rentas,
      productos: productos,
      clientesPorId: clientesPorId,
      productosPorId: productosPorId,
      equiposPorId: equiposPorId,
      usuariosPorId: usuariosPorId,
    );
    _cache = data;
    return data;
  }

  Future<VentaDetalleCompleto> cargarDetalleVenta(int ventaId) async {
    final data = _cache ?? await cargarReportes();
    final json = await _getMap(
      '${ApiConfig.ventasPath}/$ventaId',
      'No se pudo cargar el detalle de la venta.',
    );

    final ventaJson = json['venta'];
    if (ventaJson is! Map) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
    final venta = _enriquecerVenta(
      VentaReporte.fromJson(Map<String, dynamic>.from(ventaJson)),
      data.clientesPorId,
      data.usuariosPorId,
    );

    final detallesJson = json['detalles'];
    final detalles = <DetalleVentaReporte>[];
    if (detallesJson is List) {
      for (final item in detallesJson) {
        if (item is! Map) continue;
        final base = DetalleVentaReporte.fromJson(
          Map<String, dynamic>.from(item),
        );
        final producto = data.productosPorId[base.productoId];
        detalles.add(
          DetalleVentaReporte(
            detalleVentaId: base.detalleVentaId,
            ventaId: base.ventaId,
            productoId: base.productoId,
            productoNombre: producto?.nombre ?? base.productoNombre,
            precioUnitario: base.precioUnitario,
            cantidad: base.cantidad,
            subtotal: base.subtotal,
          ),
        );
      }
    }

    return VentaDetalleCompleto(venta: venta, detalles: detalles);
  }

  Future<RentaDetalleCompleto> cargarDetalleRenta(int rentaId) async {
    final data = _cache ?? await cargarReportes();
    final json = await _getMap(
      '${ApiConfig.rentasPath}/$rentaId',
      'No se pudo cargar el detalle de la renta.',
    );

    final rentaJson = json['renta'];
    if (rentaJson is! Map) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
    final renta = _enriquecerRenta(
      RentaReporte.fromJson(Map<String, dynamic>.from(rentaJson)),
      data.clientesPorId,
      data.usuariosPorId,
    );

    final detallesJson = json['detalles'];
    final detalles = <DetalleRentaReporte>[];
    if (detallesJson is List) {
      for (final item in detallesJson) {
        if (item is! Map) continue;
        final base = DetalleRentaReporte.fromJson(
          Map<String, dynamic>.from(item),
        );
        final equipo = data.equiposPorId[base.equipoId];
        detalles.add(
          DetalleRentaReporte(
            detalleRentaId: base.detalleRentaId,
            rentaId: base.rentaId,
            equipoId: base.equipoId,
            equipoNombre: equipo?.nombre ?? base.equipoNombre,
            equipoTipo: equipo?.tipo.value ?? base.equipoTipo,
            horaInicio: base.horaInicio,
            tiempoDeRenta: base.tiempoDeRenta,
            tiempoAgregado: base.tiempoAgregado,
            horaFin: base.horaFin,
            subtotal: base.subtotal,
            estado: base.estado,
          ),
        );
      }
    }

    return RentaDetalleCompleto(renta: renta, detalles: detalles);
  }

  Future<DashboardAdminData> cargarDashboard({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _dashboardCache != null) return _dashboardCache!;

    final generalFuture = _getMap(
      ApiConfig.reporteResumenGeneralPath,
      'No se pudo cargar el resumen general.',
    );
    final hoy = DateTime.now();
    final dias = List<DateTime>.generate(
      7,
      (index) => DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
      ).subtract(Duration(days: 6 - index)),
    );
    final semanaFuture = Future.wait(dias.map(_getDiarioOrNull));

    final resultados = await Future.wait<dynamic>([
      generalFuture,
      semanaFuture,
    ]);
    final generalJson = resultados[0] as Map<String, dynamic>;
    final semana = resultados[1] as List<ResumenDiarioAdmin?>;
    final resumenSemana = semana.whereType<ResumenDiarioAdmin>().toList();
    ResumenDiarioAdmin? resumenHoy;
    for (final dia in resumenSemana) {
      if (dia.fecha.year == hoy.year &&
          dia.fecha.month == hoy.month &&
          dia.fecha.day == hoy.day) {
        resumenHoy = dia;
        break;
      }
    }
    resumenHoy ??= await _getDiario(hoy);

    final data = DashboardAdminData(
      general: ResumenGeneralAdmin.fromJson(generalJson),
      hoy: resumenHoy,
      semana: resumenSemana,
    );
    _dashboardCache = data;
    return data;
  }

  Future<ResumenDiarioAdmin?> _getDiarioOrNull(DateTime fecha) async {
    try {
      return await _getDiario(fecha);
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ResumenDiarioAdmin> _getDiario(DateTime fecha) async {
    final uri = ApiConfig.endpoint(
      ApiConfig.reporteDiarioPath,
    ).replace(queryParameters: {'fecha_reporte': _fechaISO(fecha)});
    final json = await _getMapUri(uri, 'No se pudo cargar el resumen diario.');
    return ResumenDiarioAdmin.fromJson(json);
  }

  VentaReporte _enriquecerVenta(
    VentaReporte base,
    Map<int, ClienteReporte> clientes,
    Map<int, String> usuarios,
  ) {
    final cliente = base.clienteId == null ? null : clientes[base.clienteId];
    final cajero = _nombreUsuario(base.usuarioId, usuarios);
    return VentaReporte(
      ventaId: base.ventaId,
      fecha: base.fecha,
      clienteId: base.clienteId,
      cliente: cliente,
      usuarioId: base.usuarioId,
      cajeroNombre: cajero,
      subtotal: base.subtotal,
      iva: base.iva,
      total: base.total,
    );
  }

  RentaReporte _enriquecerRenta(
    RentaReporte base,
    Map<int, ClienteReporte> clientes,
    Map<int, String> usuarios,
  ) {
    final cliente = base.clienteId == null ? null : clientes[base.clienteId];
    final cajero = _nombreUsuario(base.usuarioId, usuarios);
    return RentaReporte(
      rentaId: base.rentaId,
      fecha: base.fecha,
      clienteId: base.clienteId,
      cliente: cliente,
      usuarioId: base.usuarioId,
      cajeroNombre: cajero,
      total: base.total,
      estadoPago: base.estadoPago,
    );
  }

  String? _nombreUsuario(int? usuarioId, Map<int, String> usuarios) {
    if (usuarioId == null) return null;
    final nombre = usuarios[usuarioId];
    if (nombre != null) return nombre;
    if (_auth.usuarioId == usuarioId) return _auth.nombreMostrado;
    return null;
  }

  int _compararFechaVenta(VentaReporte a, VentaReporte b) {
    return _compararFechas(a.fecha, b.fecha);
  }

  int _compararFechaRenta(RentaReporte a, RentaReporte b) {
    return _compararFechas(a.fecha, b.fecha);
  }

  int _compararFechas(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  Future<List<Map<String, dynamic>>> _getAllList(
    String path,
    String fallback, {
    int pageSize = 100,
    int maxPages = 200,
  }) async {
    final items = <Map<String, dynamic>>[];
    var offset = 0;

    for (var page = 0; page < maxPages; page++) {
      final uri = ApiConfig.endpoint(
        path,
      ).replace(queryParameters: {'offset': '$offset', 'limit': '$pageSize'});
      final pageItems = await _getList(uri, fallback);
      items.addAll(pageItems);
      if (pageItems.length < pageSize) break;
      offset += pageSize;
    }
    return items;
  }

  Future<List<Map<String, dynamic>>> _getAllListOrEmpty(
    String path,
    String fallback,
  ) async {
    try {
      return await _getAllList(path, fallback);
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> _getList(Uri uri, String fallback) async {
    final response = await _auth.getProtected(uri);
    if (response.statusCode != 200) {
      throw _errorFor(response.statusCode, response.bodyBytes, fallback);
    }

    final data = _decode(response.bodyBytes, fallback);
    if (data is! List) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }

    final items = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is! Map) {
        throw AuthException('El servidor devolvió una respuesta inesperada.');
      }
      items.add(Map<String, dynamic>.from(item));
    }
    return items;
  }

  Future<Map<String, dynamic>> _getMap(String path, String fallback) {
    return _getMapUri(ApiConfig.endpoint(path), fallback);
  }

  Future<Map<String, dynamic>> _getMapUri(Uri uri, String fallback) async {
    final response = await _auth.getProtected(uri);
    if (response.statusCode != 200) {
      throw _errorFor(response.statusCode, response.bodyBytes, fallback);
    }

    final data = _decode(response.bodyBytes, fallback);
    if (data is! Map) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
    return Map<String, dynamic>.from(data);
  }

  dynamic _decode(List<int> bodyBytes, String fallback) {
    try {
      return jsonDecode(utf8.decode(bodyBytes));
    } catch (_) {
      throw AuthException(fallback);
    }
  }

  AuthException _errorFor(
    int statusCode,
    List<int> bodyBytes,
    String fallback,
  ) {
    if (statusCode == 403) {
      return AuthException(
        'No tienes permisos para consultar los reportes.',
        statusCode: statusCode,
      );
    }

    return AuthException(
      _detail(bodyBytes) ?? fallback,
      statusCode: statusCode,
    );
  }

  String? _detail(List<int> bodyBytes) {
    try {
      final data = jsonDecode(utf8.decode(bodyBytes));
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail.trim();
        }
      }
    } catch (_) {}
    return null;
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _parseNullableString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value == null) return null;
  final texto = '$value'.trim();
  return texto.isEmpty ? null : texto;
}

String _fechaISO(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year.toString().padLeft(4, '0')}-$mes-$dia';
}
