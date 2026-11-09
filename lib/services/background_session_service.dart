import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Mantiene viva la app en segundo plano mediante un servicio en primer plano
/// de Android con una notificación permanente de "Sesión activa".
///
/// La notificación es continua, no hace ruido y al tocarla vuelve a abrir la
/// aplicación. Solo aplica a Android; en iOS y web no hace nada.
class BackgroundSessionService {
  BackgroundSessionService._();

  static const MethodChannel _channel = MethodChannel(
    'com.cybercafe.cybercafe_app_mobile/sesion_fondo',
  );

  static bool _activo = false;

  /// Indica si el servicio se encuentra activo en esta sesión.
  static bool get activo => _activo;

  /// Inicia el servicio en primer plano (idempotente).
  static Future<void> iniciar() async {
    if (!_soportado) return;

    try {
      final iniciado = await _channel.invokeMethod<bool>('iniciar');
      _activo = iniciado ?? false;
    } on MissingPluginException {
      // La implementación nativa no está disponible (por ejemplo, en tests).
      _activo = false;
    } on PlatformException catch (e) {
      _activo = false;
      debugPrint('No se pudo iniciar el servicio en segundo plano: ${e.message}');
    }
  }

  /// Pide al sistema excluir la app de la optimización de batería para que
  /// Android no suspenda la red ni los temporizadores con la pantalla apagada.
  ///
  /// Solo muestra el diálogo si la app aún no está excluida.
  static Future<void> solicitarExclusionBateria() async {
    if (!_soportado) return;

    try {
      await _channel.invokeMethod<bool>('solicitarExclusionBateria');
    } on MissingPluginException {
      // Ignorar: no hay implementación nativa.
    } on PlatformException catch (e) {
      debugPrint(
        'No se pudo solicitar la exclusión de batería: ${e.message}',
      );
    }
  }

  /// Detiene el servicio y retira la notificación permanente.
  static Future<void> detener() async {
    if (!_soportado) return;

    try {
      await _channel.invokeMethod<bool>('detener');
    } on MissingPluginException {
      // Ignorar: no hay implementación nativa.
    } on PlatformException catch (e) {
      debugPrint(
        'No se pudo detener el servicio en segundo plano: ${e.message}',
      );
    } finally {
      _activo = false;
    }
  }

  static bool get _soportado => !kIsWeb && Platform.isAndroid;
}
