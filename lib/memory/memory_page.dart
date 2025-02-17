import 'package:flutter/services.dart';

class MemoryInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  // Convert bytes to GB
  String bytesToGB(int bytes) {
    double gb = bytes / (1024 * 1024 * 1024); // Convert bytes to GB
    return gb.toStringAsFixed(2); // Return as a string with two decimal places
  }

  Future<Map<String, String>> fetchMemoryInfo() async {
    try {
      final result = Map<String, dynamic>.from(await platform.invokeMethod('getMemoryInfo'));

      return {
        'totalRAM': bytesToGB(result['totalRAM'] ?? 0),
        'availableRAM': bytesToGB(result['availableRAM'] ?? 0),
        'usedRAM': bytesToGB(result['usedRAM'] ?? 0),
        'ramPercentage': result['ramPercentage']?.toStringAsFixed(2) ?? "Unknown",

        'totalROM': bytesToGB(result['totalROM'] ?? 0),
        'availableROM': bytesToGB(result['availableROM'] ?? 0),
        'usedROM': bytesToGB(result['usedROM'] ?? 0),
        'romPercentage': result['romPercentage']?.toStringAsFixed(2) ?? "Unknown",
      };
    } on PlatformException catch (e) {
      return {
        'totalRAM': "Failed to get total RAM: '${e.message}'",
        'availableRAM': "Failed to get available RAM: '${e.message}'",
        'usedRAM': "Failed to get used RAM: '${e.message}'",
        'ramPercentage': "Failed to get RAM percentage: '${e.message}'",

        'totalROM': "Failed to get total ROM: '${e.message}'",
        'availableROM': "Failed to get available ROM: '${e.message}'",
        'usedROM': "Failed to get used ROM: '${e.message}'",
        'romPercentage': "Failed to get ROM percentage: '${e.message}'",
      };
    }
  }
}
