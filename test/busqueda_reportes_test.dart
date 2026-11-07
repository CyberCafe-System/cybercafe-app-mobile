import 'package:cybercafe_app_mobile/models/reporte_admin.dart';
import 'package:cybercafe_app_mobile/utils/busqueda_reportes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cliente = ClienteReporte(
    clienteId: 1,
    nombre: 'Ana',
    apellido: 'Pérez',
    dui: '01234567-8',
    direccion: 'San Salvador',
  );

  group('normalización e IDs', () {
    test('ignora mayúsculas, tildes y espacios extra', () {
      expect(normalizarTextoBusqueda('  Café   AMERICANO '), 'cafe americano');
    });

    test('reconoce IDs con # y prefijo de venta o renta', () {
      expect(idDesdeBusqueda('10'), 10);
      expect(idDesdeBusqueda('#12'), 12);
      expect(idDesdeBusqueda('Venta 10'), 10);
      expect(idDesdeBusqueda('renta #20'), 20);
      expect(idDesdeBusqueda('Ana Pérez'), isNull);
    });
  });

  group('búsqueda de ventas', () {
    const venta = VentaReporte(
      ventaId: 10,
      clienteId: 1,
      cliente: cliente,
      cajeroNombre: 'Cajero Uno',
      subtotal: 10,
      iva: 1.3,
      total: 11.3,
    );

    test('encuentra por cliente sin tildes', () {
      expect(coincideVenta(venta, 'ana perez'), isTrue);
      expect(coincideVenta(venta, 'Pérez'), isTrue);
    });

    test('encuentra por ID exacto y cajero', () {
      expect(coincideVenta(venta, '#10'), isTrue);
      expect(coincideVenta(venta, 'venta 10'), isTrue);
      expect(coincideVenta(venta, 'cajero uno'), isTrue);
      expect(coincideVenta(venta, '#11'), isFalse);
    });

    test('no busca por fecha ni por otros campos', () {
      expect(coincideVenta(venta, '2026'), isFalse);
    });
  });

  group('búsqueda de rentas', () {
    const renta = RentaReporte(
      rentaId: 20,
      clienteId: 1,
      cliente: cliente,
      total: 3.5,
      estadoPago: EstadoPagoReporte.pendiente,
      estadosRenta: {
        EstadoRentaReporte.activa,
        EstadoRentaReporte.pendienteRevision,
      },
    );

    test('encuentra por cliente e ID', () {
      expect(coincideRenta(renta, 'ana perez'), isTrue);
      expect(coincideRenta(renta, 'renta 20'), isTrue);
      expect(coincideRenta(renta, '#21'), isFalse);
    });

    test('encuentra por estado de pago y estado operativo', () {
      expect(coincideRenta(renta, 'pendiente'), isTrue);
      expect(coincideRenta(renta, 'activa'), isTrue);
      expect(coincideRenta(renta, 'pendiente revision'), isTrue);
      expect(coincideRenta(renta, 'pagado'), isFalse);
    });
  });

  group('búsqueda de inventario', () {
    const producto = ProductoReporte(
      productoId: 7,
      categoriaId: 2,
      nombre: 'Café Americano',
      precioCompra: 0.5,
      precioVenta: 1.5,
      cantidad: 3,
      activo: true,
      categoriaNombre: 'Bebidas',
    );

    test('encuentra por nombre o categoría', () {
      expect(coincideProducto(producto, 'cafe'), isTrue);
      expect(coincideProducto(producto, 'cafe americano'), isTrue);
      expect(coincideProducto(producto, 'bebidas'), isTrue);
      expect(coincideProducto(producto, 'postres'), isFalse);
    });

    test('no busca por estado de stock ni disponibilidad', () {
      expect(coincideProducto(producto, 'stock bajo'), isFalse);
      expect(coincideProducto(producto, 'activo'), isFalse);
    });
  });
}
