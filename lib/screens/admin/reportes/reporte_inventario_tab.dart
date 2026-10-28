import 'package:flutter/material.dart';

import '../../../models/reporte_admin.dart';
import '../../../services/reporte_pdf_service.dart';
import '../../../utils/reporte_formatters.dart';
import 'producto_detalle_screen.dart';
import 'reporte_widgets.dart';

class ReporteInventarioTab extends StatefulWidget {
  const ReporteInventarioTab({
    super.key,
    required this.productos,
    required this.onRefresh,
  });

  final List<ProductoReporte> productos;
  final Future<void> Function() onRefresh;

  @override
  State<ReporteInventarioTab> createState() => _ReporteInventarioTabState();
}

class _ReporteInventarioTabState extends State<ReporteInventarioTab> {
  final TextEditingController _busqueda = TextEditingController();
  String _consulta = '';
  bool _exportando = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<ProductoReporte> get _filtrados {
    final consulta = _consulta.trim().toLowerCase();
    if (consulta.isEmpty) return widget.productos;
    return widget.productos.where((producto) {
      final texto = [
        producto.nombre,
        producto.categoriaMostrada,
        producto.activo ? 'activo' : 'inactivo',
        producto.stockBajo ? 'stock bajo' : '',
      ].join(' ').toLowerCase();
      return texto.contains(consulta);
    }).toList();
  }

  Future<void> _exportarPdf() async {
    final productos = _filtrados;
    if (productos.isEmpty) {
      _mostrarMensaje('No hay productos para exportar.');
      return;
    }

    setState(() => _exportando = true);
    try {
      await ReportePdfService.instance.exportarInventario(
        productos,
        filtro: _consulta,
      );
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo generar el PDF de inventario.');
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final productos = _filtrados;
    final stockTotal = productos.fold<int>(
      0,
      (suma, producto) => suma + producto.cantidad,
    );
    final stockBajo = productos.where((producto) => producto.stockBajo).length;

    return RefreshIndicator(
      color: adminAmbar,
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          ReporteActionBar(
            controller: _busqueda,
            hintText: 'Buscar producto o categoría...',
            onChanged: (valor) => setState(() => _consulta = valor),
            onRefresh: () => widget.onRefresh(),
            onPdf: _exportarPdf,
            exportando: _exportando,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Productos',
                  valor: '${productos.length}',
                  icono: Icons.inventory_2_rounded,
                  color: adminAmbar,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Stock total',
                  valor: '$stockTotal',
                  icono: Icons.warehouse_rounded,
                  color: adminAzul,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Stock bajo',
                  valor: '$stockBajo',
                  icono: Icons.warning_amber_rounded,
                  color: stockBajo > 0 ? adminRojo : adminVerde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (productos.isEmpty)
            const SizedBox(
              height: 300,
              child: ReporteEmptyState(
                icono: Icons.inventory_2_rounded,
                titulo: 'Sin productos registrados',
                mensaje:
                    'Los productos del inventario aparecerán aquí con su stock y precios.',
              ),
            )
          else
            for (final producto in productos) ...[
              _TarjetaProducto(
                producto: producto,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductoDetalleScreen(producto: producto),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  const _TarjetaProducto({required this.producto, required this.onTap});

  final ProductoReporte producto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorStock = producto.stockBajo ? adminRojo : adminVerde;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorStock.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.inventory_2_rounded, color: colorStock),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              producto.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: adminMarron,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (!producto.activo)
                            const EstadoChip(
                              etiqueta: 'Inactivo',
                              color: Colors.grey,
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        producto.categoriaMostrada,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Compra ${formatearMoneda(producto.precioCompra)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Venta ${formatearMoneda(producto.precioVenta)}',
                            style: const TextStyle(
                              color: adminAmbar,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    EstadoChip(
                      etiqueta: '${producto.cantidad} uds',
                      color: colorStock,
                    ),
                    const SizedBox(height: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black38,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
