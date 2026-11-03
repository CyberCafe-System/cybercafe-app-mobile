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
      final activasJson = await _getList(
        ApiConfig.endpoint('${ApiConfig.rentasPath}/activas'),
        'No se pudieron cargar las rentas activas.',
      );
      if (activasJson.isEmpty) return const {};

      final rentasFuture = _getAllListOrEmpty(
        ApiConfig.rentasPath,
        'No se pudieron cargar las rentas.',
        maxItems: maxItems,
      );
      final clientesFuture = _getAllListOrEmpty(
        ApiConfig.clientesPath,
        'No se pudieron cargar los clientes.',
        maxItems: maxItems,
      );

      final rentas = await rentasFuture;
      final clientes = await clientesFuture;

      final clientePorRenta = <int, int>{};
      for (final renta in rentas) {
        final rentaId = _parseInt(renta['renta_id']);
        final clienteId = _parseInt(renta['cliente_id']);
        if (rentaId != null && clienteId != null) {
          clientePorRenta[rentaId] = clienteId;
        }
      }

      final nombrePorCliente = <int, String>{};
      for (final cliente in clientes) {
        final clienteId = _parseInt(cliente['cliente_id']);
        final nombre = _componerNombreCliente(cliente);
        if (clienteId != null && nombre != null) {
          nombrePorCliente[clienteId] = nombre;
        }
      }

      final activas = <int, RentaActivaEquipo>{};
      for (final item in activasJson) {
        final renta = RentaActivaEquipo.fromJson(
          item,
          consultadaEn: consultadaEn,
        );
        if (renta.equipoId < 1) continue;
        final clienteId = clientePorRenta[renta.rentaId];
        final clienteNombre = clienteId == null
            ? null
            : nombrePorCliente[clienteId];
        activas[renta.equipoId] = renta.conCliente(clienteNombre);
      }
      return activas;
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  Future<List<Map<String, dynamic>>> _getList(Uri uri, String fallback) async {
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

  Future<List<Map<String, dynamic>>> _getAllList(
    String path,
    String fallback, {
    int pageSize = 100,
    int maxItems = 5000,
  }) async {
    final items = <Map<String, dynamic>>[];
    var offset = 0;

    while (items.length < maxItems) {
      final page = await _getList(
        ApiConfig.endpoint(
          path,
        ).replace(queryParameters: {'offset': '$offset', 'limit': '$pageSize'}),
        fallback,
      );
      items.addAll(page);
      if (page.length < pageSize) break;
      offset += pageSize;
    }

    if (items.length > maxItems) {
      return items.sublist(0, maxItems);
    }
    return items;
  }

  Future<List<Map<String, dynamic>>> _getAllListOrEmpty(
    String path,
    String fallback, {
    int maxItems = 5000,
  }) async {
    try {
      return await _getAllList(path, fallback, maxItems: maxItems);
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const [];
    } catch (_) {
      return const [];
    }
  }

  String? _componerNombreCliente(Map<String, dynamic> cliente) {
    final nombre = cliente['nombre'];
    final apellido = cliente['apellido'];
    final partes = <String>[
      if (nombre is String && nombre.trim().isNotEmpty) nombre.trim(),
      if (apellido is String && apellido.trim().isNotEmpty) apellido.trim(),
    ];
    if (partes.isEmpty) return null;
    return partes.join(' ');
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

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
