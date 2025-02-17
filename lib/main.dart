import 'package:flutter/material.dart';
import 'package:testing_cleaner_app/test/home_screen2.dart';
import 'package:testing_cleaner_app/test/homemainscreen.dart';
import 'test/view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      home: MainScreen(),
    );
  }
}
  
