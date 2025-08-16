package com.example.jnk_app

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourdomain.time/settings"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "isTimeAutomatic" -> {
                    val isAuto = Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME, 0) == 1
                    result.success(isAuto)
                }
                "isTimeZoneAutomatic" -> {
                    val isAutoZone = Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME_ZONE, 0) == 1
                    result.success(isAutoZone)
                }
                "openDateTimeSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_DATE_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open Date & Time settings", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

