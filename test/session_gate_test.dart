import 'dart:convert';

import 'package:cybercafe_app_mobile/screens/auth/login_screen.dart';
import 'package:cybercafe_app_mobile/screens/auth/session_gate.dart';
import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('SessionGate', () {
    testWidgets('sin token muestra el login', (tester) async {
      final auth = AuthService(storage: InMemoryTokenStorage());

      await _pumpGate(tester, auth);

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('token válido con rol 1 entra al home de admin', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 1));
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => _perfil(rolId: 1)),
      );

      await _pumpGate(tester, auth);

      expect(find.text('home-1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('token válido con rol 3 entra al home de asistente', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 3));
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => _perfil(rolId: 3)),
      );

      await _pumpGate(tester, auth);

      expect(find.text('home-3'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('usa el rol del perfil si cambió respecto al token', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 1));
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => _perfil(rolId: 3)),
      );

      await _pumpGate(tester, auth);

      expect(find.text('home-3'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('rol no permitido limpia la sesión y muestra login', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 2));
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => _perfil(rolId: 2)),
      );

      await _pumpGate(tester, auth);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await storage.readToken(), isNull);
      expect(auth.accessToken, isNull);
    });

    testWidgets('usuario inactivo limpia la sesión y muestra login', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 1));
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => _perfil(rolId: 1, activo: false)),
      );

      await _pumpGate(tester, auth);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await storage.readToken(), isNull);
      expect(auth.accessToken, isNull);
    });

    testWidgets('token vencido no llama al backend y muestra login', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(
        _token(
          rolId: 1,
          expiraEn: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );
      final auth = AuthService(
        storage: storage,
        client: MockClient(
          (_) async => throw StateError('el backend no debería llamarse'),
        ),
      );

      await _pumpGate(tester, auth);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await storage.readToken(), isNull);
      expect(auth.accessToken, isNull);
    });

    testWidgets('sin red muestra reintento y conserva el token', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      final token = _token(rolId: 1);
      await storage.writeToken(token);
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => throw http.ClientException('sin red')),
      );

      await _pumpGate(tester, auth);

      expect(find.text('No se pudo validar la sesión'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(await storage.readToken(), token);
      expect(auth.accessToken, token);
    });

    testWidgets('reintentar tras recuperar la red entra al home', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 1));
      var fallaLaRed = true;
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async {
          if (fallaLaRed) throw http.ClientException('sin red');
          return _perfil(rolId: 1);
        }),
      );

      await _pumpGate(tester, auth);
      expect(find.text('No se pudo validar la sesión'), findsOneWidget);

      fallaLaRed = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('home-1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('usar otra cuenta limpia la sesión y muestra login', (
      tester,
    ) async {
      final storage = InMemoryTokenStorage();
      await storage.writeToken(_token(rolId: 1));
      final auth = AuthService(
        storage: storage,
        client: MockClient((_) async => throw http.ClientException('sin red')),
      );

      await _pumpGate(tester, auth);
      await tester.tap(find.text('Usar otra cuenta'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await storage.readToken(), isNull);
    });
  });
}

Future<void> _pumpGate(WidgetTester tester, AuthService auth) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SessionGate(auth: auth, homeBuilder: (rol) => Text('home-$rol')),
    ),
  );
  await tester.pumpAndSettle();
}

String _token({required int rolId, DateTime? expiraEn, int id = 7}) {
  final expira = expiraEn ?? DateTime.now().add(const Duration(hours: 1));
  final header = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({
            'id': id,
            'username': 'usuario_prueba',
            'id_rol': rolId,
            'exp': expira.toUtc().millisecondsSinceEpoch ~/ 1000,
          }),
        ),
      )
      .replaceAll('=', '');
  return '$header.$payload.firma';
}

http.Response _perfil({required int rolId, bool activo = true}) {
  return http.Response(
    jsonEncode({
      'usuario_id': 7,
      'rol_id': rolId,
      'nombre': 'Edwin Cruz',
      'username': 'edwin_asistente',
      'correo': 'edwin@coffeelan.com',
      'is_superuser': false,
      'activo': activo,
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}
