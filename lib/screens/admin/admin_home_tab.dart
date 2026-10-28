import 'package:flutter/material.dart';

import '../../models/dashboard_admin.dart';
import '../../services/auth_service.dart';
import '../../services/reporte_admin_service.dart';
import '../../utils/reporte_formatters.dart';
import 'reportes/reporte_widgets.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  late Future<DashboardAdminData> _future;

  @override
  void initState() {
    super.initState();
    _future = ReporteAdminService.instance.cargarDashboard();
  }

  Future<void> _recargar() async {
    final future = ReporteAdminService.instance.cargarDashboard(
      forceRefresh: true,
    );
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // El FutureBuilder muestra el error y permite reintentar.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: adminMarron,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: adminAmbar,
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AuthService.instance.nombreMostrado,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                AuthService.instance.etiquetaRol,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset('assets/img/logo_login.png', height: 40),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<DashboardAdminData>(
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

              final datos = snapshot.data!;
              return RefreshIndicator(
                color: adminAmbar,
                onRefresh: _recargar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  children: [
                    _EncabezadoSeccion(
                      titulo: 'Resumen del Día',
                      subtitulo: formatearFecha(datos.hoy.fecha),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ReporteStatCard(
                            titulo: 'Ingresos hoy',
                            valor: formatearMoneda(datos.hoy.totalDia),
                            detalle:
                                '${datos.hoy.cantidadVentasHoy + datos.hoy.cantidadRentasHoy} operaciones',
                            icono: Icons.attach_money_rounded,
                            color: adminVerde,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ReporteStatCard(
                            titulo: 'Ventas hoy',
                            valor: formatearMoneda(datos.hoy.ingresosVentasHoy),
                            detalle: '${datos.hoy.cantidadVentasHoy} ventas',
                            icono: Icons.receipt_long_rounded,
                            color: adminAmbar,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ReporteStatCard(
                            titulo: 'Rentas hoy',
                            valor: formatearMoneda(datos.hoy.ingresosRentasHoy),
                            detalle: '${datos.hoy.cantidadRentasHoy} rentas',
                            icono: Icons.computer_rounded,
                            color: adminAzul,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ReporteStatCard(
                            titulo: 'Rentas activas',
                            valor: '${datos.general.sesionesRentaActivas}',
                            detalle: 'En curso ahora',
                            icono: Icons.play_circle_rounded,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ReporteStatCard(
                            titulo: 'Stock bajo',
                            valor: '${datos.general.productosStockBajo}',
                            detalle: 'Productos con 5 o menos',
                            icono: Icons.warning_amber_rounded,
                            color: datos.general.productosStockBajo > 0
                                ? adminRojo
                                : adminVerde,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ReporteStatCard(
                            titulo: 'Clientes',
                            valor: '${datos.general.totalClientes}',
                            detalle: 'Registrados',
                            icono: Icons.people_alt_rounded,
                            color: const Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _EncabezadoSeccion(
                      titulo: 'Estado General',
                      subtitulo: 'Acumulado histórico del cybercafé',
                    ),
                    const SizedBox(height: 14),
                    ReporteSectionCard(
                      titulo: 'Indicadores globales',
                      icono: Icons.dashboard_customize_rounded,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final ancho = (constraints.maxWidth - 10) / 2;
                          final items = <_MiniStat>[
                            _MiniStat(
                              titulo: 'Ingresos totales',
                              valor: formatearMoneda(
                                datos.general.totalIngresos,
                              ),
                              icono: Icons.savings_rounded,
                              color: adminVerde,
                            ),
                            _MiniStat(
                              titulo: 'Ventas registradas',
                              valor: '${datos.general.cantidadVentas}',
                              icono: Icons.shopping_bag_rounded,
                              color: adminAmbar,
                            ),
                            _MiniStat(
                              titulo: 'Rentas registradas',
                              valor: '${datos.general.cantidadRentas}',
                              icono: Icons.history_rounded,
                              color: adminAzul,
                            ),
                            _MiniStat(
                              titulo: 'Equipos totales',
                              valor: '${datos.general.totalEquipos}',
                              icono: Icons.devices_rounded,
                              color: const Color(0xFF6A1B9A),
                            ),
                            _MiniStat(
                              titulo: 'Disponibles',
                              valor: '${datos.general.equiposDisponibles}',
                              icono: Icons.check_circle_rounded,
                              color: adminVerde,
                            ),
                            _MiniStat(
                              titulo: 'Mantenimiento',
                              valor:
                                  '${datos.general.equiposEnMantenimientoOAveriados}',
                              icono: Icons.build_circle_rounded,
                              color: adminRojo,
                            ),
                            _MiniStat(
                              titulo: 'Pagos pendientes hoy',
                              valor: '${datos.hoy.rentasPendientesPagoHoy}',
                              icono: Icons.pending_actions_rounded,
                              color: const Color(0xFFE65100),
                            ),
                            _MiniStat(
                              titulo: 'Ingresos por rentas',
                              valor: formatearMoneda(
                                datos.general.totalIngresosRentas,
                              ),
                              icono: Icons.payments_rounded,
                              color: adminAmbar,
                            ),
                          ];

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final item in items)
                                SizedBox(width: ancho, child: item),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _EncabezadoSeccion(
                      titulo: 'Rendimiento Semanal',
                      subtitulo: 'Últimos 7 días',
                    ),
                    const SizedBox(height: 14),
                    _GraficaSemanal(semana: datos.semana),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  const _EncabezadoSeccion({required this.titulo, required this.subtitulo});

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: adminMarron,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitulo,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficaSemanal extends StatelessWidget {
  const _GraficaSemanal({required this.semana});

  final List<ResumenDiarioAdmin> semana;

  @override
  Widget build(BuildContext context) {
    if (semana.isEmpty) {
      return const ReporteSectionCard(
        titulo: 'Sin datos semanales',
        icono: Icons.bar_chart_rounded,
        child: Text(
          'No se pudo cargar el rendimiento de los últimos días.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final maximo = semana.fold<double>(
      0,
      (maximo, dia) => dia.totalDia > maximo ? dia.totalDia : maximo,
    );
    final totalSemana = semana.fold<double>(
      0,
      (total, dia) => total + dia.totalDia,
    );
    final hoy = DateTime.now();

    return ReporteSectionCard(
      titulo: 'Ingresos por día',
      icono: Icons.bar_chart_rounded,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final dia in semana)
                  Expanded(
                    child: _BarraDia(
                      dia: dia,
                      maximo: maximo,
                      esHoy:
                          dia.fecha.year == hoy.year &&
                          dia.fecha.month == hoy.month &&
                          dia.fecha.day == hoy.day,
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade200, height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total de la semana',
                  style: TextStyle(
                    color: adminMarron,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatearMoneda(totalSemana),
                style: const TextStyle(
                  color: adminAmbar,
                  fontSize: 18,
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

class _BarraDia extends StatelessWidget {
  const _BarraDia({
    required this.dia,
    required this.maximo,
    required this.esHoy,
  });

  final ResumenDiarioAdmin dia;
  final double maximo;
  final bool esHoy;

  @override
  Widget build(BuildContext context) {
    final proporcion = maximo <= 0 ? 0.0 : dia.totalDia / maximo;
    final alto = 18 + (proporcion * 92);
    final color = esHoy ? adminAmbar : const Color(0xFFD7C4AE);

    return Tooltip(
      message: '${formatearFecha(dia.fecha)}\n${formatearMoneda(dia.totalDia)}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            dia.totalDia > 0 ? '\$${dia.totalDia.toStringAsFixed(0)}' : '',
            style: TextStyle(
              fontSize: 8,
              color: esHoy ? adminAmbar : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 26,
            height: alto,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: esHoy
                    ? const [adminAmbar, Color(0xFFE65100)]
                    : [color, color.withValues(alpha: 0.65)],
              ),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            diaCorto(dia.fecha),
            style: TextStyle(
              fontSize: 10,
              color: esHoy ? adminAmbar : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
