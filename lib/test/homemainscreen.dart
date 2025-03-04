import 'package:flutter/material.dart';
import 'package:testing_cleaner_app/test/home_screen2.dart';
import 'package:testing_cleaner_app/test/premium_screen.dart';
import 'package:testing_cleaner_app/test/speed_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override 
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track selected index

  // List of mock screens (pages)
  final List<Widget> _pages = [
    const HomeScreen2(),
    const PremiumScreen(),
    const SpeedScreen(),
  ];

  // Method to change the selected page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the current page
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 30, left: 40, right: 40, top: 10),
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // First icon (Home)
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: Container(
                  padding: _selectedIndex == 0
                      ? const EdgeInsets.all(25)
                      : const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 6, 135, 190)
                        : Colors.white, // Highlight when selected
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(Icons.clean_hands_rounded, color: _selectedIndex == 0
                        ? Colors.white
                        : const Color.fromARGB(255, 6, 135, 190)
                        ),
                ),
              ),
              // Second icon (Premium)
              GestureDetector(
                onTap: () => _onItemTapped(1),
                child: Container(
                  padding: _selectedIndex == 1
                      ? const EdgeInsets.all(25)
                      : const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color.fromARGB(255, 6, 135, 190)
                        : Colors.white, // Highlight when selected
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: _selectedIndex == 1
                        ? Colors.white
                        : const Color.fromARGB(255, 6, 135, 190),
                  ),
                ),
              ),
              // Third icon (Speed)
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Container(
                  padding: _selectedIndex == 2
                      ? const EdgeInsets.all(25)
                      : const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedIndex ==2 ?const Color.fromARGB(255, 6, 135, 190) : Colors.white , // Highlight when selected
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.speed,
                    color: _selectedIndex == 2
                        ? Colors.white
                        : const Color.fromARGB(255, 6, 135, 190),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
