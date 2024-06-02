import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/services/HikeService.dart';
import 'package:hike_connect/theme/hike_color.dart';

void main() {
  group('HikeService', () {
    test('returns correct icon and color for "mic" difficulty', () {
      Icon icon = HikeService.getDifficultyIcon('mic');
      expect(icon.icon, Icons.star_outline);
      expect(icon.color, Colors.green);
    });

    test('returns correct icon and color for "mediu" difficulty', () {
      Icon icon = HikeService.getDifficultyIcon('mediu');
      expect(icon.icon, Icons.star_half);
      expect(icon.color, HikeColor.infoColor);
    });

    test('returns correct icon and color for "mare" difficulty', () {
      Icon icon = HikeService.getDifficultyIcon('mare');
      expect(icon.icon, Icons.star);
      expect(icon.color, Colors.red);
    });

    test('returns correct icon and color for unknown difficulty', () {
      Icon icon = HikeService.getDifficultyIcon('unknown');
      expect(icon.icon, Icons.stars_rounded);
      expect(icon.color, HikeColor.infoDarkColor);
    });
  });
}
