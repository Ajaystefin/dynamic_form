import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/globals.dart';

class EncryptionHelper {
  static const int _nonceLength = 12;
  static const Uuid _uuid = Uuid();
  static String? _cachedDeviceId;
  static bool _cleared = false;

  /// Clear cached device ID - for testing purposes
  static void clearCachedDeviceId() {
    _cachedDeviceId = null;
    _cleared = true;
  }

  // Static AES key from backend (base64-decoded)
  static final Uint8List _aesKey = _getAesKey();
  static Uint8List _getAesKey() {
    String envKey = Globals.sessionID.substring(0, 14);
    Uint8List keyBytes = utf8.encode(envKey);
    Uint8List aesKeyBytes = Uint8List.fromList([
      ...keyBytes,
      ...List.filled(16 - keyBytes.length, 0),
    ]);
    return aesKeyBytes;
  }

  /// Encrypts plain text using AES-128 GCM
  static String encrypt(String plainText) {
    final nonce = _generateNonce();

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(_aesKey), 128, nonce, Uint8List(0)),
      );

    Uint8List input = Uint8List.fromList(utf8.encode(plainText));
    Uint8List encrypted = cipher.process(input);

    Uint8List result = Uint8List.fromList(nonce + encrypted);
    return base64Encode(result);
  }

  /// Generates a secure random nonce (IV)
  static Uint8List _generateNonce() {
    final rnd = Random.secure();
    return Uint8List.fromList(
        List.generate(_nonceLength, (_) => rnd.nextInt(256)));
  }

  /// Generates a device ID using device_info_plus
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    String deviceId;
    if (_cleared) {
      // For testing, generate a new UUID each time after clearing
      deviceId = _uuid.v4();
      _cleared = false; // Reset flag
    } else {
      // Use device_info_plus to get device information
      deviceId = await _getDeviceIdentifier();
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Gets device identifier using device_info_plus
  static Future<String> _getDeviceIdentifier() async {
    final deviceInfo = DeviceInfoPlugin();
    final buffer = StringBuffer();

    try {
      final webInfo = await deviceInfo.webBrowserInfo;

      // Create identifier from web browser info
      buffer.write(webInfo.userAgent ?? '');
      buffer.write(webInfo.language ?? '');
      buffer.write(webInfo.platform ?? '');
      buffer.write(webInfo.vendor ?? '');
      buffer.write(webInfo.vendorSub ?? '');
      buffer.write(webInfo.hardwareConcurrency?.toString() ?? '');
      buffer.write(webInfo.maxTouchPoints?.toString() ?? '');
    } catch (e) {
      // Fallback for testing or unsupported platforms
      buffer.write('fallback-device-id');
      buffer.write(DateTime.now().timeZoneOffset.inMinutes.toString());
    }

    // Generate UUID v5 based on device info for consistency
    return _uuid.v5(Namespace.url.value, buffer.toString());
  }

  /// Generates a 32-byte encryption key from device ID using SHA-256
  static Future<Uint8List> generateKeyFromDeviceId() async {
    final deviceId = await getDeviceId();
    final digest = SHA256Digest();
    final input = utf8.encode(deviceId);

    return digest.process(Uint8List.fromList(input));
  }
}
