import CoreLocation
import Flutter
import Foundation
import SwiftLocation

class StreamHandler: NSObject, FlutterStreamHandler {
  var locationRequest: GPSLocationRequest?
  var locationSettings: PigeonLocationSettings?
  var events: FlutterEventSink?

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {

    let activated = arguments as! Bool? ?? false
    SwiftLocation.allowsBackgroundLocationUpdates = activated

    self.events = events
    startListening()

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationRequest?.cancelRequest()
    events = nil
    return nil
  }

  public func setPigeonLocationSettings(_ settings: PigeonLocationSettings) {
    self.locationSettings = settings
    locationRequest?.cancelRequest()
    startListening()
  }

  private func toList(_ locationData: PigeonLocationData) -> [Any] {
    return [
      locationData.latitude ?? NSNull(),
      locationData.longitude ?? NSNull(),
      locationData.accuracy ?? NSNull(),
      locationData.altitude ?? NSNull(),
      locationData.bearing ?? NSNull(),
      locationData.bearingAccuracyDegrees ?? NSNull(),
      locationData.elapsedRealTimeNanos ?? NSNull(),
      locationData.elapsedRealTimeUncertaintyNanos ?? NSNull(),
      locationData.satellites ?? NSNull(),
      locationData.speed ?? NSNull(),
      locationData.speedAccuracy ?? NSNull(),
      locationData.time ?? NSNull(),
      locationData.verticalAccuracy ?? NSNull(),
      locationData.isMock ?? NSNull(),
    ]
  }

  private func startListening() {
    if events == nil {
      return
    }

    let options = SwiftLocationPlugin.locationSettingsToGPSLocationOptions(locationSettings)
    options?.subscription = .continous

    locationRequest =
      options != nil
      ? SwiftLocation.gpsLocationWith(options!)
      : SwiftLocation.gpsLocationWith {
        $0.subscription = .continous
        $0.accuracy = .house
        $0.minTimeInterval = 2
        $0.activityType = .automotiveNavigation
        $0.avoidRequestAuthorization = true
      }

    locationRequest?.then { result in
      switch result {
      case .success(let newData):
        print("New location: \(newData)")

        self.events!(self.self.toList(SwiftLocationPlugin.locationToData(newData)))

      case .failure(let error):
        print("An error has occurred: \(error.localizedDescription)")
        self.events!(
          FlutterError(
            code: "LOCATION_ERROR",
            message: error.localizedDescription,
            details: error.recoverySuggestion))
      }
    }

  }
}
