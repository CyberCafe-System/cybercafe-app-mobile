import 'dart:convert';

import '../config/api_config.dart';
import '../models/componente.dart';
import 'auth_service.dart';

class ComponenteService {
  ComponenteService({AuthService? auth}) : _auth = auth ?? AuthService.instance;

  static final ComponenteService instance = ComponenteService();

  final AuthService _auth;

  Future<List<Componente>> getComponentes({
    int maxItems = 1000,
    bool? activo,
  }) async {
    if (maxItems < 1) {
      throw ArgumentError.value(
        maxItems,
        'maxItems',
        'Debe ser mayor o igual a 1',
      );
    }

    final componentes = <Componente>[];
    var offset = 0;
    const pageSize = 100;

    while (componentes.length < maxItems) {
      final uri = ApiConfig.endpoint(ApiConfig.componentesPath).replace(
        queryParameters: {
          'offset': '$offset',
          'limit': '$pageSize',
          if (activo != null) 'activo': '$activo',
        },
      );
      final pagina = await _getComponentes(
        uri,
        'No se pudieron cargar los componentes.',
        mensajePermisos: 'No tienes permisos para consultar componentes.',
      );
      componentes.addAll(pagina);
      if (pagina.length < pageSize) break;
      offset += pageSize;
    }

    if (componentes.length > maxItems) {
      return componentes.sublist(0, maxItems);
    }
    return componentes;
  }

  Future<List<Componente>> getComponentesPorEquipo(int equipoId) async {
    if (equipoId < 1) {
      throw ArgumentError.value(
        equipoId,
        'equipoId',
        'Debe ser mayor o igual a 1',
      );
    }

    final uri = ApiConfig.endpoint(
      '${ApiConfig.equiposPath}/$equipoId/componentes',
    );
    return _getComponentes(
      uri,
      'No se pudieron cargar los componentes.',
      mensajeNoEncontrado: 'Equipo no encontrado.',
    );
  }

  Future<List<Componente>> _getComponentes(
    Uri uri,
    String fallback, {
    String? mensajeNoEncontrado,
    String? mensajePermisos,
  }) async {
    final response = await _auth.getProtected(uri);

    if (response.statusCode == 404 && mensajeNoEncontrado != null) {
      throw AuthException(mensajeNoEncontrado, statusCode: 404);
    }
    if (response.statusCode != 200) {
      throw _errorFor(
        response.statusCode,
        response.bodyBytes,
        fallback,
        mensajePermisos: mensajePermisos,
      );
    }

    final data = _decode(response.bodyBytes, fallback);
    if (data is! List) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }

    final componentes = <Componente>[];
    for (final item in data) {
      if (item is! Map) {
        throw AuthException('El servidor devolvió una respuesta inesperada.');
      }
      componentes.add(Componente.fromJson(Map<String, dynamic>.from(item)));
    }
    return componentes;
  }

  dynamic _decode(List<int> bodyBytes, String fallback) {
    try {
      return jsonDecode(utf8.decode(bodyBytes));
    } catch (_) {
      throw AuthException(fallback);
    }
  }

  AuthException _errorFor(
    int statusCode,
    List<int> bodyBytes,
    String fallback, {
    String? mensajePermisos,
  }) {
    if (statusCode == 403) {
      return AuthException(
        mensajePermisos ?? 'No tienes permisos para gestionar componentes.',
        statusCode: statusCode,
      );
    }

    return AuthException(
      _detail(bodyBytes) ?? fallback,
      statusCode: statusCode,
    );
  }

  String? _detail(List<int> bodyBytes) {
    try {
      final data = jsonDecode(utf8.decode(bodyBytes));
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail.trim();
        }
      }
    } catch (_) {}
    return null;
  }
}
