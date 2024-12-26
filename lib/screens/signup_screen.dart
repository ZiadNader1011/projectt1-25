import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/app_button.dart';

import '../widgets/app_icon.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        // mainAxisAlignment: .center,
        children: [
          AppIcon(
            width: 200.w,
          ),
          Row(
            children: [
              SizedBox(
                height: 26.h,
              ),
            ],
          ),
          Text(
            'Sign up',
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 26.h,
          ),
          AppButton(
            width: 360.w,
            child: Center(
              child: Text(
                'Sign Up as parent',
              ),
            ),
          ),
          SizedBox(
            height: 46.h,
          ),
          AppButton(
            width: 360.w,
            child: Center(
              child: Text(
                'Sign up as caregiver',
              ),
            ),
          )
        ],
      ),
    );
  }
}
