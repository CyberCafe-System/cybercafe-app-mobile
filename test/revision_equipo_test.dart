import 'package:cybercafe_app_mobile/models/revision_equipo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponenteRevisionItem.toJson', () {
    test('incluye solo los campos informados', () {
      const item = ComponenteRevisionItem(componenteId: 7);

      expect(item.toJson(), {'componente_id': 7});
    });

    test('incluye estado y descripción de daño', () {
      const item = ComponenteRevisionItem(
        componenteId: 7,
        nombre: 'Monitor',
        estado: 'Requiere reemplazo',
        descripcionDanio: 'Pantalla con líneas',
      );

      expect(item.toJson(), {
        'componente_id': 7,
        'nombre': 'Monitor',
        'estado': 'Requiere reemplazo',
        'descripcion_danio': 'Pantalla con líneas',
      });
    });
  });

  group('RevisionEquipo.toCreateJson', () {
    test('omite componentes_afectados cuando no se envían', () {
      const revision = RevisionEquipo(
        detalleRentaId: 12,
        inspeccionPasada: true,
        observaciones: 'Todo en orden',
      );

      final json = revision.toCreateJson();

      expect(json['detalle_renta_id'], 12);
      expect(json['inspeccion_pasada'], isTrue);
      expect(json['observaciones'], 'Todo en orden');
      expect(json.containsKey('componentes_afectados'), isFalse);
    });

    test('incluye componentes afectados cuando existen', () {
      const revision = RevisionEquipo(
        detalleRentaId: 12,
        inspeccionPasada: false,
        observaciones: 'Monitor dañado',
        componentesAfectados: [
          ComponenteRevisionItem(
            componenteId: 7,
            estado: 'Daños menores',
            descripcionDanio: 'Rayón en la pantalla',
          ),
        ],
      );

      final json = revision.toCreateJson();
      final componentes = json['componentes_afectados'] as List;

      expect(componentes, hasLength(1));
      expect(componentes.first, {
        'componente_id': 7,
        'estado': 'Daños menores',
        'descripcion_danio': 'Rayón en la pantalla',
      });
    });
  });
}
