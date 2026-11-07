import '../models/equipo.dart';

/// Categorías disponibles para filtrar el listado de equipos del asistente.
enum FiltroEquipo {
  disponible('Disponible'),
  danios('Daños'),
  mantenimiento('En mantenimiento'),
  pendienteRevision('Pendiente de revisión');

  const FiltroEquipo(this.etiqueta);

  final String etiqueta;
}

bool coincideConFiltros(
  Equipo equipo, {
  required Set<FiltroEquipo> filtros,
  required bool pendienteRevision,
}) {
  if (filtros.isEmpty) return true;
  if (pendienteRevision) {
    return filtros.contains(FiltroEquipo.pendienteRevision);
  }

  return filtros.any((filtro) {
    return switch (filtro) {
      FiltroEquipo.disponible => equipo.estado == EstadoEquipo.disponible,
      FiltroEquipo.danios =>
        equipo.estado == EstadoEquipo.daniosMenores ||
            equipo.estado == EstadoEquipo.defectuoso,
      FiltroEquipo.mantenimiento =>
        equipo.estado == EstadoEquipo.enMantenimiento,
      FiltroEquipo.pendienteRevision => false,
    };
  });
}

List<Equipo> filtrarEquipos(
  List<Equipo> equipos, {
  String busqueda = '',
  Set<FiltroEquipo> filtros = const {},
  bool Function(Equipo equipo)? estaPendienteRevision,
}) {
  final termino = busqueda.trim().toLowerCase();

  return equipos
      .where((equipo) {
        if (termino.isNotEmpty &&
            !equipo.nombre.toLowerCase().contains(termino)) {
          return false;
        }

        return coincideConFiltros(
          equipo,
          filtros: filtros,
          pendienteRevision: estaPendienteRevision?.call(equipo) ?? false,
        );
      })
      .toList(growable: false);
}
