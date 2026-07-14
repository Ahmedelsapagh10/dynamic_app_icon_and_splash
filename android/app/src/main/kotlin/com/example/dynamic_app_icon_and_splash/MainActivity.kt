package com.example.dynamic_app_icon_and_splash

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "dynamic_app_icon_and_splash/dynamic_app_icon"

    private val supportedAliases = mapOf(
        "default" to "com.example.dynamic_app_icon_and_splash.DefaultIcon",
        "ramadan" to "com.example.dynamic_app_icon_and_splash.RamadanIcon",
        "white_friday" to "com.example.dynamic_app_icon_and_splash.WhiteFridayIcon",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setIcon" -> handleSetIcon(call, result)
                "getCurrentIcon" -> result.success(getCurrentIcon())
                else -> result.notImplemented()
            }
        }
    }

    private fun handleSetIcon(call: MethodCall, result: MethodChannel.Result) {
        val requestedIcon = call.argument<String>("iconName")?.trim()?.lowercase() ?: "default"
        val targetAlias = supportedAliases[requestedIcon]

        if (targetAlias == null) {
            result.error("unsupported_icon", "Unsupported icon key: $requestedIcon", null)
            return
        }

        supportedAliases.values.forEach { alias ->
            setComponentEnabled(alias, alias == targetAlias)
        }

        result.success(true)
    }

    private fun getCurrentIcon(): String {
        supportedAliases.forEach { entry ->
            val componentName = ComponentName(this, entry.value)
            val state = packageManager.getComponentEnabledSetting(componentName)
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                return entry.key
            }
        }

        return "default"
    }

    private fun setComponentEnabled(aliasClassName: String, enabled: Boolean) {
        packageManager.setComponentEnabledSetting(
            ComponentName(this, aliasClassName),
            if (enabled) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            },
            PackageManager.DONT_KILL_APP,
        )
    }
}
