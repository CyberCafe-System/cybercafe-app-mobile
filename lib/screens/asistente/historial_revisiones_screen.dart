import 'package:flutter/material.dart';

import 'historial_componentes_tab.dart';
import 'historial_equipos_tab.dart';

class HistorialRevisionesScreen extends StatefulWidget {
  const HistorialRevisionesScreen({super.key});

  @override
  State<HistorialRevisionesScreen> createState() =>
      _HistorialRevisionesScreenState();
}

class _HistorialRevisionesScreenState extends State<HistorialRevisionesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<HistorialEquiposTabState> _equiposKey = GlobalKey();
  final GlobalKey<HistorialComponentesTabState> _componentesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _recargarActual() {
    if (_tabController.index == 0) {
      _equiposKey.currentState?.recargar();
    } else {
      _componentesKey.currentState?.recargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          _buildHeader(),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2C1E16),
              unselectedLabelColor: Colors.black54,
              indicatorColor: const Color(0xFFB06B05),
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Equipos'),
                Tab(text: 'Componentes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                HistorialEquiposTab(key: _equiposKey),
                HistorialComponentesTab(key: _componentesKey),
              ],
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
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 18),
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
                      'Revisiones e incidencias',
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
                onPressed: _recargarActual,
                icon: const Icon(Icons.refresh, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
