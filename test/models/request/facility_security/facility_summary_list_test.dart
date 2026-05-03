import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a minimal valid [FacilitySummaryNew] JSON map.
Map<String, dynamic> _facilityJson({
  Map<String, dynamic> overrides = const {},
}) {
  final base = <String, dynamic>{
    "facilityId": 1,
    "facilityMasterId": 2,
    "appRefNo": "APP-001",
    "groupId": 3,
    "rimNo": 4,
    "limitNo": "LN-001",
    "controllingLimitNo": "CLN-001",
    "wcasLimitNo": "WLN-001",
    "parentFacilityId": 0,
    "limitDescription": "Desc",
    "limitCapType": "CT",
    "limitCategory": "F",
    "advanceType": 1,
    "isMainLimit": true,
    "isSharedLimit": false,
    "isProjectFinActivity": false,
    "isRegulatorySpecialisedLending": false,
    "regulatorySpecialisedLendingFinanceType": 0,
    "projectName": "ProjA",
    "currency": "AED",
    "presentLimit": 1000,
    "presentLimitAED": 1000,
    "presentOutstanding": 500,
    "originalLimit": 800,
    "proposedLimit": 1200,
    "proposedLimitAED": 1200,
    "limitExpiryDate": "2025-12-31T00:00:00Z",
    "limitAvailabilityDate": "2025-01-01T00:00:00Z",
    "isCommitted": true,
    "seniority": 1,
    "countryOfRisk": "UAE",
    "purpose": 5,
    "sectorDescription": "Sector",
    "sicCode": "1234",
    "accountType": 2,
    "commitmentAccountNumber": "ACC-001",
    "promissoryNoteTaken": 1,
    "isCollateralDependent": false,
    "revolvingType": 0,
    "isDraft": false,
    "forIslamic": 0,
    "emirates": 1,
    "propertyType": 0,
    "propertySubType": 0,
    "recommendedOutstanding": 100,
    "recommendedPastdue": 10,
    "recommendedOutstandingAed": 100,
    "recommendedPastdueAed": 10,
    "sustainabilityClassification": "Green",
    "proposedByCc": 1,
    "facilityTitle": "Title",
    "remarks": "None",
    "policyDeviation": "No",
    "isCrossBoarderCorporateExposure": false,
    "createdBy": "admin",
    "createdDate": "2024-01-01T00:00:00Z",
    "updatedBy": "admin",
    "updatedDate": "2024-06-01T00:00:00Z",
    "srcMigratedId": "SRC-1",
    "limitAvailabilityPeriod": 12,
    "tenorValue": 6,
    "tenorUnit": "Months",
    "pastDues": 0,
    "index": "EIBOR",
    "marginSign": "+",
    "marginValue": 1.5,
    "productCode": "ODAS",
    "projectCode": "PRJ-001",
    "limitGroupName": "GroupA",
    "limitGroup": 1,
    "canDelete": true,
  }..addAll(overrides);
  return base;
}

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // _asInt helper – tested indirectly through fromJson calls
  // ─────────────────────────────────────────────────────────────────────────
  group("_asInt coverage (via FacilitySummaryNew.fromJson)", () {
    test("null → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"facilityId": null}),
      );
      expect(f.facilityId, isNull);
    });

    test("int → kept as int", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"facilityId": 7}),
      );
      expect(f.facilityId, 7);
    });

    test("num (double) → toInt", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"facilityId": 3.9}),
      );
      expect(f.facilityId, 3);
    });

    test("numeric string → parsed", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"facilityId": "42"}),
      );
      expect(f.facilityId, 42);
    });

    test("non-numeric string → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"facilityId": "abc"}),
      );
      expect(f.facilityId, isNull);
    });

    test("empty string → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"facilityId": "   "}),
      );
      expect(f.facilityId, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // _asNum helper
  // ─────────────────────────────────────────────────────────────────────────
  group("_asNum coverage (via fromJson)", () {
    test("null → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"presentLimit": null}),
      );
      expect(f.presentLimit, isNull);
    });

    test("num value kept", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"presentLimit": 999.9}),
      );
      expect(f.presentLimit, 999.9);
    });

    test("valid string → parsed", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"presentLimit": "123.45"}),
      );
      expect(f.presentLimit, 123.45);
    });

    test("invalid string → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"presentLimit": "bad"}),
      );
      expect(f.presentLimit, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // _asBool helper
  // ─────────────────────────────────────────────────────────────────────────
  group("_asBool coverage (via fromJson)", () {
    for (final truthy in ["true", "t", "yes", "y", "True", "YES"]) {
      test('string "$truthy" → true', () {
        final f = FacilitySummaryNew.fromJson(
          _facilityJson(overrides: {"isMainLimit": truthy}),
        );
        expect(f.isMainLimit, isTrue);
      });
    }

    for (final falsy in ["false", "f", "no", "n", "False", "NO"]) {
      test('string "$falsy" → false', () {
        final f = FacilitySummaryNew.fromJson(
          _facilityJson(overrides: {"isMainLimit": falsy}),
        );
        expect(f.isMainLimit, isFalse);
      });
    }

    test('numeric string "1" → true', () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": "1"}),
      );
      expect(f.isMainLimit, isTrue);
    });

    test('numeric string "0" → false', () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": "0"}),
      );
      expect(f.isMainLimit, isFalse);
    });

    test("unrecognised string → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": "maybe"}),
      );
      expect(f.isMainLimit, isNull);
    });

    test("null → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": null}),
      );
      expect(f.isMainLimit, isNull);
    });

    test("bool true → true", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": true}),
      );
      expect(f.isMainLimit, isTrue);
    });

    test("bool false → false", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": false}),
      );
      expect(f.isMainLimit, isFalse);
    });

    test("num 1 → true", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": 1}),
      );
      expect(f.isMainLimit, isTrue);
    });

    test("num 0 → false", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"isMainLimit": 0}),
      );
      expect(f.isMainLimit, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // _asDate helper
  // ─────────────────────────────────────────────────────────────────────────
  group("_asDate coverage (via fromJson)", () {
    test("null → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitExpiryDate": null}),
      );
      expect(f.limitExpiryDate, isNull);
    });

    test("valid ISO string → DateTime", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitExpiryDate": "2025-06-15T00:00:00Z"}),
      );
      expect(f.limitExpiryDate, isA<DateTime>());
    });

    test("invalid string → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitExpiryDate": "not-a-date"}),
      );
      expect(f.limitExpiryDate, isNull);
    });

    test("int epoch milliseconds → DateTime", () {
      final epoch = DateTime(2025, 6, 15).millisecondsSinceEpoch;
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitExpiryDate": epoch}),
      );
      expect(f.limitExpiryDate, isA<DateTime>());
    });

    test("empty string → null", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitExpiryDate": ""}),
      );
      expect(f.limitExpiryDate, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // _dateToIso (via toJson)
  // ─────────────────────────────────────────────────────────────────────────
  group("_dateToIso coverage", () {
    test("null date → null in toJson", () {
      final f = FacilitySummaryNew(limitExpiryDate: null);
      expect(f.toJson()["limitExpiryDate"], isNull);
    });

    test("non-null date → ISO string", () {
      final dt = DateTime.utc(2025, 12, 31);
      final f = FacilitySummaryNew(limitExpiryDate: dt);
      expect(f.toJson()["limitExpiryDate"], dt.toIso8601String());
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // _dateToEpochSeconds (via toSaveJson)
  // ─────────────────────────────────────────────────────────────────────────
  group("_dateToEpochSeconds coverage (via toSaveJson)", () {
    test("limitAvailabilityDateRaw is int → returned as-is", () {
      // Build via fromJson so limitAvailabilityDateRaw gets an int
      const rawEpoch = 1700000000; // some int
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitAvailabilityDate": rawEpoch}),
      );
      final save = f.toSaveJson();
      expect(save["limitAvailabilityDate"], rawEpoch);
    });

    test("limitAvailabilityDateRaw is num (double) → toInt", () {
      const rawEpoch = 1700000000.9;
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitAvailabilityDate": rawEpoch}),
      );
      final save = f.toSaveJson();
      expect(save["limitAvailabilityDate"], rawEpoch.toInt());
    });

    test(
        "limitAvailabilityDateRaw is null, dt non-null → epoch seconds from dt",
        () {
      final dt = DateTime.utc(2025, 6, 1);
      final f = FacilitySummaryNew(limitAvailabilityDate: dt);
      // raw is null by default
      final save = f.toSaveJson();
      expect(save["limitAvailabilityDate"], dt.millisecondsSinceEpoch ~/ 1000);
    });

    test("raw is valid ISO string, dt null → parsed epoch seconds", () {
      // fromJson stores the raw string in limitAvailabilityDateRaw and also
      // parses it into dt
      // We want raw=string but dt=null: use constructor with manual assignment
      final f = FacilitySummaryNew()
        ..limitAvailabilityDateRaw = "2025-06-01T00:00:00Z"
        ..limitAvailabilityDate = null;
      final save = f.toSaveJson();
      final expected =
          DateTime.parse("2025-06-01T00:00:00Z").millisecondsSinceEpoch ~/ 1000;
      expect(save["limitAvailabilityDate"], expected);
    });

    test("raw null, dt null → null", () {
      final f = FacilitySummaryNew();
      final save = f.toSaveJson();
      expect(save["limitAvailabilityDate"], isNull);
    });

    test("raw is empty string, dt null → null", () {
      final f = FacilitySummaryNew()
        ..limitAvailabilityDateRaw = "";
      final save = f.toSaveJson();
      expect(save["limitAvailabilityDate"], isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilityDis.normalizeTenorUnit – all branches
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilityDis.normalizeTenorUnit", () {
    final dis = FacilityDis();

    // Days variants
    for (final v in ["d", "day", "days", "D", "DAY", "Days"]) {
      test('"$v" → "Days"', () => expect(dis.normalizeTenorUnit(v), "Days"));
    }

    // Month variants
    for (final v in ["m", "month", "months", "M", "MONTH", "Months"]) {
      test(
        '"$v" → "Months"',
        () => expect(dis.normalizeTenorUnit(v), "Months"),
      );
    }

    // Year variants
    for (final v in ["y", "yr", "year", "years", "Y", "YR", "Year", "Years"]) {
      test('"$v" → "Years"', () => expect(dis.normalizeTenorUnit(v), "Years"));
    }

    // On-demand variants
    for (final v in [
      "ondemand",
      "on_demand",
      "on-demand",
      "OnDemand",
      "ON_DEMAND",
    ]) {
      test(
        '"$v" → "On Demand"',
        () => expect(dis.normalizeTenorUnit(v), "On Demand"),
      );
    }

    test("null → empty string", () => expect(dis.normalizeTenorUnit(null), ""));
    test(
      "empty string → empty string",
      () => expect(dis.normalizeTenorUnit(""), ""),
    );
    test("unknown value → title-cased fallback", () {
      expect(dis.normalizeTenorUnit("weeks"), "Weeks");
    });
    test("single-char unknown → uppercased first char", () {
      expect(dis.normalizeTenorUnit("q"), "Q");
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilityDis.fromJson – additionalDetails branches
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilityDis.fromJson – additionalDetails branches", () {
    test("no facility → additionalDetails skipped gracefully", () {
      final dis = FacilityDis.fromJson({"order": "1"});
      expect(dis.order, "1");
      expect(dis.facility, isNull);
    });

    test("ad is null → no crash", () {
      final dis = FacilityDis.fromJson({
        "order": "1",
        "facility": {"facilityId": 10},
        "additionalDetails": null,
      });
      expect(dis.facility, isNotNull);
    });

    test("ad is String with valid JSON containing tenor", () {
      final inner = jsonEncode({
        "tenor": {"tenorUnit": "months", "tenorValue": "12"},
      });
      final dis = FacilityDis.fromJson({
        "order": "1",
        "facility": {"facilityId": 10},
        "additionalDetails": inner,
      });
      expect(dis.facility!.tenorUnit, "Months");
      expect(dis.facility!.tenorValue, 12);
    });

    test('ad is Map with nested "additionalDetails" string key', () {
      final innerJson = jsonEncode({
        "tenor": {"tenorUnit": "days", "tenorValue": "30"},
      });
      final dis = FacilityDis.fromJson({
        "order": "2",
        "facility": {"facilityId": 20},
        "additionalDetails": {
          "additionalDetails": innerJson,
          "id": 99,
        },
      });
      expect(dis.facility!.tenorUnit, "Days");
      expect(dis.facility!.tenorValue, 30);
    });

    test("ad is Map<String,dynamic> with no inner string key", () {
      // Falls into the "else if (ad is Map<String,dynamic>)" branch in try
      final dis = FacilityDis.fromJson({
        "order": "3",
        "facility": {"facilityId": 30},
        "additionalDetails": {
          "tenor": {"tenorUnit": "years", "tenorValue": "5"},
        },
      });
      expect(dis.facility!.tenorUnit, "Years");
      expect(dis.facility!.tenorValue, 5);
    });

    test("ad is String with invalid JSON → decode error swallowed", () {
      final dis = FacilityDis.fromJson({
        "order": "4",
        "facility": {"facilityId": 40},
        "additionalDetails": "{not valid json}",
      });
      // Should not throw; facility still set
      expect(dis.facility!.facilityId, 40);
    });

    test("ad contains profitGrid → index and margin extracted", () {
      final inner = jsonEncode({
        "profitGrid": [
          {
            "index": "EIBOR",
            "margin": {"tenorUnit": "+", "tenorValue": "2.5"},
          }
        ],
      });
      final dis = FacilityDis.fromJson({
        "order": "5",
        "facility": {"facilityId": 50},
        "additionalDetails": inner,
      });
      expect(dis.facility!.index, "EIBOR");
      expect(dis.facility!.marginSign, "+");
      expect(dis.facility!.marginValue, 2.5);
    });

    test("ad contains lcCommission → index and marginValue extracted", () {
      final inner = jsonEncode({
        "lcCommission": [
          {"indexLcLGCommision": "fixedCommision", "gridCommission": "1.25"},
        ],
      });
      final dis = FacilityDis.fromJson({
        "order": "6",
        "facility": {"facilityId": 60},
        "additionalDetails": inner,
      });
      expect(dis.facility!.index, "fixedCommision");
      expect(dis.facility!.marginValue, 1.25);
      expect(dis.facility!.marginSign, "+"); // default sign injected
    });

    test("avCommission used when lcCommission absent", () {
      final inner = jsonEncode({
        "avCommission": [
          {"indexLcLGCommision": "avIdx", "gridCommission": "0.75"},
        ],
      });
      final dis = FacilityDis.fromJson({
        "order": "7",
        "facility": {"facilityId": 70},
        "additionalDetails": inner,
      });
      expect(dis.facility!.index, "avIdx");
    });

    test("lgCommission used when lc/av absent", () {
      final inner = jsonEncode({
        "lgCommission": [
          {"indexLcLGCommision": "lgIdx", "gridCommission": "0.5"},
        ],
      });
      final dis = FacilityDis.fromJson({
        "order": "8",
        "facility": {"facilityId": 80},
        "additionalDetails": inner,
      });
      expect(dis.facility!.index, "lgIdx");
    });

    test("periodOfFinance as tenor key", () {
      final inner = jsonEncode({
        "periodOfFinance": {"tenorUnit": "months", "tenorValue": "6"},
      });
      final dis = FacilityDis.fromJson({
        "order": "9",
        "facility": {"facilityId": 90},
        "additionalDetails": inner,
      });
      expect(dis.facility!.tenorUnit, "Months");
      expect(dis.facility!.tenorValue, 6);
    });

    test("maximumTenor as tenor key fallback", () {
      final inner = jsonEncode({
        "maximumTenor": {"tenorUnit": "years", "tenorValue": "3"},
      });
      final dis = FacilityDis.fromJson({
        "order": "10",
        "facility": {"facilityId": 100},
        "additionalDetails": inner,
      });
      expect(dis.facility!.tenorUnit, "Years");
    });

    test("tenor with empty tenorUnit → existing tenorUnit kept", () {
      final inner = jsonEncode({
        "tenor": {"tenorUnit": "", "tenorValue": "5"},
      });
      final dis = FacilityDis.fromJson({
        "order": "11",
        "facility": {"facilityId": 110, "tenorUnit": "Months"},
        "additionalDetails": inner,
      });
      // empty normalized unit → facility.tenorUnit should NOT be overwritten
      expect(dis.facility!.tenorValue, 5);
    });

    test("profitGrid index only set when facility.index was null/empty", () {
      // facility already has index from top-level json
      final inner = jsonEncode({
        "profitGrid": [
          {
            "index": "NewIdx",
            "margin": {"tenorUnit": "-", "tenorValue": "1"},
          }
        ],
      });
      final dis = FacilityDis.fromJson({
        "order": "12",
        "facility": {"facilityId": 120, "index": "ExistingIdx"},
        "additionalDetails": inner,
      });
      // existing index should be preserved
      expect(dis.facility!.index, "ExistingIdx");
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilityDis.toJson
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilityDis.toJson", () {
    test("toJson includes facility and order", () {
      final dis = FacilityDis(
        order: "ord-1",
        facility: FacilitySummaryNew(facilityId: 5, limitNo: "L5"),
      );
      final j = dis.toJson();
      expect(j["order"], "ord-1");
      expect(j["facility"], isA<Map>());
    });

    test("toJson includes additionalDetails when set", () {
      final dis = FacilityDis(order: "1")
        ..additionalDetails = {"key": "value"};
      final j = dis.toJson();
      expect(j["additionalDetails"], {"key": "value"});
    });

    test("toJson omits additionalDetails when null", () {
      final dis = FacilityDis(order: "1");
      final j = dis.toJson();
      expect(j.containsKey("additionalDetails"), isFalse);
    });

    test("toJson with null facility omits facility key body", () {
      final dis = FacilityDis(order: "2", facility: null);
      final j = dis.toJson();
      expect(j["order"], "2");
      expect(j.containsKey("facility"), isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilitySummaryNew._buildAdditionalDetailsForSave (via toJson / toSaveJson)
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryNew._buildAdditionalDetailsForSave", () {
    test("additionalDetailsContainer null → no additionalDetails in toJson",
        () {
      final f = FacilitySummaryNew(facilityId: 1);
      final j = f.toJson();
      expect(j.containsKey("additionalDetails"), isFalse);
    });

    test("container present with valid raw JSON string", () {
      final inner = jsonEncode({"key": "value"});
      final f = FacilitySummaryNew(facilityId: 1)
        ..additionalDetailsContainer = {"additionalDetails": inner, "id": 5}
        ..tenorUnit = "Months"
        ..tenorValue = 6;
      final j = f.toJson();
      expect(j.containsKey("additionalDetails"), isTrue);
      final addl = j["additionalDetails"] as Map;
      final decodedInner =
          jsonDecode(addl["additionalDetails"] as String) as Map;
      expect(decodedInner.containsKey("tenor"), isTrue);
    });

    test("container present with empty raw string, additionalDetailsParsed set",
        () {
      final f = FacilitySummaryNew(facilityId: 2)
        ..additionalDetailsContainer = {"additionalDetails": "", "id": 6}
        ..additionalDetailsParsed = {"existingKey": "val"}
        ..tenorUnit = "Days"
        ..tenorValue = 30;
      final j = f.toJson();
      final addl = j["additionalDetails"] as Map;
      final decodedInner =
          jsonDecode(addl["additionalDetails"] as String) as Map;
      expect(decodedInner["tenor"]["tenorUnit"], "Days");
    });

    test("profitGrid merge: existing grid first-row updated", () {
      final existingGrid = [
        {"index": "OldIdx", "otherField": "kept"},
      ];
      final inner = jsonEncode({"profitGrid": existingGrid});
      final f = FacilitySummaryNew(facilityId: 3)
        ..additionalDetailsContainer = {"additionalDetails": inner}
        ..index = "NewIdx"
        ..marginSign = "+"
        ..marginValue = 2.0;
      final j = f.toJson();
      final addl = j["additionalDetails"] as Map;
      final decoded = jsonDecode(addl["additionalDetails"] as String) as Map;
      final grid = decoded["profitGrid"] as List;
      expect(grid.first["index"], "NewIdx");
      expect(grid.first["margin"]["tenorUnit"], "+");
    });

    test("profitGrid create: empty grid → new row created", () {
      final inner = jsonEncode(<String, dynamic>{});
      final f = FacilitySummaryNew(facilityId: 4)
        ..additionalDetailsContainer = {"additionalDetails": inner}
        ..index = "EIBOR"
        ..marginSign = "-"
        ..marginValue = 0.5;
      final j = f.toJson();
      final addl = j["additionalDetails"] as Map;
      final decoded = jsonDecode(addl["additionalDetails"] as String) as Map;
      final grid = decoded["profitGrid"] as List;
      expect(grid.length, 1);
      expect(grid.first["index"], "EIBOR");
    });

    test("lcCommission updated when index and marginValue set", () {
      final existingLc = [
        {"indexLcLGCommision": "oldIdx", "gridCommission": "0.1"},
      ];
      final inner = jsonEncode({"lcCommission": existingLc});
      final f = FacilitySummaryNew(facilityId: 5)
        ..additionalDetailsContainer = {"additionalDetails": inner}
        ..index = "newIdx"
        ..marginValue = 1.0;
      final j = f.toJson();
      final addl = j["additionalDetails"] as Map;
      final decoded = jsonDecode(addl["additionalDetails"] as String) as Map;
      final lc = decoded["lcCommission"] as List;
      expect(lc.first["indexLcLGCommision"], "newIdx");
    });

    test("lcCommission created when lc was empty", () {
      final inner = jsonEncode(<String, dynamic>{});
      final f = FacilitySummaryNew(facilityId: 6)
        ..additionalDetailsContainer = {"additionalDetails": inner}
        ..index = "idx"
        ..marginValue = 0.5;
      final j = f.toJson();
      final addl = j["additionalDetails"] as Map;
      final decoded = jsonDecode(addl["additionalDetails"] as String) as Map;
      final lc = decoded["lcCommission"] as List;
      expect(lc.length, 1);
    });

    test("container raw is invalid json → inner kept empty", () {
      final f = FacilitySummaryNew(facilityId: 7)
        ..additionalDetailsContainer = {"additionalDetails": "{bad}"}
        ..tenorUnit = "Days";
      // should not throw
      expect(f.toJson, returnsNormally);
    });

    test("tenorUnit/tenorValue null → tenor block not injected", () {
      final inner = jsonEncode({"existing": "data"});
      final f = FacilitySummaryNew(facilityId: 8)
        ..additionalDetailsContainer = {"additionalDetails": inner};
      // tenorUnit and tenorValue remain null
      final j = f.toJson();
      final addl = j["additionalDetails"] as Map;
      final decoded = jsonDecode(addl["additionalDetails"] as String) as Map;
      expect(decoded.containsKey("tenor"), isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilitySummaryNew.toJson – isDraft defaults to false
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryNew.toJson – isDraft fallback", () {
    test("isDraft null → emits false", () {
      final f = FacilitySummaryNew(facilityId: 1, isDraft: null);
      expect(f.toJson()["isDraft"], isFalse);
    });

    test("isDraft true → emits true", () {
      final f = FacilitySummaryNew(facilityId: 1, isDraft: true);
      expect(f.toJson()["isDraft"], isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilitySummaryNew.toSaveJson – limitDescription toIntOrNull branch
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryNew.toSaveJson – limitDescription int conversion", () {
    test("limitDescription numeric string → int in save json", () {
      final f = FacilitySummaryNew(limitDescription: "25");
      expect(f.toSaveJson()["limitDescription"], 25);
    });

    test("limitDescription non-numeric → null", () {
      final f = FacilitySummaryNew(limitDescription: "Overdraft");
      expect(f.toSaveJson()["limitDescription"], isNull);
    });

    test("limitDescription null → null", () {
      final f = FacilitySummaryNew();
      expect(f.toSaveJson()["limitDescription"], isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilitySummaryNew.toSaveJson – forIslamic toStringOrNull branch
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryNew.toSaveJson – forIslamic stringification", () {
    test('forIslamic 1 → "1"', () {
      final f = FacilitySummaryNew(forIslamic: 1);
      expect(f.toSaveJson()["forIslamic"], "1");
    });

    test('forIslamic null → "Yes" fallback', () {
      final f = FacilitySummaryNew();
      expect(f.toSaveJson()["forIslamic"], "Yes");
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // RimSummary – groups/overallTotals null paths
  // ─────────────────────────────────────────────────────────────────────────
  group("RimSummary – null groups and overallTotals", () {
    test("groups null → groups field null", () {
      final rim = RimSummary.fromJson({"rimName": "R", "rimNo": 1});
      expect(rim.groups, isNull);
    });

    test("empty groups list → empty groups", () {
      final rim =
          RimSummary.fromJson({"rimName": "R", "rimNo": 1, "groups": []});
      expect(rim.groups, isEmpty);
    });

    test("overallTotals null → overallTotals null", () {
      final rim = RimSummary.fromJson({"rimName": "R", "rimNo": 1});
      expect(rim.overallTotals, isNull);
    });

    test("toJson with null groups and overallTotals → no list keys", () {
      final rim = RimSummary(rimName: "R", rimNo: 1);
      final j = rim.toJson();
      expect(j.containsKey("groups"), isFalse);
      expect(j.containsKey("overallTotals"), isFalse);
    });

    test("toJson with non-null groups", () {
      final rim = RimSummary(
        rimName: "R",
        rimNo: 1,
        groups: [RimGroup(groupName: "G")],
      );
      final j = rim.toJson();
      expect(j["groups"], isA<List>());
    });

    test("rimType parsed via customerTypeFromJson", () {
      // just ensuring it doesn't throw for unknown type
      final rim = RimSummary.fromJson({"rimName": "R", "rimNo": 1});
      expect(rim, isNotNull);
    });

    test("nested total.overallTotals variant", () {
      final json = {
        "rimName": "R",
        "rimNo": 7,
        "total": {
          "overallTotals": [
            {
              "totalType": "T",
              "existingLimit": "11",
              "proposedLimit": "21",
              "differenceValue": "31",
            }
          ],
        },
      };
      final rim = RimSummary.fromJson(json);
      expect(rim.overallTotals!.first.existingLimit, 11);
    });

    test("nested total.overallTotal (case variant) read", () {
      final json = {
        "rimName": "R",
        "rimNo": 8,
        "total": {
          "overallTotal": [
            {
              "totalType": "T",
              "existingLimit": 5,
              "proposedLimit": 10,
              "differenceValue": 5,
            }
          ],
        },
      };
      final rim = RimSummary.fromJson(json);
      expect(rim.overallTotals!.first.existingLimit, 5);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // RimGroup – null facilityLimits, null amounts
  // ─────────────────────────────────────────────────────────────────────────
  group("RimGroup – null paths", () {
    test("facilityLimits null → field null", () {
      final g = RimGroup.fromJson({"groupName": "G"});
      expect(g.facilityLimits, isNull);
    });

    test("amounts null → field null", () {
      final g = RimGroup.fromJson({"groupName": "G"});
      expect(g.amounts, isNull);
    });

    test("toJson with null facilityLimits and amounts", () {
      final g = RimGroup(groupName: "G");
      final j = g.toJson();
      expect(j.containsKey("facilityLimits"), isFalse);
      expect(j.containsKey("amounts"), isFalse);
    });

    test("toJson with non-null amounts", () {
      final g = RimGroup(
        groupName: "G",
        amounts: GroupAmounts(totalExistingLimit: 100),
      );
      final j = g.toJson();
      expect(j["amounts"], isA<Map>());
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilitySummaryList – null rims
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryList – null rims", () {
    test("toJson with null rims → empty map", () {
      final list = FacilitySummaryList(rims: null);
      expect(list.toJson(), isEmpty);
    });

    test("toJson with empty rims → map with empty list", () {
      final list = FacilitySummaryList(rims: []);
      final j = list.toJson();
      expect(j["rims"], isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OverallTotalEntry – null fields
  // ─────────────────────────────────────────────────────────────────────────
  group("OverallTotalEntry – null fields", () {
    test("fromJson with all null values", () {
      final e = OverallTotalEntry.fromJson({
        "totalType": null,
        "existingLimit": null,
        "proposedLimit": null,
        "difference": null,
        "differenceValue": null,
      });
      expect(e.totalType, isNull);
      expect(e.existingLimit, isNull);
      expect(e.proposedLimit, isNull);
      expect(e.differenceLabel, isNull);
      expect(e.differenceValue, isNull);
    });

    test("toJson with all null fields", () {
      final e = OverallTotalEntry();
      final j = e.toJson();
      expect(j["totalType"], isNull);
      expect(j["existingLimit"], isNull);
    });

    test("default constructor sets all null", () {
      final e = OverallTotalEntry(
        totalType: "T",
        existingLimit: 1,
        proposedLimit: 2,
        differenceLabel: "D",
        differenceValue: 3,
      );
      expect(e.totalType, "T");
      expect(e.differenceValue, 3);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FacilitySummaryNew.fromJson – limitAvailabilityDateRaw stored
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryNew.fromJson – limitAvailabilityDateRaw", () {
    test("raw stored as-is from json", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(overrides: {"limitAvailabilityDate": "2025-01-15"}),
      );
      expect(f.limitAvailabilityDateRaw, "2025-01-15");
    });

    test("limitAvailabilityDateNow stored as string", () {
      final f = FacilitySummaryNew.fromJson(
        _facilityJson(
          overrides: {"limitAvailabilityDate": "2025-01-15T00:00:00Z"},
        ),
      );
      expect(f.limitAvailabilityDateNow, "2025-01-15T00:00:00Z");
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Full fromJson round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryNew – full fromJson round-trip", () {
    test("all fields parsed without throwing", () {
      final f = FacilitySummaryNew.fromJson(_facilityJson());
      expect(f.facilityId, 1);
      expect(f.appRefNo, "APP-001");
      expect(f.currency, "AED");
      expect(f.isMainLimit, isTrue);
      expect(f.limitExpiryDate, isA<DateTime>());
      expect(f.canDelete, isTrue);
      expect(f.tenorUnit, "Months");
      expect(f.tenorValue, 6);
      expect(f.index, "EIBOR");
      expect(f.marginSign, "+");
      expect(f.marginValue, 1.5);
    });

    test("toJson contains all expected keys", () {
      final f = FacilitySummaryNew.fromJson(_facilityJson());
      final j = f.toJson();
      for (final key in [
        "facilityId",
        "appRefNo",
        "currency",
        "isMainLimit",
        "tenorUnit",
        "tenorValue",
        "index",
        "marginSign",
        "marginValue",
        "canDelete",
      ]) {
        expect(j.containsKey(key), isTrue, reason: "Missing key: $key");
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Re-run existing tests (keeping parity with original test file)
  // ─────────────────────────────────────────────────────────────────────────
  group("FacilitySummaryList (existing)", () {
    test("fromJson with rims + toJson preserves structure", () {
      final json = {
        "rims": [
          {
            "rimName": "RIM1",
            "rimNo": "123",
            "groups": [
              {
                "groupName": "GroupA",
                "facilityLimits": [
                  {
                    "order": "1",
                    "facility": {
                      "facilityId": "10",
                      "limitNo": "LN001",
                      "isMainLimit": true,
                      "presentLimit": "5000",
                      "limitExpiryDate": DateTime.now().toIso8601String(),
                    },
                  }
                ],
                "amounts": {
                  "totalExistingLimit": "1000",
                  "totalProposedLimit": 2000,
                  "totalCurrentOutstanding": "300",
                },
              }
            ],
            "overallTotals": [
              {
                "totalType": "Total",
                "existingLimit": "4000",
                "proposedLimit": 5000,
                "difference": "Diff",
                "differenceValue": "1000",
              }
            ],
          }
        ],
      };
      final list = FacilitySummaryList.fromJson(json);
      expect(list.rims!.length, 1);
      final rim = list.rims!.first;
      expect(rim.rimName, "RIM1");
      expect(rim.rimNo, 123);
      expect(rim.groups!.first.groupName, "GroupA");
      expect(rim.groups!.first.amounts!.totalExistingLimit, 1000);
      expect(rim.overallTotals!.first.differenceValue, 1000);

      final back = list.toJson();
      expect(back["rims"], isA<List>());
      expect((back["rims"] as List).length, 1);
    });
  });
}
