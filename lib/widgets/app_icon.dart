import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.width});
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_icon.png',
      width: width,
    );
  }
}
