import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/forget_password_screen.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/signup_screen.dart';

import '../widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  bool isSecure = true;
  bool remember = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_icon.png',
                  height: 180.h,
                ),
              ],
            ),
            Text(
              'Sign in',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w400),
            ),
            Text(
              'enter your email or phone number',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0.w),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.circle_rounded,
                      color: Colors.green,
                    ),
                    border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white, width: 2.w))),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0.w),
              child: Row(
                children: [
                  Text(
                    'password',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0.w),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isSecure = !isSecure;
                          });
                        },
                        icon: Icon(
                          isSecure ? Icons.visibility_off : Icons.visibility,
                        )),
                    border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white, width: 2.w))),
                obscureText: isSecure,
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: remember,
                  onChanged: (value) {
                    setState(() {
                      remember = value!;
                    });
                  },
                  // fillColor: WidgetStatePropertyAll(
                  //   Colors.white,
                  //   Theme.of(context).colorScheme.primary,
                  // ),
                  activeColor: Colors.white,

                  checkColor: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ForgetPasswordScreen(),
                      ));
                    },
                    child: Text('Forgot Password?',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        )))
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ));
                  },
                  child: AppButton(
                    width: 230.w,
                    child: Center(
                      child: Text('LOGIN',
                          style: TextStyle(
                              fontSize: 32.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                const ImageIcon(
                  AssetImage('assets/images/Face_ID.png'),
                  size: 60,
                  color: Colors.white,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ));
                    },
                    child: Text(
                      'don\'t have an account?',
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4F4F4F)),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ));
                    },
                    child: Text(
                      'Create an account!',
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary),
                    ))
              ],
            ),
            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  Positioned(
                    top: 25.h,
                    left: 0,
                    right: 0,
                    bottom: 25.h,
                    child: const Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(100.r),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              AppButton(
                width: 170.w,
                height: 60.h,
                child: Center(
                  child: Text(
                    'connect as caregiver',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 50.0,
              ),
            ])
          ],
        ),
      ),
    );
  }
}
