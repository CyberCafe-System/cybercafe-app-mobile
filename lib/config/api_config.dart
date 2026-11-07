import 'package:flutter/foundation.dart';

/// Configuración central de la API.
///
/// La URL base se puede sobreescribir en tiempo de build sin tocar código:
/// `flutter run --dart-define=API_BASE_URL=https://mi-servidor/`
class ApiConfig {
  ApiConfig._();

  /// Valor opcional pasado con `--dart-define=API_BASE_URL=...`.
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Con 'adb reverse tcp:8080 tcp:8080' por cable USB, localhost apunta a la PC.
  static const String _defaultBaseUrlAndroid = 'http://10.0.2.2:8080/';
  //static const String _defaultBaseUrlAndroid = 'http://192.168.0.0:8080/';

  /// iOS Simulator, escritorio y pruebas usan el localhost del equipo.
  static const String _defaultBaseUrlLocal = 'http://127.0.0.1:8080/';

  /// URL base del backend (sin importar si termina en `/`).
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _defaultBaseUrlAndroid;
    }
    return _defaultBaseUrlLocal;
  }

  static const String loginPath = '/oauth/login';
  static const String logoutPath = '/oauth/logout';
  static const String equiposPath = '/equipos';
  static const String componentesPath = '/componentes';
  static const String revisionesPath = '/revisiones';
  static const String detallesRentaPath = '/detalles-renta';
  static const String detallesRentaPendientesRevisionPath =
      '/detalles-renta/pendientes-revision';
  static const String rentasPath = '/rentas';
  static const String ventasPath = '/ventas';
  static const String productosPath = '/productos';
  static const String categoriasPath = '/categorias';
  static const String clientesPath = '/clientes';
  static const String usuariosPath = '/usuarios';
  static const String perfilActualPath = '/usuarios/me';
  static const String reporteResumenGeneralPath = '/reportes/resumen-general';
  static const String reporteDiarioPath = '/reportes/diario';
  static const String notificacionesPendientesPath = '/notificaciones/pendientes';
  static const String notificacionesPath = '/notificaciones';

  static const Duration requestTimeout = Duration(seconds: 15);

  /// Une la base con [path] evitando barras duplicadas.
  static Uri endpoint(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
