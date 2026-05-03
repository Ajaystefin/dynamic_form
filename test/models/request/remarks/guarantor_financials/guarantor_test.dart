import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart";

void main() {
  group("Guarantor", () {
    test("should create a Guarantor instance with required fields", () {
      final guarantor = Guarantor(
        entityId: 1,
        name: "Test Guarantor",
        analysisHtml: "<html><body>Test</body></html>",
        spreadsmartUrl: "http://test.com",
      );
      expect(guarantor.entityId, 1);
      expect(guarantor.name, "Test Guarantor");
      expect(guarantor.analysisHtml, "<html><body>Test</body></html>");
      expect(guarantor.spreadsmartUrl, "http://test.com");
      expect(guarantor.canDelete, false);
    });

    test("should create a Guarantor instance with all fields", () {
      final guarantor = Guarantor(
        entityId: 2,
        name: "Another Guarantor",
        analysisHtml: "<html><body>Another Test</body></html>",
        spreadsmartUrl: "http://another.com",
        canDelete: true,
      );
      expect(guarantor.entityId, 2);
      expect(guarantor.name, "Another Guarantor");
      expect(guarantor.analysisHtml, "<html><body>Another Test</body></html>");
      expect(guarantor.spreadsmartUrl, "http://another.com");
      expect(guarantor.canDelete, true);
    });

    test("copyWith should return a new instance with updated values", () {
      final originalGuarantor = Guarantor(
        entityId: 1,
        name: "Test Guarantor",
        analysisHtml: "<html><body>Test</body></html>",
        spreadsmartUrl: "http://test.com",
        canDelete: false,
      );

      final updatedGuarantor = originalGuarantor.copyWith(
        name: "Updated Guarantor",
        canDelete: true,
      );

      expect(updatedGuarantor.entityId, 1);
      expect(updatedGuarantor.name, "Updated Guarantor");
      expect(updatedGuarantor.analysisHtml, "<html><body>Test</body></html>");
      expect(updatedGuarantor.spreadsmartUrl, "http://test.com");
      expect(updatedGuarantor.canDelete, true);
    });

    test("copyWith should return a new instance with same values if no changes",
        () {
      final originalGuarantor = Guarantor(
        entityId: 1,
        name: "Test Guarantor",
        analysisHtml: "<html><body>Test</body></html>",
        spreadsmartUrl: "http://test.com",
        canDelete: false,
      );

      final updatedGuarantor = originalGuarantor.copyWith();

      expect(updatedGuarantor.entityId, 1);
      expect(updatedGuarantor.name, "Test Guarantor");
      expect(updatedGuarantor.analysisHtml, "<html><body>Test</body></html>");
      expect(updatedGuarantor.spreadsmartUrl, "http://test.com");
      expect(updatedGuarantor.canDelete, false);
    });
  });
}
