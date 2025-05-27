import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/screens/profile_screen.dart';
import 'package:project/screens/on_boarding_screen.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_icon.dart'; // Assuming this is where AppIcon is defined

// Add the new imports for speech-to-text and http
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';


class DrawerList extends StatefulWidget {
  const DrawerList({super.key});

  @override
  State<DrawerList> createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  final TextEditingController searchController = TextEditingController();

  // Add the speech-to-text and response variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceQuery = '';
  String _response = ''; // To store the response from Flask

  @override
  void initState() {
    super.initState();
    // It's good practice to check permissions early, or just before using the mic.
    _checkPermissions();
  }

  // Check and request microphone permission
  void _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      // Optionally update UI to reflect permission denial
      // setState(() { _voiceQuery = 'Microphone permission denied'; });
      print('Microphone permission denied');
    }
  }

  // Method to start listening
  void _startListening() async {
    // Ensure permissions are checked right before starting to listen
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
      status = await Permission.microphone.status; // Re-check status after request
    }

    if (!status.isGranted) {
      _showPermissionDeniedDialog();
      return;
    }

    bool available = await _speech.initialize(onStatus: (status) {
      print('Speech status: $status');
      if (status == 'listening') {
        setState(() {
          _isListening = true;
          _voiceQuery = 'Listening...'; // Clear previous query and indicate listening
          _response = ''; // Clear previous response
        });
      } else if (status == 'notListening' || status == 'done') {
        setState(() {
          _isListening = false;
        });
      }
    }, onError: (error) {
      print('Error: $error');
      setState(() {
        _voiceQuery = 'Error during speech recognition: ${error.errorMsg}';
        _isListening = false;
      });
    });

    if (available) {
      setState(() {
        _isListening = true;
        _voiceQuery = 'Listening...';
        _response = '';
      });
      _speech.listen(
        onResult: (result) {
          print("Recognized speech: ${result.recognizedWords}"); // Debugging log
          setState(() {
            _voiceQuery = result.recognizedWords;
          });
          // Send request only when the final result is available
          if (result.finalResult) {
            _sendRequest(_voiceQuery);
          }
        },
        listenFor: const Duration(seconds: 5), // Listen for up to 5 seconds
        pauseFor: const Duration(seconds: 2), // Pause for 2 seconds to consider speech complete
        onSoundLevelChange: (level) => print('Sound level: $level'),
      );
    } else {
      setState(() {
        _voiceQuery = 'Speech recognition is not available';
        _isListening = false;
      });
    }
  }

  // Method to stop listening
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  // Method to send the recognized speech to the Flask backend
  Future<void> _sendRequest(String text) async {
    // IMPORTANT: Replace with your actual Flask API URL.
    // Use 10.0.2.2 for Android emulator, localhost for iOS simulator.
    // For physical devices, use your PC's local IP (e.g., 'http://192.168.1.104:5000/predict_intent').
    final apiUrl = 'http://192.168.1.2:5000/predict_intent'; // Example IP

    if (text.trim().isEmpty || text == 'Listening...') {
      setState(() {
        _response = 'No speech detected or empty query.';
      });
      return;
    }

    try {
      print('Sending request to: $apiUrl');
      print('Request body: ${jsonEncode({'text': text})}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _response = 'Intent: ${data['intent']}\nResponse: ${data['response']}';
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}\nMessage: ${response.body}';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _response = 'Failed to connect to the server: $e\nCheck Flask server and network.';
      });
    }
  }

  // Helper to show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Denied'),
        content: const Text('Please enable microphone access in your device settings to use voice input.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Opens app settings for user to grant permission
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop(); // Stop listening if active when the widget is disposed
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6aaac5), Color(0xff4e8ca0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppIcon(width: 70.w),
                ],
              ),
              SizedBox(height: 20.h),

              /// 👤 User Info (Using StreamBuilder)
              if (uid != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Something went wrong", style: TextStyle(color: Colors.white));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("No User Data", style: TextStyle(color: Colors.white));
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>?;

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundImage: userData?['profileImage'] != null && (userData?['profileImage'] as String).isNotEmpty
                              ? NetworkImage(userData!['profileImage'])
                              : const AssetImage('assets/images/icon_1.png') as ImageProvider,
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData?['name'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData?['role'] ?? 'Role',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                )
              else
                const Text("Not logged in", style: TextStyle(color: Colors.white)),

              SizedBox(height: 30.h),

              // Search Box (Optional: You could integrate voice input here directly)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              // --- Voice Input Section ---
              _buildVoiceInputSection(), // New method to build the voice input UI
              SizedBox(height: 30.h),
              // --- End Voice Input Section ---

              // Your existing drawer items
              _buildDrawerItem(
                title: 'My Profile',
                icon: Icons.person,
                onTap: () => _navigateTo(context, const ProfileScreen()),
              ),
              _buildDrawerItem(
                title: 'Home',
                icon: Icons.home,
                onTap: () => _navigateTo(context, const HomeScreen()),
              ),
              _buildDrawerItem(
                title: 'Settings',
                icon: Icons.settings,
                onTap: () => _navigateTo(context, const SettingsScreen()),
              ),
              _buildDrawerItem(
                title: 'Help & Feedback',
                icon: Icons.help_outline,
                onTap: () {
                  // Open Help
                },
              ),
              _buildDrawerItem(
                title: 'Signout',
                icon: Icons.exit_to_app,
                onTap: () => _signOut(context),
                showArrow: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New method to encapsulate the voice input UI
  Widget _buildVoiceInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Voice input text
        Text(
          'Voice Command:',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        // Displaying the recognized speech
        Container(
          padding: EdgeInsets.all(12.w),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            _voiceQuery.isEmpty ? 'Tap mic to speak...' : _voiceQuery,
            style: TextStyle(fontSize: 16.sp, color: Colors.white.withOpacity(0.9)),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 15.h),
        // Microphone Button
        Center(
          child: FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: _isListening ? Colors.red.shade700 : Colors.green.shade700,
            mini: false, // Make it a standard size FAB
            child: Icon(
              _isListening ? Icons.stop : Icons.mic,
              size: 30.sp,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Response Section
        Text(
          'Flask Response:',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        // Displaying the server response
        Container(
          padding: EdgeInsets.all(12.w),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            _response.isEmpty ? 'Awaiting backend response...' : _response,
            style: TextStyle(fontSize: 16.sp, color: Colors.white.withOpacity(0.9)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }


  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
    );
  }
}

