package com.example.testing_cleaner_app

import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import android.app.Activity
import android.content.ContentResolver
import android.net.Uri
import android.util.Log
import java.io.File
import android.content.ContentUris
import android.content.Context
import android.graphics.Bitmap
import android.provider.MediaStore.Video.Thumbnails
import androidx.annotation.RequiresApi
import android.graphics.BitmapFactory
import java.io.FileOutputStream
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.widget.ImageView
import com.bumptech.glide.load.engine.DiskCacheStrategy


object MediaInfo {

    // Data class to store media details for photos, videos, and audios
    data class MediaFile(val path: String, val name: String, val size: Long, val date: Long)

    // Generic function to fetch files from MediaStore based on type
    private fun getFilesFromMediaStore(activity: Activity, mediaUri: Uri, fileType: String): List<String> {
        val files = mutableListOf<String>()
        val resolver: ContentResolver = activity.contentResolver
        val projection = arrayOf(MediaStore.Files.FileColumns.DATA)
        val cursor = resolver.query(mediaUri, projection, null, null, null)

        cursor?.use {
            val columnIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATA)
            while (it.moveToNext()) {
                val filePath = it.getString(columnIndex)
                if (filePath.endsWith(fileType)) {
                    files.add(filePath)
                }
            }
        }
        return files
    }

    // Fetch photo files from MediaStore
    fun getPhotoFiles(activity: Activity): List<Map<String, Any>> {
        val files = mutableListOf<Map<String, Any>>()
        val resolver: ContentResolver = activity.contentResolver
        val projection = arrayOf(
            MediaStore.Images.Media._ID,  
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.DATE_ADDED
        )
        val cursor = resolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection, null, null, null
        )

        cursor?.use {
            val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val nameColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val sizeColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val dateColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)

            while (it.moveToNext()) {
                val id = it.getLong(idColumnIndex)
                val name = it.getString(nameColumnIndex)
                val size = it.getLong(sizeColumnIndex)
                val date = it.getLong(dateColumnIndex)

                val photoUri: Uri = ContentUris.withAppendedId(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id
                )
                val path = getFilePathFromUri(activity, photoUri)

                if (path != null) {
                    val photoFile = mapOf(
                        "path" to path,
                        "name" to name,
                        "size" to size,
                        "date" to date
                    )
                    files.add(photoFile)
                }
            }
        }
        return files
    }

    // Scale the image to a smaller size for efficient memory usage
    // Use BitmapFactory Options to downscale large images
fun loadImageScaled(activity: Activity, uri: Uri): Bitmap? {
    val resolver: ContentResolver = activity.contentResolver
    val options = BitmapFactory.Options().apply {
        inJustDecodeBounds = true
    }

    resolver.openInputStream(uri)?.use { inputStream ->
        BitmapFactory.decodeStream(inputStream, null, options)
    }

    Log.d("MediaInfo", "Video URI: $uri")

    // Scale the image efficiently based on required size
    val scaleFactor = calculateInSampleSize(options, 100, 100) // Scale to 100x100 pixels
    options.inJustDecodeBounds = false
    options.inSampleSize = scaleFactor

    resolver.openInputStream(uri)?.use { inputStream ->
        return BitmapFactory.decodeStream(inputStream, null, options)
    }

    return null
}

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2

            while ((halfHeight / inSampleSize) > reqHeight && (halfWidth / inSampleSize) > reqWidth) {
                inSampleSize *= 2
            }
        }

        return inSampleSize
    }

    fun deletePhoto(activity: Activity, photoPath: String) {
        try {
            // Get the URI for the photo using MediaStore
            val resolver: ContentResolver = activity.contentResolver
            val uri = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)

            // Query to find the photo's ID using the file path
            val selection = MediaStore.Images.Media.DATA + " = ?"
            val selectionArgs = arrayOf(photoPath)
            val cursor = resolver.query(uri, null, selection, selectionArgs, null)

            cursor?.use {
                if (it.moveToFirst()) {
                    val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                    val photoId = it.getLong(idColumnIndex)
                    val photoUri = ContentUris.withAppendedId(uri, photoId)

                    // Now delete the photo using the URI
                    val rowsDeleted = resolver.delete(photoUri, null, null)
                    if (rowsDeleted > 0) {
                        Log.d("MediaInfo", "Photo deleted successfully.")
                    } else {
                        Log.e("MediaInfo", "Failed to delete photo.")
                    }
                } else {
                    Log.e("MediaInfo", "Photo not found in MediaStore.")
                }
            }
        } catch (e: Exception) {
            Log.e("Error", "Error deleting photo: ${e.message}")
        }
    }

    // Fetch audio files from MediaStore
    fun getAudioFiles(activity: Activity): List<Map<String, Any>> {
        val files = mutableListOf<Map<String, Any>>()
        val resolver: ContentResolver = activity.contentResolver
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATE_ADDED
        )
        val cursor = resolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection, null, null, null
        )

        cursor?.use {
            val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val nameColumnIndex = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
            val sizeColumnIndex = it.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val dateColumnIndex = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)

            while (it.moveToNext()) {
                val id = it.getLong(idColumnIndex)
                val name = it.getString(nameColumnIndex)
                val size = it.getLong(sizeColumnIndex)
                val date = it.getLong(dateColumnIndex)

                val audioUri: Uri = ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id
                )
                val path = getFilePathFromUri(activity, audioUri)

                if (path != null) {
                    val audioFile = mapOf(
                        "path" to path,
                        "name" to name,
                        "size" to size,
                        "date" to date
                    )
                    files.add(audioFile)
                }
            }
        }
        return files
    }

    fun deleteAudio(activity: Activity, audioPath: String) {
        try {
            // Get the URI for the audio using MediaStore
            val resolver: ContentResolver = activity.contentResolver
            val uri = MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)

            // Query to find the audio's ID using the file path
            val selection = MediaStore.Audio.Media.DATA + " = ?"
            val selectionArgs = arrayOf(audioPath)
            val cursor = resolver.query(uri, null, selection, selectionArgs, null)

            cursor?.use {
                if (it.moveToFirst()) {
                    val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                    val audioId = it.getLong(idColumnIndex)
                    val audioUri = ContentUris.withAppendedId(uri, audioId)

                    // Now delete the audio using the URI
                    val rowsDeleted = resolver.delete(audioUri, null, null)
                    if (rowsDeleted > 0) {
                        Log.d("MediaInfo", "Audio deleted successfully.")
                    } else {
                        Log.e("MediaInfo", "Failed to delete audio.")
                    }
                } else {
                    Log.e("MediaInfo", "Audio not found in MediaStore.")
                }
            }
        } catch (e: Exception) {
            Log.e("Error", "Error deleting audio: ${e.message}")
        }
    }

    // Fetch video files from MediaStore
    @RequiresApi(Build.VERSION_CODES.Q)
fun getVideoFiles(activity: Activity): List<Map<String, Any?>> {
    val files = mutableListOf<Map<String, Any?>>()
    val resolver: ContentResolver = activity.contentResolver

    // Define the projection (columns to fetch)
    val projection = arrayOf(
        MediaStore.Video.Media._ID,
        MediaStore.Video.Media.DISPLAY_NAME,
        MediaStore.Video.Media.SIZE,
        MediaStore.Video.Media.DATE_ADDED
    )

    // Optional: limit number of items to avoid fetching all at once
    val selection = "${MediaStore.Video.Media.MIME_TYPE} LIKE ?"
    val selectionArgs = arrayOf("video/mp4") // Filter for .mp4 videos

    // Query to fetch video files (this can be paginated with a LIMIT clause)
    val cursor = resolver.query(
        MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
        projection,
        selection,
        selectionArgs,
        null // Here, you can add ordering, e.g., ORDER BY date or name
    )

    cursor?.use {
        val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
        val nameColumnIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
        val sizeColumnIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
        val dateColumnIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED)

        while (it.moveToNext()) {
            val id = it.getLong(idColumnIndex)
            val name = it.getString(nameColumnIndex)
            val size = it.getLong(sizeColumnIndex)
            val date = it.getLong(dateColumnIndex)

            val videoUri: Uri = ContentUris.withAppendedId(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id
            )
            val path = getFilePathFromUri(activity, videoUri)

            // Load the thumbnail using Glide
            val imageView = ImageView(activity)  // Assuming you have an ImageView to show the thumbnail
            loadVideoThumbnailUsingGlide(activity, videoUri, imageView)

            // Ensure thumbnail generation if needed and add to data
            val thumbnailPath = getVideoThumbnail(activity, videoUri)

            if (path != null) {
                val videoFile = mapOf<String, Any?>(
                    "path" to path,
                    "name" to name,
                    "size" to size,
                    "date" to date,
                    "thumbnail" to thumbnailPath // Add thumbnail path to the data
                )
                files.add(videoFile)
            }
        }
    }

    return files
}


    @RequiresApi(Build.VERSION_CODES.Q)
fun getVideoThumbnail(activity: Activity, uri: Uri): String? {
    val resolver: ContentResolver = activity.contentResolver
    val videoId = ContentUris.parseId(uri)

    // Check if the videoId is valid
    if (videoId == -1L) {
        Log.e("MediaInfo", "Invalid video ID")
        return null
    }

    try {
        // Try to get the thumbnail bitmap
        val thumbnailBitmap: Bitmap? = MediaStore.Video.Thumbnails.getThumbnail(
            resolver,
            videoId,
            MediaStore.Video.Thumbnails.MINI_KIND,
            null
        )

        // Check if the thumbnail was generated successfully
        if (thumbnailBitmap != null) {
            val tempFile = File(activity.cacheDir, "video_thumbnail_${System.currentTimeMillis()}.jpg")
            val outputStream = FileOutputStream(tempFile)
            thumbnailBitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
            outputStream.flush()
            outputStream.close()

            return tempFile.absolutePath // Return the path of the generated thumbnail
        } else {
            Log.e("MediaInfo", "Thumbnail is null.")
        }
    } catch (e: Exception) {
        Log.e("Error", "Error generating thumbnail: ${e.message}")
    }

    return null
}


   fun loadVideoThumbnail(activity: Activity, uri: Uri, imageView: ImageView) {
    Glide.with(activity)
        .load(uri)
        .apply(RequestOptions().override(100, 100))  // Resize the thumbnail to 100x100 pixels for memory efficiency
        .diskCacheStrategy(DiskCacheStrategy.ALL)  // Cache the thumbnail
        .into(imageView)
}

fun loadVideoThumbnailUsingGlide(activity: Activity, uri: Uri, imageView: ImageView) {
    Glide.with(activity)
        .load(uri) // Glide will automatically handle video thumbnail generation
        .apply(RequestOptions().override(100, 100)) // Resize the thumbnail to 100x100
        .diskCacheStrategy(DiskCacheStrategy.ALL) // Cache images
        .into(imageView)
}

    // Fetch video files asynchronously
    fun fetchVideoFilesAsync(activity: Activity) {
        CoroutineScope(Dispatchers.IO).launch {
            val files = getVideoFiles(activity)  // Your video fetching function
            withContext(Dispatchers.Main) {
                // Update UI with video data here
            }
        }
    }

    // Delete video method
    fun deleteVideo(activity: Activity, videoPath: String) {
        try {
            // Get the URI for the video using MediaStore
            val resolver: ContentResolver = activity.contentResolver
            val uri = MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)

            // Query to find the video's ID using the file path
            val selection = MediaStore.Video.Media.DATA + " = ?"
            val selectionArgs = arrayOf(videoPath)
            val cursor = resolver.query(uri, null, selection, selectionArgs, null)

            cursor?.use {
                if (it.moveToFirst()) {
                    val idColumnIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                    val videoId = it.getLong(idColumnIndex)
                    val videoUri = ContentUris.withAppendedId(uri, videoId)

                    // Now delete the video using the URI
                    val rowsDeleted = resolver.delete(videoUri, null, null)
                    if (rowsDeleted > 0) {
                        Log.d("MediaInfo", "Video deleted successfully.")
                    } else {
                        Log.e("MediaInfo", "Failed to delete video.")
                    }
                } else {
                    Log.e("MediaInfo", "Video not found in MediaStore.")
                }
            }
        } catch (e: Exception) {
            Log.e("Error", "Error deleting video: ${e.message}")
        }
    }

    // Get file path from URI (works for images, videos, and audios)
    fun getFilePathFromUri(activity: Activity, uri: Uri): String? {
        val cursor = activity.contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            val columnIndex: Int = when {
                uri.toString().contains("images") -> it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                uri.toString().contains("video") -> it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                uri.toString().contains("audio") -> it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                else -> return null // Return null if not image, video, or audio
            }
            if (it.moveToFirst()) {
                return it.getString(columnIndex)
            }
        }
        return null
    }

    // Check if permission is granted
    fun isPermissionGranted(activity: Activity): Boolean {
        return ContextCompat.checkSelfPermission(activity, android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
    }

    // Request permissions if not granted
    private fun requestPermissions(activity: Activity) {
        ActivityCompat.requestPermissions(activity, arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE), 1)
    }

    // Handle the result of permission request
    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode == 1 && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            Log.d("Permissions", "Permission granted.")
        } else {
            Log.d("Permissions", "Permission denied.")
        }
    }
}
