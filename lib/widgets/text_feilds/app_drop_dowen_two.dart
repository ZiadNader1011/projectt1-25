import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDropDowenTwo extends StatefulWidget {
  const AppDropDowenTwo({super.key, required this.label, required this.widget});
  final String label;
  final Widget widget;

  @override
  State<AppDropDowenTwo> createState() => _AppDropDowenTwoState();
}

class _AppDropDowenTwoState extends State<AppDropDowenTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          widget.widget,
          SizedBox(
            width: 10.w,
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: Colors.black,
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            // Ensure DropdownButton gets proper constraints
            child: DropdownButton(
              isExpanded: true,
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
              hint: Text(
                widget.label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              borderRadius: BorderRadius.circular(5.r),
              dropdownColor: Theme.of(context).colorScheme.onPrimary,
              underline: const SizedBox(),
              items: const <DropdownMenuItem<Object>>[
                DropdownMenuItem(
                    value: 1,
                    child: Text(
                      'a',
                      style: TextStyle(color: Colors.black),
                    )),
                DropdownMenuItem(
                    value: 2,
                    child: Text('b', style: TextStyle(color: Colors.black))),
                DropdownMenuItem(
                    value: 3,
                    child: Text('c', style: TextStyle(color: Colors.black))),
                DropdownMenuItem(
                    value: 4,
                    child: Text('d', style: TextStyle(color: Colors.black))),
                DropdownMenuItem(
                    value: 5,
                    child: Text('e', style: TextStyle(color: Colors.black))),
                DropdownMenuItem(
                    value: 6,
                    child: Text('f', style: TextStyle(color: Colors.black))),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
