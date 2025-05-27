import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/on_boarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/style/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';


// GlobalKey for HealtronApp
final GlobalKey<_HealtronAppState> healtronAppKey = GlobalKey<_HealtronAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyAlW2mqjNpHHdbTf9hLnrUKAsBe-7VAFVc',
        appId: '1:220092453832:android:9ea27e774110c72a0ba6fd',
        messagingSenderId: '220092453832',
        projectId: 'project1-25',
      ),
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Handle initialization failure, maybe show a message or retry
  }

  // Load saved language preferences
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('languageCode') ?? 'en';

  runApp(HealtronApp(initialLocale: Locale(langCode)));  // Pass the locale
}

class HealtronApp extends StatefulWidget {
  final Locale initialLocale;

  const HealtronApp({super.key, this.initialLocale = const Locale('en')});  // Default to English

  @override
  State<HealtronApp> createState() => _HealtronAppState();
}

class _HealtronAppState extends State<HealtronApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Healtron App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasData) {
                return const HomeScreen();
              } else {
                return const OnBoardingScreen();
              }
            },
          ),
        );
      },
    );
  }
}
