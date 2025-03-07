package com.example.testing_cleaner_app

import android.content.Context
import android.os.Environment
import java.io.File
import android.content.pm.PackageManager
import android.Manifest
import android.util.Log
import androidx.core.content.ContextCompat


object OtherFilesUtil {

    fun getOtherFiles(context: Context): List<File> {
        val fileList = mutableListOf<File>()

        // Check permission
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            Log.e("OtherFilesUtil", "Permission not granted")
            return fileList
        }

        // Use a known directory path for testing
        val rootDir = Environment.getExternalStorageDirectory()

        val extensionsToInclude = listOf("doc", "xls", "txt", "apk")
        val extensionsToExclude = listOf("mp3", "mp4", "png", "jpg")

        // Start scanning
        scanDirectory(rootDir, extensionsToInclude, extensionsToExclude, fileList)

        return fileList
    }

    private fun scanDirectory(dir: File, include: List<String>, exclude: List<String>, fileList: MutableList<File>) {
    if (dir.isDirectory) {
        Log.d("scanDirectory", "Scanning directory: ${dir.absolutePath}")
        val files = dir.listFiles()
        files?.forEach { file ->
            Log.d("scanDirectory", "Found file: ${file.name} - ${file.absolutePath}")
            if (file.isDirectory) {
                scanDirectory(file, include, exclude, fileList) // Recurse into subdirectories
            } else {
                val fileExtension = file.extension.lowercase()
                if (include.contains(fileExtension) && !exclude.contains(fileExtension)) {
                    Log.d("scanDirectory", "Adding file: ${file.name}")
                    fileList.add(file)
                }
            }
        }
    } else {
        Log.d("scanDirectory", "Not a directory: ${dir.absolutePath}")
    }
}


    // Helper function to get file extension
    private fun getFileExtension(file: File): String? {
        val fileName = file.name
        return if (fileName.contains(".")) {
            fileName.substring(fileName.lastIndexOf(".") + 1).lowercase()
        } else {
            null
        }
    }

    // Function to delete a file
    fun deleteOtherFile(file: File): Boolean {
        return try {
            if (file.exists()) {
                file.delete()
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }
}
