import 'package:flutter/material.dart';

class TsClip1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 4 - 20,
      size.height - 70,
      size.width / 2,
      size.height - 30,
    );
    path.quadraticBezierTo(
      3 / 4 * size.width + 35,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
