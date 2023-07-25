import 'package:back_location_platform_interface/back_location_platform_interface.dart';
import 'package:flutter/material.dart';

export 'package:back_location_platform_interface/back_location_platform_interface.dart'
    show LocationData, LocationAccuracy, LocationSettings, LocationPlatform;

LocationPlatform get _platform => LocationPlatform.instance;

/// Allows you to mock the [LocationPlatform] instance for testing.
@visibleForTesting
void setLocationInstance(LocationPlatform platform) {
  LocationPlatform.instance = platform;
}

/// Returns the current location.
Future<LocationData> getLocation({LocationSettings? settings}) async {
  final location = await _platform.getLocation(settings: settings);
  if (location == null) throw Exception('Unable to get location');
  return location;
}

/// Listen to the current location.
Stream<LocationData> onLocationChanged({bool inBackground = false}) {
  return _platform
      .onLocationChanged(inBackground: inBackground)
      .where((event) => event != null)
      .cast<LocationData>();
}

/// Update global location settings.
/// The settings are a passthrough to the [LocationSettings] class.
Future<void> setLocationSettings({
  /// If set to true, the app will request Google Play Services
  /// to request location.
  /// If not available on the device, the app will fallback to GPS.
  bool askForGooglePlayServices = false,

  /// If set to true, the app will use Google Play Services to request location.
  /// If not available on the device, the app will fallback to GPS.
  /// Only valid on Android.
  bool useGooglePlayServices = true,

  /// If set to true, the app will fallback to GPS if
  /// Google Play Services is not available on the device.
  /// Only valid on Android.
  bool fallbackToGPS = true,

  /// If set to true, the app will ignore the last known position
  /// and request a fresh one
  bool ignoreLastKnownPosition = true,

  /// The duration of the location request.
  /// Only valid on Android.
  double? expirationDuration,

  /// The fastest interval between location updates.
  /// In milliseconds.
  /// Only valid on Android.
  double fastestInterval = 500,

  /// The interval between location updates.
  /// In milliseconds.
  double interval = 1000,

  /// The maximum amount of time the app will wait for a location.
  /// In milliseconds.
  double? maxWaitTime,

  /// The number of location updates to request.
  /// Only valid on Android.
  int? numUpdates,

  /// The accuracy of the location request.
  LocationAccuracy accuracy = LocationAccuracy.high,

  /// The smallest displacement between location updates.
  double smallestDisplacement = 0,

  /// If set to true, the app will wait for an accurate location.
  /// Only valid on Android.
  bool waitForAccurateLocation = true,

  /// The acceptable accuracy of the location request.
  /// Only valid on Android.
  double? acceptableAccuracy,
}) async {
  final response = await _platform.setLocationSettings(
    LocationSettings(
      useGooglePlayServices: useGooglePlayServices,
      fallbackToGPS: fallbackToGPS,
      ignoreLastKnownPosition: ignoreLastKnownPosition,
      expirationDuration: expirationDuration,
      fastestInterval: fastestInterval,
      interval: interval,
      maxWaitTime: maxWaitTime,
      numUpdates: numUpdates,
      accuracy: accuracy,
      smallestDisplacement: smallestDisplacement,
      waitForAccurateLocation: waitForAccurateLocation,
      acceptableAccuracy: acceptableAccuracy,
    ),
  );
  if (response != true) throw Exception('Unable to set new location settings');
}

/// Change options of sticky background notification on Android.
///
/// This method only applies to Android and allows for customizing the
/// notification, which is shown when inBackground for[onLocationChanged]
/// is set to true.
///
/// Uses [title] as the notification's content title and searches for a
/// drawable resource with the given [iconName]. If no matching resource is
/// found, no icon is shown. The content text will be set to [subtitle], while
/// the sub text will be set to [description]. The notification [color] can
/// also be customized.
///
/// When [onTapBringToFront] is set to true, tapping the notification will
/// bring the activity back to the front.
///
/// Both [title] and [channelName] will be set to defaults, if no values are
/// provided. All other null arguments will be ignored.
///
/// Returns true if the notification is currently has been properly updated
///
/// For Android SDK versions above 25, uses [channelName] for the
/// [NotificationChannel](https://developer.android.com/reference/android/app/NotificationChannel).
Future<bool> updateBackgroundNotification({
  String? channelName,
  String? channelDescription,
  String? iconName,
  String? contentTitle,
  String? contentText,
  String? subText,
  Color? color,
  bool? onTapBringToFront,
  bool? setOngoing,
}) async {
  final response = await _platform.updateBackgroundNotification(
    channelName: channelName,
    channelDescription: channelDescription,
    iconName: iconName,
    contentTitle: contentTitle,
    contentText: contentText,
    subText: subText,
    color: color,
    onTapBringToFront: onTapBringToFront,
    setOngoing: setOngoing,
  );
  if (response == null) {
    throw Exception('Error while getting Network status');
  }
  return response;
}
