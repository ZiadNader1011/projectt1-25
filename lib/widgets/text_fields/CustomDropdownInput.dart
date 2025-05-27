import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownInput extends StatefulWidget {
  final String label;
  final Widget icon;
  final List<String> options;
  final Function(String?)? onChanged;
  final String? selectedValue;
  final String? Function(String?)? validator;
  final  String? selectedDose;
  const CustomDropdownInput({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.validator,
    this.selectedDose
  });

  @override
  State<CustomDropdownInput> createState() => _CustomDropdownInputState();
}

class _CustomDropdownInputState extends State<CustomDropdownInput> {
  late TextEditingController _controller;
  List<String> _filteredOptions = [];
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedValue);
    _filteredOptions = widget.options + ['Else']; // Add "Else" for custom input
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterOptions(String input) {
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(input.toLowerCase()))
          .toList();
      _filteredOptions.add('Else'); // Ensure "Else" is still in the list
    });
    widget.onChanged?.call(input); // Pass the user input directly to the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              children: [
                widget.icon,
                SizedBox(width: 8.w),
                Expanded(
                  child: !_isCustom
                      ? DropdownButtonFormField<String>(
                    isExpanded: true, // Ensure the dropdown takes full width
                    value: widget.selectedValue,
                    iconEnabledColor: Colors.white,
                    dropdownColor: Colors.white, // Set dropdown color to black or any other color
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    validator: widget.validator,
                    items: _filteredOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == "Else") {
                        setState(() {
                          _isCustom = true; // Switch to custom input when "Else" is selected
                        });
                      } else {
                        _controller.text = value ?? '';
                        widget.onChanged?.call(value);
                      }
                    },
                  )
                      : TextFormField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: _filterOptions, // Filters options as user types
                    validator: widget.validator,
                    onFieldSubmitted: (value) {
                      widget.onChanged?.call(value); // Pass custom value to parent widget
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
