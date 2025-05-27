import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project/screens/loading_dialog.dart';
import 'package:project/screens/add_medicine_screen.dart'; // Make sure this import is correct
import '../helper/auth_service.dart'; // Adjust the path if necessary

class AuthRegistrationService {
  // --- Class Properties ---
  final BuildContext context;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final void Function(String?) setFirstNameError;
  final void Function(String?) setLastNameError;
  final void Function(String?) setEmailError;
  final void Function(String?) setPasswordError;
  final void Function(bool?) setAgree;
  final void Function(String?) setSelectedAnalysisFilePath;
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication auth;
  final void Function(bool) setNewAccountCreated;
  final bool Function() biometricAvailableGetter;

  String? selectedAnalysisFilePath;

  // --- Constructor ---
  AuthRegistrationService({
    required this.context,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.setFirstNameError,
    required this.setLastNameError,
    required this.setEmailError,
    required this.setPasswordError,
    required this.setAgree,
    required this.setSelectedAnalysisFilePath,
    required this.secureStorage,
    required this.auth,
    required this.setNewAccountCreated,
    required this.biometricAvailableGetter,
  });

  // --- Encryption Methods ---
  // Returns an Encrypter object, initializing encryption key and IV if needed.
  Future<encrypt.Encrypter> getEncrypter() async {
    String? keyString = await secureStorage.read(key: 'aes_key');
    String? ivString = await secureStorage.read(key: 'aes_iv');
    if (keyString == null || ivString == null) {
      // Generate and store new key/IV if they don't exist.
      final key = encrypt.Key.fromSecureRandom(32);
      final iv = encrypt.IV.fromSecureRandom(16);
      await secureStorage.write(key: 'aes_key', value: key.base64);
      await secureStorage.write(key: 'aes_iv', value: iv.base64);
      return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    } else {
      // Reuse existing key/IV.
      final key = encrypt.Key.fromBase64(keyString);
      return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    }
  }

  // Encrypts the given data string using the AES algorithm.
  Future<String> encryptData(String data) async {
    final encrypter = await getEncrypter();
    final ivString = await secureStorage.read(key: 'aes_iv');
    final iv = encrypt.IV.fromBase64(ivString!);
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  // --- Firestore Interaction ---
  // Saves encrypted user data to Firestore.
  Future<void> saveEncryptedDataToFirestore(
      String uid, String firstName, String lastName, String reportContent) async {
    final encryptedFirstName = await encryptData(firstName);
    final encryptedLastName = await encryptData(lastName);
    final encryptedReport = await encryptData(reportContent);

    await FirebaseFirestore.instance.collection('patients').doc(uid).set({
      'first_name': encryptedFirstName,
      'last_name': encryptedLastName,
      'analysis_report': encryptedReport,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // --- Local Storage ---
  // Stores encrypted data to a local file.
  Future<void> storeEncryptedDataLocally(
      String encryptedData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(encryptedData);
    } catch (e) {
      print('Error saving encrypted data: $e');
    }
  }

  // Saves patient data (first name, last name, report) locally after encryption.
  Future<void> savePatientDataLocally(
      String firstName, String lastName, String analysisReport) async {
    final encryptedFirstName = await encryptData(firstName);
    final encryptedLastName = await encryptData(lastName);
    final encryptedReport = await encryptData(analysisReport);

    await storeEncryptedDataLocally(encryptedFirstName, 'first_name.enc');
    await storeEncryptedDataLocally(encryptedLastName, 'last_name.enc');
    await storeEncryptedDataLocally(encryptedReport, 'analysis_report.enc');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your data has been securely encrypted and saved.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Biometric Authentication ---
  // Authenticates the user using biometrics.
  Future<bool> _authenticate({String reason = 'Authenticate'}) async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      return authenticated;
    } catch (e) {
      print("Error during authentication: $e");
      return false;
    }
  }

  // --- Biometric Preference ---
  // Stores the user's preference for using biometric login.
  Future<void> _setBiometricPreference(bool enabled) async {
    await secureStorage.write(
        key: 'biometric_login_enabled', value: enabled.toString());
  }

  // Retrieves the user's biometric login preference.
  Future<String?> _getBiometricPreference() async {
    return await secureStorage.read(key: 'biometric_login_enabled');
  }

  // --- User Registration ---
  // Registers a new user, including biometric authentication setup.
  Future<void> registerUser() async {
    // Validate form fields
    setFirstNameError(
        firstNameController.text.isEmpty ? 'First name is required' : null);
    setLastNameError(
        lastNameController.text.isEmpty ? 'Last name is required' : null);
    setEmailError(emailController.text.isEmpty ? 'Email is required' : null);
    setPasswordError(
        passwordController.text.isEmpty ? 'Password is required' : null);

    // If any validation error exists, return.
    if ([
      firstNameController.text.isEmpty ? 'First name is required' : null,
      lastNameController.text.isEmpty ? 'Last name is required' : null,
      emailController.text.isEmpty ? 'Email is required' : null,
      passwordController.text.isEmpty ? 'Password is required' : null
    ].any((e) => e != null)) return;

    final emailTrimmed = emailController.text.trim();
    final passwordTrimmed = passwordController.text.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(emailTrimmed)) {
      setEmailError('Invalid email format');
      return;
    }
    if (passwordTrimmed.length < 6) {
      setPasswordError('Password must be at least 6 characters');
      return;
    }

    setNewAccountCreated(false); //Resets

    bool isAuthenticated =
    true; // Assume authenticated until biometric check
    // Check for biometric availability and authenticate if available.
    if (biometricAvailableGetter()) {
      isAuthenticated = await _authenticate(
          reason: 'Authenticate to complete your registration securely.');
      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Fingerprint authentication failed. Registration cancelled.')),
        );
        return;
      }
    }

    try {
      // Show loading dialog.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: AnimatedLoadingDialog()),
      );

      UserCredential credential;
      // Attempt user creation.
      try {
        credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTrimmed,
          password: passwordTrimmed,
        );
        setNewAccountCreated(true);
      } on FirebaseAuthException catch (e) {
        // Handle email-already-in-use error by attempting to sign in.
        if (e.code == 'email-already-in-use') {
          try {
            credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailTrimmed,
              password: passwordTrimmed,
            );
          } on FirebaseAuthException catch (loginError) {
            // Handle login errors (e.g., wrong password).
            if (context.mounted) Navigator.of(context).pop();
            String msg = (loginError.code == 'wrong-password')
                ? 'Account exists but password is incorrect.'
                : 'Could not log in to existing account: ${loginError.message}';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
            return;
          }
        } else {
          // Handle other FirebaseAuth exceptions.
          if (context.mounted) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Authentication failed: ${e.message}'),
          ));
          return;
        }
      } catch (e) {
        // Handle unexpected errors.
        if (context.mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'An unexpected error occurred during authentication: $e')),
        );
        return;
      }

      final user = credential.user;
      if (user == null) {
        if (context.mounted) Navigator.of(context).pop();
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User could not be loaded.');
      }

      // Store user email and password securely.
      await secureStorage.write(key: 'user_email', value: emailTrimmed);
      await secureStorage.write(key: 'user_password', value: passwordTrimmed);

      await AuthService.initialize();

      String enrollResult;
      // Enroll user for biometric authentication.
      try {
        enrollResult =
        (await AuthService.enrollWithBiometrics(emailTrimmed, passwordTrimmed))!;
        print("enrollResult: $enrollResult");
      } catch (e) {
        enrollResult = 'An error occurred during biometric enrollment: $e';
        print("Error in registerUser catch: $e");
      }

      // Handle biometric enrollment failure.
      if (enrollResult != 'success') {
        if (context.mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric enrollment failed: $enrollResult')),
        );
        return;
      }

      // Process and store analysis report.
      String reportContent = "No report uploaded";
      if (selectedAnalysisFilePath != null) {
        final file = File(selectedAnalysisFilePath!);
        try {
          reportContent = await file.readAsString();
        } catch (e) {
          if (context.mounted) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error reading file: $e.  Path: ${file.path}')),
          );
          return;
        }
      }

      // Save user data and analysis report.
      try {
        await saveEncryptedDataToFirestore(
          user.uid,
          firstNameController.text,
          lastNameController.text,
          reportContent,
        );

        await savePatientDataLocally(
            firstNameController.text, lastNameController.text, reportContent);
      } catch (e) {
        if (context.mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
        return; // IMPORTANT: Return after showing error
      }

      if (context.mounted) Navigator.of(context).pop();

      // Show account creation success dialog.
      if (context.mounted) {
        bool enableBiometric = false;
        bool biometricSetupAttempted = false;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Account Created'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Your account has been successfully created!'),
                    // Prompt to enable biometric login.
                    if (biometricAvailableGetter() &&
                        !biometricSetupAttempted)
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
                                value: enableBiometric,
                                onChanged: (val) =>
                                    setState(() => enableBiometric = val),
                              ),
                            ],
                          ),
                          if (enableBiometric)
                            const Text(
                              'Place your finger on the sensor or use your face to authenticate.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    if (biometricSetupAttempted && !enableBiometric)
                      const Text(
                        'You can enable biometric login later in the app settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
                actions: [
                  // Skip biometric setup.
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AddMedicineScreen()), // Corrected
                      );
                    },
                    child: const Text('Skip'),
                  ),
                  // Continue with biometric setup.
                  TextButton(
                    onPressed: () async {
                      if (biometricAvailableGetter() &&
                          enableBiometric) {
                        setState(() => biometricSetupAttempted = true);
                        final authSuccess =
                        await AuthService.authenticateWithBiometrics();
                        if (authSuccess) {
                          await secureStorage.write(
                              key: 'biometric_authenticated',
                              value: 'true');
                          await _setBiometricPreference(
                              true); // Store the preference
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const AddMedicineScreen()), // Corrected
                            );
                          }
                        } else {
                          // Biometric setup failed.
                          if (context.mounted) {
                            setState(() {
                              enableBiometric = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Biometric setup failed. Please try again later in settings.')),
                            );
                          }
                        }
                      } else {
                        // User chose not to enable biometrics.
                        await _setBiometricPreference(
                            false); // Store the preference
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const AddMedicineScreen()), // Corrected
                        );
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors during registration.
      if (context.mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'An unexpected error occurred while creating the account')),
      );
    }
  }

  // --- User Login ---
  // Handles user login using stored credentials and biometric authentication.
  Future<void> loginWithBiometrics(BuildContext loginContext) async {
    // Check if biometric authentication is available on the device.
    if (!biometricAvailableGetter()) {
      ScaffoldMessenger.of(loginContext).showSnackBar(
        const SnackBar(
            content: Text(
                'Biometric authentication is not available on this device.')),
      );
      return;
    }

    // Check if the user has enabled biometric login.
    final biometricEnabled = await _getBiometricPreference();
    if (biometricEnabled != 'true') {
      ScaffoldMessenger.of(loginContext).showSnackBar(
        const SnackBar(
            content:
            Text('Biometric login is not enabled for this account.')),
      );
      return;
    }

    try {
      final bool authenticated =
      await _authenticate(reason: 'Authenticate to log in.');


      if (authenticated) {
        final storedEmail = await secureStorage.read(key: 'user_email');
        final storedPassword =
        await secureStorage.read(key: 'user_password');

        // Retrieve stored email and password.
        if (storedEmail != null && storedPassword != null) {
          // Show loading dialog.
          showDialog(
            context: loginContext,
            barrierDismissible: false,
            builder: (_) =>
            const Center(child: AnimatedLoadingDialog()),
          );
          try {
            // Sign in with stored credentials.
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: storedEmail,
              password: storedPassword,
            );
            if (loginContext.mounted) Navigator.of(loginContext).pop();
            // Navigate to the main screen.
            if (loginContext.mounted) {
              Navigator.pushReplacement(
                loginContext,
                MaterialPageRoute(
                    builder: (_) =>
                    const AddMedicineScreen()), // Corrected screen name.
              );
            }
          } on FirebaseAuthException catch (e) {
            // Handle Firebase authentication errors.
            if (loginContext.mounted) Navigator.of(loginContext).pop();
            ScaffoldMessenger.of(loginContext).showSnackBar(
              SnackBar(content: Text('Failed to log in: ${e.message}')),
            );
          } catch (e) {
            // Handle unexpected errors.
            if (loginContext.mounted) Navigator.of(loginContext).pop();
            ScaffoldMessenger.of(loginContext).showSnackBar(
              const SnackBar(
                  content: Text(
                      'An unexpected error occurred during login.')),
            );
          }
        } else {
          // Handle case where stored credentials are not found.
          ScaffoldMessenger.of(loginContext).showSnackBar(
            const SnackBar(
                content: Text(
                    'Could not retrieve stored login information.')),
          );
        }
      } else {
        // Handle failed biometric authentication.
        ScaffoldMessenger.of(loginContext).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed.')),
        );
      }
    } catch (e) {
      // Handle errors during the biometric authentication process.
      print("Error during biometric login: $e");
      ScaffoldMessenger.of(loginContext).showSnackBar(
        SnackBar(
            content:
            Text('An error occurred during biometric login: $e')),
      );
    }
  }


  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}







