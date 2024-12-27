import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/day_check_box.dart';

import '../widgets/app_button.dart';
import '../widgets/app_icon.dart';
import '../widgets/text_feilds/app_drop_dowen_two.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  List<bool> isSelected = [false, false, false, false, false, false, false];
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  void _onItemTapped(int index) {
    setState(() {
      isSelected[index] = !isSelected[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                AppIcon(
                  width: 100.w,
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(
                  child: AppDropDowenTwo(
                    label: 'Dose',
                    widget: ImageIcon(AssetImage('assets/images/icon_7.png')),
                  ),
                ),
                Expanded(
                  child: AppDropDowenTwo(
                    label: 'VIEW',
                    widget: Icon(Icons.visibility),
                  ),
                ),
              ],
            ),
            const AppDropDowenTwo(
              label: 'How to Use',
              widget: ImageIcon(
                AssetImage('assets/images/icon_8.png'),
                size: 45,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AppDropDowenTwo(
                    label: 'Begin',
                    widget: Image.asset('assets/images/icon_9.png'),
                  ),
                ),
                Expanded(
                  child: AppDropDowenTwo(
                    label: 'End',
                    widget: Image.asset('assets/images/icon_9.png'),
                  ),
                ),
              ],
            ),
            const AppDropDowenTwo(
              label: 'Drug type',
              widget: ImageIcon(
                AssetImage('assets/images/icon_8.png'),
                size: 45,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(color: Colors.white, fontSize: 36.sp),
                  ),
                ),
                AppButton(
                  width: 103.w,
                  radius: 28,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white),
                      Text('play')
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: DayCheckBox(
                      label: days[index],
                      isSelected: isSelected[index],
                    ),
                  );
                },
                itemCount: days.length,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: AppButton(
                // width: 103.w,
                radius: 28,
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 36.sp),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40.h,
            )
          ],
        ),
      ),
    );
  }
}
