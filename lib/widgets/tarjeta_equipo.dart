import 'package:flutter/material.dart';
import '../models/equipo.dart';

class TarjetaEquipo extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;

  const TarjetaEquipo({super.key, required this.equipo, required this.onTap});

  Color get _color {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_obtenerIcono(), size: 38, color: const Color(0xFF2C1E16)),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                equipo.estado.value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
