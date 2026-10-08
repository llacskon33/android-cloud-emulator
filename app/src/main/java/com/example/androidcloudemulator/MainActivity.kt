package com.example.androidcloudemulator

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.androidcloudemulator.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.textView.text = "Android Cloud Emulator\nAPK generado correctamente"
    }
}
