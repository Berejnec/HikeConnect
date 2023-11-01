import 'package:flutter/material.dart';
import 'package:hike_connect/theme/hike_color.dart';

class HikesScreen extends StatelessWidget {
  const HikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasee'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Text(
                'Lista trasee montane Romania (document oficial de la Ministru)\nTraseele mele preferate\nNavigare catre detaliile unui traseu\n',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              const Divider(height: 48),
              FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(HikeColor.primaryColor),
                ),
                child: const Text('Primary button'),
              ),
              FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(HikeColor.secondaryColor),
                ),
                child: const Text('Secondary button'),
              ),
              FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(HikeColor.tertiaryColor),
                ),
                child: const Text('Tertiary button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
