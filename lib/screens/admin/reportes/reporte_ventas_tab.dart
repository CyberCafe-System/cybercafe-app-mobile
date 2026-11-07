import 'package:flutter/material.dart';

import '../../../models/reporte_admin.dart';
import '../../../services/reporte_pdf_service.dart';
import '../../../utils/busqueda_reportes.dart';
import '../../../utils/reporte_formatters.dart';
import 'reporte_widgets.dart';
import 'venta_detalle_screen.dart';

class ReporteVentasTab extends StatefulWidget {
  const ReporteVentasTab({
    super.key,
    required this.ventas,
    required this.onRefresh,
  });

  final List<VentaReporte> ventas;
  final Future<void> Function() onRefresh;

  @override
  State<ReporteVentasTab> createState() => _ReporteVentasTabState();
}

class _ReporteVentasTabState extends State<ReporteVentasTab> {
  static const int _pageSize = 25;
  final TextEditingController _busqueda = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _consulta = '';
  bool _exportando = false;
  int _visibles = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final totalFiltradas = _filtradas.length;
      if (_visibles < totalFiltradas) {
        setState(() {
          _visibles = (_visibles + _pageSize).clamp(0, totalFiltradas);
        });
      }
    }
  }

  List<VentaReporte> get _filtradas {
    if (_consulta.trim().isEmpty) return widget.ventas;
    return widget.ventas
        .where((venta) => coincideVenta(venta, _consulta))
        .toList();
  }

  Future<void> _exportarPdf() async {
    final ventas = _filtradas.where((v) => !v.estaAnulada).toList();
    if (ventas.isEmpty) {
      _mostrarMensaje('No hay ventas para exportar.');
      return;
    }

    setState(() => _exportando = true);
    try {
      await ReportePdfService.instance.exportarVentas(
        ventas,
        filtro: _consulta,
      );
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo generar el PDF de ventas.');
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
    final ventas = _filtradas;
    final ventasValidas = ventas.where((v) => !v.estaAnulada).toList();
    final total = ventasValidas.fold<double>(
      0,
      (suma, venta) => suma + venta.total,
    );
    final promedio =
        ventasValidas.isEmpty ? 0.0 : total / ventasValidas.length;
    final ventasMostradas = ventas.take(_visibles).toList();
    final hayMas = ventasMostradas.length < ventas.length;

    return RefreshIndicator(
      color: adminAmbar,
      onRefresh: widget.onRefresh,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          ReporteActionBar(
            controller: _busqueda,
            hintText: 'Cliente, ID o cajero...',
            onChanged: (valor) => setState(() {
              _consulta = valor;
              _visibles = _pageSize;
            }),
            onRefresh: () => widget.onRefresh(),
            onPdf: _exportarPdf,
            exportando: _exportando,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Total recaudado',
                  valor: formatearMoneda(total),
                  icono: Icons.attach_money_rounded,
                  color: adminVerde,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Ventas',
                  valor: '${ventasValidas.length}',
                  icono: Icons.receipt_long_rounded,
                  color: adminAmbar,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Ticket promedio',
                  valor: formatearMoneda(promedio),
                  icono: Icons.insights_rounded,
                  color: adminAzul,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (ventas.isEmpty)
            SizedBox(
              height: 300,
              child: ReporteEmptyState(
                icono: Icons.receipt_long_rounded,
                titulo: _consulta.trim().isEmpty
                    ? 'Sin ventas registradas'
                    : 'Sin resultados',
                mensaje: _consulta.trim().isEmpty
                    ? 'Cuando se registre una venta aparecerá aquí con el cliente y su total.'
                    : 'No hay ventas que coincidan con "${_consulta.trim()}".',
              ),
            )
          else ...[
            for (final venta in ventasMostradas) ...[
              _TarjetaVenta(
                venta: venta,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VentaDetalleScreen(venta: venta),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
            if (hayMas)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _visibles = (_visibles + _pageSize).clamp(
                        0,
                        ventas.length,
                      );
                    });
                  },
                  icon: const Icon(Icons.expand_more_rounded),
                  label: Text(
                    'Cargar más (${ventasMostradas.length} de ${ventas.length})',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaVenta extends StatelessWidget {
  const _TarjetaVenta({required this.venta, required this.onTap});

  final VentaReporte venta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: adminAmbar.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: adminAmbar,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta #${venta.ventaId ?? '—'}',
                        style: const TextStyle(
                          color: adminMarron,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        venta.clienteMostrado,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${formatearFechaHora(venta.fecha)} · ${venta.cajeroMostrado}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatearMoneda(venta.total),
                      style: const TextStyle(
                        color: adminVerde,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
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
