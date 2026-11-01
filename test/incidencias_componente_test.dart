import 'package:cybercafe_app_mobile/models/componente.dart';
import 'package:cybercafe_app_mobile/utils/incidencias_componente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Parser de observaciones', () {
    test('extrae bloques estructurados en el orden recibido', () {
      const observaciones = '''
[REVISIÓN: #12 | FECHA: 31/10/2026 14:20]
Descripción: Mouse con botón izquierdo fallando
--------------------------------------------------
[REVISIÓN: #8 | FECHA: 27/10/2026 09:05]
Descripción: Cable desgastado
--------------------------------------------------
''';

      final incidencias = parsearIncidenciasComponente(observaciones);

      expect(incidencias, hasLength(2));
      expect(incidencias.first.revisionId, 12);
      expect(incidencias.first.fechaTexto, '31/10/2026 14:20');
      expect(
        incidencias.first.descripcion,
        'Mouse con botón izquierdo fallando',
      );
      expect(incidencias.last.revisionId, 8);
      expect(incidencias.last.descripcion, 'Cable desgastado');
    });

    test('acepta observaciones de texto libre como una incidencia', () {
      final incidencias = parsearIncidenciasComponente(
        'Descripción: El teclado no enciende',
      );

      expect(incidencias, hasLength(1));
      expect(incidencias.single.revisionId, isNull);
      expect(incidencias.single.fechaTexto, isNull);
      expect(incidencias.single.descripcion, 'El teclado no enciende');
    });

    test(
      'devuelve vacío para observaciones nulas, vacías o sin texto útil',
      () {
        expect(parsearIncidenciasComponente(null), isEmpty);
        expect(parsearIncidenciasComponente('   '), isEmpty);
        expect(
          parsearIncidenciasComponente(
            '--------------------------------------------------',
          ),
          isEmpty,
        );
      },
    );
  });

  group('Filtro y búsqueda de componentes', () {
    final mouse = _componente(
      nombre: 'Mouse Óptico',
      numeroSerie: 'SN-001',
      tipo: TipoComponente.mouse,
      descripcion: 'Mouse negro',
      observaciones: '''
[REVISIÓN: #12 | FECHA: 31/10/2026 14:20]
Descripción: Botón izquierdo fallando
--------------------------------------------------
''',
    );
    final teclado = _componente(
      nombre: 'Teclado Mecánico',
      tipo: TipoComponente.teclado,
      descripcion: 'Teclado RGB',
    );
    final monitor = _componente(
      nombre: 'Monitor LED',
      numeroSerie: 'SN-003',
      tipo: TipoComponente.monitor,
      descripcion: 'Pantalla de 24 pulgadas',
      observaciones: 'Pixel muerto',
    );
    final componentes = [teclado, mouse, monitor];

    test('sin consulta ni filtro conserva todos los componentes', () {
      expect(filtrarComponentesIncidencias(componentes), hasLength(3));
    });

    test('busca por nombre, serie, tipo, descripción y observaciones', () {
      expect(
        _nombres(
          filtrarComponentesIncidencias(componentes, consulta: 'optico'),
        ),
        ['Mouse Óptico'],
      );
      expect(
        _nombres(
          filtrarComponentesIncidencias(componentes, consulta: 'sn-003'),
        ),
        ['Monitor LED'],
      );
      expect(
        _nombres(
          filtrarComponentesIncidencias(componentes, consulta: 'teclado'),
        ),
        ['Teclado Mecánico'],
      );
      expect(
        _nombres(
          filtrarComponentesIncidencias(componentes, consulta: 'pantalla'),
        ),
        ['Monitor LED'],
      );
      expect(
        _nombres(
          filtrarComponentesIncidencias(componentes, consulta: 'pixel muerto'),
        ),
        ['Monitor LED'],
      );
      expect(
        _nombres(
          filtrarComponentesIncidencias(
            componentes,
            consulta: 'boton izquierdo',
          ),
        ),
        ['Mouse Óptico'],
      );
    });

    test('filtra componentes con y sin incidencias', () {
      final conIncidencias = filtrarComponentesIncidencias(
        componentes,
        filtro: FiltroIncidenciasComponente.conIncidencias,
      );
      final sinIncidencias = filtrarComponentesIncidencias(
        componentes,
        filtro: FiltroIncidenciasComponente.sinIncidencias,
      );

      expect(_nombres(conIncidencias), ['Monitor LED', 'Mouse Óptico']);
      expect(_nombres(sinIncidencias), ['Teclado Mecánico']);
    });

    test('combina búsqueda y filtro', () {
      final filtrados = filtrarComponentesIncidencias(
        componentes,
        consulta: 'pixel',
        filtro: FiltroIncidenciasComponente.conIncidencias,
      );

      expect(_nombres(filtrados), ['Monitor LED']);
      expect(
        filtrarComponentesIncidencias(
          componentes,
          consulta: 'mouse',
          filtro: FiltroIncidenciasComponente.sinIncidencias,
        ),
        isEmpty,
      );
    });

    test('ordena primero los componentes con incidencias', () {
      final ordenados = filtrarComponentesIncidencias([
        _componente(nombre: 'A sin incidencias', tipo: TipoComponente.control),
        _componente(
          nombre: 'Z con incidencias',
          tipo: TipoComponente.control,
          observaciones: 'Falla',
        ),
        _componente(
          nombre: 'B con incidencias',
          tipo: TipoComponente.control,
          observaciones: 'Falla',
        ),
      ]);

      expect(_nombres(ordenados), [
        'B con incidencias',
        'Z con incidencias',
        'A sin incidencias',
      ]);
    });

    test('usa valores de respaldo para serie y descripción ausentes', () {
      expect(numeroSerieComponente(teclado), 'No registrado');
      expect(
        descripcionComponente(
          _componente(nombre: 'Control', tipo: TipoComponente.control),
        ),
        'Sin descripción',
      );
      expect(componenteTieneIncidencias(teclado), isFalse);
      expect(componenteTieneIncidencias(mouse), isTrue);
    });
  });
}

Componente _componente({
  required String nombre,
  required TipoComponente tipo,
  String? numeroSerie,
  String? descripcion,
  String? observaciones,
}) {
  return Componente(
    nombre: nombre,
    numeroSerie: numeroSerie,
    tipo: tipo,
    estado: EstadoComponente.disponible,
    descripcion: descripcion,
    observaciones: observaciones,
  );
}

List<String> _nombres(List<Componente> componentes) {
  return componentes.map((componente) => componente.nombre).toList();
}
