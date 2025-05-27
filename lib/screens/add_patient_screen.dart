import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_button.dart';
import '../widgets/app_icon.dart';
import '../widgets/text_fields/text_field_one.dart';
import 'add_medicine_screen.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool agree = false;
  List<String> medications = [];

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  Future<void> _addPatient() async {
    if (!_formKey.currentState!.validate() || !agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and accept terms.')),
      );
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final docRef = await FirebaseFirestore.instance.collection('patients').add({
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'phone': phoneNumber.text.trim(),
        'caregiverId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'medications': medications,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient added successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AddMedicineScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding patient: $e')),
      );
    }
  }

  void _navigateToAddMedication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        medications.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Patient"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(child: AppIcon(width: 160.w)),
              SizedBox(height: 20.h),

              // Name Fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFeildOne(
                          controller: firstName,
                          label: 'First Name',
                          validator: (value) =>
                          value!.trim().isEmpty ? 'First name is required' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      children: [
                        TextFeildOne(
                          controller: lastName,
                          label: 'Last Name',
                          validator: (value) =>
                          value!.trim().isEmpty ? 'Last name is required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Phone Field
              TextFeildOne(
                controller: phoneNumber,
                label: 'Phone Number',
                icon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.trim().isEmpty ? 'Phone number is required' : null,
              ),
              SizedBox(height: 20.h),

              // Medication
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Medication', style: TextStyle(fontSize: 16.sp)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: _navigateToAddMedication,
                  ),
                ],
              ),
              if (medications.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: medications.map((med) {
                      return Chip(
                        label: Text(med),
                        backgroundColor: Colors.teal.shade100,
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 12.h),

              // Agreement
              Row(
                children: [
                  Checkbox(
                    shape: const CircleBorder(),
                    value: agree,
                    onChanged: (value) => setState(() => agree = value ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the terms and conditions',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // NEXT Button
              AppButton(
                radius: 20.r,
                width: double.infinity,
                height: 48.h,
                onTap: _addPatient,
                child: Center(
                  child: Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
