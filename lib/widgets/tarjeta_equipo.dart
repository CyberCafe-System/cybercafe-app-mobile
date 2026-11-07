import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/renta_activa.dart';
import '../utils/renta_formatters.dart';

class TarjetaEquipo extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;
  final bool pendienteRevision;
  final String? clienteNombre;
  final RentaActivaEquipo? rentaActiva;
  final DateTime ahora;

  const TarjetaEquipo({
    super.key,
    required this.equipo,
    required this.onTap,
    required this.ahora,
    this.pendienteRevision = false,
    this.clienteNombre,
    this.rentaActiva,
  });

  Color _color(bool enUso) {
    if (pendienteRevision) {
      return const Color(0xFF1E88E5);
    }
    if (rentaActiva != null && rentaActiva!.esTiempoTerminado) {
      return const Color(0xFFD32F2F);
    }
    if (enUso) {
      return const Color(0xFFB06B05);
    }

    switch (equipo.estado) {
      case EstadoEquipo.disponible:
        return const Color(0xFF66BB6A);
      case EstadoEquipo.daniosMenores:
        return const Color(0xFFF9A825);
      case EstadoEquipo.defectuoso:
        return const Color(0xFFD32F2F);
      case EstadoEquipo.enMantenimiento:
        return const Color(0xFF757575);
    }
  }

  IconData _obtenerIcono() {
    if (pendienteRevision) {
      return Icons.assignment_late;
    }

    switch (equipo.estado) {
      case EstadoEquipo.enMantenimiento:
        return Icons.build_circle;
      case EstadoEquipo.daniosMenores:
      case EstadoEquipo.defectuoso:
        return Icons.warning_amber_rounded;
      case EstadoEquipo.disponible:
        return equipo.tipo == TipoEquipo.pc
            ? Icons.desktop_windows
            : Icons.sports_esports;
    }
  }

  Color _colorProgreso(RentaActivaEquipo renta) {
    if (renta.restanteEn(ahora) <= Duration.zero) {
      return const Color(0xFFD32F2F);
    }
    if (renta.progresoEn(ahora) >= 0.8) {
      return const Color(0xFFF9A825);
    }
    return const Color(0xFFB06B05);
  }

  String _clienteMostrado(String? nombre) {
    final cliente = nombre?.trim();
    if (cliente == null || cliente.isEmpty) return 'Cliente no disponible';
    return 'Cliente: $cliente';
  }

  @override
  Widget build(BuildContext context) {
    final renta = pendienteRevision ? null : rentaActiva;
    final enUso = renta != null;
    final esTerminada = renta != null && renta.esTiempoTerminado;
    final color = _color(enUso);
    final estadoEtiqueta = pendienteRevision
        ? 'Pendiente de revisión'
        : esTerminada
        ? 'Tiempo terminado'
        : enUso
        ? 'En uso'
        : equipo.estado.value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: color, width: 6)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _obtenerIcono(),
                        size: 38,
                        color: const Color(0xFF2C1E16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        equipo.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estadoEtiqueta,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (enUso) ...[
                        const SizedBox(height: 5),
                        Text(
                          _clienteMostrado(renta.clienteNombre),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatearTiempoRestante(renta.restanteEn(ahora)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: _colorProgreso(renta),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          formatearHoraFinalizacion(renta.horaFinalizacion),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: renta.progresoEn(ahora),
                            minHeight: 5,
                            backgroundColor: color.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _colorProgreso(renta),
                            ),
                          ),
                        ),
                      ],
                      if (pendienteRevision) ...[
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            _clienteMostrado(clienteNombre),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Toca para inspeccionar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
