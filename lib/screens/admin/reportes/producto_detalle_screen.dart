import 'package:flutter/material.dart';

import '../../../models/reporte_admin.dart';
import '../../../utils/reporte_formatters.dart';
import 'reporte_widgets.dart';

class ProductoDetalleScreen extends StatelessWidget {
  const ProductoDetalleScreen({super.key, required this.producto});

  final ProductoReporte producto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminFondo,
      appBar: AppBar(
        backgroundColor: adminMarron,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          producto.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          _HeroProducto(producto: producto),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Precio compra',
                  valor: formatearMoneda(producto.precioCompra),
                  icono: Icons.shopping_basket_rounded,
                  color: adminAzul,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Precio venta',
                  valor: formatearMoneda(producto.precioVenta),
                  icono: Icons.sell_rounded,
                  color: adminVerde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Stock actual',
                  valor: '${producto.cantidad}',
                  detalle: producto.stockBajo
                      ? 'Requiere reposición'
                      : 'Stock saludable',
                  icono: Icons.inventory_2_rounded,
                  color: producto.stockBajo ? adminRojo : adminAmbar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Margen',
                  valor: formatearMoneda(producto.margen),
                  icono: Icons.trending_up_rounded,
                  color: producto.margen >= 0 ? adminVerde : adminRojo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ReporteSectionCard(
            titulo: 'Información del producto',
            icono: Icons.inventory_rounded,
            child: Column(
              children: [
                ReporteInfoRow(
                  etiqueta: 'Producto',
                  valor: producto.nombre,
                  icono: Icons.label_rounded,
                ),
                ReporteInfoRow(
                  etiqueta: 'ID',
                  valor: '#${producto.productoId ?? '—'}',
                  icono: Icons.tag_rounded,
                ),
                ReporteInfoRow(
                  etiqueta: 'Categoría',
                  valor: producto.categoriaMostrada,
                  icono: Icons.category_rounded,
                ),
                ReporteInfoRow(
                  etiqueta: 'Stock',
                  valor: '${producto.cantidad} unidades',
                  icono: Icons.warehouse_rounded,
                ),
                ReporteInfoRow(
                  etiqueta: 'Estado',
                  valor: producto.activo ? 'Activo' : 'Inactivo',
                  icono: Icons.verified_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ReporteSectionCard(
            titulo: 'Precios y ganancia',
            icono: Icons.payments_rounded,
            color: adminVerde,
            child: Column(
              children: [
                ReporteInfoRow(
                  etiqueta: 'Compra',
                  valor: formatearMoneda(producto.precioCompra),
                ),
                ReporteInfoRow(
                  etiqueta: 'Venta',
                  valor: formatearMoneda(producto.precioVenta),
                ),
                Divider(color: Colors.grey.shade200),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Margen por unidad',
                        style: TextStyle(
                          color: adminMarron,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      formatearMoneda(producto.margen),
                      style: TextStyle(
                        color: producto.margen >= 0 ? adminVerde : adminRojo,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (producto.stockBajo) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: adminRojo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: adminRojo.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: adminRojo),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este producto tiene 5 unidades o menos. Considera reabastecer el inventario.',
                      style: TextStyle(
                        color: adminRojo,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroProducto extends StatelessWidget {
  const _HeroProducto({required this.producto});

  final ProductoReporte producto;

  @override
  Widget build(BuildContext context) {
    final imagen = producto.imagen;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [adminMarron, Color(0xFF5A3514), adminAmbar],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: adminMarron.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 76,
              height: 76,
              color: Colors.white.withValues(alpha: 0.15),
              child: imagen == null || imagen.trim().isEmpty
                  ? const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 38,
                    )
                  : Image.network(
                      imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  producto.categoriaMostrada,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    EstadoChip(
                      etiqueta: producto.activo ? 'Activo' : 'Inactivo',
                      color: Colors.white,
                    ),
                    if (producto.stockBajo) ...[
                      const SizedBox(width: 6),
                      const EstadoChip(
                        etiqueta: 'Stock bajo',
                        color: Color(0xFFFFCDD2),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
