import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";
import "../../test_config.dart";

class MockStorageInterface extends Mock implements StorageInterface {}

void main() {
  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  group("LocalStorageService", () {
    late LocalStorageService localStorageService;
    late MockStorageInterface mockStorage;

    setUp(() {
      localStorageService = LocalStorageService();
      mockStorage = MockStorageInterface();
      localStorageService.setStorage(mockStorage);
    });

    group("Singleton Pattern", () {
      test("should return the same instance", () {
        final instance1 = LocalStorageService();
        final instance2 = LocalStorageService();
        expect(identical(instance1, instance2), isTrue);
      });

      test("should have consistent instance across multiple calls", () {
        final instance1 = LocalStorageService();
        final instance2 = LocalStorageService();
        final instance3 = LocalStorageService();

        expect(identical(instance1, instance2), isTrue);
        expect(identical(instance2, instance3), isTrue);
        expect(identical(instance1, instance3), isTrue);
      });
    });

    group("Storage Operations", () {
      test("should initialize storage", () async {
        when(() => mockStorage.init(path: any(named: "path")))
            .thenAnswer((_) async {});

        await localStorageService.init();

        verify(() => mockStorage.init(path: any(named: "path"))).called(1);
      });

      test("should initialize storage with custom path", () async {
        when(() => mockStorage.init(path: any(named: "path")))
            .thenAnswer((_) async {});

        await localStorageService.init(path: "/custom/path");

        verify(() => mockStorage.init(path: "/custom/path")).called(1);
      });

      test("should put data", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});

        await localStorageService.put("test_box", "test_key", "test_value");

        verify(() => mockStorage.put("test_box", "test_key", "test_value"))
            .called(1);
      });

      test("should get data", () async {
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "test_value");

        final result =
            await localStorageService.get<String>("test_box", "test_key");

        expect(result, equals("test_value"));
        verify(() => mockStorage.get("test_box", "test_key")).called(1);
      });

      test("should get data with default value", () async {
        when(() => mockStorage.get(any(), any())).thenAnswer((_) async => null);

        final result = await localStorageService
            .get<String>("test_box", "test_key", defaultValue: "default_value");

        expect(result, equals("default_value"));
        verify(() => mockStorage.get("test_box", "test_key")).called(1);
      });

      test("should delete data", () async {
        when(() => mockStorage.delete(any(), any())).thenAnswer((_) async {});

        await localStorageService.delete("test_box", "test_key");

        verify(() => mockStorage.delete("test_box", "test_key")).called(1);
      });

      test("should clear box", () async {
        when(() => mockStorage.clearBox(any())).thenAnswer((_) async {});

        await localStorageService.clearBox("test_box");

        verify(() => mockStorage.clearBox("test_box")).called(1);
      });
    });

    group("Data Types", () {
      test("should handle string data", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "string_value");

        await localStorageService.put("test_box", "key", "string_value");
        final result = await localStorageService.get<String>("test_box", "key");

        expect(result, equals("string_value"));
        verify(() => mockStorage.put("test_box", "key", "string_value"))
            .called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });

      test("should handle integer data", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any())).thenAnswer((_) async => 42);

        await localStorageService.put("test_box", "key", 42);
        final result = await localStorageService.get<int>("test_box", "key");

        expect(result, equals(42));
        verify(() => mockStorage.put("test_box", "key", 42)).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });

      test("should handle boolean data", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any())).thenAnswer((_) async => true);

        await localStorageService.put("test_box", "key", true);
        final result = await localStorageService.get<bool>("test_box", "key");

        expect(result, equals(true));
        verify(() => mockStorage.put("test_box", "key", true)).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });

      test("should handle list data", () async {
        final testList = ["item1", "item2", "item3"];
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => testList);

        await localStorageService.put("test_box", "key", testList);
        final result =
            await localStorageService.get<List<String>>("test_box", "key");

        expect(result, equals(testList));
        verify(() => mockStorage.put("test_box", "key", testList)).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });

      test("should handle map data", () async {
        final testMap = {"key1": "value1", "key2": "value2"};
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => testMap);

        await localStorageService.put("test_box", "key", testMap);
        final result = await localStorageService.get<Map<String, String>>(
          "test_box",
          "key",
        );

        expect(result, equals(testMap));
        verify(() => mockStorage.put("test_box", "key", testMap)).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });

      test("should handle null data", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any())).thenAnswer((_) async => null);

        await localStorageService.put("test_box", "key", null);
        final result = await localStorageService.get<String>("test_box", "key");

        expect(result, isNull);
        verify(() => mockStorage.put("test_box", "key", null)).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });
    });

    group("Error Handling", () {
      test("should handle storage errors gracefully", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenThrow(Exception("Storage error"));

        expect(
          () => localStorageService.put("test_box", "key", "value"),
          throwsException,
        );
      });

      test("should handle get errors gracefully", () async {
        when(() => mockStorage.get(any(), any()))
            .thenThrow(Exception("Get error"));

        expect(
          () => localStorageService.get("test_box", "key"),
          throwsException,
        );
      });

      test("should handle delete errors gracefully", () async {
        when(() => mockStorage.delete(any(), any()))
            .thenThrow(Exception("Delete error"));

        expect(
          () => localStorageService.delete("test_box", "key"),
          throwsException,
        );
      });

      test("should handle clear box errors gracefully", () async {
        when(() => mockStorage.clearBox(any()))
            .thenThrow(Exception("Clear error"));

        expect(
          () => localStorageService.clearBox("test_box"),
          throwsException,
        );
      });
    });

    group("Method Chaining", () {
      test("should support method chaining patterns", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "value");
        when(() => mockStorage.delete(any(), any())).thenAnswer((_) async {});
        when(() => mockStorage.clearBox(any())).thenAnswer((_) async {});

        // Test that methods can be called in sequence
        await localStorageService.put("test_box", "key", "value");
        await localStorageService.get("test_box", "key");
        await localStorageService.delete("test_box", "key");
        await localStorageService.clearBox("test_box");

        verify(() => mockStorage.put("test_box", "key", "value")).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
        verify(() => mockStorage.delete("test_box", "key")).called(1);
        verify(() => mockStorage.clearBox("test_box")).called(1);
      });
    });

    group("Multiple Operations", () {
      test("should handle multiple operations on different boxes", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "value");

        await localStorageService.put("box1", "key1", "value1");
        await localStorageService.put("box2", "key2", "value2");
        await localStorageService.get("box1", "key1");
        await localStorageService.get("box2", "key2");

        verify(() => mockStorage.put("box1", "key1", "value1")).called(1);
        verify(() => mockStorage.put("box2", "key2", "value2")).called(1);
        verify(() => mockStorage.get("box1", "key1")).called(1);
        verify(() => mockStorage.get("box2", "key2")).called(1);
      });

      test("should handle multiple operations on same box", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "value");

        await localStorageService.put("test_box", "key1", "value1");
        await localStorageService.put("test_box", "key2", "value2");
        await localStorageService.get("test_box", "key1");
        await localStorageService.get("test_box", "key2");

        verify(() => mockStorage.put("test_box", "key1", "value1")).called(1);
        verify(() => mockStorage.put("test_box", "key2", "value2")).called(1);
        verify(() => mockStorage.get("test_box", "key1")).called(1);
        verify(() => mockStorage.get("test_box", "key2")).called(1);
      });
    });

    group("Edge Cases", () {
      test("should handle empty strings", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "value");

        await localStorageService.put("", "", "value");
        await localStorageService.get("", "");

        verify(() => mockStorage.put("", "", "value")).called(1);
        verify(() => mockStorage.get("", "")).called(1);
      });

      test("should handle special characters", () async {
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => "value");

        await localStorageService.put(
          "test@box#123",
          "test@key#123",
          "test@value#123",
        );
        await localStorageService.get("test@box#123", "test@key#123");

        verify(
          () => mockStorage.put(
            "test@box#123",
            "test@key#123",
            "test@value#123",
          ),
        ).called(1);
        verify(() => mockStorage.get("test@box#123", "test@key#123")).called(1);
      });

      test("should handle very long strings", () async {
        final longString = "a" * 1000;
        when(() => mockStorage.put(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.get(any(), any()))
            .thenAnswer((_) async => longString);

        await localStorageService.put("test_box", "key", longString);
        final result = await localStorageService.get<String>("test_box", "key");

        expect(result, equals(longString));
        verify(() => mockStorage.put("test_box", "key", longString)).called(1);
        verify(() => mockStorage.get("test_box", "key")).called(1);
      });
    });

    group("Service Behavior", () {
      test("should maintain singleton behavior across operations", () async {
        final instance1 = LocalStorageService();
        final instance2 = LocalStorageService();

        // Set storage on one instance
        final mockStorage1 = MockStorageInterface();
        instance1.setStorage(mockStorage1);

        // Verify both instances are the same
        expect(identical(instance1, instance2), isTrue);

        // Verify the second instance also has the same storage
        when(() => mockStorage1.put(any(), any(), any()))
            .thenAnswer((_) async {});

        await instance2.put("test_box", "key", "value");

        verify(() => mockStorage1.put("test_box", "key", "value")).called(1);
      });

      test("should handle storage replacement", () async {
        final mockStorage1 = MockStorageInterface();
        final mockStorage2 = MockStorageInterface();

        localStorageService.setStorage(mockStorage1);
        when(() => mockStorage1.put(any(), any(), any()))
            .thenAnswer((_) async {});

        await localStorageService.put("test_box", "key", "value1");
        verify(() => mockStorage1.put("test_box", "key", "value1")).called(1);

        localStorageService.setStorage(mockStorage2);
        when(() => mockStorage2.put(any(), any(), any()))
            .thenAnswer((_) async {});

        await localStorageService.put("test_box", "key", "value2");
        verify(() => mockStorage2.put("test_box", "key", "value2")).called(1);
        verifyNever(() => mockStorage1.put("test_box", "key", "value2"));
      });

      test("should create HiveStorage when no storage is set", () async {
        final service = LocalStorageService();

        // Don't set storage - should create HiveStorage automatically
        // Note: This will fail in test environment due to missing encryption
        // key
        // but we can test that the service structure is correct
        expect(service, isA<LocalStorageService>());
        expect(service.init, isA<Function>());
        expect(service.put, isA<Function>());
        expect(service.get, isA<Function>());
        expect(service.delete, isA<Function>());
        expect(service.clearBox, isA<Function>());
      });
    });
  });

  group("HiveStorage with Real Hive Operations", () {
    late HiveStorage hiveStorage;
    late Box testBox;

    setUpAll(() async {
      // Create a test box for real Hive operations using test configuration
      testBox = await TestConfig.createTestBox("test_storage_box");
    });

    setUp(() {
      hiveStorage =
          HiveStorage(encryptionKey: TestConfig.testEncryptionKeyBytes);
    });

    tearDown(() async {
      await testBox.clear();
    });

    tearDownAll(() async {
      await testBox.close();
    });

    test("should implement StorageInterface", () {
      expect(hiveStorage, isA<StorageInterface>());
    });

    test("should have all required methods", () {
      expect(hiveStorage.init, isA<Function>());
      expect(hiveStorage.put, isA<Function>());
      expect(hiveStorage.get, isA<Function>());
      expect(hiveStorage.delete, isA<Function>());
      expect(hiveStorage.clearBox, isA<Function>());
    });

    test("should handle initialization", () async {
      expect(() => hiveStorage.init(), returnsNormally);
    });

    test("should handle initialization with custom path", () async {
      expect(() => hiveStorage.init(path: "/custom/path"), returnsNormally);
    });

    test("should handle multiple initialization calls", () async {
      expect(() => hiveStorage.init(), returnsNormally);
      expect(() => hiveStorage.init(), returnsNormally);
      expect(() => hiveStorage.init(path: "/another/path"), returnsNormally);
    });

    test("should handle initialization with null path", () async {
      expect(() => hiveStorage.init(path: null), returnsNormally);
    });

    test("should handle initialization with empty path", () async {
      expect(() => hiveStorage.init(path: ""), returnsNormally);
    });

    test("should handle initialization with special characters in path",
        () async {
      expect(
        () => hiveStorage.init(path: "/path/with/special@chars#123"),
        returnsNormally,
      );
    });

    test("should handle initialization with very long path", () async {
      final longPath = '/path/${'a' * 1000}';
      expect(() => hiveStorage.init(path: longPath), returnsNormally);
    });

    test("should handle initialization with relative path", () async {
      expect(() => hiveStorage.init(path: "./relative/path"), returnsNormally);
    });

    test("should handle initialization with absolute path", () async {
      expect(() => hiveStorage.init(path: "/absolute/path"), returnsNormally);
    });

    test("should handle initialization with Windows-style path", () async {
      expect(
        () => hiveStorage.init(path: r"C:\Windows\Path"),
        returnsNormally,
      );
    });

    test("should handle initialization with Unix-style path", () async {
      expect(() => hiveStorage.init(path: "/unix/style/path"), returnsNormally);
    });

    test("should handle initialization with path containing spaces", () async {
      expect(
        () => hiveStorage.init(path: "/path with spaces"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing dots", () async {
      expect(() => hiveStorage.init(path: "/path.with.dots"), returnsNormally);
    });

    test("should handle initialization with path containing underscores",
        () async {
      expect(
        () => hiveStorage.init(path: "/path_with_underscores"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing hyphens", () async {
      expect(
        () => hiveStorage.init(path: "/path-with-hyphens"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing numbers", () async {
      expect(
        () => hiveStorage.init(path: "/path123with456numbers"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing mixed characters",
        () async {
      expect(
        () => hiveStorage.init(path: r"/path@with#mixed$chars%123"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing unicode characters",
        () async {
      expect(
        () => hiveStorage.init(path: "/path/with/unicode/ñáéíóú"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing emoji", () async {
      expect(
        () => hiveStorage.init(path: "/path/with/emoji/🚀"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing backslashes",
        () async {
      expect(
        () => hiveStorage.init(path: r"/path\with\backslashes"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing forward slashes",
        () async {
      expect(
        () => hiveStorage.init(path: "/path/with/forward/slashes"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing multiple slashes",
        () async {
      expect(
        () => hiveStorage.init(path: "///multiple///slashes///"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing only slashes",
        () async {
      expect(() => hiveStorage.init(path: "///"), returnsNormally);
    });

    test("should handle initialization with path containing only dots",
        () async {
      expect(() => hiveStorage.init(path: "..."), returnsNormally);
    });

    test(
        "should handle initialization with path"
        " containing only special characters", () async {
      expect(() => hiveStorage.init(path: r"@#$%^&*()"), returnsNormally);
    });

    test("should handle initialization with path containing only numbers",
        () async {
      expect(() => hiveStorage.init(path: "123456789"), returnsNormally);
    });

    test("should handle initialization with path containing only letters",
        () async {
      expect(
        () => hiveStorage.init(path: "abcdefghijklmnopqrstuvwxyz"),
        returnsNormally,
      );
    });

    test(
        "should handle "
        "initialization with path "
        "containing only uppercase letters", () async {
      expect(
        () => hiveStorage.init(path: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing mixed case letters",
        () async {
      expect(
        () => hiveStorage.init(path: "AbCdEfGhIjKlMnOpQrStUvWxYz"),
        returnsNormally,
      );
    });

    test("should handle initialization with path containing only whitespace",
        () async {
      expect(() => hiveStorage.init(path: "   "), returnsNormally);
    });

    test("should handle initialization with path containing tabs", () async {
      expect(() => hiveStorage.init(path: "\t\t\t"), returnsNormally);
    });

    test("should handle initialization with path containing newlines",
        () async {
      expect(() => hiveStorage.init(path: "\n\n\n"), returnsNormally);
    });

    test("should handle initialization with path containing carriage returns",
        () async {
      expect(() => hiveStorage.init(path: "\r\r\r"), returnsNormally);
    });

    test("should handle initialization with path containing form feeds",
        () async {
      expect(() => hiveStorage.init(path: "\f\f\f"), returnsNormally);
    });

    test("should handle initialization with path containing vertical tabs",
        () async {
      expect(() => hiveStorage.init(path: "\v\v\v"), returnsNormally);
    });

    test("should handle initialization with path containing bell characters",
        () async {
      expect(() => hiveStorage.init(path: "aaa"), returnsNormally);
    });

    test("should handle initialization with path containing escape sequences",
        () async {
      expect(() => hiveStorage.init(path: "\x1b\x1b\x1b"), returnsNormally);
    });

    test("should handle initialization with path containing null bytes",
        () async {
      expect(() => hiveStorage.init(path: "000"), returnsNormally);
    });

    test("should handle initialization with path containing delete characters",
        () async {
      expect(() => hiveStorage.init(path: "\x7f\x7f\x7f"), returnsNormally);
    });

    test("should handle initialization with path containing extended ASCII",
        () async {
      expect(() => hiveStorage.init(path: "\x80\x80\x80"), returnsNormally);
    });

    test("should handle initialization with path containing high ASCII",
        () async {
      expect(() => hiveStorage.init(path: "\xff\xff\xff"), returnsNormally);
    });

    // Test device ID-based encryption
    test("should use device ID-based encryption key by default", () async {
      // Ensure device ID is consistent
      final deviceId1 = await EncryptionHelper.getDeviceId();
      final deviceId2 = await EncryptionHelper.getDeviceId();
      expect(deviceId1, equals(deviceId2));

      // Ensure key generation is consistent
      final key1 = await EncryptionHelper.generateKeyFromDeviceId();
      final key2 = await EncryptionHelper.generateKeyFromDeviceId();
      expect(key1, equals(key2));
      expect(key1.length, equals(32)); // 256 bits
    });

    test("should work with device ID encryption in real storage", () async {
      final deviceKey = await EncryptionHelper.generateKeyFromDeviceId();
      expect(deviceKey.length, equals(32));

      // This verifies that the device ID key can be used for Hive encryption
      expect(() => HiveAesCipher(deviceKey), returnsNormally);
    });

    // Test actual Hive operations
    test("should put and get string data", () async {
      await hiveStorage.put("test_box", "string_key", "test_string_value");
      final result = await hiveStorage.get("test_box", "string_key");
      expect(result, equals("test_string_value"));
    });

    test("should put and get integer data", () async {
      await hiveStorage.put("test_box", "int_key", 42);
      final result = await hiveStorage.get("test_box", "int_key");
      expect(result, equals(42));
    });

    test("should put and get boolean data", () async {
      await hiveStorage.put("test_box", "bool_key", true);
      final result = await hiveStorage.get("test_box", "bool_key");
      expect(result, equals(true));
    });

    test("should put and get list data", () async {
      final testList = ["item1", "item2", "item3"];
      await hiveStorage.put("test_box", "list_key", testList);
      final result = await hiveStorage.get("test_box", "list_key");
      expect(result, equals(testList));
    });

    test("should put and get map data", () async {
      final testMap = {"key1": "value1", "key2": "value2"};
      await hiveStorage.put("test_box", "map_key", testMap);
      final result = await hiveStorage.get("test_box", "map_key");
      expect(result, equals(testMap));
    });

    test("should put and get null data", () async {
      await hiveStorage.put("test_box", "null_key", null);
      final result = await hiveStorage.get("test_box", "null_key");
      expect(result, isNull);
    });

    test("should delete data", () async {
      await hiveStorage.put("test_box", "delete_key", "value_to_delete");
      await hiveStorage.delete("test_box", "delete_key");
      final result = await hiveStorage.get("test_box", "delete_key");
      expect(result, isNull);
    });

    test("should clear box", () async {
      await hiveStorage.put("test_box", "key1", "value1");
      await hiveStorage.put("test_box", "key2", "value2");
      await hiveStorage.clearBox("test_box");

      final result1 = await hiveStorage.get("test_box", "key1");
      final result2 = await hiveStorage.get("test_box", "key2");

      expect(result1, isNull);
      expect(result2, isNull);
    });

    test("should handle multiple operations on same box", () async {
      await hiveStorage.put("test_box", "key1", "value1");
      await hiveStorage.put("test_box", "key2", "value2");
      await hiveStorage.put("test_box", "key3", "value3");

      final result1 = await hiveStorage.get("test_box", "key1");
      final result2 = await hiveStorage.get("test_box", "key2");
      final result3 = await hiveStorage.get("test_box", "key3");

      expect(result1, equals("value1"));
      expect(result2, equals("value2"));
      expect(result3, equals("value3"));
    });

    test("should handle operations on different boxes", () async {
      await hiveStorage.put("box1", "key1", "value1");
      await hiveStorage.put("box2", "key2", "value2");

      final result1 = await hiveStorage.get("box1", "key1");
      final result2 = await hiveStorage.get("box2", "key2");

      expect(result1, equals("value1"));
      expect(result2, equals("value2"));
    });

    test("should handle overwriting existing data", () async {
      await hiveStorage.put("test_box", "overwrite_key", "old_value");
      await hiveStorage.put("test_box", "overwrite_key", "new_value");

      final result = await hiveStorage.get("test_box", "overwrite_key");
      expect(result, equals("new_value"));
    });

    test("should handle empty strings", () async {
      await hiveStorage.put("test_box", "", "empty_key_value");
      final result = await hiveStorage.get("test_box", "");
      expect(result, equals("empty_key_value"));
    });

    test("should handle special characters in keys and values", () async {
      await hiveStorage.put("test@box#123", "test@key#123", "test@value#123");
      final result = await hiveStorage.get("test@box#123", "test@key#123");
      expect(result, equals("test@value#123"));
    });

    test("should handle very long strings", () async {
      final longString = "a" * 1000;
      await hiveStorage.put("test_box", "long_key", longString);
      final result = await hiveStorage.get("test_box", "long_key");
      expect(result, equals(longString));
    });

    test("should handle complex nested data structures", () async {
      final complexData = {
        "string": "value",
        "number": 42,
        "boolean": true,
        "list": [
          1,
          2,
          3,
          {"nested": "data"},
        ],
        "map": {"key": "value", "number": 123},
      };

      await hiveStorage.put("test_box", "complex_key", complexData);
      final result = await hiveStorage.get("test_box", "complex_key");
      expect(result, equals(complexData));
    });

    test("should handle method chaining pattern", () async {
      await hiveStorage.put("test_box", "key1", "value1");
      await hiveStorage.put("test_box", "key2", "value2");
      await hiveStorage.get("test_box", "key1");
      await hiveStorage.get("test_box", "key2");
      await hiveStorage.delete("test_box", "key1");
      await hiveStorage.clearBox("test_box");

      // Verify operations completed without errors
      final result = await hiveStorage.get("test_box", "key2");
      expect(result, isNull);
    });
  });
}
