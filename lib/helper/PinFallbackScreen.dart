import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project/screens/home_screen.dart';

class PinFallbackScreen extends StatefulWidget {
  const PinFallbackScreen({super.key});

  @override
  State<PinFallbackScreen> createState() => _PinFallbackScreenState();
}

class _PinFallbackScreenState extends State<PinFallbackScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _error = '';

  Future<void> _verifyPin() async {
    // Retrieve stored PIN securely
    final storedPin = await _storage.read(key: 'user_pin');

    if (_pinController.text == storedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _error = 'Incorrect PIN. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Use your PIN as fallback authentication'),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PIN',
                errorText: _error.isNotEmpty ? _error : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}

