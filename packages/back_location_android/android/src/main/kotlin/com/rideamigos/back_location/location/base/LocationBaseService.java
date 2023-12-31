package com.rideamigos.back_location.location.base;

import android.app.Service;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.CallSuper;

import com.rideamigos.back_location.location.CustomLocationManager;
import com.rideamigos.back_location.location.configuration.LocationConfiguration;
import com.rideamigos.back_location.location.constants.ProcessType;
import com.rideamigos.back_location.location.listener.LocationListener;

public abstract class LocationBaseService extends Service implements LocationListener {

    private CustomLocationManager customLocationManager;

    public abstract LocationConfiguration getLocationConfiguration();

    @CallSuper
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        customLocationManager = new CustomLocationManager.Builder(getApplicationContext())
              .configuration(getLocationConfiguration())
              .notify(this)
              .build();
        return super.onStartCommand(intent, flags, startId);
    }

    protected CustomLocationManager getLocationManager() {
        return customLocationManager;
    }

    protected void getLocation() {
        if (customLocationManager != null) {
            customLocationManager.get();
        } else {
            throw new IllegalStateException("locationManager is null. "
                  + "Make sure you call super.onStartCommand before attempting to getLocation");
        }
    }

    @Override
    public void onProcessTypeChanged(@ProcessType int processType) {
        // override if needed
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
        // override if needed
    }

    @Override
    public void onProviderEnabled(String provider) {
        // override if needed
    }

    @Override
    public void onProviderDisabled(String provider) {
        // override if needed
    }
}
