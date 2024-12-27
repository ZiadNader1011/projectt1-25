import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.ending,
      this.onTap});
  final String title;
  final Widget icon;
  final Widget ending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        height: 56.h,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.32),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            )),
        child: Row(
          children: [
            icon,
            SizedBox(width: 12.w),
            Text(title),
            Spacer(),
            ending
          ],
        ),
      ),
    );
  }
}
