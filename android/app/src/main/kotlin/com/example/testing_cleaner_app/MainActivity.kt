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
import com.example.your_app_name.FileAccessPhone
import com.example.testing_cleaner_app.OtherFilesUtil
import io.flutter.plugin.common.MethodCall
import java.io.File

import android.media.MediaPlayer
import android.app.Activity
import android.util.Log
import java.util.Calendar

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context


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
                    "getVideoFiles" -> handleGetVideoFiles(result)
                    "getAudioFiles" -> handleGetAudioFiles(result)
                    "getAudioDuration" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val duration = getAudioDuration(path)
                        result.success(duration)
                    } else {
                        result.error("UNAVAILABLE", "Audio path not available", null)
                    }
                }
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
                    
                    "getAppUsageStats" -> {
    // Get the UsageStatsManager system service
    val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val calendar = Calendar.getInstance()

    // Example for daily stats (you can use INTERVAL_HOURLY for hourly stats)
    calendar.add(Calendar.DAY_OF_YEAR, -1)  // Get stats from the last 24 hours

    // Query for usage stats within the defined time period (last 24 hours)
    val stats = usageStatsManager.queryUsageStats(
        UsageStatsManager.INTERVAL_DAILY, // Change this to INTERVAL_HOURLY for hourly stats
        calendar.timeInMillis,
        System.currentTimeMillis()
    )

    fun formatDuration(totalTimeInForeground: Long): String {
        val seconds = totalTimeInForeground / 1000
        val minutes = seconds / 60
        val hours = minutes / 60

        return if (hours > 0) {
            "${hours}h ${minutes % 60}m"
        } else {
            "${minutes}m ${seconds % 60}s"
        }
    }

    // Check if the stats are not empty and process the data
    if (stats != null && stats.isNotEmpty()) {
        val usageStatsList = mutableListOf<Map<String, Any>>()

        // Iterate through the retrieved stats
        for (usageStat in stats) {
            val packageName = usageStat.packageName  // Get the package name of the app
            val lastUsed = usageStat.lastTimeUsed  // Get the last time the app was used
            val totalTime = usageStat.totalTimeInForeground  // Get the total time the app was in the foreground

            // Create a map to hold the app info
            val appInfo = mapOf(
                "packageName" to packageName,
                "lastUsed" to lastUsed,
                "totalTime" to formatDuration(totalTime)  // You can use the existing formatDuration function
            )

            // Add the app information to the list
            usageStatsList.add(appInfo)
        }

        // Return the result to Flutter (or whatever platform you're using)
        result.success(usageStatsList)

    } else {
        // If no usage stats are found, send an error message
        result.error("UNAVAILABLE", "No usage stats found", null)
    }
}


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
                     "getFilesInDirectory" -> {
    val directoryPath = call.argument<String>("directoryPath")
    val offset = call.argument<Int>("offset") ?: 0 // Use 0 as default if offset is not provided
    
    if (directoryPath != null) {
        // Now pass the directoryPath and offset to getFilesInDirectory
        val files = FileAccessPhone.getFilesInDirectory(this, directoryPath, offset)
        result.success(files)
    } else {
        result.error("INVALID_ARGUMENT", "Directory path is null", null)
    }
}
                "getSpecialFolders" -> {
                    val specialFolders = FileAccessPhone.getSpecialFolders(this)
                    result.success(specialFolders)
                }
                 "getOtherFiles" -> handleGetOtherFiles(result)
                "deleteOtherFile" -> handleDeleteFile(call, result)
               
                
                 "deleteFile" -> {
                        val filePath = call.argument<String>("filePath")
                        if (filePath != null) {
                            // Call the deleteFile method
                            val success = FileAccessPhone.deleteFile(filePath)
                            if (success) {
                                result.success(true) // Successfully deleted the file
                            } else {
                                result.error("DELETE_FAILED", "Failed to delete the file.", null)
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "File path is null", null)
                        }
                    }
                    "checkStoragePermission" -> {
                        val isPermissionGranted = FileAccessPhone.isPermissionGranted(applicationContext)
                        result.success(isPermissionGranted)
                    }
                    "requestStoragePermission" -> {
                        FileAccessPhone.requestPermission(applicationContext, result)
                    }
                    "deletePhoto" -> {
                        val photoPath = call.argument<String>("path")
                        if (photoPath != null) {
                            val deleted = MediaInfo.deletePhoto(this, photoPath)
                            result.success(deleted)
                    }   else {
                        result.success(false)
                        }
                    }
                    "deleteVideo" -> {
                        val videoPath = call.argument<String>("path")
                        if (videoPath != null) {
                            val deleted = MediaInfo.deleteVideo(this, videoPath)
                            result.success(deleted)
                        } else {
                            result.success(false)
                        }
                    }
                    "deleteAudio" -> {
                        val audioPath = call.argument<String>("path")
                        if (audioPath != null) {
                            val deleted = MediaInfo.deleteAudio(this, audioPath)
                            result.success(deleted)
                        } else {
                            result.success(false)
                        }
                    }
                    "uninstallApp" -> {
                        // Get the package name from the Flutter side
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            // Call uninstallApp from appinfo.kt
                            uninstallApp(this, packageName)
                            result.success("Uninstall initiated")
                        } else {
                            result.error("ERROR", "Package name not provided", null)
                        }
                    }
                    

                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun getAudioDuration(path: String): String {
        val mediaPlayer = MediaPlayer()
        try {
            mediaPlayer.setDataSource(path)
            mediaPlayer.prepare() // This might take time
            val duration = mediaPlayer.duration
            mediaPlayer.release()

            val minutes = duration / 1000 / 60
            val seconds = (duration / 1000) % 60
            return "$minutes m $seconds s"
        } catch (e: Exception) {
            e.printStackTrace()
            return "Unknown"
        }
    }



     private fun openAllFilesAccessSettings() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // For Android 11+ (API 30+), we need to check for MANAGE_EXTERNAL_STORAGE permission
                val isPermissionGranted = isStoragePermissionGranted()
                if (isPermissionGranted) {
                    // Permission is granted
                    println("Permission already granted.")
                } else {
                    // Launch settings to request permission
                    val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                    val uri = Uri.fromParts("package", packageName, null)
                    intent.data = uri
                    startActivity(intent)
                    println("Opening 'All Files Access' settings.")
                }
            } else {
                // For older Android versions, open the general app settings
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                val uri = Uri.fromParts("package", packageName, null)
                intent.data = uri
                startActivity(intent)
                println("Opening app settings for older versions.")
            }
        } catch (e: Exception) {
            // Catch any exceptions to prevent crashes
            println("Error opening settings: ${e.message}")
        }
    }

    private fun isStoragePermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Check if permission to manage files is granted (only needed for Android 11+)
            android.os.Environment.isExternalStorageManager()
        } else {
            // Permissions are handled by regular storage permissions on lower versions
            true // Assuming permissions are granted for versions below Android 11
        }
    }

     private fun handleGetOtherFiles(result: MethodChannel.Result) {
        try {
            // Call the utility method to get files
            val files = OtherFilesUtil.getOtherFiles(applicationContext)
            val filesList = files.map { file ->
                mapOf("name" to file.name, "size" to file.length(), "path" to file.absolutePath)
            }
            result.success(filesList) // Send the result back to Flutter
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get other files: ${e.message}", null)
        }
    }

    private fun handleDeleteFile(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.argument<String>("filePath")
        if (filePath != null) {
            try {
                val file = File(filePath ?: "")
                val success = OtherFilesUtil.deleteOtherFile(file)

                if (success) {
                    result.success(true) // File deleted successfully
                } else {
                    result.error("ERROR", "Failed to delete file", null)
                }
            } catch (e: Exception) {
                result.error("ERROR", "Failed to delete file: ${e.message}", null)
            }
        } else {
            result.error("ERROR", "File path not provided", null)
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
        // Call the SpeedTestUtil to start the speed test
        SpeedTestUtil.startSpeedTest(applicationContext) { speedResult ->
            // Here, 'speedResult' now contains additional information like Wi-Fi SSID, mobile operator, and location
            // You can log or send this back as needed

            // Example of how you can handle the result
            if (speedResult.containsKey("error")) {
                result.error("SPEED_TEST_FAILED", speedResult["error"], null)
            } else {
                // Return the full result
                result.success(speedResult)
            }
        }
    } else {
        // Request permissions if not granted
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

    // Get video files from the device
private fun handleGetVideoFiles(result: MethodChannel.Result) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        val isGranted = Environment.isExternalStorageManager()
        if (isGranted) {
            val files = MediaInfo.getVideoFiles(this)
            result.success(files)
        } else {
            result.error("PERMISSION_DENIED", "Permission not granted for accessing all files", null)
        }
    } else {
        val files = MediaInfo.getVideoFiles(this)
        result.success(files)
    }
}

    // Get video files from the device
private fun handleGetAudioFiles(result: MethodChannel.Result) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        val isGranted = Environment.isExternalStorageManager()
        if (isGranted) {
            val files = MediaInfo.getAudioFiles(this)
            result.success(files)
        } else {
            result.error("PERMISSION_DENIED", "Permission not granted for accessing all files", null)
        }
    } else {
        val files = MediaInfo.getAudioFiles(this)
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

   private fun uninstallApp(context: Context, packageName: String) {
    val uninstallIntent = Intent(Intent.ACTION_UNINSTALL_PACKAGE)
    uninstallIntent.data = Uri.parse("package:$packageName")
    uninstallIntent.putExtra(Intent.EXTRA_RETURN_RESULT, true)

    // Using startActivityForResult to handle the result of uninstallation
    if (context is Activity) {
        context.startActivityForResult(uninstallIntent, REQUEST_CODE)
    } else {
        Log.e("AppInfo", "Context is not an Activity, cannot call startActivityForResult")
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
