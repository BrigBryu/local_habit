package com.example.habit_level_up.habit_level_up

import android.app.Application
import android.util.Log

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Disable EGL emulation debug logging
        try {
            System.setProperty("debug.egl.profiler", "0")
            System.setProperty("debug.egl.trace", "0")
            System.setProperty("debug.egl.debug_proc", "0")
            System.setProperty("debug.egl.callstack", "0")
            
            // Also try to disable OpenGL debug
            System.setProperty("debug.opengl.trace", "0")
            System.setProperty("debug.opengl.debug_proc", "0")
            
            // Disable graphics debug in general
            System.setProperty("debug.graphics", "0")
            
            Log.d("MainApplication", "EGL debug logging disabled")
        } catch (e: Exception) {
            Log.w("MainApplication", "Failed to disable EGL debug logging", e)
        }
    }
}