package com.rideamigos.back_location.location.configuration;

public final class Configurations {

    /**
     * Pre-Defined Configurations
     */
    private Configurations() {
        // No instance
    }
    /**
     * Returns a LocationConfiguration which tights to default definitions with given messages. Since this method is
     * basically created in order to be used in Activities, User needs to be asked for permission and enabling gps.
     *
     * @return
     */
    public static LocationConfiguration.Builder defaultConfiguration() {
        return new LocationConfiguration.Builder()
                .useGooglePlayServices(new GooglePlayServicesConfiguration.Builder().build())
                .useDefaultProviders(new DefaultProviderConfiguration.Builder().requiredTimeInterval(2 * 1000).build());
    }
}
