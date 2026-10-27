import 'package:flutter/material.dart';
import '../../models/componente.dart';
import '../../models/equipo.dart';
import '../../services/auth_service.dart';
import '../../services/componente_service.dart';
import '../../services/revision_service.dart';

class InspeccionScreen extends StatefulWidget {
  final int equipoId;
  final String nombreEquipo;
  final String tipoEquipo;
  final EstadoEquipo estadoActual;

  const InspeccionScreen({
    super.key,
    required this.equipoId,
    required this.nombreEquipo,
    required this.tipoEquipo,
    required this.estadoActual,
  });

  @override
  State<InspeccionScreen> createState() => _InspeccionScreenState();
}

class _InspeccionScreenState extends State<InspeccionScreen> {
  late Future<List<Componente>> _componentesFuture;
  final Map<int, EstadoComponente> _estadosLocales = {};
  final Set<int> _actualizando = {};
  final _observacionController = TextEditingController();
  late EstadoEquipo _estadoEquipoSeleccionado;
  bool _guardandoRevision = false;

  @override
  void initState() {
    super.initState();
    _estadoEquipoSeleccionado = widget.estadoActual;
    _componentesFuture = _cargarComponentes();
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<List<Componente>> _cargarComponentes() {
    return ComponenteService.instance.getComponentesPorEquipo(widget.equipoId);
  }

  void _recargarComponentes() {
    setState(() {
      _estadosLocales.clear();
      _actualizando.clear();
      _componentesFuture = _cargarComponentes();
    });
  }

  Future<void> _cambiarEstado(
    Componente componente,
    EstadoComponente nuevoEstado,
  ) async {
    final componenteId = componente.componenteId;
    if (componenteId == null || _actualizando.contains(componenteId)) return;

    final estadoAnterior = _estadosLocales[componenteId] ?? componente.estado;

    setState(() {
      _estadosLocales[componenteId] = nuevoEstado;
      _actualizando.add(componenteId);
    });

    try {
      final actualizado = await ComponenteService.instance.actualizarEstado(
        componenteId,
        nuevoEstado,
      );
      if (!mounted) return;
      setState(() {
        _estadosLocales[componenteId] = actualizado.estado;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _estadosLocales[componenteId] = estadoAnterior;
      });
      _mostrarError(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _estadosLocales[componenteId] = estadoAnterior;
      });
      _mostrarError('No se pudo actualizar el estado del componente.');
    } finally {
      if (mounted) {
        setState(() {
          _actualizando.remove(componenteId);
        });
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _finalizarRevision() async {
    if (_guardandoRevision) return;

    FocusScope.of(context).unfocus();
    setState(() => _guardandoRevision = true);

    try {
      final componentes = await _componentesFuture;
      final estadoSeleccionado = _estadoEquipoSeleccionado;
      var todosDisponibles = true;

      for (final componente in componentes) {
        final componenteId = componente.componenteId;
        final estado = componenteId == null
            ? componente.estado
            : _estadosLocales[componenteId] ?? componente.estado;

        if (estado != EstadoComponente.disponible) {
          todosDisponibles = false;
        }
      }

      if (estadoSeleccionado == EstadoEquipo.disponible && !todosDisponibles) {
        _mostrarError(
          'No puedes dejar el equipo Disponible mientras tenga componentes '
          'con daños.',
        );
        return;
      }

      final inspeccionPasada = estadoSeleccionado == EstadoEquipo.disponible;

      await RevisionService.instance.crearRevision(
        equipoId: widget.equipoId,
        inspeccionPasada: inspeccionPasada,
        observaciones: _observacionController.text.trim(),
        estadoSiDaniado: inspeccionPasada ? null : estadoSeleccionado,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisión y observación registradas.'),
          backgroundColor: Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      _mostrarError(e.message);
    } catch (_) {
      if (!mounted) return;
      _mostrarError('No se pudo registrar la revisión.');
    } finally {
      if (mounted) {
        setState(() => _guardandoRevision = false);
      }
    }
  }

  Color _colorEstado(EstadoComponente estado) {
    switch (estado) {
      case EstadoComponente.disponible:
        return const Color(0xFF43A047);
      case EstadoComponente.daniosMenores:
        return const Color(0xFFF9A825);
      case EstadoComponente.requiereReemplazo:
        return const Color(0xFFD32F2F);
    }
  }

  Color _colorEstadoEquipo(EstadoEquipo estado) {
    switch (estado) {
      case EstadoEquipo.disponible:
        return const Color(0xFF43A047);
      case EstadoEquipo.daniosMenores:
        return const Color(0xFFF9A825);
      case EstadoEquipo.defectuoso:
        return const Color(0xFFD32F2F);
      case EstadoEquipo.enMantenimiento:
        return const Color(0xFF757575);
    }
  }

  IconData _iconoComponente(TipoComponente tipo) {
    switch (tipo) {
      case TipoComponente.mouse:
        return Icons.mouse;
      case TipoComponente.teclado:
        return Icons.keyboard;
      case TipoComponente.monitor:
        return Icons.monitor;
      case TipoComponente.control:
        return Icons.videogame_asset;
    }
  }

  void _mostrarModalReporte(BuildContext context, String componente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABECERA DEL MODAL CON LA 'X'
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Reportar $componente',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe la falla con detalle...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'ENVIAR A MANTENIMIENTO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estadoColor = _colorEstadoEquipo(_estadoEquipoSeleccionado);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB06B05),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              widget.tipoEquipo == 'PC'
                  ? Icons.desktop_windows
                  : Icons.sports_esports,
              size: 60,
              color: const Color(0xFF2C1E16),
            ),
            Text(
              widget.nombreEquipo,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C1E16),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Checklist de Componentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1E16),
                ),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: FutureBuilder<List<Componente>>(
                future: _componentesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB06B05),
                      ),
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
                            onPressed: _recargarComponentes,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final componentes = snapshot.data ?? const <Componente>[];
                  if (componentes.isEmpty) {
                    return const Center(
                      child: Text(
                        'Este equipo no tiene componentes registrados.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: componentes.length,
                    itemBuilder: (context, index) {
                      final componente = componentes[index];
                      final componenteId = componente.componenteId;
                      final estado = componenteId == null
                          ? componente.estado
                          : _estadosLocales[componenteId] ?? componente.estado;
                      final actualizando =
                          componenteId != null &&
                          _actualizando.contains(componenteId);
                      final color = _colorEstado(estado);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            left: BorderSide(color: color, width: 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F6F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Icon(
                                    _iconoComponente(componente.tipo),
                                    size: 26,
                                    color: const Color(0xFF2C1E16),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        componente.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        componente.descripcion ??
                                            componente.tipo.value,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _mostrarModalReporte(
                                    context,
                                    componente.nombre,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.redAccent.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.priority_high_rounded,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<EstadoComponente>(
                                  value: estado,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  icon: actualizando
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFB06B05),
                                          ),
                                        )
                                      : Icon(
                                          Icons.arrow_drop_down,
                                          color: color,
                                        ),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  onChanged:
                                      actualizando || componenteId == null
                                      ? null
                                      : (nuevoEstado) {
                                          if (nuevoEstado == null ||
                                              nuevoEstado == estado) {
                                            return;
                                          }
                                          _cambiarEstado(
                                            componente,
                                            nuevoEstado,
                                          );
                                        },
                                  items: EstadoComponente.values.map((item) {
                                    final itemColor = _colorEstado(item);
                                    return DropdownMenuItem<EstadoComponente>(
                                      value: item,
                                      child: Text(
                                        item.value,
                                        style: TextStyle(
                                          color: itemColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Estado del equipo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1E16),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: estadoColor.withOpacity(0.35)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<EstadoEquipo>(
                  value: _estadoEquipoSeleccionado,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_drop_down, color: estadoColor),
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: _guardandoRevision
                      ? null
                      : (nuevoEstado) {
                          if (nuevoEstado == null) return;
                          setState(() {
                            _estadoEquipoSeleccionado = nuevoEstado;
                          });
                        },
                  items: EstadoEquipo.values.map((estado) {
                    final itemColor = _colorEstadoEquipo(estado);
                    return DropdownMenuItem<EstadoEquipo>(
                      value: estado,
                      child: Text(
                        estado.value,
                        style: TextStyle(
                          color: itemColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Si el estado no es Disponible, la revisión se registrará como '
              'no aprobada.',
              style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _observacionController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'Observaciones del equipo',
                hintText: 'Agrega una observación para esta revisión...',
                labelStyle: const TextStyle(color: Color(0xFF2C1E16)),
                prefixIcon: const Icon(Icons.notes, color: Color(0xFF2C1E16)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFFB06B05),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _guardandoRevision ? null : _finalizarRevision,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB06B05), Color(0xFF2C1E16)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C1E16).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _guardandoRevision
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'FINALIZAR REVISIÓN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
