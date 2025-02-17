import 'package:flutter/services.dart';

class StorageService {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final Map<dynamic, dynamic> storage = await platform.invokeMethod('getStorageInfo');
      final total = storage['total'];
      final available = storage['available'];

      // Convert bytes to GB
      double totalGB = total / (1024 * 1024 * 1024); // Convert bytes to GB
      double availableGB = available / (1024 * 1024 * 1024); // Convert bytes to GB
      double usedGB = totalGB - availableGB; // Calculate used storage in GB

      // Calculate the percentage of available and used storage
      double availablePercentage = (availableGB / totalGB) * 100;
      double usedPercentage = (usedGB / totalGB) * 100;

      return {
        'total': totalGB,
        'available': availableGB,
        'used': usedGB,
        'availablePercentage': availablePercentage,
        'usedPercentage': usedPercentage,
      };
    } on PlatformException catch (e) {
      throw Exception("Failed to get storage info: '${e.message}'");
    }
  }
}
