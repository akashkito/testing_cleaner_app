import 'package:flutter/material.dart';

class BirthDayCardClipper extends CustomClipper<Path> {
  @override
Path getClip(Size size) {
  var path = Path();

  double borderRadius = 20.0; // Border radius of the folder
  double slantWidth = 7.0; // Width of the slant from the center

  // Start at the bottom-left corner
  path.moveTo(0, size.height);

  // Bottom-left corner
  path.lineTo(0, borderRadius);

  // Left vertical side with rounded corner
  path.quadraticBezierTo(0, 0, borderRadius, 0);

  // Left side of the slant (curved from the center)
  path.lineTo((size.width / 2) - slantWidth, 0); // Left part of the slant

  // Top-center slant (curved)
  path.quadraticBezierTo(size.width * 0.5, size.height * 0.9,
      size.width * 0.3, size.height * 0.2);

  // Straight 90-degree right side from the top
  path.lineTo(size.width, size.height * 0.2); // 90-degree straight line to the top-right

  // Bottom-right corner
  path.lineTo(size.width, size.height - borderRadius);

  // Bottom-right corner with rounded corner
  path.quadraticBezierTo(size.width, size.height, size.width - borderRadius, size.height);

  // Bottom-left corner
  path.lineTo(borderRadius, size.height);

  // Bottom-left corner with rounded corner
  path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

  path.close();

  return path;
}

@override
bool shouldReclip(CustomClipper<Path> oldClipper) => false;

}
