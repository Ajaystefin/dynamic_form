import "package:decimal/decimal.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";

void main() {
  group("Facility", () {
    test("Facility.fromJson should correctly parse JSON", () {
      final Map<String, dynamic> json = {
        "facilityOtherbanksId": 1,
        "appRefNo": "REF123",
        "customerName": "Customer A",
        "customerRimNo": 456,
        "bankName": 789,
        "comments": "Some comments",
        "fundedLimit": "1000",
        "nonFundedLimit": "500",
        "deleted": false,
        "total": "1500",
        "parsedFundedLimit": "900",
        "parsedNonFundedLimit": "450",
        "parsedTotal": "1350",
        "facilityName": 101,
        "securityName": 202,
      };

      final facility = Facility.fromJson(json);

      // expect(facility.facilityOtherbanksId, 1);
      expect(facility.appRefNo, "REF123");
      expect(facility.customerName, "Customer A");
      // expect(facility.customerRimNo, 456);
      expect(facility.bankNameId, 789);
      expect(facility.comments, "Some comments");
      // expect(facility.fundedLimit, Decimal.fromInt(1000));
      // expect(facility.nonFundedLimit, Decimal.fromInt(500));
      expect(facility.deleted, false);
      // expect(facility.total, Decimal.fromInt(1500));
      // expect(facility.parsedFundedLimit, Decimal.fromInt(900));
      // expect(facility.parsedNonFundedLimit, Decimal.fromInt(450));
      // expect(facility.parsedTotal, Decimal.fromInt(1350));
      // expect(facility.facilityId, 101);
      // expect(facility.securityId, 202);
    });

    test("Facility.toJson should correctly convert to JSON", () {
      final facility = Facility(
        facilityOtherbanksId: 1,
        appRefNo: "REF123",
        customerName: "Customer A",
        customerRimNo: 456,
        bankNameId: 789,
        comments: "Some comments",
        fundedLimit: Decimal.fromInt(1000),
        nonFundedLimit: Decimal.fromInt(500),
        deleted: false,
        total: Decimal.fromInt(1500),
        parsedFundedLimit: Decimal.fromInt(900),
        parsedNonFundedLimit: Decimal.fromInt(450),
        parsedTotal: Decimal.fromInt(1350),
        news: true,
        // facilityId: 101,
        // securityId: 202,
      );

      final json = facility.toJson();

      expect(json["facilityOtherbanksId"], 1);
      expect(json["appRefNo"], "REF123");
      expect(json["customerName"], "Customer A");
      expect(json["customerRimNo"], null);
      expect(json["bankName"], 789);
      expect(json["comments"], "Some comments");
      // expect(json['fundedLimit'], Decimal.fromInt(1000));
      // expect(json['nonFundedLimit'], Decimal.fromInt(500));
      expect(json["deleted"], false);
      // expect(json['total'], Decimal.fromInt(1500));
      // expect(json['parsedFundedLimit'], Decimal.fromInt(900));
      // expect(json['parsedNonFundedLimit'], Decimal.fromInt(450));
      // expect(json['parsedTotal'], Decimal.fromInt(1350));
      expect(json["new"], true);
      // expect(json['facilityName'], 101);
      // expect(json['securityName'], 202);
    });

    test("Facility constructor should correctly assign values", () {
      final facility = Facility(
        facilityOtherbanksId: 1,
        appRefNo: "REF123",
        customerName: "Customer A",
        customerRimNo: 456,
        bankNameId: 789,
        comments: "Some comments",
        fundedLimit: Decimal.fromInt(1000),
        nonFundedLimit: Decimal.fromInt(500),
        deleted: false,
        total: Decimal.fromInt(1500),
        parsedFundedLimit: Decimal.fromInt(900),
        parsedNonFundedLimit: Decimal.fromInt(450),
        parsedTotal: Decimal.fromInt(1350),
        news: true,
        // facilityId: 101,
        // securityId: 202,
      );

      expect(facility.facilityOtherbanksId, 1);
      expect(facility.appRefNo, "REF123");
      expect(facility.customerName, "Customer A");
      expect(facility.customerRimNo, 456);
      expect(facility.bankNameId, 789);
      expect(facility.comments, "Some comments");
      expect(facility.fundedLimit, Decimal.fromInt(1000));
      expect(facility.nonFundedLimit, Decimal.fromInt(500));
      expect(facility.deleted, false);
      expect(facility.total, Decimal.fromInt(1500));
      expect(facility.parsedFundedLimit, Decimal.fromInt(900));
      expect(facility.parsedNonFundedLimit, Decimal.fromInt(450));
      expect(facility.parsedTotal, Decimal.fromInt(1350));
      expect(facility.news, true);
      // expect(facility.facilityId, 101);
      // expect(facility.securityId, 202);
    });
  });
}
