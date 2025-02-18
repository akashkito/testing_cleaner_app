package com.example.testing_cleaner_app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.testing_cleaner_app"
    
    // Permission request code
    private val PERMISSION_REQUEST_CODE = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {

                // Handle startSpeedTest method call
                "startSpeedTest" -> {
                    if (checkPermissions()) {
                        // Call the SpeedTestUtil class to start the speed test
                        SpeedTestUtil.startSpeedTest(applicationContext) { speedResult ->
                            result.success(speedResult)
                        }
                    } else {
                        // Request permissions if not granted
                        requestPermissions()
                        result.error("PERMISSION_DENIED", "Required permissions not granted", null)
                    }
                }

                "getBatteryLevel" -> {
                    val batteryLevel = BatteryInfo.getBatteryLevel(applicationContext)
                    if (batteryLevel != -1) result.success(batteryLevel)
                    else result.error("UNAVAILABLE", "Battery level not available.", null)
                }
                "getBatteryStatus" -> {
                    val batteryStatus = BatteryInfo.getBatteryStatus(applicationContext)
                    result.success(batteryStatus)
                }
                "getStorageInfo" -> {
                    val storageInfo = StorageInfo.getStorageInfo()
                    result.success(storageInfo)
                }
                "getDisplayInfo" -> {
                    val displayInfo = DisplayInfo.getScreenResolution(applicationContext)
                    result.success(displayInfo)
                }
                "isUsagePermissionGranted" -> {
                    val isGranted = AppInfo.isUsagePermissionGranted(applicationContext)
                    result.success(isGranted)
                }
                "openUsageAccessSettings" -> {
                    AppInfo.openUsageAccessSettings(applicationContext)
                    result.success(null)  // Indicate the method was successful
                }
                "getInstalledApps" -> {
                    if (AppInfo.isUsagePermissionGranted(applicationContext)) {
                        val apps = AppInfo.getInstalledApps(applicationContext)
                        result.success(apps)
                    } else {
                        // Show dialog and return error
                        AppInfo.showUsagePermissionDialog(this)
                        result.error("PERMISSION_DENIED", "Usage Access Permission not granted", null)
                    }
                }
                "openUsageAccessSettings" -> {
                    AppInfo.openUsageAccessSettings(applicationContext)
                    result.success("Navigated to Usage Access Settings")
                }
                "getDeviceInfo" -> {
                    val deviceDetails = DeviceInfo.getDeviceDetails(applicationContext)
                    result.success(deviceDetails)
                }
                "getWifiInfo" -> {
                    val wifiInfo = WifiInfo.getWifiInfo(applicationContext)
                    result.success(wifiInfo)
                }
                "getMemoryInfo" -> {
                    val memoryInfo = MemoryInfo.getMemoryInfo(applicationContext)
                    result.success(memoryInfo)
                }
                "getCameraInfo" -> {
                    val cameraInfo = CameraInfo.getCameraInfo(applicationContext)
                    result.success(cameraInfo)
                }
                "getProcessorInfo" -> {
                    val processorInfo = ProcessorInfo.getProcessorInfo()
                    result.success(processorInfo)
                }
                "getJunkFiles" -> {
                    val junkFiles = getJunkFiles(applicationContext)
                    result.success(junkFiles)
                }
                
                else -> result.notImplemented()
            }
        }
    }

    // Check if the necessary permissions are granted
    private fun checkPermissions(): Boolean {
        val locationPermission = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_FINE_LOCATION
        )
        val networkPermission = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_NETWORK_STATE
        )
        return locationPermission == PackageManager.PERMISSION_GRANTED &&
                networkPermission == PackageManager.PERMISSION_GRANTED
    }

    // Request the necessary permissions
    private fun requestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_NETWORK_STATE),
                PERMISSION_REQUEST_CODE
            )
        }
    }

    // Handle permission request result
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Permissions granted!", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Permissions denied!", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
