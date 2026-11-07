import 'dart:convert';

import '../config/api_config.dart';
import '../models/equipo.dart';
import '../models/pendiente_revision.dart';
import '../models/revision_equipo.dart';
import '../models/revision_historial.dart';
import 'auth_service.dart';
import 'paginacion_api.dart';

class RevisionService {
  RevisionService({AuthService? auth}) : _auth = auth ?? AuthService.instance;

  static final RevisionService instance = RevisionService();

  final AuthService _auth;

  Future<RevisionEquipo> crearRevision({
    required int detalleRentaId,
    required bool inspeccionPasada,
    required String observaciones,
    List<ComponenteRevisionItem>? componentesAfectados,
    EstadoEquipo? estadoSiDaniado,
  }) async {
    if (detalleRentaId < 1) {
      throw ArgumentError.value(
        detalleRentaId,
        'detalleRentaId',
        'Debe ser mayor o igual a 1',
      );
    }

    final revision = RevisionEquipo(
      detalleRentaId: detalleRentaId,
      inspeccionPasada: inspeccionPasada,
      observaciones: observaciones,
      componentesAfectados: componentesAfectados,
    );

    var uri = ApiConfig.endpoint(ApiConfig.revisionesPath);
    if (estadoSiDaniado != null) {
      uri = uri.replace(
        queryParameters: {'estado_si_daniado': estadoSiDaniado.value},
      );
    }

    final response = await _auth.postProtected(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(revision.toCreateJson()),
    );

    if (response.statusCode != 201) {
      throw _errorFor(
        response.statusCode,
        response.bodyBytes,
        'No se pudo registrar la revisión.',
      );
    }

    final data = _decode(
      response.bodyBytes,
      'No se pudo registrar la revisión.',
    );
    if (data is! Map) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
    return RevisionEquipo.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Map<int, PendienteRevision>> getEquiposConRevisionPendiente({
    int maxItems = 1000,
  }) async {
    if (maxItems < 1) {
      throw ArgumentError.value(
        maxItems,
        'maxItems',
        'Debe ser mayor o igual a 1',
      );
    }

    final detalles = await _getAllList(
      ApiConfig.detallesRentaPendientesRevisionPath,
      'No se pudieron consultar las rentas pendientes de revisión.',
      maxItems: maxItems,
    );
    if (detalles.isEmpty) return const {};

    final pendientes = <int, PendienteRevision>{};
    final detallePorEquipo = <int, int>{};
    for (final detalle in detalles) {
      final equipoId = _parseInt(detalle['equipo_id']);
      final detalleId = _parseInt(detalle['detalle_renta_id']);
      if (equipoId == null || detalleId == null) continue;

      final detalleAnterior = detallePorEquipo[equipoId];
      if (detalleAnterior != null && detalleId <= detalleAnterior) {
        continue;
      }

      final clienteNombre = detalle['cliente_nombre'];
      detallePorEquipo[equipoId] = detalleId;
      pendientes[equipoId] = PendienteRevision(
        detalleRentaId: detalleId,
        equipoId: equipoId,
        rentaId: _parseInt(detalle['renta_id']),
        clienteNombre:
            clienteNombre is String && clienteNombre.trim().isNotEmpty
            ? clienteNombre.trim()
            : null,
      );
    }
    return pendientes;
  }

  Future<List<RevisionHistorialItem>> getHistorialRevisiones({
    int maxItems = 1000,
  }) async {
    if (maxItems < 1) {
      throw ArgumentError.value(
        maxItems,
        'maxItems',
        'Debe ser mayor o igual a 1',
      );
    }

    final revisionesJson = await _getAllList(
      ApiConfig.revisionesPath,
      'No se pudo cargar el historial de revisiones.',
      maxItems: maxItems,
    );
    if (revisionesJson.isEmpty) return const [];

    final revisiones = revisionesJson.map(RevisionEquipo.fromJson).toList();
    final todasEnriquecidas = revisiones.every(
      (r) => r.equipoNombre != null && r.equipoNombre!.isNotEmpty,
    );

    if (todasEnriquecidas) {
      final historial = <RevisionHistorialItem>[];
      for (final revision in revisiones) {
        TipoEquipo? tipo;
        if (revision.equipoTipo != null) {
          try {
            tipo = TipoEquipo.fromValue(revision.equipoTipo!);
          } catch (_) {}
        }
        historial.add(
          RevisionHistorialItem(
            revision: revision,
            equipoNombre: revision.equipoNombre!,
            equipoTipo: tipo,
            clienteNombre: revision.clienteNombre,
            usuarioNombre:
                revision.usuarioNombre ??
                (revision.usuarioId == _auth.usuarioId ? _auth.username : null),
          ),
        );
      }
      historial.sort((a, b) {
        final fechaA = a.revision.fechaRevision;
        final fechaB = b.revision.fechaRevision;
        if (fechaA == null && fechaB == null) return 0;
        if (fechaA == null) return 1;
        if (fechaB == null) return -1;
        return fechaB.compareTo(fechaA);
      });
      return historial;
    }

    // Fallback de compatibilidad si alguna respuesta no incluye campos enriquecidos
    final detallesFuture = _getAllListOrEmpty(
      ApiConfig.detallesRentaPath,
      'No se pudieron cargar los detalles de renta.',
      maxItems: maxItems,
    );
    final equiposFuture = _getAllListOrEmpty(
      ApiConfig.equiposPath,
      'No se pudieron cargar los equipos.',
      maxItems: maxItems,
    );
    final rentasFuture = _getAllListOrEmpty(
      ApiConfig.rentasPath,
      'No se pudieron cargar las rentas.',
      maxItems: maxItems,
    );
    final clientesFuture = _getAllListOrEmpty(
      ApiConfig.clientesPath,
      'No se pudieron cargar los clientes.',
      maxItems: maxItems,
    );
    final nombresFuture = _getNombresUsuarios();

    final detallesJson = await detallesFuture;
    final equiposJson = await equiposFuture;
    final rentasJson = await rentasFuture;
    final clientesJson = await clientesFuture;

    final equipoPorDetalle = <int, int>{};
    final rentaPorDetalle = <int, int>{};
    for (final detalle in detallesJson) {
      final detalleId = _parseInt(detalle['detalle_renta_id']);
      final equipoId = _parseInt(detalle['equipo_id']);
      final rentaId = _parseInt(detalle['renta_id']);
      if (detalleId == null) continue;
      if (equipoId != null) {
        equipoPorDetalle[detalleId] = equipoId;
      }
      if (rentaId != null) {
        rentaPorDetalle[detalleId] = rentaId;
      }
    }

    final equiposPorId = <int, Equipo>{};
    for (final item in equiposJson) {
      final equipo = Equipo.fromJson(item);
      final id = equipo.equipoId;
      if (id != null) {
        equiposPorId[id] = equipo;
      }
    }

    final clientePorRenta = <int, int>{};
    for (final renta in rentasJson) {
      final rentaId = _parseInt(renta['renta_id']);
      final clienteId = _parseInt(renta['cliente_id']);
      if (rentaId != null && clienteId != null) {
        clientePorRenta[rentaId] = clienteId;
      }
    }

    final nombrePorCliente = <int, String>{};
    for (final cliente in clientesJson) {
      final clienteId = _parseInt(cliente['cliente_id']);
      final nombre = _componerNombreCliente(cliente);
      if (clienteId != null && nombre != null) {
        nombrePorCliente[clienteId] = nombre;
      }
    }

    final nombresUsuarios = await nombresFuture;

    final historial = <RevisionHistorialItem>[];
    for (final revision in revisiones) {
      final equipoId =
          revision.equipoId ?? equipoPorDetalle[revision.detalleRentaId];
      final equipo = equipoId == null ? null : equiposPorId[equipoId];
      final rentaId = rentaPorDetalle[revision.detalleRentaId];
      final clienteId = rentaId == null ? null : clientePorRenta[rentaId];
      final clienteNombre =
          revision.clienteNombre ??
          (clienteId == null ? null : nombrePorCliente[clienteId]);

      TipoEquipo? tipo = equipo?.tipo;
      if (tipo == null && revision.equipoTipo != null) {
        try {
          tipo = TipoEquipo.fromValue(revision.equipoTipo!);
        } catch (_) {}
      }

      historial.add(
        RevisionHistorialItem(
          revision: revision,
          equipoNombre:
              revision.equipoNombre ??
              equipo?.nombre ??
              (equipoId == null ? 'Equipo no disponible' : 'Equipo #$equipoId'),
          equipoTipo: tipo,
          clienteNombre: clienteNombre,
          usuarioNombre:
              revision.usuarioNombre ??
              _resolverNombreUsuario(revision.usuarioId, nombresUsuarios),
        ),
      );
    }

    historial.sort((a, b) {
      final fechaA = a.revision.fechaRevision;
      final fechaB = b.revision.fechaRevision;
      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;
      return fechaB.compareTo(fechaA);
    });

    return historial;
  }

  Future<PaginaApi<Map<String, dynamic>>> _getList(
    Uri uri,
    String fallback,
  ) async {
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
    return PaginaApi(items: items, total: PaginadorApi.totalDesde(response));
  }

  Future<List<Map<String, dynamic>>> _getAllList(
    String path,
    String fallback, {
    int pageSize = 100,
    int maxItems = 1000,
    Map<String, String>? queryParameters,
  }) async {
    final resultado = await PaginadorApi.recolectar<Map<String, dynamic>>(
      pageSize: pageSize,
      maxItems: maxItems,
      cargarPagina: (offset, limit) => _getList(
        ApiConfig.endpoint(path).replace(
          queryParameters: {
            'offset': '$offset',
            'limit': '$limit',
            ...?queryParameters,
          },
        ),
        fallback,
      ),
    );
    return resultado.items;
  }

  Future<List<Map<String, dynamic>>> _getAllListOrEmpty(
    String path,
    String fallback, {
    int pageSize = 100,
    int maxItems = 1000,
    Map<String, String>? queryParameters,
  }) async {
    try {
      return await _getAllList(
        path,
        fallback,
        pageSize: pageSize,
        maxItems: maxItems,
        queryParameters: queryParameters,
      );
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<Map<int, String>> _getNombresUsuarios() async {
    if (!_auth.isAdmin) return const {};

    try {
      final usuarios = await _getAllList(
        '/usuarios',
        'No se pudieron cargar los usuarios.',
      );

      final nombres = <int, String>{};
      for (final usuario in usuarios) {
        final id = _parseInt(usuario['usuario_id']);
        final nombre = usuario['nombre'];
        final username = usuario['username'];
        final etiqueta = nombre is String && nombre.trim().isNotEmpty
            ? nombre.trim()
            : username is String && username.trim().isNotEmpty
            ? username.trim()
            : null;
        if (id != null && etiqueta != null) {
          nombres[id] = etiqueta;
        }
      }
      return nombres;
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  String? _resolverNombreUsuario(int? usuarioId, Map<int, String> nombres) {
    if (usuarioId == null) return null;
    final nombre = nombres[usuarioId];
    if (nombre != null) return nombre;
    if (_auth.usuarioId == usuarioId) return _auth.username;
    return null;
  }

  String? _componerNombreCliente(Map<String, dynamic> cliente) {
    final nombre = cliente['nombre'];
    final apellido = cliente['apellido'];
    final partes = <String>[
      if (nombre is String && nombre.trim().isNotEmpty) nombre.trim(),
      if (apellido is String && apellido.trim().isNotEmpty) apellido.trim(),
    ];
    if (partes.isEmpty) return null;
    return partes.join(' ');
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
        'No tienes permisos para registrar revisiones.',
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
