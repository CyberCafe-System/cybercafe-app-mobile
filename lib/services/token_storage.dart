import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstracción del almacenamiento del token de sesión.
///
/// Permite sustituir el backend real (encriptado en el dispositivo) por un
/// almacén en memoria durante los tests.
abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> deleteToken();
}

/// Almacenamiento seguro real usando flutter_secure_storage
/// (Keystore/Keychain según la plataforma).
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage();

  static const _key = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> readToken() => _storage.read(key: _key);

  @override
  Future<void> writeToken(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> deleteToken() => _storage.delete(key: _key);
}

/// Almacén en memoria para tests unitarios y de widgets.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;
}
