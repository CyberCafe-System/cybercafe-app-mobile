import 'dart:convert';

import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/componente_service.dart';
import 'package:cybercafe_app_mobile/services/equipo_service.dart';
import 'package:cybercafe_app_mobile/services/paginacion_api.dart';
import 'package:cybercafe_app_mobile/services/revision_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaginadorApi', () {
    test('recorre todas las páginas y no duplica registros', () async {
      final maestra = List.generate(250, (i) => i);
      final offsets = <int>[];

      final resultado = await PaginadorApi.recolectar<int>(
        pageSize: 100,
        cargarPagina: (offset, limit) async {
          offsets.add(offset);
          return PaginaApi(
            items: maestra.skip(offset).take(limit).toList(),
            total: maestra.length,
          );
        },
      );

      expect(offsets, [0, 100, 200]);
      expect(resultado.items, maestra);
      expect(resultado.truncado, isFalse);
    });

    test('no pide una página extra si el total ya fue alcanzado', () async {
      final maestra = List.generate(200, (i) => i);
      final offsets = <int>[];

      final resultado = await PaginadorApi.recolectar<int>(
        pageSize: 100,
        cargarPagina: (offset, limit) async {
          offsets.add(offset);
          return PaginaApi(
            items: maestra.skip(offset).take(limit).toList(),
            total: maestra.length,
          );
        },
      );

      // Sin la cabecera haría una tercera petición vacía.
      expect(offsets, [0, 100]);
      expect(resultado.items, maestra);
      expect(resultado.truncado, isFalse);
    });

    test('se detiene en maxItems y reporta el truncado', () async {
      final maestra = List.generate(250, (i) => i);
      final offsets = <int>[];

      final resultado = await PaginadorApi.recolectar<int>(
        pageSize: 100,
        maxItems: 150,
        cargarPagina: (offset, limit) async {
          offsets.add(offset);
          return PaginaApi(
            items: maestra.skip(offset).take(limit).toList(),
            total: maestra.length,
          );
        },
      );

      expect(offsets, [0, 100]);
      expect(resultado.items, hasLength(150));
      expect(resultado.items, maestra.take(150));
      expect(resultado.truncado, isTrue);
    });

    test('totalDesde lee la cabecera y tolera su ausencia', () {
      final conTotal = http.Response(
        '[]',
        200,
        headers: {'X-Total-Count': ' 42 '},
      );
      final sinTotal = http.Response('[]', 200);

      expect(PaginadorApi.totalDesde(conTotal), 42);
      expect(PaginadorApi.totalDesde(sinTotal), isNull);
    });
  });

  group('Paginación de servicios', () {
    test('EquipoService recorre todos los equipos sin saltos', () async {
      final offsets = <int>[];
      final auth = await _authAutenticada((request) async {
        if (request.method == 'POST' && request.url.path == '/oauth/login') {
          return _loginResponse();
        }
        if (request.method == 'GET' && request.url.path == '/equipos') {
          final offset = int.parse(request.url.queryParameters['offset']!);
          final limit = int.parse(request.url.queryParameters['limit']!);
          offsets.add(offset);
          expect(limit, 100);
          return _json(
            List.generate(
              limit,
              (i) => _equipoJson(offset + i),
            ).where((e) => e['equipo_id'] < 250).toList(),
            total: 250,
          );
        }
        return _noEncontrado();
      });

      final equipos = await EquipoService(auth: auth).getTodosLosEquipos();

      expect(offsets, [0, 100, 200]);
      expect(equipos, hasLength(250));
      expect(equipos.map((e) => e.equipoId).toSet(), hasLength(250));
      expect(equipos.first.equipoId, 0);
      expect(equipos.last.equipoId, 249);
    });

    test('ComponenteService recorre todos los componentes', () async {
      final offsets = <int>[];
      final auth = await _authAutenticada((request) async {
        if (request.method == 'POST' && request.url.path == '/oauth/login') {
          return _loginResponse();
        }
        if (request.method == 'GET' && request.url.path == '/componentes') {
          final offset = int.parse(request.url.queryParameters['offset']!);
          final limit = int.parse(request.url.queryParameters['limit']!);
          offsets.add(offset);
          return _json(
            List.generate(
              limit,
              (i) => _componenteJson(offset + i),
            ).where((c) => c['componente_id'] < 250).toList(),
            total: 250,
          );
        }
        return _noEncontrado();
      });

      final componentes = await ComponenteService(
        auth: auth,
      ).getComponentes();

      expect(offsets, [0, 100, 200]);
      expect(componentes, hasLength(250));
      expect(componentes.map((c) => c.componenteId).toSet(), hasLength(250));
    });

    test(
      'RevisionService usa el endpoint enriquecido y pagina pendientes',
      () async {
        final offsets = <int>[];
        final rutasSolicitadas = <String>[];
        final auth = await _authAutenticada((request) async {
          if (request.method == 'POST' && request.url.path == '/oauth/login') {
            return _loginResponse();
          }
          rutasSolicitadas.add(request.url.path);
          if (request.method == 'GET' &&
              request.url.path == '/detalles-renta/pendientes-revision') {
            final offset = int.parse(request.url.queryParameters['offset']!);
            final limit = int.parse(request.url.queryParameters['limit']!);
            offsets.add(offset);
            final items = List.generate(limit, (i) {
              final id = offset + i + 1;
              return {
                'detalle_renta_id': id,
                'renta_id': 1000 + id,
                'equipo_id': id,
                'equipo_nombre': 'Equipo $id',
                'cliente_id': id,
                'cliente_nombre': 'Cliente $id',
              };
            }).where((d) => (d['detalle_renta_id'] as int) <= 250).toList();
            return _json(items, total: 250);
          }
          return _noEncontrado();
        });

        final pendientes = await RevisionService(
          auth: auth,
        ).getEquiposConRevisionPendiente();

        expect(offsets, [0, 100, 200]);
        expect(pendientes, hasLength(250));
        expect(pendientes[1]!.clienteNombre, 'Cliente 1');
        // Ya no se cruzan rentas ni clientes en el dispositivo.
        expect(rutasSolicitadas, isNot(contains('/rentas')));
        expect(rutasSolicitadas, isNot(contains('/clientes')));
      },
    );

    test('RevisionService conserva el detalle más reciente por equipo', () async {
      final auth = await _authAutenticada((request) async {
        if (request.method == 'POST' && request.url.path == '/oauth/login') {
          return _loginResponse();
        }
        if (request.method == 'GET' &&
            request.url.path == '/detalles-renta/pendientes-revision') {
          return _json(
            [
              {
                'detalle_renta_id': 10,
                'renta_id': 1,
                'equipo_id': 7,
                'cliente_nombre': 'Cliente viejo',
              },
              {
                'detalle_renta_id': 12,
                'renta_id': 2,
                'equipo_id': 7,
                'cliente_nombre': 'Cliente nuevo',
              },
            ],
            total: 2,
          );
        }
        return _noEncontrado();
      });

      final pendientes = await RevisionService(
        auth: auth,
      ).getEquiposConRevisionPendiente();

      expect(pendientes.keys, [7]);
      expect(pendientes[7]!.detalleRentaId, 12);
      expect(pendientes[7]!.clienteNombre, 'Cliente nuevo');
    });
  });
}

Future<AuthService> _authAutenticada(
  Future<http.Response> Function(http.Request request) responder,
) async {
  final auth = AuthService(
    client: MockClient(responder),
    storage: InMemoryTokenStorage(),
  );
  await auth.login(username: 'asistente', password: 'secreta');
  return auth;
}

http.Response _loginResponse() {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode({
        'id': 3,
        'username': 'asistente',
        'id_rol': 3,
        'exp': 4102444800,
      }),
    ),
  );
  return _json({
    'access_token': '$header.$payload.firma',
    'token_type': 'bearer',
  });
}

Map<String, dynamic> _equipoJson(int id) {
  return {
    'equipo_id': id,
    'nombre': 'Equipo $id',
    'descripcion': null,
    'tarifa_por_hora': '1.50',
    'imagen': null,
    'tipo': 'PC',
    'estado': 'Disponible',
  };
}

Map<String, dynamic> _componenteJson(int id) {
  return {
    'componente_id': id,
    'equipo_id': id,
    'nombre': 'Componente $id',
    'numero_serie': null,
    'tipo': 'Mouse',
    'estado': 'Disponible',
    'descripcion': null,
    'observaciones': null,
    'imagen': null,
    'activo': true,
  };
}

http.Response _json(Object data, {int? total}) {
  return http.Response(
    jsonEncode(data),
    200,
    headers: {
      'content-type': 'application/json',
      if (total != null) 'x-total-count': '$total',
    },
  );
}

http.Response _noEncontrado() {
  return http.Response('{"detail":"No encontrado"}', 404);
}
