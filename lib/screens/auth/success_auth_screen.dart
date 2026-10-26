import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../asistente/dashboard_screen.dart';

class SuccessAuthScreen extends StatefulWidget {
  const SuccessAuthScreen({super.key});

  @override
  State<SuccessAuthScreen> createState() => _SuccessAuthScreenState();
}

class _SuccessAuthScreenState extends State<SuccessAuthScreen> {
  @override
  void initState() {
    super.initState();
    _navegarAlDashboard();
  }

  void _navegarAlDashboard() async {
    // Esperamos 2.5 segundos para que el usuario vea la animación
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardAsistente()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Fondo claro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animacion.json', // Tu animación de carga correcta
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Autenticación Exitosa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1E16),
              ),
            ),
            const Text(
              'Cargando tu área de trabajo...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
