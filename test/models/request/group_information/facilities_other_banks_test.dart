import "package:decimal/decimal.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/models/request/group_information/facilities_other_banks.dart";

void main() {
  group("FacilitiesOtherBanks", () {
    test("fromJson creates a valid object from JSON", () {
      final Map<String, dynamic> json = {
        "facilitiesList": [
          {
            "facilityOtherbanksId": 1,
            "appRefNo": "APP001",
            "customerName": "Test Customer",
            "customerRimNo": 12345,
            "bankName": 1,
            "comments": "Test Comments",
            "fundedLimit": "1000",
            "nonFundedLimit": "500",
            "deleted": false,
            "total": "1500",
            "parsedFundedLimit": "1000",
            "parsedNonFundedLimit": "500",
            "parsedTotal": "1500",
            "new": true,
            "facilityName": 1,
            "securityName": 1,
          },
          {
            "facilityOtherbanksId": 2,
            "appRefNo": "APP002",
            "customerName": "Test Customer 2",
            "customerRimNo": 54321,
            "bankName": 2,
            "comments": "Test Comments 2",
            "fundedLimit": "2000",
            "nonFundedLimit": "1000",
            "deleted": true,
            "total": "3000",
            "parsedFundedLimit": "2000",
            "parsedNonFundedLimit": "1000",
            "parsedTotal": "3000",
            "new": false,
            "facilityName": 2,
            "securityName": 2,
          },
        ],
        "customer": {
          "customerName": "Test Customer",
          "customerRimNo": 12345,
        },
      };

      final facilitiesOtherBanks = FacilitiesOtherBanks.fromJson(json);

      expect(facilitiesOtherBanks, isA<FacilitiesOtherBanks>());
      expect(facilitiesOtherBanks.facilitiesList, isNotNull);
      expect(facilitiesOtherBanks.facilitiesList!.length, 2);
      // expect(facilitiesOtherBanks.facilitiesList![0].facilityOtherbanksId,
      // 1);
      expect(
        facilitiesOtherBanks.customer,
        isNull,
      ); // Customer is not parsed in fromJson
    });

    test("toJson converts a valid object to JSON", () {
      final facilitiesOtherBanks = FacilitiesOtherBanks(
        facilitiesList: [
          Facility(
            facilityOtherbanksId: 1,
            appRefNo: "APP001",
            customerName: "Test Customer",
            customerRimNo: 12345,
            bankNameId: 1,
            comments: "Test Comments",
            fundedLimit: Decimal.fromInt(1000),
            nonFundedLimit: Decimal.fromInt(500),
            deleted: false,
            total: Decimal.fromInt(1500),
            parsedFundedLimit: Decimal.fromInt(1000),
            parsedNonFundedLimit: Decimal.fromInt(500),
            parsedTotal: Decimal.fromInt(1500),
            news: true,
            // facilityId: 1,
            // securityId: 1,
          ),
        ],
        customer: Customer(customerName: "Test Customer", customerRimNo: 12345),
      );

      final json = facilitiesOtherBanks.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json["facilitiesList"], isNotNull);
      expect((json["facilitiesList"] as List).length, 1);
      // expect(json['facilitiesList'][0]['facilityName'], 1);
      expect(json["customer"], isNull); // Customer is not serialized in toJson
    });

    test("fromJson handles null facilitiesList", () {
      final Map<String, dynamic> json = {};
      final facilitiesOtherBanks = FacilitiesOtherBanks.fromJson(json);
      expect(facilitiesOtherBanks.facilitiesList, isNull);
    });

    test("toJson handles null facilitiesList", () {
      final facilitiesOtherBanks = FacilitiesOtherBanks();
      final json = facilitiesOtherBanks.toJson();
      expect(json["facilitiesList"], isNull);
    });
  });
}
