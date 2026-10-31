import 'package:flutter/material.dart';
import 'historial_revisiones_screen.dart';
import 'inspeccion_screen.dart';
import 'perfil_screen.dart';
import '../../models/equipo.dart';
import '../../models/pendiente_revision.dart';
import '../../services/auth_service.dart';
import '../../services/equipo_service.dart';
import '../../services/revision_service.dart';
import '../../utils/equipo_filtros.dart';
import '../../widgets/tarjeta_equipo.dart';

class DashboardAsistente extends StatefulWidget {
  const DashboardAsistente({super.key});

  @override
  State<DashboardAsistente> createState() => _DashboardAsistenteState();
}

class _DashboardAsistenteState extends State<DashboardAsistente> {
  int _pantallaActiva = 0;
  late Future<_DashboardData> _dashboardFuture;
  final TextEditingController _buscadorController = TextEditingController();
  String _busqueda = '';
  Set<FiltroEquipo> _filtrosSeleccionados = <FiltroEquipo>{};

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _cargarDashboard();
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  Future<_DashboardData> _cargarDashboard() async {
    final resultados = await Future.wait<Object>([
      EquipoService.instance.getEquipos(offset: 0, limit: 200),
      _cargarPendientesRevision(),
    ]);

    return _DashboardData(
      equipos: resultados[0] as List<Equipo>,
      pendientes: resultados[1] as Map<int, PendienteRevision>,
    );
  }

  Future<Map<int, PendienteRevision>> _cargarPendientesRevision() async {
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

  void _actualizarBusqueda(String value) {
    setState(() => _busqueda = value);
  }

  void _limpiarBusquedaYFiltros() {
    _buscadorController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _busqueda = '';
      _filtrosSeleccionados = <FiltroEquipo>{};
    });
  }

  Future<void> _abrirFiltros() async {
    final seleccionados = await showModalBottomSheet<Set<FiltroEquipo>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _FiltrosEquipoSheet(seleccionadosIniciales: _filtrosSeleccionados),
    );

    if (seleccionados == null || !mounted) return;
    setState(() => _filtrosSeleccionados = seleccionados);
  }

  Widget _buildSinResultados() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.black38),
          const SizedBox(height: 10),
          const Text(
            'No hay equipos que coincidan con la búsqueda o los filtros.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _limpiarBusquedaYFiltros,
            child: const Text('Limpiar búsqueda y filtros'),
          ),
        ],
      ),
    );
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
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                AuthService.instance.nombreMostrado,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                AuthService.instance.etiquetaRol,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
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
                  IconButton(
                    onPressed: _recargarEquipos,
                    icon: const Icon(Icons.refresh),
                    color: Colors.black,
                    tooltip: 'Actualizar',
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
                  child: TextField(
                    controller: _buscadorController,
                    onChanged: _actualizarBusqueda,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar equipo...',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: _busqueda.trim().isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: () {
                                _buscadorController.clear();
                                _actualizarBusqueda('');
                              },
                              icon: const Icon(Icons.close, size: 18),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _abrirFiltros,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _filtrosSeleccionados.isEmpty
                        ? Colors.white
                        : const Color(0xFFFFF1DF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _filtrosSeleccionados.isEmpty
                            ? 'Filtrar'
                            : 'Filtrar (${_filtrosSeleccionados.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.tune, size: 20),
                    ],
                  ),
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
                final todosLosEquipos = data?.equipos ?? const <Equipo>[];
                final pendientes =
                    data?.pendientes ?? const <int, PendienteRevision>{};
                if (todosLosEquipos.isEmpty) {
                  return const Center(
                    child: Text('No hay equipos registrados.'),
                  );
                }

                final equipos = filtrarEquipos(
                  todosLosEquipos,
                  busqueda: _busqueda,
                  filtros: _filtrosSeleccionados,
                  estaPendienteRevision: (equipo) {
                    final equipoId = equipo.equipoId;
                    return equipoId != null && pendientes.containsKey(equipoId);
                  },
                );

                if (equipos.isEmpty) {
                  return _buildSinResultados();
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
                    final pendiente = equipo.equipoId == null
                        ? null
                        : pendientes[equipo.equipoId];
                    return TarjetaEquipo(
                      equipo: equipo,
                      pendienteRevision: pendiente != null,
                      clienteNombre: pendiente?.clienteNombre,
                      onTap: () async {
                        final equipoId = equipo.equipoId;
                        if (equipoId == null) return;
                        if (pendiente == null) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Este equipo no tiene una renta pendiente '
                                  'de revisión.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          return;
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InspeccionScreen(
                              equipoId: equipoId,
                              detalleRentaId: pendiente.detalleRentaId,
                              nombreEquipo: equipo.nombre,
                              tipoEquipo: equipo.tipo.value,
                              estadoActual: equipo.estado,
                              clienteNombre: pendiente.clienteNombre,
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
  final Map<int, PendienteRevision> pendientes;
}

class _FiltrosEquipoSheet extends StatefulWidget {
  const _FiltrosEquipoSheet({required this.seleccionadosIniciales});

  final Set<FiltroEquipo> seleccionadosIniciales;

  @override
  State<_FiltrosEquipoSheet> createState() => _FiltrosEquipoSheetState();
}

class _FiltrosEquipoSheetState extends State<_FiltrosEquipoSheet> {
  late Set<FiltroEquipo> _seleccionados;

  @override
  void initState() {
    super.initState();
    _seleccionados = Set<FiltroEquipo>.of(widget.seleccionadosIniciales);
  }

  void _alternar(FiltroEquipo filtro) {
    setState(() {
      if (!_seleccionados.remove(filtro)) {
        _seleccionados.add(filtro);
      }
    });
  }

  IconData _icono(FiltroEquipo filtro) {
    return switch (filtro) {
      FiltroEquipo.disponible => Icons.check_circle_outline,
      FiltroEquipo.danios => Icons.warning_amber_rounded,
      FiltroEquipo.mantenimiento => Icons.build_circle_outlined,
      FiltroEquipo.pendienteRevision => Icons.assignment_late_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune, color: Color(0xFFB06B05)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar equipos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2C1E16),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Puedes seleccionar más de una categoría.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filtro in FiltroEquipo.values)
                  FilterChip(
                    selected: _seleccionados.contains(filtro),
                    onSelected: (_) => _alternar(filtro),
                    avatar: Icon(
                      _icono(filtro),
                      size: 18,
                      color: _seleccionados.contains(filtro)
                          ? const Color(0xFFB06B05)
                          : Colors.black54,
                    ),
                    label: Text(filtro.etiqueta),
                    labelStyle: TextStyle(
                      color: _seleccionados.contains(filtro)
                          ? const Color(0xFFB06B05)
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: const Color(0xFFFFF1DF),
                    checkmarkColor: const Color(0xFFB06B05),
                    side: BorderSide(
                      color: _seleccionados.contains(filtro)
                          ? const Color(0xFFB06B05)
                          : Colors.black12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(_seleccionados.clear),
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB06B05),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, _seleccionados),
                    child: const Text(
                      'Aplicar filtros',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
