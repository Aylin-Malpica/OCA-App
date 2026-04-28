import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class PasswordHasher {

  static const int iterations = 100000;
  static const int saltSize = 16;
  static const int keySize = 16;

  static Future<bool> verify(String password, String stored) async {
    final payload = _base64UrlDecode(stored);

    if (payload.length != saltSize + keySize) {
      return false;
    }

    final salt = payload.sublist(0, saltSize);
    final storedKey = payload.sublist(saltSize);

    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: keySize * 8,
    );

    final secretKey = SecretKey(utf8.encode(password));

    final newKey = await algorithm.deriveKey(
      secretKey: secretKey,
      nonce: salt,
    );

    final computedBytes = await newKey.extractBytes();
    final valid = _compare(storedKey, computedBytes);
    return valid;
  }

  static bool _compare(List<int> a, List<int> b) {

    if (a.length != b.length) return false;

    int diff = 0;

    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }

    return diff == 0;
  }

  static Uint8List _base64UrlDecode(String input) {

    String s = input.replaceAll('-', '+').replaceAll('_', '/');

    while (s.length % 4 != 0) {
      s += '=';
    }

    return base64.decode(s);
  }
}