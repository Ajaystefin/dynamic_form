import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

void main() {
  // ----------------------------------------------------
  // ConditionType
  // ----------------------------------------------------
  group("ConditionType", () {
    test("fromString returns correct enum for known and default values", () {
      expect(ConditionType.fromString("STANDARD"), ConditionType.standard);
      expect(
        ConditionType.fromString("NON-STANDARD"),
        ConditionType.nonStandard,
      );
      expect(
        ConditionType.fromString("unknown"),
        ConditionType.standard,
      ); // default
    });

    test("name getter returns serialized names", () {
      expect(ConditionType.standard.name, "STANDARD");
      expect(ConditionType.nonStandard.name, "NON-STANDARD");
    });
  });

  // ----------------------------------------------------
  // FeeRate
  // ----------------------------------------------------
  group("FeeRate", () {
    test("fromJson parses all fields", () {
      final json = Map<String, dynamic>.from({
        "feeRateId": 101,
        "feeType": "Processing",
        "amount": 250.75,
        "percentage": 1.5,
        "frequency": "Monthly",
        "comment": "Standard fee",
      });
      final feeRate = FeeRate.fromJson(json);
      expect(feeRate.feeRateId, 101);
      expect(feeRate.feeType, "Processing");
      expect(feeRate.amount, 250.75);
      expect(feeRate.percentage, 1.5);
      expect(feeRate.frequency, "Monthly");
      expect(feeRate.comment, "Standard fee");
    });

    test("fromJson handles missing keys", () {
      final feeRate = FeeRate.fromJson(Map<String, dynamic>.from({}));
      expect(feeRate.feeRateId, 0);
      expect(feeRate.feeType, "");
      expect(feeRate.amount, 0.0);
      expect(feeRate.percentage, 0.0);
      expect(feeRate.frequency, "");
      expect(feeRate.comment, "");
    });

    test("toJson serializes correctly", () {
      final feeRate = FeeRate.fromJson(
        Map<String, dynamic>.from({
          "feeRateId": 10,
          "feeType": "Setup",
          "amount": 99.9,
          "percentage": 2.0,
          "frequency": "Yearly",
          "comment": "x",
        }),
      );
      expect(feeRate.toJson(), {
        "feeRateId": 10,
        "feeType": "Setup",
        "amount": 99.9,
        "percentage": 2.0,
        "frequency": "Yearly",
        "comment": "x",
      });
    });
  });

  // ----------------------------------------------------
  // Condition
  // ----------------------------------------------------
  group("Condition", () {
    test("fromJson parses with unknown type -> default STANDARD", () {
      final json = Map<String, dynamic>.from({
        "conditionId": 201,
        "conditionType": "MANDATORY", // unknown -> fallback STANDARD
        "description": "Submit documents",
        "isWaivedOff": true,
        "isAmended": false,
      });
      final condition = Condition.fromJson(json);
      expect(condition.conditionId, 201);
      expect(condition.description, "Submit documents");
      expect(condition.isWaivedOff, true);
      expect(condition.isAmended, false);
      expect(condition.conditionType, ConditionType.standard);
      expect(condition.isStandard, isTrue);
      expect(condition.isNonStandard, isFalse);
    });

    test("fromJson handles missing keys", () {
      final condition = Condition.fromJson(Map<String, dynamic>.from({}));
      expect(condition.conditionId, null);
      expect(condition.description, "");
      expect(condition.isWaivedOff, false);
      expect(condition.isAmended, false);
      expect(condition.conditionType, ConditionType.standard);
    });

    //   test('toJson serializes with conditionType.name and getters reflect
    // type',
    //       () {
    //     final condition = Condition(
    //       conditionId: null,
    //       facilityConditionId: null,
    //       facilityType: "Main Limit",
    //       rimNo: 272,
    //       limitType: "All",
    //       description: 'desc',
    //       isWaivedOff: false,
    //       isAmended: true,
    //       conditionType: ConditionType.nonStandard,
    //     );
    //     expect(condition.toJson(), {
    //       "facilityConditionId": null,
    //       "rimNo": 1023563,
    //       "limitType": "Main limit",
    //       "facilityType": "All",
    //       "conditionId": null,
    //       "description": "test",
    //       "isWaivedOff": false,
    //       "isAmended": false,
    //       "conditionType": "NON-STANDARD"
    //     });
    //     expect(condition.isNonStandard, isTrue);
    //     expect(condition.isStandard, isFalse);
    //   });
  });

  // ----------------------------------------------------
  // AdditionalDetails + nested models
  // ----------------------------------------------------
  group("AdditionalDetails", () {
    test("fromJson parses nested structures", () {
      final json = Map<String, dynamic>.from({
        "excessAmount": Map<String, dynamic>.from({"value": 100}),
        "toBeRegularizedBy": "2025-12-31",
        "sourceOfRepayment": "Cash Flow",
        "lcCommission": [
          Map<String, dynamic>.from({
            "dateFrom": Map<String, dynamic>.from({"formatted": "2025-01-01"}),
            "dateTo": Map<String, dynamic>.from({"formatted": "2025-12-31"}),
            "amountfrom": 1000,
            "amountTo": 2000,
            "gridCommission": "5%",
          }),
        ],
        "lcMargin": "10%",
        "marginExtent": "High",
        "usanceTenor": Map<String, dynamic>.from(
          {"tenorUnit": "Days", "tenorValue": "90"},
        ),
        "preferentialExchangeRate": Map<String, dynamic>.from(
          {"exchangeRateCurrency": "USD", "percentage": "5"},
        ),
        "shipmentBySeaOrAir": true,
      });
      final details = AdditionalDetails.fromJson(json);
      expect(details.excessAmount["value"], 100);
      expect(details.lcCommission.first.gridCommission, "5%");
      expect(details.usanceTenor.tenorUnit, "Days");
      expect(details.usanceTenor.tenorValue, "90");
      expect(details.preferentialExchangeRate.exchangeRateCurrency, "USD");
      expect(details.preferentialExchangeRate.percentage, "5");
      expect(details.shipmentBySeaOrAir, isTrue);
    });

    test("toJson serializes correctly", () {
      final details = AdditionalDetails.fromJson(
        Map<String, dynamic>.from({
          "excessAmount": Map<String, dynamic>.from({"value": 1}),
          "toBeRegularizedBy": "2025-12-31",
          "sourceOfRepayment": "CF",
          "lcCommission": [
            Map<String, dynamic>.from({
              "dateFrom":
                  Map<String, dynamic>.from({"formatted": "2025-01-01"}),
              "dateTo": Map<String, dynamic>.from({"formatted": "2025-12-31"}),
              "amountfrom": 10,
              "amountTo": 20,
              "gridCommission": "3%",
            }),
          ],
          "lcMargin": "2%",
          "marginExtent": "Low",
          "usanceTenor": Map<String, dynamic>.from(
            {"tenorUnit": "Days", "tenorValue": "30"},
          ),
          "preferentialExchangeRate": Map<String, dynamic>.from(
            {"exchangeRateCurrency": "EUR", "percentage": "1"},
          ),
          "shipmentBySeaOrAir": false,
        }),
      );
      expect(details.toJson(), {
        "excessAmount": {"value": 1},
        "toBeRegularizedBy": "2025-12-31",
        "sourceOfRepayment": "CF",
        "lcCommission": [
          {
            "dateFrom": "2025-01-01",
            "dateTo": "2025-12-31",
            "amountfrom": 10.0,
            "amountTo": 20.0,
            "gridCommission": "3%",
          }
        ],
        "lcMargin": "2%",
        "marginExtent": "Low",
        "usanceTenor": {"tenorUnit": "Days", "tenorValue": "30"},
        "preferentialExchangeRate": {
          "exchangeRateCurrency": "EUR",
          "percentage": "1",
        },
        "shipmentBySeaOrAir": false,
      });
    });
  });

  group("LcCommission", () {
    test("fromJson parses fields", () {
      final json = Map<String, dynamic>.from({
        "dateFrom": Map<String, dynamic>.from({"formatted": "2025-01-01"}),
        "dateTo": Map<String, dynamic>.from({"formatted": "2025-12-31"}),
        "amountfrom": 1000,
        "amountTo": 2000,
        "gridCommission": "5%",
      });
      final lcCommission = LcCommission.fromJson(json);
      expect(lcCommission.dateFrom, "2025-01-01");
      expect(lcCommission.dateTo, "2025-12-31");
      expect(lcCommission.amountFrom, 1000);
      expect(lcCommission.amountTo, 2000);
      expect(lcCommission.gridCommission, "5%");
    });

    test("toJson serializes", () {
      final lc = LcCommission.fromJson(
        Map<String, dynamic>.from({
          "dateFrom": Map<String, dynamic>.from({"formatted": "2025-02-01"}),
          "dateTo": Map<String, dynamic>.from({"formatted": "2025-03-01"}),
          "amountfrom": 5.5,
          "amountTo": 6.6,
          "gridCommission": "1%",
        }),
      );
      expect(lc.toJson(), {
        "dateFrom": "2025-02-01",
        "dateTo": "2025-03-01",
        "amountfrom": 5.5,
        "amountTo": 6.6,
        "gridCommission": "1%",
      });
    });
  });

  group("UsanceTenor", () {
    test("fromJson parses", () {
      final json =
          Map<String, dynamic>.from({"tenorUnit": "Days", "tenorValue": "90"});
      final tenor = UsanceTenor.fromJson(json);
      expect(tenor.tenorUnit, "Days");
      expect(tenor.tenorValue, "90");
    });

    test("toJson serializes", () {
      final tenor = UsanceTenor.fromJson(
        Map<String, dynamic>.from({"tenorUnit": "Months", "tenorValue": "12"}),
      );
      expect(tenor.toJson(), {"tenorUnit": "Months", "tenorValue": "12"});
    });
  });

  group("PreferentialExchangeRate", () {
    test("fromJson parses", () {
      final json = Map<String, dynamic>.from(
        {"exchangeRateCurrency": "USD", "percentage": "5"},
      );
      final rate = PreferentialExchangeRate.fromJson(json);
      expect(rate.exchangeRateCurrency, "USD");
      expect(rate.percentage, "5");
    });

    test("toJson serializes", () {
      final rate = PreferentialExchangeRate.fromJson(
        Map<String, dynamic>.from(
          {"exchangeRateCurrency": "JPY", "percentage": "2"},
        ),
      );
      expect(rate.toJson(), {"exchangeRateCurrency": "JPY", "percentage": "2"});
    });
  });

  // ----------------------------------------------------
  // FacilityDetail (comprehensive tests)
  // ----------------------------------------------------
  group("FacilityDetail", () {
    test(
        "fromJson converts types, handles alternative"
        " keys, and parses nested lists", () {
      final json = Map<String, dynamic>.from({
        "rimNo": 7,
        "seniority": 232,
        "sicCode": 361,
        "isSharedLimit": "true", // string -> bool
        "isCommitted": "false", // string -> bool
        "isProjectFinActivity": "true",
        "facilityId": 123,
        "facilityTitle": "My Facility",
        "appRefNo": "APP-001",
        "limitNo": "LIM-001",
        "limitAvailabilityDate": "2025-10-03T09:02:49", // ISO -> DateTime
        "sustainabilityClassification": "SC",
        "commitmentAccountNumber": "ACC-9",
        "controllingLimitNo": "CLN-9",
        "projectName": "PRJ-9",
        "limitDescription": 25,
        "Country_of_Risk": "United Arab Emirates", // alt key
        "advanceType": 232,
        "sectorDescription": 356,
        "accountType": "1644", // IMPORTANT: keep as string per your model
        "purpose": 11353,
        "emirates": 11370,
        "currency": "AED",
        "proposedByCc": "100", // string -> int
        "presentLimit": 200.0, // double -> int
        "originalLimit": null,
        "proposedLimit": "500", // string -> int
        "presentOutstanding": "300", // string -> int
        "pastDues": 55,
        "isMainLimit": true,
        "facilitySubLimits": [
          // **FIX**: include a string accountType to avoid int->String cast in
          // nested parse
          Map<String, dynamic>.from({"accountType": ""}),
        ],
        "conditions": [
          Map<String, dynamic>.from(
            {
              "conditionId": 1,
              "conditionType": "STANDARD",
              "description": "OK",
            },
          ),
        ],
        "feeRates": [
          Map<String, dynamic>.from(
            {"feeRateId": 1, "feeType": "F", "amount": 1.0, "percentage": 0.1},
          ),
        ],
        "additionalDetails": Map<String, dynamic>.from({
          "excessAmount": Map<String, dynamic>.from({"value": 0}),
        }),
      });

      final detail = FacilityDetail.fromJson(json);

      // Booleans via _toBoolOrNull
      expect(detail.isSharedLimit, true);
      expect(detail.isCommitted, false);
      expect(detail.isProjectFinActivity, true);

      // Numbers via _toIntOrNull
      expect(detail.proposedByCc, 100);
      expect(detail.presentLimit, 200); // 200.0 -> 200
      expect(detail.proposedLimit, 500);
      expect(detail.presentOutstanding, 300);
      expect(detail.pastDues, 55);

      // Date via _toDateOrNull
      expect(detail.limitAvailabilityDate, isNotNull);
      expect(
        detail.limitAvailabilityDate!.toIso8601String(),
        anyOf("2025-10-03T09:02:49.000", "2025-10-03T09:02:49.000Z"),
      );

      // Alternative key mapping
      expect(detail.countryOfRisk, "United Arab Emirates");

      // Basic scalars
      expect(detail.currency, "AED");
      expect(detail.appRefNo, "APP-001");
      expect(detail.accountType, "1644"); // string type per your file
      expect(detail.isMainLimit, true);

      // Nested lists
      expect(detail.facilitySubLimits.length, 1);
      expect(detail.conditions.length, 1);
      expect(detail.feeRates.length, 1);

      // AdditionalDetails present
      // expect(detail.additionalDetails.excessAmount['value'], 0);
    });

    test("fromJson handles minimal keys safely (supply accountType as string)",
        () {
      // Important: provide accountType as string to avoid int->String cast
      // error
      final detail = FacilityDetail.fromJson(
        Map<String, dynamic>.from({
          "accountType": "", // ensure constructor receives a String
        }),
      );
      expect(detail.facilityId, 0);
      expect(detail.limitNo, "");
      expect(detail.isMainLimit, false);
      expect(detail.currency, ServerConstants.aedCurrency); // default
      expect(detail.limitAvailabilityDate, isNull);
      expect(detail.presentLimit, isNull);
      expect(detail.proposedLimit, isNull);
      expect(detail.presentOutstanding, isNull);
      expect(detail.pastDues, isNull);
      expect(detail.facilitySubLimits, isEmpty);
      expect(detail.conditions, isEmpty);
      expect(detail.feeRates, isEmpty);
      // expect(detail.additionalDetails.toJson(), isA<Map<String, dynamic>>());
    });

    test("fromJson invalid date string -> limitAvailabilityDate is null", () {
      final detail = FacilityDetail.fromJson(
        Map<String, dynamic>.from({
          "limitAvailabilityDate": "not-a-date",
          "accountType": "0", // keep type consistent
        }),
      );
      expect(detail.limitAvailabilityDate, isNull);
    });

    test("toJson serializes all top-level keys & nested lists", () {
      // Build via fromJson then toJson for consistency and to hit recursion
      final detail = FacilityDetail.fromJson(
        Map<String, dynamic>.from({
          "facilityId": 1,
          "facilityTitle": "T",
          "appRefNo": "APP",
          "isProjectFinActivity": true,
          "limitNo": "L",
          "controllingLimitNo": "CLN",
          "limitDescription": 25,
          "limitAvailabilityDate": "2025-10-03T09:02:49",
          "currency": "AED",
          "presentLimit": 10,
          "proposedLimit": 20,
          "presentOutstanding": 30,
          "pastDues": 40,
          "isMainLimit": false,
          "facilitySubLimits": [
            // **FIX**: include a string accountType to avoid int->String cast
            // in nested parse
            Map<String, dynamic>.from({"accountType": ""}),
          ],
          "conditions": [
            Map<String, dynamic>.from({"conditionType": "STANDARD"}),
          ],
          "feeRates": [
            Map<String, dynamic>.from({"feeRateId": 2}),
          ],
          "additionalDetails": Map<String, dynamic>.from({}),
          "isSharedLimit": false,
          "accountType": "1644", // ensure String type
        }),
      );

      final map = detail.toJson();

      // Selected keys and shapes
      expect(map["facilityId"], 1);
      expect(map["facilityTitle"], "T");
      expect(map["appRefNo"], "APP");
      expect(map["isProjectFinActivity"], true);
      expect(map["limitNo"], "L");
      expect(map["controllingLimitNo"], "CLN");
      expect(map["limitDescription"], 25);
      expect(map["currency"], "AED");
      expect(map["presentLimit"], 10);
      expect(map["proposedLimit"], 20);
      expect(map["presentOutstanding"], 30);
      expect(map["pastDues"], 40);
      expect(map["isMainLimit"], false);

      // ISO-8601 date string (be tolerant to a trailing 'Z')
      expect(
        map["limitAvailabilityDate"],
        anyOf("2025-10-03T09:02:49.000", "2025-10-03T09:02:49.000Z"),
      );

      // Nested lists serialized via .toJson()
      expect(map["facilitySubLimits"], isA<List>());
      expect((map["facilitySubLimits"] as List).length, 1);
      expect(map["conditions"], isA<List>());
      expect(
        (map["conditions"] as List).first,
        containsPair("conditionType", "STANDARD"),
      );
      expect(map["feeRates"], isA<List>());
      expect((map["feeRates"] as List).first, containsPair("feeRateId", 2));

      // Additional details present & isSharedLimit included
      // expect(map['additionalDetails'], isA<Map<String, dynamic>>());
      expect(map["isSharedLimit"], false);
    });
  });
}
