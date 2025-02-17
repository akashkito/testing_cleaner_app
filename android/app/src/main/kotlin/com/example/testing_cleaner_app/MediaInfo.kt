package com.example.testing_cleaner_app

import android.os.Environment
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import android.app.Activity
import java.io.File

object MediaInfo {

    fun getAudioFiles(activity: Activity): List<String> {
        val audioFiles = mutableListOf<String>()
        if (isPermissionGranted(activity)) {
            val musicDir = File(Environment.getExternalStorageDirectory().toString() + "/Music")
            audioFiles.addAll(scanDirectoryForMediaFiles(musicDir))
        } else {
            requestPermissions(activity)
        }
        return audioFiles
    }

    fun getPhotoFiles(activity: Activity): List<String> {
        val photoFiles = mutableListOf<String>()
        if (isPermissionGranted(activity)) {
            val photosDirectory = File(Environment.getExternalStorageDirectory().toString() + "/DCIM/Camera")
            if (photosDirectory.exists() && photosDirectory.isDirectory) {
                val files = photosDirectory.listFiles()
                files?.forEach { file ->
                    if (file.isFile && (file.name.endsWith(".jpg") || file.name.endsWith(".png"))) {
                        photoFiles.add(file.absolutePath)
                    }
                }
            }
        } else {
            requestPermissions(activity)
        }
        return photoFiles
    }

    fun getVideoFiles(activity: Activity): List<String> {
        val videoFiles = mutableListOf<String>()
        if (isPermissionGranted(activity)) {
            val videoDir = File(Environment.getExternalStorageDirectory().toString() + "/Movies")
            videoFiles.addAll(scanDirectoryForMediaFiles(videoDir))
        } else {
            requestPermissions(activity)
        }
        return videoFiles
    }

    private fun scanDirectoryForMediaFiles(directory: File): List<String> {
        val mediaFiles = mutableListOf<String>()
        if (directory.exists() && directory.isDirectory) {
            val files = directory.listFiles()
            files?.forEach { file ->
                if (file.isFile && file.exists()) {
                    mediaFiles.add(file.absolutePath)
                }
            }
        }
        return mediaFiles
    }

    // Check if permission is granted
    private fun isPermissionGranted(activity: Activity): Boolean {
        return (ContextCompat.checkSelfPermission(activity, android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)
    }

    // Request permissions if not granted
    private fun requestPermissions(activity: Activity) {
        ActivityCompat.requestPermissions(activity, arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE), 1)
    }
}
