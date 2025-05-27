import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/AuthRegistrationService.dart';
import 'package:project/screens/add_medicine_screen.dart';
import '../helper/auth_service.dart';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_auth/local_auth.dart';
import '../widgets/create_account_logic.dart';
import '../widgets/create_account_widgets.dart';

class CreateAccountPatient extends StatefulWidget {
  const CreateAccountPatient({super.key});

  @override
  State<CreateAccountPatient> createState() => _CreateAccountPatientState();
}

class _CreateAccountPatientState extends State<CreateAccountPatient>
    with CreateAccountLogic {
  final AuthService _secureAuthService = AuthService();
  late final LocalAuthentication auth = LocalAuthentication(); // Initialize here
  bool _newAccountCreated = false; // To track if a new account was created
  late AuthRegistrationService _registrationService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool biometricAvailable = false;
  bool _biometricEnabled = false;
  bool biometricSetupAttempted = false;

  // Initialize controllers and variables
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  bool isSecure = true;
  String passwordStrength = "";
  bool agree = false;
  String? selectedAnalysisFilePath;

  @override
  AuthRegistrationService get registrationService => _registrationService;

  @override
  Future<void> Function() get authenticateUserCallback => authenticateUser;

  @override
  Future<String> Function(String) get encryptData => encryptDataFunction;

  @override
  Future<void> Function(String, String) get storeEncryptedDataLocally =>
      storeEncryptedDataLocallyFunction;

  @override
  Future<void> Function(String, String, String) get savePatientDataLocally =>
      savePatientDataLocallyFunction;

  @override
  Future<void> Function() get pickAndEncryptAnalysisFileMethod =>
      pickAndEncryptAnalysisFile;

  @override
  void Function(String) get checkPasswordStrengthMethod => checkPasswordStrength;

  @override
  BuildContext get currentContext => context;

  // Added methods from CreateAccountLogic
  void togglePasswordVisibility() {
    setState(() {
      isSecure = !isSecure;
    });
  }

  Future<void> _enrollBiometric() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Enable fingerprint login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        await enableBiometricAuthentication();
        setState(() {
          _biometricEnabled = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.fingerprint, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Fingerprint login enabled!'),
                  ],
                )),
          );
          // Optionally store email/password securely here if not handled elsewhere
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Fingerprint enrollment failed.'),
                  ],
                )),
          );
        }
      }
    } on PlatformException catch (e) {
      print("PlatformException during biometric enrollment: ${e.code} - ${e.message}");
      String errorMessage = 'An error occurred during enrollment.';
      IconData errorIcon = Icons.error_outline;
      Color iconColor = Colors.red;
      switch (e.code) {
        case 'NotAvailable':
          errorMessage =
          'Biometric authentication is not available on this device.';
          errorIcon = Icons.info_outline;
          iconColor = Colors.grey;
          break;
        case 'LockedOut':
          errorMessage =
          'Biometric authentication is locked out. Please try again later.';
          errorIcon = Icons.lock;
          iconColor = Colors.orange;
          break;
        case 'PermanentlyLockedOut':
          errorMessage =
          'Biometric authentication is permanently locked out.  You need to use your device\'s backup authentication method.';
          errorIcon = Icons.lock_open;
          iconColor = Colors.red;
          break;
        case 'UserCanceled':
          errorMessage = 'Biometric authentication was canceled by the user.';
          errorIcon = Icons.cancel_outlined;
          iconColor = Colors.grey;
          break;
        case 'NotEnrolled':
          errorMessage =
          'Biometrics are not enrolled on this device. Please set up fingerprint or face recognition in your device settings.';
          errorIcon = Icons.fingerprint_outlined;
          iconColor = Colors.grey;
          break;
        default:
          errorMessage = 'An unexpected error occurred: ${e.message}';
          break;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Row(
                children: [
                  Icon(errorIcon, color: iconColor),
                  SizedBox(width: 8),
                  Text(errorMessage),
                ],
              )),
        );
      }
    } catch (e) {
      print("Error during biometric enrollment: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('An error occurred during enrollment.'),
                ],
              )),
        );
      }
    }
  }

  void updateAgreement(bool? value) {
    if (value != null) {
      // null check
      setState(() {
        agree = value!; // Use the non-nullable value here.
      });
    }
  }

  void updateSelectedAnalysisFile(String? path) {
    setState(() {
      selectedAnalysisFilePath = path;
    });
  }

  void checkPassword(String value) {
    checkPasswordStrength(value);
    setState(() {
      passwordError = _registrationService.validatePassword(value);
    });
  }

  @override
  Future<void> triggerBiometricLogin() async {
    if (_biometricEnabled) {
      authenticateUserCallback(); // For login
    } else {
      _enrollBiometric(); // For first-time enrollment
    }
  }

  Future<void> registerAccount() async {
    if (agree) {
      try {
        await _registrationService.registerUser();
        // Show dialog only after successful registration:
        if (_newAccountCreated && context.mounted) {
          await _showBiometricSetupDialog();
        }
      } catch (e) {
        if (context.mounted) {
          // Check if context is valid
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('An error occurred during registration: $e')),
          );
        }
      }
    } else {
      if (context.mounted) {
        // Check if context is valid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Please agree to the terms and conditions.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _registrationService = AuthRegistrationService(
      context: context,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      emailController: emailController,
      passwordController: passwordController,
      setFirstNameError: (error) => setState(() => firstNameError = error),
      setLastNameError: (error) => setState(() => lastNameError = error),
      setEmailError: (error) => setState(() => emailError = error),
      setPasswordError: (error) => setState(() => passwordError = error),
      setAgree: updateAgreement,
      setSelectedAnalysisFilePath: updateSelectedAnalysisFile,
      secureStorage: secureStorage,
      auth: auth,
      setNewAccountCreated: (value) =>
          setState(() => _newAccountCreated = value),
      biometricAvailableGetter: () => biometricAvailable,
    );

    auth.canCheckBiometrics.then((value) async {
      setState(() {
        biometricAvailable = value;
      });
      isBiometricAuthenticated().then((enabled) { // Check if already enabled
        setState(() {
          _biometricEnabled = enabled;
        });
      });
    });
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        final authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated) {
          // Navigate to Home
        } else {
          print("Authentication failed");
        }
      } else {
        print("Biometric not supported or not enrolled");
      }
    } catch (e) {
      print("Authentication error: $e");
    }
  }

// Method to enable biometric authentication and store the flag
  Future<void> enableBiometricAuthentication() async {
    // Assuming biometric authentication is successful
    await secureStorage.write(key: 'biometric_authenticated', value: 'true');
  }

// Method to check if biometric authentication is enabled
  Future<bool> isBiometricAuthenticated() async {
    String? value = await secureStorage.read(key: 'biometric_authenticated');
    return value == 'true'; // Return true if it's enabled, false otherwise
  }

  Future<void> saveEncryptedDataToFirestore(String uid, String firstName,
      String lastName, String reportContent) async {
    final encryptedFirstName =
    await encryptData(firstName); // Use getter
    final encryptedLastName =
    await encryptData(lastName); // Use getter
    final encryptedReport =
    await encryptData(reportContent); // Use getter

    await FirebaseFirestore.instance.collection('patients').doc(uid).set({
      'first_name': encryptedFirstName,
      'last_name': encryptedLastName,
      'analysis_report': encryptedReport,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> authenticateUser() async {
    try {
      // Step 1: Biometric authentication
      final authSuccess = await AuthService.authenticateWithBiometrics();
      if (!authSuccess) {
        if (context.mounted) {
          // Check context before using it.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.fingerprint_outlined, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Biometric authentication failed'),
                  ],
                )),
          );
        }
        return;
      }

      // Step 2: Retrieve stored credentials
      final email = await AuthService.getStoredEmail();
      final password = await AuthService.getStoredPassword();

      if (email == null ||
          password == null ||
          email.trim().isEmpty ||
          password.trim().isEmpty) {
        print(
            "Missing credentials: email=$email, password=${password == null ? 'null' : '***'}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                        'Stored credentials are missing or corrupted. Please re-login manually.'),
                  ],
                )),
          );
        }
        return;
      }

      // Optional: Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Step 3: Firebase sign-in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await Future.delayed(
          const Duration(milliseconds: 300)); // Optional UX delay

      // Step 4: Navigate to AddMedicineScreen
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Close loading if error occurs

      String msg;
      IconData errorIcon = Icons.error_outline;
      Color iconColor = Colors.red;

      switch (e.code) {
        case 'user-not-found':
          msg = 'No user found with these credentials.';
          errorIcon = Icons.person_off_outlined;
          break;
        case 'wrong-password':
          msg = 'Stored password is incorrect. Please re-login manually.';
          errorIcon = Icons.lock_outline;
          break;
        case 'invalid-credential':
          msg = 'Stored credentials are invalid or expired. Please re-login.';
          errorIcon = Icons.warning_amber;
          iconColor = Colors.orange;
          break;
        default:
          msg = 'Firebase login failed: ${e.message}';
          break;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                Icon(errorIcon, color: iconColor),
                SizedBox(width: 8),
                Text(msg),
              ],
            )));
      }

      if (['user-not-found', 'wrong-password', 'invalid-credential']
          .contains(e.code)) {
        await AuthService.clearStoredCredentials();
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Close loading if error occurs

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('An unexpected error occurred. Please try again.'),
              ],
            )),
      );
    }
  }

  Future<bool> _showBiometricSetupDialog() async {
    bool enableBiometrics = false;
    // final isBiometricAvailable =
    //    await biometricAvailableGetter(); // Corrected line
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Needed to use setState inside dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Account Created'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your account has been successfully created!'),
                  if (biometricAvailable && !_biometricEnabled)
                  // Only show if available AND not already enabled
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'For faster and secure login in the future, you can enable fingerprint or Face ID.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Enable Biometric Login?'),
                            Switch(
                              value: enableBiometrics,
                              onChanged: (val) {
                                setState(() {
                                  enableBiometrics = val;
                                });
                              },
                            ),
                          ],
                        ),
                        if (enableBiometrics)
                          const Text(
                            'Place your finger on the sensor or use your face to authenticate.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  if (_biometricEnabled)
                    const Text(
                      'Biometric login is enabled.',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 14, color: Colors.green),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddMedicineScreen()),
                    );
                  },
                  child: const Text('Skip'),
                ),
                TextButton(
                  onPressed: () async {
                    if (biometricAvailable &&
                        enableBiometrics &&
                        !_biometricEnabled) {
                      await _enrollBiometric();
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddMedicineScreen()),
                      );
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    return enableBiometrics;
  }

  Future<void> signUpUser() async {
    try {
      // Sign-up logic here (e.g., create the user in Firebase)

      // After successful account creation
      bool enableBiometrics = await _showBiometricSetupDialog();
      if (enableBiometrics) {
        // Proceed to check and enable biometric authentication
        authenticateUser();
      }
    } catch (e) {
      print('Error during sign-up: $e');
    }
  }

  Future<void> resetBiometricFlag() async {
    await secureStorage.delete(key: 'biometric_authenticated');
  }

  Future<encrypt.Encrypter> getEncrypter() async {
    String? keyString = await secureStorage.read(key: 'aes_key');
    String? ivString = await secureStorage.read(key: 'aes_iv');
    if (keyString == null || ivString == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      final iv = encrypt.IV.fromSecureRandom(16);
      await secureStorage.write(key: 'aes_key', value: key.base64);
      await secureStorage.write(key: 'aes_iv', value: iv.base64);
      return encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc));
    } else {
      final key = encrypt.Key.fromBase64(keyString);
      return encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc));
    }
  }

  Future<String> encryptDataFunction(String data) async {
    // Changed method name
    final encrypter = await getEncrypter();
    final ivString = await secureStorage.read(key: 'aes_iv');
    final iv = encrypt.IV.fromBase64(ivString!);
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  Future<void> storeEncryptedDataLocallyFunction(
      String encryptedData, String fileName) async {
    // Changed method name
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(encryptedData);
    } catch (e) {
      print('Error saving encrypted data: $e');
    }
  }

  Future<void> savePatientDataLocallyFunction(String firstName,
      String lastName, String analysisReport) async {
    // Changed method name
    final encryptedFirstName =
    await encryptDataFunction(firstName); // Use getter
    final encryptedLastName =
    await encryptDataFunction(lastName); // Use getter
    final encryptedReport =
    await encryptDataFunction(analysisReport); // Use getter

    await storeEncryptedDataLocallyFunction(
        encryptedFirstName, 'first_name.enc');
    await storeEncryptedDataLocallyFunction(
        encryptedLastName, 'last_name.enc');
    await storeEncryptedDataLocallyFunction(
        encryptedReport, 'analysis_report.enc');

    if (context.mounted) {
      // Check context before using it.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your data has been securely encrypted and saved.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> pickAndEncryptAnalysisFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      updateSelectedAnalysisFile(filePath);
      try {
        final file = File(filePath);
        final fileBytes = await file.readAsBytes(); // Read as bytes
        final encryptedBytes =
        await encryptBytes(fileBytes); // Encrypt the bytes
        await storeEncryptedBytesLocally(
            encryptedBytes, 'analysis_report.enc'); // Store the encrypted bytes
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Encrypted report saved locally!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error reading or encrypting file: $e')),
          );
        }
        print('Error reading or encrypting file: $e');
      }
    }
  }

  Future<encrypt.Encrypted> encryptBytes(List<int> bytes) async {
    final encrypter = await getEncrypter();
    final ivString = await secureStorage.read(key: 'aes_iv');
    final iv = encrypt.IV.fromBase64(ivString!);
    return encrypter.encryptBytes(bytes, iv: iv);
  }

  Future<void> storeEncryptedBytesLocally(
      encrypt.Encrypted encryptedData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(
          encryptedData.bytes); // Write the encrypted bytes
    } catch (e) {
      print('Error saving encrypted data: $e');
    }
  }

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() => passwordStrength = "");
      return;
    }
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial =
    password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool isLong = password.length >= 6;
    setState(() {
      if (!isLong) {
        passwordStrength = "Weak";
      } else if (hasUpper && hasDigit && hasSpecial) {
        passwordStrength = "Strong";
      } else if ((hasUpper || hasDigit) && password.length >= 8) {
        passwordStrength = "Medium";
      } else {
        passwordStrength = "Weak";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(7.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateAccountWidgets.buildTopSection(
              context: context, // Pass the context here
              firstNameController: firstNameController,
              firstNameError: firstNameError,
              lastNameController: lastNameController,
              lastNameError: lastNameError,
              emailController: emailController,
              emailError: emailError,
              passwordController: passwordController,
              isSecure: isSecure,
              onSecureToggle: togglePasswordVisibility,
              onPasswordChanged: checkPassword,
              passwordStrength: passwordStrength,
              passwordError: passwordError, // Pass the passwordError
              onUploadReportTap: pickAndEncryptAnalysisFileMethod,
              selectedAnalysisFilePath: selectedAnalysisFilePath,
            ),
            CreateAccountWidgets.buildBottomSection(
              agree: agree,
              onAgreeChanged:updateAgreement,
              onBiometricTap: triggerBiometricLogin,
              onNextTap: registerAccount,
            ),
          ],
        ),
      ),
    );
  }
}

