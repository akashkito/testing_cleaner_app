package com.example.testing_cleaner_app

import android.app.ActivityManager
import android.content.Context
import android.os.Environment
import android.os.StatFs

object MemoryInfo {

    fun getMemoryInfo(context: Context): Map<String, Any> {
        val memoryInfo = mutableMapOf<String, Any>()

        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfoDetails = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfoDetails)

        memoryInfo["totalRAM"] = memoryInfoDetails.totalMem
        memoryInfo["availableRAM"] = memoryInfoDetails.availMem
        memoryInfo["usedRAM"] = memoryInfoDetails.totalMem - memoryInfoDetails.availMem
        memoryInfo["ramPercentage"] = (memoryInfoDetails.availMem.toFloat() / memoryInfoDetails.totalMem.toFloat()) * 100

        val path = Environment.getDataDirectory()
        val stat = StatFs(path.absolutePath)

        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        val availableBlocks = stat.availableBlocksLong

        memoryInfo["totalROM"] = blockSize * totalBlocks
        memoryInfo["availableROM"] = blockSize * availableBlocks
        memoryInfo["usedROM"] = blockSize * (totalBlocks - availableBlocks)
        memoryInfo["romPercentage"] = (availableBlocks.toFloat() / totalBlocks.toFloat()) * 100

        return memoryInfo
    }
}
