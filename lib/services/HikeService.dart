import 'package:flutter/material.dart';
import 'package:hike_connect/theme/hike_color.dart';

class HikeService {
  static Icon getDifficultyIcon(String difficulty) {
    IconData icon;
    Color color;

    switch (difficulty.toLowerCase()) {
      case 'mic':
        icon = Icons.star_outline;
        color = Colors.green;
        break;
      case 'mediu':
        icon = Icons.star_half;
        color = HikeColor.infoColor;
        break;
      case 'mare':
        icon = Icons.star;
        color = Colors.red;
        break;
      default:
        icon = Icons.stars_rounded;
        color = HikeColor.infoDarkColor;
    }

    return Icon(icon, color: color);
  }
}
