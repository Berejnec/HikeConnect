import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconTextRow({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const Gap(8.0),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16.0))),
      ],
    );
  }
}
