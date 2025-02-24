import 'package:flutter/material.dart';
import 'camera/camera_info.dart';
import 'display/display_info_page.dart';
import 'memory/memory_page.dart';
import 'wifi/wifi_info_page.dart';
import 'battery/battery_page.dart';
import 'processor/processor_info.dart';

class SystemInfoPage extends StatefulWidget {
  const SystemInfoPage({super.key});

  @override
  _SystemInfoPageState createState() => _SystemInfoPageState();
}

class _SystemInfoPageState extends State<SystemInfoPage> {
  // Existing variables for Wi-Fi, camera, display, and memory
  final WiFiInfo wifiInfoClass = WiFiInfo();
  final CameraInfo cameraInfoClass = CameraInfo();
  final DisplayInfo displayInfoClass = DisplayInfo();
  final MemoryInfo memoryInfoClass = MemoryInfo();
  final BatteryInfo batteryInfoClass = BatteryInfo();
  final ProcessorInfo processorInfoClass = ProcessorInfo();

  // Data variables
  String ssid = "Unknown", macAddress = "Unknown", ipAddress = "Unknown";
  bool isWifiFetched = false, isCameraFetched = false, isDisplayFetched = false;
  String cameraInfo = "Fetching Camera Info...",
      displayWidth = "Unknown",
      displayHeight = "Unknown";
  String totalRAM = "Unknown",
      availableRAM = "Unknown",
      usedRAM = "Unknown",
      ramPercentage = "Unknown";
  String totalROM = "Unknown",
      availableROM = "Unknown",
      usedROM = "Unknown",
      romPercentage = "Unknown";
  String displayRefreshRate = "Unknown", displayOrientation = "Unknown";

  // Fetch info methods
  Future<void> _fetchWifiInfo() async {
    final wifiData = await wifiInfoClass.fetchWiFiInfo();
    setState(() {
      ssid = wifiData['SSID']!;
      macAddress = wifiData['MAC']!;
      ipAddress = wifiData['IP']!;
      isWifiFetched = true;
    });
  }

  Future<void> _fetchCameraInfo() async {
    await cameraInfoClass.fetchCameraInfo();
    setState(() {
      cameraInfo = cameraInfoClass.getCameraInfoString();
      isCameraFetched = true;
    });
  }

  Future<void> _fetchDisplayInfo() async {
    final displayData = await displayInfoClass.fetchDisplayInfo();
    setState(() {
      displayWidth = displayData['width']!;
      displayHeight = displayData['height']!;
      displayRefreshRate = displayData['refreshRate']!;
      displayOrientation = displayData['orientation']!;
      isDisplayFetched = true;
    });
  }

  Future<void> _fetchMemoryInfo() async {
    final memoryData = await memoryInfoClass.fetchMemoryInfo();
    setState(() {
      totalRAM = memoryData['totalRAM']!;
      availableRAM = memoryData['availableRAM']!;
      usedRAM = memoryData['usedRAM']!;
      ramPercentage = memoryData['ramPercentage']!;
      totalROM = memoryData['totalROM']!;
      availableROM = memoryData['availableROM']!;
      usedROM = memoryData['usedROM']!;
      romPercentage = memoryData['romPercentage']!;
    });
  }

  Future<void> _fetchBatteryInfo() async {
    await batteryInfoClass.fetchBatteryInfo();
    setState(() {});
  }

  Future<void> _fetchProcessorInfo() async {
    await processorInfoClass.fetchProcessorInfo();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchWifiInfo();
    _fetchCameraInfo();
    _fetchDisplayInfo();
    _fetchMemoryInfo();
    _fetchBatteryInfo();
    _fetchProcessorInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDropdown(
                'WiFi Info',
                isWifiFetched
                    ? _buildWifiInfo()
                    : const Text('Fetching Wi-Fi Info...'),
                0),
            _buildDropdown(
                'Camera Info',
                isCameraFetched
                    ? Text(cameraInfo)
                    : const Text('Fetching Camera Info...'),
                1),
            _buildDropdown(
                'Display Info',
                isDisplayFetched
                    ? _buildDisplayInfo()
                    : const Text('Fetching Display Info...'),
                2),
            _buildDropdown('Memory Info', _buildMemoryInfo(), 3),
            _buildDropdown('Processor Info', _buildProcessorInfo(), 4),
            _buildDropdown('Battery Info', _buildBatteryInfo(), 5),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String title, Widget info, int index) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded:
          index == 0, // Only the first one is expanded by default
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: info,
        ),
      ],
    );
  }

  Row RowWidget(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Text(value)],
    );
  }

  Column _buildWifiInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RowWidget('SSID', ssid),
        RowWidget('MAC Address:', macAddress),
        RowWidget('IP Address', ipAddress),
      ],
    );
  }

  Widget _buildDisplayInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RowWidget("Width", displayWidth),
        RowWidget("Height", displayHeight),
        RowWidget("Refresh Rate", displayRefreshRate),
        RowWidget("Orientation", displayOrientation),
      ],
    );
  }

  Widget _buildMemoryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RowWidget('Total RAM', '$totalRAM GB'),
        RowWidget('Available RAM', '$availableRAM GB'),
        RowWidget('Used RAM:', '$usedRAM GB'),
        RowWidget('RAM Percentage', '$ramPercentage%'),
        const SizedBox(
          height: 20,
        ),
        RowWidget('Total ROM', '$totalROM GB'),
        RowWidget('Available ROM', '$availableROM GB'),
        RowWidget('Used ROM:', '$usedROM GB'),
        RowWidget('ROM Percentage', '$romPercentage%'),
      ],
    );
  }

  Widget _buildProcessorInfo() {
    return Column(
      children: [
        RowWidget('CPU Model', processorInfoClass.cpuModel),
        RowWidget('Number of Cores', processorInfoClass.numCores),
        RowWidget('CPU Architecture', processorInfoClass.cpuArchitecture),
      ],
    );
  }

  Widget _buildBatteryInfo() {
    return Column(
      children: [
        RowWidget('Battery Level', batteryInfoClass.batteryLevel),
        RowWidget('Charging Status:', batteryInfoClass.chargingStatus),
        RowWidget('Battery Health', batteryInfoClass.batteryHealth),
      ],
    );
  }
}
