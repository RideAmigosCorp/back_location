package com.rideamigos.back_location.location;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.rideamigos.back_location.location.configuration.LocationConfiguration;
import com.rideamigos.back_location.location.helper.LogUtils;
import com.rideamigos.back_location.location.helper.logging.DefaultLogger;
import com.rideamigos.back_location.location.helper.logging.Logger;
import com.rideamigos.back_location.location.listener.LocationListener;
import com.rideamigos.back_location.location.providers.locationprovider.DispatcherLocationProvider;
import com.rideamigos.back_location.location.providers.locationprovider.LocationProvider;
import com.rideamigos.back_location.location.view.ContextProcessor;

public class CustomLocationManager {

    private final LocationListener listener;
    private final LocationConfiguration configuration;
    private final LocationProvider activeProvider;

    /**
     * Library tries to log as much as possible in order to make it transparent to see what is actually going on
     * under the hood. You can enable it for debug purposes, but do not forget to disable on production.
     *
     * Log is disabled as default.
     */
    public static void enableLog(boolean enable) {
        LogUtils.enable(enable);
    }

    /**
     * The Logger specifies how this Library is logging debug information. By default {@link DefaultLogger}
     * is used and it can be replaced by your own custom implementation of {@link Logger}.
     */
    public static void setLogger(@NonNull Logger logger) {
        LogUtils.setLogger(logger);
    }

    /**
     * To create an instance of this manager you MUST specify a LocationConfiguration
     */
    private CustomLocationManager(Builder builder) {
        this.listener = builder.listener;
        this.configuration = builder.configuration;
        this.activeProvider = builder.activeProvider;
    }

    public static class Builder {

        private final ContextProcessor contextProcessor;
        private LocationListener listener;
        private LocationConfiguration configuration;
        private LocationProvider activeProvider;

        /**
         * Builder object to create LocationManager
         *
         * @param contextProcessor holds the address of the context,which this manager will run on
         */
        public Builder(@NonNull ContextProcessor contextProcessor) {
            this.contextProcessor = contextProcessor;
        }

        /**
         * Builder object to create LocationManager
         *
         * @param context MUST be an application context
         */
        public Builder(@NonNull Context context) {
            this.contextProcessor = new ContextProcessor(context);
        }

        /**
         * Activity is required in order to ask for permission, GPS enable dialog, Rationale dialog,
         * GoogleApiClient and SettingsApi.
         *
         * @param activity will be kept as weakReference
         */
        public Builder activity(Activity activity) {
            this.contextProcessor.setActivity(activity);
            return this;
        }

        /**
         * Fragment is required in order to ask for permission, GPS enable dialog, Rationale dialog,
         * GoogleApiClient and SettingsApi.
         *
         * @param fragment will be kept as weakReference
         */
        public Builder fragment(Fragment fragment) {
            this.contextProcessor.setFragment(fragment);
            return this;
        }

        /**
         * Configuration object in order to take decisions accordingly while trying to retrieve location
         */
        public Builder configuration(@NonNull LocationConfiguration locationConfiguration) {
            this.configuration = locationConfiguration;
            return this;
        }

        /**
         * Instead of using {@linkplain DispatcherLocationProvider} you can create your own,
         * and set it to manager so it will use given one.
         */
        public Builder locationProvider(@NonNull LocationProvider provider) {
            this.activeProvider = provider;
            return this;
        }

        /**
         * Specify a LocationListener to receive location when it is available,
         * or get knowledge of any other steps in process
         */
        public Builder notify(LocationListener listener) {
            this.listener = listener;
            return this;
        }

        public CustomLocationManager build() {
            if (contextProcessor == null) {
                throw new IllegalStateException("You must set a context to LocationManager.");
            }

            if (configuration == null) {
                throw new IllegalStateException("You must set a configuration object.");
            }

            if (activeProvider == null) {
                locationProvider(new DispatcherLocationProvider());
            }

            this.activeProvider.configure(contextProcessor, configuration, listener);

            return new CustomLocationManager(this);
        }
    }

    /**
     * Returns configuration object which is defined to this manager
     */
    public LocationConfiguration getConfiguration() {
        return configuration;
    }

    /**
     * Google suggests to stop location updates when the activity is no longer in focus
     * http://developer.android.com/training/location/receive-location-updates.html#stop-updates
     */
    public void onPause() {
        activeProvider.onPause();
    }

    /**
     * Restart location updates to keep continue getting locations when activity is back
     */
    public void onResume() {
        activeProvider.onResume();
    }

    /**
     * Release whatever you need to when onDestroy is called
     */
    public void onDestroy() {
        activeProvider.onDestroy();
    }

    /**
     * This is required to check when user handles with Google Play Services error, or enables GPS...
     */
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        activeProvider.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * To determine whether LocationManager is currently waiting for location or it did already receive one!
     */
    public boolean isWaitingForLocation() {
        return activeProvider.isWaiting();
    }


    /**
     * Abort the mission and cancel all location update requests
     */
    public void cancel() {
        activeProvider.cancel();
    }

    /**
     * The only method you need to call to trigger getting location process
     */
    public void get() {
        activeProvider.get();
    }

    /**
     * Only For Test Purposes
     */
    LocationProvider activeProvider() {
        return activeProvider;
    }


}
