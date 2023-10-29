import 'package:flutter/material.dart';

class HikesScreen extends StatelessWidget {
  const HikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('hikes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hikes'),
      ),
      body: const Center(
        child: Text('Hikes Screen'),
      ),
    );
  }
}
