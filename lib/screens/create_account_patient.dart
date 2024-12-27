import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/login_screen.dart';

import '../widgets/app_button.dart';
import '../widgets/app_icon.dart';
import '../widgets/text_feilds/app_drop_dowen_one.dart';
import '../widgets/text_feilds/text_field_one.dart';

class CreateAccountPatient extends StatefulWidget {
  const CreateAccountPatient({super.key});

  @override
  State<CreateAccountPatient> createState() => _CreateAccountPatientState();
}

class _CreateAccountPatientState extends State<CreateAccountPatient> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController dropDownController = TextEditingController();
  bool isSecure = true;
  bool agree = false;

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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                width: 170.w,
              ),
            ],
          ),
          // Row(
          //   children: [
          //     SizedBox(
          //       height: 26.h,
          //     ),
          //   ],
          // ),
          Text(
            'Create an account',
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
          // SizedBox(
          //   height: 26.h,
          // ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
            },
            child: Text(
              'Already have an account?',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
            },
            child: Text(
              'LOGIN!',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 29.0.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: TextFeildOne(
                        controller: firstName,
                        label: 'First Name',
                      )),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                          child: TextFeildOne(
                        controller: lastName,
                        label: 'Last Name',
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  TextFeildOne(
                    controller: phoneNumber,
                    label: 'phone number',
                    icon: Icon(Icons.phone),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  TextFeildOne(
                    controller: password,
                    label: 'PASSWORD',
                    icon: IconButton(
                      icon: Icon(
                          isSecure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        isSecure = !isSecure;
                        setState(() {});
                      },
                    ),
                    secure: isSecure,
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  DropDowenOne(
                    label: 'What medication are you currently on? ',
                    controller: dropDownController,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(children: [
                    Checkbox(
                      shape: const CircleBorder(),
                      checkColor: Colors.black26,
                      value: agree,
                      onChanged: (value) {
                        setState(() {
                          agree = value!;
                        });
                      },
                    ),
                    Text(
                      'I agree to the terms and conditions ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ]),
                  const ImageIcon(
                    AssetImage('assets/images/Face_ID.png'),
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  AppButton(
                    width: 360.w,
                    child: Center(
                      child: Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
