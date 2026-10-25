import 'package:flutter/material.dart';

class InspeccionScreen extends StatefulWidget {
  final String equipoId;
  final String tipoEquipo;

  const InspeccionScreen({
    super.key,
    required this.equipoId,
    required this.tipoEquipo,
  });

  @override
  State<InspeccionScreen> createState() => _InspeccionScreenState();
}

class _InspeccionScreenState extends State<InspeccionScreen> {
  late List<Map<String, dynamic>> _componentes;

  @override
  void initState() {
    super.initState();

    if (widget.tipoEquipo == 'Consola') {
      _componentes = [
        {
          "nombre": "Consola",
          "modelo": "PS5 Digital",
          "estado": "ok",
          "icono": Icons.sports_esports,
        },
        {
          "nombre": "Control 1",
          "modelo": "DualSense Blanco",
          "estado": "pendiente",
          "icono": Icons.videogame_asset,
        },
        {
          "nombre": "Control 2",
          "modelo": "DualSense Negro",
          "estado": "ok",
          "icono": Icons.videogame_asset,
        },
        {
          "nombre": "Cable HDMI",
          "modelo": "Alta Velocidad 2m",
          "estado": "ok",
          "icono": Icons.settings_input_hdmi,
        },
      ];
    } else {
      _componentes = [
        {
          "nombre": "Monitor",
          "modelo": "Samsung 24\"",
          "estado": "ok",
          "icono": Icons.monitor,
        },
        {
          "nombre": "Teclado",
          "modelo": "Mecánico Redragon",
          "estado": "pendiente",
          "icono": Icons.keyboard,
        },
        {
          "nombre": "Mouse",
          "modelo": "Logitech G203",
          "estado": "pendiente",
          "icono": Icons.mouse,
        },
        {
          "nombre": "Torre",
          "modelo": "NZXT Cristal",
          "estado": "ok",
          "icono": Icons.dns,
        }, // Icono de Torre cambiado
      ];
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
            // Icono principal dinámico según el equipo
            Icon(
              widget.tipoEquipo == 'PC'
                  ? Icons.desktop_windows
                  : Icons.sports_esports,
              size: 60,
              color: const Color(0xFF2C1E16),
            ),
            Text(
              widget.equipoId,
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
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _componentes.length,
                itemBuilder: (context, index) {
                  final comp = _componentes[index];
                  bool isOk = comp['estado'] == 'ok';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isOk
                              ? Colors.green.withOpacity(0.1)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Icon(
                            comp['icono'],
                            size: 26,
                            color: const Color(0xFF2C1E16),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comp['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                comp['modelo'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => comp['estado'] = 'ok'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isOk
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF66BB6A),
                                            Color(0xFF43A047),
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [Colors.white, Colors.white],
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isOk
                                        ? Colors.transparent
                                        : Colors.grey.shade300,
                                  ),
                                  boxShadow: isOk
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: isOk
                                      ? Colors.white
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () =>
                                  _mostrarModalReporte(context, comp['nombre']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.5),
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
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
                child: const Center(
                  child: Text(
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
