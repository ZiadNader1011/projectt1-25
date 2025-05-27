import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:project/screens/verify_code_screen.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:async'; // For Timer

import '../widgets/app_icon.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  String? phoneNumberWithCountryCode;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _canResendOtp = false;
  int _resendCountdown = 30; // Initial countdown time in seconds
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _startResendTimer() {
    setState(() {
      _canResendOtp = false;
      _resendCountdown = 30;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResendOtp = true;
        });
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_canResendOtp && phoneNumberWithCountryCode != null && phoneNumberWithCountryCode!.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumberWithCountryCode!,
          verificationCompleted: (PhoneAuthCredential credential) {
            print("Verification completed automatically (resend)");
            _showSnackBar('Verification completed automatically');
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Resend Verification failed: $e');
            _showSnackBar('Failed to resend OTP. Please try again later.', isError: true);
          },
          codeSent: (String verificationId, int? resendToken) {
            print("OTP resent to $phoneNumberWithCountryCode");
            _showSnackBar('OTP resent to your phone number');
            _startResendTimer(); // Start the timer again after resend
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyCodeScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumberWithCountryCode!,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print("Auto-retrieval timed out (resend)");
            _showSnackBar('Auto-retrieval timed out. Please enter the code manually.');
            setState(() {
              _isLoading = false;
            });
          },
        );
      } catch (e) {
        print("Error resending OTP: $e");
        _showSnackBar('Failed to resend OTP. Please try again later.', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (!_canResendOtp) {
      _showSnackBar('Please wait for the countdown to finish before resending.', isError: true);
    } else {
      _showSnackBar('Please enter a valid phone number first.', isError: true);
    }
  }

  void sendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      if (phoneNumberWithCountryCode == null ||
          phoneNumberWithCountryCode!.isEmpty) {
        _showSnackBar('Please enter a valid phone number', isError: true);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumberWithCountryCode!,
          verificationCompleted: (PhoneAuthCredential credential) {
            print("Verification completed automatically");
            _showSnackBar('Verification completed automatically');
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Verification failed: $e');
            _showSnackBar('Failed to send OTP. Please check the number and try again.', isError: true);
          },
          codeSent: (String verificationId, int? resendToken) {
            print("OTP sent to $phoneNumberWithCountryCode");
            _showSnackBar('OTP sent to your phone number');
            _startResendTimer(); // Start the resend timer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyCodeScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumberWithCountryCode!,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print("Auto-retrieval timed out");
            _showSnackBar('Auto-retrieval timed out. Please enter the code manually.');
            setState(() {
              _isLoading = false;
            });
          },
        );
      } catch (e) {
        print("Error sending OTP: $e");
        _showSnackBar('Failed to send OTP. Please check the number and try again.', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showSnackBar('Please enter a valid phone number', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcon(width: 160.w),
                SizedBox(height: 24.h),
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Enter your phone number below to receive a verification code via SMS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 32.h),
                Form(
                  key: _formKey,
                  child: IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                    ),
                    initialCountryCode: 'SA',
                    onChanged: (phone) {
                      phoneNumberWithCountryCode = phone.completeNumber;
                      print('Phone number changed: $phoneNumberWithCountryCode');
                    },
                    onSaved: (phone) {
                      phoneNumberWithCountryCode = phone?.completeNumber;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(height: 40.h),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : sendOtp,
                      child: Container(
                        width: 180.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SEND OTP',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: _isLoading || !_canResendOtp ? null : _resendOtp,
                      child: Text(
                        _canResendOtp
                            ? 'Resend OTP'
                            : 'Resend OTP in $_resendCountdown seconds',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}