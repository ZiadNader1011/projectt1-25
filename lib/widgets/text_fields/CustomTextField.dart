import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.fillColor = Colors.white,  // Default background color
    this.textColor = Colors.black,  // Default text color
  });

  final TextEditingController controller;
  final String label;
  final Color fillColor;
  final Color textColor;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});  // Rebuild to reflect focus changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.all(
          Radius.circular(22.r),
        ),
        border: Border.all(
          color: _focusNode.hasFocus ? Colors.blue : Colors.transparent,  // Focus effect
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,  // Attach the focus node
        style: TextStyle(color: widget.textColor, fontSize: 20.sp),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: "",  // Empty hint text to avoid background placeholder text
          labelStyle: TextStyle(
            color: widget.textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}
