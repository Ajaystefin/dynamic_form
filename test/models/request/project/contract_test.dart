import "package:test/test.dart";
import "package:wcas_frontend/models/request/project/contract.dart";

// If your PPC and DateTimeUtils are in your project, these imports will work.
// Otherwise, create minimal stubs in test-only files with the same package
// paths.

// Minimal expectations helper for date conversion: we only validate non-null.
Matcher _isDateOrNull(bool shouldBeDate) =>
    shouldBeDate ? isA<DateTime>() : isNull;

void main() {
  group("parseInt", () {
    test("parses int, double, num, numeric strings and null", () {
      expect(parseInt(123), 123);
      expect(parseInt(123.9), 123);
      expect(parseInt(num.parse("456")), 456);
      expect(parseInt("789"), 789);
      expect(parseInt("1,234"), 1234);
      expect(parseInt("123.0"), 123);
      expect(parseInt(""), isNull);
      expect(parseInt(null), isNull);
      expect(parseInt("abc"), isNull);
    });
  });

  group("parseDouble", () {
    test("parses double, int, num, numeric strings and null", () {
      expect(parseDouble(12.34), 12.34);
      expect(parseDouble(10), 10.0);
      expect(parseDouble(num.parse("56")), 56.0);
      expect(parseDouble("78.9"), 78.9);
      expect(parseDouble("1,234.56"), 1234.56);
      expect(parseDouble(""), isNull);
      expect(parseDouble(null), isNull);
      expect(parseDouble("abc"), isNull);
    });
  });

  group("Contract.fromProjectContractJson / toProjectContractJson", () {
    test("round-trip basic project contract json", () {
      final src = {
        "rimNo": 101,
        "contractName": "Main",
        "contractorId": 55,
        "segment": "Civil",
        "contractorType": "Prime",
        "contractCode": "C-001",
        "contractValue": "1234.50",
        "completionPercentage": 85,
        "paymaster": "PM Co",
        "cbdExposureGuarantees": "100.25",
        "cbdExposureTotal": 300.0,
      };

      final c = Contract.fromProjectContractJson(src);
      expect(c.rimNo, "101");
      // expect(c.contractName, 'Main');
      expect(c.contractorId, 55);
      expect(c.segment, "Civil");
      expect(c.contractorType, "Prime");
      expect(c.contractCode, "C-001");
      expect(c.contractValue, "1234.50");
      expect(c.completionPercentage, 85);
      expect(c.paymaster, "PM Co");
      expect(c.cbdExposureGuarantees, 100.25);
      expect(c.cbdExposureTotal, 300.0);

      final out = c.toProjectContractJson();
      expect(out["rimNo"], "101");
      expect(out["contractorId"], 55);
      expect(out["segment"], "Civil");
      expect(out["contractorType"], "Prime");
      expect(out["contractCode"], "C-001");
      expect(out["contractValue"], "1234.50");
      expect(out["completionPercentage"], 85);
      expect(out["paymaster"], "PM Co");
      expect(out["cbdExposureGuarantees"], 100.25);
      expect(out["cbdExposureTotal"], 300.0);
    });
  });

  group("Contract.fromJson / toJson", () {
    test("handles mixed sources and date conversions", () {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      final src = {
        "contractName": null,
        "projectName": "PN",
        "completion": nowMs,
        "guarantees": "G",
        "segment": "Seg",
        "total": 999,
        "type": "T",
        "contractCode": "CC",
        "borrowerRole": "BR",
        "customerName": "Cust",
        "rimNo": null,
        "rim": "RIM-ALT",
        "paymasterName": "Paymaster",
        // 'contractorValue': 77.7,
        "initialContractValue": "50.5",
        "initialContractorVarient": 1,
        "originalCompletionVarient": 2,
        "projectTenor": 12,
        "expectedStartDate": nowMs,
        "expectedCompletionDate": nowMs,
        "originalCompletionDate": nowMs,
        "contractorScope": "Scope",
        "projectCode": "PC",
        "projectUltimateOwner": "PUO",
        "projectOwnerEntity": "POE",
        "projectOwnerRim": 333,
        "projectOwnerEntityRim": 444,
      };

      final c = Contract.fromJson(src);
      expect(c.contractName, "PN"); // falls back to projectName
      expect(c.completion, _isDateOrNull(true));
      expect(c.guarantees, "G");
      expect(c.segment, "Seg");
      expect(c.total, 999);
      expect(c.type, "T");
      expect(c.contractCode, "CC");
      expect(c.borrowerRole, "BR");
      // expect(c.customerName, 'Cust');
      expect(c.rimNo, "RIM-ALT");
      expect(c.paymasterName, "Paymaster");
      // expect(c.contractValue, "77.7");
      expect(c.initialContractValue, "50.5");
      expect(c.initialContractorVarient, 1);
      expect(c.originalCompletionVarient, 2);
      expect(c.projectTenor, 12);
      expect(c.expectedStartDate, _isDateOrNull(true));
      expect(c.expectedCompletionDate, _isDateOrNull(true));
      expect(c.originalCompletionDate, _isDateOrNull(true));
      expect(c.contractorScope, "Scope");
      expect(c.projectCode, "PC");
      expect(c.projectUltimateOwner, "PUO");
      expect(c.projectOwnerEntity, "POE");
      expect(c.projectOwnerRim, 333);
      expect(c.projectOwnerEntityRim, 444);

      final out = c.toJson();
      expect(out["contractName"], "PN");
      expect(out["completion"], _isDateOrNull(true));
      expect(out["expectedCompletionDate"], isA<int?>());
      expect(out["expectedStartDate"], isA<int?>());
      expect(out["rimNo"], c.customerRimNo); // note: maps customerRimNo
    });
  });

  group("Contract.toSaveContractJson / toSaveLinkJson", () {
    test("formats dates via DateTimeUtils and includes core fields", () {
      final c = Contract(
        projectCode: "PC",
        projectName: "PN",
        projectId: "PID",
        contractName: "CN",
        rimNo: "RIM",
        borrowerRole: "BR",
        contractCode: "CC",
        contractCurrency: "AED",
        paymasterName: "PM",
        projectTenor: 10,
        contractAmount: "9999.0",
        initialContractValue: "9999.0",
        appReffNo: "APP001",
        isMainContractor: true,
        expectedCompletionDate: DateTime(2025, 12, 31),
        expectedStartDate: DateTime(2025, 01, 01),
        completionPercentage: 85,
        guarantee: 1,
        lastCompletionPercentage: 80,
        projectCollectionAccount: 123.45,
        originalCompletionDate: DateTime(2025, 12, 31),
        originalStartDate: DateTime(2025, 01, 01),
        originalEndDate: DateTime(2025, 06, 30),
      );

      final save = c.toSaveContractJson();
      expect(save["projectCode"], "PC");
      expect(save["projectName"], "PN");
      expect(save["projectId"], "PID");
      expect(save["contractName"], "CN");
      expect(save["rimNo"], "RIM");
      expect(save["contractValue"], "9999.0");
      expect(save["initialContractValue"], "9999.0");
      expect(save["isMainContractor"], true);
      expect(save["completionPercentage"], 85);
      // expect(save['guarantee'], 1);
      expect(save["lastCompletionPercentage"], 80);
      // expect(save['projectCollectionAccount'], 123.45);
      // expectedStartDate and expectedEndDate are strings via DateTimeUtils
      // formatting
      expect(save["expectedStartDate"], isA<String>());
      expect(save["expectedEndDate"], isA<String>());

      final link = c.toSaveLinkJson();
      expect(link["projectCode"], "PC");
      expect(link["projectName"], "PN");
      expect(link["projectId"], "PID");
      expect(link["contractName"], "CN");
      expect(link["rimNo"], null);
      expect(link["contractValue"], "9999.0");
      expect(link["initialContractValue"], "9999.0");
      expect(link["isMainContractor"], true);
      expect(link["expectedStartDate"], isA<String>());
      expect(link["expectedEndDate"], isA<String>());
    });
  });

  group(
      "Contract.fromContractByContractCodeJson / toContractByContractCodeJson",
      () {
    test("handles dates and optional ppcList mapping", () {
      final startMs = DateTime(2025, 01, 01).millisecondsSinceEpoch;
      final endMs = DateTime(2025, 12, 31).millisecondsSinceEpoch;

      // Provide at least one PPC item; PPC.fromJson must exist in your project
      final src = {
        "contractId": "ID1",
        "contractCode": "CC1",
        "projectId": "PID1",
        "contractName": "CN1",
        "rimNo": "RIM1",
        "borrowerRole": "BR1",
        "contractCurrency": "AED",
        "contractValue": "1000",
        "initialContractValue": "900",
        "projectTenor": 24,
        "contractValueAedAmount": "1000",
        "paymasterName": "PM1",
        "contractScope": "Scope1",
        "expectedStartDate": startMs,
        "expectedEndDate": endMs,
        "originalStartDate": startMs,
        "originalEndDate": endMs,
        "completionPercentage": 60,
        "lastCompletionPercentage": 55,
        "variationAmount": 10.5,
        "variationPercent": 1.05,
        // 'projectCollectionAccount': 222.33,
        "isMainContractor": false,
        "appRefNo": "APPX",
        "guarantee": 2,
        "ppcList": [
          {
            "ppcId": 1,
            "ppcName": "Milestone 1",
          } // shape handled by PPC.fromJson
        ],
      };

      final c = Contract.fromContractByContractCodeJson(src);
      expect(c.contractId, "ID1");
      expect(c.contractCode, "CC1");
      expect(c.projectId, "PID1");
      expect(c.contractName, "CN1");
      expect(c.rimNo, "RIM1");
      expect(c.contractCurrency, "AED");
      expect(c.contractValue, "1000");
      expect(c.initialContractValue, "900");
      expect(c.projectTenor, 24);
      expect(c.contractValueAedAmount, "1000");
      expect(c.paymasterName, "PM1");
      expect(c.contractScope, "Scope1");
      expect(c.expectedStartDate, _isDateOrNull(true));
      expect(c.expectedEndDate, _isDateOrNull(true));
      expect(c.originalStartDate, _isDateOrNull(true));
      expect(c.originalEndDate, _isDateOrNull(true));
      expect(c.completionPercentage, 60);
      expect(c.lastCompletionPercentage, 55);
      expect(c.variationAmount, 10.5);
      expect(c.variationPercent, 1.05);
      // expect(c.projectCollectionAccount, 222.33);
      expect(c.isMainContractor, false);
      expect(c.appRefNo, "APPX");
      // expect(c.guarantee, 2);
      expect(c.ppcList, isNotNull);
      expect(c.ppcList!.length, 1);

      final out = c.toContractByContractCodeJson();
      expect(out["contractId"], "ID1");
      expect(out["contractCode"], "CC1");
      expect(out["projectId"], "PID1");
      expect(out["contractName"], "CN1");
      expect(out["rimNo"], "RIM1");
      expect(out["contractCurrency"], "AED");
      expect(out["contractValue"], "1000");
      expect(out["initialContractValue"], "900");
      expect(out["expectedStartDate"], isA<DateTime?>());
      expect(out["expectedEndDate"], isA<DateTime?>());
      expect(out["originalStartDate"], isA<DateTime?>());
      expect(out["originalEndDate"], isA<DateTime?>());
      expect(out["ppcList"], isA<List?>());
    });

    test("ppcList null branch", () {
      final c = Contract(contractName: "NoPPC");
      final out = c.toContractByContractCodeJson();
      expect(out.containsKey("ppcList"), isFalse); // exercises null branch
    });
  });
}
