import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'role_home.dart';

enum _GateEstado { comprobando, login, listo, errorConexion }

/// Decide al arrancar si se restaura la sesión guardada o se muestra el login.
class SessionGate extends StatefulWidget {
  const SessionGate({super.key, this.auth, this.homeBuilder});

  final AuthService? auth;

  /// Permite sustituir los dashboards reales en tests.
  final Widget Function(int rolId)? homeBuilder;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  _GateEstado _estado = _GateEstado.comprobando;
  String? _mensajeLogin;
  Widget? _home;

  AuthService get _auth => widget.auth ?? AuthService.instance;

  @override
  void initState() {
    super.initState();
    _validar();
  }

  Future<void> _validar({bool mostrarCarga = false}) async {
    if (mostrarCarga && mounted) {
      setState(() {
        _estado = _GateEstado.comprobando;
        _mensajeLogin = null;
      });
    }

    bool restaurada;
    try {
      restaurada = await _auth.restoreSession();
    } catch (_) {
      restaurada = false;
    }

    if (!restaurada) {
      _irALogin();
      return;
    }

    try {
      final activa = await _auth.verificarSesionActiva();
      if (!activa) {
        _irALogin('Tu sesión finalizó. Inicia sesión nuevamente.');
        return;
      }
    } on AuthException catch (e) {
      if (e.statusCode == 401) {
        _irALogin(e.message);
      } else {
        _irAErrorConexion();
      }
      return;
    } catch (_) {
      _irAErrorConexion();
      return;
    }

    final rol = _auth.rolEfectivo;
    final home = widget.homeBuilder?.call(rol ?? -1) ?? homePorRol(rol);

    if (rol == null || (rol != 1 && rol != 3) || home == null) {
      await _descartarSesion();
      _irALogin('Tu rol no tiene acceso a la aplicación móvil.');
      return;
    }

    if (!mounted) return;
    setState(() {
      _home = conSessionWatcher(home);
      _estado = _GateEstado.listo;
    });
  }

  Future<void> _descartarSesion() async {
    try {
      await _auth.clearSession();
    } catch (_) {
      // Si el almacenamiento falla, igualmente se muestra el login.
    }
  }

  Future<void> _usarOtraCuenta() async {
    await _descartarSesion();
    _irALogin();
  }

  void _irALogin([String? mensaje]) {
    if (!mounted) return;
    setState(() {
      _mensajeLogin = mensaje;
      _home = null;
      _estado = _GateEstado.login;
    });
  }

  void _irAErrorConexion() {
    if (!mounted) return;
    setState(() {
      _home = null;
      _estado = _GateEstado.errorConexion;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_estado) {
      case _GateEstado.listo:
        return _home ?? const SizedBox.shrink();
      case _GateEstado.login:
        return LoginScreen(mensajeSesion: _mensajeLogin);
      case _GateEstado.errorConexion:
        return _PantallaErrorConexion(
          onReintentar: () => _validar(mostrarCarga: true),
          onUsarOtraCuenta: _usarOtraCuenta,
        );
      case _GateEstado.comprobando:
        return const _PantallaCarga();
    }
  }
}

class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/img/logo_login.png',
              height: 90,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.coffee, size: 72, color: Color(0xFF2C1E16)),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFFB06B05)),
            const SizedBox(height: 16),
            const Text(
              'Restaurando sesión...',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantallaErrorConexion extends StatelessWidget {
  const _PantallaErrorConexion({
    required this.onReintentar,
    required this.onUsarOtraCuenta,
  });

  final VoidCallback onReintentar;
  final Future<void> Function() onUsarOtraCuenta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Color(0xFFB06B05),
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudo validar la sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1E16),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Revisa tu conexión a internet e inténtalo de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB06B05),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onUsarOtraCuenta,
                child: const Text('Usar otra cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
