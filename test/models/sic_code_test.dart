import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/sic_code.dart";

void main() {
  group("SicCodeReview", () {
    test("should create SicCodeReview instance with all properties", () {
      final sicCodeReview = SicCodeReview(
        sicCodeReviewId: 1,
        custInfoId: 100,
        appRefNo: "APP123",
        rimNo: 200,
        facilityId: 300,
        customerRimNo: 400,
        customerName: "Test Customer",
        primaryBusinessActivity: "Technology",
        existingSicCode: "1234",
        proposedSicCode: "5678",
        accountLevelSicCode: "9012",
        createdBy: "admin",
        createdDate: "2025-09-01",
        updatedBy: "admin",
        updatedDate: "2025-09-05",
      );

      expect(sicCodeReview.sicCodeReviewId, 1);
      expect(sicCodeReview.custInfoId, 100);
      expect(sicCodeReview.appRefNo, "APP123");
      expect(sicCodeReview.rimNo, 200);
      expect(sicCodeReview.facilityId, 300);
      expect(sicCodeReview.customerRimNo, 400);
      expect(sicCodeReview.customerName, "Test Customer");
      expect(sicCodeReview.primaryBusinessActivity, "Technology");
      expect(sicCodeReview.existingSicCode, "1234");
      expect(sicCodeReview.proposedSicCode, "5678");
      expect(sicCodeReview.accountLevelSicCode, "9012");
      expect(sicCodeReview.createdBy, "admin");
      expect(sicCodeReview.createdDate, "2025-09-01");
      expect(sicCodeReview.updatedBy, "admin");
      expect(sicCodeReview.updatedDate, "2025-09-05");
    });

    test("should create SicCodeReview instance with minimal properties", () {
      final sicCodeReview = SicCodeReview();

      expect(sicCodeReview.sicCodeReviewId, isNull);
      expect(sicCodeReview.customerName, isNull);
      expect(sicCodeReview.existingSicCode, isNull);
    });

    test("should create SicCodeReview from JSON with all properties", () {
      final json = {
        "sicCodeReviewId": 1,
        "custInfoId": 100,
        "appRefNo": "APP123",
        "rimNo": 200,
        "facilityId": 300,
        "customerName": "Test Customer",
        "primaryBusinessActivity": "Technology",
        "industryCbdSicCode": "1234", // Maps to existingSicCode
        "proposedSicCode": "5678",
        "accountLevelSicCode": "9012",
        "createdBy": "admin",
        "createdDate": "2025-09-01",
        "updatedBy": "admin",
        "updatedDate": "2025-09-05",
      };

      final sicCodeReview = SicCodeReview.fromJson(json);

      expect(sicCodeReview.sicCodeReviewId, 1);
      expect(sicCodeReview.customerRimNo, 200);
      expect(sicCodeReview.existingSicCode, "1234");
      expect(sicCodeReview.proposedSicCode, "5678");
      expect(sicCodeReview.accountLevelSicCode, "9012");
    });
  });
}
