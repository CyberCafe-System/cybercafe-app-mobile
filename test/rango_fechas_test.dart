import 'package:cybercafe_app_mobile/utils/rango_fechas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rangoDisponible', () {
    test('calcula los extremos ignorando fechas nulas y la hora', () {
      final rango = rangoDisponible([
        null,
        DateTime(2026, 3, 15, 18, 30),
        DateTime(2026, 1, 2, 8),
        DateTime(2026, 5, 20, 23, 59),
      ]);

      expect(rango, isNotNull);
      expect(rango!.start, DateTime(2026, 1, 2));
      expect(rango.end, DateTime(2026, 5, 20));
    });

    test('devuelve null cuando no hay fechas válidas', () {
      expect(rangoDisponible([null, null]), isNull);
    });
  });

  group('estaEnRango', () {
    final rango = DateTimeRange(
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 31),
    );

    test('incluye los días límite sin importar la hora', () {
      expect(estaEnRango(DateTime(2026, 3, 1, 0, 1), rango), isTrue);
      expect(estaEnRango(DateTime(2026, 3, 31, 23, 59), rango), isTrue);
      expect(estaEnRango(DateTime(2026, 3, 15, 12), rango), isTrue);
    });

    test('excluye fechas fuera del rango y valores nulos', () {
      expect(estaEnRango(DateTime(2026, 2, 28, 23, 59), rango), isFalse);
      expect(estaEnRango(DateTime(2026, 4, 1), rango), isFalse);
      expect(estaEnRango(null, rango), isFalse);
    });
  });
}
