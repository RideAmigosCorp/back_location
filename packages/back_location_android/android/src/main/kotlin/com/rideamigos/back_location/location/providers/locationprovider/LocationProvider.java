package com.rideamigos.back_location.location.providers.locationprovider;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;

import com.rideamigos.back_location.location.CustomLocationManager;
import com.rideamigos.back_location.location.configuration.LocationConfiguration;
import com.rideamigos.back_location.location.helper.LogUtils;
import com.rideamigos.back_location.location.listener.LocationListener;
import com.rideamigos.back_location.location.view.ContextProcessor;

import java.lang.ref.WeakReference;

public abstract class LocationProvider {

    private boolean isWaiting = false;
    private LocationConfiguration configuration;
    private ContextProcessor contextProcessor;
    private WeakReference<LocationListener> weakLocationListener;

    /**
     * This method is called immediately once the LocationProvider is set to {@linkplain CustomLocationManager}
     */
    @CallSuper
    public void configure(ContextProcessor contextProcessor, LocationConfiguration configuration,
                          LocationListener listener) {
        this.contextProcessor = contextProcessor;
        this.configuration = configuration;
        this.weakLocationListener = new WeakReference<>(listener);
        initialize();
    }

    /**
     * This is used for passing object between LocationProviders
     */
    @CallSuper
    public void configure(LocationProvider locationProvider) {
        this.contextProcessor = locationProvider.contextProcessor;
        this.configuration = locationProvider.configuration;
        this.weakLocationListener = locationProvider.weakLocationListener;
        initialize();
    }

    /**
     * This is where your provider actually starts working
     */
    public abstract void get();

    /**
     * This provider is asked to be canceled all tasks currently running
     * and remove all location update listeners
     */
    public abstract void cancel();

    /**
     * Call this method while you begin to process getting location
     * and call it when at least one location is received
     */
    public void setWaiting(boolean waiting) {
        this.isWaiting = waiting;
    }

    /**
     * Returns waiting state
     */
    public boolean isWaiting() {
        return isWaiting;
    }

    /**
     * Override when you need to handle activityResult such as listening for GPS activation
     */
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    }

    /**
     * This is called right after configurations are set
     */
    public void initialize() {
    }

    /**
     * To remove location updates while getting from GPS or Network Provider
     */
    @CallSuper
    public void onDestroy() {
        weakLocationListener.clear();
    }

    public void onPause() {
    }

    public void onResume() {
    }

    protected LocationConfiguration getConfiguration() {
        return configuration;
    }

    @Nullable
    protected LocationListener getListener() {
        return weakLocationListener.get();
    }

    @Nullable
    protected Context getContext() {
        return contextProcessor.getContext();
    }

    @Nullable
    protected Activity getActivity() {
        return contextProcessor.getActivity();
    }


    protected boolean startActivityForResult(Intent intent) {
        if (getActivity() != null) {
            getActivity().startActivityForResult(intent, com.rideamigos.back_location.location.constants.RequestCode.GPS_ENABLE);
        } else {
            LogUtils.logE("Cannot startActivityForResult because host is neither Activity nor Fragment.");
            return false;
        }
        return true;
    }
}
