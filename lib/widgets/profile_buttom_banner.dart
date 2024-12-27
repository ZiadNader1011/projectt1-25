import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/medicine_item.dart';

class ProfileBottomBanner extends StatelessWidget {
  const ProfileBottomBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        height: 420.h,
        decoration: BoxDecoration(
            color: Color(0xff3B5998),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            )),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/icon_5.png',
                  height: 80.h,
                ),
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Current medication',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30.sp,
                      color: Colors.black),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MedicineItem(
                    color: Color(0xffffffff),
                    label: 'spring',
                    quantity: '10mg'),
              ],
            ),
            GestureDetector(
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/icon_6.png',
                    height: 80.h,
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Text(
                    'add medicine',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 30.sp,
                        color: Colors.black),
                  ),
                ],
              ),
            )
          ]),
        ));
  }
}
