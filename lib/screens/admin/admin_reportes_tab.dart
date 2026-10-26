import 'package:flutter/material.dart';

class AdminReportesTab extends StatelessWidget {
  const AdminReportesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Área superior
          Container(
            color: const Color(0xFFF4F6F9),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // MENÚ CIRCULAR
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: const Color(0xFFB06B05),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(
                        0xFF2C1E16,
                      ).withOpacity(0.6),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Ventas'),
                        Tab(text: 'Rentas'),
                        Tab(text: 'Inventario'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Etiqueta indicadora de pantalla actual
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 48, 27, 10),
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
                Icon(Icons.analytics, color: Color(0xFFB06B05)),
                SizedBox(width: 10),
                Text(
                  'SECCIÓN DE REPORTES',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 254, 254, 254),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              children: [
                _buildVistaReporte(
                  context,
                  'Ventas',
                  ['Producto', 'Cant.', 'Total'],
                  [
                    ['Café Americano', '2', '\$3.00'],
                    ['Hora PC', '1', '\$1.50'],
                    ['Doritos', '3', '\$2.25'],
                  ],
                ),
                _buildVistaReporte(
                  context,
                  'Rentas',
                  ['Equipo', 'Tiempo', 'Estado'],
                  [
                    ['PC-01', '1h 30m', 'Finalizado'],
                    ['Consola-02', '45m', 'Activo'],
                    ['PC-04', '2h', 'Finalizado'],
                  ],
                ),
                _buildVistaReporte(
                  context,
                  'Inventario',
                  ['Producto', 'Stock', 'Precio'],
                  [
                    ['Coca Cola 600ml', '24', '\$1.00'],
                    ['Galletas Oreo', '15', '\$0.75'],
                    ['Café Grano', '5kg', '\$12.00'],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVistaReporte(
    BuildContext context,
    String tipo,
    List<String> columnas,
    List<List<String>> datos,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: Color(0xFFB06B05)),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: columnas
                          .map(
                            (col) => Expanded(
                              child: Text(
                                col,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C1E16),
                                ),
                                textAlign: col == columnas.last
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: datos.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.shade200, height: 1),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          child: Row(
                            children: datos[index].map((dato) {
                              bool isLast = dato == datos[index].last;
                              return Expanded(
                                child: Text(
                                  dato,
                                  style: TextStyle(
                                    fontWeight: isLast
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isLast
                                        ? const Color(0xFFB06B05)
                                        : Colors.black87,
                                  ),
                                  textAlign: isLast
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
