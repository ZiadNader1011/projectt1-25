// lib/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  // Store the encryption key securely
  static Future<void> storeKey(String key) async {
    try {
      await _storage.write(key: 'encryption_key', value: key);
    } catch (e) {
      print("Error storing key: $e");
    }
  }

  // Retrieve the encryption key
  static Future<String?> getKey() async {
    try {
      return await _storage.read(key: 'encryption_key');
    } catch (e) {
      print("Error retrieving key: $e");
      return null;
    }
  }

  // Delete the encryption key (optional)
  static Future<void> deleteKey() async {
    try {
      await _storage.delete(key: 'encryption_key');
    } catch (e) {
      print("Error deleting key: $e");
    }
  }
}
