import 'package:cybercafe_app_mobile/models/equipo.dart';
import 'package:cybercafe_app_mobile/utils/equipo_filtros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final equipos = [
    _equipo(1, 'Pc-1', EstadoEquipo.disponible),
    _equipo(2, 'Pc-2', EstadoEquipo.daniosMenores),
    _equipo(3, 'Consola-1', EstadoEquipo.defectuoso),
    _equipo(4, 'Pc-3', EstadoEquipo.enMantenimiento),
    _equipo(5, 'Pc-4', EstadoEquipo.disponible),
  ];

  List<int> ids(List<Equipo> resultado) {
    return resultado.map((equipo) => equipo.equipoId!).toList();
  }

  test('filtra por nombre sin distinguir mayúsculas ni espacios', () {
    expect(ids(filtrarEquipos(equipos, busqueda: '  consola ')), [3]);
    expect(ids(filtrarEquipos(equipos, busqueda: 'PC-2')), [2]);
    expect(ids(filtrarEquipos(equipos, busqueda: 'pc')), [1, 2, 4, 5]);
  });

  test('filtra por disponible', () {
    final resultado = filtrarEquipos(
      equipos,
      filtros: {FiltroEquipo.disponible},
    );

    expect(ids(resultado), [1, 5]);
  });

  test('filtra por ambos tipos de daños', () {
    final resultado = filtrarEquipos(equipos, filtros: {FiltroEquipo.danios});

    expect(ids(resultado), [2, 3]);
  });

  test('filtra por mantenimiento', () {
    final resultado = filtrarEquipos(
      equipos,
      filtros: {FiltroEquipo.mantenimiento},
    );

    expect(ids(resultado), [4]);
  });

  test('filtra por equipos pendientes de revisión', () {
    final resultado = filtrarEquipos(
      equipos,
      filtros: {FiltroEquipo.pendienteRevision},
      estaPendienteRevision: (equipo) => equipo.equipoId == 5,
    );

    expect(ids(resultado), [5]);
  });

  test('un equipo pendiente no aparece en los filtros de estado', () {
    final resultado = filtrarEquipos(
      equipos,
      filtros: {FiltroEquipo.disponible},
      estaPendienteRevision: (equipo) => equipo.equipoId == 5,
    );

    expect(ids(resultado), [1]);
  });

  test('combina varias categorías con lógica OR', () {
    final resultado = filtrarEquipos(
      equipos,
      filtros: {FiltroEquipo.disponible, FiltroEquipo.mantenimiento},
    );

    expect(ids(resultado), [1, 4, 5]);
  });

  test('combina búsqueda y filtros', () {
    final resultado = filtrarEquipos(
      equipos,
      busqueda: 'sola',
      filtros: {FiltroEquipo.danios},
    );

    expect(ids(resultado), [3]);
  });

  test('sin filtros devuelve todos los equipos', () {
    expect(ids(filtrarEquipos(equipos, filtros: {})), [1, 2, 3, 4, 5]);
  });

  test('devuelve vacío cuando no hay coincidencias', () {
    expect(filtrarEquipos(equipos, busqueda: 'no-existe'), isEmpty);
  });
}

Equipo _equipo(int id, String nombre, EstadoEquipo estado) {
  return Equipo(
    equipoId: id,
    nombre: nombre,
    tarifaPorHora: 1,
    tipo: TipoEquipo.pc,
    estado: estado,
  );
}
