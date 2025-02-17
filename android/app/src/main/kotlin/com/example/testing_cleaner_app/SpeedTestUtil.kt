package com.example.testing_cleaner_app

import android.os.AsyncTask
import java.net.URL
import java.io.BufferedInputStream
import java.net.HttpURLConnection
import java.io.OutputStream

object SpeedTestUtil {

    // Function to start speed test (both upload and download)
    fun startSpeedTest(callback: (String) -> Unit) {
        // Run async task to perform the speed test
        SpeedTestTask(callback).execute()
    }

    // AsyncTask for download speed testing
    private class SpeedTestTask(val callback: (String) -> Unit) : AsyncTask<Void, Void, String>() {

        override fun doInBackground(vararg params: Void?): String {
            var downloadSpeed = 0L
            var uploadSpeed = 0L
            val testDownloadUrl = "https://speed.hetzner.de/100MB.bin" // Example test URL for download
            val testUploadUrl = "https://youruploadserver.com/upload" // Replace with your server's upload endpoint
            
            try {
                // Download speed test
                val downloadUrl = URL(testDownloadUrl)
                val connection: HttpURLConnection = downloadUrl.openConnection() as HttpURLConnection
                connection.requestMethod = "GET"
                connection.setRequestProperty("User-Agent", "Mozilla/5.0")
                connection.connect()

                val inputStream = BufferedInputStream(connection.inputStream)
                val startTime = System.nanoTime()
                val buffer = ByteArray(1024)

                while (inputStream.read(buffer) != -1) {
                    // Simulate downloading file data
                }

                val endTime = System.nanoTime()
                downloadSpeed = (endTime - startTime) / 1000000 // Time in milliseconds for download

                // For upload speed, we simulate uploading a small file
                val uploadData = ByteArray(1024 * 10) // 10 KB of data to simulate upload
                val uploadStartTime = System.nanoTime()
                
                // Upload logic (you would need to replace the upload URL with your actual server endpoint)
                val uploadUrl = URL(testUploadUrl)
                val uploadConnection: HttpURLConnection = uploadUrl.openConnection() as HttpURLConnection
                uploadConnection.requestMethod = "POST"
                uploadConnection.setRequestProperty("Content-Type", "application/octet-stream")
                uploadConnection.doOutput = true
                val outputStream: OutputStream = uploadConnection.outputStream
                outputStream.write(uploadData)
                outputStream.flush()

                val uploadEndTime = System.nanoTime()
                uploadSpeed = (uploadEndTime - uploadStartTime) / 1000000 // Time in milliseconds for upload

            } catch (e: Exception) {
                e.printStackTrace()
                return "Speed test failed"
            }

            // Return formatted result
            return "Download Speed: ${downloadSpeed}ms\nUpload Speed: ${uploadSpeed}ms"
        }

        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)
            callback(result ?: "Speed test failed")
        }
    }
}
