/// Configuración central de la API.
///
/// La URL base se puede sobreescribir en tiempo de build sin tocar código:
/// `flutter run --dart-define=API_BASE_URL=https://mi-servidor/`
class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'http://20.114.51.249/';

  /// URL base del backend (sin importar si termina en `/`).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const String loginPath = '/oauth/login';
  static const String logoutPath = '/oauth/logout';
  static const String equiposPath = '/equipos';
  static const String componentesPath = '/componentes';
  static const String revisionesPath = '/revisiones';
  static const String detallesRentaPath = '/detalles-renta';
  static const String rentasPath = '/rentas';
  static const String clientesPath = '/clientes';

  /// Ruta del listado de productos.
  /// Configurable: `--dart-define=PRODUCTS_PATH=/api/products`.
  static const String productsPath = String.fromEnvironment(
    'PRODUCTS_PATH',
    defaultValue: '/usuarios',
  );

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
