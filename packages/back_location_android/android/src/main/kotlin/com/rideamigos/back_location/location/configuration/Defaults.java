package com.rideamigos.back_location.location.configuration;

import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.Priority;

public final class Defaults {

    private static final int SECOND = 1000;
    private static final int MINUTE = 60 * SECOND;

    static final int WAIT_PERIOD = 20 * SECOND;
    static final int TIME_PERIOD = 5 * MINUTE;

    static final int LOCATION_DISTANCE_INTERVAL = 0;
    static final int LOCATION_INTERVAL = 5 * MINUTE;

    static final float MIN_ACCURACY = 5.0f;

    static final boolean KEEP_TRACKING = false;
    static final boolean FALLBACK_TO_DEFAULT = true;
    static final boolean ASK_FOR_GP_SERVICES = false;
    static final boolean IGNORE_LAST_KNOW_LOCATION = false;

    static final String EMPTY_STRING = "";

    private static final int LOCATION_PRIORITY =  Priority.PRIORITY_BALANCED_POWER_ACCURACY;
    private static final int LOCATION_FASTEST_INTERVAL = MINUTE;

    /**
     * https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest
     */
    public static LocationRequest createDefaultLocationRequest() {
        LocationRequest.Builder locationRequestBuilder = new LocationRequest.Builder(Defaults.LOCATION_INTERVAL).setPriority(Defaults.LOCATION_PRIORITY).setMinUpdateIntervalMillis(Defaults.LOCATION_FASTEST_INTERVAL);

        return locationRequestBuilder.build();
    }

    private Defaults() {
        // No instance
    }

}
