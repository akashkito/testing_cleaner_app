package com.example.testing_cleaner_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.TrafficStats
import androidx.core.app.ActivityCompat
import kotlin.concurrent.thread

object SpeedTestUtil {

    // Start the speed test process
    fun startSpeedTest(context: Context, callback: (speedResult: Map<String, String>) -> Unit) {
        // Check permissions before proceeding with the speed test
        if (checkPermissions(context)) {
            // Proceed with speed test
            performSpeedTest(context, callback)
        } else {
            // Permissions not granted, callback with error message
            callback(mapOf("error" to "Permissions not granted"))
        }
    }

    // Check if required permissions are granted
    private fun checkPermissions(context: Context): Boolean {
        // Check ACCESS_FINE_LOCATION and ACCESS_NETWORK_STATE permissions
        val locationPermission = ActivityCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        )
        val networkPermission = ActivityCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_NETWORK_STATE
        )
        return locationPermission == PackageManager.PERMISSION_GRANTED &&
                networkPermission == PackageManager.PERMISSION_GRANTED
    }

    // Perform the speed test if permissions are granted
    private fun performSpeedTest(context: Context, callback: (speedResult: Map<String, String>) -> Unit) {
        thread {
            try {
                // Get the initial traffic statistics
                val initialBytesReceived = TrafficStats.getTotalRxBytes()
                val initialBytesSent = TrafficStats.getTotalTxBytes()

                // Wait for 1 second (or you can customize this time period)
                Thread.sleep(1000)

                // Get the traffic stats after 1 second
                val finalBytesReceived = TrafficStats.getTotalRxBytes()
                val finalBytesSent = TrafficStats.getTotalTxBytes()

                // Calculate the download/upload speeds
                val downloadSpeed = (finalBytesReceived - initialBytesReceived) / 1024.0 / 1024.0 // in Mbps
                val uploadSpeed = (finalBytesSent - initialBytesSent) / 1024.0 / 1024.0 // in Mbps

                // Get the network type (Wi-Fi or mobile data)
                val networkType = getNetworkType(context)

                // Prepare the result
                val speedResult = mapOf(
                    "download" to String.format("%.2f Mbps", downloadSpeed),
                    "upload" to String.format("%.2f Mbps", uploadSpeed),
                    "networkType" to networkType
                )

                // Send the result back via callback
                callback(speedResult)
            } catch (e: Exception) {
                e.printStackTrace()
                callback(mapOf("error" to "Speed test failed: ${e.localizedMessage}"))
            }
        }
    }

    // Get the network type (Wi-Fi or Mobile)
    private fun getNetworkType(context: Context): String {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val activeNetwork = connectivityManager.activeNetwork
        val networkCapabilities = connectivityManager.getNetworkCapabilities(activeNetwork)

        return when {
            networkCapabilities == null -> "No Network"
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "Wi-Fi"
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Mobile Data"
            else -> "Unknown"
        }
    }
}