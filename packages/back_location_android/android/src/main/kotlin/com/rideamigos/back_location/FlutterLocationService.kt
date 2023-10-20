package com.rideamigos.back_location

import android.app.Activity
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.util.Log
import com.rideamigos.back_location.location.CustomLocationManager
import com.rideamigos.back_location.location.configuration.DefaultProviderConfiguration
import com.rideamigos.back_location.location.configuration.GooglePlayServicesConfiguration
import com.rideamigos.back_location.location.configuration.LocationConfiguration
import io.flutter.plugin.common.PluginRegistry


class FlutterLocationService() : Service(),
    PluginRegistry.ActivityResultListener {
    companion object {
        private const val TAG = "FlutterLocationService"

        private const val ONGOING_NOTIFICATION_ID = 75131
        private const val CHANNEL_ID = "back_location_channel_01"
    }

    // Binder given to clients
    private val binder = LocalBinder()

    // Service is foreground
    private var isForeground = false

    private var backgroundNotification: BackgroundNotification? = null

    private var customLocationManager: CustomLocationManager? = null

    // Store result until a permission check is resolved
    public var activity: Activity? = null


    inner class LocalBinder : Binder() {
        fun getService(): FlutterLocationService = this@FlutterLocationService
    }

    override fun onCreate() {
        super.onCreate()
        backgroundNotification = BackgroundNotification(
            applicationContext,
            CHANNEL_ID,
            ONGOING_NOTIFICATION_ID
        )
    }

    override fun onBind(intent: Intent?): IBinder? {
        Log.d(TAG, "Binding to location service.")
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        Log.d(TAG, "Unbinding from location service.")
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        Log.d(TAG, "Destroying service.")

        customLocationManager?.cancel()
        customLocationManager = null
        backgroundNotification = null

        super.onDestroy()
    }


    fun enableBackgroundMode() {
        if (isForeground) {
            Log.d(TAG, "Service already in foreground mode.")
        } else {
            Log.d(TAG, "Start service in foreground mode.")


            val locationConfiguration =
                LocationConfiguration.Builder()
                    .keepTracking(true)
                    .useGooglePlayServices(GooglePlayServicesConfiguration.Builder().build())
                    .useDefaultProviders(DefaultProviderConfiguration.Builder().build())
                    .build()

            customLocationManager = CustomLocationManager.Builder(applicationContext)
                .activity(activity) // Only required to ask permission and/or GoogleApi - SettingsApi
                .configuration(locationConfiguration)
                .build()

            customLocationManager?.get()

            val notification = backgroundNotification!!.build()
            startForeground(ONGOING_NOTIFICATION_ID, notification)

            isForeground = true
        }
    }

    fun disableBackgroundMode() {
        Log.d(TAG, "Stop service in foreground.")
        stopForeground(true)

        customLocationManager?.cancel()

        isForeground = false
    }

    fun changeNotificationOptions(options: NotificationOptions): Map<String, Any>? {
        backgroundNotification?.updateOptions(options, isForeground)

        return if (isForeground)
            mapOf("channelId" to CHANNEL_ID, "notificationId" to ONGOING_NOTIFICATION_ID)
        else
            null
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d("Location", "onActivityResult")
        customLocationManager?.onActivityResult(requestCode, resultCode, data)
        return true
    }

}
