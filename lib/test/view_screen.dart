import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_cleaner_app/battery/battery_page.dart';
import 'package:testing_cleaner_app/storage/storage_info.dart';
import 'package:testing_cleaner_app/test/device_info.dart';
import 'package:testing_cleaner_app/test/homemainscreen.dart';
import '../camera/camera_info.dart';
import '../display/display_info_page.dart';
import '../memory/memory_page.dart';
import '../processor/processor_info.dart';
import '../wifi/wifi_info_page.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

// Custom Search Delegate for App Search
class AppSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> apps;

  AppSearchDelegate(this.apps);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Map<String, dynamic>> searchResults = apps
        .where(
            (app) => app['appName'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final app = searchResults[index];
        return ListTile(
          title: Text(app['appName']),
          subtitle: Text(
              'Package: ${app['packageName']}\nVersion: ${app['version']}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Trigger uninstallation
              debugPrint('Uninstalling app: ${app['appName']}');
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> searchResults = apps
        .where(
            (app) => app['appName'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final app = searchResults[index];
        return Column(
          children: [
            ListTile(
              title: Text(app['appName']),
              subtitle: Text(
                  'Package: ${app['packageName']}\nVersion: ${app['version']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Trigger uninstallation
                  debugPrint('Uninstalling app: ${app['appName']}');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cache Size: ${app['cacheSize']}'),
                  Text('Data Size: ${app['dataSize']}'),
                  Text('App Size: ${app['appSize']}'),
                  Text('Install Date: ${app['installDate']}'),
                  Text('Last Update: ${app['lastUpdateDate']}'),
                  Text('Uninstall Intent: ${app['uninstallIntent']}'),
                  const Divider(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ViewPageState extends State<ViewPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  String _batteryLevel = 'Unknown battery level.';
  bool _isLoading = false;
  final String _storageInfo = "";
  String _junkFiles = 'Fetching junk files...';

  List<Map<String, dynamic>> _installedApps = [];
  List<Map<String, dynamic>> _filteredApps = [];
  final TextEditingController _searchController = TextEditingController();

  // New variable to store device information
  String _deviceInfo = 'Fetching device info...';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterApps);
    _getStorageInfo();
    _getDeviceInfo(); // Fetch device info when the page is initialized
  }

  // Future<void> _getStorageInfo() async {
  //   setState(() {
  //     _isLoading = true; // Show loading indicator for storage
  //   });

  //   try {
  //     final Map<dynamic, dynamic> storage = await platform.invokeMethod('getStorageInfo');
  //     final total = storage['total'];
  //     final available = storage['available'];

  //     // Convert bytes to GB
  //     double totalGB = total / (1024 * 1024 * 1024); // Convert bytes to GB
  //     double availableGB = available / (1024 * 1024 * 1024); // Convert bytes to GB

  //     // Set the storage info in GB
  //     setState(() {
  //       _storageInfo =
  //           'Total: ${totalGB.toStringAsFixed(2)} GB, Available: ${availableGB.toStringAsFixed(2)} GB';
  //     });
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       _storageInfo = "Failed to get storage info: '${e.message}'";
  //     });
  //   }

  //   setState(() {
  //     _isLoading = false; // Hide loading indicator
  //   });
  // }

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

  // Fetch junk files from native code
  Future<void> _getJunkFiles() async {
    try {
      final List<dynamic> junkFiles =
          await platform.invokeMethod('getJunkFiles');
      setState(() {
        _junkFiles = junkFiles.isNotEmpty
            ? junkFiles.join('\n')
            : "No junk files found.";
      });
    } on PlatformException catch (e) {
      setState(() {
        _junkFiles = "Failed to get junk files: '${e.message}'";
      });
    }
  }

  Future<void> _getBatteryLevel() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Invoke the platform method for battery level
      final int result =
          await platform.invokeMethod<int>('getBatteryLevel') ?? -1;

      // Update battery level message
      if (result == -1) {
        _batteryLevel = 'Battery level not available.';
      } else {
        _batteryLevel = 'Battery level at $result%';
      }
    } on PlatformException catch (e) {
      _batteryLevel = "Failed to get battery level: '${e.message}'";
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  // Method to filter apps based on search query
  void _filterApps() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = _installedApps.where((app) {
        return app['appName']
            .toLowerCase()
            .contains(query); // Match the query with appName
      }).toList();
    });
  }

  // Fetch installed apps from the platform
  Future<void> _getInstalledApps() async {
    try {
      final List<dynamic> apps =
          await platform.invokeMethod('getInstalledApps');

      List<Map<String, dynamic>> appList = [];
      for (var app in apps) {
        final String appName = app['appName'] ?? 'Unknown';
        final String packageName = app['packageName'] ?? 'Unknown';
        final String version = app['versionName'] ?? 'Unknown';
        final String versionCode = app['versionCode'] ?? 'Unknown';
        final String cacheSize = app['cacheSize'] ?? '0';
        final String dataSize = app['dataSize'] ?? '0';
        final String appSize = app['appSize'] ?? '0';
        final String installDate = app['installDate'] ?? 'Unknown';
        final String lastUpdateDate = app['lastUpdateDate'] ?? 'Unknown';
        final String uninstallIntent = app['uninstallIntent'] ?? '';

        final String? appIconBase64 = app['appIcon'];
        final Uint8List appIcon =
            appIconBase64 != null && appIconBase64.isNotEmpty
                ? base64Decode(appIconBase64)
                : Uint8List(0); // Fallback to empty icon

        appList.add({
          'appName': appName,
          'packageName': packageName,
          'version': version,
          'versionCode': versionCode,
          'cacheSize': cacheSize,
          'dataSize': dataSize,
          'appSize': appSize,
          'installDate': installDate,
          'lastUpdateDate': lastUpdateDate,
          'uninstallIntent': uninstallIntent,
          'appIcon': appIcon,
        });
      }

      setState(() {
        _installedApps = appList;
        _filteredApps = appList; // Initially show all apps
      });
    } on PlatformException catch (e) {
      setState(() {
        _installedApps = [
          {"appName": "Failed to load apps", "error": e.message}
        ];
      });
    }
  }

  // Fetch device info from the native side
  Future<void> _getDeviceInfo() async {
    setState(() {
      _isLoading = true; // Show loading indicator while fetching device info
    });

    try {
      final Map<dynamic, dynamic> deviceInfo =
          await platform.invokeMethod('getDeviceInfo');

      // Process the device info and display it
      setState(() {
        _deviceInfo = 'Model: ${deviceInfo['deviceInfo']['model']}\n'
            'Manufacturer: ${deviceInfo['deviceInfo']['manufacturer']}\n'
            'Hardware: ${deviceInfo['deviceInfo']['hardware']}\n'
            'Android Version: ${deviceInfo['androidVersion']}\n'
            'Android ID: ${deviceInfo['androidID']}\n'
            'Screen Resolution: ${deviceInfo['screenResolution']['width']}x${deviceInfo['screenResolution']['height']}\n'
            'Screen Size: ${deviceInfo['screenSize']} inches';
      });
    } on PlatformException catch (e) {
      setState(() {
        _deviceInfo = "Failed to get device info: '${e.message}'";
      });
    }

    setState(() {
      _isLoading = false; // Hide loading indicator after fetching the data
    });
  }

  // Other methods...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AppSearchDelegate(_installedApps),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceInfoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Show loading indicator while fetching data
            _isLoading ? const CircularProgressIndicator() : Container(),

            // Display Storage Info
            const SizedBox(height: 10),
            Text(_storageInfo),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StorageInfoWidget()));
                      },
                      child: const Text('Get Storage Info')),
                ],
              ),
            ),

            // Display Battery Level
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('Get Battery Level'),
            ),
            Text(_batteryLevel),

            const SizedBox(height: 20),

            // Display Junk Files
            ElevatedButton(
              onPressed: _getJunkFiles,
              child: const Text('Get Junk Files'),
            ),
            Text(_junkFiles),

            const SizedBox(height: 20),

            // Display Device Info
            ElevatedButton(
              onPressed: _getDeviceInfo, // Fetch device info on button press
              child: const Text('Get Device Info'),
            ),
            Text(_deviceInfo), // Show the fetched device info

            const SizedBox(height: 20),

            // Button to fetch installed apps
            ElevatedButton(
              onPressed: _getInstalledApps,
              child: const Text('Get Installed Apps'),
            ),
            // Displaying the list of apps
            Expanded(
              child: ListView.builder(
                itemCount: _filteredApps.length,
                itemBuilder: (context, index) {
                  final app = _filteredApps[index];
                  return Column(
                    children: [
                      ListTile(
                        leading:
                            app['appIcon'] != null && app['appIcon'].isNotEmpty
                                ? Image.memory(app['appIcon'],
                                    width: 40, height: 40)
                                : const Icon(Icons.app_blocking),
                        title: Text(app['appName']),
                        subtitle: Text(
                          'Package: ${app['packageName']}\n'
                          'Version: ${app['version']}\n'
                          'Version Code: ${app['versionCode']}\n',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _uninstallApp(app['uninstallIntent']);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cache Size: ${app['cacheSize']}'),
                            Text('Data Size: ${app['dataSize']}'),
                            Text('App Size: ${app['appSize']}'),
                            Text('Install Date: ${app['installDate']}'),
                            Text('Last Update: ${app['lastUpdateDate']}'),
                            Text('Uninstall Intent: ${app['uninstallIntent']}'),
                            const Divider(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Other methods...
  Future<void> _uninstallApp(String packageName) async {
    try {
      await platform.invokeMethod('uninstallApp', {'packageName': packageName});
    } on PlatformException catch (e) {
      debugPrint("Error uninstalling app: ${e.message}");
    }
  }
}
