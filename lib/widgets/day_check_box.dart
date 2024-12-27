import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DayCheckBox extends StatelessWidget {
  const DayCheckBox({super.key, required this.label, required this.isSelected});
  final String label;
  final bool isSelected;

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 20.sp, color: Colors.black),
          ),
          CircleAvatar(
            backgroundColor: isSelected ? Colors.green : Colors.white,
            child: Icon(Icons.check),
          )
        ],
      ),
    );
  }
}
