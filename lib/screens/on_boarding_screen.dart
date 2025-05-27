import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/login_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Stack(
              children: [
                Image.asset('assets/images/bg_1.png'),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 190.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100.r),
                          ),
                          color: Color(0xff34516b),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0), // Optional for better look
                          child: Image.asset('assets/images/icoon.png'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "providing personalized care, timely medication reminders",
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 317.w,
              height: 55.h,
              decoration: BoxDecoration(
                color: Color(0xff34516b),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started For Free',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 28.0,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 120.h,
          ),
        ],
      ),
    );
  }
}
