import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hike_connect/theme/hike_color.dart';

class HikeConnectTheme {
  const HikeConnectTheme._();

  static ThemeData getPrimaryTheme() {
    return _primaryTheme.copyWith(
      textTheme: GoogleFonts.aBeeZeeTextTheme(_primaryTheme.textTheme),
    );
  }

  static final ThemeData _primaryTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: HikeColor.primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: HikeColor.secondaryColor,
      foregroundColor: Colors.white,
    ),
  );
}
