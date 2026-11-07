import '../utils/reporte_formatters.dart';

class ComponenteRevisionItem {
  const ComponenteRevisionItem({
    this.componenteId,
    this.nombre,
    this.estado,
    this.descripcionDanio,
  });

  final int? componenteId;
  final String? nombre;
  final String? estado;
  final String? descripcionDanio;

  Map<String, dynamic> toJson() {
    return {
      if (componenteId != null) 'componente_id': componenteId,
      if (nombre != null && nombre!.trim().isNotEmpty) 'nombre': nombre,
      if (estado != null && estado!.trim().isNotEmpty) 'estado': estado,
      if (descripcionDanio != null && descripcionDanio!.trim().isNotEmpty)
        'descripcion_danio': descripcionDanio,
    };
  }
}

class RevisionEquipo {
  const RevisionEquipo({
    this.revisionEquipoId,
    required this.detalleRentaId,
    this.usuarioId,
    this.usuarioNombre,
    this.equipoId,
    this.equipoNombre,
    this.equipoTipo,
    this.clienteNombre,
    required this.inspeccionPasada,
    required this.observaciones,
    this.fechaRevision,
    this.componentesAfectados,
  });

  final int? revisionEquipoId;
  final int detalleRentaId;
  final int? usuarioId;
  final String? usuarioNombre;
  final int? equipoId;
  final String? equipoNombre;
  final String? equipoTipo;
  final String? clienteNombre;
  final bool inspeccionPasada;
  final String observaciones;
  final DateTime? fechaRevision;
  final List<ComponenteRevisionItem>? componentesAfectados;

  factory RevisionEquipo.fromJson(Map<String, dynamic> json) {
    final detalleRentaId = _parseInt(json['detalle_renta_id']);
    if (detalleRentaId == null) {
      throw const FormatException('El detalle_renta_id es obligatorio');
    }

    final inspeccionPasada = json['inspeccion_pasada'];
    if (inspeccionPasada is! bool) {
      throw const FormatException('El campo inspeccion_pasada debe ser bool');
    }

    final observaciones = json['observaciones'];
    if (observaciones is! String) {
      throw const FormatException('El campo observaciones debe ser texto');
    }

    final fechaRevision = json['fecha_revision'];
    final usuarioNombre = json['usuario_nombre'];
    final equipoNombre = json['equipo_nombre'];
    final equipoTipo = json['equipo_tipo'];
    final clienteNombre = json['cliente_nombre'];

    return RevisionEquipo(
      revisionEquipoId: _parseInt(json['revision_equipo_id']),
      detalleRentaId: detalleRentaId,
      usuarioId: _parseInt(json['usuario_id']),
      usuarioNombre: usuarioNombre is String && usuarioNombre.trim().isNotEmpty
          ? usuarioNombre.trim()
          : null,
      equipoId: _parseInt(json['equipo_id']),
      equipoNombre: equipoNombre is String && equipoNombre.trim().isNotEmpty
          ? equipoNombre.trim()
          : null,
      equipoTipo: equipoTipo is String && equipoTipo.trim().isNotEmpty
          ? equipoTipo.trim()
          : null,
      clienteNombre: clienteNombre is String && clienteNombre.trim().isNotEmpty
          ? clienteNombre.trim()
          : null,
      inspeccionPasada: inspeccionPasada,
      observaciones: observaciones,
      fechaRevision: parseApiUtcDateTime(fechaRevision),
    );
  }

  Map<String, dynamic> toCreateJson() {
    final componentes = componentesAfectados
        ?.where((item) => item.toJson().isNotEmpty)
        .map((item) => item.toJson())
        .toList();

    return {
      'detalle_renta_id': detalleRentaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      'inspeccion_pasada': inspeccionPasada,
      'observaciones': observaciones,
      if (componentes != null && componentes.isNotEmpty)
        'componentes_afectados': componentes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (revisionEquipoId != null) 'revision_equipo_id': revisionEquipoId,
      'detalle_renta_id': detalleRentaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (usuarioNombre != null) 'usuario_nombre': usuarioNombre,
      if (equipoId != null) 'equipo_id': equipoId,
      if (equipoNombre != null) 'equipo_nombre': equipoNombre,
      if (equipoTipo != null) 'equipo_tipo': equipoTipo,
      if (clienteNombre != null) 'cliente_nombre': clienteNombre,
      'inspeccion_pasada': inspeccionPasada,
      'observaciones': observaciones,
      if (fechaRevision != null)
        'fecha_revision': fechaRevision!.toUtc().toIso8601String(),
    };
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Valor entero inválido: $value');
}
