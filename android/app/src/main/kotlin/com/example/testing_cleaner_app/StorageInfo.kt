package com.example.testing_cleaner_app

import android.os.Environment
import android.os.StatFs

object StorageInfo {
    
    fun getStorageInfo(): Map<String, Long> {
        val storageInfo = mutableMapOf<String, Long>()
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.absolutePath)

        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        val availableBlocks = stat.availableBlocksLong

        storageInfo["total"] = blockSize * totalBlocks
        storageInfo["available"] = blockSize * availableBlocks

        return storageInfo
    }
}
