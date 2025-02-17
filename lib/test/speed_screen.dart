import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeedScreen extends StatefulWidget {
  @override
  _SpeedScreenState createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  String _speedResult = 'Press button to start test';

  Future<void> _startSpeedTest() async {
    try {
      final String result = await platform.invokeMethod('startSpeedTest');
      setState(() {
        _speedResult = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _speedResult = "Failed to start speed test: '${e.message}'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speed Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_speedResult),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startSpeedTest,
              child: Text('Start Speed Test'),
            ),
          ],
        ),
      ),
    );
  }
}
