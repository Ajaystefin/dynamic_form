import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/services/draft/browser_unload_service.dart";

void main() {
  group("BrowserUnloadService", () {
    test("singleton instance should not be null", () {
      final service = BrowserUnloadService.instance;

      expect(service, isNotNull);
    });

    test("register should not throw", () {
      final service = BrowserUnloadService.instance;

      expect(service.register, returnsNormally);
    });

    test("unregister should not throw", () {
      final service = BrowserUnloadService.instance;

      expect(service.unregister, returnsNormally);
    });

    test("tryFetchWithKeepalive returns bool", () {
      final result = BrowserUnloadService.tryFetchWithKeepalive(
        url: "https://example.com",
        body: "{}",
        headers: {"Content-Type": "application/json"},
      );

      expect(result, isA<bool>());
    });

    test("tryFetchWithKeepalive returns false on non-web", () {
      final result = BrowserUnloadService.tryFetchWithKeepalive(
        url: "https://example.com",
        body: "{}",
        headers: {"Content-Type": "application/json"},
      );

      // On test environment (non-web), should be false
      expect(result, false);
    });
  });
}
