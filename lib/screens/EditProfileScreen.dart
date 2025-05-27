import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentEmail;
  final String currentPhone;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _emailController.text = widget.currentEmail;
    _phoneController.text = widget.currentPhone;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return phone.length == 10;
  }

  Future<void> updateUserProfile() async {
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid email format")));
      return;
    }

    if (!_isValidPhone(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Phone number must be 10 digits")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      await userDoc.update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context); // Go back to the Profile screen after update
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Color(0xff34516b), // Blue background for the header
        elevation: 0,
      ),
      backgroundColor: Color(0xff6aaac5), // Blue background for the screen
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : AssetImage('assets/images/icon_1.png'),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Update your information',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              SizedBox(height: 30.h),

              // Name field with icon
              _buildTextField(_nameController, 'Name', TextInputType.name, Icons.person),
              SizedBox(height: 16.h),

              // Email field with icon
              _buildTextField(_emailController, 'Email', TextInputType.emailAddress, Icons.email),
              SizedBox(height: 16.h),

              // Phone field with icon
              _buildTextField(_phoneController, 'Phone', TextInputType.phone, Icons.phone),
              SizedBox(height: 30.h),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : updateUserProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black), // Black text for clarity
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black), // Ensure text is black in the text fields
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // White background for text fields
        labelText: label,
        labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black), // Black text for labels
        prefixIcon: Icon(icon, color: Colors.black), // Add icon to the left of the input field
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      ),
    );
  }
}
