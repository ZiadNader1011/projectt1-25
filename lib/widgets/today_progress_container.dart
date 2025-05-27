import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodayProgressContainer extends StatelessWidget {
  final String progressText;
  final Widget? child; // New optional child

  const TodayProgressContainer({
    super.key,
    required this.progressText,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        color: const Color(0xffECE6F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bills.png',
                width: 40.w,
                height: 40.h,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Today’s Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        color: Colors.black,
                      ),
                    ),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (child != null) ...[
            SizedBox(height: 12.h),
            child!,
          ],
        ],
      ),
    );
  }
}
