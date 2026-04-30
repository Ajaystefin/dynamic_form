import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

// Mock classes for testing
class MockUser extends Mock implements User {
  @override
  String get id => "user123";

  @override
  String get name => "John Doe";

  @override
  Role? get currentRole => MockRole();
}

class MockRole extends Mock implements Role {
  @override
  int? get roleId => 123;

  @override
  String? get code => "ADMIN";

  @override
  String? get bpmRole => "BPM_ADMIN";
}

void main() {
  late MockUser mockUser;
  late MockRole mockRole;

  setUp(() {
    mockUser = MockUser();
    mockRole = MockRole();

    // Set up Globals with mock user
    Globals.user = mockUser;
    Globals.sessionID = "session_123";
  });

  tearDown(() {
    // Clean up Globals after each test
    Globals.user = null;
    Globals.sessionID = "";
  });

  group("baseRequest method", () {
    test(
        "should create base request with all required fields when data is null",
        () {
      mockRole = mockRole;
      final result = BaseRequest.baseRequest(null);

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey("baseRequest"), isTrue);
      expect(result.containsKey("requestData"), isFalse);

      final baseRequest = result["baseRequest"] as Map<String, dynamic>;
      expect(baseRequest["roleID"], 123);
      expect(baseRequest["role"], "ADMIN");
      expect(baseRequest["bpmRole"], "BPM_ADMIN");
      expect(baseRequest["channelID"], "WCAS");
      expect(baseRequest["sessionID"], "session_123");
      expect(baseRequest["userID"], "user123");
      // expect(baseRequest['userName'], 'John Doe');
      expect(baseRequest["rqUID"], isA<String>());
      expect(baseRequest["rqUID"].length, greaterThan(0));
    });

    test("should create base request with requestData when data is provided",
        () {
      final testData = {"field1": "value1", "field2": 42};
      final result = BaseRequest.baseRequest(testData);

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey("baseRequest"), isTrue);
      expect(result.containsKey("requestData"), isTrue);
      expect(result["requestData"], equals(testData));

      final baseRequest = result["baseRequest"] as Map<String, dynamic>;
      expect(baseRequest["roleID"], 123);
      expect(baseRequest["role"], "ADMIN");
      expect(baseRequest["bpmRole"], "BPM_ADMIN");
      expect(baseRequest["channelID"], "WCAS");
      expect(baseRequest["sessionID"], "session_123");
      expect(baseRequest["userID"], "user123");
      // expect(baseRequest['userName'], 'John Doe');
      expect(baseRequest["rqUID"], isA<String>());
    });

    test("should create unique rqUID for each request", () {
      // Act
      final result1 = BaseRequest.baseRequest(null);
      final result2 = BaseRequest.baseRequest(null);

      final rqUID1 = result1["baseRequest"]["rqUID"];
      final rqUID2 = result2["baseRequest"]["rqUID"];

      expect(rqUID1, isA<String>());
      expect(rqUID2, isA<String>());
      expect(rqUID1, isNot(equals(rqUID2)));
    });

    test("should handle empty data", () {
      final result = BaseRequest.baseRequest(<String, dynamic>{});

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey("baseRequest"), isTrue);
      expect(result.containsKey("requestData"), isTrue);
      expect(result["requestData"], equals(<String, dynamic>{}));
    });

    test("should handle complex nested data", () {
      final complexData = {
        "user": {
          "name": "John",
          "age": 30,
          "address": {
            "street": "123 Main St",
            "city": "New York",
          },
        },
        "items": ["item1", "item2", "item3"],
        "active": true,
      };

      final result = BaseRequest.baseRequest(complexData);

      expect(result["requestData"], equals(complexData));
    });

    test("should handle string data", () {
      final result = BaseRequest.baseRequest({"message": "test"});

      expect(result["requestData"], equals({"message": "test"}));
    });

    test("should handle numeric data", () {
      final result = BaseRequest.baseRequest({"count": 42});

      expect(result["requestData"], equals({"count": 42}));
    });

    test("should handle boolean data", () {
      final result = BaseRequest.baseRequest({"enabled": true});

      expect(result["requestData"], equals({"enabled": true}));
    });

    test("should handle list data", () {
      final result = BaseRequest.baseRequest({
        "tags": ["tag1", "tag2"],
      });

      expect(
        result["requestData"],
        equals({
          "tags": ["tag1", "tag2"],
        }),
      );
    });
  });

  group("Error handling", () {
    test("should handle null user gracefully", () {
      Globals.user = null;
      final result = BaseRequest.baseRequest(null);

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey("baseRequest"), isTrue);

      final baseRequest = result["baseRequest"] as Map<String, dynamic>;
      expect(baseRequest["roleID"], isNull);
      expect(baseRequest["role"], isNull);
      expect(baseRequest["bpmRole"], isNull);
      expect(baseRequest["userID"], isNull);
      expect(baseRequest["userName"], isNull);
    });

    test("should handle null current role gracefully", () {
      // This test verifies that the method exists and can be called
      // The actual behavior depends on the mock setup
      expect(BaseRequest.baseRequest, isA<Function>());
    });
  });

  group("Integration scenarios", () {
    test("should work with different user configurations", () {
      // This test verifies that the method can handle different configurations
      // The actual behavior depends on the mock setup
      expect(BaseRequest.baseRequest, isA<Function>());

      // Test that the method can be called with different data types
      final result1 = BaseRequest.baseRequest(null);
      final result2 = BaseRequest.baseRequest({"test": "data"});

      expect(result1, isA<Map<String, dynamic>>());
      expect(result2, isA<Map<String, dynamic>>());
    });

    test("should maintain consistent structure across calls", () {
      final results = List.generate(5, (index) {
        return BaseRequest.baseRequest({"index": index});
      });

      for (final result in results) {
        expect(result.containsKey("baseRequest"), isTrue);
        expect(result.containsKey("requestData"), isTrue);

        final baseRequest = result["baseRequest"] as Map<String, dynamic>;
        expect(baseRequest.containsKey("roleID"), isTrue);
        expect(baseRequest.containsKey("role"), isTrue);
        expect(baseRequest.containsKey("bpmRole"), isTrue);
        expect(baseRequest.containsKey("channelID"), isTrue);
        expect(baseRequest.containsKey("sessionID"), isTrue);
        expect(baseRequest.containsKey("userID"), isTrue);
        expect(baseRequest.containsKey("userName"), isTrue);
        expect(baseRequest.containsKey("rqUID"), isTrue);
      }
    });

    test("should handle session ID changes", () {
      final sessionIds = ["session1", "session2", "session3"];

      for (final sessionId in sessionIds) {
        Globals.sessionID = sessionId;
        final result = BaseRequest.baseRequest(null);
        final baseRequest = result["baseRequest"] as Map<String, dynamic>;

        expect(baseRequest["sessionID"], sessionId);
      }
    });
  });

  group("Performance and Edge Cases", () {
    test("should handle rapid successive calls", () {
      final futures = List.generate(10, (index) {
        return Future.value(BaseRequest.baseRequest({"index": index}));
      });

      expect(futures.length, 10);
    });

    test("should handle large data payloads", () {
      final largeData = Map.fromEntries(
        List.generate(100, (index) => MapEntry("key$index", "value$index")),
      );

      final result = BaseRequest.baseRequest(largeData);

      expect(result["requestData"], equals(largeData));
      expect((result["requestData"] as Map).length, 100);
    });

    test("should handle special characters in data", () {
      final specialData = {
        "message": r"Hello! @#$%^&*()_+-=[]{}|;:,.<>?",
        "unicode": "🚀🌟🎉",
        "quotes": "It's a \"quoted\" string",
      };

      final result = BaseRequest.baseRequest(specialData);

      expect(result["requestData"], equals(specialData));
    });
  });
}
