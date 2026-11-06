class NotificacionApp {
  const NotificacionApp({
    required this.notificacionId,
    required this.usuarioDestinoId,
    required this.tipo,
    required this.detalleRentaId,
    required this.titulo,
    required this.mensaje,
    required this.creadaEn,
    this.leidaEn,
  });

  final int notificacionId;
  final int usuarioDestinoId;
  final String tipo;
  final int detalleRentaId;
  final String titulo;
  final String mensaje;
  final DateTime creadaEn;
  final DateTime? leidaEn;

  bool get estaLeida => leidaEn != null;

  factory NotificacionApp.fromJson(Map<String, dynamic> json) {
    return NotificacionApp(
      notificacionId: json['notificacion_id'] as int? ?? 0,
      usuarioDestinoId: json['usuario_destino_id'] as int? ?? 0,
      tipo: json['tipo'] as String? ?? 'TIEMPO_TERMINADO',
      detalleRentaId: json['detalle_renta_id'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? '',
      creadaEn: DateTime.tryParse(json['creada_en']?.toString() ?? '') ??
          DateTime.now(),
      leidaEn: json['leida_en'] != null
          ? DateTime.tryParse(json['leida_en'].toString())
          : null,
    );
  }
}

