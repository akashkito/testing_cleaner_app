package com.example.testing_cleaner_app

import android.os.Build
import android.util.Log
import java.io.BufferedReader
import java.io.FileReader

object ProcessorInfo {

    fun getProcessorInfo(): Map<String, Any> {
        val processorInfo = mutableMapOf<String, Any>()

        try {
            val cpuModel = try {
                val reader = BufferedReader(FileReader("/proc/cpuinfo"))
                var line: String?
                var cpuModel = ""
                while (reader.readLine().also { line = it } != null) {
                    if (line!!.contains("model name")) {
                        cpuModel = line!!.split(":")[1].trim()
                        break
                    }
                }
                reader.close()
                cpuModel
            } catch (e: Exception) {
                Log.e("ProcessorInfo", "Error reading CPU model", e)
                "Unknown"
            }

            val numCores = Runtime.getRuntime().availableProcessors()
            val cpuArchitecture = Build.SUPPORTED_ABIS.joinToString(", ")

            processorInfo["cpuModel"] = cpuModel
            processorInfo["numCores"] = numCores
            processorInfo["cpuArchitecture"] = cpuArchitecture
        } catch (e: Exception) {
            Log.e("ProcessorInfo", "Error fetching processor info", e)
            processorInfo["error"] = e.localizedMessage
        }

        return processorInfo
    }
}
