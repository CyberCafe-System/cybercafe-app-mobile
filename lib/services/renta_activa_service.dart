import 'dart:convert';

import '../config/api_config.dart';
import '../models/renta_activa.dart';
import 'auth_service.dart';

class RentaActivaService {
  RentaActivaService({AuthService? auth})
    : _auth = auth ?? AuthService.instance;

  static final RentaActivaService instance = RentaActivaService();

  final AuthService _auth;

  Future<Map<int, RentaActivaEquipo>> getRentasActivasPorEquipo({
    int maxItems = 5000,
  }) async {
    final consultadaEn = DateTime.now();

    try {
      // /rentas/activas devuelve directamente todas las rentas activas en una sola petición.
      final activasJson = await _getListDirecta(
        ApiConfig.endpoint('${ApiConfig.rentasPath}/activas'),
        'No se pudieron cargar las rentas activas.',
      );
      if (activasJson.isEmpty) return const {};

      final activas = <int, RentaActivaEquipo>{};
      final limite = activasJson.length > maxItems ? maxItems : activasJson.length;
      for (var i = 0; i < limite; i++) {
        final renta = RentaActivaEquipo.fromJson(
          activasJson[i],
          consultadaEn: consultadaEn,
        );
        if (renta.equipoId < 1) continue;
        activas[renta.equipoId] = renta;
      }
      return activas;
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  Future<List<Map<String, dynamic>>> _getListDirecta(
    Uri uri,
    String fallback,
  ) async {
    final response = await _auth.getProtected(uri);
    if (response.statusCode != 200) {
      throw _errorFor(response.statusCode, response.bodyBytes, fallback);
    }

    final data = _decode(response.bodyBytes, fallback);
    if (data is! List) {
      throw AuthException('El servidor devolvió una respuesta inesperada.');
    }

    final items = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is! Map) {
        throw AuthException('El servidor devolvió una respuesta inesperada.');
      }
      items.add(Map<String, dynamic>.from(item));
    }
    return items;
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
