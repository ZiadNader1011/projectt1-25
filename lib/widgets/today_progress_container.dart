import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodayProgressContainer extends StatelessWidget {
  const TodayProgressContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w , vertical: 20.h),
      clipBehavior: Clip.antiAlias,
      height: 100.h,
      decoration: BoxDecoration(
borderRadius: BorderRadius.circular(60),
        color: Color(0xffECE6F0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/bills.png'),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Today Progress' , style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16.sp , color: Colors.black),),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Current plane' , style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16.sp , color: Colors.black),),
                  Icon(Icons.arrow_forward_ios_rounded)
                ],
              )

            ],
          ) ,
          Spacer(),
          Text('2/3' , style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 46.sp , color: Colors.black),)
        ],
      ),
    );
  }
}
