import 'dart:convert';

import '../config/api_config.dart';
import '../models/equipo.dart';
import 'auth_service.dart';

class EquipoService {
  EquipoService({AuthService? auth}) : _auth = auth ?? AuthService.instance;

  static final EquipoService instance = EquipoService();

  final AuthService _auth;

  Future<List<Equipo>> getEquipos({int offset = 0, int limit = 20}) async {
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'Debe ser mayor o igual a 0');
    }
    if (limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'Debe ser mayor o igual a 1');
    }

    final uri = ApiConfig.endpoint(
      ApiConfig.equiposPath,
    ).replace(queryParameters: {'offset': '$offset', 'limit': '$limit'});

    final response = await _auth.getProtected(uri);

    if (response.statusCode != 200) {
      throw _errorFor(
        response.statusCode,
        response.bodyBytes,
        'No se pudieron cargar los equipos.',
      );
    }

    final data = _decode(
      response.bodyBytes,
      'No se pudieron cargar los equipos.',
    );
    if (data is! List) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }

    final equipos = <Equipo>[];
    for (final item in data) {
      if (item is! Map) {
        throw AuthException('El servidor devolvió una respuesta inesperada.');
      }
      equipos.add(Equipo.fromJson(Map<String, dynamic>.from(item)));
    }
    return equipos;
  }

  Future<Equipo> getEquipo(int id) async {
    if (id < 1) {
      throw ArgumentError.value(id, 'id', 'Debe ser mayor o igual a 1');
    }

    final uri = ApiConfig.endpoint('${ApiConfig.equiposPath}/$id');
    final response = await _auth.getProtected(uri);

    if (response.statusCode == 404) {
      throw AuthException('Equipo no encontrado.', statusCode: 404);
    }
    if (response.statusCode != 200) {
      throw _errorFor(
        response.statusCode,
        response.bodyBytes,
        'No se pudo cargar el equipo.',
      );
    }

    final data = _decode(response.bodyBytes, 'No se pudo cargar el equipo.');
    if (data is! Map) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }
    return Equipo.fromJson(Map<String, dynamic>.from(data));
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
        'No tienes permisos para consultar equipos.',
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
