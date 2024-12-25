import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {super.key,
      required this.child,
      this.width,
      this.height,
      this.color,
      this.radius});
  final Widget child;
  final double? width;
  final double? height;
  final Color? color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 317.w,
      height: height ?? 50.h,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.all(
          Radius.circular(radius ?? 5.r),
        ),
      ),
      child: child,
    );
  }
}
