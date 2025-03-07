import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedScreen extends StatefulWidget {
  const SpeedScreen({super.key});

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

  // Store history of previous speed tests
  List<Map<String, String>> _speedHistory = [];

  // Store the timestamp of the last speed test
  DateTime? _lastTestTimestamp;

  // Function to start the speed test
  Future<void> _startSpeedTest() async {
    final currentTime = DateTime.now();

    // Only run the speed test if at least 10 seconds have passed since the last test
    if (_lastTestTimestamp == null ||
        currentTime.difference(_lastTestTimestamp!).inSeconds >= 1) {
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
          double downloadMbps =
              double.tryParse(downloadSpeed.split(' ')[0]) ?? 0.0;
          double uploadMbps = double.tryParse(uploadSpeed.split(' ')[0]) ?? 0.0;

          double downloadKbps = downloadMbps * 1000;
          double uploadKbps = uploadMbps * 1000;
          double downloadGbps = downloadMbps / 1000;
          double uploadGbps = uploadMbps / 1000;

          // Update speed displays based on selected unit
          String downloadText =
              _getSpeedInUnit(downloadMbps, downloadKbps, downloadGbps);
          String uploadText =
              _getSpeedInUnit(uploadMbps, uploadKbps, uploadGbps);

          setState(() {
            _downloadSpeed = downloadText;
            _uploadSpeed = uploadText;
            _networkType = networkType;
            _isTesting = false;
            _lastTestTimestamp = currentTime;
          });

// Format the current date and time into yyyy-MM-dd HH:mm
          String formattedDateTime =
              '${currentTime.year.toString().padLeft(4, '0')}-'
              '${currentTime.month.toString().padLeft(2, '0')}-'
              '${currentTime.day.toString().padLeft(2, '0')} '
              '${currentTime.hour.toString().padLeft(2, '0')}:'
              '${currentTime.minute.toString().padLeft(2, '0')}';

// Save the result in the history list with the formatted date and time
          _speedHistory.insert(0, {
            'download': downloadText,
            'upload': uploadText,
            'networkType': networkType,
            'timestamp':
                formattedDateTime, // Store the date and time in yyyy-MM-dd HH:mm format
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
    } else {
      // If the speed test was conducted too recently, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Set padding inside the SnackBar
          elevation: 10,
          backgroundColor: Colors.white,
          content: Text(
            'Please wait at least 10 seconds before retesting',
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
          // Customizing margin and position
          margin: const EdgeInsets.all(20), // Margin around the Snackbar
          showCloseIcon: true,
          closeIconColor: Colors.black,
          behavior:
              SnackBarBehavior.floating, // To make it floating and customizable
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Optional, for rounded corners
          ),
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

  // Function to clear the speed test history
  void _clearHistory() {
    setState(() {
      _speedHistory.clear();
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Speed Test',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _downloadSpeed = '0.00 Mbps';
                      _uploadSpeed = '0.00 Mbps';
                      _networkType = 'Unknown';
                    });
                  },
                  child: const Icon(
                    Icons.restart_alt_rounded,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: _clearHistory,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 30,
                  ),
                )
              ],
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        'Network Type: ',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _networkType,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            _isTesting
                ? Container(
                    height: 150,
                    child: const Center(child: CircularProgressIndicator()),
                  ) // Show loading indicator when testing
                : SizedBox(
                    height: 150,
                    child: GestureDetector(
                      onTap: _startSpeedTest,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                                // color: Colors.greenAccent,
                                border: Border.all(
                                  width: 4,
                                  color: Colors.greenAccent,
                                ),
                                borderRadius: BorderRadius.circular(
                                  100,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "GO",
                                style: GoogleFonts.montserrat(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        _downloadSpeed,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Download Speed',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        _uploadSpeed,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Upload Speed',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
// Speed unit selection (chips instead of dropdown)
            Wrap(
              spacing: 10.0,
              children: ['Mbps', 'kbps', 'Gbps'].map((unit) {
                return ChoiceChip(
                  label: Text(
                    unit,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: _selectedUnit == unit,
                  onSelected: (selected) {
                    setState(() {
                      _selectedUnit = unit;
                    });
                    // No need to reload the speed test, just update the displayed unit
                    _startSpeedTest();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Display speed test history
            Expanded(
              child: ListView.builder(
                itemCount: _speedHistory.length,
                itemBuilder: (context, index) {
                  var history = _speedHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${history['networkType']}',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${history['timestamp']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.download_rounded,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                Text(
                                  '${history['download']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.upload_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                Text(
                                  '${history['upload']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );

                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
