import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/login_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icon.dart';
import '../widgets/text_fields/text_field_one.dart';


class CreateAccountWidgets {
  static Widget buildTopSection({
    required BuildContext context,
    required TextEditingController firstNameController,
    required String? firstNameError,
    required TextEditingController lastNameController,
    required String? lastNameError,
    required TextEditingController emailController,
    required String? emailError,
    required TextEditingController passwordController,
    required bool isSecure,
    required VoidCallback onSecureToggle, // Changed to void Function(bool)
    required void Function(String) onPasswordChanged, // Changed to void Function(String)
    required String passwordStrength,
    required String? passwordError,
    required void Function() onUploadReportTap, // Changed to void Function()
    required String? selectedAnalysisFilePath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: AppIcon(width: 170.w)),
        SizedBox(height: 10.h),
        Text('Create an account', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 5.h),
        buildLoginButton(context),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFeildOne(controller: firstNameController, label: 'First Name'),
                  if (firstNameError != null) Text(firstNameError!, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFeildOne(controller: lastNameController, label: 'Last Name'),
                  if (lastNameError != null) Text(lastNameError!, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFeildOne(
                    controller: emailController,
                    label: 'Email',
                    icon: const Icon(Icons.email),
                  ),
                  if (emailError != null)
                    Text(
                      emailError!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFeildOne(
                    controller: passwordController,
                    label: 'Password',
                    secure: isSecure,
                    icon: IconButton(
                      icon: Icon(isSecure ? Icons.visibility_off : Icons.visibility),
                      onPressed: onSecureToggle,
                    ),
                    onChanged: onPasswordChanged,
                  ),
                  if (passwordError != null)
                    Text(
                      passwordError!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (passwordStrength.isNotEmpty)
          Text(
            'Password Strength: $passwordStrength',
            style: TextStyle(
              fontSize: 14.sp,
              color: passwordStrength == 'Weak'
                  ? Colors.red
                  : passwordStrength == 'Medium'
                  ? Colors.orange
                  : Colors.yellowAccent,
            ),
          ),
        SizedBox(height: 12.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton(
              onTap: onUploadReportTap,
              radius: 20.r,
              width: double.infinity,
              height: 45.h,
              color: Colors.white,
              child: Text(
                selectedAnalysisFilePath == null
                    ? 'Upload Analysis Report (optional)'
                    : 'Change Analysis Report',
                style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
            if (selectedAnalysisFilePath != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Encrypted file saved at:\n$selectedAnalysisFilePath',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  static Widget buildBottomSection({
    required bool agree,
    required void Function(bool?) onAgreeChanged, // Changed to void Function(bool?)
    required void Function() onBiometricTap, // Changed to void Function()
    required void Function() onNextTap, // Changed to void Function()
  }) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(value: agree, onChanged: onAgreeChanged),
            Expanded(child: Text('I agree to the terms and conditions', style: TextStyle(fontSize: 16.sp))),
          ],
        ),
        SizedBox(height: 20.h),

        GestureDetector(
          onTap: onNextTap,
          child: Container(
            width: double.infinity,
            height: 55.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF64DD17)]),
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: Center(
              child: Text('NEXT', style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildLoginButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      },
      child: Text('Already have an account? LOGIN!', style: TextStyle(fontSize: 16.sp, color: Colors.white70)),
    );
  }
}