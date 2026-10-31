import 'reporte_formatters.dart';

String formatearTiempoRestante(Duration restante) {
  if (restante <= Duration.zero) return 'Tiempo agotado';

  final minutos = (restante.inSeconds / 60).ceil();
  if (minutos < 60) {
    return minutos == 1 ? 'Queda 1 min' : 'Quedan $minutos min';
  }

  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  if (resto == 0) {
    return horas == 1 ? 'Queda 1 h' : 'Quedan $horas h';
  }
  return 'Quedan $horas h ${resto.toString().padLeft(2, '0')} min';
}

String formatearHoraFinalizacion(DateTime hora) {
  return 'Finaliza a las ${formatearHora(hora)}';
}
