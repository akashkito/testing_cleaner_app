import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Future<void> _fetchCameraInfo() async {
  //   await cameraInfoClass.fetchCameraInfo();
  //   setState(() {
  //     cameraInfo = cameraInfoClass.getStyledCameraInfo();
  //     isCameraFetched = true;
  //   });
  // }

   Widget cameraInfoWidget = Container();

  // Fetching camera info method
  Future<void> _fetchCameraInfo() async {
    await cameraInfoClass.fetchCameraInfo();
    setState(() {
      // Instead of assigning the string, assign the actual widget
      cameraInfoWidget = cameraInfoClass.getStyledCameraInfo();
      isCameraFetched = true; // Mark camera info as fetched
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
        title: Text('System Info',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDropdown(
                Icons.wifi,
                'WiFi Info',
                isWifiFetched
                    ? _buildWifiInfo()
                    : const Text('Fetching Wi-Fi Info...'),
                0),
            // _buildDropdown(
            //     Icons.camera,
            //     'Camera Info',
            //     isCameraFetched
            //         ? Text(cameraInfo, style: GoogleFonts.montserrat(fontSize: 14),)
            //         : const Text('Fetching Camera Info...'),
            //     1),
            _buildDropdown(
              Icons.camera,
              'Camera Info',
              isCameraFetched
                  ? cameraInfoWidget // Directly use the widget here
                  : const Text('Fetching Camera Info...'),
              1,
            ),
            _buildDropdown(
                Icons.display_settings,
                'Display Info',
                isDisplayFetched
                    ? _buildDisplayInfo()
                    : const Text('Fetching Display Info...'),
                2),
            _buildDropdown(
              Icons.settings_system_daydream_outlined,
              'Memory Info',
              _buildMemoryInfo(),
              3,
            ),
            _buildDropdown(
              Icons.memory_sharp,
              'Processor Info',
              _buildProcessorInfo(),
              4,
            ),
            _buildDropdown(
              Icons.battery_charging_full_outlined,
              'Battery Info',
              _buildBatteryInfo(),
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(IconData? icon, String title, Widget info, int index) {
    bool isExpanded =
        index == 0; // Change this to check if it's expanded or not
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4), // Set the border radius here
        color: Colors.white, // Optional: Set a background color if needed
        // Optionally, set a border for the container here
        border: Border.all(
            color: Colors.blue, width: 0.2), // Adjust border if needed
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ExpansionTile(
          // collapsedShape: Border.all(width: 0),

          backgroundColor: const Color.fromARGB(255, 239, 250, 255),
          collapsedTextColor: const Color.fromARGB(255, 73, 99, 74),
          collapsedIconColor: const Color.fromARGB(255, 75, 134, 77),
          collapsedBackgroundColor: const Color.fromARGB(255, 248, 248, 248),
          leading: Icon(icon),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: Border.all(
            width: 0,
          ),
          initiallyExpanded:
              isExpanded, // Only the first one is expanded by default
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: info,
            ),
          ],
          // Use onExpansionChanged callback to detect expansion state and apply conditional styling
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
        ),
      ),
    );
  }

  Row RowWidget(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 120,
              child: Text(
                textAlign: TextAlign.end,
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                 style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              ),
            ),
          ],
        ),
      ],
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
        RowWidget("Dimension", '${displayWidth}x${displayHeight}'),
        // RowWidget("Height", displayHeight),
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
