import 'package:flutter/services.dart';

class BatteryInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  String batteryLevel = "Unknown";
  String chargingStatus = "Unknown";
  String batteryHealth = "Unknown";

  Future<void> fetchBatteryInfo() async {
    try {
      final int batteryResult = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = '$batteryResult%';

      final String chargingResult = await platform.invokeMethod('getBatteryStatus');
      chargingStatus = chargingResult;

      // Uncomment this if you have a method for battery health
      // final String healthResult = await platform.invokeMethod('getBatteryHealth');
      // batteryHealth = healthResult;
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'";
      chargingStatus = "Failed to get charging status: '${e.message}'";
      batteryHealth = "Failed to get battery health: '${e.message}'";
    }
  }
}
