package com.rideamigos.back_location

import LocationHostApi
import PigeonLocationAccuracy
import PigeonLocationData
import PigeonLocationSettings
import PigeonNotificationSettings
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.graphics.Color
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.Priority
import com.rideamigos.back_location.FlutterLocationService.LocalBinder
import com.rideamigos.back_location.location.LocationManager
import com.rideamigos.back_location.location.configuration.*
import com.rideamigos.back_location.location.configuration.Configurations.defaultConfiguration
import com.rideamigos.back_location.location.constants.FailType
import com.rideamigos.back_location.location.constants.ProcessType
import com.rideamigos.back_location.location.listener.LocationListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler


class LocationPlugin : FlutterPlugin, ActivityAware, LocationListener, LocationHostApi,
    StreamHandler {
    private var context: Context? = null
    private var activity: Activity? = null

    private var globalLocationConfigurationBuilder: LocationConfiguration.Builder =
        defaultConfiguration()
    private var locationManager: LocationManager? = null
    private var streamLocationManager: LocationManager? = null
    private var flutterLocationService: FlutterLocationService? = null

    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private var callbackResultsNeedingLocation: MutableList<(Result<PigeonLocationData>) -> Unit> =
        mutableListOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        LocationHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, STREAM_CHANNEL_NAME)
        eventChannel?.setStreamHandler(this)
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        LocationHostApi.setUp(binding.binaryMessenger, null)
        context = null
        eventChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        binding.activity.bindService(
            Intent(
                binding.activity, FlutterLocationService::class.java
            ), serviceConnection, Context.BIND_AUTO_CREATE
        )
    }

    override fun onDetachedFromActivity() {
        activity = null

    }


    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }


    private val serviceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, service: IBinder) {
            Log.d("LOCATION", "Service connected: $name")
            flutterLocationService = (service as LocalBinder).getService()
            flutterLocationService!!.activity = activity
        }

        override fun onServiceDisconnected(name: ComponentName) {
            Log.d("LOCATION", "Service disconnected:$name")
            flutterLocationService = null
        }
    }

    override fun onProcessTypeChanged(processType: Int) {
        Log.d("Location", "onProcessTypeChanged")
        when (processType) {
            ProcessType.ASKING_PERMISSIONS -> {
                Log.d("Location", "ASKING_PERMISSIONS")
            }
            ProcessType.GETTING_LOCATION_FROM_CUSTOM_PROVIDER -> {
                Log.d("Location", "GETTING_LOCATION_FROM_CUSTOM_PROVIDER")
            }
            ProcessType.GETTING_LOCATION_FROM_GOOGLE_PLAY_SERVICES -> {
                Log.d("Location", "GETTING_LOCATION_FROM_GOOGLE_PLAY_SERVICES")
            }
            ProcessType.GETTING_LOCATION_FROM_GPS_PROVIDER -> {
                Log.d("Location", "GETTING_LOCATION_FROM_GPS_PROVIDER")
            }
            ProcessType.GETTING_LOCATION_FROM_NETWORK_PROVIDER -> {
                Log.d("Location", "GETTING_LOCATION_FROM_NETWORK_PROVIDER")
            }
        }
    }

    override fun onLocationChanged(location: Location?) {
        Log.d("LOCATION", location?.latitude.toString() + " " + location?.longitude.toString())

        var locationData = PigeonLocationData(
            latitude = location!!.latitude,
            longitude = location.longitude,
            accuracy = location.accuracy.toDouble(),
            altitude = location.altitude,
            bearing = location.bearing.toDouble(),
            elapsedRealTimeNanos = location.elapsedRealtimeNanos.toDouble(),
            speed = location.speed.toDouble(),
            satellites = location.extras?.getInt("satellites")?.toLong(),
        )


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            locationData = locationData.copy(
                bearingAccuracyDegrees = locationData.bearingAccuracyDegrees,
                speedAccuracy = locationData.speedAccuracy,
                verticalAccuracy = locationData.verticalAccuracy
            )

        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            locationData =
                locationData.copy(elapsedRealTimeUncertaintyNanos = locationData.elapsedRealTimeUncertaintyNanos)
        }


        for (callback in callbackResultsNeedingLocation) {
            callback(
                Result.success(
                    locationData
                )
            )
        }


        eventSink?.success(pigeonLocationDataToList(locationData))

        callbackResultsNeedingLocation = mutableListOf()
    }

    private fun pigeonLocationDataToList(pigeonLocationData: PigeonLocationData): ArrayList<Any?> {
        val toListResult = ArrayList<Any?>(14)
        toListResult.add(pigeonLocationData.latitude)
        toListResult.add(pigeonLocationData.longitude)
        toListResult.add(pigeonLocationData.accuracy)
        toListResult.add(pigeonLocationData.altitude)
        toListResult.add(pigeonLocationData.bearing)
        toListResult.add(pigeonLocationData.bearingAccuracyDegrees)
        toListResult.add(pigeonLocationData.elapsedRealTimeNanos)
        toListResult.add(pigeonLocationData.elapsedRealTimeUncertaintyNanos)
        toListResult.add(pigeonLocationData.satellites)
        toListResult.add(pigeonLocationData.speed)
        toListResult.add(pigeonLocationData.speedAccuracy)
        toListResult.add(pigeonLocationData.time)
        toListResult.add(pigeonLocationData.verticalAccuracy)
        toListResult.add(pigeonLocationData.isMock)
        return toListResult
    }

    override fun onLocationFailed(type: Int) {
        Log.d("Location", "onLocationFailed")
        when (type) {
            FailType.GOOGLE_PLAY_SERVICES_NOT_AVAILABLE -> {
            }
            FailType.GOOGLE_PLAY_SERVICES_SETTINGS_DENIED -> {
            }
            FailType.GOOGLE_PLAY_SERVICES_SETTINGS_DIALOG -> {
            }
            FailType.NETWORK_NOT_AVAILABLE -> {
            }
            FailType.TIMEOUT -> {
            }
            FailType.UNKNOWN -> {
            }
            FailType.VIEW_DETACHED -> {
            }
            FailType.VIEW_NOT_REQUIRED_TYPE -> {
            }
        }
    }

    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {
        Log.d("Location", "onStatusChanged")
    }

    override fun onProviderEnabled(provider: String?) {
        Log.d("Location", "onProviderEnabled")
    }

    override fun onProviderDisabled(provider: String?) {
        Log.d("Location", "onProviderDisabled")
    }

    override fun getLocation(
        settings: PigeonLocationSettings?, callback: (Result<PigeonLocationData>) -> Unit
    ) {
        callbackResultsNeedingLocation.add(callback)

        val isListening = streamLocationManager != null

        if (settings != null) {
            val locationConfiguration = getLocationConfigurationFromSettings(settings)
            locationManager = LocationManager.Builder(context!!)
                .activity(activity) // Only required to ask permission and/or GoogleApi - SettingsApi
                .configuration(locationConfiguration.build()).notify(this).build()

            locationManager?.get()
        } else {
            if (!isListening) {
                locationManager = LocationManager.Builder(context!!)
                    .activity(activity) // Only required to ask permission and/or GoogleApi - SettingsApi
                    .configuration(globalLocationConfigurationBuilder.build()).notify(this).build()

                locationManager?.get()
            }

        }
    }

    private fun getPriorityFromAccuracy(accuracy: PigeonLocationAccuracy): Int {
        return when (accuracy) {
            PigeonLocationAccuracy.POWERSAVE -> Priority.PRIORITY_PASSIVE
            PigeonLocationAccuracy.LOW -> Priority.PRIORITY_LOW_POWER
            PigeonLocationAccuracy.BALANCED -> Priority.PRIORITY_BALANCED_POWER_ACCURACY
            PigeonLocationAccuracy.HIGH -> Priority.PRIORITY_HIGH_ACCURACY
            PigeonLocationAccuracy.NAVIGATION -> Priority.PRIORITY_HIGH_ACCURACY
        }
    }


    private fun getLocationConfigurationFromSettings(settings: PigeonLocationSettings): LocationConfiguration.Builder {
        val locationConfiguration = LocationConfiguration.Builder()

        if (settings.useGooglePlayServices) {
            val googlePlayServices = GooglePlayServicesConfiguration.Builder()
            googlePlayServices.askForGooglePlayServices(settings.askForGooglePlayServices)
                .fallbackToDefault(settings.fallbackToGPS)
                .ignoreLastKnowLocation(settings.ignoreLastKnownPosition)

            val locationRequestBuilder = LocationRequest.Builder(settings.interval.toLong())

            if (settings.expirationDuration != null) {
                locationRequestBuilder.setDurationMillis(settings.expirationDuration.toLong())
            }

            if (settings.maxWaitTime != null) {
                locationRequestBuilder.setMaxUpdateDelayMillis(settings.maxWaitTime.toLong())
            }
            if (settings.numUpdates != null) {
                locationRequestBuilder.setMaxUpdates((settings.numUpdates.toInt()))
            }

            locationRequestBuilder.setMinUpdateIntervalMillis(settings.fastestInterval.toLong())
                .setPriority(getPriorityFromAccuracy(settings.accuracy))
                .setMinUpdateDistanceMeters(settings.smallestDisplacement.toFloat())
                .setWaitForAccurateLocation(settings.waitForAccurateLocation)


            googlePlayServices.locationRequest(locationRequestBuilder.build())

            locationConfiguration.useGooglePlayServices(googlePlayServices.build())
        }

        if (settings.fallbackToGPS) {
            val defaultProvider = DefaultProviderConfiguration.Builder()

            defaultProvider.requiredTimeInterval(settings.interval.toLong())
            if (settings.acceptableAccuracy != null) {
                defaultProvider.acceptableAccuracy(settings.acceptableAccuracy.toFloat())
            }

            locationConfiguration.useDefaultProviders(defaultProvider.build())
        }

        return locationConfiguration
    }

    override fun setLocationSettings(settings: PigeonLocationSettings): Boolean {
        val locationConfiguration = getLocationConfigurationFromSettings(settings)

        globalLocationConfigurationBuilder = locationConfiguration

        if (streamLocationManager != null) {
            streamLocationManager?.cancel()
            streamLocationManager = LocationManager.Builder(context!!)
                .activity(activity) // Only required to ask permission and/or GoogleApi - SettingsApi
                .configuration(globalLocationConfigurationBuilder.keepTracking(true).build())
                .notify(this).build()

            streamLocationManager?.get()
        }

        return true
    }

    override fun changeNotificationSettings(settings: PigeonNotificationSettings): Boolean {
        flutterLocationService?.changeNotificationOptions(
            NotificationOptions(
                title = settings.title ?: kDefaultNotificationTitle,
                iconName = settings.iconName ?: kDefaultNotificationIconName,
                subtitle = settings.subtitle,
                description = settings.subtitle,
                color = if (settings.color != null) Color.parseColor(settings.color) else null,
                onTapBringToFront = settings.onTapBringToFront ?: false,
                setOngoing = settings.setOngoing ?: false,
                channelDescription = settings.channelDescription
            )
        )

        return true
    }

    override fun setBackgroundActivated(activated: Boolean): Boolean {
        if (activated) {
            flutterLocationService?.enableBackgroundMode()
        } else {
            flutterLocationService?.disableBackgroundMode()
        }
        return true
    }


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val inBackground = arguments as Boolean
        eventSink = events
        streamLocationManager = LocationManager.Builder(context!!)
            .activity(activity) // Only required to ask permission and/or GoogleApi - SettingsApi
            .configuration(globalLocationConfigurationBuilder.keepTracking(true).build())
            .notify(this).build()

        streamLocationManager?.get()
        if (inBackground) {
            flutterLocationService?.enableBackgroundMode()
        }
    }

    override fun onCancel(arguments: Any?) {
        flutterLocationService?.disableBackgroundMode()

        eventSink = null
        streamLocationManager?.cancel()
        streamLocationManager = null
    }

    companion object {
        private const val STREAM_CHANNEL_NAME = "lyokone/location_stream"
    }


}
