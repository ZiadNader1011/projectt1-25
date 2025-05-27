import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DayCheckBox extends StatelessWidget {
  const DayCheckBox({
    super.key,
    required this.label,
    required this.isSelected,
    this.time = '', // <-- optional time string
  });

  final String label;
  final bool isSelected;
  final String time; // <-- time to display under the day

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 90.h,
      width: 80.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 20.sp, color: Colors.black),
          ),
          SizedBox(height: 6.h),
          CircleAvatar(
            radius: 14.r,
            backgroundColor: isSelected ? Colors.green : Colors.white,
            child: Icon(Icons.check, size: 16.sp, color: isSelected ? Colors.white : Colors.black),
          ),
          if (time.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              time,
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}
