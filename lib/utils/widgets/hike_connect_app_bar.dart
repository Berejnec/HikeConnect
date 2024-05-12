import 'package:flutter/material.dart';
import 'package:hike_connect/theme/hike_color.dart';

class HikeConnectAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const HikeConnectAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, 0.5),
        ),
      ),
      centerTitle: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HikeColor.gradientColors,
          ),
        ),
      ),
    );
  }
}
