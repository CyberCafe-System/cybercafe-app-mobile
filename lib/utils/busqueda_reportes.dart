import '../models/reporte_admin.dart';

const Map<String, String> _equivalencias = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

String normalizarTextoBusqueda(String texto) {
  var normalizado = texto.toLowerCase();
  for (final entrada in _equivalencias.entries) {
    normalizado = normalizado.replaceAll(entrada.key, entrada.value);
  }
  return normalizado.replaceAll(RegExp(r'\s+'), ' ').trim();
}

int? idDesdeBusqueda(String consulta) {
  final limpio = normalizarTextoBusqueda(consulta)
      .replaceFirst(RegExp(r'^(venta|renta)\s*#?\s*'), '')
      .replaceFirst('#', '')
      .trim();
  if (limpio.isEmpty || !RegExp(r'^\d+$').hasMatch(limpio)) return null;
  return int.tryParse(limpio);
}

bool coincideVenta(VentaReporte venta, String consulta) {
  final termino = normalizarTextoBusqueda(consulta);
  if (termino.isEmpty) return true;

  final id = idDesdeBusqueda(consulta);
  if (id != null) return venta.ventaId == id;

  return _coincideAlguno(termino, [
    venta.clienteMostrado,
    venta.cajeroMostrado,
  ]);
}

bool coincideRenta(RentaReporte renta, String consulta) {
  final termino = normalizarTextoBusqueda(consulta);
  if (termino.isEmpty) return true;

  final id = idDesdeBusqueda(consulta);
  if (id != null) return renta.rentaId == id;

  return _coincideAlguno(termino, [
    renta.clienteMostrado,
    renta.estadoPago.etiqueta,
    ...renta.estadosRenta.map((estado) => estado.etiqueta),
  ]);
}

bool coincideProducto(ProductoReporte producto, String consulta) {
  final termino = normalizarTextoBusqueda(consulta);
  if (termino.isEmpty) return true;

  return _coincideAlguno(termino, [
    producto.nombre,
    producto.categoriaMostrada,
  ]);
}

bool _coincideAlguno(String termino, Iterable<String?> campos) {
  return campos.any(
    (campo) => normalizarTextoBusqueda(campo ?? '').contains(termino),
  );
}
