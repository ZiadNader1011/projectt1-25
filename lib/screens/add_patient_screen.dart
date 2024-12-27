import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/app_button.dart';
import 'package:project/widgets/app_icon.dart';

import '../widgets/text_feilds/text_field_one.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  bool agree = false;
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController dropDownController = TextEditingController();
  bool isSecure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.exit_to_app)),
      ),
      body: Padding(
        // padding: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(width: 200.w),
              ],
            ),
            AppButton(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(),
                Text(
                  'Add Patient',
                  style: TextStyle(fontSize: 20.sp),
                ),
                Icon(Icons.arrow_drop_down_sharp)
              ],
            )),
            SizedBox(
              height: 20.h,
            ),
            AppButton(
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(),
                    Text(
                      'Enter His current medication',
                      style: TextStyle(fontSize: 20.sp, color: Colors.black),
                    ),
                    Icon(Icons.arrow_drop_down_sharp)
                  ],
                )),
            SizedBox(
              height: 20.h,
            ),
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
            SizedBox(
              height: 12.h,
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
            ImageIcon(
              AssetImage('assets/images/Face_ID.png'),
              color: Colors.white,
              size: 60,
            ),
            Spacer(),
            AppButton(
                child: Center(
              child: Text(
                'Add Patient',
                style: TextStyle(fontSize: 20.sp),
              ),
            )),
            SizedBox(
              height: 30.h,
            )
          ],
        ),
      ),
    );
  }
}
