import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../screens/AuthRegistrationService.dart';

import '../helper/auth_service.dart';
import '../screens/login_screen.dart';


mixin CreateAccountLogic<T extends StatefulWidget> on State<T> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  bool isSecure = true;
  bool agree = false;
  String? selectedAnalysisFilePath;
  String passwordStrength = "";

  AuthRegistrationService get registrationService;
  Future<void> Function() get authenticateUserCallback;
  Future<String> Function(String) get encryptData;
  Future<void> Function(String, String) get storeEncryptedDataLocally;
  Future<void> Function(String, String, String) get savePatientDataLocally;
  Future<void> Function() get pickAndEncryptAnalysisFileMethod;
  void Function(String) get checkPasswordStrengthMethod;
  BuildContext get currentContext;

  void togglePasswordVisibility() {
    setState(() {
      isSecure = !isSecure;
    });
  }

  void updateAgreement(bool? value) {
    setState(() {
      agree = value ?? false;
    });
  }

  void updateSelectedAnalysisFile(String? path) {
    setState(() {
      selectedAnalysisFilePath = path;
    });
  }

  Future<void> pickAndEncryptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      updateSelectedAnalysisFile(filePath);
      try {
        final file = File(filePath);
        final fileContent = await file.readAsString();
        final encryptedContent = await encryptData(fileContent);
        await storeEncryptedDataLocally(encryptedContent, 'analysis_report.enc');
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Encrypted report saved locally!')),
        );
      } catch (e) {
        print('Error reading or encrypting file: $e');
      }
    }
  }

  void checkPassword(String password) {
    checkPasswordStrengthMethod(password);
  }

  Future<void> registerAccount() async {
    setState(() {
      firstNameError = firstNameController.text.isEmpty ? 'First name is required' : null;
      lastNameError = lastNameController.text.isEmpty ? 'Last name is required' : null;
      emailError = emailController.text.isEmpty ? 'Email is required' : null;
      passwordError = passwordController.text.isEmpty ? 'Password is required' : null;
    });

    if ([firstNameError, lastNameError, emailError, passwordError].any((e) => e != null)) return;

    final emailTrimmed = emailController.text.trim();
    final passwordTrimmed = passwordController.text.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(emailTrimmed)) {
      setState(() => emailError = 'Invalid email format');
      return;
    }
    if (passwordTrimmed.length < 6) {
      setState(() => passwordError = 'Password must be at least 6 characters');
      return;
    }
    if (!agree) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and conditions')),
      );
      return;
    }

    await registrationService.registerUser();
  }

  Future<void> triggerBiometricLogin() async {
    final result = await AuthService.biometricLogin();
    if (result == 'success') {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Login successful via fingerprint')),
      );
    } else {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text(result ?? 'Authentication error')),
      );
    }
  }

  void navigateToLoginScreen() {
    Navigator.pushReplacement(currentContext, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }
}