import 'package:http/http.dart' as http;

/// Una página individual devuelta por un endpoint paginado.
class PaginaApi<T> {
  const PaginaApi({required this.items, this.total});

  final List<T> items;

  /// Total de registros reportado en la cabecera `X-Total-Count`.
  ///
  /// Es `null` cuando el servidor no envía la cabecera (por ejemplo, una
  /// versión anterior del backend).
  final int? total;
}

/// Resultado de recorrer una o varias páginas.
class ResultadoPaginado<T> {
  const ResultadoPaginado({required this.items, required this.truncado});

  final List<T> items;

  /// `true` cuando se alcanzó el tope local [PaginadorApi.recolectar] y el
  /// servidor todavía podía tener más registros.
  final bool truncado;
}

/// Utilidades para recorrer endpoints que usan `offset`/`limit`.
///
/// El servidor expone el total de registros en `X-Total-Count`. Cuando esa
/// cabecera está presente se evita una petición extra al final; cuando no,
/// se conserva el comportamiento anterior de detenerse con una página
/// incompleta.
class PaginadorApi {
  PaginadorApi._();

  /// Lee el total de registros de una respuesta HTTP.
  static int? totalDesde(http.Response response) {
    final raw =
        response.headers['x-total-count'] ?? response.headers['X-Total-Count'];
    if (raw == null) return null;
    return int.tryParse(raw.trim());
  }

  /// Recorre todas las páginas de un endpoint.
  ///
  /// Se detiene cuando la página viene vacía, cuando trae menos de [pageSize]
  /// elementos, cuando ya se recolectó el total reportado por el servidor o
  /// cuando se alcanza [maxItems].
  static Future<ResultadoPaginado<T>> recolectar<T>({
    required Future<PaginaApi<T>> Function(int offset, int limit) cargarPagina,
    int pageSize = 100,
    int? maxItems,
  }) async {
    if (pageSize < 1) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Debe ser mayor o igual a 1',
      );
    }
    if (maxItems != null && maxItems < 1) {
      throw ArgumentError.value(
        maxItems,
        'maxItems',
        'Debe ser mayor o igual a 1',
      );
    }

    final items = <T>[];
    int? total;
    var offset = 0;

    while (true) {
      final pagina = await cargarPagina(offset, pageSize);
      total = pagina.total ?? total;
      items.addAll(pagina.items);

      if (pagina.items.isEmpty) break;
      if (total != null && items.length >= total) break;
      if (maxItems != null && items.length >= maxItems) break;
      if (pagina.items.length < pageSize) break;

      offset += pageSize;
    }

    final truncado =
        maxItems != null &&
        items.length >= maxItems &&
        (total == null || items.length < total);

    final recortados = items.length > (maxItems ?? items.length)
        ? items.sublist(0, maxItems)
        : items;

    return ResultadoPaginado(items: recortados, truncado: truncado);
  }
}
