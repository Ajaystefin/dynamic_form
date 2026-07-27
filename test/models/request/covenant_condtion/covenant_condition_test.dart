import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

void main() {
  group("CovenantCondition.fromJson", () {
    // test('parses full payload including alternate keys and lists', () {
    //   // Facility & Customer minimal JSONs (align with your project models)
    //   final borrower1 = {
    //     'customerRimNo': 111,
    //     'customerName': 'Alice',
    //   };
    //   final borrower2 = {
    //     'customerRimNo': 222,
    //     'customerName': 'Bob',
    //   };

    //   final facility1 = {
    //     'facilityId': 1,
    //     'limitNumber': 'LIM-001',
    //     'facilityTitle': 'FT-1',
    //     'appRefNo': 'APP-X',
    //   };
    //   final facility2 = {
    //     'facilityId': 2,
    //     'limitNumber': 'LIM-002',
    //     'facilityTitle': 'FT-2',
    //     'appRefNo': 'APP-Y',
    //   };

    //   final json = {
    //     'covenantConditionId': 99,
    //     'covenantConditionNo': 'CC-00099',
    //     'covenantType': 10,
    //     'conditionType': 2,
    //     'description': 'Provide audited statements',
    //     'category': 7,
    //     'frequency': 12,
    //     'monitorDate': 20250101,
    //     'nextMonitorDate': '2025-12-31',
    //     'isGeneric': true,
    //     'isNew': true,
    //     'isCovenant': true,
    //     'isDeleted': false,
    //     'deleted': false,
    //     'isStandard': true,
    //     'isInternalFinancial': true,
    //     'status': 1,
    //     'action': 3,
    //     // prefer covConMasterId; if absent, use covenantConditionMasterId
    //     'covenantConditionMasterId': 555,
    //     'rimNo': 1010,
    //     'groupId': 8080,
    //     'limitCode': 3030,
    //     'threshold': 123,
    //     'timeForSubmition': 15,
    //     'refNo': 'REF-9',
    //     'appRefNum': 'APP-9',
    //     'customerName': 'Mega Co',
    //     'entityName': 'Holdings LLC',
    //     'creditLensId': 'CL-8899',
    //     'periodTerm': 6,
    //     'basisOfPreparation': 4,
    //     'auditStatus': 2,
    //     'covenantSubType': 20,
    //     'thresholdType': 9,
    //     'financialYearEndDate': '2025-03-31',
    //     'mode': 'SAVE',
    //     'facilityIdList': ['LIM-001', 'LIM-002'],
    //     'isIncludedInTermaSheet': true,
    //     'targetDate': '2025-11-11',
    //     'borrowerIdList': [borrower1, borrower2],
    //     'facilityDetailList': [facility1, facility2],
    //   };

    //   final model = CovenantCondition.fromJson(json);
    //   // Core scalars
    //   expect(model.covenantConditionId, 99);
    //   expect(model.covenantConditionNo, 'CC-00099');
    //   expect(model.covenantType, 10);
    //   expect(model.conditionType, 2);
    //   expect(model.description, 'Provide audited statements');
    //   expect(model.category, 7);
    //   expect(model.frequency, 12);
    //   expect(model.monitorDate, 20250101);
    //   expect(model.nextMonitorDate, '2025-12-31');
    //   expect(model.isGeneric, isTrue);
    //   expect(model.isNew, isTrue);
    //   expect(model.isCovenant, isTrue);
    //   expect(model.isDeleted, isFalse);
    //   expect(model.deleted, isFalse);
    //   expect(model.isStandard, isTrue);
    //   expect(model.isInternalFinancial, isTrue);
    //   expect(model.status, 1);
    //   expect(model.action, 3);
    //   expect(model.covConMasterId, 555); // pulled from covenantConditionMasterId
    //   expect(model.rimNo, 1010);
    //   expect(model.groupId, 8080);
    //   expect(model.limitCode, 3030);
    //   expect(model.threshold, 123);
    //   expect(model.timeForSubmition, 15);
    //   expect(model.refNo, 'REF-9');
    //   expect(model.appRefNum, 'APP-9');
    //   expect(model.customerName, 'Mega Co');
    //   expect(model.entityName, 'Holdings LLC');
    //   expect(model.creditLensId, 'CL-8899');
    //   expect(model.periodTerm, 6);
    //   expect(model.basisOfPreparation, 4);
    //   expect(model.auditStatus, 2);
    //   expect(model.covenantSubType, 20);
    //   expect(model.thresholdType, 9);
    //   expect(model.financialYearEndDate, '2025-03-31');
    //   expect(model.mode, 'SAVE');
    //   expect(model.includeInTerms, isTrue);
    //   expect(model.targetDate, '2025-11-11');

    //   // Lists parsed
    //   expect(model.facilityIdList, ['LIM-001', 'LIM-002']);
    //   expect(model.borrowers?.length, 2);
    //   expect(model.borrowers?.first.customerRimNo, 111);
    //   expect(model.borrowers?.last.customerName, 'Bob');
    //   expect(model.facilityDetailList?.length, 2);
    //   expect(model.facilityDetailList?.first.limitNumber, 'LIM-001');
    //   expect(model.facilityDetailList?.last.limitNumber, 'LIM-002');
    // });

    test("handles null borrowerIdList and uses covConMasterId when present",
        () {
      final json = {
        "covenantConditionId": 1,
        "covenantConditionNo": "CC-1",
        "covConMasterId": 777, // direct key preferred
        "borrowerIdList": null, // leads to null borrowers
        "facilityDetailList": <Map<String, dynamic>>[],
      };
      final model = CovenantCondition.fromJson(json);
      expect(model.covConMasterId, 777);
      expect(model.borrowers, isNull);
      expect(model.facilityDetailList, isEmpty);
    });
  });

  group("CovenantCondition.toJson", () {
    test("serializes all fields and nested lists to expected shape", () {
      final borrowers = [
        Customer(customerRimNo: 1, customerName: "A"),
        Customer(customerRimNo: 2, customerName: "B"),
      ];
      final facilities = [
        Facility()..limitNumber = "LIM-01",
        Facility()..limitNumber = "LIM-02",
      ];

      final model = CovenantCondition(
        covenantConditionId: 5,
        covenantConditionNo: "CC-5",
        covenantType: 1,
        conditionType: 2,
        description: "Desc",
        category: 3,
        frequency: 4,
        monitorDate: 20250101,
        nextMonitorDate: "2025-02-02",
        isGeneric: true,
        isNew: false,
        isCovenant: true,
        isDeleted: false,
        deleted: false,
        isStandard: true,
        isInternalFinancial: true,
        status: 10,
        action: 20,
        covConMasterId: 99,
        rimNo: 88,
        groupId: 77,
        limitCode: 66,
        threshold: 100,
        timeForSubmition: 15,
        refNo: "REF",
        appRefNum: "APP",
        customerName: "Cust",
        entityName: "Entity",
        creditLensId: "CL",
        periodTerm: 12,
        basisOfPreparation: 9,
        auditStatus: 8,
        covenantSubType: 7,
        thresholdType: 6,
        financialYearEndDate: "2025-03-03",
        mode: "SAVE",
        includeInTerms: true,
        targetDate: "2025-04-04",
        borrowers: borrowers,
        facilityDetailList: facilities,
        facilityIdList: ["LIM-01", "LIM-02"],
      );

      final json = model.toJson();
      expect(json["covenantConditionId"], 5);
      expect(json["covenantConditionNo"], "CC-5");
      expect(json["covenantType"], 1);
      expect(json["conditionType"], 2);
      expect(json["description"], "Desc");
      expect(json["category"], 3);
      expect(json["frequency"], 4);
      expect(json["monitorDate"], 20250101);
      expect(json["nextMonitorDate"], "2025-02-02");
      expect(json["isGeneric"], true);
      expect(json["isNew"], false);
      expect(json["isCovenant"], true);
      expect(json["isDeleted"], false);
      expect(json["deleted"], false);
      expect(json["isStandard"], true);
      expect(json["isInternalFinancial"], true);
      expect(json["status"], 10);
      expect(json["action"], 20);
      expect(json["covConMasterId"], 99);
      expect(json["rimNo"], 88);
      expect(json["groupId"], 77);
      expect(json["limitCode"], 66);
      expect(json["threshold"], 100);
      expect(json["timeForSubmition"], 15);
      expect(json["refNo"], "REF");
      expect(json["appRefNum"], "APP");
      expect(json["customerName"], "Cust");
      expect(json["entityName"], "Entity");
      expect(json["creditLensId"], "CL");
      expect(json["periodTerm"], 12);
      expect(json["basisOfPreparation"], 9);
      expect(json["auditStatus"], 8);
      expect(json["covenantSubType"], 7);
      expect(json["thresholdType"], 6);
      expect(json["financialYearEndDate"], "2025-03-03");
      expect(json["mode"], "SAVE");
      expect(json["facilityIdList"], ["LIM-01", "LIM-02"]);
      expect(json["isIncludedInTermaSheet"], true);
      expect(json["targetDate"], "2025-04-04");

      // Borrowers serialized via Customer.toJson()
      final borrowersJson = json["borrowerIdList"] as List;
      expect(borrowersJson.length, 2);
      expect(borrowersJson.first["rimNo"], 1);
      expect(borrowersJson.first["custName"], null);

      // Facilities serialized via Facility.toJson()
      final facilitiesJson = json["facilityDetailList"] as List;
      expect(facilitiesJson.length, 2);
      // We only need to assert presence; exact shape depends on
      // Facility.toJson()
      expect(facilitiesJson.first, isA<Map<String, dynamic>>());
    });
  });

  group("CovenantCondition.toDeleteJson", () {
    test("removes specific keys and converts flags to 1/0", () {
      final model = CovenantCondition(
        covenantConditionId: 5,
        covenantConditionNo: "CC-5",
        isDeleted: true,
        isCovenant: false,
        isGeneric: true,
        isNew: false,
        covConMasterId: 999,
        mode: "DEL",
        nextMonitorDate: "2025-05-05",
      );

      final json = model.toDeleteJson("APP-DEL");

      // Removed keys
      expect(json.containsKey("covenantConditionNo"), isFalse);
      expect(json.containsKey("deleted"), isFalse);
      expect(json.containsKey("monitorDate"), isFalse);
      expect(json.containsKey("covenantConditionMasterId"), isFalse);
      expect(json.containsKey("appRefNum"), isFalse);

      // Overridden/added keys
      expect(json["covConMasterId"], 999);
      expect(json["appRefNo"], "APP-DEL");
      expect(json["nextMonitorDate"], "2025-05-05");
      expect(json["mode"], "DEL");

      // Flags converted to 1/0
      expect(json["isDeleted"], 1);
      expect(json["isCovenant"], 0);
      expect(json["isGeneric"], 1);
      expect(json["isNew"], 0);
    });
  });

  group("CovenantCondition.toSaveJson", () {
    test("builds save payload with defaults and list mappings", () {
      final borrowers = [
        Customer(customerRimNo: 9, customerName: "Nine"),
      ];
      final facilities = [
        Facility()
          ..limitNumber = "LIM-SAVE-01"
          ..facilityTitle = "Save Ft",
      ];

      final model = CovenantCondition(
        covenantConditionId: 42,
        appRefNum: "APP-SAVE",
        rimNo: 321,
        covenantConditionNo: "CC-SAVE",
        covenantType: 5,
        isNew: true,
        description: "Save desc",
        frequency: 6,
        facilityDetailList: facilities,
        status: 90,
        action: 77,
        groupId: 808,
        periodTerm: 12,
        basisOfPreparation: 2,
        auditStatus: 1,
        timeForSubmition: 30,
        covenantSubType: 3,
        threshold: 111,
        thresholdType: 222,
        financialYearEndDate: "2025-06-06",
        nextMonitorDate: "2025-07-07",
        conditionType: 55,
        targetDate: "2025-08-08",
        includeInTerms: true,
        borrowers: borrowers,
      );

      final json = model.toSaveJson();

      expect(json["covenantConditionId"], 42);
      expect(json["covenantConditionMasterId"], 0); // default when null
      expect(json["appRefNum"], "APP-SAVE");
      expect(json["rimNo"], 321);
      expect(json["covenantConditionNo"], "CC-SAVE");
      expect(json["isCovenant"], false); // default when null
      expect(json["covenantType"], 5);
      expect(json["isGeneric"], false); // default when null
      expect(
        json["isNew"],
        true,
      ); // carries provided isNew (note: set twice, last wins)
      expect(json["description"], "Save desc");
      expect(json["frequency"], 6);

      // facilityIdList derived from facilityDetailList.limitNumber (only
      // non-null strings)
      expect(json["facilityIdList"], ["LIM-SAVE-01"]);

      // facilityDetailList serialized via Facility.toJson()
      expect(json["facilityDetailList"], isA<List>());

      expect(json["status"], 90);
      expect(json["action"], 77);
      expect(json["isStandard"], true); // default when null
      expect(json["groupId"], 808);
      expect(json["periodTerm"], 12);
      expect(json["basisOfPreparation"], 2);
      expect(json["auditStatus"], 1);
      expect(json["timeForSubmition"], 30);
      expect(json["covenantSubType"], 3);
      expect(json["isInternalFinancial"], false); // default when null
      expect(json["threshold"], 111);
      expect(json["thresholdType"], 222);
      expect(json["financialYearEndDate"], "2025-06-06");
      expect(json["nextMonitorDate"], "2025-07-07");
      expect(json["conditionType"], 55);
      expect(json["isDeleted"], false); // default when null
      expect(json["customerName"], ""); // default when null
      expect(json["entityName"], ""); // default when null
      expect(json["creditLensId"], ""); // default when null
      expect(json["targetDate"], "2025-08-08");
      expect(json["isIncludedInTermaSheet"], true);

      // borrowers mapped to { rimNo, custName }
      final borrowerList = json["borrowerIdList"] as List;
      expect(borrowerList.length, 1);
      expect(borrowerList.first["rimNo"], 9);
      expect(borrowerList.first["custName"], "Nine");
    });

    test("handles empty facilityDetailList and borrowers gracefully", () {
      final model = CovenantCondition();
      final json = model.toSaveJson();
      expect(json["facilityIdList"], <String>[]);
      expect(json["facilityDetailList"], <dynamic>[]);
      expect(json["borrowerIdList"], <dynamic>[]);
    });
  });
}
