import 'package:flutter/material.dart';

import '../../../models/reporte_admin.dart';
import '../../../services/reporte_admin_service.dart';
import '../../../utils/reporte_formatters.dart';
import 'reporte_widgets.dart';

class VentaDetalleScreen extends StatefulWidget {
  const VentaDetalleScreen({super.key, required this.venta});

  final VentaReporte venta;

  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
  late Future<VentaDetalleCompleto> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<VentaDetalleCompleto> _cargar() {
    final id = widget.venta.ventaId;
    if (id == null) {
      return Future.error('La venta no tiene un identificador válido.');
    }
    return ReporteAdminService.instance.cargarDetalleVenta(id);
  }

  void _recargar() {
    setState(() => _future = _cargar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminFondo,
      appBar: AppBar(
        backgroundColor: adminMarron,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Venta #${widget.venta.ventaId ?? '—'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<VentaDetalleCompleto>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: adminAmbar),
            );
          }
          if (snapshot.hasError) {
            return ReporteErrorState(
              mensaje: '${snapshot.error}',
              onRetry: _recargar,
            );
          }

          final detalle = snapshot.data!;
          final venta = detalle.venta;
          final cliente = venta.cliente;
          return RefreshIndicator(
            color: adminAmbar,
            onRefresh: () async => _recargar(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                _HeroVenta(venta: venta),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ReporteStatCard(
                        titulo: 'Subtotal',
                        valor: formatearMoneda(venta.subtotal),
                        icono: Icons.receipt_long_rounded,
                        color: adminAzul,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReporteStatCard(
                        titulo: 'IVA',
                        valor: formatearMoneda(venta.iva),
                        icono: Icons.percent_rounded,
                        color: adminAmbar,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ReporteSectionCard(
                  titulo: 'Cliente',
                  icono: Icons.person_rounded,
                  child: Column(
                    children: [
                      ReporteInfoRow(
                        etiqueta: 'Nombre',
                        valor: cliente?.nombreCompleto ?? venta.clienteMostrado,
                        icono: Icons.badge_outlined,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'DUI',
                        valor: _texto(cliente?.dui),
                        icono: Icons.credit_card_rounded,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'Teléfono',
                        valor: formatearTelefono(cliente?.telefono),
                        icono: Icons.phone_rounded,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'Correo',
                        valor: _texto(cliente?.correo),
                        icono: Icons.email_rounded,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'Dirección',
                        valor: _texto(cliente?.direccion),
                        icono: Icons.location_on_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ReporteSectionCard(
                  titulo: 'Información de la venta',
                  icono: Icons.info_outline_rounded,
                  child: Column(
                    children: [
                      ReporteInfoRow(
                        etiqueta: 'Venta',
                        valor: '#${venta.ventaId ?? '—'}',
                        icono: Icons.tag_rounded,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'Fecha',
                        valor: formatearFechaHora(venta.fecha),
                        icono: Icons.calendar_today_rounded,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'Cajero',
                        valor: venta.cajeroMostrado,
                        icono: Icons.point_of_sale_rounded,
                      ),
                      ReporteInfoRow(
                        etiqueta: 'Productos',
                        valor: '${detalle.detalles.length}',
                        icono: Icons.shopping_bag_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ReporteSectionCard(
                  titulo: 'Productos vendidos',
                  icono: Icons.shopping_cart_rounded,
                  child: detalle.detalles.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Esta venta no tiene productos registrados.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : Column(
                          children: [
                            for (
                              var i = 0;
                              i < detalle.detalles.length;
                              i++
                            ) ...[
                              _LineaProducto(
                                numero: i + 1,
                                detalle: detalle.detalles[i],
                              ),
                              if (i < detalle.detalles.length - 1)
                                Divider(
                                  height: 22,
                                  color: Colors.grey.shade200,
                                ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                _ResumenTotal(venta: venta),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _texto(String? valor) {
  final texto = valor?.trim();
  return texto == null || texto.isEmpty ? 'No disponible' : texto;
}

class _HeroVenta extends StatelessWidget {
  const _HeroVenta({required this.venta});

  final VentaReporte venta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total de la venta',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      formatearMoneda(venta.total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatearFechaHora(venta.fecha),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Flexible(
                child: Text(
                  venta.clienteMostrado,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineaProducto extends StatelessWidget {
  const _LineaProducto({required this.numero, required this.detalle});

  final int numero;
  final DetalleVentaReporte detalle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: adminAmbar.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$numero',
            style: const TextStyle(
              color: adminAmbar,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detalle.productoNombre,
                style: const TextStyle(
                  color: adminMarron,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${detalle.cantidad} × ${formatearMoneda(detalle.precioUnitario)}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatearMoneda(detalle.subtotal),
          style: const TextStyle(
            color: adminAmbar,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ResumenTotal extends StatelessWidget {
  const _ResumenTotal({required this.venta});

  final VentaReporte venta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: adminAmbar.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ReporteInfoRow(
            etiqueta: 'Subtotal',
            valor: formatearMoneda(venta.subtotal),
          ),
          ReporteInfoRow(etiqueta: 'IVA', valor: formatearMoneda(venta.iva)),
          Divider(color: Colors.grey.shade200),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL',
                  style: TextStyle(
                    color: adminMarron,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                formatearMoneda(venta.total),
                style: const TextStyle(
                  color: adminAmbar,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
