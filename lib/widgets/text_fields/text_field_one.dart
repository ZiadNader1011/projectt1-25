import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart'; // 👈 Import for input formatter

class TextFeildOne extends StatelessWidget {
  const TextFeildOne({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.secure,
    this.allowOnlyAlphanumeric = false,
    this.onChanged,
    this.inputFormatters, // 👈 Add this
    this.keyboardType, // 👈 And this
    this.validator,

  });

  final TextEditingController controller;
  final String label;
  final Widget? icon;
  final bool? secure;
  final bool allowOnlyAlphanumeric;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  final List<TextInputFormatter>? inputFormatters; // 👈 New
  final TextInputType? keyboardType; // 👈 New

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters ??
          (allowOnlyAlphanumeric
              ? [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))]
              : null),
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        suffixIcon: icon,
      ),
      obscureText: secure ?? false,
      onChanged: onChanged,
    );
  }
}
