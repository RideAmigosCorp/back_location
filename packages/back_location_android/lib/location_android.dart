import 'package:back_location_platform_interface/back_location_platform_interface.dart';

/// The Android implementation of [LocationPlatform].
class LocationAndroid {
  /// Registers this class as the default instance of [LocationPlatform]
  static void registerWith() {
    LocationPlatform.instance = MethodChannelLocation();
  }
}
