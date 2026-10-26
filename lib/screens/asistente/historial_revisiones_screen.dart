import 'package:flutter/material.dart';

class HistorialRevisionesScreen extends StatelessWidget {
  final String componente;
  final String equipo;

  const HistorialRevisionesScreen({
    super.key,
    required this.componente,
    required this.equipo,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> historial = [
      {
        "fecha": "26 Oct 2026 - 10:15 AM",
        "estado": "ok",
        "nota": "Revisión de rutina, funcionando correctamente.",
        "usuario": "Edwin Cruz",
      },
      {
        "fecha": "22 Oct 2026 - 04:30 PM",
        "estado": "reparacion",
        "nota": "Se limpiaron los switches mecánicos, teclas pegajosas.",
        "usuario": "Mantenimiento IT",
      },
      {
        "fecha": "20 Oct 2026 - 08:00 PM",
        "estado": "reporte",
        "nota": "Cliente reportó que la barra espaciadora no responde.",
        "usuario": "Edwin Cruz",
      },
      {
        "fecha": "15 Oct 2026 - 11:20 AM",
        "estado": "ok",
        "nota": "Asignado como componente nuevo al equipo.",
        "usuario": "Admin",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB06B05),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de $componente',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Equipo: $equipo',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: historial.length,
        itemBuilder: (context, index) {
          final item = historial[index];

          // Lógica de colores e iconos según el estado
          Color colorEstado = Colors.green;
          IconData iconoEstado = Icons.check_circle;
          String textoEstado = "ÓPTIMO";

          if (item['estado'] == 'reporte') {
            colorEstado = Colors.redAccent;
            iconoEstado = Icons.warning_rounded;
            textoEstado = "REPORTE FALLA";
          } else if (item['estado'] == 'reparacion') {
            colorEstado = const Color(0xFFB06B05); // Cobre
            iconoEstado = Icons.build_circle;
            textoEstado = "MANTENIMIENTO";
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Línea de tiempo visual
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconoEstado, color: colorEstado, size: 24),
                  ),
                  if (index != historial.length - 1)
                    Container(
                      width: 2,
                      height: 80,
                      color: Colors.grey.shade300,
                    ), // Línea conectora
                ],
              ),
              const SizedBox(width: 15),
              // Tarjeta de información
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: colorEstado.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['fecha'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              textoEstado,
                              style: TextStyle(
                                fontSize: 9,
                                color: colorEstado,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['nota'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C1E16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item['usuario'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
