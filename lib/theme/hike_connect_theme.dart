import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hike_connect/theme/hike_color.dart';

class HikeConnectTheme {
  const HikeConnectTheme._();

  static ThemeData getPrimaryTheme() {
    return _primaryTheme.copyWith(
      textTheme: GoogleFonts.ptSansTextTheme(_primaryTheme.textTheme),
    );
  }

  static final ThemeData _primaryTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: HikeColor.primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: HikeColor.secondaryColor,
      foregroundColor: Colors.white,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: HikeColor.white,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: MaterialStatePropertyAll(HikeColor.primaryColor),
        fixedSize: MaterialStatePropertyAll(Size.fromHeight(200)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: HikeColor.infoColor,
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.white,
      actionsPadding: EdgeInsets.only(right: 8.0),
    ),
  );
}
