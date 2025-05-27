import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vibration/vibration.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icon.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyCodeScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen>
    with SingleTickerProviderStateMixin {
  String _code = '';
  bool _isEditing = true;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _hasInternet = true;
  bool _wrongCode = false; // State to trigger error indication

  int _secondsRemaining = 60;
  Timer? _timer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  FocusNode _otpFocusNode = FocusNode();
  //  AnimationController? _shakeController; // Remove unused controller

  late String _verificationId;
  Color _underlineColor = Colors.black; //  Default underline color

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    startTimer();
    _checkInternetConnectivity();
    _monitorInternetConnectivity();
    //   _initializeShakeController();  // Remove initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_otpFocusNode);
    });
  }

  //  void _initializeShakeController() {  // Remove this method
  //   if (_shakeController == null) {
  //     _shakeController = AnimationController(
  //       duration: const Duration(milliseconds: 500),
  //       vsync: this,
  //     );
  //   }
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySubscription?.cancel();
    _otpFocusNode.dispose();
    //  _shakeController?.dispose();  // Remove disposal
    super.dispose();
  }

  Future<void> _checkInternetConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _hasInternet = (connectivityResult != ConnectivityResult.none);
    });
  }

  void _monitorInternetConnectivity() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _hasInternet = (result != ConnectivityResult.none);
          });
          if (!_hasInternet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No internet connection')),
            );
          }
        });
  }

  void startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> verifyOtp() async {
    if (!_hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _code.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushReplacementNamed(context, '/resetPassword');
    } on FirebaseAuthException catch (e) {
      print("OTP verification failed: $e");
      String errorMessage = 'Invalid OTP. Please try again.';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'The verification code you entered is incorrect.';
        setState(() {
          _wrongCode = true;
          _underlineColor = Colors.red; // Change color
        });
        _triggerErrorFeedback();
      } else if (e.code == 'session-expired') {
        errorMessage = 'The verification code has expired. Please resend.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print("An unexpected error occurred during OTP verification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _wrongCode = false;
          _underlineColor = Colors.black; // Reset color after the delay
        });
      });
    }
  }

  Future<void> resendCode() async {
    if (!_hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    if (_secondsRemaining > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait for the countdown to finish')),
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to resend OTP: ${e.message}')),
          );
          setState(() => _isResending = false);
        },
        codeSent: (String newVerificationId, int? resendToken) {
          setState(() {
            _verificationId = newVerificationId;
            _isResending = false;
          });
          startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      print("An unexpected error occurred during resend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend OTP. Please try again later.')),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('If you go back, you might need to request a new verification code.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go back'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _triggerErrorFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
    //  _shakeController?.forward().then((_) => _shakeController?.reset());  // Remove shake
  }

  @override
  Widget build(BuildContext context) {
    //  _initializeShakeController();  // Remove from build
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Column(
          children: [
            AppIcon(width: 200.w),
            Text(
              'Verify Code',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 50.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'Enter the 6-digit code sent via SMS to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Focus(
                focusNode: _otpFocusNode,
                child: VerificationCode(
                  autofocus: true,
                  length: 6,
                  textStyle: TextStyle(fontSize: 20.sp, color: Colors.black),
                  underlineColor: _underlineColor, // Use the color here!
                  keyboardType: TextInputType.number,
                  fullBorder: true,
                  underlineWidth: 2.0,
                  cursorColor: Colors.blue,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  onCompleted: (String value) {
                    setState(() {
                      _code = value;
                      _isEditing = false;
                    });
                    verifyOtp();
                  },
                  onEditing: (bool value) {
                    setState(() {
                      _isEditing = value;
                      _wrongCode = false;
                      _underlineColor = Colors.black; // Reset color when editing starts
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              _secondsRemaining > 0
                  ? 'Resend code in $_secondsRemaining s'
                  : 'Didn’t receive code?',
              style: TextStyle(fontSize: 14.sp),
            ),
            TextButton(
              onPressed: (_secondsRemaining == 0 && !_isResending && _hasInternet) ? resendCode : null,
              child: _isResending
                  ? const CircularProgressIndicator()
                  : Text(
                'Resend Code',
                style: TextStyle(
                  color: (_secondsRemaining == 0 && _hasInternet) ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            GestureDetector(
              onTap: (_isVerifying || !_hasInternet) ? null : verifyOtp,
              child: AppButton(
                width: 200.w,
                height: 75.h,
                radius: 200,
                child: Center(
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'VERIFY OTP',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            if (!_hasInternet)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Text(
                  'No internet connection. Please connect to verify OTP.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

