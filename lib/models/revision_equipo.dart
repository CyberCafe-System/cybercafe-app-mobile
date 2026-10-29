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
    required this.inspeccionPasada,
    required this.observaciones,
    this.fechaRevision,
    this.componentesAfectados,
  });

  final int? revisionEquipoId;
  final int detalleRentaId;
  final int? usuarioId;
  final String? usuarioNombre;
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

    return RevisionEquipo(
      revisionEquipoId: _parseInt(json['revision_equipo_id']),
      detalleRentaId: detalleRentaId,
      usuarioId: _parseInt(json['usuario_id']),
      usuarioNombre: usuarioNombre is String && usuarioNombre.trim().isNotEmpty
          ? usuarioNombre.trim()
          : null,
      inspeccionPasada: inspeccionPasada,
      observaciones: observaciones,
      fechaRevision: fechaRevision is String
          ? DateTime.tryParse(fechaRevision)
          : null,
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
