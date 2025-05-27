import 'package:flutter/material.dart';
import 'package:project/screens/home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _errorMessage = '';

  Future<void> _savePin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
      });
      return;
    }

    if (pin.length < 4) {
      setState(() {
        _errorMessage = 'PIN must be at least 4 digits long.';
      });
      return;
    }

    // Store the PIN securely using FlutterSecureStorage
    await _storage.write(key: 'user_pin', value: pin);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Your PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Set a new PIN for authentication'),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Save PIN'),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
