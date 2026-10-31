import 'dart:convert';

import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthService.getProtected', () {
    test('401 limpia el token y notifica la sesión expirada', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken('token-expirado');

      final auth = AuthService(
        client: MockClient((_) async => http.Response('', 401)),
        storage: storage,
      );
      var sessionExpired = false;
      auth.onSessionExpired = () => sessionExpired = true;

      expect(await auth.restoreSession(), isTrue);

      await expectLater(
        auth.getProtected(Uri.parse('http://127.0.0.1:8000/equipos')),
        throwsA(
          isA<AuthException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );

      expect(await storage.readToken(), isNull);
      expect(auth.accessToken, isNull);
      expect(sessionExpired, isTrue);
    });

    test('403 conserva la sesión local', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken('token-valido');

      final auth = AuthService(
        client: MockClient((_) async => http.Response('', 403)),
        storage: storage,
      );

      expect(await auth.restoreSession(), isTrue);

      final response = await auth.getProtected(
        Uri.parse('http://127.0.0.1:8000/usuarios'),
      );

      expect(response.statusCode, 403);
      expect(await storage.readToken(), 'token-valido');
      expect(auth.accessToken, 'token-valido');
    });
  });

  group('AuthService.verificarSesionActiva', () {
    test('activo false cierra la sesión y notifica una sola vez', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken('token-valido');

      final auth = AuthService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(_perfilJson(activo: false)), 200),
        ),
        storage: storage,
      );
      var sesionesExpiradas = 0;
      auth.onSessionExpired = () => sesionesExpiradas++;

      expect(await auth.restoreSession(), isTrue);
      expect(await auth.verificarSesionActiva(), isFalse);
      expect(sesionesExpiradas, 1);
      expect(auth.accessToken, isNull);
      expect(await storage.readToken(), isNull);

      expect(await auth.verificarSesionActiva(), isFalse);
      expect(sesionesExpiradas, 1);
    });

    test('activo true conserva la sesión y actualiza el perfil', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken('token-valido');

      final auth = AuthService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(_perfilJson(activo: true)), 200),
        ),
        storage: storage,
      );
      var sesionesExpiradas = 0;
      auth.onSessionExpired = () => sesionesExpiradas++;

      expect(await auth.restoreSession(), isTrue);
      expect(await auth.verificarSesionActiva(), isTrue);
      expect(sesionesExpiradas, 0);
      expect(auth.accessToken, 'token-valido');
      expect(await storage.readToken(), 'token-valido');
      expect(auth.perfil?.activo, isTrue);
      expect(auth.perfil?.nombre, 'Edwin Cruz');
    });

    test('un fallo de red no cierra la sesión', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken('token-valido');

      final auth = AuthService(
        client: MockClient((_) async => throw http.ClientException('sin red')),
        storage: storage,
      );
      var sesionesExpiradas = 0;
      auth.onSessionExpired = () => sesionesExpiradas++;

      expect(await auth.restoreSession(), isTrue);
      await expectLater(
        auth.verificarSesionActiva(),
        throwsA(isA<AuthException>()),
      );

      expect(sesionesExpiradas, 0);
      expect(auth.accessToken, 'token-valido');
      expect(await storage.readToken(), 'token-valido');
    });
  });
}

Map<String, dynamic> _perfilJson({required bool activo}) => {
  'usuario_id': 7,
  'rol_id': 3,
  'nombre': 'Edwin Cruz',
  'username': 'edwin_asistente',
  'correo': 'edwin@coffeelan.com',
  'is_superuser': false,
  'activo': activo,
};
