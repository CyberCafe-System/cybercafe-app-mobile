import 'dart:convert';

import '../config/api_config.dart';
import '../models/componente.dart';
import 'auth_service.dart';

class ComponenteService {
  ComponenteService({AuthService? auth}) : _auth = auth ?? AuthService.instance;

  static final ComponenteService instance = ComponenteService();

  final AuthService _auth;

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
    final response = await _auth.getProtected(uri);

    if (response.statusCode == 404) {
      throw AuthException('Equipo no encontrado.', statusCode: 404);
    }
    if (response.statusCode != 200) {
      throw _errorFor(
        response.statusCode,
        response.bodyBytes,
        'No se pudieron cargar los componentes.',
      );
    }

    final data = _decode(
      response.bodyBytes,
      'No se pudieron cargar los componentes.',
    );
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

  Future<Componente> actualizarEstado(
    int componenteId,
    EstadoComponente estado,
  ) async {
    if (componenteId < 1) {
      throw ArgumentError.value(
        componenteId,
        'componenteId',
        'Debe ser mayor o igual a 1',
      );
    }

    final uri = ApiConfig.endpoint(
      '${ApiConfig.componentesPath}/$componenteId/estado',
    ).replace(queryParameters: {'nuevo_estado': estado.value});
    final response = await _auth.patchProtected(uri);

    if (response.statusCode == 404) {
      throw AuthException('Componente no encontrado.', statusCode: 404);
    }
    if (response.statusCode != 200) {
      throw _errorFor(
        response.statusCode,
        response.bodyBytes,
        'No se pudo actualizar el estado del componente.',
      );
    }

    final data = _decode(
      response.bodyBytes,
      'No se pudo actualizar el estado del componente.',
    );
    if (data is! Map) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
    return Componente.fromJson(Map<String, dynamic>.from(data));
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
    String fallback,
  ) {
    if (statusCode == 403) {
      return AuthException(
        'No tienes permisos para gestionar componentes.',
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
