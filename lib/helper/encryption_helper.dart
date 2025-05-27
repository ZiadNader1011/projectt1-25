import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class EncryptionHelper {
  static final _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'aes_key';

  // Retrieve or generate AES key
  static Future<encrypt.Key> _getKey() async {
    String? storedKey = await _storage.read(key: _keyStorageKey);
    if (storedKey == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _keyStorageKey, value: key.base64);
      return key;
    } else {
      return encrypt.Key.fromBase64(storedKey);
    }
  }

  // Encrypt plain text
  static Future<String> encryptText(String plainText) async {
    final key = await _getKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // Encrypt and save a file
  static Future<String> encryptAndSaveFile(String path) async {
    final fileBytes = await File(path).readAsBytes();
    final key = await _getKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

    final dir = await getApplicationDocumentsDirectory();
    final encryptedFile = File('${dir.path}/encrypted_${DateTime.now().millisecondsSinceEpoch}.enc');
    await encryptedFile.writeAsBytes(encrypted.bytes);

    return encryptedFile.path;
  }
}
