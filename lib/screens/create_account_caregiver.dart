import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/widgets/app_icon.dart';
import '../widgets/text_fields/text_field_one.dart';
import 'AuthRegistrationService.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:local_auth/local_auth.dart';
import '../helper/auth_service.dart';

class CreateAccountCaregiver extends StatefulWidget {
  const CreateAccountCaregiver({super.key});

  @override
  State<CreateAccountCaregiver> createState() => _CreateAccountCaregiverState();
}

class _CreateAccountCaregiverState extends State<CreateAccountCaregiver> {
  // --- Text Editing Controllers ---
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController(); // Added confirm password controller
  final TextEditingController emailController =
  TextEditingController(); // Added email controller

  // --- State Variables ---
  bool isSecure = true;
  bool isConfirmSecure = true;
  String passwordStrength = '';
  String? passwordError;
  String? confirmPasswordError;
  XFile? _analysisReport;
  String? selectedAnalysisFilePath;
  final int _maxFileSizeMB = 5;
  bool _newAccountCreated = false;
  bool _biometricAvailable = false;
  bool _agreedToTerms = false; // Track agreement to terms

  // --- Formatter ---
  final phoneFormatter = MaskTextInputFormatter(
    mask: '+###############',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // --- Subjects ---
  final BehaviorSubject<String> _passwordSubject = BehaviorSubject<String>();

  // --- Local Authentication and Storage ---
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // --- initState ---
  @override
  void initState() {
    super.initState();
    _passwordSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((value) {
      setState(() {
        passwordStrength = checkPasswordStrength(value);
      });
    });
    _checkBiometricAvailability();
  }

  // --- dispose ---
  @override
  void dispose() {
    _passwordSubject.close();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // --- Check Biometric Availability ---
  Future<void> _checkBiometricAvailability() async {
    final available = await _localAuth.canCheckBiometrics;
    setState(() {
      _biometricAvailable = available;
    });
  }

  // --- Password Strength Check ---
  String checkPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    if (password.length < 8) return 'Medium';
    return 'Strong';
  }

  // --- Phone Number Validation ---
  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[+]*[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  // --- Pick Analysis Report ---
  Future<void> pickAnalysisReport() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final File file = File(result.files.first.path!);
      final fileSizeMB = await file.length() / (1024 * 1024);

      if (fileSizeMB > _maxFileSizeMB) {
        showSnack('File size exceeds the limit of $_maxFileSizeMB MB');
        return;
      }

      setState(() {
        _analysisReport = XFile(file.path);
        selectedAnalysisFilePath = _analysisReport!.path;
      });
    } else {
      showSnack('No file selected');
    }
  }

  // --- Show Snackbar ---
  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  // --- Handle Account Creation ---
  Future<void> handleCreateAccount() async {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showSnack('Please fill in all required fields');
      return;
    }

    if (!isValidPhoneNumber(phoneNumberController.text)) {
      showSnack('Invalid phone number');
      return;
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      showSnack('Invalid email format');
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() => passwordError = 'Password must be at least 6 characters');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => confirmPasswordError = 'Passwords do not match');
      return;
    }

    if (!_agreedToTerms) {
      showSnack('Please agree to the Terms & Conditions and Privacy Policy');
      return;
    }

    final authService = AuthRegistrationService(
      context: context,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      emailController: emailController,
      passwordController: passwordController,
      setFirstNameError: (error) {
        if (mounted) setState(() {});
      },
      setLastNameError: (error) {
        if (mounted) setState(() {});
      },
      setEmailError: (error) {
        if (mounted) setState(() {});
      },
      setPasswordError: (error) {
        if (mounted) setState(() => passwordError = error);
      },
      setAgree: (agree) {
        if (mounted) setState(() => _agreedToTerms = agree ?? false);
      },
      setSelectedAnalysisFilePath: (path) {
        if (mounted) setState(() => selectedAnalysisFilePath = path);
      },
      secureStorage: _secureStorage,
      auth: _localAuth,
      setNewAccountCreated: (created) {
        if (mounted) setState(() => _newAccountCreated = created);
      },
      biometricAvailableGetter: () => _biometricAvailable,
    );

    await authService.registerUser();
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: AppIcon(width: 120.w)),
            SizedBox(height: 15.h),
            Text('Create an account',
                style: TextStyle(
                    fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                    style: TextStyle(fontSize: 14.sp)),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen())),
                  child: Text('Login!',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(
                    child: TextFeildOne(
                        controller: firstNameController, label: 'First Name')),
                SizedBox(width: 10.w),
                Expanded(
                    child: TextFeildOne(
                        controller: lastNameController, label: 'Last Name')),
              ],
            ),
            SizedBox(height: 15.h),
            TextFeildOne(
              controller: emailController,
              label: 'Email',
              icon: const Icon(Icons.email),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15.h),
            TextFeildOne(
              controller: phoneNumberController,
              label: 'Phone Number',
              icon: const Icon(Icons.phone),
              inputFormatters: [phoneFormatter],
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 15.h),
            TextFeildOne(
              controller: passwordController,
              label: 'Password',
              secure: isSecure,
              icon: IconButton(
                icon: Icon(isSecure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => isSecure = !isSecure),
              ),
              onChanged: (val) =>
                  _passwordSubject.add(val), // Use the subject for debouncing
            ),
            if (passwordStrength.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Text('Password Strength: $passwordStrength',
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: _getPasswordStrengthColor(passwordStrength))),
              ),
            if (passwordError != null)
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Text(passwordError!,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp)),
              ),
            SizedBox(height: 15.h),
            TextFeildOne(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              secure: isConfirmSecure,
              icon: IconButton(
                icon: Icon(isConfirmSecure
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => isConfirmSecure = !isConfirmSecure),
              ),
            ),
            if (confirmPasswordError != null)
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Text(confirmPasswordError!,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp)),
              ),
            SizedBox(height: 20.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 45.h,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: pickAnalysisReport,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      selectedAnalysisFilePath == null
                          ? 'Upload Analysis Report (Optional)'
                          : 'Change Analysis Report',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                if (selectedAnalysisFilePath != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'File selected: ${selectedAnalysisFilePath!.split('/').last}',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreedToTerms = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                      children: [
                        const TextSpan(
                            text: 'By creating an account, you agree to our '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          // You can add a TapGestureRecognizer here to open the terms
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          // You can add a TapGestureRecognizer here to open the policy
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: handleCreateAccount,
              child: Container(
                width: double.infinity,
                height: 45.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFF00C853),
                    Color(0xFF64DD17)
                  ]),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Center(
                  child: Text('Create Account',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // --- Get Password Strength Color ---
  Color _getPasswordStrengthColor(String strength) {
    if (strength == 'Weak') return Colors.red;
    if (strength == 'Medium') return Colors.orange;
    if (strength == 'Strong') return Colors.green;
    return Colors.grey;
  }
}



