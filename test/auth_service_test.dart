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
}
