package com.example.personal_finance

import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import notification.listener.service.NotificationListener

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "moneta/notification_queue",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAllowedPackages" -> {
                    val pkgs = (call.arguments as? List<*>)
                        ?.filterIsInstance<String>() ?: emptyList()
                    NotificationQueue.setAllowed(this, pkgs)
                    result.success(null)
                }
                "drain" -> result.success(NotificationQueue.drain(this))
                "status" -> {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(
                        mapOf(
                            "connected" to NotificationListener.isConnected,
                            "ignoringBattery" to pm.isIgnoringBatteryOptimizations(packageName),
                            "queued" to NotificationQueue.count(this),
                        )
                    )
                }
                "openBatterySettings" -> {
                    // Daftar pengecualian optimasi baterai; cadangannya info aplikasi.
                    try {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                    } catch (e: Exception) {
                        openAppDetails()
                    }
                    result.success(null)
                }
                "openAppSettings" -> {
                    openAppDetails()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openAppDetails() {
        startActivity(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.parse("package:$packageName"))
        )
    }
}
