import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropDowenOne extends StatefulWidget {
  const DropDowenOne(
      {super.key, required this.controller, required this.label});
  final TextEditingController controller;
  final String label;
  @override
  State<DropDowenOne> createState() => _DropDowenOneState();
}

class _DropDowenOneState extends State<DropDowenOne> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.all(
          Radius.circular(5.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
      child: DropdownButton(
        isExpanded: true,
        style: TextStyle(color: Colors.white, fontSize: 20.sp),
        hint: Text(
          widget.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        borderRadius: BorderRadius.circular(5.r),
        dropdownColor: Theme.of(context).colorScheme.primary,
        items: <DropdownMenuItem<Object>>[
          DropdownMenuItem(value: 1, child: Text('a')),
          DropdownMenuItem(value: 2, child: Text('b')),
          DropdownMenuItem(value: 3, child: Text('c')),
          DropdownMenuItem(value: 4, child: Text('d')),
          DropdownMenuItem(value: 5, child: Text('e')),
          DropdownMenuItem(value: 6, child: Text('f')),
        ],
        onChanged: (value) {},
      ),
    );
  }
}
