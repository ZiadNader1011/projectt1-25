import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/app_icon.dart';
import 'package:project/widgets/drawer_list.dart';

import '../widgets/medicine_item.dart';
import '../widgets/today_progress_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        forceMaterialTransparency: true,
        actions: [
          AppIcon(
            width: 50.w,
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        width: MediaQuery.of(context).size.width,
        child: const DrawerList(),
      ),
      body: Column(
        children: [
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (DateTime date) {},
            timeLineProps: EasyTimeLineProps(
                decoration: BoxDecoration(
                    // color: Colors.grey
                    )),
            dayProps: EasyDayProps(
                inactiveDayStyle: DayStyle(
                    decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(
                Radius.circular(100.r),
              ),
            ))),
          ),
          SizedBox(
            height: 16.h,
          ),
          const TodayProgressContainer(),
          SizedBox(
            height: 16.h,
          ),
          Row(
            children: [
              Text(
                'Today Activity',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.black),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
          SizedBox(
            height: 306.h,
            child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return MedicineItem(
                      label: 'ketoprofen',
                      quantity: '2 mg',
                      color: Colors.green);
                }),
          )
        ],
      ),
    );
  }
}
