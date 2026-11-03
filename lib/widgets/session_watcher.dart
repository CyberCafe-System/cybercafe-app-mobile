import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Mantiene la sesión sincronizada con la API mientras hay una sesión activa.
///
/// Consulta `/usuarios/me` periódicamente para detectar si el usuario fue
/// desactivado. También verifica al volver del segundo plano y pausa el
/// temporizador cuando la app deja de estar visible.
class SessionWatcher extends StatefulWidget {
  const SessionWatcher({
    super.key,
    required this.child,
    required this.onSessionExpired,
    this.interval = const Duration(seconds: 30),
    this.auth,
  });

  final Widget child;
  final void Function(BuildContext context) onSessionExpired;
  final Duration interval;
  final AuthService? auth;

  @override
  State<SessionWatcher> createState() => _SessionWatcherState();
}

class _SessionWatcherState extends State<SessionWatcher>
    with WidgetsBindingObserver {
  late final AuthService _auth;
  late final VoidCallback _callback;
  Timer? _timer;
  bool _verificando = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? AuthService.instance;
    _callback = _manejarSesionExpirada;
    _auth.onSessionExpired = _callback;
    WidgetsBinding.instance.addObserver(this);
    _iniciarTemporizador();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _iniciarTemporizador();
      _verificarSesion();
    } else {
      _detenerTemporizador();
    }
  }

  void _iniciarTemporizador() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) => _verificarSesion());
  }

  void _detenerTemporizador() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _verificarSesion() async {
    if (_verificando || !_auth.isAuthenticated) return;
    _verificando = true;
    try {
      await _auth.verificarSesionActiva();
    } catch (_) {
      // Un fallo de red se reintenta en la siguiente verificación.
    } finally {
      _verificando = false;
    }
  }

  void _manejarSesionExpirada() {
    if (!mounted) return;
    widget.onSessionExpired(context);
  }

  @override
  void dispose() {
    _detenerTemporizador();
    WidgetsBinding.instance.removeObserver(this);
    if (identical(_auth.onSessionExpired, _callback)) {
      _auth.onSessionExpired = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
