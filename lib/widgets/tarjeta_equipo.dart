import 'package:flutter/material.dart';

class TarjetaEquipo extends StatelessWidget {
  final Map<String, dynamic> equipo;
  final VoidCallback onTap;

  const TarjetaEquipo({super.key, required this.equipo, required this.onTap});

  IconData _obtenerIcono() {
    final estado = equipo['estado'].toString().toLowerCase();
    if (estado.contains('mantenimiento')) return Icons.build_circle;
    if (estado.contains('revisión')) return Icons.warning_amber_rounded;
    return equipo['tipo'] == 'PC'
        ? Icons.desktop_windows
        : Icons.sports_esports;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: equipo['color'], width: 6)),
          boxShadow: [
            BoxShadow(
              color: equipo['color'].withOpacity(0.15),
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
              equipo['id'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: equipo['color'].withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                equipo['estado'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: equipo['color'],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // NUEVO: Muestra el usuario si existe
            if (equipo['usuario'] != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    equipo['usuario'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
