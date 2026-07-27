import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/services/web_stub.dart" as web;

void main() {
  group("MockStorage", () {
    test("getItem returns null when key does not exist", () {
      final web.MockStorage storage = web.MockStorage();

      expect(storage.getItem("missing_key"), isNull);
    });

    test("setItem stores value and getItem returns stored value", () {
      final web.MockStorage storage = web.MockStorage()
        ..setItem("token", "abc123");

      expect(storage.getItem("token"), "abc123");
    });

    test("setItem overwrites existing value for same key", () {
      final web.MockStorage storage = web.MockStorage()
        ..setItem("token", "old_value")
        ..setItem("token", "new_value");

      expect(storage.getItem("token"), "new_value");
    });

    test("stores multiple keys independently", () {
      final web.MockStorage storage = web.MockStorage()
        ..setItem("userId", "101")
        ..setItem("role", "admin")
        ..setItem("region", "UAE");

      expect(storage.getItem("userId"), "101");
      expect(storage.getItem("role"), "admin");
      expect(storage.getItem("region"), "UAE");
    });

    test("supports empty string key", () {
      final web.MockStorage storage = web.MockStorage()
        ..setItem("", "empty_key_value");

      expect(storage.getItem(""), "empty_key_value");
    });

    test("supports empty string value", () {
      final web.MockStorage storage = web.MockStorage()
        ..setItem("empty_value_key", "");

      expect(storage.getItem("empty_value_key"), "");
    });

    test("different MockStorage instances do not share data", () {
      final web.MockStorage firstStorage = web.MockStorage();
      final web.MockStorage secondStorage = web.MockStorage();

      firstStorage.setItem("token", "first_token");
      secondStorage.setItem("token", "second_token");

      expect(firstStorage.getItem("token"), "first_token");
      expect(secondStorage.getItem("token"), "second_token");
    });
  });

  group("MockWindow", () {
    test("has sessionStorage instance", () {
      final web.MockWindow mockWindow = web.MockWindow();

      expect(mockWindow.sessionStorage, isA<web.MockStorage>());
    });

    test("sessionStorage stores and returns values", () {
      final web.MockWindow mockWindow = web.MockWindow();

      mockWindow.sessionStorage.setItem("language", "en");

      expect(mockWindow.sessionStorage.getItem("language"), "en");
    });

    test("each MockWindow has independent sessionStorage", () {
      final web.MockWindow firstWindow = web.MockWindow();
      final web.MockWindow secondWindow = web.MockWindow();

      firstWindow.sessionStorage.setItem("session", "first");
      secondWindow.sessionStorage.setItem("session", "second");

      expect(firstWindow.sessionStorage.getItem("session"), "first");
      expect(secondWindow.sessionStorage.getItem("session"), "second");
    });
  });

  group("global window", () {
    test("global window exposes sessionStorage", () {
      expect(web.window.sessionStorage, isA<web.MockStorage>());
    });

    test("global window sessionStorage stores and returns value", () {
      const String key = "theme_web_stub_test";
      const String value = "dark";

      web.window.sessionStorage.setItem(key, value);

      expect(web.window.sessionStorage.getItem(key), value);
    });

    test("global window sessionStorage overwrites value", () {
      const String key = "theme_overwrite_web_stub_test";

      web.window.sessionStorage.setItem(key, "light");
      web.window.sessionStorage.setItem(key, "dark");

      expect(web.window.sessionStorage.getItem(key), "dark");
    });

    test("global window returns null for unknown key", () {
      expect(
        web.window.sessionStorage.getItem("unknown_web_stub_test_key"),
        isNull,
      );
    });
  });
}
