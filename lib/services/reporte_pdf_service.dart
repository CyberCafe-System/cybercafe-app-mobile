import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/reporte_admin.dart';
import '../utils/reporte_formatters.dart';

class ReportePdfService {
  ReportePdfService._();

  static final ReportePdfService instance = ReportePdfService._();

  static final PdfColor _marron = PdfColor.fromHex('#2C1E16');
  static final PdfColor _ambar = PdfColor.fromHex('#B06B05');
  static final PdfColor _grisFondo = PdfColor.fromHex('#F4F6F9');
  static final PdfColor _grisTexto = PdfColor.fromHex('#5F5F5F');

  static pw.Font? _fuenteRegular;
  static pw.Font? _fuenteBold;

  Future<void> _cargarFuentes() async {
    if (_fuenteRegular != null && _fuenteBold != null) return;
    final regular = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    _fuenteRegular = pw.Font.ttf(regular);
    _fuenteBold = pw.Font.ttf(bold);
  }

  Future<void> exportarVentas(
    List<VentaReporte> ventas, {
    String? filtro,
  }) async {
    final bytes = await generarVentas(ventas, filtro: filtro);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'reporte_ventas_${_marcaTiempo()}.pdf',
    );
  }

  Future<Uint8List> generarVentas(
    List<VentaReporte> ventas, {
    String? filtro,
  }) async {
    await _cargarFuentes();
    final total = ventas.fold<double>(0, (suma, venta) => suma + venta.total);
    final documento = _crearDocumento(
      titulo: 'Reporte de Ventas',
      filtro: filtro,
      resumen: [
        _ResumenPdf('Ventas', '${ventas.length}'),
        _ResumenPdf('Total recaudado', formatearMoneda(total)),
      ],
      tabla: ventas.isEmpty
          ? _sinRegistros('No hay ventas para mostrar.')
          : pw.TableHelper.fromTextArray(
              headers: const ['Venta', 'Fecha', 'Cliente', 'Cajero', 'Total'],
              data: [
                for (final venta in ventas)
                  [
                    '#${venta.ventaId ?? '—'}',
                    formatearFechaHora(venta.fecha),
                    venta.clienteMostrado,
                    venta.cajeroMostrado,
                    formatearMoneda(venta.total),
                  ],
              ],
              headerDecoration: pw.BoxDecoration(color: _marron),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(fontSize: 8, color: _marron),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              headerPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8),
                1: const pw.FlexColumnWidth(1.8),
                2: const pw.FlexColumnWidth(2.2),
                3: const pw.FlexColumnWidth(1.8),
                4: const pw.FlexColumnWidth(1.1),
              },
            ),
    );

    return documento.save();
  }

  Future<void> exportarRentas(
    List<RentaReporte> rentas, {
    String? filtro,
  }) async {
    final bytes = await generarRentas(rentas, filtro: filtro);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'reporte_rentas_${_marcaTiempo()}.pdf',
    );
  }

  Future<Uint8List> generarRentas(
    List<RentaReporte> rentas, {
    String? filtro,
  }) async {
    await _cargarFuentes();
    final total = rentas.fold<double>(0, (suma, renta) => suma + renta.total);
    final pendientes = rentas
        .where((renta) => renta.estadoPago == EstadoPagoReporte.pendiente)
        .length;
    final documento = _crearDocumento(
      titulo: 'Reporte de Rentas',
      filtro: filtro,
      resumen: [
        _ResumenPdf('Rentas', '${rentas.length}'),
        _ResumenPdf('Total', formatearMoneda(total)),
        _ResumenPdf('Pendientes', '$pendientes'),
      ],
      tabla: rentas.isEmpty
          ? _sinRegistros('No hay rentas para mostrar.')
          : pw.TableHelper.fromTextArray(
              headers: const ['Renta', 'Fecha', 'Cliente', 'Estado', 'Total'],
              data: [
                for (final renta in rentas)
                  [
                    '#${renta.rentaId ?? '—'}',
                    formatearFechaHora(renta.fecha),
                    renta.clienteMostrado,
                    renta.estadoPago.etiqueta,
                    formatearMoneda(renta.total),
                  ],
              ],
              headerDecoration: pw.BoxDecoration(color: _marron),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(fontSize: 8, color: _marron),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              headerPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8),
                1: const pw.FlexColumnWidth(1.8),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.1),
              },
            ),
    );

    return documento.save();
  }

  Future<void> exportarInventario(
    List<ProductoReporte> productos, {
    String? filtro,
  }) async {
    final bytes = await generarInventario(productos, filtro: filtro);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'reporte_inventario_${_marcaTiempo()}.pdf',
    );
  }

  Future<Uint8List> generarInventario(
    List<ProductoReporte> productos, {
    String? filtro,
  }) async {
    await _cargarFuentes();
    final stockTotal = productos.fold<int>(
      0,
      (suma, producto) => suma + producto.cantidad,
    );
    final stockBajo = productos.where((producto) => producto.stockBajo).length;
    final documento = _crearDocumento(
      titulo: 'Reporte de Inventario',
      filtro: filtro,
      resumen: [
        _ResumenPdf('Productos', '${productos.length}'),
        _ResumenPdf('Stock total', '$stockTotal'),
        _ResumenPdf('Stock bajo', '$stockBajo'),
      ],
      tabla: productos.isEmpty
          ? _sinRegistros('No hay productos para mostrar.')
          : pw.TableHelper.fromTextArray(
              headers: const [
                'Producto',
                'Categoría',
                'Stock',
                'Compra',
                'Venta',
                'Estado',
              ],
              data: [
                for (final producto in productos)
                  [
                    producto.nombre,
                    producto.categoriaMostrada,
                    '${producto.cantidad}',
                    formatearMoneda(producto.precioCompra),
                    formatearMoneda(producto.precioVenta),
                    producto.activo ? 'Activo' : 'Inactivo',
                  ],
              ],
              headerDecoration: pw.BoxDecoration(color: _marron),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(fontSize: 8, color: _marron),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              headerPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(2.3),
                1: const pw.FlexColumnWidth(1.8),
                2: const pw.FlexColumnWidth(0.7),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(0.9),
              },
            ),
    );

    return documento.save();
  }

  pw.Document _crearDocumento({
    required String titulo,
    required List<_ResumenPdf> resumen,
    required pw.Widget tabla,
    String? filtro,
  }) {
    final documento = pw.Document(
      theme: pw.ThemeData.withFont(base: _fuenteRegular, bold: _fuenteBold),
    );
    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: _grisTexto),
            ),
          );
        },
        build: (context) => [
          _encabezado(titulo),
          pw.SizedBox(height: 14),
          _filaResumen(resumen),
          if (filtro != null && filtro.trim().isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Búsqueda aplicada: ${filtro.trim()}',
              style: pw.TextStyle(
                fontSize: 9,
                color: _grisTexto,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
          pw.SizedBox(height: 14),
          tabla,
        ],
      ),
    );
    return documento;
  }

  pw.Widget _encabezado(String titulo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _marron,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(
              color: _ambar,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Text(
              'CL',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CoffeeLan',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  titulo,
                  style: const pw.TextStyle(
                    color: PdfColors.grey300,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generado',
                style: const pw.TextStyle(
                  color: PdfColors.grey300,
                  fontSize: 8,
                ),
              ),
              pw.Text(
                formatearFechaHora(DateTime.now()),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _filaResumen(List<_ResumenPdf> resumen) {
    return pw.Row(
      children: [
        for (var i = 0; i < resumen.length; i++) ...[
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(9),
              decoration: pw.BoxDecoration(
                color: _grisFondo,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    resumen[i].etiqueta,
                    style: pw.TextStyle(fontSize: 8, color: _grisTexto),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    resumen[i].valor,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: _ambar,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (i < resumen.length - 1) pw.SizedBox(width: 8),
        ],
      ],
    );
  }

  pw.Widget _sinRegistros(String mensaje) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _grisFondo,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        mensaje,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 10, color: _grisTexto),
      ),
    );
  }

  String _marcaTiempo() {
    final ahora = DateTime.now();
    final fecha = fechaISO(ahora).replaceAll('-', '');
    final hora = ahora.hour.toString().padLeft(2, '0');
    final minuto = ahora.minute.toString().padLeft(2, '0');
    return '${fecha}_$hora$minuto';
  }
}

class _ResumenPdf {
  const _ResumenPdf(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;
}
