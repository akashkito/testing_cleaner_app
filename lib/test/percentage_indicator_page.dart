import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PercentIndicatorPage extends StatefulWidget {
  final Future<void> loadingTask; // The task to show progress for
  final Widget targetPage; // The page to navigate to after loading is complete

  const PercentIndicatorPage({
    Key? key,
    required this.loadingTask,
    required this.targetPage,
  }) : super(key: key);

  @override
  _PercentIndicatorPageState createState() => _PercentIndicatorPageState();
}

class _PercentIndicatorPageState extends State<PercentIndicatorPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  // Simulate loading and update progress
  Future<void> _simulateLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          _progress = i / 100.0; // Update progress percentage
        });
      });
    }

    // Once the task is complete, navigate to the target page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget.targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loading..."),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 50.0, // Size of the indicator
              lineWidth: 6.0, // Width of the line
              percent: _progress,
              center: Text(
                "${(_progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blue,
              backgroundColor: Colors.grey[300]!,
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading, please wait...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
