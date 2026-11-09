package com.cybercafe.cybercafe_app_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

/**
 * Servicio en primer plano que mantiene vivo el proceso de la app mientras el
 * usuario tiene una sesión iniciada, para que pueda seguir recibiendo
 * notificaciones aunque esté en otra aplicación o con la pantalla apagada.
 *
 * La notificación es permanente ("Sesión activa") y al tocarla abre la app.
 */
class SessionForegroundService : Service() {

    companion object {
        private const val CHANNEL_ID = "cybercafe_sesion_activa"
        private const val NOTIFICATION_ID = 1001
        private const val ACTION_INICIAR =
            "com.cybercafe.cybercafe_app_mobile.SESION_FONDO_INICIAR"
        private const val ACTION_DETENER =
            "com.cybercafe.cybercafe_app_mobile.SESION_FONDO_DETENER"
        private const val WAKE_LOCK_TAG = "CyberCafe::SesionActiva"

        /** Inicia el servicio desde la app (siempre en primer plano). */
        fun iniciar(context: Context) {
            val intent = Intent(context, SessionForegroundService::class.java)
                .setAction(ACTION_INICIAR)
            ContextCompat.startForegroundService(context, intent)
        }

        /** Detiene el servicio y retira la notificación permanente. */
        fun detener(context: Context) {
            context.stopService(
                Intent(context, SessionForegroundService::class.java)
            )
        }
    }

    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        crearCanal()
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        if (intent?.action == ACTION_DETENER) {
            detenerServicio()
            return START_NOT_STICKY
        }

        return try {
            startForeground(NOTIFICATION_ID, construirNotificacion())
            adquirirWakeLock()
            START_NOT_STICKY
        } catch (e: Exception) {
            // Si Android rechaza el servicio (por ejemplo, por falta de tipo de
            // foreground service), no dejamos la app en un estado inconsistente.
            detenerServicio()
            START_NOT_STICKY
        }
    }

    override fun onDestroy() {
        detenerServicio()
        super.onDestroy()
    }

    private fun detenerServicio() {
        liberarWakeLock()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    /**
     * Mantiene la CPU despierta para que los temporizadores de Dart sigan
     * ejecutándose con la pantalla apagada.
     *
     * Sin la exclusión de optimización de batería, Android puede ignorar este
     * wake lock durante Doze; por eso la app también solicita esa exclusión.
     */
    private fun adquirirWakeLock() {
        if (wakeLock?.isHeld == true) return

        val powerManager =
            getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG)
            .apply {
                setReferenceCounted(false)
                acquire()
            }
    }

    private fun liberarWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (_: Exception) {
            // Si el wake lock ya no está retenido, no hay nada que liberar.
        }
        wakeLock = null
    }

    private fun crearCanal() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            "Sesión activa",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description =
                "Mantiene la app conectada para recibir notificaciones en segundo plano."
            setShowBadge(false)
            enableLights(false)
            enableVibration(false)
            setSound(null, null)
        }
        manager.createNotificationChannel(channel)
    }

    private fun construirNotificacion(): Notification {
        val abrirApp = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            }

        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            abrirApp,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Sesión activa")
            .setContentText(
                "Toca para abrir la app. Seguirás recibiendo notificaciones en segundo plano."
            )
            .setSmallIcon(R.drawable.ic_stat_sesion)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(contentIntent)
            .build()
    }
}
