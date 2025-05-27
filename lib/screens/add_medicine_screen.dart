import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/home_screen.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icon.dart';
import '../widgets/text_fields/CustomDropdownInput.dart';


class AddMedicineScreen extends StatefulWidget {
  final Map<String, dynamic>? medicine;
  final String? medicineDocId;


  const AddMedicineScreen({super.key, this.medicine, this.medicineDocId});



  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  List<bool> isSelected = [false, false, false, false, false, false, false];

  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  TextEditingController _beginController = TextEditingController();
  TextEditingController _endController = TextEditingController();

  String? selectedDrugType;
  String? selectedDose;
  String? selectedView;
  String? selectedUsage;
  bool isPlayActive = false;



  bool allDaysSelected = false;







  Map<String, List<TimeOfDay>> notificationTimes = {
    'Sun': [],
    'Mon': [],
    'Tue': [],
    'Wed': [],
    'Thu': [],
    'Fri': [],
    'Sat': [],
  };

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      final medicine = widget.medicine!;
      final beginTimestamp = medicine['begin_date'];
      final endTimestamp = medicine['end_date'];

      if (beginTimestamp is Timestamp) {
        _beginController.text = beginTimestamp.toDate().toString().split(' ')[0];
      }
      if (endTimestamp is Timestamp) {
        _endController.text = endTimestamp.toDate().toString().split(' ')[0];
      }

      selectedDrugType = medicine['medicine_name'];
      selectedDose = medicine['dose'];
      selectedView = medicine['view'];
      selectedUsage = medicine['how_to_use'];
      isPlayActive = medicine['notification_enabled'] ?? false;

      medicine['notification_times']?.forEach((day, timeList) {
        if (timeList != null && timeList is List) {
          for (var time in timeList) {
            final parts = time.split(":");
            if (parts.length == 2) {
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);
              if (hour != null && minute != null) {
                notificationTimes[day]?.add(TimeOfDay(hour: hour, minute: minute));
              }
            }
          }
        }
      });

      List<bool> selectedDays = List<bool>.from(medicine['selected_days'] ?? []);
      if (selectedDays.length == 7) {
        isSelected = selectedDays;
      }
    }
  }

  bool _validateInputs() {
    if (_beginController.text.isEmpty || _endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both begin and end dates')),
      );
      return false;
    }

    if (isSelected.every((selected) => !selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one day for notifications')),
      );
      return false;
    }

    // NEW VALIDATION: Ensure at least one notification time is selected for selected days
    bool hasAtLeastOneTime = false;
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i] && notificationTimes[days[i]]!.isNotEmpty) {
        hasAtLeastOneTime = true;
        break;
      }
    }

    if (!hasAtLeastOneTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one notification time for the selected days')),
      );
      return false;
    }

    return true;
  }


  Future<void> _saveDataToFirestore() async {
    if (!_validateInputs()) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in!')));
        return;
      }

      String userId = user.uid;

      DateTime? rawBegin = DateTime.tryParse(_beginController.text);
      DateTime? rawEnd = DateTime.tryParse(_endController.text);

      if (rawBegin == null || rawEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid date format')));
        return;
      }

      Map<String, List<String>> convertedTimes = {};
      for (int i = 0; i < isSelected.length; i++) {
        if (isSelected[i]) {
          final times = notificationTimes[days[i]];
          convertedTimes[days[i]] = times!.map((t) => t.format(context)).toList();
        }
      }

      Map<String, dynamic> entry = {
        'userId': userId,
        'medicine_name': selectedDrugType ?? 'Unnamed',
        'begin_date': Timestamp.fromDate(rawBegin),
        'end_date': Timestamp.fromDate(rawEnd),
        'dose': selectedDose ?? '5mg',
        'view': selectedView ?? '1 tablet',
        'how_to_use': selectedUsage ?? 'Before eating',
        'notification_times': convertedTimes,
        'selected_days': isSelected,
        'notification_enabled': isPlayActive,
        'created_at': FieldValue.serverTimestamp(),
      };

      if (widget.medicineDocId != null) {
        await FirebaseFirestore.instance.collection('medicines').doc(widget.medicineDocId).update(entry);
      } else {
        await FirebaseFirestore.instance.collection('medicines').add(entry);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medicine saved successfully!')));
      Navigator.pop(context, 'refresh');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Color(0xff6aaac5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.black),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: InputDecoration(border: InputBorder.none, hintText: 'Select date'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff6aaac5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    ),
                    Spacer(),
                    AppIcon(width: 100.w),
                  ],
                ),
                SizedBox(height: 16.h),


                _sectionTitle('Medicine Info'),

                Row(
                  children: [
                    Expanded(
                      child: CustomDropdownInput(
                        label: 'Dose',
                        icon: Image.asset('assets/images/icon_7.png', width: 24, height: 24),
                        options: ['5mg', '10mg', '20mg', '50mg'],
                        onChanged: (value) => setState(() => selectedDose = value),

                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomDropdownInput(
                        label: 'View',
                        icon: Icon(Icons.remove_red_eye),
                        options: ['1 tablet', '2 tablets', '3 tablets'],
                        onChanged: (value) => setState(() => selectedView = value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomDropdownInput(
                  label: 'How to Use',
                  icon: Image.asset('assets/images/icon_8.png', width: 24, height: 24),
                  options: ['Before eating', 'After eating', 'While eating'],
                  onChanged: (value) => setState(() => selectedUsage = value),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, _beginController),
                        child: _buildDateField('Begin Date', _beginController),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, _endController),
                        child: _buildDateField('End Date', _endController),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomDropdownInput(
                  label: 'Drug Type',
                  icon: Image.asset('assets/images/icon_8.png', width: 24, height: 24),
                  options: ['Paracetamol', 'Ibuprofen', 'Aspirin', 'Ciprofloxacin'],
                  onChanged: (value) => setState(() => selectedDrugType = value),
                ),

                SizedBox(height: 16.h),
                _sectionTitle('Notifications'),


                // Select All Days + Add Time to All Selected Days
                Row(
                  children: [
                    Checkbox(
                      value: allDaysSelected,
                      onChanged: (val) {
                        setState(() {
                          allDaysSelected = val!;
                          isSelected = List.generate(7, (_) => allDaysSelected);
                        });
                      },
                    ),
                    Text('Select All Days', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    Spacer(),
                    if (isSelected.contains(true))
                      ElevatedButton.icon(
                        icon: Icon(Icons.access_time, size: 18),
                        label: Text('Add Time to Days', style: TextStyle(fontSize: 12.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              for (int i = 0; i < isSelected.length; i++) {
                                if (isSelected[i] && !notificationTimes[days[i]]!.contains(picked)) {
                                  notificationTimes[days[i]]!.add(picked);
                                }
                              }
                            });
                          }
                        },
                      ),
                  ],
                ),

















                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Enable Notifications', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    Switch(
                      value: isPlayActive,
                      onChanged: (val) => setState(() => isPlayActive = val),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                Column(
                  children: days.asMap().entries.map((entry) {
                    int index = entry.key;
                    String day = entry.value;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected[index],
                                onChanged: (val) => setState(() => isSelected[index] = val!),
                              ),
                              Text(day, style: TextStyle(fontSize: 16.sp)),
                              Spacer(),
                              if (isSelected[index])
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => notificationTimes[day]!.add(picked));
                                    }
                                  },
                                ),
                            ],
                          ),
                          if (notificationTimes[day]!.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: notificationTimes[day]!.map((time) {
                                return Chip(
                                  label: Text(time.format(context)),
                                  onDeleted: () => setState(() => notificationTimes[day]!.remove(time)),
                                  backgroundColor: Colors.green.shade200,
                                  deleteIconColor: Colors.red,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),
                AppButton(
                  width: double.infinity,
                  height: 48.h,
                  radius: 28,
                  onTap: _saveDataToFirestore,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF27AE60),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}