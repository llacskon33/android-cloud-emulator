package com.llacskon33.cloudemulator

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.google.android.material.button.MaterialButton
import com.google.android.material.materialswitch.MaterialSwitch
import com.google.android.material.textfield.TextInputEditText

class MainActivity : AppCompatActivity() {

    private enum class State(val label: Int, val color: Int) {
        DISCONNECTED(R.string.status_disconnected, 0xFF9E9E9E.toInt()),
        CONNECTING(R.string.status_connecting, 0xFFFFC107.toInt()),
        CONNECTED(R.string.status_connected, 0xFF3DDC84.toInt()),
        ERROR(R.string.status_error, 0xFFF44336.toInt()),
    }

    private lateinit var webView: WebView
    private lateinit var configPanel: View
    private lateinit var controls: View
    private lateinit var statusText: TextView
    private lateinit var hostInput: TextInputEditText
    private lateinit var portInput: TextInputEditText
    private lateinit var passwordInput: TextInputEditText
    private lateinit var httpsSwitch: MaterialSwitch
    private lateinit var settings: ConnectionSettings
    private var hadError = false

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        settings = ConnectionSettings(this)
        webView = findViewById(R.id.webView)
        configPanel = findViewById(R.id.configPanel)
        controls = findViewById(R.id.controls)
        statusText = findViewById(R.id.statusText)
        hostInput = findViewById(R.id.hostInput)
        portInput = findViewById(R.id.portInput)
        passwordInput = findViewById(R.id.passwordInput)
        httpsSwitch = findViewById(R.id.httpsSwitch)

        hostInput.setText(settings.host)
        portInput.setText(settings.port.toString())
        passwordInput.setText(settings.password)
        httpsSwitch.isChecked = settings.https

        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            useWideViewPort = true
            loadWithOverviewMode = true
            mediaPlaybackRequiresUserGesture = false
            allowFileAccess = false
            allowContentAccess = false
            cacheMode = WebSettings.LOAD_NO_CACHE
            mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
        }
        webView.isFocusable = true
        webView.isFocusableInTouchMode = true
        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {
                if (!hadError) setState(State.CONNECTING)
            }

            override fun onPageFinished(view: WebView, url: String?) {
                if (!hadError) setState(State.CONNECTED)
            }

            override fun onReceivedError(
                view: WebView,
                request: WebResourceRequest,
                error: WebResourceError,
            ) {
                if (request.isForMainFrame) {
                    hadError = true
                    setState(State.ERROR)
                }
            }
        }

        findViewById<MaterialButton>(R.id.connectButton).setOnClickListener { connect() }
        findViewById<MaterialButton>(R.id.disconnectButton).setOnClickListener { disconnect() }
        findViewById<MaterialButton>(R.id.refreshButton).setOnClickListener { reload() }

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                if (webView.visibility == View.VISIBLE) disconnect() else finish()
            }
        })

        if (savedInstanceState == null && settings.host.isNotBlank()) connect()
    }

    private fun connect() {
        val host = hostInput.text?.toString()?.trim().orEmpty()
            .removePrefix("http://").removePrefix("https://").trimEnd('/')
        val port = portInput.text?.toString()?.toIntOrNull()
        if (host.isEmpty() || host.any { it.isWhitespace() || it == '/' || it == '?' || it == '#' || it == '@' }) {
            hostInput.error = getString(R.string.error_host)
            return
        }
        if (port == null || port !in 1..65535) {
            portInput.error = getString(R.string.error_port)
            return
        }
        val password = passwordInput.text?.toString().orEmpty()
        settings.save(host, port, password, httpsSwitch.isChecked)

        hadError = false
        configPanel.visibility = View.GONE
        webView.visibility = View.VISIBLE
        controls.visibility = View.VISIBLE
        setFullscreen(true)
        webView.loadUrl(buildUrl(host, port, password, httpsSwitch.isChecked))
    }

    private fun buildUrl(host: String, port: Int, password: String, https: Boolean): String {
        val builder = Uri.Builder()
            .scheme(if (https) "https" else "http")
            .encodedAuthority(if (host.contains(':')) "[$host]:$port" else "$host:$port")
            .path("/vnc.html")
            .appendQueryParameter("autoconnect", "true")
            .appendQueryParameter("resize", "scale")
            .appendQueryParameter("reconnect", "true")
        if (password.isNotEmpty()) builder.appendQueryParameter("password", password)
        return builder.build().toString()
    }

    private fun disconnect() {
        webView.stopLoading()
        webView.loadUrl("about:blank")
        webView.visibility = View.GONE
        controls.visibility = View.GONE
        configPanel.visibility = View.VISIBLE
        setFullscreen(false)
        setState(State.DISCONNECTED)
    }

    private fun reload() {
        hadError = false
        val host = settings.host
        if (webView.url.isNullOrEmpty() || webView.url == "about:blank") {
            webView.loadUrl(buildUrl(host, settings.port, settings.password, settings.https))
        } else {
            webView.reload()
        }
    }

    private fun setState(state: State) {
        statusText.setText(state.label)
        statusText.setCompoundDrawablesRelativeWithIntrinsicBounds(
            dot(state.color), null, null, null,
        )
    }

    private fun dot(color: Int) = android.graphics.drawable.GradientDrawable().apply {
        shape = android.graphics.drawable.GradientDrawable.OVAL
        setColor(color)
        val size = (12 * resources.displayMetrics.density).toInt()
        setSize(size, size)
    }

    private fun setFullscreen(enabled: Boolean) {
        WindowCompat.setDecorFitsSystemWindows(window, !enabled)
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        if (enabled) {
            controller.systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            controller.hide(WindowInsetsCompat.Type.systemBars())
        } else {
            controller.show(WindowInsetsCompat.Type.systemBars())
        }
    }

    override fun onResume() {
        super.onResume()
        webView.onResume()
    }

    override fun onPause() {
        webView.onPause()
        super.onPause()
    }

    override fun onDestroy() {
        webView.destroy()
        super.onDestroy()
    }
}
