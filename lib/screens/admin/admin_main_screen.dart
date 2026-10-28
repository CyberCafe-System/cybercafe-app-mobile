import 'package:flutter/material.dart';

import '../../services/reporte_admin_service.dart';
import 'admin_home_tab.dart';
import 'admin_reportes_tab.dart';
import 'admin_perfil_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _pantallaActiva = 0;

  @override
  void initState() {
    super.initState();
    ReporteAdminService.instance.limpiarCache();
  }

  final List<Widget> _pantallas = [
    const AdminHomeTab(),
    const AdminReportesTab(),
    const AdminPerfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      resizeToAvoidBottomInset:
          false, // Evita errores visuales si se abre el teclado
      body: _pantallas[_pantallaActiva],

      // Envolvemos el menú en un SafeArea con fondo oscuro
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
                _buildBottomNavIcon(Icons.dashboard, "Dashboard", 0),
                _buildBottomNavIcon(Icons.analytics, "Reportes", 1),
                _buildBottomNavIcon(Icons.admin_panel_settings, "Perfil", 2),
              ],
            ),
          ),
        ),
      ),
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
