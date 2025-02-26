package com.example.testing_cleaner_app

import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.util.Base64
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.File
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import android.net.Uri
import android.util.Log


const val REQUEST_CODE = 1001  // Define the request code for permission

object AppInfo {

    // Check and request necessary permissions
    fun checkAndRequestPermissions(activity: Activity) {
        val permissions = mutableListOf<String>()

        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
        }

        if (!isUsagePermissionGranted(activity)) {
            permissions.add(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
            permissions.add(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
        }

        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(activity, permissions.toTypedArray(), REQUEST_CODE)
        }
    }

    // Check if usage access permission is granted
    fun isUsagePermissionGranted(context: Context): Boolean {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - TimeUnit.DAYS.toMillis(1), time)
        return stats.isNotEmpty()
    }

    // Open usage access settings if permission is not granted
    fun openUsageAccessSettings(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        context.startActivity(intent)
    }

    // Show a dialog for Usage Access Permission
    fun showUsagePermissionDialog(activity: Activity) {
        val builder = android.app.AlertDialog.Builder(activity)
        builder.setTitle("Permission Required")
            .setMessage("This app requires usage access to show detailed app information. Please enable it in the settings.")
            .setPositiveButton("Go to Settings") { dialog, _ -> openUsageAccessSettings(activity) }
            .setNegativeButton("Cancel") { dialog, _ -> dialog.dismiss() }
        builder.create().show()
    }

    // Get installed apps with expanded size checks
    fun getInstalledApps(context: Context): List<Map<String, Any>> {
        val appsList = mutableListOf<Map<String, Any>>()
        val packageManager = context.packageManager

        val installedPackages = packageManager.getInstalledPackages(
            PackageManager.GET_META_DATA or
            PackageManager.GET_DISABLED_COMPONENTS or
            PackageManager.GET_SHARED_LIBRARY_FILES or
            PackageManager.GET_UNINSTALLED_PACKAGES
        )

        for (packageInfo in installedPackages) {
            val appName = packageInfo.applicationInfo?.loadLabel(packageManager)?.toString() ?: "Unknown"
            val packageName = packageInfo.packageName
            val versionName = packageInfo.versionName ?: "Unknown"
            val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode.toString()
            } else {
                packageInfo.versionCode.toString()
            }

            // File path and size calculation
            val appSourceDir = packageInfo.applicationInfo?.sourceDir ?: ""
            val installDate = getInstallDate(packageInfo.firstInstallTime)
            val lastUpdateDate = getInstallDate(packageInfo.lastUpdateTime)

            val appIconBase64 = getAppIcon(context, packageInfo.applicationInfo)

            val isSystemApp = packageInfo.applicationInfo?.flags?.and(ApplicationInfo.FLAG_SYSTEM) != 0
            val isDisabled = packageManager.getApplicationEnabledSetting(packageInfo.packageName) == PackageManager.COMPONENT_ENABLED_STATE_DISABLED

            // Fix for app size, data size, cache size with logging
            val appSize = getAppSize(appSourceDir)
            val dataSize = getDataSize(packageName, context)
            val cacheSize = getCacheSize(context, packageName)

            // Log sizes for debugging purposes
            Log.d("AppInfo", "App: $appName, APK Size: $appSize, Data Size: $dataSize, Cache Size: $cacheSize")

            // Total size: Sum of app size, data size, and cache size
            val totalSize = appSize + dataSize + cacheSize

            // Add each app info to the list
            appsList.add(
                mapOf(
                    "appName" to appName,
                    "packageName" to packageName,
                    "versionName" to versionName,
                    "versionCode" to versionCode,
                    "installDate" to installDate,
                    "lastUpdateDate" to lastUpdateDate,
                    "appIcon" to appIconBase64,
                    "storage" to mapOf(
                        "app" to appSize,
                        "data" to dataSize,
                        "cache" to cacheSize,
                        "totalAppSize" to totalSize
                    ),
                    "uninstallIntent" to "package:$packageName",
                    "isSystemApp" to isSystemApp,
                    "isDisabled" to isDisabled
                )
            )
        }

        return appsList
    }

    // Helper method to get app size (APK size)
    fun getAppSize(appSourceDir: String): Long {
        val appFile = File(appSourceDir)
        return if (appFile.exists()) appFile.length() else 0L
    }

    // Helper method to calculate data size
    fun getDataSize(packageName: String, context: Context): Long {
        val dataDir = File("/data/data/$packageName")
        return if (dataDir.exists()) getFolderSize(dataDir) else 0L
    }

    fun getCacheSize(context: Context, packageName: String): Long {
    try {
        val cacheDir = File(context.cacheDir, packageName)
        if (cacheDir.exists()) {
            Log.d("Cache Access", "Cache directory exists: ${cacheDir.path}")
            return getDirectorySize(cacheDir)
        } else {
            Log.d("Cache Access", "Cache directory does not exist: ${cacheDir.path}")
        }
    } catch (e: Exception) {
        e.printStackTrace()
    }
    return 0
}


    // Helper method to calculate directory size (recursive)
    fun getDirectorySize(file: File): Long {
        var size = 0L
        if (file.exists()) {
            val files = file.listFiles()
            if (files != null) {
                for (f in files) {
                    size += if (f.isDirectory) {
                        getDirectorySize(f)
                    } else {
                        f.length()
                    }
                }
            }
        }
        return size
    }

    // Helper method to calculate folder size (recursive)
    fun getFolderSize(file: File): Long {
        var size: Long = 0
        file.listFiles()?.forEach {
            size += if (it.isDirectory) getFolderSize(it) else it.length()
        }
        return size
    }

    // Get install date in readable format
    fun getInstallDate(timeInMillis: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        return sdf.format(Date(timeInMillis))
    }

    // Force Stop an app
    fun forceStopApp(context: Context, packageName: String) {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        try {
            activityManager.killBackgroundProcesses(packageName)
            println("App $packageName force stopped successfully.")
        } catch (e: Exception) {
            println("Failed to force stop app $packageName: ${e.message}")
        }
    }

    // Uninstall an app
    fun uninstallApp(context: Context, packageName: String) {
        val uninstallIntent = Intent(Intent.ACTION_UNINSTALL_PACKAGE)
        uninstallIntent.data = Uri.parse("package:$packageName")
        uninstallIntent.putExtra(Intent.EXTRA_RETURN_RESULT, true)
        context.startActivity(uninstallIntent)
    }

    // Get app icon in Base64 format
    private fun getAppIcon(context: Context, appInfo: ApplicationInfo?): String {
        return try {
            val icon = appInfo?.loadIcon(context.packageManager)
            val bitmap = (icon as android.graphics.drawable.BitmapDrawable).bitmap
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            Base64.encodeToString(byteArray, Base64.DEFAULT)
        } catch (e: Exception) {
            ""
        }
    }

    // Get app usage stats (screen time)
    fun getAppUsageStats(context: Context) {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()

        if (!isUsagePermissionGranted(context)) {
            println("Usage access permission is not granted.")
            return
        }

        // Query usage stats for the past 7 days
        val appStats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_WEEKLY,
            time - TimeUnit.DAYS.toMillis(7),
            time
        )

        if (appStats.isEmpty()) {
            println("No usage stats found.")
            return
        }

        // Process and print the app usage stats
        appStats.forEach { usageStats ->
            val lastUsed = usageStats.lastTimeUsed
            val totalTime = usageStats.totalTimeInForeground
            val formattedTime = formatDuration(totalTime)

            println("Package: ${usageStats.packageName}, Last Used: $lastUsed, Total Time: $formattedTime")
        }
    }

    // Format duration in hours, minutes, seconds
    fun formatDuration(durationMillis: Long): String {
        val hours = TimeUnit.MILLISECONDS.toHours(durationMillis)
        val minutes = TimeUnit.MILLISECONDS.toMinutes(durationMillis) % 60
        val seconds = TimeUnit.MILLISECONDS.toSeconds(durationMillis) % 60
        return String.format("%02d:%02d:%02d", hours, minutes, seconds)
    }
}
