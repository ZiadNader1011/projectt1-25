import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/screens/EditProfileScreen.dart';
import '../widgets/profile_buttom_banner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  String? userName;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await createUserIfNotExists(user);
    setState(() {
      currentUser = user;
    });
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (currentUser == null) return;
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            userName = userData['name'];
            userPhone = userData['phone'];
          });
          _checkProfileCompletionAndShowDialog(userData); // Check after fetching data
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> createUserIfNotExists(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'name': user.displayName ?? '',
        'email': user.email ?? 'No email provided',
        'phone': user.phoneNumber ?? '', // Allow empty initially
        'role': 'Patient',
      });
    }
  }

  Future<void> updateUserRole(String newRole) async {
    if (currentUser == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    await userDoc.update({
      'role': newRole,
    });
    await fetchUserData();
  }

  Future<void> _googleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        await getCurrentUser();
      }
    } catch (e) {
      print("Google Sign In Error: $e");
    }
  }

  Future<void> _askForMissingProfileInfo(BuildContext context, Map<String, dynamic>? userData) async {
    TextEditingController nameController = TextEditingController(text: userData?['name'] ?? '');
    TextEditingController phoneController = TextEditingController(text: userData?['phone'] ?? '');
    bool showNameField = userData?['name'] == null || (userData?['name'] as String).trim().isEmpty;
    bool showPhoneField = userData?['phone'] == null || (userData?['phone'] as String).trim().isEmpty;

    if (!showNameField && !showPhoneField) {
      return; // No need to show the dialog if both are present
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Complete Your Profile', style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showNameField)
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                if (showNameField && showPhoneField) SizedBox(height: 10.h),
                if (showPhoneField)
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.black),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String enteredName = nameController.text.trim();
                String enteredPhone = phoneController.text.trim();
                Map<String, dynamic> updates = {};

                if (showNameField && enteredName.isNotEmpty) {
                  updates['name'] = enteredName;
                }
                if (showPhoneField && enteredPhone.isNotEmpty) {
                  updates['phone'] = enteredPhone;
                }

                if (updates.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .update(updates);
                    await fetchUserData(); // Re-fetch data to update the UI and potentially dismiss the dialog if all info is now present
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    print("Error updating profile info: $e");
                    // Optionally show an error message to the user
                  }
                } else {
                  Navigator.of(context).pop(); // Dismiss if no new data was entered (shouldn't happen if the dialog is shown)
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to check if name or phone is missing and show the dialog
  void _checkProfileCompletionAndShowDialog(Map<String, dynamic>? userData) {
    final name = userData?['name'] as String?;
    final phone = userData?['phone'] as String?;

    if ((name == null || name.trim().isEmpty) || (phone == null || phone.trim().isEmpty)) {
      // Use Future.delayed to ensure the build context is available
      Future.delayed(Duration.zero, () => _askForMissingProfileInfo(context, userData));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            if (userData == null) {
              return const Center(child: Text('User data not available.'));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage('assets/images/icon_1.png'),
                      ),
                      SizedBox(width: 15.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name'] ?? 'No Name',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () {
                              String newRole = userData['role'] == 'Patient' ? 'Caregiver' : 'Patient';
                              updateUserRole(newRole);
                            },
                            child: Text(
                              userData['role'] ?? 'Patient',
                              style: TextStyle(fontSize: 14.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                userId: currentUser!.uid,
                                currentName: userData['name'] ?? 'No Name',
                                currentEmail: userData['email'] ?? 'No Email',
                                currentPhone: userData['phone'] ?? 'No Phone',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Account Information',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  SizedBox(height: 10.h),
                  _buildInfoCard(Icons.person, 'Name', userData['name']),
                  _buildInfoCard(Icons.phone, 'Phone', userData['phone']),
                  _buildInfoCard(Icons.mail, 'Email', userData['email']),
                  SizedBox(height: 30.h),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: 50.w),
                            GestureDetector(
                              onTap: _googleSignIn,
                              child: Image.asset('assets/images/icon_11.png', height: 30.h),
                            ),
                            SizedBox(width: 50.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  ProfileBottomBanner(userId: currentUser!.uid),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String? value) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    value ?? 'Not provided',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
