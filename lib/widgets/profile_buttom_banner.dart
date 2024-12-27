import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/add_medicine_screen.dart';
import 'package:project/widgets/medicine_item.dart';

import '../screens/add_patient_screen.dart';

class ProfileBottomBanner extends StatelessWidget {
  const ProfileBottomBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        height: 420.h,
        decoration: const BoxDecoration(
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MedicineItem(
                    color: Color(0xffffffff),
                    label: 'spring',
                    quantity: '10mg'),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddMedicineScreen(),
                ));
              },
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
            ),
            SizedBox(
              height: 10.h,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddPatientScreen(),
                ));
              },
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
                    'add patient',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 30.sp,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
