// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOTUq_DnDpLFkgP3mNXoqPJGPJofYoGUo',
    appId: '1:376999450516:web:b388fbea642ebb54806181',
    messagingSenderId: '376999450516',
    projectId: 'hikeconnect',
    authDomain: 'hikeconnect.firebaseapp.com',
    storageBucket: 'hikeconnect.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBF4kWRAbe0682qyX0a4jaTEEahnPdyBYg',
    appId: '1:376999450516:android:405dfde802c09e5c806181',
    messagingSenderId: '376999450516',
    projectId: 'hikeconnect',
    storageBucket: 'hikeconnect.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDchwi9LRrXj5l5ZF1cXuawYb0DoeM_rtE',
    appId: '1:376999450516:ios:a7f9c0f5c66dcc43806181',
    messagingSenderId: '376999450516',
    projectId: 'hikeconnect',
    storageBucket: 'hikeconnect.appspot.com',
    androidClientId: '376999450516-i8aufg9pca4m12df7jihuspj8eifdovk.apps.googleusercontent.com',
    iosClientId: '376999450516-3ra5528m3p16nhvfn6q6a5eegb10ia86.apps.googleusercontent.com',
    iosBundleId: 'com.hikeconnect.hikeConnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDchwi9LRrXj5l5ZF1cXuawYb0DoeM_rtE',
    appId: '1:376999450516:ios:b490e3a3584e3d85806181',
    messagingSenderId: '376999450516',
    projectId: 'hikeconnect',
    storageBucket: 'hikeconnect.appspot.com',
    androidClientId: '376999450516-i8aufg9pca4m12df7jihuspj8eifdovk.apps.googleusercontent.com',
    iosClientId: '376999450516-fd6ek1hr3etunb799ehj2gkj8ab7jdj1.apps.googleusercontent.com',
    iosBundleId: 'com.hikeconnect.hikeConnect.RunnerTests',
  );
}