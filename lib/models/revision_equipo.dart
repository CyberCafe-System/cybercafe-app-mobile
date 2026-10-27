class RevisionEquipo {
  const RevisionEquipo({
    this.revisionEquipoId,
    required this.detalleRentaId,
    this.usuarioId,
    required this.inspeccionPasada,
    required this.observaciones,
    this.fechaRevision,
  });

  final int? revisionEquipoId;
  final int detalleRentaId;
  final int? usuarioId;
  final bool inspeccionPasada;
  final String observaciones;
  final DateTime? fechaRevision;

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

    return RevisionEquipo(
      revisionEquipoId: _parseInt(json['revision_equipo_id']),
      detalleRentaId: detalleRentaId,
      usuarioId: _parseInt(json['usuario_id']),
      inspeccionPasada: inspeccionPasada,
      observaciones: observaciones,
      fechaRevision: fechaRevision is String
          ? DateTime.tryParse(fechaRevision)
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'detalle_renta_id': detalleRentaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      'inspeccion_pasada': inspeccionPasada,
      'observaciones': observaciones,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (revisionEquipoId != null) 'revision_equipo_id': revisionEquipoId,
      'detalle_renta_id': detalleRentaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
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
