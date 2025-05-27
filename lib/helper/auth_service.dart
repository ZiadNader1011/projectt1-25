import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static const _emailKey = 'secure_email';
  static const _passwordKey = 'secure_password';
  static const _bioEnabledKey = 'biometric_enabled';
  static const _retryCountKey = 'biometric_retry_count';
  static const _pinHashKey = 'secure_pin_hash';
  static const _aesKeyStorage = 'aes_key';
  static const _lastFailedKey = 'biometric_last_failed';
  static const _maxRetries = 5;

  static late encrypt.Key _aesKey;

  static Future<bool> authenticateWithBiometrics({String reason = 'Authenticate to continue'}) {
    return _performBiometricAuth(reason);
  }
  static Future<bool> _deviceSupportsSecureAuth() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      final biometrics = await _localAuth.getAvailableBiometrics();
      print(
          'canCheck: $canCheck, supported: $supported, biometrics.isNotEmpty: ${biometrics
              .isNotEmpty}'); // Add this
      return canCheck && supported && biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  static Future<File> _getBiometricFlagFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/biometric.flag';
    print('Biometric flag file path: $filePath'); // Add this
    return File(filePath);
  }



  static Future<void> initialize() async {
    final stored = await _storage.read(key: _aesKeyStorage);
    if (stored == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _aesKeyStorage, value: base64UrlEncode(key.bytes));
      _aesKey = key;
    } else {
      _aesKey = encrypt.Key(base64Url.decode(stored));
    }
  }

  static String _encrypt(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_aesKey));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return jsonEncode({'iv': iv.base64, 'data': encrypted.base64});
  }

  static String _decrypt(String encryptedData) {
    final parsed = jsonDecode(encryptedData);
    final iv = encrypt.IV.fromBase64(parsed['iv']);
    final encrypter = encrypt.Encrypter(encrypt.AES(_aesKey));
    return encrypter.decrypt64(parsed['data'], iv: iv);
  }

  static Future<String?> enrollWithBiometrics(String email, String password) async {
    try {
      if (!await _deviceSupportsSecureAuth()) {
        return 'Biometric authentication not supported or not enrolled';
      }

      final didAuth = await _performBiometricAuth('Authenticate to enroll biometrics');
      if (!didAuth) return 'Biometric authentication failed during enrollment';

      await _storage.write(key: _emailKey, value: _encrypt(email));
      await _storage.write(key: _passwordKey, value: _encrypt(password));
      await _storage.write(key: _bioEnabledKey, value: 'true');
      await _storage.write(key: _retryCountKey, value: '0');

      final flagFile = await _getBiometricFlagFile();
      await flagFile.writeAsString('biometric_enrolled');

      return 'success';
    } catch (e) {
      return 'Enrollment error: $e';
    }
  }


  static Future<String?> biometricLogin() async {
    await initialize();

    final flagFile = await _getBiometricFlagFile();
    final fileExists = await flagFile.exists();

    final isEnabled = await _storage.read(key: _bioEnabledKey);
    if (!fileExists || isEnabled != 'true') {
      return 'Biometric login not enabled or enrolled';
    }

    if (!await _canRetryBiometric()) return 'Try again in 1 minute';

    final retryCount = int.tryParse(await _storage.read(key: _retryCountKey) ?? '0') ?? 0;
    if (retryCount >= _maxRetries) return 'Too many failed attempts. Try again later.';

    if (!await _deviceSupportsSecureAuth()) return 'Biometric not available';

    final didAuth = await _performBiometricAuth('Login using fingerprint or device PIN');
    if (!didAuth) {
      await _storage.write(key: _retryCountKey, value: '${retryCount + 1}');
      await _storage.write(key: _lastFailedKey, value: DateTime.now().toIso8601String());
      return 'Authentication failed (${retryCount + 1}/$_maxRetries)';
    }

    final emailEnc = await _storage.read(key: _emailKey);
    final passEnc = await _storage.read(key: _passwordKey);
    if (emailEnc == null || passEnc == null) return 'Stored credentials not found';

    final email = _decrypt(emailEnc);
    final password = _decrypt(passEnc);

    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _storage.write(key: _retryCountKey, value: '0');

    return 'success';
  }

  static Future<String?> loginWithPin(String pin) async {
    try {
      final hashed = sha256.convert(utf8.encode(pin)).toString();
      final stored = await _storage.read(key: _pinHashKey);
      if (stored != hashed) return 'Incorrect PIN';

      final emailEnc = await _storage.read(key: _emailKey);
      final passEnc = await _storage.read(key: _passwordKey);
      if (emailEnc == null || passEnc == null) return 'Credentials missing';

      final email = _decrypt(emailEnc);
      final password = _decrypt(passEnc);

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } catch (e) {
      return 'PIN login error: $e';
    }
  }

  static Future<void> setPin(String pin) async {
    final hashed = sha256.convert(utf8.encode(pin)).toString();
    await _storage.write(key: _pinHashKey, value: hashed);
  }

  static Future<bool> _performBiometricAuth(String reason) async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      final useBiometricOnly = biometrics.contains(BiometricType.fingerprint);
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: useBiometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      print('Biometric authentication result: $authenticated'); // Add this
      return authenticated;
    } catch (e) {
      print("AuthService: _performBiometricAuth error: $e");
      return false;
    }
  }


  static Future<bool> _canRetryBiometric() async {
    final lastFailedStr = await _storage.read(key: _lastFailedKey);
    if (lastFailedStr == null) return true;

    final lastFailed = DateTime.tryParse(lastFailedStr);
    if (lastFailed == null) return true;

    final now = DateTime.now();
    return now.difference(lastFailed).inMinutes > 1;
  }

  static Future<void> clearStoredCredentials() async {
    await _storage.deleteAll();
    final flagFile = await _getBiometricFlagFile();
    if (await flagFile.exists()) await flagFile.delete();
  }


  static Future<bool> isBiometricLoginEnabled() async {
    return (await _storage.read(key: _bioEnabledKey)) == 'true';
  }

  static Future<int> getRetryCount() async {
    return int.tryParse(await _storage.read(key: _retryCountKey) ?? '0') ?? 0;
  }

  /// Google Sign-In logic
  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': userCredential.user!.displayName,
      'email': userCredential.user!.email,
      'phone': userCredential.user!.phoneNumber,
      'photoUrl': userCredential.user!.photoURL,
      'role': 'patient',
    }, SetOptions(merge: true));

    return userCredential;
  }

  static Future<String?> getStoredEmail() async {
    final enc = await _storage.read(key: _emailKey);
    return enc == null ? null : _decrypt(enc);
  }

  static Future<String?> getStoredPassword() async {
    final enc = await _storage.read(key: _passwordKey);
    return enc == null ? null : _decrypt(enc);
  }



  static Future<void> debugPrintStoredCredentials() async {
    try {
      final emailEnc = await _storage.read(key: _emailKey);
      final passEnc = await _storage.read(key: _passwordKey);
      final aesKeyRaw = await _storage.read(key: _aesKeyStorage);

      if (emailEnc == null || passEnc == null || aesKeyRaw == null) {
        print("❌ One or more stored values are null.");
        return;
      }

      final email = _decrypt(emailEnc);
      final password = _decrypt(passEnc);
      final aesKeyBase64 = base64Url.encode(_aesKey.bytes);

      print('🔓 Decrypted Email: $email');
      print('🔓 Decrypted Password: $password');
      print('🗝 AES Key (Base64): $aesKeyBase64');
    } catch (e) {
      print('⚠️ Error during debug print: $e');
    }
  }
}
