import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let channel = "com.example.testing_cleaner_app"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: channel, binaryMessenger: controller.binaryMessenger)

    batteryChannel.setMethodCallHandler { (call, result) in
      if call.method == "getBatteryLevel" {
        // Ensure battery monitoring is enabled
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel == -1 {
          result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
        } else {
          result(Int(batteryLevel * 100))  // Convert to percentage
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
