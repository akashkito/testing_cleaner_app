import 'package:flutter/services.dart';

class ProcessorInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  String cpuModel = "Unknown";
  String numCores = "Unknown";
  String cpuArchitecture = "Unknown";

  Future<void> fetchProcessorInfo() async {
    try {
      final Map<String, dynamic> result = Map<String, dynamic>.from(await platform.invokeMethod('getProcessorInfo'));

      // Check for errors
      if (result.containsKey('error')) {
        cpuModel = "Error: ${result['error']}";
        numCores = "Error: ${result['error']}";
        cpuArchitecture = "Error: ${result['error']}";
        return;
      }

      cpuModel = result['cpuModel'] ?? "Unknown";
      numCores = result['numCores']?.toString() ?? "Unknown";
      cpuArchitecture = result['cpuArchitecture'] ?? "Unknown";
    } on PlatformException catch (e) {
      cpuModel = "Failed to get CPU model: '${e.message}'";
      numCores = "Failed to get number of cores: '${e.message}'";
      cpuArchitecture = "Failed to get CPU architecture: '${e.message}'";
    }
  }
}
