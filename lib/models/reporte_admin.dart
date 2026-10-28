import 'equipo.dart';

class ClienteReporte {
  const ClienteReporte({
    this.clienteId,
    required this.nombre,
    required this.apellido,
    required this.dui,
    required this.direccion,
    this.telefono,
    this.correo,
  });

  final int? clienteId;
  final String nombre;
  final String apellido;
  final String dui;
  final String direccion;
  final int? telefono;
  final String? correo;

  String get nombreCompleto {
    final partes = <String>[
      if (nombre.trim().isNotEmpty) nombre.trim(),
      if (apellido.trim().isNotEmpty) apellido.trim(),
    ];
    if (partes.isNotEmpty) return partes.join(' ');
    if (clienteId != null) return 'Cliente #$clienteId';
    return 'Cliente no disponible';
  }

  factory ClienteReporte.fromJson(Map<String, dynamic> json) {
    return ClienteReporte(
      clienteId: _parseInt(json['cliente_id']),
      nombre: _parseString(json['nombre']),
      apellido: _parseString(json['apellido']),
      dui: _parseString(json['dui']),
      direccion: _parseString(json['direccion']),
      telefono: _parseInt(json['telefono']),
      correo: _parseNullableString(json['correo']),
    );
  }
}

class ProductoReporte {
  const ProductoReporte({
    this.productoId,
    this.categoriaId,
    required this.nombre,
    required this.precioCompra,
    required this.precioVenta,
    required this.cantidad,
    this.imagen,
    required this.activo,
    this.categoriaNombre,
  });

  final int? productoId;
  final int? categoriaId;
  final String nombre;
  final double precioCompra;
  final double precioVenta;
  final int cantidad;
  final String? imagen;
  final bool activo;
  final String? categoriaNombre;

  bool get stockBajo => cantidad <= 5;
  double get margen => precioVenta - precioCompra;

  String get categoriaMostrada {
    final nombreCategoria = categoriaNombre?.trim();
    if (nombreCategoria != null && nombreCategoria.isNotEmpty) {
      return nombreCategoria;
    }
    if (categoriaId != null) return 'Categoría #$categoriaId';
    return 'Sin categoría';
  }

  ProductoReporte conCategoria(String? nombreCategoria) {
    return ProductoReporte(
      productoId: productoId,
      categoriaId: categoriaId,
      nombre: nombre,
      precioCompra: precioCompra,
      precioVenta: precioVenta,
      cantidad: cantidad,
      imagen: imagen,
      activo: activo,
      categoriaNombre: nombreCategoria,
    );
  }

  factory ProductoReporte.fromJson(Map<String, dynamic> json) {
    return ProductoReporte(
      productoId: _parseInt(json['producto_id']),
      categoriaId: _parseInt(json['categoria_id']),
      nombre: _parseString(json['nombre']),
      precioCompra: _parseDouble(json['precio_compra']),
      precioVenta: _parseDouble(json['precio_venta']),
      cantidad: _parseInt(json['cantidad']) ?? 0,
      imagen: _parseNullableString(json['imagen']),
      activo: _parseBool(json['activo'], fallback: true),
      categoriaNombre: _parseNullableString(json['categoria_nombre']),
    );
  }
}

class VentaReporte {
  const VentaReporte({
    this.ventaId,
    this.fecha,
    this.clienteId,
    this.cliente,
    this.usuarioId,
    this.cajeroNombre,
    required this.subtotal,
    required this.iva,
    required this.total,
  });

  final int? ventaId;
  final DateTime? fecha;
  final int? clienteId;
  final ClienteReporte? cliente;
  final int? usuarioId;
  final String? cajeroNombre;
  final double subtotal;
  final double iva;
  final double total;

  String get clienteMostrado {
    final nombreCliente = cliente?.nombreCompleto;
    if (nombreCliente != null && nombreCliente.trim().isNotEmpty) {
      return nombreCliente;
    }
    if (clienteId != null) return 'Cliente #$clienteId';
    return 'Cliente no disponible';
  }

  String get cajeroMostrado {
    final nombreCajero = cajeroNombre?.trim();
    if (nombreCajero != null && nombreCajero.isNotEmpty) return nombreCajero;
    if (usuarioId != null) return 'Usuario #$usuarioId';
    return 'No disponible';
  }

  factory VentaReporte.fromJson(Map<String, dynamic> json) {
    final subtotal = _parseDouble(json['subtotal']);
    final iva = _parseDouble(json['iva']);
    final total = _parseNullableDouble(json['total']) ?? subtotal + iva;
    return VentaReporte(
      ventaId: _parseInt(json['venta_id']),
      fecha: _parseDate(json['fecha']),
      clienteId: _parseInt(json['cliente_id']),
      usuarioId: _parseInt(json['usuario_id']),
      subtotal: subtotal,
      iva: iva,
      total: total,
    );
  }
}

class DetalleVentaReporte {
  const DetalleVentaReporte({
    this.detalleVentaId,
    this.ventaId,
    this.productoId,
    required this.productoNombre,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });

  final int? detalleVentaId;
  final int? ventaId;
  final int? productoId;
  final String productoNombre;
  final double precioUnitario;
  final int cantidad;
  final double subtotal;

  factory DetalleVentaReporte.fromJson(Map<String, dynamic> json) {
    final productoId = _parseInt(json['producto_id']);
    final nombre = _parseNullableString(json['producto_nombre']);
    return DetalleVentaReporte(
      detalleVentaId: _parseInt(json['detalle_venta_id']),
      ventaId: _parseInt(json['venta_id']),
      productoId: productoId,
      productoNombre:
          nombre ??
          (productoId == null
              ? 'Producto no disponible'
              : 'Producto #$productoId'),
      precioUnitario: _parseDouble(json['precio_unitario']),
      cantidad: _parseInt(json['cantidad']) ?? 0,
      subtotal: _parseDouble(json['subtotal']),
    );
  }
}

class VentaDetalleCompleto {
  const VentaDetalleCompleto({required this.venta, required this.detalles});

  final VentaReporte venta;
  final List<DetalleVentaReporte> detalles;

  double get total => venta.total;
}

enum EstadoPagoReporte {
  pendiente('Pendiente'),
  pagado('Pagado'),
  desconocido('Desconocido');

  const EstadoPagoReporte(this.etiqueta);

  final String etiqueta;

  static EstadoPagoReporte fromValue(dynamic value) {
    final texto = _parseString(value).toLowerCase();
    if (texto == 'pendiente') return EstadoPagoReporte.pendiente;
    if (texto == 'pagado') return EstadoPagoReporte.pagado;
    return EstadoPagoReporte.desconocido;
  }
}

enum EstadoRentaReporte {
  activa('Activa'),
  finalizada('Finalizada'),
  pendienteRevision('Pendiente Revisión'),
  desconocida('Desconocida');

  const EstadoRentaReporte(this.etiqueta);

  final String etiqueta;

  static EstadoRentaReporte fromValue(dynamic value) {
    final texto = _parseString(value).toLowerCase();
    if (texto == 'activa') return EstadoRentaReporte.activa;
    if (texto == 'finalizada') return EstadoRentaReporte.finalizada;
    if (texto == 'pendiente revision') {
      return EstadoRentaReporte.pendienteRevision;
    }
    return EstadoRentaReporte.desconocida;
  }
}

class RentaReporte {
  const RentaReporte({
    this.rentaId,
    this.fecha,
    this.clienteId,
    this.cliente,
    this.usuarioId,
    this.cajeroNombre,
    required this.total,
    required this.estadoPago,
  });

  final int? rentaId;
  final DateTime? fecha;
  final int? clienteId;
  final ClienteReporte? cliente;
  final int? usuarioId;
  final String? cajeroNombre;
  final double total;
  final EstadoPagoReporte estadoPago;

  String get clienteMostrado {
    final nombreCliente = cliente?.nombreCompleto;
    if (nombreCliente != null && nombreCliente.trim().isNotEmpty) {
      return nombreCliente;
    }
    if (clienteId != null) return 'Cliente #$clienteId';
    return 'Cliente no disponible';
  }

  String get cajeroMostrado {
    final nombreCajero = cajeroNombre?.trim();
    if (nombreCajero != null && nombreCajero.isNotEmpty) return nombreCajero;
    if (usuarioId != null) return 'Usuario #$usuarioId';
    return 'No disponible';
  }

  factory RentaReporte.fromJson(Map<String, dynamic> json) {
    return RentaReporte(
      rentaId: _parseInt(json['renta_id']),
      fecha: _parseDate(json['fecha']),
      clienteId: _parseInt(json['cliente_id']),
      usuarioId: _parseInt(json['usuario_id']),
      total: _parseDouble(json['total']),
      estadoPago: EstadoPagoReporte.fromValue(json['estado_de_pago']),
    );
  }
}

class DetalleRentaReporte {
  const DetalleRentaReporte({
    this.detalleRentaId,
    this.rentaId,
    this.equipoId,
    required this.equipoNombre,
    this.equipoTipo,
    this.horaInicio,
    required this.tiempoDeRenta,
    this.tiempoAgregado,
    this.horaFin,
    required this.subtotal,
    required this.estado,
  });

  final int? detalleRentaId;
  final int? rentaId;
  final int? equipoId;
  final String equipoNombre;
  final String? equipoTipo;
  final DateTime? horaInicio;
  final int tiempoDeRenta;
  final int? tiempoAgregado;
  final DateTime? horaFin;
  final double subtotal;
  final EstadoRentaReporte estado;

  int get tiempoTotal => tiempoDeRenta + (tiempoAgregado ?? 0);

  factory DetalleRentaReporte.fromJson(Map<String, dynamic> json) {
    final equipoId = _parseInt(json['equipo_id']);
    final nombre = _parseNullableString(json['equipo_nombre']);
    return DetalleRentaReporte(
      detalleRentaId: _parseInt(json['detalle_renta_id']),
      rentaId: _parseInt(json['renta_id']),
      equipoId: equipoId,
      equipoNombre:
          nombre ??
          (equipoId == null ? 'Equipo no disponible' : 'Equipo #$equipoId'),
      equipoTipo: _parseNullableString(json['equipo_tipo']),
      horaInicio: _parseDate(json['hora_inicio']),
      tiempoDeRenta: _parseInt(json['tiempo_de_renta']) ?? 0,
      tiempoAgregado: _parseInt(json['tiempo_agregado']),
      horaFin: _parseDate(json['hora_fin']),
      subtotal: _parseDouble(json['subtotal']),
      estado: EstadoRentaReporte.fromValue(json['estado']),
    );
  }
}

class RentaDetalleCompleto {
  const RentaDetalleCompleto({required this.renta, required this.detalles});

  final RentaReporte renta;
  final List<DetalleRentaReporte> detalles;

  double get total => renta.total;
}

class ReporteAdminData {
  const ReporteAdminData({
    required this.ventas,
    required this.rentas,
    required this.productos,
    required this.clientesPorId,
    required this.productosPorId,
    required this.equiposPorId,
    required this.usuariosPorId,
  });

  final List<VentaReporte> ventas;
  final List<RentaReporte> rentas;
  final List<ProductoReporte> productos;
  final Map<int, ClienteReporte> clientesPorId;
  final Map<int, ProductoReporte> productosPorId;
  final Map<int, Equipo> equiposPorId;
  final Map<int, String> usuariosPorId;

  double get totalVentas =>
      ventas.fold(0, (total, venta) => total + venta.total);
  double get totalRentas =>
      rentas.fold(0, (total, renta) => total + renta.total);
  int get productosStockBajo =>
      productos.where((producto) => producto.stockBajo).length;
  int get rentasPendientes => rentas
      .where((renta) => renta.estadoPago == EstadoPagoReporte.pendiente)
      .length;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _parseDouble(dynamic value) => _parseNullableDouble(value) ?? 0;

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _parseString(dynamic value) {
  if (value is String) return value;
  if (value == null) return '';
  return '$value';
}

String? _parseNullableString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value == null) return null;
  final texto = '$value'.trim();
  return texto.isEmpty ? null : texto;
}

bool _parseBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is String) {
    final texto = value.toLowerCase();
    if (texto == 'true') return true;
    if (texto == 'false') return false;
  }
  if (value is num) return value != 0;
  return fallback;
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}
