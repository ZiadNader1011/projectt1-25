import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/create_account_caregiver.dart';
import 'package:project/screens/create_account_patient.dart';
import '../widgets/SignupButton.dart';
import '../widgets/app_icon.dart'; // Assuming AppIcon exists

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF74b9cd), // Light blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          AppIcon(width: 200.w),
          SizedBox(height: 20.h),
          Text(
            'Sign up',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40.h),

          // ✨ Use SignupButton
          SignupButton(
            text: 'Sign Up as Patient',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateAccountPatient()),
            ),
          ),

          SizedBox(height: 30.h),

          SignupButton(
            text: 'Sign Up as Caregiver',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateAccountCaregiver()),
            ),
          ),
        ],
      ),
    );
  }
}
