import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StorageInfoWidget extends StatelessWidget {

  static const platform = MethodChannel('com.example.testing_cleaner_app');

  const StorageInfoWidget({super.key});

  Future<Map<String, double>> _getStorageInfo() async {
    try {
      final Map<dynamic, dynamic> storage =
          await platform.invokeMethod('getStorageInfo');
      final total = storage['total'];
      final available = storage['available'];

      // Convert bytes to GB
      double totalGB = total / (1024 * 1024 * 1024); // Convert bytes to GB
      double availableGB =
          available / (1024 * 1024 * 1024); // Convert bytes to GB
      double usedGB = totalGB - availableGB; // Calculate used storage in GB

      return {
        'total': totalGB,
        'available': availableGB,
        'used': usedGB,
      };
    } on PlatformException catch (e) {
      throw Exception("Failed to get storage info: '${e.message}'");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, double>>(
        future: _getStorageInfo(), // Fetch storage info
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show loading indicator
          }
      
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
      
          if (snapshot.hasData) {
            final storageData = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Storage: ${storageData['total']!.toStringAsFixed(2)} GB"),
                Text("Available Storage: ${storageData['available']!.toStringAsFixed(2)} GB"),
                Text("Used Storage: ${storageData['used']!.toStringAsFixed(2)} GB"),
              ],
            );
          }
      
          return const Text("No data available");
        },
      ),
    );
  }
}
