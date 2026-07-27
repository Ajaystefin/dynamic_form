import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/file_attachment/business_segment_payload.dart";

void main() {
  group("BusinessSegmentPayload.toJson", () {
    test(
        "serializes with rating and numeric population/gdp, arrays, audit, and nested structure",
        () {
      // Arrange
      final payload = BusinessSegmentPayload(
        appRefNo: "APP-001",
        rimNo: 12345,
        businessSegment: "Corporate",
        countryName: "United Arab Emirates",
        rating: "A",
        populationText: "10000000", // -> popuLation int
        gdpText: "500000000", // -> gdp int
        exportPartners: const ["IN", "CN"],
        importPartners: const ["US"],
        strengths: const ["Stable policy", "Strong logistics"],
        threats: const ["Oil price volatility"],
        createdBy: "tester",
        createdDate: DateTime.utc(2025, 1, 2, 3, 4, 5),
        updatedBy: "tester",
        updatedDate: DateTime.utc(2025, 1, 2, 3, 4, 5),
      );

      // Act
      final json = payload.toJson();

      // Assert - top-level fields
      expect(json["appRefNo"], "APP-001");
      expect(json["rimNo"], 12345);
      expect(json["businessSegment"], "Corporate");
      expect(json["customerType"], "Country");
      expect(json["createdBy"], "tester");
      expect(json["updatedBy"], "tester");
      // ISO-8601 UTC (ends with Z)
      expect(json["createdDate"], "2025-01-02T03:04:05.000Z");
      expect(json["updatedDate"], "2025-01-02T03:04:05.000Z");

      // Assert - nested countryOverView
      final cov = json["countryOverView"] as Map<String, dynamic>;
      expect(cov["countryName"], "United Arab Emirates");
      expect(cov["rating"], "A");
      // quirky backend key spelling 'popuLation'
      expect(cov["popuLation"], 10000000);
      expect(cov["gdp"], "500000000");
      expect(cov["exportPartners"], ["IN", "CN"]);
      expect(cov["importPartners"], ["US"]);
      expect(cov["strengths"], ["Stable policy", "Strong logistics"]);
      expect(cov["threats"], ["Oil price volatility"]);
    });

    test("omits rating and omits non-parseable numbers for popuLation/gdp", () {
      // Arrange: population/gdp not parseable
      final payload = BusinessSegmentPayload(
        appRefNo: "APP-002",
        rimNo: 777,
        businessSegment: "Corporate",
        countryName: "Oman",
        populationText: "ten", // not an int -> omit
        gdpText: "n/a", // not an int -> omit
        exportPartners: const [],
        importPartners: const [],
        strengths: const [],
        threats: const [],
        createdBy: "writer",
        createdDate: DateTime.utc(2024, 6),
        updatedBy: "writer",
        updatedDate: DateTime.utc(2024, 6),
      );

      // Act
      final json = payload.toJson();

      // Assert - present
      expect(json["appRefNo"], "APP-002");
      expect(json["rimNo"], 777);

      final cov = json["countryOverView"] as Map<String, dynamic>;
      expect(cov["countryName"], "Oman");

      // Assert - omitted keys
      expect(cov.containsKey("rating"), isFalse);
      expect(cov.containsKey("popuLation"), isFalse);
      expect(cov.containsKey("gdp"), isTrue);
    });
  });

  group("BusinessSegmentPayload.fromContext", () {
    test("creates payload with audit defaults when Globals.user is null", () {
      // Arrange: use factory with explicit domain fields; audit comes from
      // factory
      final before = DateTime.now().toUtc();

      final payload = BusinessSegmentPayload.fromContext(
        appRefNo: "APP-CTX-1",
        rimNo: 99001,
        businessSegment: "Corporate",
        countryName: "Qatar",
        rating: "AA",
        populationText: "3000000",
        gdpText: "200000000",
        exportPartners: const ["AE"],
        importPartners: const ["US", "CN"],
        strengths: const ["High income"],
        threats: const ["Geopolitical risk"],
      );

      // Act
      final json = payload.toJson();

      // Assert
      expect(json["appRefNo"], "APP-CTX-1");
      expect(json["rimNo"], 99001);
      expect(json["customerType"], "Country");
      expect(json["businessSegment"], "Corporate");

      // Factory defaults: createdBy/updatedBy = 'system' and UTC timestamps
      expect(json["createdBy"], "system"); // derived when Globals.user is null
      expect(json["updatedBy"], "system");

      // Timestamps are ISO-8601 UTC and "recent" (allow a 5s window)
      final created = DateTime.parse(json["createdDate"] as String);
      final updated = DateTime.parse(json["updatedDate"] as String);
      final after = DateTime.now().toUtc();

      expect(created.isUtc, isTrue);
      expect(updated.isUtc, isTrue);
      // created <= now and >= before (allowing a few seconds skew)
      expect(
        created.isAfter(before.subtract(const Duration(seconds: 5))),
        isTrue,
      );
      expect(
        after.isAfter(created.subtract(const Duration(seconds: 5))),
        isTrue,
      );

      final cov = json["countryOverView"] as Map<String, dynamic>;
      expect(cov["countryName"], "Qatar");
      expect(cov["rating"], "AA");
      expect(cov["popuLation"], 3000000);
      expect(cov["gdp"], "200000000");
      expect(cov["exportPartners"], ["AE"]);
      expect(cov["importPartners"], ["US", "CN"]);
      expect(cov["strengths"], ["High income"]);
      expect(cov["threats"], ["Geopolitical risk"]);
    });
  });
}
