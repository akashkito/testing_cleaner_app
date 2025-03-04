import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:testing_cleaner_app/test/homemainscreen.dart';

class LiquidSwipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = [
      const LiquidSwipePageContent(
        title: "Welcome to Our App!",
        image: 'assets/app_icon.png', // Your image or icon
        backgroundColor: Color.fromARGB(255, 114, 192, 255), // Set the background color for this page
      ),
      const LiquidSwipePageContent(
        title: "Stay Connected",
        image: 'assets/app_icon.png', // Your image or icon
        backgroundColor: Color.fromARGB(255, 141, 255, 145), // Set the background color for this page
      ),
      const LiquidSwipePageContent(
        title: "Get Started Now",
        image: 'assets/app_icon.png', // Your image or icon
        isLastPage: true,
        backgroundColor: Color.fromARGB(255, 237, 135, 255), // Set the background color for this page
      ),
    ];

    return Scaffold(
      body: LiquidSwipe(
        pages: pages,
        fullTransitionValue: 300, // Customize transition speed
        enableSideReveal: true,
      ),
    );
  }
}

class LiquidSwipePageContent extends StatelessWidget {
  final String title;
  final String image;
  final bool isLastPage;
  final Color backgroundColor; // New backgroundColor parameter

  const LiquidSwipePageContent({
    required this.title,
    required this.image,
    this.isLastPage = false,
    required this.backgroundColor, // Require the background color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor, // Set the background color
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image), // Image or icon here
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (isLastPage) 
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const MainScreen()));
                  },
                  child: const Text("Go to Home"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
