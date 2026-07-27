import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/models/request/approval/proposed_facilities.dart";

void main() {
  group("ProposedFacilities", () {
    test("constructor should assign all provided values", () {
      final DateTime tpanReceivedDate = DateTime.utc(2026, 1, 10);
      final DateTime creditAppDate = DateTime.utc(2026, 2, 15);

      final ProposedFacilities model = ProposedFacilities(
        applicationRefNo: "APP-001",
        purpose: "Working capital",
        requestType: "New",
        status: "Approved",
        tpanReceivedDate: tpanReceivedDate,
        customerRimNumber: 12345,
        groupId: 10,
        creditAppDate: creditAppDate,
        customerName: "Test Customer",
        cleanExposure: 5000,
      );

      expect(model.applicationRefNo, "APP-001");
      expect(model.purpose, "Working capital");
      expect(model.requestType, "New");
      expect(model.status, "Approved");
      expect(model.tpanReceivedDate, tpanReceivedDate);
      expect(model.customerRimNumber, 12345);
      expect(model.groupId, 10);
      expect(model.creditAppDate, creditAppDate);
      expect(model.customerName, "Test Customer");
      expect(model.cleanExposure, 5000);
    });

    test("constructor should allow nullable status", () {
      final ProposedFacilities model = ProposedFacilities(
        applicationRefNo: "APP-002",
        purpose: "Expansion",
        requestType: "Renewal",
        tpanReceivedDate: DateTime.utc(2026, 3),
        customerRimNumber: 45678,
        groupId: 20,
        creditAppDate: DateTime.utc(2026, 3, 5),
        customerName: "Nullable Status Customer",
        cleanExposure: 1000,
      );

      expect(model.status, isNull);
    });

    test("fromJson should parse all json values correctly", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "applicationRefNo": "APP-003",
        "purpose": "Asset purchase",
        "requestType": "Amendment",
        "status": "Pending",
        "tpanRecievedDate": "2026-04-01T10:30:00.000Z",
        "customerRimNumber": 11111,
        "groupId": 30,
        "creditAppDate": "2026-04-02T12:00:00.000Z",
        "customerName": "Json Customer",
        "cleanExposure": 7500,
      };

      final ProposedFacilities model = ProposedFacilities.fromJson(json);

      expect(model.applicationRefNo, "APP-003");
      expect(model.purpose, "Asset purchase");
      expect(model.requestType, "Amendment");
      expect(model.status, "Pending");
      expect(
        model.tpanReceivedDate,
        DateTime.parse("2026-04-01T10:30:00.000Z"),
      );
      expect(model.customerRimNumber, 11111);
      expect(model.groupId, 30);
      expect(model.creditAppDate, DateTime.parse("2026-04-02T12:00:00.000Z"));
      expect(model.customerName, "Json Customer");
      expect(model.cleanExposure, 7500);
    });

    test("fromJson should apply default values for nullable fallback fields",
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        "applicationRefNo": "APP-004",
        "purpose": null,
        "requestType": "New",
        "status": null,
        "tpanRecievedDate": "2026-05-01T00:00:00.000Z",
        "customerRimNumber": 22222,
        "groupId": 40,
        "creditAppDate": "2026-05-02T00:00:00.000Z",
        "customerName": "Default Customer",
        "cleanExposure": null,
      };

      final ProposedFacilities model = ProposedFacilities.fromJson(json);

      expect(model.applicationRefNo, "APP-004");
      expect(model.purpose, "");
      expect(model.status, "");
      expect(model.cleanExposure, 0);
    });

    test("toJson should serialize model correctly", () {
      final DateTime tpanReceivedDate = DateTime.utc(2026, 6, 1, 8, 30);
      final DateTime creditAppDate = DateTime.utc(2026, 6, 2, 9, 45);

      final ProposedFacilities model = ProposedFacilities(
        applicationRefNo: "APP-005",
        purpose: "Trade finance",
        requestType: "Review",
        status: "Completed",
        tpanReceivedDate: tpanReceivedDate,
        customerRimNumber: 33333,
        groupId: 50,
        creditAppDate: creditAppDate,
        customerName: "Serialize Customer",
        cleanExposure: 9000,
      );

      final Map<String, dynamic> json = model.toJson();

      expect(json, <String, dynamic>{
        "applicationRefNo": "APP-005",
        "purpose": "Trade finance",
        "requestType": "Review",
        "status": "Completed",
        "tpanRecievedDate": tpanReceivedDate.toUtc().toIso8601String(),
        "customerRimNumber": 33333,
        "groupId": 50,
        "creditAppDate": creditAppDate.toUtc().toIso8601String(),
        "customerName": "Serialize Customer",
      });

      expect(json.containsKey("cleanExposure"), isFalse);
    });

    test("toJson should serialize null status", () {
      final ProposedFacilities model = ProposedFacilities(
        applicationRefNo: "APP-006",
        purpose: "General",
        requestType: "New",
        tpanReceivedDate: DateTime.utc(2026, 7),
        customerRimNumber: 44444,
        groupId: 60,
        creditAppDate: DateTime.utc(2026, 7, 2),
        customerName: "Null Status Customer",
        cleanExposure: 1200,
      );

      final Map<String, dynamic> json = model.toJson();

      expect(json["status"], isNull);
    });

    test("fromJson and toJson should work together", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "applicationRefNo": "APP-007",
        "purpose": "Round trip",
        "requestType": "New",
        "status": "Draft",
        "tpanRecievedDate": "2026-08-01T00:00:00.000Z",
        "customerRimNumber": 55555,
        "groupId": 70,
        "creditAppDate": "2026-08-05T00:00:00.000Z",
        "customerName": "Round Trip Customer",
        "cleanExposure": 1500,
      };

      final ProposedFacilities model = ProposedFacilities.fromJson(json);
      final Map<String, dynamic> encoded = model.toJson();

      expect(encoded["applicationRefNo"], json["applicationRefNo"]);
      expect(encoded["purpose"], json["purpose"]);
      expect(encoded["requestType"], json["requestType"]);
      expect(encoded["status"], json["status"]);
      expect(encoded["customerRimNumber"], json["customerRimNumber"]);
      expect(encoded["groupId"], json["groupId"]);
      expect(encoded["customerName"], json["customerName"]);

      expect(
        encoded["tpanRecievedDate"],
        DateTime.parse(json["tpanRecievedDate"] as String)
            .toUtc()
            .toIso8601String(),
      );

      expect(
        encoded["creditAppDate"],
        DateTime.parse(json["creditAppDate"] as String)
            .toUtc()
            .toIso8601String(),
      );
    });
  });
}
