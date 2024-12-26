import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/app_icon.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

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
        actions: [
          AppIcon(
            width: 50.w,
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // EasyDateTimeLine(initialDate: initialDate)
            Text('hello'),
            EasyDateTimeLine(initialDate: DateTime.now(), onDateChange: (DateTime date) {  },) ,
          ],
        ),
      ),
      body:  Column(
        children: [
          EasyDateTimeLine(initialDate: DateTime.now(), onDateChange: (DateTime date) {  }, timeLineProps: EasyTimeLineProps(

            decoration: BoxDecoration(
              // color: Colors.grey
            )
          ),dayProps: EasyDayProps(
            inactiveDayStyle: DayStyle(
              decoration: BoxDecoration(
                color: Colors.grey ,
                borderRadius: BorderRadius.all(
                  Radius.circular(100.r),
                ),
              )
            )
          ),)  ,
          SizedBox(
            height: 16.h,
          ) ,
          const TodayProgressContainer() ,
          SizedBox(
            height: 16.h,
          ) ,
          Row(
            children: [
              Text('Today Activity' , style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16.sp , color: Colors.black),),
              Spacer(),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
        ],
      ),
    );
  }
}
