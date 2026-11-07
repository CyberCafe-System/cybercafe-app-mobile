import 'package:cybercafe_app_mobile/models/revision_equipo.dart';
import 'package:cybercafe_app_mobile/models/revision_historial.dart';
import 'package:cybercafe_app_mobile/utils/historial_equipo_filtros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final historial = [
    _item(1, 'Pc-1', inspeccionPasada: true),
    _item(2, 'Pc-2', inspeccionPasada: false),
    _item(3, 'Consola-1', inspeccionPasada: true),
    _item(4, 'Pc-3', inspeccionPasada: false),
  ];

  List<int> ids(List<RevisionHistorialItem> resultado) {
    return resultado.map((item) => item.revision.revisionEquipoId!).toList();
  }

  test('busca por nombre de equipo sin distinguir mayúsculas', () {
    expect(ids(filtrarHistorialEquipos(historial, busqueda: '  pc ')), [
      1,
      2,
      4,
    ]);
    expect(ids(filtrarHistorialEquipos(historial, busqueda: 'CONSOLA')), [3]);
  });

  test('el filtro todos devuelve todo el historial', () {
    expect(ids(filtrarHistorialEquipos(historial)), [1, 2, 3, 4]);
  });

  test('filtra las revisiones aprobadas como disponibles', () {
    final resultado = filtrarHistorialEquipos(
      historial,
      filtro: FiltroHistorialEquipo.disponibles,
    );

    expect(ids(resultado), [1, 3]);
  });

  test('filtra las revisiones no aprobadas como con daños', () {
    final resultado = filtrarHistorialEquipos(
      historial,
      filtro: FiltroHistorialEquipo.conDanios,
    );

    expect(ids(resultado), [2, 4]);
  });

  test('combina búsqueda y filtro', () {
    final resultado = filtrarHistorialEquipos(
      historial,
      busqueda: 'pc-3',
      filtro: FiltroHistorialEquipo.conDanios,
    );

    expect(ids(resultado), [4]);
  });

  test('devuelve vacío cuando no hay coincidencias', () {
    expect(filtrarHistorialEquipos(historial, busqueda: 'no-existe'), isEmpty);
  });
}

RevisionHistorialItem _item(
  int id,
  String equipoNombre, {
  required bool inspeccionPasada,
}) {
  return RevisionHistorialItem(
    revision: RevisionEquipo(
      revisionEquipoId: id,
      detalleRentaId: id,
      inspeccionPasada: inspeccionPasada,
      observaciones: '',
    ),
    equipoNombre: equipoNombre,
  );
}
