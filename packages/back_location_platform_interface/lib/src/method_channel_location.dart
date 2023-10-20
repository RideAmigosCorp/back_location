part of '../back_location_platform_interface.dart';

///
class MethodChannelLocation extends LocationPlatform {
  ///
  factory MethodChannelLocation() {
    if (_instance == null) {
      const eventChannel = EventChannel('lyokone/location_stream');
      _instance = MethodChannelLocation.private(eventChannel);
    }
    return _instance!;
  }

  /// This constructor is only used for testing and shouldn't be accessed by
  /// users of the plugin. It may break or change at any time.
  @visibleForTesting
  MethodChannelLocation.private(this._eventChannel);

  static MethodChannelLocation? _instance;

  final _api = LocationHostApi();
  late final EventChannel _eventChannel;

  @override
  Future<LocationData?> getLocation({LocationSettings? settings}) async {
    final pigeonData = await _api.getLocation(settings?.toPigeon());
    return LocationData.fromPigeon(pigeonData);
  }

  /// Current opened stream of location
  Stream<LocationData>? _onLocationChanged;

  @override
  Stream<LocationData?> onLocationChanged({bool inBackground = false}) {
    if (_onLocationChanged != null) {
      _api.setBackgroundActivated(inBackground);
    }

    return _onLocationChanged ??=
        _eventChannel.receiveBroadcastStream(inBackground).map<LocationData>(
              (dynamic event) => LocationData.fromPigeon(
                PigeonLocationData.decode(event as Object),
              ),
            );
  }

  @override
  Future<bool?> setLocationSettings(LocationSettings settings) {
    return _api.setLocationSettings(settings.toPigeon());
  }

  @override
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
  }) async {
    if (!Platform.isAndroid) {
      return true;
    }
    return _api.changeNotificationSettings(
      PigeonNotificationSettings(
        channelName: channelName,
        channelDescription: channelDescription,
        iconName: iconName,
        contentTitle: contentTitle,
        contentText: contentText,
        subText: subText,
        color: color != null ? '#${color.value.toRadixString(16)}' : null,
        onTapBringToFront: onTapBringToFront,
        setOngoing: setOngoing,
      ),
    );
  }

  @override
  Future<bool> isAndroidNetworkProviderEnabled() {
    return _api.isAndroidNetworkProviderEnabled();
  }

  @override
  Future<void> promptUserToEnableAndroidNetworkProvider() {
    return _api.promptUserToEnableAndroidNetworkProvider();
  }
}
