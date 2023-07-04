// ignore_for_file: avoid_positional_boolean_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.pigeon.dart',
    dartTestOut: 'test/test.pigeon.dart',
    javaOut:
        '../back_location_android/android/src/main/java/com/rideamigos/location/GeneratedAndroidLocation.java',
    javaOptions: JavaOptions(
      package: 'com.rideamigos.back_location',
      className: 'GeneratedAndroidLocation',
    ),
    swiftOut: '../back_location_ios/ios/Classes/Messages.swift',
  ),
)
class PigeonLocationData {
  double? latitude;
  double? longitude;
  double? accuracy;
  double? altitude;
  double? bearing;
  double? bearingAccuracyDegrees;
  double? elapsedRealTimeNanos;
  double? elapsedRealTimeUncertaintyNanos;
  int? satellites;
  double? speed;
  double? speedAccuracy;
  double? time;
  double? verticalAccuracy;
  bool? isMock;
}

class PigeonNotificationSettings {
  String? channelName;
  String? title;
  String? iconName;
  String? subtitle;
  String? description;
  String? color;
  bool? onTapBringToFront;
}

enum PigeonLocationAccuracy { powerSave, low, balanced, high, navigation }

class PigeonLocationSettings {
  PigeonLocationSettings({
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
    this.accuracy = PigeonLocationAccuracy.high,
    this.smallestDisplacement = 0,
    this.waitForAccurateLocation = true,
  });

  bool useGooglePlayServices;
  bool fallbackToGPS;
  bool ignoreLastKnownPosition;
  double? expirationDuration;
  double? expirationTime;
  double fastestInterval;
  double interval;
  double? maxWaitTime;
  int? numUpdates;
  PigeonLocationAccuracy accuracy;
  double smallestDisplacement;
  bool waitForAccurateLocation;
  double? acceptableAccuracy;
}

@HostApi()
abstract class LocationHostApi {
  @async
  PigeonLocationData getLocation(PigeonLocationSettings? settings);

  bool setLocationSettings(PigeonLocationSettings settings);

  bool changeNotificationSettings(PigeonNotificationSettings settings);

  bool setBackgroundActivated(bool activated);
}
