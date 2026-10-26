import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class AdminPerfilTab extends StatelessWidget {
  const AdminPerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera con degradado (Igual a la del asistente)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, bottom: 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1E16), Color(0xFFB06B05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB06B05).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Color(0xFF2C1E16),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Edwin Cruz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Administrador',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),

        // NUEVO: Etiqueta indicadora de pantalla actual
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFB06B05).withOpacity(0.3)),
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
              Icon(Icons.person, color: Color(0xFFB06B05)),
              SizedBox(width: 10),
              Text(
                'PERFIL DE USUARIO',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C1E16),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Botón de Contraseña que muestra el mensaje de restricción web
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por políticas de seguridad, el cambio de contraseña solo puede realizarse desde la plataforma web.',
                      ),
                      backgroundColor: Color(0xFF2C1E16),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                child: _buildOpcionAdmin(
                  Icons.lock_reset,
                  'Cambiar Contraseña',
                ),
              ),
              // Eliminado el botón de Gestión de personal
            ],
          ),
        ),

        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            ),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpcionAdmin(IconData icon, String titulo) {
    return Container(
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2C1E16)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
