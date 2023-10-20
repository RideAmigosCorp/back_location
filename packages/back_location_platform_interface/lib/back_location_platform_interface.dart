library back_location_platform_interface;

import 'dart:io' show Platform;

import 'package:back_location_platform_interface/src/messages.pigeon.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'src/method_channel_location.dart';
part 'src/types.dart';

/// The interface that implementations of location must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `Location`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [LocationPlatform] methods.
abstract class LocationPlatform extends PlatformInterface {
  /// Constructs a LocationPlatform.
  LocationPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocationPlatform _instance = MethodChannelLocation();

  /// The default instance of [LocationPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocation].
  static LocationPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [LocationPlatform] when they  themselves.
  static set instance(LocationPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current location.
  Future<LocationData?> getLocation({LocationSettings? settings});

  /// Return a stream of the user's location.
  Stream<LocationData?> onLocationChanged({bool inBackground = false});

  /// Set new global location settings for the app
  Future<bool?> setLocationSettings(LocationSettings settings);

  /// Return true if the notification was properly updated
  Future<bool?> updateBackgroundNotification({
    String? channelName,
    String? channelDescription,
    String? iconName,
    String? contentTitle,
    String? contentText,
    String? subText,
    Color? color,
    bool? onTapBringToFront,
    bool? setOngoing,
  });

  /// Checks if the android location NETWORK_PROVIDER is enabled
  Future<bool> isAndroidNetworkProviderEnabled();

  /// Prompts the user to enable the NETWORK_PROVIDER if it is disabled
  Future<void> promptUserToEnableAndroidNetworkProvider();
}
