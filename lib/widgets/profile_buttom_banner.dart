import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/add_medicine_screen.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/add_patient_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ProfileBottomBanner extends StatelessWidget {
  final String userId;

  ProfileBottomBanner({
    super.key,
    required this.userId,
  });

  // Encrypt the file
  Future<encrypt.Encrypted?> _encryptFile(File file) async {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.ctr),
    );

    try {
      final bytes = await file.readAsBytes();
      return encrypter.encryptBytes(bytes, iv: iv);
    } catch (e) {
      debugPrint("Error encrypting file: $e");
      return null;
    }
  }

  // Upload encrypted file to Firebase Storage
  Future<String?> _uploadFileToStorage(File file, String filename) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('analysis_reports/$filename');
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading file to storage: $e");
      return null;
    }
  }

  // Handle file upload
  Future<void> _handleFileUpload(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String filename = result.files.single.name;

      final encryptedData = await _encryptFile(file);
      if (encryptedData == null) {
        _showErrorDialog(context, "File encryption failed.");
        return;
      }

      final encryptedFile = File('${file.path}.encrypted');
      await encryptedFile.writeAsBytes(encryptedData.bytes);

      final downloadUrl = await _uploadFileToStorage(encryptedFile, filename);
      if (downloadUrl == null) {
        _showErrorDialog(context, "File upload failed.");
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'analysisReportUrl': downloadUrl,
        });
        _showSuccessSnackBar(context, "Analysis report uploaded successfully.");
      } catch (e) {
        debugPrint("Error updating Firestore: $e");
        _showErrorDialog(context, "Failed to update user data.");
      } finally {
        await encryptedFile.delete();
      }
    } else {
      _showErrorDialog(context, "No file selected.");
    }
  }

  // Open file if exists
  Future<void> _handleOpenFile(BuildContext context, String? fileUrl) async {
    if (fileUrl != null && fileUrl.isNotEmpty) {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(context, "Could not open file.");
      }
    } else {
      _handleFileUpload(context); // upload if file doesn't exist
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Text('User data not available', style: TextStyle(fontSize: 16.sp)),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] ?? 'patient';
        final analysisReportUrl = userData['analysisReportUrl'];

        List<Widget> options = [
          _buildOption(
            context,
            icon: Icons.medical_services_outlined,
            title: 'Current Medication',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen())),
          ),
          _buildOption(
            context,
            icon: Icons.add_circle_outline,
            title: 'Add Medicine',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddMedicineScreen())),
          ),
          _buildOption(
            context,
            icon: Icons.upload_file,
            title: (analysisReportUrl != null && analysisReportUrl.isNotEmpty)
                ? 'View Analysis Report'
                : 'Upload Analysis Report',
            onTap: () => _handleOpenFile(context, analysisReportUrl),
          ),
        ];

        if (role == 'caregiver') {
          options.add(
            _buildOption(
              context,
              icon: Icons.person_add_alt_1,
              title: 'Add Patient',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPatientScreen())),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ...options,
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32.sp, color: Colors.blueAccent),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}