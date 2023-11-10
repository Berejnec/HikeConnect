import 'package:flutter/material.dart';
import 'package:hike_connect/theme/hike_color.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text('Pagina pentru vizualizarea altor utilizatori.\n'
                    'Share extern anumite informatii: poze/trasee'),
                Divider(height: 48),
                Card(
                  elevation: 5,
                  margin: EdgeInsets.zero,
                  color: HikeColor.secondaryColor,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adrian Berejnec',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Incepator',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          child: Text('A'),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 48),
                Text(
                  'Info text',
                  style: TextStyle(color: HikeColor.infoColor),
                ),
                Text(
                  'Info light text',
                  style: TextStyle(color: HikeColor.infoLightColor),
                ),
                Text(
                  'Info dark text',
                  style: TextStyle(color: HikeColor.infoDarkColor),
                ),
                Text(
                  'Warning text',
                  style: TextStyle(color: HikeColor.warningColor),
                ),
                Text(
                  'Warning light text',
                  style: TextStyle(color: HikeColor.warningLightColor),
                ),
                Text(
                  'Warning dark text',
                  style: TextStyle(color: HikeColor.warningDarkColor),
                ),
                Text(
                  'Error text',
                  style: TextStyle(color: HikeColor.errorColor),
                ),
                Text(
                  'Error light text',
                  style: TextStyle(color: HikeColor.errorLightColor),
                ),
                Text(
                  'Error dark text',
                  style: TextStyle(color: HikeColor.errorDarkColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
