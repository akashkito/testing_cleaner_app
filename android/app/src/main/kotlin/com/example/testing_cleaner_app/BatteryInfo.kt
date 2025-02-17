package com.example.testing_cleaner_app

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION_CODES
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter

object BatteryInfo {
    
    fun getBatteryLevel(context: Context): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(context.applicationContext).registerReceiver(
                null, 
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )
            intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)?.let { level ->
                level * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            } ?: -1
        }
    }

    fun getBatteryStatus(context: Context): String {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val status = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_STATUS)
        return when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
            BatteryManager.BATTERY_STATUS_FULL -> "Full"
            else -> "Not Charging"
        }
    }
}
