import 'package:flutter/material.dart';

class HikeColor {
  const HikeColor._();

  static const Color primaryColor = Color(0xFF127C0E);
  static Color bgLoginColor = Colors.green.shade200;
  static Color green = Colors.green.shade300;

  static const Color secondaryColor = Color(0xFF6F7C80);
  static const Color tertiaryColor = Color(0xFFA1A7AC);
  static Color? fourthColor = Colors.grey[300];

  static const Color infoColor = Color(0xFF0E7C7C);
  static const Color infoLightColor = Color(0xFFA5D8D8);
  static const Color infoDarkColor = Color(0xFF005151);

  static const Color warningColor = Color(0xFFFFA500);
  static const Color warningLightColor = Color(0xFFFFD700);
  static const Color warningDarkColor = Color(0xFF8B6000);

  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorLightColor = Color(0xFFFF6659);
  static const Color errorDarkColor = Color(0xFF9A0007);

  static const Color white = Colors.white;

  static List<Color> gradientColors = [
    HikeColor.primaryColor.withOpacity(0.8),
    const Color(0xFF248922).withOpacity(0.8),
    const Color(0xFF379535).withOpacity(0.8),
    const Color(0xFF4AA249).withOpacity(0.8),
    const Color(0xFF5CAE5D).withOpacity(0.8),
    const Color(0xFF6FBB70).withOpacity(0.8)
  ];

  static List<Color> bottomBarGradientColors = [
    const Color(0xFF63B857).withOpacity(1),
    const Color(0xFF4AA249).withOpacity(1),
    const Color(0xFF317D3B).withOpacity(1),
  ];
}
