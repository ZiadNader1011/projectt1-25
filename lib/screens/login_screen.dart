import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project/screens/create_account_caregiver.dart';
import 'package:project/widgets/app_button.dart';
import 'package:local_auth/local_auth.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/signup_screen.dart';
import 'package:project/screens/forget_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/auth_service.dart';
import 'loading_dialog.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isSecure = true;
  bool remember = false;
  bool isLoading = false;
  bool isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String biometricHint = 'Tap to login with fingerprint (if enabled)';
  String biometricLabel = 'Use Biometric Login';
  String? savedEmail;
  String? savedPassword;
  final LocalAuthentication auth = LocalAuthentication();
  final secureStorage = const FlutterSecureStorage();
  final _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _checkBiometricsSupport();
    _loadBiometricPreference(); // Load biometric preference on init
    _loadSavedCredentials().then((_) {
      if (_isBiometricEnabled &&
          savedEmail != null &&
          savedPassword != null &&
          isBiometricAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _attemptBiometricLoginOnInit(); // Immediate prompt if enabled and credentials exist
        });
      }
    });
  }
  Future<bool> _isBiometricSupported() async {
    final isAvailable = await auth.canCheckBiometrics;
    return isAvailable && await auth.isDeviceSupported();
  }
  Future<void> _checkBiometricsSupport() async {
    try {
      isBiometricAvailable = await auth.canCheckBiometrics;
      final availableBiometrics = await auth.getAvailableBiometrics();
      if (isBiometricAvailable && availableBiometrics.isNotEmpty) {
        setState(() {
          isBiometricAvailable = true;
        });
      } else {
        setState(() {
          isBiometricAvailable = false;
          _isBiometricEnabled =
          false; // Disable if no biometrics available
          _saveBiometricPreference(false);
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      setState(() {
        isBiometricAvailable = false;
        _isBiometricEnabled = false; // Disable on error
        _saveBiometricPreference(false);
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!isBiometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Biometric authentication is not available on this device.')),
      );
      return;
    }

    try {
      setState(() {
        biometricHint = 'Authenticating...'; // Feedback during auth
      });
      final authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        biometricHint =
        'Tap to login with fingerprint (if enabled)'; // Reset hint
      });

      if (authenticated) {
        savedEmail = await secureStorage.read(key: 'email');
        savedPassword = await secureStorage.read(key: 'password');
        if (savedEmail != null && savedPassword != null) {
          setState(() {
            emailController.text = savedEmail!;
            passwordController.text = savedPassword!;
          });
          await _signIn();
        } else {
          // Improved handling of no saved credentials
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Biometric authentication successful, but no saved credentials found.  Please log in manually to enable biometric login.'),
              action: SnackBarAction(
                label: 'Login',
                onPressed: () {
                },
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed.')),
        );
      }
    } on PlatformException catch (e) {
      setState(() {
        biometricHint =
        'Tap to login with fingerprint (if enabled)';
      });
      String message;
      switch (e.code) {
        case 'NotAvailable':
          message =
          'Biometric authentication is not available on this device.';
          break;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          message =
          'Biometric authentication is locked due to too many failed attempts. Please use your PIN, pattern, or password.';
          break;
        case 'NoBiometrics':
          message =
          'No fingerprints are enrolled on this device. Please enroll a fingerprint in your device settings to use this feature.';
          break;
        case 'UserCancel':
          message = 'Biometric authentication was canceled by the user.';
          break;
        case 'Timeout':
          message = 'Biometric authentication timed out. Please try again.';
          break;
        case 'NotEnrolled': // Android Specific
          message =
          'Biometric authentication is not enrolled on this device. Please enroll a fingerprint';
          break;
        default:
          message = 'Biometric login failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseAuthException catch (e) {
      setState(() {
        biometricHint =
        'Tap to login with fingerprint (if enabled)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric login failed: ${e.message}')),
      );
    } catch (e) {
      setState(() {
        biometricHint =
        'Tap to login with fingerprint (if enabled)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric login failed: $e')),
      );
    }
  }
  Future<void> _attemptBiometricLoginOnInit() async {
    if (isBiometricAvailable &&
        _isBiometricEnabled &&
        savedEmail != null &&
        savedPassword != null) {
      try {
        setState(() {
          biometricHint =
          'Authenticating...';
        });
        final authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        setState(() {
          biometricHint =
          'Tap to login with fingerprint (if enabled)';
        });
        if (authenticated) {
          setState(() {
            emailController.text = savedEmail!;
            passwordController.text = savedPassword!;
          });
          await _signIn();
        }
      } on PlatformException catch (e) {
        setState(() {
          biometricHint =
          'Tap to login with fingerprint (if enabled)';
        });
        debugPrint('Error during initial biometric attempt: $e');
      }
    }
  }
  Future<void> _loadSavedCredentials() async {
    savedEmail = await secureStorage.read(key: 'email');
    savedPassword = await secureStorage.read(key: 'password');

    setState(() {
      if (savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail!;
        passwordController.text = savedPassword!;
        remember = true;
      }
    });
  }
  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }
  Future<void> _saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }
  Future<void> _signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: AnimatedLoadingDialog()),
      );
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (remember) {
        await secureStorage.write(
            key: 'email', value: emailController.text.trim());
        await secureStorage.write(
            key: 'password', value: passwordController.text);
        if (isBiometricAvailable && !_isBiometricEnabled) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Enable Biometric Login?"),
                  content: const Text(
                      "Would you like to enable biometric login for future sign-ins?"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () {
                        setState(() {
                          _isBiometricEnabled = true;
                        });
                        _saveBiometricPreference(true);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Biometric login enabled for future use.')),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        await secureStorage.delete(key: 'email');
        await secureStorage.delete(key: 'password');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('email');
        await prefs.remove('password');
        _saveBiometricPreference(false);
      }
      if (context.mounted) Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // ... (rest of your error handling)
    } catch (e) {
      // ... (rest of your error handling)
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Image.asset('assets/images/icoon.png', height: 150.h),
              SizedBox(height: 10.h),
              Text('Sign in',
                  style:
                  TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 25.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Email',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: 3.h),
              _buildTextField(
                controller: emailController,
                hintText: 'Enter your email',
                icon: Icons.email_outlined,
                obscure: false,
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Password',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                icon: Icons.lock_outline,
                obscure: isSecure,
                suffixIcon: IconButton(
                  icon: Icon(isSecure
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      isSecure = !isSecure;
                    });
                  },
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: remember,
                        onChanged: (value) {
                          setState(() {
                            remember = value!;
                          });
                        },
                      ),
                      Text('Remember Me', style: TextStyle(fontSize: 16.sp)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _signIn,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : AppButton(
                        height: 55.h,
                        child: Center(
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  if (isBiometricAvailable && _isBiometricEnabled)
                    Tooltip(
                      message: biometricHint,
                      child: GestureDetector(
                        onTap: _handleBiometricLogin,
                        child: Icon(
                          Icons.fingerprint,
                          size: 55,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  if (isBiometricAvailable && !_isBiometricEnabled)
                    const SizedBox(width: 55),
                  if (!isBiometricAvailable)
                    const SizedBox(width: 55),
                ],
              ),
              SizedBox(height: 16.h),
              if (isBiometricAvailable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Use Biometric Login", style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isBiometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isBiometricEnabled = value;
                        });
                        _saveBiometricPreference(value);
                      },
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgetPasswordScreen()));
                  },
                  child: Text('Forgot Password?',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800)),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()));
                  },
                  child: Text("Don't have an account?",
                      style:
                      TextStyle(fontSize: 16.sp, color: Colors.grey.shade800)),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()));
                  },
                  child: Text(
                    "Create an account!",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Stack(
                children: [
                  Divider(thickness: 1.5, color: Colors.grey.shade400),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 2)
                          ],
                        ),
                        child: Text('OR',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded( // Add Expanded here too
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const CreateAccountCaregiver()));
                      },
                      child: AppButton(
                        width: 200.w,
                        height: 60.h,
                        child: Center(
                          child: Text('Connect as Caregiver',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  const Icon(Icons.arrow_forward,
                      size: 35, color: Colors.black87),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscure,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }
}











