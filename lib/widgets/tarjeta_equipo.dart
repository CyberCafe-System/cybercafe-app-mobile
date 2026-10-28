import 'package:flutter/material.dart';
import '../models/equipo.dart';

class TarjetaEquipo extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;
  final bool pendienteRevision;
  final String? clienteNombre;

  const TarjetaEquipo({
    super.key,
    required this.equipo,
    required this.onTap,
    this.pendienteRevision = false,
    this.clienteNombre,
  });

  Color get _color {
    if (pendienteRevision) {
      return const Color(0xFF1E88E5);
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

  @override
  Widget build(BuildContext context) {
    final cliente = clienteNombre?.trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: _color, width: 6)),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.15),
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
                        color: _color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pendienteRevision
                            ? 'Pendiente de revisión'
                            : equipo.estado.value,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (pendienteRevision) ...[
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          cliente != null && cliente.isNotEmpty
                              ? 'Cliente: $cliente'
                              : 'Cliente no disponible',
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
            );
          },
        ),
      ),
    );
  }
}
