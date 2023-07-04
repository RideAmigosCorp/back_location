import CoreLocation
import Flutter
import SwiftLocation
import UIKit

@UIApplicationMain
public class SwiftLocationPlugin: NSObject, FlutterPlugin, LocationHostApi, UIApplicationDelegate {

  var globalPigeonLocationSettings: PigeonLocationSettings?
  var streamHandler: StreamHandler?

  init(_ messenger: FlutterBinaryMessenger, _ registrar: FlutterPluginRegistrar) {
    super.init()
    let eventChannel = FlutterEventChannel(
      name: "lyokone/location_stream", binaryMessenger: messenger)
    self.streamHandler = StreamHandler()
    eventChannel.setStreamHandler(self.streamHandler)

    registrar.addApplicationDelegate(self)
  }

  public func getLocationSettings(
    _ settings: PigeonLocationSettings?,
    completion: @escaping (PigeonLocationData?, FlutterError?) -> Void
  ) {
    let currentSettings = SwiftLocationPlugin.locationSettingsToGPSLocationOptions(
      settings ?? globalPigeonLocationSettings)

    if globalPigeonLocationSettings?.ignoreLastKnownPosition == false {
      let lastKnownPosition = SwiftLocation.lastKnownGPSLocation
      if lastKnownPosition != nil {
        completion(SwiftLocationPlugin.locationToData(lastKnownPosition!), nil)
        return
      }
    }

    SwiftLocation.gpsLocationWith(currentSettings ?? getDefaultGPSLocationOptions()).then {
      result in  // you can attach one or more subscriptions via `then`.
      switch result {
      case .success(let location):
        completion(SwiftLocationPlugin.locationToData(location), nil)
      case .failure(let error):
        completion(
          nil,
          FlutterError(
            code: "LOCATION_ERROR",
            message: error.localizedDescription,
            details: error.recoverySuggestion))
      }
    }
  }

  static public func locationToData(_ location: CLLocation) -> PigeonLocationData {
    return PigeonLocationData.make(
      withLatitude: NSNumber(value: location.coordinate.latitude),
      longitude: NSNumber(value: location.coordinate.longitude),
      accuracy: NSNumber(value: location.horizontalAccuracy),
      altitude: NSNumber(value: location.altitude),
      bearing: NSNumber(value: location.course),
      bearingAccuracyDegrees: NSNumber(value: location.courseAccuracy),
      elapsedRealTimeNanos: nil,
      elapsedRealTimeUncertaintyNanos: nil,
      satellites: nil,
      speed: NSNumber(value: location.speed),
      speedAccuracy: NSNumber(value: location.speedAccuracy),
      time: NSNumber(value: location.timestamp.timeIntervalSince1970),
      verticalAccuracy: NSNumber(value: location.verticalAccuracy),
      isMock: false)

  }

  public func getDefaultGPSLocationOptions() -> GPSLocationOptions {
    let defaultOption = GPSLocationOptions()
    defaultOption.minTimeInterval = 2
    defaultOption.subscription = .single

    return defaultOption
  }

  static private func mapAccuracy(_ accuracy: PigeonLocationAccuracy) -> GPSLocationOptions.Accuracy
  {
    switch accuracy {

    case .powerSave:
      return GPSLocationOptions.Accuracy.city
    case .low:
      return GPSLocationOptions.Accuracy.block
    case .balanced:
      return GPSLocationOptions.Accuracy.house
    case .high:
      return GPSLocationOptions.Accuracy.room
    case .navigation:
      return GPSLocationOptions.Accuracy.room
    @unknown default:
      return GPSLocationOptions.Accuracy.room
    }
  }

  static public func locationSettingsToGPSLocationOptions(_ settings: PigeonLocationSettings?)
    -> GPSLocationOptions?
  {
    if settings == nil {
      return nil
    }
    let options = GPSLocationOptions()

    let minTimeInterval = settings?.interval
    let accuracy = settings?.accuracy
    let minDistance = settings?.smallestDisplacement

    options.activityType = .automotiveNavigation
    options.subscription = .single
    options.avoidRequestAuthorization = true
      
    if minTimeInterval != nil {
      options.minTimeInterval = Double(Int(truncating: minTimeInterval!) / 1000)
    }

    if accuracy != nil {
      options.accuracy = mapAccuracy(accuracy!)
    }

    
    if minDistance != nil {
      options.minDistance = Double(truncating: minDistance!)
    }

    return options
  }

  public func setLocationSettingsSettings(
    _ settings: PigeonLocationSettings, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> NSNumber? {
    globalPigeonLocationSettings = settings

    return NSNumber(true)
  }


  // Not applicable to iOS
  public func changeNotificationSettingsSettings(
    _ settings: PigeonNotificationSettings, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> NSNumber? {
    return NSNumber(true)
  }

  public func setBackgroundActivatedActivated(
    _ activated: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> NSNumber? {
    SwiftLocation.allowsBackgroundLocationUpdates = activated.boolValue
    return NSNumber(true)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger: FlutterBinaryMessenger = registrar.messenger()
    let api: LocationHostApi & NSObjectProtocol = SwiftLocationPlugin.init(messenger, registrar)

    LocationHostApiSetup(messenger, api)
  }

  @nonobjc public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
  ) -> Bool {
    return true
  }

}
