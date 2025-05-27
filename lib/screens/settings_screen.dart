import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/on_boarding_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricsSupport();
  }

  // --- Biometric Authentication ---
  Future<void> _checkBiometricsSupport() async {
    try {
      _isBiometricAvailable = await auth.canCheckBiometrics;
      _availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {
        _isBiometricAvailable = _isBiometricAvailable;
        _availableBiometrics = _availableBiometrics;
      });
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _addBiometric() async {
    if (!_isBiometricAvailable) {
      _showSnackBar('Biometric authentication is not available on this device.');
      return;
    }

    if (_availableBiometrics.isEmpty) {
      _showSnackBar(
          'No biometrics are enrolled. Please enroll a fingerprint or face in your device settings.');
      return;
    }

    try {
      final authenticated = await auth.authenticate(
        localizedReason:
        'Add a new biometric for login.', // Changed localizedReason
        options: const AuthenticationOptions(
          useErrorDialogs: true, // Show system error dialogs
          stickyAuth:
          true, // Keep session active
        ),
      );

      if (authenticated) {
        _showSnackBar('Biometric added successfully.');
        _checkBiometricsSupport(); // Refresh the list
      } else {
        _showSnackBar('Failed to add biometric.');
      }
    } on PlatformException catch (e) {
      debugPrint('Error adding biometric: $e');
      if (e.code == 'NotEnrolled') {
        _showSnackBar(
            'No biometrics are enrolled. Please enroll a fingerprint or face in your device settings.');
      } else {
        _showSnackBar('Error adding biometric: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error adding biometric: $e');
      _showSnackBar('Error adding biometric: $e');
    }
  }

  Future<void> _deleteBiometrics() async {
    if (!_isBiometricAvailable) {
      _showSnackBar('Biometric authentication is not available on this device.');
      return;
    }

    if (_availableBiometrics.isEmpty) {
      _showSnackBar(
          'No biometrics are enrolled. There is nothing to delete.');
      return;
    }

    try {
      // Show a confirmation dialog before proceeding
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Biometrics'),
          content: const Text(
              'Are you sure you want to delete all enrolled biometrics? This will remove all fingerprints and face recognition data used for authentication in this app.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        // There's no direct way to delete a specific biometric in Flutter's local_auth.
        //show dialog
        _showSnackBar(
          'Biometrics can only be managed from device settings, not from this app.',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Error deleting biometric: $e');
      _showSnackBar('Error deleting biometric: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting biometric: $e');
      _showSnackBar('Error deleting biometric: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Handle change password logic here
  void _changePassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        TextEditingController newPasswordController = TextEditingController();
        TextEditingController confirmPasswordController =
        TextEditingController();

        return AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                const InputDecoration(hintText: "Enter current password"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Enter new password"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                const InputDecoration(hintText: "Confirm new password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String currentPassword = passwordController.text.trim();
                String newPassword = newPasswordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill out all fields")),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                try {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Re-authenticate the user with their current password
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPassword,
                    );

                    await user.reauthenticateWithCredential(credential);

                    // Update the password
                    await user.updatePassword(newPassword);

                    Navigator.of(context).pop(); // Close the dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Password successfully changed!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No user signed in.")),
                    );
                  }
                } catch (e) {
                  print("Error updating password: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Failed to change password. Please check your credentials.")),
                  );
                }
              },
              child: const Text("Change"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Logout and navigate to the onboarding screen
  void _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingCard(
                icon: Icons.lock,
                title: 'Change Password',
                trailing:
                const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: _changePassword,
              ),
              Divider(color: Colors.white30),
              _buildSettingCard(
                icon: Icons.fingerprint,
                title: 'Add Biometric',
                trailing:
                const Icon(Icons.add, color: Colors.white), // Changed icon
                onTap: _addBiometric,
              ),
              Divider(color: Colors.white30),
              _buildSettingCard(
                icon: Icons.fingerprint,
                title: 'Delete Biometrics',
                trailing:
                const Icon(Icons.delete, color: Colors.white), // Changed icon
                onTap: _deleteBiometrics,
              ),
              Divider(color: Colors.white30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.exit_to_app, size: 20.sp),
                label: Text(
                  "Logout",
                  style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(12.0.w),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}


