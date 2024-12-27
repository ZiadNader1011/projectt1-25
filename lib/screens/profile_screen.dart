import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/profile_buttom_banner.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Row(
          children: [
            ImageIcon(
              AssetImage(
                'assets/images/icon_1.png',
              ),
              size: 60,
            ),
            SizedBox(
              width: 15.w,
            ),
            Column(
              children: [Text('Name'), Text('patient')],
            ),
            Spacer(),
            IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
          ],
        ),
        SizedBox(
          height: 20.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0.w),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.black),
                  ),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 50,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Text(
                    'Name',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.black,
                    size: 50,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Text(
                    'contact',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Icon(
                    Icons.mail,
                    color: Colors.black,
                    size: 50,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Text(
                    'email',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.black),
                  ),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 27.w, vertical: 8.h),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.32),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      )),
                  height: 56.h,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Image.asset('assets/images/icon_4.png'),
                      Spacer(),
                      Image.asset('assets/images/icon_2.png'),
                      Spacer(),
                      Image.asset('assets/images/icon_3.png'),
                    ],
                  )),
            ],
          ),
        ),
        Spacer(),
        ProfileBottomBanner()
      ])),
    );
  }
}
