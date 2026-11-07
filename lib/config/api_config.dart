/// Configuración central de la API.
///
/// La URL base vive en un único punto ([_defaultBaseUrl]) y puede
/// sobreescribirse en tiempo de build sin tocar código:
/// `flutter run --dart-define=API_BASE_URL=https://mi-servidor/`
///
/// Nota: al ser un cliente móvil, cualquier URL incluida en el binario se
/// puede extraer con ingeniería inversa; por eso no se tratan como secretos.
/// La "protección" aquí es centralizar el valor, permitir sobreescribirlo
/// externamente y validarlo al arrancar para evitar configuraciones inválidas.
class ApiConfig {
  ApiConfig._();

  /// URL base por defecto del backend para esta rama.
  static const String _defaultBaseUrl = 'http://158.158.0.0/';

  /// Valor opcional pasado con `--dart-define=API_BASE_URL=...`.
  /// Tiene prioridad sobre [_defaultBaseUrl].
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// URL base del backend, siempre normalizada (esquema y `/` final).
  static final String baseUrl = _normalize(
    _overrideBaseUrl.isNotEmpty ? _overrideBaseUrl : _defaultBaseUrl,
  );

  /// Normaliza y valida la URL para que los servicios no tengan que hacerlo.
  static String _normalize(String value) {
    var url = value.trim();
    if (url.isEmpty) {
      throw StateError('La URL base de la API no puede estar vacía.');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (!url.endsWith('/')) {
      url = '$url/';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      throw FormatException('URL base de la API inválida: $value');
    }
    return url;
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
