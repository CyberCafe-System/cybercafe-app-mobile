import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/usuario_perfil.dart';
import 'token_storage.dart';

/// Error de autenticación con un mensaje apto para mostrar al usuario.
class AuthException implements Exception {
  AuthException(this.message, {this.statusCode, this.retryAfter});

  /// Mensaje entendible (nunca contiene token, contraseña ni detalles técnicos).
  final String message;

  /// Código HTTP de la respuesta, si la hubo.
  final int? statusCode;

  /// Espera sugerida por el servidor vía `Retry-After` (solo en 429).
  final Duration? retryAfter;

  @override
  String toString() => message;
}

/// Servicio de autenticación contra los endpoints OAuth2 del backend.
///
/// - Login: `POST /oauth/login` (x-www-form-urlencoded: username, password).
/// - Logout: `POST /oauth/logout` con `Authorization: Bearer <token>`.
/// - El access_token se persiste en [TokenStorage] (almacenamiento seguro).
class AuthService {
  AuthService({http.Client? client, TokenStorage? storage, Duration? timeout})
    : _client = client ?? http.Client(),
      _storage = storage ?? const SecureTokenStorage(),
      _timeout = timeout ?? ApiConfig.requestTimeout;

  static final AuthService instance = AuthService();

  final http.Client _client;
  final TokenStorage _storage;
  final Duration _timeout;

  String? _accessToken;
  int? _rolId;
  int? _usuarioId;
  String? _username;
  UsuarioPerfil? _perfil;
  Future<UsuarioPerfil?>? _perfilFuture;
  bool _sesionExpiradaNotificada = false;

  /// Se invoca cuando la sesión ya no es válida (token expirado, revocado o
  /// usuario desactivado): la sesión local ya fue limpiada y hay que volver al
  /// login.
  void Function()? onSessionExpired;

  String? get accessToken => _accessToken;
  int? get rolId => _rolId;
  int? get usuarioId => _usuarioId;
  String? get username => _username;
  UsuarioPerfil? get perfil => _perfil;
  bool get isAdmin => _rolId == 1;
  bool get isAsistente => _rolId == 3;
  bool get isAuthenticated => _accessToken != null;

  /// Nombre real del usuario; si el perfil aún no cargó, usa el username.
  String get nombreMostrado {
    final nombre = _perfil?.nombre.trim();
    if (nombre != null && nombre.isNotEmpty) return nombre;
    final username = _username?.trim();
    return username != null && username.isNotEmpty ? username : 'Usuario';
  }

  String get usernameMostrado {
    final username = _perfil?.username.trim();
    if (username != null && username.isNotEmpty) return username;
    final delToken = _username?.trim();
    return delToken != null && delToken.isNotEmpty ? delToken : 'No disponible';
  }

  String get correoMostrado {
    final correo = _perfil?.correo.trim();
    return correo != null && correo.isNotEmpty ? correo : 'No disponible';
  }

  /// Etiqueta legible del rol a partir del perfil o de los claims del token.
  String get etiquetaRol {
    switch (_perfil?.rolId ?? _rolId) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Cajero';
      case 3:
        return 'Asistente de Equipos';
      default:
        return 'Usuario';
    }
  }

  /// Restaura la sesión guardada al arrancar la app.
  ///
  /// No valida el token con el backend (la API es la autoridad): si resulta
  /// estar vencido, la primera petición protegida devolverá 401 y se limpiará.
  Future<bool> restoreSession() async {
    _sesionExpiradaNotificada = false;
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      _accessToken = null;
      _rolId = null;
      _usuarioId = null;
      _username = null;
      _perfil = null;
      _perfilFuture = null;
      return false;
    }
    _accessToken = token;
    _applyTokenClaims(token);
    return true;
  }

  /// Realiza el login y persiste el access_token en almacenamiento seguro.
  ///
  /// Nunca guarda la contraseña ni escribe token/credenciales en logs.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _send(
      () => _client.post(
        ApiConfig.endpoint(ApiConfig.loginPath),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      ),
      statusCode: 0,
    );

    if (response.statusCode != 200) {
      throw _mapError(response, isLogin: true);
    }

    final data = jsonDecode(response.body);
    final token = data is Map<String, dynamic> ? data['access_token'] : null;

    if (token is! String || token.isEmpty) {
      throw AuthException(
        'No se pudo iniciar sesión. Respuesta inesperada del servidor.',
        statusCode: response.statusCode,
      );
    }

    _sesionExpiradaNotificada = false;
    _accessToken = token;
    _applyTokenClaims(token);
    _perfil = null;
    _perfilFuture = null;
    await _storage.writeToken(token);
  }

  /// Cierra la sesión en el servidor y elimina SIEMPRE la sesión local,
  /// aunque la llamada falle (se relanza el error tras limpiar para que la
  /// UI pueda mostrar un aviso).
  Future<void> logout() async {
    final token = _accessToken;
    Object? failure;

    if (token != null) {
      try {
        final response = await _client
            .post(
              ApiConfig.endpoint(ApiConfig.logoutPath),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(_timeout);
        // 401 significa que el token ya no era válido: la sesión terminó
        // igualmente y no hay nada que avisar.
        if (response.statusCode >= 300 && response.statusCode != 401) {
          failure = response;
        }
      } catch (e) {
        failure = e;
      }
    }

    _sesionExpiradaNotificada = false;
    await _clearSession();

    if (failure != null) {
      if (failure is AuthException) throw failure;
      throw AuthException(
        'No se pudo avisar al servidor del cierre de sesión, '
        'pero se cerró localmente.',
      );
    }
  }

  /// Encabezados listos para cualquier petición protegida.
  Map<String, String> authorizedHeaders() => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Petición GET protegida: adjunta el Bearer y, si responde 401, limpia la
  /// sesión local y avisa vía [onSessionExpired].
  Future<http.Response> getProtected(Uri uri) {
    return _protectedRequest(
      (token) => _client.get(uri, headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Petición PATCH protegida con el mismo manejo de sesión que [getProtected].
  Future<http.Response> patchProtected(Uri uri) {
    return _protectedRequest(
      (token) =>
          _client.patch(uri, headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Petición POST protegida con el mismo manejo de sesión que [getProtected].
  Future<http.Response> postProtected(
    Uri uri, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _protectedRequest(
      (token) => _client.post(
        uri,
        headers: {'Authorization': 'Bearer $token', ...?headers},
        body: body,
      ),
    );
  }

  Future<http.Response> _protectedRequest(
    Future<http.Response> Function(String token) run,
  ) async {
    final token = _accessToken;
    if (token == null) {
      throw AuthException('Debes iniciar sesión para continuar.');
    }

    final response = await _send(() => run(token), statusCode: 0);

    if (response.statusCode == 401) {
      await _expirarSesion();
      throw AuthException(
        'Tu sesión ha expirado. Inicia sesión de nuevo.',
        statusCode: 401,
      );
    }

    return response;
  }

  /// Obtiene el listado de productos (`GET [ApiConfig.productsPath]`).
  ///
  /// Devuelve el JSON decodificado (la forma exacta la define el backend).
  Future<dynamic> getProducts() async {
    final response = await getProtected(
      ApiConfig.endpoint(ApiConfig.productsPath),
    );

    if (response.statusCode != 200) {
      throw _mapError(response, isLogin: false);
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
  }

  /// Carga y cachea el perfil del usuario autenticado (`GET /usuarios/me`).
  ///
  /// Si el endpoint falla por una causa distinta a 401, devuelve `null` para
  /// que la UI use el username del token como respaldo.
  Future<UsuarioPerfil?> cargarPerfil() async {
    final perfil = _perfil;
    if (perfil != null) return perfil;

    final enCurso = _perfilFuture;
    if (enCurso != null) return enCurso;

    final future = _fetchPerfil();
    _perfilFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_perfilFuture, future)) {
        _perfilFuture = null;
      }
    }
  }

  Future<UsuarioPerfil?> _fetchPerfil() async {
    try {
      final response = await getProtected(
        ApiConfig.endpoint(ApiConfig.perfilActualPath),
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) return null;

      final perfil = UsuarioPerfil.fromJson(Map<String, dynamic>.from(data));
      _perfil = perfil;
      return perfil;
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Consulta el estado actual del usuario sin usar el perfil cacheado.
  ///
  /// Devuelve `false` si el usuario ya no existe, fue desactivado o el token
  /// dejó de ser válido. En esos casos la sesión local queda cerrada.
  Future<bool> verificarSesionActiva() async {
    if (_accessToken == null) return false;

    final http.Response response;
    try {
      response = await getProtected(
        ApiConfig.endpoint(ApiConfig.perfilActualPath),
      );
    } on AuthException catch (e) {
      if (e.statusCode == 401) return false;
      rethrow;
    }

    if (response.statusCode != 200) return true;

    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) return true;

      final perfil = UsuarioPerfil.fromJson(Map<String, dynamic>.from(data));
      _perfil = perfil;

      if (!perfil.activo) {
        await _expirarSesion();
        return false;
      }
      return true;
    } catch (_) {
      // Una respuesta inesperada no debe cerrar la sesión por sí sola.
      return true;
    }
  }

  Future<void> _expirarSesion() async {
    if (_sesionExpiradaNotificada) return;
    _sesionExpiradaNotificada = true;
    await _clearSession();
    onSessionExpired?.call();
  }

  Future<void> _clearSession() async {
    _accessToken = null;
    _rolId = null;
    _usuarioId = null;
    _username = null;
    _perfil = null;
    _perfilFuture = null;
    await _storage.deleteToken();
  }

  void _applyTokenClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        _resetClaims();
        return;
      }
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      if (data is! Map<String, dynamic>) {
        _resetClaims();
        return;
      }
      final rol = data['id_rol'] ?? data['rol_id'];
      _rolId = rol is int ? rol : int.tryParse('$rol');

      final id = data['id'] ?? data['usuario_id'];
      _usuarioId = id is int ? id : int.tryParse('$id');

      final username = data['username'];
      _username = username is String && username.trim().isNotEmpty
          ? username.trim()
          : null;
    } catch (_) {
      _resetClaims();
    }
  }

  void _resetClaims() {
    _rolId = null;
    _usuarioId = null;
    _username = null;
    _perfil = null;
  }

  Future<http.Response> _send(
    Future<http.Response> Function() run, {
    required int statusCode,
  }) async {
    try {
      return await run().timeout(_timeout);
    } on TimeoutException {
      throw AuthException(
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw AuthException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  AuthException _mapError(http.Response response, {required bool isLogin}) {
    final status = response.statusCode;
    final detail = _extractDetail(response.body);

    if (status == 429) {
      final retryAfter = _parseRetryAfter(response.headers['retry-after']);
      final wait = retryAfter == null
          ? 'Espera un momento y vuelve a intentarlo.'
          : 'Espera ${retryAfter.inSeconds} '
                '${retryAfter.inSeconds == 1 ? 'segundo' : 'segundos'} '
                'y vuelve a intentarlo.';
      return AuthException(
        'Demasiados intentos. $wait',
        statusCode: 429,
        retryAfter: retryAfter,
      );
    }

    if (status == 401) {
      return AuthException(
        isLogin
            ? 'Usuario o contraseña incorrectos.'
            : 'Tu sesión ha expirado. Inicia sesión de nuevo.',
        statusCode: 401,
      );
    }

    if (status == 403) {
      return AuthException(
        detail ?? 'Cuenta inactiva o acceso denegado.',
        statusCode: 403,
      );
    }

    return AuthException(
      'No se pudo completar la operación. Inténtalo de nuevo más tarde.',
      statusCode: status,
    );
  }

  /// Extrae `{"detail": "..."}` de las respuestas de FastAPI, si existe.
  static String? _extractDetail(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) return detail.trim();
      }
    } catch (_) {
      // Cuerpo no JSON: se ignora y se usan los mensajes genéricos.
    }
    return null;
  }

  /// `Retry-After` puede venir en segundos o como fecha HTTP; solo se soporta
  /// el formato en segundos (el habitual en APIs).
  static Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }
}
