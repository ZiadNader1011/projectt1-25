/*
 * Copyright (c) 2023 Biwesh Shrestha
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MyCalenderItem extends StatelessWidget {
  const MyCalenderItem({
    super.key,
    required this.index,
    required this.startDate,
    required this.initialDate,
    required this.selectedDate,
    required this.textColor,
    required this.selectedColor,
    required this.backgroundColor,
    required this.locale,
    required this.onDatePressed,
  });

  final int index;
  final DateTime startDate;
  final DateTime initialDate;
  final DateTime selectedDate;
  final Color textColor;
  final Color selectedColor;
  final Color backgroundColor;
  final Locale locale;
  final VoidCallback onDatePressed;

  @override
  Widget build(BuildContext context) {
    DateTime date = startDate.add(Duration(days: index));
    int diffDays = date.difference(selectedDate).inDays;
    int checkPastDate = date.difference(initialDate).inDays;

    return Container(
      width: 70.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: diffDays != 0 ? backgroundColor : selectedColor,
          borderRadius: BorderRadius.circular(16.r)),
      child: TextButton(
        onPressed: onDatePressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat.d(locale.toString()).format(date),
            ),
            SizedBox(height: 10.0.h),
            Text(
              DateFormat.E(locale.toString()).format(date),
            ),
          ],
        ),
      ),
    );
  }
}
