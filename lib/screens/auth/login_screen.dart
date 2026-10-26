import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para el efecto de desenfoque (vidrio)
import 'success_auth_screen.dart'; // Nueva pantalla de animación

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _loginProcess() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    // TODO: BACKEND - Validación de credenciales con la API
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    if (!mounted) return;

    // Al ser correcto, enviamos a la pantalla de animación
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SuccessAuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/fondo_login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.2,
                    ), // Blanco semi-transparente
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo de la empresa
                      Image.asset(
                        'assets/img/logo_login.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.coffee,
                              size: 80,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The COFFEE LAN',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: _userController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Nombre de Usuario',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginProcess,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFB06B05,
                            ), // Color Cobre
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Si tienes problemas para ingresar',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const Text(
                        '¡Notifica a tu supervisor!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
