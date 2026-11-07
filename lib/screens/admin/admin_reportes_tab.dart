import 'package:flutter/material.dart';

import '../../models/reporte_admin.dart';
import '../../services/reporte_admin_service.dart';
import 'reportes/reporte_inventario_tab.dart';
import 'reportes/reporte_rentas_tab.dart';
import 'reportes/reporte_ventas_tab.dart';
import 'reportes/reporte_widgets.dart';

class AdminReportesTab extends StatefulWidget {
  const AdminReportesTab({super.key});

  @override
  State<AdminReportesTab> createState() => _AdminReportesTabState();
}

class _AdminReportesTabState extends State<AdminReportesTab> {
  late Future<ReporteAdminData> _future;

  @override
  void initState() {
    super.initState();
    _future = ReporteAdminService.instance.cargarReportes();
  }

  Future<void> _recargar() async {
    final future = ReporteAdminService.instance.cargarReportes(
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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: adminFondo,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: adminAmbar,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: adminMarron.withValues(alpha: 0.6),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Ventas'),
                        Tab(text: 'Rentas'),
                        Tab(text: 'Inventario'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 48, 27, 10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: adminAmbar.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, color: adminAmbar),
                SizedBox(width: 10),
                Text(
                  'SECCIÓN DE REPORTES',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 254, 254, 254),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<ReporteAdminData>(
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

                final data = snapshot.data!;
                return TabBarView(
                  children: [
                    ReporteVentasTab(ventas: data.ventas, onRefresh: _recargar),
                    ReporteRentasTab(rentas: data.rentas, onRefresh: _recargar),
                    ReporteInventarioTab(
                      productos: data.productos,
                      onRefresh: _recargar,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
