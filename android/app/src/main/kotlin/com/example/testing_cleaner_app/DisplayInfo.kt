package com.example.testing_cleaner_app

import android.content.Context
import android.util.DisplayMetrics
import android.view.WindowManager

object DisplayInfo {

    fun getScreenResolution(context: Context): Map<String, Int> {
        val displayMetrics = DisplayMetrics()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getMetrics(displayMetrics)

        return mapOf(
            "width" to displayMetrics.widthPixels,
            "height" to displayMetrics.heightPixels
        )
    }

    fun getScreenSize(context: Context): Double {
        val displayMetrics = DisplayMetrics()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getMetrics(displayMetrics)

        val densityDpi = displayMetrics.densityDpi.toDouble()
        val widthInches = displayMetrics.widthPixels.toDouble() / densityDpi
        val heightInches = displayMetrics.heightPixels.toDouble() / densityDpi

        return Math.sqrt(widthInches * widthInches + heightInches * heightInches)
    }
}
