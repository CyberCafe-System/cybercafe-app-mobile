import 'package:flutter/material.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera Admin
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2C1E16),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFB06B05),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edwin Cruz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Administrador',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Image.asset('assets/img/logo_login.png', height: 40),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFB06B05).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard, color: Color(0xFFB06B05)),
                      SizedBox(width: 10),
                      Text(
                        'ESTADISTICA GENERAL',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2C1E16),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1E16),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              'Ventas Totales',
                              '\$145.50',
                              Icons.attach_money,
                              const Color(0xFF43A047),
                              const Color(0xFFE8F5E9),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildKpiCard(
                              'Rentas Activas',
                              '4',
                              Icons.computer,
                              const Color(0xFFB06B05),
                              const Color(0xFFFFF3E0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildKpiCard(
                        'Alertas Inventario',
                        '2 Productos Bajos',
                        Icons.warning_amber_rounded,
                        const Color(0xFFD32F2F),
                        const Color(0xFFFFEBEE),
                        fullWidth: true,
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        'Rendimiento Semanal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1E16),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBarraGrafica('Lun', 40),
                                _buildBarraGrafica('Mar', 70),
                                _buildBarraGrafica('Mie', 50),
                                _buildBarraGrafica('Jue', 90, isMax: true),
                                _buildBarraGrafica('Vie', 80),
                                _buildBarraGrafica('Sab', 110),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (fullWidth) const SizedBox(width: 10),
              if (fullWidth)
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          if (!fullWidth) const SizedBox(height: 5),
          if (!fullWidth)
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBarraGrafica(String dia, double alto, {bool isMax = false}) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 30,
          height: alto,
          decoration: BoxDecoration(
            gradient: isMax
                ? const LinearGradient(
                    colors: [Color(0xFFB06B05), Color(0xFFE65100)],
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dia,
          style: TextStyle(
            color: isMax ? const Color(0xFFB06B05) : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
