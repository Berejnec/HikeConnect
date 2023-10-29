import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('social');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
      ),
      body: const Center(
        child: Text('Social Screen'),
      ),
    );
  }
}
