package com.example.testing_cleaner_app

import android.os.Build
import android.provider.Settings
import android.content.Context
import android.util.DisplayMetrics
import android.view.WindowManager
import kotlin.math.sqrt

object DeviceInfo {

    fun getDeviceDetails(context: Context): Map<String, Any> {
        val deviceDetails = mutableMapOf<String, Any>()
        deviceDetails["screenResolution"] = DisplayInfo.getScreenResolution(context)
        deviceDetails["screenSize"] = DisplayInfo.getScreenSize(context)
        deviceDetails["androidID"] = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
        deviceDetails["androidVersion"] = Build.VERSION.RELEASE
        deviceDetails["deviceInfo"] = mapOf(
            "model" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "hardware" to Build.HARDWARE
        )

        return deviceDetails
    }
}
