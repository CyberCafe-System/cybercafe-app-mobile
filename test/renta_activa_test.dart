import 'dart:convert';

import 'package:cybercafe_app_mobile/models/renta_activa.dart';
import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/renta_activa_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:cybercafe_app_mobile/utils/renta_formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RentaActivaEquipo', () {
    test('calcula el tiempo restante y el progreso', () {
      final consultadaEn = DateTime(2026, 10, 30, 10);
      final renta = RentaActivaEquipo.fromJson({
        'detalle_renta_id': 3,
        'renta_id': 20,
        'equipo_id': 8,
        'hora_inicio': '2026-10-30T10:00:00Z',
        'tiempo_total': 60,
        'minutos_transcurridos': 15,
        'minutos_restantes': 45,
        'subtotal': '2.50',
      }, consultadaEn: consultadaEn);

      expect(renta.restanteEn(consultadaEn), const Duration(minutes: 45));
      expect(renta.progresoEn(consultadaEn), 0.25);
      expect(renta.horaFinalizacion, DateTime(2026, 10, 30, 10, 45));

      final quinceMinutosDespues = consultadaEn.add(
        const Duration(minutes: 15),
      );
      expect(
        renta.restanteEn(quinceMinutosDespues),
        const Duration(minutes: 30),
      );
      expect(renta.progresoEn(quinceMinutosDespues), 0.5);

      final vencida = consultadaEn.add(const Duration(hours: 2));
      expect(renta.restanteEn(vencida), Duration.zero);
      expect(renta.progresoEn(vencida), 1);
    });

    test('usa el tiempo total si falta minutos_restantes', () {
      final renta = RentaActivaEquipo.fromJson({
        'detalle_renta_id': 3,
        'renta_id': 20,
        'equipo_id': 8,
        'tiempo_total': 30,
        'minutos_transcurridos': 10,
      }, consultadaEn: DateTime(2026, 10, 30, 10));

      expect(renta.minutosRestantes, 20);
    });
  });

  group('Formato de tiempo de renta', () {
    test('describe el tiempo restante en minutos y horas', () {
      expect(
        formatearTiempoRestante(const Duration(minutes: 45)),
        'Quedan 45 min',
      );
      expect(
        formatearTiempoRestante(const Duration(minutes: 1)),
        'Queda 1 min',
      );
      expect(formatearTiempoRestante(const Duration(hours: 1)), 'Queda 1 h');
      expect(
        formatearTiempoRestante(const Duration(minutes: 90)),
        'Quedan 1 h 30 min',
      );
      expect(formatearTiempoRestante(Duration.zero), 'Tiempo agotado');
    });

    test('muestra la hora de finalización', () {
      expect(
        formatearHoraFinalizacion(DateTime(2026, 10, 30, 14, 5)),
        'Finaliza a las 14:05',
      );
    });
  });

  group('RentaActivaService', () {
    test('carga rentas activas y les asigna el cliente', () async {
      final auth = AuthService(
        client: MockClient(_responder),
        storage: InMemoryTokenStorage(),
      );
      await _autenticar(auth);

      final activas = await RentaActivaService(
        auth: auth,
      ).getRentasActivasPorEquipo();

      expect(activas.keys, [8]);
      final renta = activas[8]!;
      expect(renta.rentaId, 20);
      expect(renta.clienteNombre, 'Ana Pérez');
      expect(renta.minutosRestantes, 45);
      expect(renta.tiempoTotal, 60);
    });
  });
}

Future<void> _autenticar(AuthService auth) async {
  await auth.login(username: 'asistente', password: 'secreta');
}

Future<http.Response> _responder(http.Request request) async {
  final path = request.url.path;

  if (request.method == 'POST' && path == '/oauth/login') {
    return _json({
      'access_token': _tokenConClaims(id: 3, username: 'asistente', rolId: 3),
      'token_type': 'bearer',
    });
  }

  if (request.method == 'GET' && path == '/rentas/activas') {
    return _json(
      [
        {
          'detalle_renta_id': 3,
          'renta_id': 20,
          'equipo_id': 8,
          'equipo_nombre': 'PC-08',
          'cliente_nombre': 'Ana Pérez',
          'hora_inicio': '2026-10-30T10:00:00Z',
          'tiempo_de_renta': 60,
          'tiempo_agregado': 0,
          'tiempo_total': 60,
          'minutos_transcurridos': 15,
          'minutos_restantes': 45,
          'subtotal': '2.50',
          'estado': 'Activa',
        },
      ],
      total: 1,
    );
  }

  return http.Response('{"detail":"No encontrado"}', 404);
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

String _tokenConClaims({
  required int id,
  required String username,
  required int rolId,
}) {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode({
        'id': id,
        'username': username,
        'id_rol': rolId,
        'exp': 4102444800,
      }),
    ),
  );
  return '$header.$payload.firma';
}
