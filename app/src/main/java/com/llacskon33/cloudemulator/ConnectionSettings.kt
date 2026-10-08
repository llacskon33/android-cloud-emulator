package com.llacskon33.cloudemulator

import android.content.Context

class ConnectionSettings(context: Context) {
    private val prefs = context.getSharedPreferences("connection", Context.MODE_PRIVATE)

    val host: String get() = prefs.getString(KEY_HOST, "").orEmpty()
    val port: Int get() = prefs.getInt(KEY_PORT, DEFAULT_PORT)
    val password: String get() = prefs.getString(KEY_PASSWORD, "").orEmpty()
    val https: Boolean get() = prefs.getBoolean(KEY_HTTPS, false)

    fun save(host: String, port: Int, password: String, https: Boolean) {
        prefs.edit()
            .putString(KEY_HOST, host)
            .putInt(KEY_PORT, port)
            .putString(KEY_PASSWORD, password)
            .putBoolean(KEY_HTTPS, https)
            .apply()
    }

    companion object {
        const val DEFAULT_PORT = 6080
        private const val KEY_HOST = "host"
        private const val KEY_PORT = "port"
        private const val KEY_PASSWORD = "password"
        private const val KEY_HTTPS = "https"
    }
}
