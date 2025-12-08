package com.example.peak_trail

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.peak_trail/location"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startTracking") {
                val intent = Intent(this, LocationService::class.java)
                intent.action = LocationService.ACTION_START
                startService(intent) // O startForegroundService en O+
                result.success(null)
            } else if (call.method == "stopTracking") {
                val intent = Intent(this, LocationService::class.java)
                intent.action = LocationService.ACTION_STOP
                startService(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}