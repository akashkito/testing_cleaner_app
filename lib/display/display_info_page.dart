import 'package:flutter/services.dart';

class DisplayInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<Map<String, String>> fetchDisplayInfo() async {
    try {
      final result = await platform.invokeMethod('getDisplayInfo');
      return {
        'width': result['width']?.toString() ?? "Unknown",
        'height': result['height']?.toString() ?? "Unknown",
        'refreshRate': result['refreshRate']?.toString() ?? "Unknown",
        'orientation': result['orientation'] == 1 ? "Portrait" : "Landscape",
      };
    } on PlatformException catch (e) {
      return {
        'width': "Failed to get width: '${e.message}'",
        'height': "Failed to get height: '${e.message}'",
        'refreshRate': "Failed to get refresh rate: '${e.message}'",
        'orientation': "Failed to get orientation: '${e.message}'",
      };
    }
  }
}
