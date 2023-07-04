package com.rideamigos.back_location.location.configuration;

import androidx.annotation.Nullable;

public class LocationConfiguration {

    private final boolean keepTracking;
    private final GooglePlayServicesConfiguration googlePlayServicesConfiguration;
    private final DefaultProviderConfiguration defaultProviderConfiguration;

    private LocationConfiguration(Builder builder) {
        this.keepTracking = builder.keepTracking;
        this.googlePlayServicesConfiguration = builder.googlePlayServicesConfiguration;
        this.defaultProviderConfiguration = builder.defaultProviderConfiguration;
    }


    // region Getters
    public boolean keepTracking() {
        return keepTracking;
    }

    @Nullable
    public GooglePlayServicesConfiguration googlePlayServicesConfiguration() {
        return googlePlayServicesConfiguration;
    }

    @Nullable
    public DefaultProviderConfiguration defaultProviderConfiguration() {
        return defaultProviderConfiguration;
    }
    // endregion

    public static class Builder {

        private boolean keepTracking = com.rideamigos.back_location.location.configuration.Defaults.KEEP_TRACKING;
        private GooglePlayServicesConfiguration googlePlayServicesConfiguration;
        private DefaultProviderConfiguration defaultProviderConfiguration;

        /**
         * If you need to keep receiving location updates, then you need to set this as true.
         * Otherwise manager will be aborted after any location received.
         * Default is False.
         */
        public Builder keepTracking(boolean keepTracking) {
            this.keepTracking = keepTracking;
            return this;
        }

        /**
         * This configuration is required in order to configure GooglePlayServices Api.
         * If this is not set, then GooglePlayServices will not be used.
         */
        public Builder useGooglePlayServices(GooglePlayServicesConfiguration googlePlayServicesConfiguration) {
            this.googlePlayServicesConfiguration = googlePlayServicesConfiguration;
            return this;
        }

        /**
         * This configuration is required in order to configure Default Location Providers.
         * If this is not set, then they will not be used.
         */
        public Builder useDefaultProviders(DefaultProviderConfiguration defaultProviderConfiguration) {
            this.defaultProviderConfiguration = defaultProviderConfiguration;
            return this;
        }

        public LocationConfiguration build() {
            if (googlePlayServicesConfiguration == null && defaultProviderConfiguration == null) {
                throw new IllegalStateException("You need to specify one of the provider configurations."
                        + " Please see GooglePlayServicesConfiguration and DefaultProviderConfiguration");
            }


            return new LocationConfiguration(this);
        }

    }
}
