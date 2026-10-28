import 'package:flutter/material.dart';
import 'historial_revisiones_screen.dart';
import 'inspeccion_screen.dart';
import 'perfil_screen.dart';
import '../../models/equipo.dart';
import '../../services/auth_service.dart';
import '../../services/equipo_service.dart';
import '../../services/revision_service.dart';
import '../../widgets/tarjeta_equipo.dart';

class DashboardAsistente extends StatefulWidget {
  const DashboardAsistente({super.key});

  @override
  State<DashboardAsistente> createState() => _DashboardAsistenteState();
}

class _DashboardAsistenteState extends State<DashboardAsistente> {
  int _pantallaActiva = 0;
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _cargarDashboard();
  }

  Future<_DashboardData> _cargarDashboard() async {
    final resultados = await Future.wait<Object>([
      EquipoService.instance.getEquipos(offset: 0, limit: 50),
      _cargarPendientesRevision(),
    ]);

    return _DashboardData(
      equipos: resultados[0] as List<Equipo>,
      pendientes: resultados[1] as Map<int, String?>,
    );
  }

  Future<Map<int, String?>> _cargarPendientesRevision() async {
    try {
      return await RevisionService.instance.getEquiposConRevisionPendiente();
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  void _recargarEquipos() {
    setState(() {
      _dashboardFuture = _cargarDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),

      body: switch (_pantallaActiva) {
        1 => const HistorialRevisionesScreen(),
        2 => PerfilScreen(onVolver: () => setState(() => _pantallaActiva = 0)),
        _ => _buildDashboardView(),
      },

      bottomNavigationBar: Container(
        color: const Color(0xFF2C1E16),
        child: SafeArea(
          child: Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF2C1E16),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavIcon(Icons.home, "Inicio", 0),
                _buildBottomNavIcon(Icons.history, "Historial", 1),
                _buildBottomNavIcon(Icons.person, "Perfil", 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB06B05),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Edwin Cruz',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Image.asset('assets/img/logo_login.png', height: 40),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar equipo...',
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Text(
                      'Filtrar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.tune, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FutureBuilder<_DashboardData>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB06B05)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 48,
                          color: Colors.black38,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _recargarEquipos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data;
                final equipos = data?.equipos ?? const <Equipo>[];
                final pendientes = data?.pendientes ?? const <int, String?>{};
                if (equipos.isEmpty) {
                  return const Center(
                    child: Text('No hay equipos registrados.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    final equipo = equipos[index];
                    return TarjetaEquipo(
                      equipo: equipo,
                      pendienteRevision:
                          equipo.equipoId != null &&
                          pendientes.containsKey(equipo.equipoId),
                      clienteNombre: equipo.equipoId == null
                          ? null
                          : pendientes[equipo.equipoId],
                      onTap: () async {
                        final equipoId = equipo.equipoId;
                        if (equipoId == null) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InspeccionScreen(
                              equipoId: equipoId,
                              nombreEquipo: equipo.nombre,
                              tipoEquipo: equipo.tipo.value,
                              estadoActual: equipo.estado,
                            ),
                          ),
                        );
                        if (mounted) {
                          _recargarEquipos();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, int index) {
    bool isActive = _pantallaActiva == index;
    return GestureDetector(
      onTap: () => setState(() => _pantallaActiva = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFB06B05) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFFB06B05),
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFFB06B05),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({required this.equipos, required this.pendientes});

  final List<Equipo> equipos;
  final Map<int, String?> pendientes;
}
