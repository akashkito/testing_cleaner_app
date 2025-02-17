package com.example.testing_cleaner_app

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager

object CameraInfo {

    fun getCameraInfo(context: Context): Map<String, Any> {
        val cameraInfo = mutableMapOf<String, Any>()
        val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val cameraList = mutableListOf<Map<String, String>>()

        try {
            val cameraIdList = cameraManager.cameraIdList
            for (cameraId in cameraIdList) {
                val characteristics = cameraManager.getCameraCharacteristics(cameraId)
                val cameraType = characteristics.get(CameraCharacteristics.LENS_FACING)
                val resolution = characteristics.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE)

                // Creating a map to hold the camera details as simple serializable types
                val cameraDetails = mapOf(
                    "cameraId" to cameraId,
                    "type" to if (cameraType == CameraCharacteristics.LENS_FACING_FRONT) "Front" else "Rear",
                    "resolution" to (resolution?.toString() ?: "Unknown")
                )

                // Adding the camera details to the list
                cameraList.add(cameraDetails)
            }
        } catch (e: Exception) {
            cameraInfo["error"] = e.localizedMessage
        }

        // Storing the list of camera details in the cameraInfo map
        cameraInfo["cameras"] = cameraList
        return cameraInfo
    }
}
