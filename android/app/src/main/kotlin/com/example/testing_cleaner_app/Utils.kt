package com.example.testing_cleaner_app

import java.io.File

object Utils {

    // Scan a directory for files and return their absolute paths
    fun scanDirectoryForFiles(directory: File): List<String> {
        val filesList = mutableListOf<String>()
        if (directory.exists() && directory.isDirectory) {
            directory.listFiles()?.forEach { file ->
                if (file.isFile) {
                    filesList.add(file.absolutePath)
                }
            }
        }
        return filesList
    }
}
