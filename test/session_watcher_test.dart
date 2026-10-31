import 'dart:convert';

import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:cybercafe_app_mobile/widgets/session_watcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('expulsa la sesión cuando el usuario fue desactivado', (
    tester,
  ) async {
    final storage = InMemoryTokenStorage();
    await storage.writeToken('token-valido');

    final auth = AuthService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'usuario_id': 7,
            'rol_id': 3,
            'nombre': 'Edwin Cruz',
            'username': 'edwin_asistente',
            'correo': 'edwin@coffeelan.com',
            'activo': false,
          }),
          200,
        ),
      ),
      storage: storage,
    );
    expect(await auth.restoreSession(), isTrue);

    var sesionExpirada = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SessionWatcher(
          auth: auth,
          interval: const Duration(milliseconds: 20),
          onSessionExpired: (_) => sesionExpirada = true,
          child: const Scaffold(body: Text('Dashboard')),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 25));
    await tester.pump();

    expect(sesionExpirada, isTrue);
    expect(auth.accessToken, isNull);
    expect(await storage.readToken(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
