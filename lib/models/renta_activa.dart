class RentaActivaEquipo {
  const RentaActivaEquipo({
    required this.detalleRentaId,
    required this.rentaId,
    required this.equipoId,
    required this.tiempoTotal,
    required this.minutosTranscurridos,
    required this.minutosRestantes,
    required this.consultadaEn,
    this.horaInicio,
    this.clienteNombre,
    this.subtotal = 0,
  });

  final int detalleRentaId;
  final int rentaId;
  final int equipoId;
  final DateTime? horaInicio;
  final int tiempoTotal;
  final int minutosTranscurridos;
  final int minutosRestantes;
  final double subtotal;
  final DateTime consultadaEn;
  final String? clienteNombre;

  Duration restanteEn(DateTime ahora) {
    final transcurrido = ahora.difference(consultadaEn);
    final restante = Duration(minutes: minutosRestantes) - transcurrido;
    return restante.isNegative ? Duration.zero : restante;
  }

  DateTime get horaFinalizacion =>
      consultadaEn.add(Duration(minutes: minutosRestantes));

  double progresoEn(DateTime ahora) {
    final totalSegundos = tiempoTotal * 60;
    if (totalSegundos <= 0) return 1;
    final restanteSegundos = restanteEn(ahora).inSeconds;
    final transcurridoSegundos = totalSegundos - restanteSegundos;
    return (transcurridoSegundos / totalSegundos).clamp(0.0, 1.0);
  }

  RentaActivaEquipo conCliente(String? nombre) {
    return RentaActivaEquipo(
      detalleRentaId: detalleRentaId,
      rentaId: rentaId,
      equipoId: equipoId,
      tiempoTotal: tiempoTotal,
      minutosTranscurridos: minutosTranscurridos,
      minutosRestantes: minutosRestantes,
      consultadaEn: consultadaEn,
      horaInicio: horaInicio,
      clienteNombre: nombre,
      subtotal: subtotal,
    );
  }

  factory RentaActivaEquipo.fromJson(
    Map<String, dynamic> json, {
    DateTime? consultadaEn,
  }) {
    final tiempoTotal = _parseInt(json['tiempo_total']) ?? 0;
    final minutosTranscurridos = _parseInt(json['minutos_transcurridos']) ?? 0;
    final minutosRestantes =
        _parseInt(json['minutos_restantes']) ??
        (tiempoTotal - minutosTranscurridos).clamp(0, tiempoTotal).toInt();

    return RentaActivaEquipo(
      detalleRentaId: _parseInt(json['detalle_renta_id']) ?? 0,
      rentaId: _parseInt(json['renta_id']) ?? 0,
      equipoId: _parseInt(json['equipo_id']) ?? 0,
      horaInicio: _parseDate(json['hora_inicio']),
      tiempoTotal: tiempoTotal,
      minutosTranscurridos: minutosTranscurridos,
      minutosRestantes: minutosRestantes,
      subtotal: _parseDouble(json['subtotal']),
      consultadaEn: consultadaEn ?? DateTime.now(),
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}
