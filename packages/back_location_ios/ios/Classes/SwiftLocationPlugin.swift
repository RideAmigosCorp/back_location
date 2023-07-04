import CoreLocation
import Flutter
import SwiftLocation
import UIKit

extension FlutterError: Error {}

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

  func getLocation(
    settings: PigeonLocationSettings?,
    completion: @escaping (Result<PigeonLocationData, Error>) -> Void
  ) {
    let currentSettings = SwiftLocationPlugin.locationSettingsToGPSLocationOptions(
      settings ?? globalPigeonLocationSettings)

    if globalPigeonLocationSettings?.ignoreLastKnownPosition == false {
      let lastKnownPosition = SwiftLocation.lastKnownGPSLocation
      if lastKnownPosition != nil {
        completion(.success(SwiftLocationPlugin.locationToData(lastKnownPosition!)))
        return
      }
    }

    SwiftLocation.gpsLocationWith(currentSettings ?? getDefaultGPSLocationOptions()).then {
      result in  // you can attach one or more subscriptions via `then`.
      switch result {
      case .success(let location):
        completion(.success(SwiftLocationPlugin.locationToData(location)))
      case .failure(let error):
        completion(
          .failure(
            FlutterError(
              code: "LOCATION_ERROR",
              message: error.localizedDescription,
              details: error.recoverySuggestion)))
      }
    }
  }

  static func locationToData(_ location: CLLocation) -> PigeonLocationData {
      return PigeonLocationData(
      latitude:  location.coordinate.latitude,
      longitude:location.coordinate.longitude,
      accuracy: location.horizontalAccuracy,
      altitude: location.altitude,
      bearing: location.course,
      bearingAccuracyDegrees: location.courseAccuracy,
      elapsedRealTimeNanos: nil,
      elapsedRealTimeUncertaintyNanos: nil,
      satellites: nil,
      speed: location.speed,
      speedAccuracy: location.speedAccuracy,
      time: location.timestamp.timeIntervalSince1970,
      verticalAccuracy: location.verticalAccuracy,
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

  static func locationSettingsToGPSLocationOptions(_ settings: PigeonLocationSettings?)
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
      options.minTimeInterval = Double(minTimeInterval! / 1000)
    }

    if accuracy != nil {
      options.accuracy = mapAccuracy(accuracy!)
    }

    if minDistance != nil {
      options.minDistance = minDistance!
    }

    return options
  }

  func setLocationSettings(settings: PigeonLocationSettings) throws -> Bool {
    globalPigeonLocationSettings = settings

    return true
  }

  // Not applicable to iOS
  func changeNotificationSettings(settings: PigeonNotificationSettings) throws -> Bool {
    return true
  }

  func setBackgroundActivated(activated: Bool) throws -> Bool {
    SwiftLocation.allowsBackgroundLocationUpdates = activated
    return true
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger: FlutterBinaryMessenger = registrar.messenger()
    let api: LocationHostApi & NSObjectProtocol = SwiftLocationPlugin.init(messenger, registrar)

    LocationHostApiSetup.setUp(binaryMessenger: messenger, api: api)
  }

  @nonobjc public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
  ) -> Bool {
    return true
  }

}
