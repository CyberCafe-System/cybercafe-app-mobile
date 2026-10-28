import 'package:flutter/material.dart';

import '../../models/equipo.dart';
import '../../models/revision_historial.dart';
import '../../services/auth_service.dart';
import '../../services/revision_service.dart';

class HistorialRevisionesScreen extends StatefulWidget {
  const HistorialRevisionesScreen({super.key});

  @override
  State<HistorialRevisionesScreen> createState() =>
      _HistorialRevisionesScreenState();
}

class _HistorialRevisionesScreenState extends State<HistorialRevisionesScreen> {
  late Future<List<RevisionHistorialItem>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _historialFuture = _cargarHistorial();
  }

  Future<List<RevisionHistorialItem>> _cargarHistorial() {
    return RevisionService.instance.getHistorialRevisiones();
  }

  void _recargar() {
    setState(() {
      _historialFuture = _cargarHistorial();
    });
  }

  Future<void> _refrescar() async {
    _recargar();
    try {
      await _historialFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<RevisionHistorialItem>>(
              future: _historialFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB06B05)),
                  );
                }

                if (snapshot.hasError) {
                  return _buildError(snapshot.error);
                }

                final historial =
                    snapshot.data ?? const <RevisionHistorialItem>[];
                if (historial.isEmpty) {
                  return _buildVacio();
                }

                return RefreshIndicator(
                  color: const Color(0xFFB06B05),
                  onRefresh: _refrescar,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: historial.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      return _buildTarjeta(historial[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFB06B05),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black,
                child: Icon(Icons.history, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Revisiones de equipos',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: _recargar,
                icon: const Icon(Icons.refresh, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    final mensaje = error is AuthException
        ? error.message
        : 'No se pudo cargar el historial de revisiones.';
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
            TextButton(onPressed: _recargar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return RefreshIndicator(
      color: const Color(0xFFB06B05),
      onRefresh: _refrescar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: const [
          SizedBox(height: 130),
          Icon(Icons.history_toggle_off, size: 64, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            'No hay revisiones registradas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1E16),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Las inspecciones que se finalicen aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjeta(RevisionHistorialItem item) {
    final aprobada = item.revision.inspeccionPasada;
    final colorEstado = aprobada
        ? const Color(0xFF43A047)
        : const Color(0xFFF9A825);
    final observaciones = item.revision.observaciones.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: colorEstado, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB06B05).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconoEquipo(item.equipoTipo),
                  color: const Color(0xFFB06B05),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.equipoNombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1E16),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.equipoTipo?.value ?? 'Equipo',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildEstadoBadge(aprobada),
            ],
          ),
          const SizedBox(height: 14),
          _buildDato(
            Icons.calendar_today_outlined,
            _formatearFecha(item.revision.fechaRevision),
          ),
          const SizedBox(height: 8),
          _buildDato(
            Icons.person_outline,
            'Registrada por ${_textoUsuario(item)}',
          ),
          const SizedBox(height: 8),
          _buildDato(Icons.group_outlined, _textoCliente(item)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if (observaciones.isEmpty)
            const Text(
              'Sin observaciones.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            const Text(
              'Observaciones',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              observaciones,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF2C1E16)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(bool aprobada) {
    final color = aprobada ? const Color(0xFF43A047) : const Color(0xFFF9A825);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        aprobada ? 'APROBADA' : 'NO APROBADA',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDato(IconData icono, String texto) {
    return Row(
      children: [
        Icon(icono, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconoEquipo(TipoEquipo? tipo) {
    switch (tipo) {
      case TipoEquipo.pc:
        return Icons.desktop_windows;
      case TipoEquipo.consola:
        return Icons.sports_esports;
      case null:
        return Icons.devices_other;
    }
  }

  String _textoCliente(RevisionHistorialItem item) {
    final nombre = item.clienteNombre;
    if (nombre != null && nombre.trim().isNotEmpty) {
      return 'Cliente: $nombre';
    }
    return 'Cliente no disponible';
  }

  String _textoUsuario(RevisionHistorialItem item) {
    final usuarioId = item.revision.usuarioId;
    final nombre = item.usuarioNombre;
    if (nombre != null && nombre.trim().isNotEmpty) {
      return usuarioId == AuthService.instance.usuarioId
          ? '$nombre (tú)'
          : nombre;
    }
    if (usuarioId == null) {
      return 'Usuario no disponible';
    }
    return 'Inspector #$usuarioId';
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';

    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia ${meses[local.month - 1]} ${local.year} · $hora:$minuto';
  }
}
