package com.example.testing_cleaner_app

import java.io.File

object Utils {

    fun scanDirectoryForFiles(directory: File): List<String> {
        val filesList = mutableListOf<String>()
        if (directory.exists() && directory.isDirectory) {
            val files = directory.listFiles()
            if (files != null) {
                for (file in files) {
                    if (file.isFile && file.exists()) {
                        filesList.add(file.absolutePath)
                    }
                }
            }
        }
        return filesList
    }
}
