import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/on_boarding_screen.dart';

import 'core/style/app_theme.dart';

class HealtronApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        title: 'Material App',
        theme: AppTheme.theme,
        home: const OnBoardingScreen(),
      ),
    );
  }
}
