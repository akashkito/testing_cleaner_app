// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Map<String, dynamic> _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  // Fetch device information
  Future<void> _fetchDeviceInfo() async {
    try {
      final Map<String, dynamic>? deviceInfo = await platform.invokeMapMethod<String, dynamic>('getDeviceInfo');
      setState(() {
        _deviceInfo = deviceInfo ?? {}; // Handle potential null values
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to get device info: '${e.message}'");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Info"),
      ),
      body: Center(
        child: _deviceInfo.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the screen resolution info
                  Text("Screen Resolution: ${_deviceInfo['screenResolution']}"),
                  // Display the screen size
                  Text("Screen Size: ${_deviceInfo['screenSize']} inches"),
                  // Display the Android version
                  Text("Android Version: ${_deviceInfo['androidVersion']}"),
                  // Display the device model
                  Text("Model: ${_deviceInfo['deviceInfo']['model']}"),
                  // Display the Android ID
                  Text("Android ID: ${_deviceInfo['androidID']}"),
                  // Display manufacturer and hardware information if needed
                  Text("Manufacturer: ${_deviceInfo['deviceInfo']['manufacturer']}"),
                  Text("Hardware: ${_deviceInfo['deviceInfo']['hardware']}"),
                ],
              )
            : const CircularProgressIndicator(), // Show a loading spinner while fetching data
      ),
    );
  }
}

