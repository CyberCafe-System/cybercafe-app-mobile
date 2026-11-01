import 'package:flutter/material.dart';

import '../../models/componente.dart';
import '../../services/auth_service.dart';
import '../../services/componente_service.dart';
import '../../utils/incidencias_componente.dart';
import '../../widgets/tarjeta_incidencia_componente.dart';

class HistorialComponentesTab extends StatefulWidget {
  const HistorialComponentesTab({super.key});

  @override
  State<HistorialComponentesTab> createState() =>
      HistorialComponentesTabState();
}

class HistorialComponentesTabState extends State<HistorialComponentesTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Componente>> _componentesFuture;
  final TextEditingController _busqueda = TextEditingController();
  String _consulta = '';
  FiltroIncidenciasComponente _filtro = FiltroIncidenciasComponente.todos;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _componentesFuture = _cargarComponentes();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<List<Componente>> _cargarComponentes() {
    return ComponenteService.instance.getComponentes();
  }

  void recargar() {
    setState(() {
      _componentesFuture = _cargarComponentes();
    });
  }

  Future<void> _refrescar() async {
    recargar();
    try {
      await _componentesFuture;
    } catch (_) {}
  }

  void _limpiarBusquedaYFiltro() {
    _busqueda.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _consulta = '';
      _filtro = FiltroIncidenciasComponente.todos;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: TextField(
              controller: _busqueda,
              onChanged: (valor) => setState(() => _consulta = valor),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar componente...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: _consulta.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          _busqueda.clear();
                          setState(() => _consulta = '');
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 10),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final filtro in FiltroIncidenciasComponente.values)
                  ChoiceChip(
                    label: Text(filtro.etiqueta),
                    selected: _filtro == filtro,
                    onSelected: (_) => setState(() => _filtro = filtro),
                    showCheckmark: false,
                    selectedColor: const Color(0xFFFFF1DF),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _filtro == filtro
                          ? const Color(0xFFB06B05)
                          : Colors.transparent,
                    ),
                    labelStyle: TextStyle(
                      color: _filtro == filtro
                          ? const Color(0xFF2C1E16)
                          : Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Componente>>(
            future: _componentesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB06B05)),
                );
              }

              if (snapshot.hasError) {
                return _buildError(snapshot.error);
              }

              final componentes = snapshot.data ?? const <Componente>[];
              if (componentes.isEmpty) {
                return _buildVacio(
                  titulo: 'No hay componentes registrados.',
                  mensaje: 'Los componentes y sus incidencias aparecerán aquí.',
                );
              }

              final filtrados = filtrarComponentesIncidencias(
                componentes,
                consulta: _consulta,
                filtro: _filtro,
              );
              if (filtrados.isEmpty) {
                return _buildVacio(
                  titulo: 'Sin resultados.',
                  mensaje:
                      'No hay componentes que coincidan con la búsqueda o el filtro.',
                  mostrarLimpiar: true,
                );
              }

              return RefreshIndicator(
                color: const Color(0xFFB06B05),
                onRefresh: _refrescar,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return TarjetaIncidenciaComponente(
                      componente: filtrados[index],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object? error) {
    final mensaje = error is AuthException
        ? error.message
        : 'No se pudieron cargar las incidencias de los componentes.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.black38),
            const SizedBox(height: 10),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: recargar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildVacio({
    required String titulo,
    required String mensaje,
    bool mostrarLimpiar = false,
  }) {
    return RefreshIndicator(
      color: const Color(0xFFB06B05),
      onRefresh: _refrescar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          const SizedBox(height: 90),
          const Icon(Icons.history_toggle_off, size: 64, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1E16),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          if (mostrarLimpiar) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _limpiarBusquedaYFiltro,
                child: const Text('Limpiar búsqueda y filtro'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
