String formatearMoneda(num valor) => '\$${valor.toStringAsFixed(2)}';

String formatearFecha(DateTime? fecha, {String vacio = 'No disponible'}) {
  if (fecha == null) return vacio;
  final local = fecha.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  return '$dia/$mes/${local.year}';
}

String formatearFechaHora(DateTime? fecha, {String vacio = 'No disponible'}) {
  if (fecha == null) return vacio;
  final local = fecha.toLocal();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '${formatearFecha(local)} · $hora:$minuto';
}

String formatearHora(DateTime? fecha, {String vacio = 'No disponible'}) {
  if (fecha == null) return vacio;
  final local = fecha.toLocal();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

String formatearDuracion(int minutos) {
  if (minutos <= 0) return '0 min';
  final horas = minutos ~/ 60;
  final restantes = minutos % 60;
  if (horas == 0) return '$restantes min';
  if (restantes == 0) return '${horas}h';
  return '${horas}h ${restantes}m';
}

String formatearTelefono(int? telefono) {
  if (telefono == null) return 'No disponible';
  final texto = telefono.toString();
  if (texto.length == 8) {
    return '${texto.substring(0, 4)}-${texto.substring(4)}';
  }
  return texto;
}

String diaCorto(DateTime fecha) {
  const nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  return nombres[fecha.weekday - 1];
}

String fechaISO(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year.toString().padLeft(4, '0')}-$mes-$dia';
}
