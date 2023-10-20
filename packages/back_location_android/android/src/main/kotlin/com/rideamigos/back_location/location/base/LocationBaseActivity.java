package com.rideamigos.back_location.location.base;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.appcompat.app.AppCompatActivity;

import com.rideamigos.back_location.location.CustomLocationManager;
import com.rideamigos.back_location.location.configuration.LocationConfiguration;
import com.rideamigos.back_location.location.constants.ProcessType;
import com.rideamigos.back_location.location.listener.LocationListener;

public abstract class LocationBaseActivity extends AppCompatActivity implements LocationListener {

    private CustomLocationManager customLocationManager;

    public abstract LocationConfiguration getLocationConfiguration();

    protected CustomLocationManager getLocationManager() {
        return customLocationManager;
    }

    protected void getLocation() {
        if (customLocationManager != null) {
            customLocationManager.get();
        } else {
            throw new IllegalStateException("locationManager is null. "
                  + "Make sure you call super.initialize before attempting to getLocation");
        }
    }

    @CallSuper
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        customLocationManager = new CustomLocationManager.Builder(getApplicationContext())
              .configuration(getLocationConfiguration())
              .activity(this)
              .notify(this)
              .build();
    }

    @CallSuper
    @Override
    protected void onDestroy() {
        customLocationManager.onDestroy();
        super.onDestroy();
    }

    @CallSuper
    @Override
    protected void onPause() {
        customLocationManager.onPause();
        super.onPause();
    }

    @CallSuper
    @Override
    protected void onResume() {
        super.onResume();
        customLocationManager.onResume();
    }

    @CallSuper
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        customLocationManager.onActivityResult(requestCode, resultCode, data);
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
