// ignore_for_file: lines_longer_than_80_chars

part of '../back_location_platform_interface.dart';

// Those types are often a direct reflect of the Pigeon implementation
// but since Pigeon does not support comments
// there is a passthrough to the user facing types.

/// {@template location_data}
/// The response object of [LocationPlatform.getLocation] and [LocationPlatform.onLocationChanged].
/// {@endtemplate}
class LocationData {
  /// {@macro location_data}
  LocationData({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.bearing,
    this.bearingAccuracyDegrees,
    this.elapsedRealTimeNanos,
    this.elapsedRealTimeUncertaintyNanos,
    this.satellites,
    this.speed,
    this.speedAccuracy,
    this.time,
    this.verticalAccuracy,
    this.isMock,
  });

  /// Constructor from a Pigeon LocationData.
  factory LocationData.fromPigeon(PigeonLocationData pigeonData) {
    return LocationData(
      latitude: pigeonData.latitude,
      longitude: pigeonData.longitude,
      accuracy: pigeonData.accuracy,
      altitude: pigeonData.altitude,
      bearing: pigeonData.bearing,
      bearingAccuracyDegrees: pigeonData.bearingAccuracyDegrees,
      elapsedRealTimeNanos: pigeonData.elapsedRealTimeNanos,
      elapsedRealTimeUncertaintyNanos:
          pigeonData.elapsedRealTimeUncertaintyNanos,
      satellites: pigeonData.satellites,
      speed: pigeonData.speed,
      speedAccuracy: pigeonData.speedAccuracy,
      time: pigeonData.time,
      verticalAccuracy: pigeonData.verticalAccuracy,
      isMock: pigeonData.isMock,
    );
  }

  /// Latitude in degrees
  final double? latitude;

  /// Longitude, in degrees
  final double? longitude;

  /// Estimated horizontal accuracy of this location, radial, in meters
  ///
  /// Always 0 on Web
  final double? accuracy;

  /// Estimated vertical accuracy of this location, in meters.
  final double? verticalAccuracy;

  /// In meters above the WGS 84 reference ellipsoid. Derived from GPS informations.
  ///
  /// Always 0 on Web
  final double? altitude;

  /// In meters/second
  ///
  /// Always 0 on Web
  final double? speed;

  /// In meters/second
  ///
  /// Always 0 on Web
  final double? speedAccuracy;

  /// Bearing is the horizontal direction of travel of this device, in degrees
  ///
  /// Always 0 on Web
  final double? bearing;

  /// Get the estimated bearing accuracy of this location, in degrees.
  /// Only available on Android
  /// https://developer.android.com/reference/android/location/Location#getBearingAccuracyDegrees()
  final double? bearingAccuracyDegrees;

  /// timestamp of the LocationData
  final double? time;

  /// Is the location currently mocked
  ///
  /// Always false on iOS
  final bool? isMock;

  /// Return the time of this fix, in elapsed real-time since system boot.
  /// Only available on Android
  /// https://developer.android.com/reference/android/location/Location#getElapsedRealtimeNanos()
  final double? elapsedRealTimeNanos;

  /// Get estimate of the relative precision of the alignment of the ElapsedRealtimeNanos timestamp.
  /// Only available on Android
  /// https://developer.android.com/reference/android/location/Location#getElapsedRealtimeUncertaintyNanos()
  final double? elapsedRealTimeUncertaintyNanos;

  /// The number of satellites used to derive the fix.
  /// Only available on Android
  /// https://developer.android.com/reference/android/location/Location#getExtras()
  final int? satellites;
}

/// Precision of the Location. A lower precision will provide a greater battery
/// life.
///
/// https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest
/// https://developer.apple.com/documentation/corelocation/cllocationaccuracy?language=objc
enum LocationAccuracy {
  /// To request best accuracy possible with zero additional power consumption,
  powerSave,

  /// To request "city" level accuracy
  low,

  ///  To request "block" level accuracy
  balanced,

  /// To request the most accurate locations available
  high,

  /// To request location for navigation usage (affect only iOS)
  navigation
}

/// Extended to [LocationAccuracy].
extension LocationAccuracyExtension on LocationAccuracy {
  /// Convert the LocationAccuracy to the Pigeon equivalent.
  PigeonLocationAccuracy toPigeon() {
    switch (this) {
      case LocationAccuracy.powerSave:
        return PigeonLocationAccuracy.powerSave;
      case LocationAccuracy.low:
        return PigeonLocationAccuracy.low;
      case LocationAccuracy.balanced:
        return PigeonLocationAccuracy.balanced;
      case LocationAccuracy.high:
        return PigeonLocationAccuracy.high;
      case LocationAccuracy.navigation:
        return PigeonLocationAccuracy.navigation;
    }
  }
}

/// {@template location_settings}
/// [LocationSettings] is used to change the settings of the next location
/// request.
/// {@endtemplate}
class LocationSettings {
  /// {@macro location_settings}
  LocationSettings({
    this.useGooglePlayServices = true,
    this.fallbackToGPS = true,
    this.ignoreLastKnownPosition = false,
    this.expirationDuration,
    this.expirationTime,
    this.fastestInterval = 500,
    this.interval = 1000,
    this.maxWaitTime,
    this.numUpdates,
    this.acceptableAccuracy,
    this.accuracy = LocationAccuracy.high,
    this.smallestDisplacement = 0,
    this.waitForAccurateLocation = true,
  });

  /// If set to true, the app will use Google Play Services to request location.
  /// If not available on the device, the app will fallback to GPS.
  /// Only valid on Android.
  bool useGooglePlayServices;

  /// If set to true, the app will fallback to GPS if Google Play Services is not
  /// available on the device.
  /// Only valid on Android.
  bool fallbackToGPS;

  /// If set to true, the app will ignore the last known position
  /// and request a fresh one
  bool ignoreLastKnownPosition;

  /// The duration of the location request.
  /// Only valid on Android.
  double? expirationDuration;

  /// The expiration time of the location request.
  /// Only valid on Android.
  double? expirationTime;

  /// The fastest interval between location updates.
  /// In milliseconds.
  /// Only valid on Android.
  double fastestInterval;

  /// The interval between location updates.
  /// In milliseconds.
  double interval;

  /// The maximum amount of time the app will wait for a location.
  /// In milliseconds.
  double? maxWaitTime;

  /// The number of location updates to request.
  /// Only valid on Android.
  int? numUpdates;

  /// The accuracy of the location request.
  LocationAccuracy accuracy;

  /// The smallest displacement between location updates.
  double smallestDisplacement;

  /// If set to true, the app will wait for an accurate location.
  /// Only valid on Android.
  bool waitForAccurateLocation;

  /// The acceptable accuracy of the location request.
  /// Only valid on Android.
  double? acceptableAccuracy;

  /// Converts to the Pigeon equivalent.
  PigeonLocationSettings toPigeon() {
    return PigeonLocationSettings(
      useGooglePlayServices: useGooglePlayServices,
      fallbackToGPS: fallbackToGPS,
      ignoreLastKnownPosition: ignoreLastKnownPosition,
      expirationDuration: expirationDuration,
      expirationTime: expirationTime,
      fastestInterval: fastestInterval,
      interval: interval,
      maxWaitTime: maxWaitTime,
      numUpdates: numUpdates,
      accuracy: accuracy.toPigeon(),
      smallestDisplacement: smallestDisplacement,
      waitForAccurateLocation: waitForAccurateLocation,
      acceptableAccuracy: acceptableAccuracy,
    );
  }
}
