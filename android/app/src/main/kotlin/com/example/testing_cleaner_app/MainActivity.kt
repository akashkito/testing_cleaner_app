package com.example.testing_cleaner_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import androidx.annotation.NonNull
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.testing_cleaner_app"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSpeedTest" -> {
                    SpeedTestUtil.startSpeedTest { speedResult ->
                        result.success(speedResult)
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
}
