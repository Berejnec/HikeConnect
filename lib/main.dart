import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hike_connect/app_navigation_cubit.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/auth/splash_screen.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:hike_connect/theme/hike_connect_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:splash_view/splash_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HikeConnectApp());
}

class HikeConnectApp extends StatelessWidget {
  const HikeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.grey[300],
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<ScreenCubit>(create: (context) => ScreenCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: HikeConnectTheme.getPrimaryTheme(),
        home: SplashView(
          logo: Image.asset(
            'assets/logo.png',
            width: 120,
            height: 120,
          ),
          title: const Text('HikeConnect'),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HikeColor.gradientColors,
          ),
          loadingIndicator: const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: CircularProgressIndicator(),
          ),
          bottomLoading: true,
          done: Done(
            const SplashScreen(),
            animationDuration: const Duration(seconds: 2),
            curve: Curves.decelerate,
          ),
        ),
      ),
    );
  }
}
