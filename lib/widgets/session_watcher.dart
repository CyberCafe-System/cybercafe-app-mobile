import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/local_notification_service.dart';
import '../services/notificacion_service.dart';

/// Mantiene la sesión sincronizada con la API y gestiona el sondeo global
/// de notificaciones del sistema para cualquier usuario autenticado (Admin o Asistente).
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

  /// Callback global para refrescar pantallas secundarias cuando lleguen alertas.
  static VoidCallback? onNotificacionesNuevas;

  @override
  State<SessionWatcher> createState() => _SessionWatcherState();
}

class _SessionWatcherState extends State<SessionWatcher>
    with WidgetsBindingObserver {
  late final AuthService _auth;
  late final VoidCallback _callback;
  Timer? _timer;
  Timer? _notificacionesTimer;
  bool _verificando = false;
  bool _consultandoNotificaciones = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? AuthService.instance;
    _callback = _manejarSesionExpirada;
    _auth.onSessionExpired = _callback;
    WidgetsBinding.instance.addObserver(this);
    LocalNotificationService.instance.solicitarPermisos();
    _iniciarTemporizadores();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _verificarSesion();
        _consultarNotificaciones();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _iniciarTemporizadores();
      _verificarSesion();
      _consultarNotificaciones();
    } else {
      _detenerTemporizadores();
    }
  }

  void _iniciarTemporizadores() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) => _verificarSesion());

    _notificacionesTimer?.cancel();
    _notificacionesTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _consultarNotificaciones(),
    );
  }

  void _detenerTemporizadores() {
    _timer?.cancel();
    _timer = null;
    _notificacionesTimer?.cancel();
    _notificacionesTimer = null;
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

  Future<void> _consultarNotificaciones() async {
    if (_consultandoNotificaciones || !_auth.isAuthenticated) return;
    _consultandoNotificaciones = true;
    try {
      final notifs = await NotificacionService.instance.obtenerPendientes();
      if (!mounted || notifs.isEmpty) return;

      for (final n in notifs) {
        if (!mounted) break;

        // 1. Notificación nativa en la bandeja de Android (sonido, vibración, heads-up)
        await LocalNotificationService.instance.mostrarNotificacion(
          id: n.notificacionId,
          titulo: n.titulo,
          cuerpo: n.mensaje,
        );

        // 2. Banner visual emergente en la app (SnackBar)
        final esRevision = n.tipo == 'PENDIENTE_REVISION';
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  esRevision ? Icons.build_circle_outlined : Icons.alarm_on,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${n.titulo}\n${n.mensaje}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: esRevision
                ? const Color(0xFFD35400)
                : const Color(0xFFC0392B),
            duration: const Duration(seconds: 6),
          ),
        );

        // 3. Marcar como leída en la base de datos
        await NotificacionService.instance.marcarComoLeida(n.notificacionId);
      }

      SessionWatcher.onNotificacionesNuevas?.call();
    } catch (_) {
      // Ignorar errores transitorios de red
    } finally {
      _consultandoNotificaciones = false;
    }
  }

  void _manejarSesionExpirada() {
    if (!mounted) return;
    widget.onSessionExpired(context);
  }

  @override
  void dispose() {
    _detenerTemporizadores();
    WidgetsBinding.instance.removeObserver(this);
    if (identical(_auth.onSessionExpired, _callback)) {
      _auth.onSessionExpired = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
