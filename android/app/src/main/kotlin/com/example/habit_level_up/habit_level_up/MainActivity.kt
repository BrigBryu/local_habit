package com.example.habit_level_up.habit_level_up

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Disable EGL emulation debug logging
        System.setProperty("debug.egl.profiler", "0")
        System.setProperty("debug.egl.trace", "0")
        System.setProperty("debug.egl.debug_proc", "0")
        
        super.onCreate(savedInstanceState)
    }
}
