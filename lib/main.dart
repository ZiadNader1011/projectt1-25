import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/core/style/app_theme.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/on_boarding_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1) Initialize Firebase Core
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAlW2mqjNpHHdbTf9hLnrUKAsBe-7VAFVc',
          appId: '1:220092453832:android:9ea27e774110c72a0ba6fd',
          messagingSenderId: '220092453832',
          projectId: 'project1-25',
        ),
      );
    }


    await FirebaseAppCheck.instance.activate(
      androidProvider: kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,

    );

    if (kDebugMode) {
      final debugToken = await FirebaseAppCheck.instance.getToken(true);
      print('🔥 App Check Debug Token (use this for custom debug builds): $debugToken');
    }
  } catch (e) {
    print('❌ Error initializing Firebase/App Check: $e');
  }

  runApp(const HealtronApp());
}

class HealtronApp extends StatelessWidget {
  const HealtronApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, __) {
        return MaterialApp(
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          home: const AuthGate(),
        );
      },
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const HomeScreen();       // user is logged in
        } else {
          return const OnBoardingScreen(); // user not logged in
        }
      },
    );
  }
}

