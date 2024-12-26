import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFeildOne extends StatelessWidget {
  const TextFeildOne(
      {super.key,
      required this.controller,
      required this.label,
      this.icon,
      this.secure});
  final TextEditingController controller;
  final String label;
  final Widget? icon;
  final bool? secure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
          fillColor: Theme.of(context).colorScheme.primary,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide.none,
          ),
          // label: Text(label),
          suffixIcon: icon != null ? icon : null),
      obscureText: secure ?? false,
    );
  }
}
