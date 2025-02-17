package com.example.testing_cleaner_app

import android.content.Context
import java.io.File

// Get Junk Files
fun getJunkFiles(context: Context): List<String> {
    val junkFiles = mutableListOf<String>()

    // Get Cache Files (Internal Cache)
    val cacheDir = context.cacheDir
    junkFiles.addAll(scanDirectoryForJunk(cacheDir))

    // Get Cache Files (External Cache)
    val externalCacheDir = context.externalCacheDir
    if (externalCacheDir != null) {
        junkFiles.addAll(scanDirectoryForJunk(externalCacheDir))
    }

    // Optionally, you can add other directories for residual files or temp files

    return junkFiles
}

// Helper method to scan a directory for files (cache, temporary files)
fun scanDirectoryForJunk(directory: File): List<String> {
    val junkFiles = mutableListOf<String>()

    if (directory.exists() && directory.isDirectory) {
        val files = directory.listFiles()
        if (files != null) {
            for (file in files) {
                if (file.isFile && file.exists()) {
                    junkFiles.add(file.absolutePath)
                }
            }
        }
    }

    return junkFiles
}
