package com.onebeat.app

import android.Manifest
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothStatusCodes
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_CAPABILITIES_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCapabilities" -> result.success(readCapabilities())
                "requestBluetoothPermissions" -> requestBluetoothPermissions(result)
                "openBluetoothSettings" -> openBluetoothSettings(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun readCapabilities(): Map<String, Any> {
        val manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val adapter = manager.adapter
        val permissionGranted = hasBluetoothPermission()
        val leAudioSupported = if (
            permissionGranted && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
        ) {
            adapter?.isLeAudioSupported == BluetoothStatusCodes.FEATURE_SUPPORTED
        } else {
            false
        }
        val broadcastSupported = if (
            permissionGranted && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
        ) {
            adapter?.isLeAudioBroadcastSourceSupported == BluetoothStatusCodes.FEATURE_SUPPORTED
        } else {
            false
        }

        return mapOf(
            "platformVersion" to Build.VERSION.SDK_INT,
            "bluetoothAvailable" to (adapter != null),
            "bluetoothPermissionGranted" to permissionGranted,
            "bluetoothEnabled" to (permissionGranted && adapter?.isEnabled == true),
            "leAudioSupported" to leAudioSupported,
            "broadcastSourceSupported" to broadcastSupported,
        )
    }

    private fun hasBluetoothPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun requestBluetoothPermissions(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || hasBluetoothPermission()) {
            result.success(true)
            return
        }
        if (pendingPermissionResult != null) {
            result.error("request_in_progress", "A permission request is already active.", null)
            return
        }

        pendingPermissionResult = result
        requestPermissions(
            arrayOf(
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_SCAN,
            ),
            BLUETOOTH_PERMISSION_REQUEST,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != BLUETOOTH_PERMISSION_REQUEST) return

        val granted = grantResults.isNotEmpty() &&
            grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
    }

    private fun openBluetoothSettings(result: MethodChannel.Result) {
        try {
            startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
            result.success(null)
        } catch (error: Exception) {
            result.error("settings_unavailable", error.message, null)
        }
    }

    private companion object {
        const val AUDIO_CAPABILITIES_CHANNEL = "com.onebeat.app/audio_capabilities"
        const val BLUETOOTH_PERMISSION_REQUEST = 4102
    }
}
