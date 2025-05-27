// lib/utils/biometric_helper.dart

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isFingerprintRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprint_registered') ?? false;
  }

  Future<bool> authenticate({bool biometricOnly = true}) async {
    final isRegistered = await isFingerprintRegistered();
    final reason = isRegistered
        ? 'Authenticate to login'
        : 'Register your fingerprint for future login';

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      if (authenticated && !isRegistered) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fingerprint_registered', true);
      }

      return authenticated;
    } on PlatformException {
      return false;
    }
  }
}
