import '../models/revision_historial.dart';

/// Categorías para filtrar las incidencias de equipos del historial.
enum FiltroHistorialEquipo {
  todos('Todos'),
  disponibles('Disponibles'),
  conDanios('Con daños');

  const FiltroHistorialEquipo(this.etiqueta);

  final String etiqueta;
}

/// Filtra las incidencias por nombre de equipo y resultado de la revisión.
///
/// Una revisión aprobada representa un equipo que quedó disponible; una no
/// aprobada representa un equipo con daños.
List<RevisionHistorialItem> filtrarHistorialEquipos(
  List<RevisionHistorialItem> historial, {
  String busqueda = '',
  FiltroHistorialEquipo filtro = FiltroHistorialEquipo.todos,
}) {
  final termino = busqueda.trim().toLowerCase();

  return historial
      .where((item) {
        if (termino.isNotEmpty &&
            !item.equipoNombre.toLowerCase().contains(termino)) {
          return false;
        }

        return switch (filtro) {
          FiltroHistorialEquipo.todos => true,
          FiltroHistorialEquipo.disponibles => item.revision.inspeccionPasada,
          FiltroHistorialEquipo.conDanios => !item.revision.inspeccionPasada,
        };
      })
      .toList(growable: false);
}
