import 'package:flutter/material.dart';

/// Devuelve la fecha sin hora para comparar rangos por día.
DateTime fechaSinHora(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

/// Indica si [fecha] cae dentro del rango inclusivo de [rango].
bool estaEnRango(DateTime? fecha, DateTimeRange rango) {
  if (fecha == null) return false;
  final dia = fechaSinHora(fecha);
  return !dia.isBefore(fechaSinHora(rango.start)) &&
      !dia.isAfter(fechaSinHora(rango.end));
}

/// Calcula el rango disponible a partir de las fechas de los registros.
DateTimeRange? rangoDisponible(Iterable<DateTime?> fechas) {
  DateTime? menor;
  DateTime? mayor;
  for (final fecha in fechas) {
    if (fecha == null) continue;
    final dia = fechaSinHora(fecha);
    if (menor == null || dia.isBefore(menor)) menor = dia;
    if (mayor == null || dia.isAfter(mayor)) mayor = dia;
  }
  if (menor == null || mayor == null) return null;
  return DateTimeRange(start: menor, end: mayor);
}

/// Abre el selector de rango de fechas para exportar un PDF.
Future<DateTimeRange?> seleccionarRangoFechas(
  BuildContext context, {
  required Iterable<DateTime?> fechas,
}) {
  final disponibles = rangoDisponible(fechas);
  final hoy = fechaSinHora(DateTime.now());
  final primerDia =
      disponibles?.start ?? DateTime(hoy.year - 1, hoy.month, hoy.day);
  final ultimoDia = disponibles?.end ?? hoy;
  final lastDate = ultimoDia.isAfter(hoy) ? ultimoDia : hoy;

  return showDateRangePicker(
    context: context,
    firstDate: primerDia,
    lastDate: lastDate,
    helpText: 'Selecciona el rango de fechas',
    cancelText: 'Cancelar',
    confirmText: 'Aplicar',
    saveText: 'Aplicar',
    fieldStartLabelText: 'Desde',
    fieldEndLabelText: 'Hasta',
    fieldStartHintText: 'dd/mm/aaaa',
    fieldEndHintText: 'dd/mm/aaaa',
    errorFormatText: 'Usa el formato dd/mm/aaaa',
    errorInvalidText: 'Fecha fuera del rango disponible',
    errorInvalidRangeText: 'La fecha final debe ser posterior a la inicial',
  );
}
