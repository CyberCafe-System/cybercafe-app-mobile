package com.cybercafe.cybercafe_app_mobile

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {

    /**
     * Usa el motor cacheado por [CyberCafeApplication] para que el isolate de
     * Dart sobreviva cuando el usuario cierra la app desde "Recientes".
     */
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance()
            .get(CyberCafeApplication.ENGINE_ID)
    }
}
