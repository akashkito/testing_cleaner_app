import 'package:flutter/services.dart';

class WiFiInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<Map<String, String>> fetchWiFiInfo() async {
    try {
      final result = await platform.invokeMethod('getWifiInfo');
      return {
        'SSID': result['SSID'] ?? "Unknown",
        'MAC': result['MAC'] ?? "Unknown",
        'IP': result['IP'] ?? "Unknown",
      };
    } on PlatformException catch (e) {
      return {
        'SSID': "Failed to get SSID: '${e.message}'",
        'MAC': "Failed to get MAC address: '${e.message}'",
        'IP': "Failed to get IP address: '${e.message}'",
      };
    }
  }
}
