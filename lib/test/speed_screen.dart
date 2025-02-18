// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SpeedScreen extends StatefulWidget {
//   @override
//   _SpeedScreenState createState() => _SpeedScreenState();
// }

// class _SpeedScreenState extends State<SpeedScreen> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   String _downloadSpeed = '0.00 Mbps';
//   String _uploadSpeed = '0.00 Mbps';
//   String _networkType = 'Unknown';
//   bool _isTesting = false;

//   // Function to start the speed test
//   Future<void> _startSpeedTest() async {
//     setState(() {
//       _isTesting = true;
//     });

//     try {
//       // Call the native code to start the speed test
//       final dynamic result = await platform.invokeMethod('startSpeedTest');

//       // Ensure the result is a Map<String, String>
//       if (result is Map<dynamic, dynamic>) {
//         setState(() {
//           _downloadSpeed = result['download']?.toString() ?? '0.00 Mbps';
//           _uploadSpeed = result['upload']?.toString() ?? '0.00 Mbps';
//           _networkType = result['networkType']?.toString() ?? 'Unknown';
//           _isTesting = false;
//         });
//       } else {
//         throw Exception('Invalid result format');
//       }
//     } on PlatformException catch (e) {
//       setState(() {
//         _downloadSpeed = 'Error';
//         _uploadSpeed = 'Error';
//         _networkType = 'Unknown';
//         _isTesting = false;
//       });
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to start speed test: ${e.message}'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _downloadSpeed = 'Error';
//         _uploadSpeed = 'Error';
//         _networkType = 'Unknown';
//         _isTesting = false;
//       });
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text('Error'),
//           content: Text('An unexpected error occurred: ${e.toString()}'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Speed Test'),
//       ),
//       body: Center(
//         child: _isTesting
//             ? CircularProgressIndicator() // Show loading indicator when testing
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     'Network Type: $_networkType',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Download Speed: $_downloadSpeed',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Upload Speed: $_uploadSpeed',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 40),
//                   ElevatedButton(
//                     onPressed: _startSpeedTest,
//                     child: Text('Start Speed Test'),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _downloadSpeed = '0.00 Mbps';
//                         _uploadSpeed = '0.00 Mbps';
//                         _networkType = 'Unknown';
//                       });
//                     },
//                     child: Text('Reset Test'),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeedScreen extends StatefulWidget {
  @override
  _SpeedScreenState createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  String _downloadSpeed = '0.00 Mbps';
  String _uploadSpeed = '0.00 Mbps';
  String _networkType = 'Unknown';
  bool _isTesting = false;
  
  // Speed unit selection (kbps, mbps, gbps)
  String _selectedUnit = 'Mbps'; // Default to Mbps
  
  // Function to start the speed test
  Future<void> _startSpeedTest() async {
    setState(() {
      _isTesting = true;
    });

    try {
      // Call the native code to start the speed test
      final dynamic result = await platform.invokeMethod('startSpeedTest');

      // Ensure the result is a Map<String, String>
      if (result is Map<dynamic, dynamic>) {
        String downloadSpeed = result['download']?.toString() ?? '0.00 Mbps';
        String uploadSpeed = result['upload']?.toString() ?? '0.00 Mbps';
        String networkType = result['networkType']?.toString() ?? 'Unknown';

        // Convert the speed values to different units
        double downloadMbps = double.tryParse(downloadSpeed.split(' ')[0]) ?? 0.0;
        double uploadMbps = double.tryParse(uploadSpeed.split(' ')[0]) ?? 0.0;

        double downloadKbps = downloadMbps * 1000;
        double uploadKbps = uploadMbps * 1000;
        double downloadGbps = downloadMbps / 1000;
        double uploadGbps = uploadMbps / 1000;

        // Update speed displays based on selected unit
        String downloadText = _getSpeedInUnit(downloadMbps, downloadKbps, downloadGbps);
        String uploadText = _getSpeedInUnit(uploadMbps, uploadKbps, uploadGbps);

        setState(() {
          _downloadSpeed = downloadText;
          _uploadSpeed = uploadText;
          _networkType = networkType;
          _isTesting = false;
        });
      } else {
        throw Exception('Invalid result format');
      }
    } on PlatformException catch (e) {
      setState(() {
        _downloadSpeed = 'Error';
        _uploadSpeed = 'Error';
        _networkType = 'Unknown';
        _isTesting = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to start speed test: ${e.message}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _downloadSpeed = 'Error';
        _uploadSpeed = 'Error';
        _networkType = 'Unknown';
        _isTesting = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('An unexpected error occurred: ${e.toString()}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Get the speed in the selected unit (kbps, Mbps, or Gbps)
  String _getSpeedInUnit(double mbps, double kbps, double gbps) {
    switch (_selectedUnit) {
      case 'kbps':
        return '${kbps.toStringAsFixed(2)} Kbps';
      case 'Gbps':
        return '${gbps.toStringAsFixed(2)} Gbps';
      case 'Mbps':
      default:
        return '${mbps.toStringAsFixed(2)} Mbps';
    }
  }

  @override
  void initState() {
    super.initState();
    // Automatically start the speed test when the screen loads
    _startSpeedTest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Test'),
        actions: <Widget>[
          // Dropdown for selecting the speed unit (kbps, Mbps, or Gbps)
          DropdownButton<String>(
            value: _selectedUnit,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                _selectedUnit = newValue!;
              });
              _startSpeedTest(); // Re-run the test with the new unit
            },
            items: <String>['Mbps', 'kbps', 'Gbps']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Center(
        child: _isTesting
            ? const CircularProgressIndicator() // Show loading indicator when testing
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Network Type: $_networkType',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Download Speed: $_downloadSpeed',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Upload Speed: $_uploadSpeed',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _startSpeedTest,
                    child: const Text('Start Speed Test'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _downloadSpeed = '0.00 Mbps';
                        _uploadSpeed = '0.00 Mbps';
                        _networkType = 'Unknown';
                      });
                    },
                    child: const Text('Reset Test'),
                  ),
                ],
              ),
      ),
    );
  }
}

