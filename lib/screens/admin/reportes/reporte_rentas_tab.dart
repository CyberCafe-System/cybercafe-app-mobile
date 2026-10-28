import 'package:flutter/material.dart';

import '../../../models/reporte_admin.dart';
import '../../../services/reporte_pdf_service.dart';
import '../../../utils/reporte_formatters.dart';
import 'renta_detalle_screen.dart';
import 'reporte_widgets.dart';

class ReporteRentasTab extends StatefulWidget {
  const ReporteRentasTab({
    super.key,
    required this.rentas,
    required this.onRefresh,
  });

  final List<RentaReporte> rentas;
  final Future<void> Function() onRefresh;

  @override
  State<ReporteRentasTab> createState() => _ReporteRentasTabState();
}

class _ReporteRentasTabState extends State<ReporteRentasTab> {
  final TextEditingController _busqueda = TextEditingController();
  String _consulta = '';
  bool _exportando = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<RentaReporte> get _filtradas {
    final consulta = _consulta.trim().toLowerCase();
    if (consulta.isEmpty) return widget.rentas;
    return widget.rentas.where((renta) {
      final texto = [
        'renta ${renta.rentaId ?? ''}',
        renta.clienteMostrado,
        renta.cajeroMostrado,
        renta.estadoPago.etiqueta,
        formatearFechaHora(renta.fecha),
      ].join(' ').toLowerCase();
      return texto.contains(consulta);
    }).toList();
  }

  Future<void> _exportarPdf() async {
    final rentas = _filtradas;
    if (rentas.isEmpty) {
      _mostrarMensaje('No hay rentas para exportar.');
      return;
    }

    setState(() => _exportando = true);
    try {
      await ReportePdfService.instance.exportarRentas(
        rentas,
        filtro: _consulta,
      );
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo generar el PDF de rentas.');
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
    final rentas = _filtradas;
    final total = rentas.fold<double>(0, (suma, renta) => suma + renta.total);
    final pendientes = rentas
        .where((renta) => renta.estadoPago == EstadoPagoReporte.pendiente)
        .length;

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
            hintText: 'Buscar por cliente, renta o estado...',
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
                  titulo: 'Total rentas',
                  valor: formatearMoneda(total),
                  icono: Icons.computer_rounded,
                  color: adminAmbar,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Rentas',
                  valor: '${rentas.length}',
                  icono: Icons.receipt_rounded,
                  color: adminAzul,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReporteStatCard(
                  titulo: 'Pendientes',
                  valor: '$pendientes',
                  icono: Icons.pending_actions_rounded,
                  color: pendientes > 0 ? adminRojo : adminVerde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (rentas.isEmpty)
            const SizedBox(
              height: 300,
              child: ReporteEmptyState(
                icono: Icons.computer_rounded,
                titulo: 'Sin rentas registradas',
                mensaje:
                    'Las rentas de equipos aparecerán aquí con su cliente y estado de pago.',
              ),
            )
          else
            for (final renta in rentas) ...[
              _TarjetaRenta(
                renta: renta,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RentaDetalleScreen(renta: renta),
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

class _TarjetaRenta extends StatelessWidget {
  const _TarjetaRenta({required this.renta, required this.onTap});

  final RentaReporte renta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorPago = _colorEstadoPago(renta.estadoPago);
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
                    color: adminAzul.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.computer_rounded, color: adminAzul),
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
                              'Renta #${renta.rentaId ?? '—'}',
                              style: const TextStyle(
                                color: adminMarron,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          EstadoChip(
                            etiqueta: renta.estadoPago.etiqueta,
                            color: colorPago,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        renta.clienteMostrado,
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
                        '${formatearFechaHora(renta.fecha)} · ${renta.cajeroMostrado}',
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
                      formatearMoneda(renta.total),
                      style: const TextStyle(
                        color: adminAmbar,
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

Color _colorEstadoPago(EstadoPagoReporte estado) {
  switch (estado) {
    case EstadoPagoReporte.pagado:
      return adminVerde;
    case EstadoPagoReporte.pendiente:
      return const Color(0xFFE65100);
    case EstadoPagoReporte.desconocido:
      return Colors.grey;
  }
}
