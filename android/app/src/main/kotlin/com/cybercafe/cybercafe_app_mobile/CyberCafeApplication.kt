package com.cybercafe.cybercafe_app_mobile

import android.app.Application
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

/**
 * Mantiene un único [FlutterEngine] durante toda la vida del proceso.
 *
 * Esto permite que, al cerrar la app desde "Recientes", el motor de Flutter y
 * el isolate de Dart sigan vivos mientras el servicio en primer plano mantiene
 * el proceso activo. Así el sondeo de notificaciones no se detiene.
 *
 * El canal nativo también vive aquí para que iniciar/detener el servicio
 * funcione incluso cuando la Activity ya fue destruida.
 */
class CyberCafeApplication : Application() {

    companion object {
        const val ENGINE_ID = "cybercafe_engine"
        private const val CANAL_SESION_FONDO =
            "com.cybercafe.cybercafe_app_mobile/sesion_fondo"
    }

    override fun onCreate() {
        super.onCreate()

        // Se crea y se cachea, pero el entrypoint de Dart se ejecuta cuando la
        // MainActivity se inicia (FlutterActivity lo hace automáticamente).
        val engine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: FlutterEngine(this).also {
                FlutterEngineCache.getInstance().put(ENGINE_ID, it)
            }

        configurarCanal(engine)
    }

    private fun configurarCanal(engine: FlutterEngine) {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            CANAL_SESION_FONDO
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "iniciar" -> {
                        SessionForegroundService.iniciar(this)
                        result.success(true)
                    }

                    "detener" -> {
                        SessionForegroundService.detener(this)
                        result.success(true)
                    }

                    "solicitarExclusionBateria" -> {
                        solicitarExclusionBateria()
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error(
                    "servicio_fondo_error",
                    e.message ?: "No se pudo controlar el servicio en segundo plano.",
                    null
                )
            }
        }
    }

    /**
     * Pide al usuario excluir la app de la optimización de batería para que
     * Android no suspenda la red ni los temporizadores con la pantalla apagada.
     */
    private fun solicitarExclusionBateria() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return

        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (powerManager.isIgnoringBatteryOptimizations(packageName)) return

        try {
            startActivity(
                Intent(
                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    Uri.parse("package:$packageName")
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            )
        } catch (_: Exception) {
            // Algunos fabricantes no soportan el diálogo directo; se abre la
            // lista de apps para que el usuario lo haga manualmente.
            try {
                startActivity(
                    Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                )
            } catch (_: Exception) {
                // Sin soporte: no hay nada más que hacer.
            }
        }
    }
}
