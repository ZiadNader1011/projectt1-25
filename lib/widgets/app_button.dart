import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,

    this.width,
    this.height,
    this.color,
    this.radius,
    this.onTap,
    this.elevation,

  });

  final Widget child;
  final double? width;
  final double? height;
  final Color? color;
  final double? radius;
  final double? elevation;
  final VoidCallback? onTap;


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Makes the background handled by Container
      elevation: elevation ?? 0,
      borderRadius: BorderRadius.circular(radius ?? 25.r),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width ?? 100.w,
          height: height ?? 30.h,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(radius ?? 25.r),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
