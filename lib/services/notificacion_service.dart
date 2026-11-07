import 'dart:convert';

import '../config/api_config.dart';
import '../models/notificacion.dart';
import 'auth_service.dart';

class NotificacionService {
  NotificacionService({AuthService? auth})
      : _auth = auth ?? AuthService.instance;

  static final NotificacionService instance = NotificacionService();

  final AuthService _auth;

  Future<List<NotificacionApp>> obtenerPendientes() async {
    try {
      final uri = ApiConfig.endpoint(ApiConfig.notificacionesPendientesPath);
      final response = await _auth.getProtected(uri);
      if (response.statusCode != 200) {
        return const [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! List) return const [];

      return data
          .map((item) => NotificacionApp.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> marcarComoLeida(int notificacionId) async {
    try {
      final uri = ApiConfig.endpoint(
          '${ApiConfig.notificacionesPath}/$notificacionId/leer');
      final response = await _auth.postProtected(uri, body: {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> marcarTodasComoLeidas() async {
    try {
      final uri =
          ApiConfig.endpoint('${ApiConfig.notificacionesPath}/leer-todas');
      final response = await _auth.postProtected(uri, body: {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

