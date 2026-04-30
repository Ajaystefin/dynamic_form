import "dart:convert";
import "dart:io";

import "package:easy_localization/easy_localization.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";

/// Test configuration utilities for setting up environment variables and Hive
class TestConfig {
  static const String testEncryptionKey = "12345678901234567890123456789012";

  /// Set up test environment with proper encryption key
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Disable EasyLocalization warnings globally
    EasyLocalization.logger.enableLevels = [];
    // Set up Hive for testing with temporary directory
    final tempDir = Directory.systemTemp;
    Hive.init(tempDir.path);

    // Register test adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TestStringAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TestIntAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TestBoolAdapter());
    }
  }

  /// Create a test box with encryption
  static Future<Box> createTestBox(String boxName) async {
    final encryptionKey = utf8.encode(testEncryptionKey);
    return Hive.openBox(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    await Hive.close();
  }

  /// Get test encryption key as bytes
  static List<int> get testEncryptionKeyBytes => utf8.encode(testEncryptionKey);
}

// Test adapters for different data types
class TestStringAdapter extends TypeAdapter<String> {
  @override
  final int typeId = 0;

  @override
  String read(BinaryReader reader) => reader.readString();

  @override
  void write(BinaryWriter writer, String obj) => writer.writeString(obj);
}

class TestIntAdapter extends TypeAdapter<int> {
  @override
  final int typeId = 1;

  @override
  int read(BinaryReader reader) => reader.readInt();

  @override
  void write(BinaryWriter writer, int obj) => writer.writeInt(obj);
}

class TestBoolAdapter extends TypeAdapter<bool> {
  @override
  final int typeId = 2;

  @override
  bool read(BinaryReader reader) => reader.readBool();

  @override
  void write(BinaryWriter writer, bool obj) => writer.writeBool(obj);
}
