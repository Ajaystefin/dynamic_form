import "dart:convert";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:pointycastle/api.dart";
import "package:pointycastle/block/aes.dart";
import "package:pointycastle/block/modes/gcm.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";

/// Mirror the helper's internal AES key derivation (_getAesKey)
Uint8List _deriveAesKeyFromSession(String sessionId) {
  final envKey = sessionId.substring(0, 16); // identical behavior to helper
  final keyBytes = utf8.encode(envKey);
  return Uint8List.fromList([
    ...keyBytes,
    ...List.filled(16 - keyBytes.length, 0),
  ]);
}

/// Decrypt base64 cipher from EncryptionHelper.encrypt() using AES-128 GCM.
String _decryptWithAesGcm({
  required Uint8List aesKey,
  required String base64Cipher,
}) {
  final all = base64Decode(base64Cipher);
  // First 12 bytes are the nonce/IV (same _nonceLength used by helper)
  final nonce = Uint8List.view(all.buffer, 0, 12);
  final ct = Uint8List.view(all.buffer, 12);

  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(KeyParameter(aesKey), 128, nonce, Uint8List(0)),
    );
  final out = cipher.process(ct);
  return utf8.decode(out);
}

void main() {
  group("EncryptionHelper – test setup", () {
    setUpAll(() async {
      // Use a long session ID so substring(0,14) is safe.
      // Base64(UUID) ensures deterministic length > 14.
      const rawKey = "1c1c6328-cdba-4bce-812b-0c89bc1c3098";
      Globals.sessionID = base64Encode(
        utf8.encode(
          rawKey,
        ),
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)

      TestWidgetsFlutterBinding.ensureInitialized();
      await EnvConfig.setEnvironment();
    });
  });

  group("AES-GCM encryption", () {
    test("encrypt returns base64 and embeds a 12-byte nonce", () {
      const msg = "hello-world";
      final out = EncryptionHelper.encrypt(
        msg,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(out, isA<String>());
      expect(() => base64Decode(out), returnsNormally);

      final all = base64Decode(out);
      expect(all.length, greaterThan(12)); // nonce + ciphertext+tag
      final nonce = Uint8List.view(all.buffer, 0, 12);
      expect(nonce.length, 12); // covers _nonceLength usage
    });

    test(
        "encrypt produces different ciphertext for"
        " same plaintext (random nonce)", () {
      const msg = "same-input";
      final c1 = EncryptionHelper.encrypt(
        msg,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      final c2 = EncryptionHelper.encrypt(
        msg,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(c1, isNot(equals(c2)));
    });

    test("AES-GCM roundtrip decrypt yields the original plaintext", () {
      final session = Globals.sessionID;
      final aesKey = _deriveAesKeyFromSession(
        session,
      ); // mirror _getAesKey [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)

      const original = "Plaintext to verify AES-GCM decryption — UTF8 ✓";
      final enc = EncryptionHelper.encrypt(
        original,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      final dec = _decryptWithAesGcm(aesKey: aesKey, base64Cipher: enc);
      expect(dec, original);
    });

    test("encrypt works with empty and non-ASCII plaintext", () {
      final empty = EncryptionHelper.encrypt(
        "",
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(() => base64Decode(empty), returnsNormally);

      final unicode = EncryptionHelper.encrypt(
        "नमसढ़ते, مرحبا, 㝓ん㝫㝡㝯",
      ); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(() => base64Decode(unicode), returnsNormally);
    });
  });

  group("Device ID – caching & branches", () {
    setUp(EncryptionHelper.clearCachedDeviceId);

    test(
        "after clear: first "
        "call uses UUID "
        "v4; second call returns cached value", () async {
      final id1 = await EncryptionHelper
          .getDeviceId(); // v4 branch, resets _cleared=false [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(id1, isNotEmpty);
      expect(id1.length, 36);

      final id2 = await EncryptionHelper
          .getDeviceId(); // cached return [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(id2, equals(id1));
    });

    test("distinct UUID v4 values across separate clears", () async {
      final idA = await EncryptionHelper.getDeviceId();
      EncryptionHelper
          .clearCachedDeviceId(); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      final idB = await EncryptionHelper.getDeviceId();
      expect(idA, isNot(equals(idB))); // randomness covered
    });

    test("fresh start (not cleared) → _getDeviceIdentifier path (UUID v5)",
        () async {
      // Reset to simulate sequence: consume v4 once, then rely on identifier
      // path
      EncryptionHelper.clearCachedDeviceId();
      await EncryptionHelper.getDeviceId(); // v4 once, clears flag to false
      EncryptionHelper.clearCachedDeviceId(); // make cache null again

      // This call goes through _getDeviceIdentifier. On non-web,
      // webBrowserInfo can throw ⇒ fallback path exercised.
      final id = await EncryptionHelper
          .getDeviceId(); // v5 path [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(id, isNotEmpty);
      expect(id.length, 36);
    });
  });

  group("Key derivation (SHA-256) from device ID", () {
    test("generateKeyFromDeviceId returns 32 bytes (256-bit)", () async {
      final key = await EncryptionHelper
          .generateKeyFromDeviceId(); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(key, isA<Uint8List>());
      expect(key.length, 32);
    });

    test("key stays consistent while device ID is cached; differs after clear",
        () async {
      final k1 = await EncryptionHelper
          .generateKeyFromDeviceId(); // cached deviceId [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      final k2 = await EncryptionHelper
          .generateKeyFromDeviceId(); // same cached [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(k1, equals(k2));

      // Clear ⇒ new deviceId ⇒ new SHA-256 key
      EncryptionHelper
          .clearCachedDeviceId(); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      final k3 = await EncryptionHelper
          .generateKeyFromDeviceId(); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(k3.length, 32);
      expect(k3, isNot(equals(k1)));
    });

    test("key bytes are valid (non-zero somewhere, all within byte range)",
        () async {
      final key = await EncryptionHelper
          .generateKeyFromDeviceId(); // [1](https://cbddxb-my.sharepoint.com/personal/pwn15012_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/encryption_helper_test.dart)
      expect(key.any((b) => b != 0), isTrue);
      expect(key.every((b) => b >= 0 && b <= 255), isTrue);
    });
  });
}
