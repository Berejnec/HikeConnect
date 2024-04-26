import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RowInfo extends StatelessWidget {
  final String info;
  final Widget? icon;

  const RowInfo({super.key, required this.info, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (icon != null) icon!,
        const Gap(12),
        Expanded(
          child: Text(
            info,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
