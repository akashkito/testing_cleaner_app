package com.example.testing_cleaner_app

import android.content.Context
import android.net.wifi.WifiManager

object WifiInfo {

    fun getWifiInfo(context: Context): Map<String, String> {
        val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val wifiInfo = wifiManager.connectionInfo
        val wifiDetails = mutableMapOf<String, String>()
        
        wifiDetails["SSID"] = wifiInfo.ssid
        wifiDetails["MAC"] = wifiInfo.macAddress

        val ipAddress = wifiInfo.ipAddress
        val formattedIp = String.format(
            "%d.%d.%d.%d",
            (ipAddress and 0xFF),
            (ipAddress shr 8 and 0xFF),
            (ipAddress shr 16 and 0xFF),
            (ipAddress shr 24 and 0xFF)
        )
        wifiDetails["IP"] = formattedIp
        
        return wifiDetails
    }
}
