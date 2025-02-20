package com.example.testing_cleaner_app

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import android.os.Environment
import android.widget.Toast


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.testing_cleaner_app"
    private val PERMISSION_REQUEST_CODE = 1
    private val REQUEST_CODE_MANAGE_STORAGE = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val isGranted = Environment.isExternalStorageManager()
            if (!isGranted) {
                try {
                    // Request "Manage All Files Access" permission for Android 11+
                    val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                    startActivityForResult(intent, REQUEST_CODE_MANAGE_STORAGE)
                } catch (e: ActivityNotFoundException) {
                    Toast.makeText(this, "Cannot open settings to grant permission. Please enable it manually.", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "startSpeedTest" -> handleStartSpeedTest(result)
                    "checkStoragePermission" -> handleCheckStoragePermission(result)
                    "requestStoragePermission" -> handleRequestStoragePermission(result)
                    "getPhotoFiles" -> handleGetPhotoFiles(result)
                    "getBatteryLevel" -> handleGetBatteryLevel(result)
                    "getBatteryStatus" -> handleGetBatteryStatus(result)
                    "getStorageInfo" -> handleGetStorageInfo(result)
                    "getDisplayInfo" -> handleGetDisplayInfo(result)
                    "isUsagePermissionGranted" -> handleIsUsagePermissionGranted(result)
                    "openUsageAccessSettings" -> handleOpenUsageAccessSettings(result)
                    "getInstalledApps" -> handleGetInstalledApps(result)
                    "getDeviceInfo" -> handleGetDeviceInfo(result)
                    "getWifiInfo" -> handleGetWifiInfo(result)
                    "getMemoryInfo" -> handleGetMemoryInfo(result)
                    "getCameraInfo" -> handleGetCameraInfo(result)
                    "getProcessorInfo" -> handleGetProcessorInfo(result)
                    "getJunkFiles" -> handleGetJunkFiles(result)
                    "openAppSettings" -> {
                        openAppSettings()
                        result.success(null)
                    }
                    "openStorageAccessSettings" -> {
                        openStorageAccessSettings() // Open storage access settings for Android 11+
                        result.success(null)
                    }
                    "openAllFilesAccessSettings" -> {
                        openAllFilesAccessSettings() // Open storage access settings for Android 11+
                        result.success(null)
                    }
                    "deletePhoto" -> {
                    val photoPath = call.argument<String>("path")
                    if (photoPath != null) {
                        val deleted = MediaInfo.deletePhoto(this, photoPath)
                        result.success(deleted)
                    } else {
                        result.success(false)
                    }
                }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun openAllFilesAccessSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
            val uri = Uri.fromParts("package", packageName, null)
            intent.data = uri
            startActivity(intent)
        } else {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            val uri = Uri.fromParts("package", packageName, null)
            intent.data = uri
            startActivity(intent)
        }
    }

    // Request for basic location and network permissions
    private fun checkPermissions(): Boolean {
        val locationPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
        val networkPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_NETWORK_STATE)
        return locationPermission == PackageManager.PERMISSION_GRANTED && networkPermission == PackageManager.PERMISSION_GRANTED
    }

    // Request permissions for location and network access
    private fun requestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_NETWORK_STATE),
                PERMISSION_REQUEST_CODE
            )
        }
    }

    // Request storage permission for Android 6-10 devices
    fun requestStoragePermission(@NonNull result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(
                this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                1
            )
            result.success(true)
        } else {
            result.success(true)
        }
    }

    // Handle speed test functionality
    private fun handleStartSpeedTest(result: MethodChannel.Result) {
        if (checkPermissions()) {
            SpeedTestUtil.startSpeedTest(applicationContext) { speedResult ->
                result.success(speedResult)
            }
        } else {
            requestPermissions()
            result.error("PERMISSION_DENIED", "Required permissions not granted", null)
        }
    }

    // Handle storage permission check for Flutter
    private fun handleCheckStoragePermission(result: MethodChannel.Result) {
        val permissionGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        result.success(permissionGranted)
    }

    // Request storage permission and handle it for both Android 6-10 and Android 11+
    private fun handleRequestStoragePermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val isGranted = Environment.isExternalStorageManager()
            if (!isGranted) {
                try {
                    // If not granted, open the permission settings for Android 11+
                    val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                    startActivityForResult(intent, REQUEST_CODE_MANAGE_STORAGE)
                } catch (e: ActivityNotFoundException) {
                    Toast.makeText(this, "Cannot open settings to grant permission. Please enable it manually.", Toast.LENGTH_LONG).show()
                }
                result.success(false)
            } else {
                result.success(true)
            }
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), PERMISSION_REQUEST_CODE)
                result.success(false)
            } else {
                result.success(true)
            }
        }
    }

    // Get photo files from the device
    private fun handleGetPhotoFiles(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val isGranted = Environment.isExternalStorageManager()
            if (isGranted) {
                val files = MediaInfo.getPhotoFiles(this)
                result.success(files)
            } else {
                result.error("PERMISSION_DENIED", "Permission not granted for accessing all files", null)
            }
        } else {
            val files = MediaInfo.getPhotoFiles(this)
            result.success(files)
        }
    }

    // Get battery level
    private fun handleGetBatteryLevel(result: MethodChannel.Result) {
        val batteryLevel = BatteryInfo.getBatteryLevel(applicationContext)
        if (batteryLevel != -1) result.success(batteryLevel)
        else result.error("UNAVAILABLE", "Battery level not available.", null)
    }

    // Get battery status
    private fun handleGetBatteryStatus(result: MethodChannel.Result) {
        val batteryStatus = BatteryInfo.getBatteryStatus(applicationContext)
        result.success(batteryStatus)
    }

    // Get storage info
    private fun handleGetStorageInfo(result: MethodChannel.Result) {
        val storageInfo = StorageInfo.getStorageInfo()
        result.success(storageInfo)
    }

    // Get display info
    private fun handleGetDisplayInfo(result: MethodChannel.Result) {
        val displayInfo = DisplayInfo.getScreenResolution(applicationContext)
        result.success(displayInfo)
    }

    // Check if usage permission is granted
    private fun handleIsUsagePermissionGranted(result: MethodChannel.Result) {
        val isGranted = AppInfo.isUsagePermissionGranted(applicationContext)
        result.success(isGranted)
    }

    // Open usage access settings
    private fun handleOpenUsageAccessSettings(result: MethodChannel.Result) {
        AppInfo.openUsageAccessSettings(applicationContext)
        result.success(null)
    }

    // Get installed apps
    private fun handleGetInstalledApps(result: MethodChannel.Result) {
        if (AppInfo.isUsagePermissionGranted(applicationContext)) {
            val apps = AppInfo.getInstalledApps(applicationContext)
            result.success(apps)
        } else {
            AppInfo.showUsagePermissionDialog(this)
            result.error("PERMISSION_DENIED", "Usage Access Permission not granted", null)
        }
    }

    // Get device info
    private fun handleGetDeviceInfo(result: MethodChannel.Result) {
        val deviceDetails = DeviceInfo.getDeviceDetails(applicationContext)
        result.success(deviceDetails)
    }

    // Get Wi-Fi info
    private fun handleGetWifiInfo(result: MethodChannel.Result) {
        val wifiInfo = WifiInfo.getWifiInfo(applicationContext)
        result.success(wifiInfo)
    }

    // Get memory info
    private fun handleGetMemoryInfo(result: MethodChannel.Result) {
        val memoryInfo = MemoryInfo.getMemoryInfo(applicationContext)
        result.success(memoryInfo)
    }

    // Get camera info
    private fun handleGetCameraInfo(result: MethodChannel.Result) {
        val cameraInfo = CameraInfo.getCameraInfo(applicationContext)
        result.success(cameraInfo)
    }

    // Get processor info
    private fun handleGetProcessorInfo(result: MethodChannel.Result) {
        val processorInfo = ProcessorInfo.getProcessorInfo()
        result.success(processorInfo)
    }

    // Get junk files
    private fun handleGetJunkFiles(result: MethodChannel.Result) {
        val junkFiles = getJunkFiles(applicationContext)
        result.success(junkFiles)
    }

    // Open app settings
    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri = Uri.fromParts("package", packageName, null)
        intent.data = uri
        startActivity(intent)
    }

    // Open storage access settings
    private fun openStorageAccessSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                // Open the settings page to request "Manage All Files Access" permission
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                startActivityForResult(intent, REQUEST_CODE_MANAGE_STORAGE)
            } catch (e: ActivityNotFoundException) {
                // If the intent cannot be handled, show a message to the user
                Toast.makeText(this, "Cannot open settings to grant permission. Please enable it manually.", Toast.LENGTH_LONG).show()
                openAppSettings()  // Fallback to app settings if unable to open manage files access
            }
        } else {
            // For devices below Android 11, fall back to normal app settings
            openAppSettings()
        }
    }

    // Handle permissions result from user
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val isGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            flutterEngine?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onPermissionResult", isGranted)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_MANAGE_STORAGE) {
            if (Environment.isExternalStorageManager()) {
                flutterEngine?.let { engine ->
                    MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onPermissionResult", true)
                }
            } else {
                flutterEngine?.let { engine ->
                    MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onPermissionResult", false)
                }
            }
        }
    }
}
