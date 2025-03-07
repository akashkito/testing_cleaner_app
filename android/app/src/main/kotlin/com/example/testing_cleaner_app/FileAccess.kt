package com.example.your_app_name

import android.content.Context
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FileItem class to hold the file details like name, size, and icon.
data class FileItem(
    val name: String,
    val size: Long,
    val icon: String,  // Path or resource name for the icon
    val path: String   // Full file path
)

class FileAccessPhone {

    companion object {

        private val CHUNK_SIZE = 50 // Number of files to load per request

        // Example of converting FileItem to a Map
        fun getFilesInDirectory(context: Context, directoryPath: String, offset: Int): List<Map<String, Any>> {
            val filesList = mutableListOf<Map<String, Any>>()
            val dir = File(directoryPath)

            // Log to check the directory being accessed
            println("Accessing directory: $directoryPath")

            // List of file extensions we are interested in
            val fileExtensions = listOf(".apk", ".jpg", ".jpeg", ".png", ".mp4", ".txt", ".pdf", ".mp3", ".tmp")

            if (dir.exists() && dir.isDirectory) {
                // Recursively search for files in this directory and its subdirectories
                searchFiles(dir, filesList, fileExtensions, offset)
            } else {
                println("Directory does not exist or is not a directory: $directoryPath")
            }

            println("Files found: ${filesList.size}")  // Log the number of files found
            return filesList
        }

        private fun searchFiles(dir: File, filesList: MutableList<Map<String, Any>>, extensions: List<String>, offset: Int) {
            val files = dir.listFiles()
            var counter = 0
            files?.forEach { file ->
                // Check if the file matches the desired file extensions
                if (counter >= offset && extensions.any { file.name.endsWith(it, ignoreCase = true) }) {
                    // Create a Map from the FileItem
                    val fileItemMap = mapOf(
                        "name" to file.name,
                        "size" to file.length(),
                        "icon" to getIconForFile(file), // Replace with your actual logic for getting an icon
                        "path" to file.absolutePath
                    )
                    filesList.add(fileItemMap)
                }
                if (file.isDirectory) {
                    searchFiles(file, filesList, extensions, offset)
                }
                counter++
                if (filesList.size >= CHUNK_SIZE) return // Stop once we reach the desired chunk size
            }
        }

        // Example method to get an icon for a file (you may need to implement this logic)
        private fun getIconForFile(file: File): String {
            return when {
                file.name.endsWith(".mp4", ignoreCase = true) -> "video_icon"
                file.name.endsWith(".mp3", ignoreCase = true) -> "audio_icon"
                file.name.endsWith(".jpg", ignoreCase = true) || file.name.endsWith(".jpeg", ignoreCase = true) -> "image_icon"
                else -> "default_icon"
            }
        }

        // Method to delete a file
        fun deleteFile(filePath: String): Boolean {
            val file = File(filePath)
            return if (file.exists()) {
                file.delete()
            } else {
                false
            }
        }

        // Method to check if permission is granted (to access external storage)
        fun isPermissionGranted(context: Context): Boolean {
            val permission = android.Manifest.permission.READ_EXTERNAL_STORAGE
            return ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
        }

        // Method to request permission (for Android 6.0+)
        fun requestPermission(context: Context, result: MethodChannel.Result) {
            val permission = android.Manifest.permission.READ_EXTERNAL_STORAGE
            if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                result.success(false)  // Indicating that the permission is not granted
            } else {
                result.success(true)  // Permission granted
            }
        }

        // Method to get special folders (including the new ones you requested)
        fun getSpecialFolders(context: Context): List<String> {
            val specialFolders = mutableListOf<String>()
            specialFolders.add("/storage/emulated/0/Download")  // Downloads
            specialFolders.add("/data/data/com.example.your_app_name/cache")  // Cache
            specialFolders.add("/data/data/com.example.your_app_name/.cache")  // Hidden Cache
            specialFolders.add("/data/app")  // APKs
            specialFolders.add("/storage/emulated/0/.thumbnails")  // Thumbnails
            specialFolders.add("/data/data/com.example.your_app_name/files/temporary")  // Temporary Files
            specialFolders.add("/storage/emulated/0/")  // General storage for large files
            specialFolders.add("/storage/emulated/0/")  // Empty folders
            specialFolders.add("/data/data/com.example.your_app_name/.residual")  // Junk or residual folders
            specialFolders.add("/storage/emulated/0/.junk")  // Junk
            return specialFolders
        }

        // Method to find empty directories within a given path
        fun findEmptyFolders(path: String): List<String> {
            val emptyFolders = mutableListOf<String>()
            val rootDir = File(path)
            if (rootDir.exists() && rootDir.isDirectory) {
                val directories = rootDir.listFiles { file -> file.isDirectory }
                directories?.forEach { dir ->
                    if (dir.list()?.isEmpty() == true) {
                        emptyFolders.add(dir.absolutePath)
                    }
                }
            }
            return emptyFolders
        }

        // Method to find large files (greater than a certain size) in a given path
        fun findLargeFiles(path: String, sizeLimit: Long): List<String> {
            val largeFiles = mutableListOf<String>()
            val rootDir = File(path)
            if (rootDir.exists() && rootDir.isDirectory) {
                val files = rootDir.listFiles { file -> file.isFile }
                files?.forEach { file ->
                    if (file.length() > sizeLimit) {
                        largeFiles.add(file.absolutePath)
                    }
                }
            }
            return largeFiles
        }

        // Method to get files that are larger than a given size (e.g., 50MB)
        fun getLargeFilesAboveSize(context: Context, sizeLimit: Long): List<Map<String, Any>> {
            val largeFilesList = mutableListOf<Map<String, Any>>()

            // Check each special folder for large files
            val specialFolders = getSpecialFolders(context)
            specialFolders.forEach { folderPath ->
                val largeFiles = findLargeFiles(folderPath, sizeLimit)
                largeFiles.forEach { filePath ->
                    val file = File(filePath)
                    largeFilesList.add(
                        mapOf(
                            "name" to file.name,
                            "size" to file.length(),
                            "icon" to getIconForFile(file),
                            "path" to file.absolutePath
                        )
                    )
                }
            }

            return largeFilesList
        }
    }
}
