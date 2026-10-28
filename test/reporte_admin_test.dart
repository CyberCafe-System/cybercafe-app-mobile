import 'dart:convert';

import 'package:cybercafe_app_mobile/models/reporte_admin.dart';
import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/reporte_admin_service.dart';
import 'package:cybercafe_app_mobile/services/reporte_pdf_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Modelos de reportes', () {
    test('parsea ventas, productos y estados con decimales en texto', () {
      final venta = VentaReporte.fromJson({
        'venta_id': 10,
        'fecha': '2026-10-27T14:30:00Z',
        'cliente_id': 1,
        'usuario_id': 2,
        'subtotal': '10.00',
        'iva': '1.30',
      });

      expect(venta.ventaId, 10);
      expect(venta.total, 11.3);
      expect(venta.fecha, isNotNull);

      final producto = ProductoReporte.fromJson({
        'producto_id': 7,
        'categoria_id': 2,
        'nombre': 'Café Americano',
        'precio_compra': '0.50',
        'precio_venta': '1.50',
        'cantidad': 3,
        'activo': true,
      });
      final conCategoria = producto.conCategoria('Bebidas');

      expect(producto.stockBajo, isTrue);
      expect(conCategoria.nombre, 'Café Americano');
      expect(conCategoria.categoriaMostrada, 'Bebidas');
      expect(conCategoria.margen, 1.0);
      expect(EstadoPagoReporte.fromValue('Pagado'), EstadoPagoReporte.pagado);
      expect(
        EstadoRentaReporte.fromValue('Pendiente Revision'),
        EstadoRentaReporte.pendienteRevision,
      );
    });
  });

  group('ReporteAdminService', () {
    test('une ventas, rentas y productos con sus catálogos', () async {
      final auth = await _crearAuth();
      final service = ReporteAdminService(auth: auth);

      final data = await service.cargarReportes();

      expect(data.ventas, hasLength(1));
      expect(data.ventas.single.clienteMostrado, 'Ana Pérez');
      expect(data.ventas.single.cajeroMostrado, 'Cajero Uno');
      expect(data.ventas.single.total, 11.3);
      expect(data.rentas.single.clienteMostrado, 'Ana Pérez');
      expect(data.rentas.single.estadoPago, EstadoPagoReporte.pagado);
      expect(data.productos.single.categoriaMostrada, 'Bebidas');
      expect(data.productos.single.stockBajo, isTrue);
      expect(data.totalVentas, 11.3);
      expect(data.totalRentas, 3.5);
      expect(data.productosStockBajo, 1);
    });

    test('completa detalles de venta y renta con nombres reales', () async {
      final auth = await _crearAuth();
      final service = ReporteAdminService(auth: auth);
      await service.cargarReportes();

      final venta = await service.cargarDetalleVenta(10);
      expect(venta.detalles, hasLength(1));
      expect(venta.detalles.single.productoNombre, 'Café Americano');
      expect(venta.venta.clienteMostrado, 'Ana Pérez');

      final renta = await service.cargarDetalleRenta(20);
      expect(renta.detalles, hasLength(1));
      expect(renta.detalles.single.equipoNombre, 'PC-01');
      expect(renta.detalles.single.equipoTipo, 'PC');
      expect(renta.detalles.single.tiempoTotal, 75);
    });

    test('informa cuando no hay permisos para consultar reportes', () async {
      final cliente = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/oauth/login') {
          return _json({
            'access_token': _tokenConClaims(id: 1, username: 'admin', rolId: 1),
            'token_type': 'bearer',
          });
        }
        return http.Response('{"detail":"No autorizado"}', 403);
      });
      final auth = AuthService(
        client: cliente,
        storage: InMemoryTokenStorage(),
      );
      await auth.login(username: 'admin', password: 'secreta');
      final service = ReporteAdminService(auth: auth);

      await expectLater(
        service.cargarReportes(),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'mensaje',
            contains('permisos'),
          ),
        ),
      );
    });

    test('carga los KPIs y los últimos siete días del dashboard', () async {
      final auth = await _crearAuth();
      final service = ReporteAdminService(auth: auth);

      final dashboard = await service.cargarDashboard();

      expect(dashboard.general.totalClientes, 8);
      expect(dashboard.general.sesionesRentaActivas, 2);
      expect(dashboard.hoy.totalDia, 12.5);
      expect(dashboard.semana, hasLength(7));
      expect(dashboard.semana.last.fecha, isNotNull);
    });
  });

  group('ReportePdfService', () {
    test('genera archivos PDF con contenido', () async {
      final ventas = [
        VentaReporte(
          ventaId: 1,
          fecha: DateTime(2026, 10, 27, 10, 30),
          cliente: const ClienteReporte(
            clienteId: 1,
            nombre: 'Ana',
            apellido: 'Pérez',
            dui: '01234567-8',
            direccion: 'San Salvador',
          ),
          cajeroNombre: 'Cajero Uno',
          subtotal: 10,
          iva: 1.3,
          total: 11.3,
        ),
      ];
      final rentas = [
        RentaReporte(
          rentaId: 2,
          fecha: DateTime(2026, 10, 27, 11),
          cliente: const ClienteReporte(
            clienteId: 1,
            nombre: 'Ana',
            apellido: 'Pérez',
            dui: '01234567-8',
            direccion: 'San Salvador',
          ),
          cajeroNombre: 'Cajero Uno',
          total: 3.5,
          estadoPago: EstadoPagoReporte.pagado,
        ),
      ];
      final productos = [
        const ProductoReporte(
          productoId: 7,
          categoriaId: 2,
          nombre: 'Café Americano',
          precioCompra: 0.5,
          precioVenta: 1.5,
          cantidad: 3,
          activo: true,
          categoriaNombre: 'Bebidas',
        ),
      ];

      final ventasPdf = await ReportePdfService.instance.generarVentas(ventas);
      final rentasPdf = await ReportePdfService.instance.generarRentas(rentas);
      final inventarioPdf = await ReportePdfService.instance.generarInventario(
        productos,
      );

      expect(ventasPdf, isNotEmpty);
      expect(rentasPdf, isNotEmpty);
      expect(inventarioPdf, isNotEmpty);
    });
  });
}

Future<AuthService> _crearAuth() async {
  final cliente = MockClient(_responder);
  final auth = AuthService(client: cliente, storage: InMemoryTokenStorage());
  await auth.login(username: 'admin', password: 'secreta');
  return auth;
}

Future<http.Response> _responder(http.Request request) async {
  final path = request.url.path;

  if (request.method == 'POST' && path == '/oauth/login') {
    return _json({
      'access_token': _tokenConClaims(id: 1, username: 'admin', rolId: 1),
      'token_type': 'bearer',
    });
  }

  if (request.method == 'GET' && path == '/ventas') {
    return _json([
      {
        'venta_id': 10,
        'fecha': '2026-10-27T14:30:00Z',
        'cliente_id': 1,
        'usuario_id': 2,
        'subtotal': '10.00',
        'iva': '1.30',
      },
    ]);
  }

  if (request.method == 'GET' && path == '/ventas/10') {
    return _json({
      'venta': {
        'venta_id': 10,
        'fecha': '2026-10-27T14:30:00Z',
        'cliente_id': 1,
        'usuario_id': 2,
        'subtotal': '10.00',
        'iva': '1.30',
      },
      'detalles': [
        {
          'detalle_venta_id': 30,
          'venta_id': 10,
          'producto_id': 7,
          'precio_unitario': '1.50',
          'cantidad': 2,
          'subtotal': '3.00',
        },
      ],
      'total': '11.30',
    });
  }

  if (request.method == 'GET' && path == '/rentas') {
    return _json([
      {
        'renta_id': 20,
        'fecha': '2026-10-27T15:00:00Z',
        'cliente_id': 1,
        'usuario_id': 2,
        'total': '3.50',
        'estado_de_pago': 'Pagado',
      },
    ]);
  }

  if (request.method == 'GET' && path == '/rentas/20') {
    return _json({
      'renta': {
        'renta_id': 20,
        'fecha': '2026-10-27T15:00:00Z',
        'cliente_id': 1,
        'usuario_id': 2,
        'total': '3.50',
        'estado_de_pago': 'Pagado',
      },
      'detalles': [
        {
          'detalle_renta_id': 40,
          'renta_id': 20,
          'equipo_id': 5,
          'hora_inicio': '2026-10-27T15:00:00Z',
          'tiempo_de_renta': 60,
          'tiempo_agregado': 15,
          'hora_fin': '2026-10-27T16:15:00Z',
          'subtotal': '3.50',
          'estado': 'Finalizada',
        },
      ],
    });
  }

  if (request.method == 'GET' && path == '/productos') {
    return _json([
      {
        'producto_id': 7,
        'categoria_id': 2,
        'nombre': 'Café Americano',
        'precio_compra': '0.50',
        'precio_venta': '1.50',
        'cantidad': 3,
        'imagen': null,
        'activo': true,
      },
    ]);
  }

  if (request.method == 'GET' && path == '/clientes') {
    return _json([
      {
        'cliente_id': 1,
        'nombre': 'Ana',
        'apellido': 'Pérez',
        'dui': '01234567-8',
        'direccion': 'San Salvador',
        'telefono': 71234567,
        'correo': 'ana@correo.com',
      },
    ]);
  }

  if (request.method == 'GET' && path == '/categorias') {
    return _json([
      {
        'categoria_id': 2,
        'nombre': 'Bebidas',
        'descripcion': 'Bebidas frías y calientes',
        'activa': true,
      },
    ]);
  }

  if (request.method == 'GET' && path == '/equipos') {
    return _json([
      {
        'equipo_id': 5,
        'nombre': 'PC-01',
        'descripcion': 'Equipo de prueba',
        'tarifa_por_hora': '2.00',
        'imagen': null,
        'tipo': 'PC',
        'estado': 'Disponible',
      },
    ]);
  }

  if (request.method == 'GET' && path == '/usuarios') {
    return _json([
      {
        'usuario_id': 2,
        'rol_id': 2,
        'nombre': 'Cajero Uno',
        'username': 'cajero',
        'correo': 'cajero@correo.com',
        'is_superuser': false,
        'activo': true,
      },
    ]);
  }

  if (request.method == 'GET' && path == '/reportes/resumen-general') {
    return _json({
      'total_ingresos': '100.00',
      'total_ingresos_ventas': '80.00',
      'total_ingresos_rentas': '20.00',
      'cantidad_ventas': 8,
      'cantidad_rentas': 4,
      'sesiones_renta_activas': 2,
      'total_clientes': 8,
      'total_equipos': 10,
      'equipos_disponibles': 6,
      'equipos_en_mantenimiento_o_averiados': 2,
      'productos_stock_bajo': 1,
    });
  }

  if (request.method == 'GET' && path == '/reportes/diario') {
    final fecha = request.url.queryParameters['fecha_reporte'];
    return _json({
      'fecha': fecha ?? '2026-10-27',
      'total_dia': '12.50',
      'ingresos_ventas_hoy': '10.00',
      'ingresos_rentas_hoy': '2.50',
      'cantidad_ventas_hoy': 3,
      'cantidad_rentas_hoy': 1,
      'rentas_pendientes_pago_hoy': 1,
    });
  }

  return http.Response('{"detail":"No encontrado"}', 404);
}

http.Response _json(Object data) {
  return http.Response(
    jsonEncode(data),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

String _tokenConClaims({
  required int id,
  required String username,
  required int rolId,
}) {
  final header = base64Url
      .encode(utf8.encode('{"alg":"HS256"}'))
      .replaceAll('=', '');
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({'id': id, 'username': username, 'id_rol': rolId}),
        ),
      )
      .replaceAll('=', '');
  return '$header.$payload.firma';
}
