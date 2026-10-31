import 'dart:convert';

import 'package:cybercafe_app_mobile/models/usuario_perfil.dart';
import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('UsuarioPerfil.fromJson', () {
    test('mapea los datos públicos del usuario', () {
      final perfil = UsuarioPerfil.fromJson({
        'usuario_id': 7,
        'rol_id': 3,
        'nombre': 'Edwin Cruz',
        'username': 'edwin_asistente',
        'correo': 'edwin@coffeelan.com',
        'password': 'no-debe-usarse',
        'activo': true,
      });

      expect(perfil.usuarioId, 7);
      expect(perfil.rolId, 3);
      expect(perfil.nombre, 'Edwin Cruz');
      expect(perfil.username, 'edwin_asistente');
      expect(perfil.correo, 'edwin@coffeelan.com');
      expect(perfil.activo, isTrue);
    });

    test('detecta un usuario desactivado', () {
      final perfil = UsuarioPerfil.fromJson({
        'usuario_id': 8,
        'rol_id': 2,
        'nombre': 'Cajero',
        'username': 'cajero',
        'correo': 'cajero@coffeelan.com',
        'activo': false,
      });

      expect(perfil.activo, isFalse);
    });

    test('asume activo si la API no envía el campo', () {
      final perfil = UsuarioPerfil.fromJson({
        'usuario_id': 9,
        'rol_id': 1,
        'nombre': 'Admin',
        'username': 'admin',
        'correo': 'admin@coffeelan.com',
      });

      expect(perfil.activo, isTrue);
    });
  });

  group('AuthService perfil', () {
    test('carga /usuarios/me y expone nombre, correo y rol', () async {
      final cliente = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/oauth/login') {
          return http.Response(
            jsonEncode({
              'access_token': _tokenConClaims(
                id: 7,
                username: 'edwin_asistente',
                rolId: 3,
              ),
              'token_type': 'bearer',
            }),
            200,
          );
        }

        if (request.method == 'GET' && request.url.path == '/usuarios/me') {
          expect(request.headers['Authorization'], startsWith('Bearer '));
          return http.Response(
            jsonEncode({
              'usuario_id': 7,
              'rol_id': 3,
              'nombre': 'Edwin Cruz',
              'username': 'edwin_asistente',
              'correo': 'edwin@coffeelan.com',
              'is_superuser': false,
              'activo': true,
            }),
            200,
          );
        }

        return http.Response('{"detail":"No encontrado"}', 404);
      });

      final auth = AuthService(
        client: cliente,
        storage: InMemoryTokenStorage(),
      );

      await auth.login(username: 'edwin_asistente', password: 'secreta');

      expect(auth.nombreMostrado, 'edwin_asistente');
      expect(auth.etiquetaRol, 'Asistente de Equipos');

      final perfil = await auth.cargarPerfil();

      expect(perfil?.nombre, 'Edwin Cruz');
      expect(auth.nombreMostrado, 'Edwin Cruz');
      expect(auth.usernameMostrado, 'edwin_asistente');
      expect(auth.correoMostrado, 'edwin@coffeelan.com');
      expect(auth.etiquetaRol, 'Asistente de Equipos');
    });

    test(
      'usa el token como respaldo si el perfil no está disponible',
      () async {
        final cliente = MockClient((request) async {
          if (request.method == 'POST' && request.url.path == '/oauth/login') {
            return http.Response(
              jsonEncode({
                'access_token': _tokenConClaims(
                  id: 9,
                  username: 'admin',
                  rolId: 1,
                ),
                'token_type': 'bearer',
              }),
              200,
            );
          }

          return http.Response('Sin conexión', 500);
        });

        final auth = AuthService(
          client: cliente,
          storage: InMemoryTokenStorage(),
        );

        await auth.login(username: 'admin', password: 'secreta');
        final perfil = await auth.cargarPerfil();

        expect(perfil, isNull);
        expect(auth.nombreMostrado, 'admin');
        expect(auth.correoMostrado, 'No disponible');
        expect(auth.etiquetaRol, 'Administrador');
      },
    );
  });
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
