import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  group("Covenant Model Tests", () {
    setUp(() {
      Globals.request = Request(applicationRefNo: "APP999");
      ServerConstants.defaultFacilityList = [
        FacilityNew(
          limitNo: "DEFAULT",
          rimNo: 0,
          facilityTypeName: "",
          projectName: "",
          proposedLimit: 0,
        ),
      ];
    });

    test("Constructor initializes all fields correctly", () {
      final covenant = Covenant(
        covenantConditionId: 1,
        covenantType: 2,
        conditionType: 3,
        covenantConditionNo: "CCN001",
        description: "Test Description",
        category: 4,
        frequency: 5,
        monitorDate: 20250101,
        nextMonitorDate: "2025-10-10",
        isGeneric: true,
        isNew: false,
        isCovenant: true,
        isDeleted: false,
        deleted: false,
        isStandard: true,
        isInternalFinancial: false,
        status: "New",
        action: 2,
        covConMasterId: 3,
        rimNo: 123,
        groupId: 456,
        limitCode: 789,
        threshold: 1000,
        timeForSubmition: 30,
        refNo: "REF123",
        appRefNum: "APP456",
        customerName: "Customer A",
        entityName: "Entity B",
        creditLensId: "CL789",
        periodTerm: 12,
        basisOfPreparation: 1,
        auditStatus: 2,
        covenantSubType: 3,
        thresholdType: 4,
        financialYearEndDate: "2025-12-31",
        mode: "Online",
        borrowers: [Customer(customerRimNo: 1, customerName: "Dummy")],
        facilityIdList: [
          FacilityNew(
            rimNo: 123,
            limitNo: "LIM001",
            facilityTypeName: "Type A",
            projectName: "Project X",
            proposedLimit: 500000,
          ),
        ],
      );

      expect(covenant.covenantConditionId, 1);
      expect(covenant.borrowers?.first.customerName, "Dummy");
      expect(covenant.facilityIdList?.first.projectName, "Project X");
    });

    // test('fromJson creates Covenant correctly', () {
    //   final json = {
    //     'covenantConditionId': 1,
    //     'covenantConditionNo': 'CCN001',
    //     'covenantType': 2,
    //     'conditionType': 3,
    //     'description': 'Test Description',
    //     'category': 4,
    //     'frequency': 5,
    //     'monitorDate': 20250101,
    //     'nextMonitorDate': '2025-10-10',
    //     'isGeneric': true,
    //     'isNew': false,
    //     'isCovenant': true,
    //     'isDeleted': false,
    //     'deleted': false,
    //     'isStandard': true,
    //     'isInternalFinancial': false,
    //     'status': 1,
    //     'action': 2,
    //     'covenantConditionMasterId': 99,
    //     'rimNo': 123,
    //     'groupId': 456,
    //     'limitCode': 789,
    //     'threshold': 1000,
    //     'timeForSubmition': 30,
    //     'refNo': 'REF123',
    //     'appRefNum': 'APP456',
    //     'customerName': 'Customer A',
    //     'entityName': 'Entity B',
    //     'creditLensId': 'CL789',
    //     'periodTerm': 12,
    //     'basisOfPreparation': 1,
    //     'auditStatus': 2,
    //     'covenantSubType': 3,
    //     'thresholdType': 4,
    //     'financialYearEndDate': '2025-12-31',
    //     'mode': 'Online',
    //     'borrowerIdList': [
    //       {'customerRimNo': 1, 'customerName': 'Dummy'}
    //     ],
    //     'facilityDetailList': [
    //       {
    //         'rimNo': 123,
    //         'limitNo': 'LIM001',
    //         'facilityTypeName': 'Type A',
    //         'projectName': 'Project X',
    //         'proposedLimit': 500000
    //       }
    //     ]
    //   };

    //   final covenant = Covenant.fromJson(json);
    //   expect(covenant.covConMasterId, 99);
    //   expect(covenant.borrowers?.first.customerName, 'Dummy');
    //   // expect(covenant.facilityIdList?.first.limitNo, 'LIM001');
    // });

    // test('Default values for borrowers and facilityIdList are empty lists',
    // () {
    //   final covenant = Covenant();
    //   expect(covenant.borrowers, isEmpty);
    //   expect(covenant.facilityIdList, isEmpty);
    // });

    test("toDeleteJson returns correct map", () {
      final covenant = Covenant(
        covenantConditionId: 1,
        covConMasterId: 2,
        appRefNum: "APP123",
        rimNo: 456,
        covenantConditionNo: "CCN001",
        isCovenant: true,
        covenantType: 3,
        isGeneric: true,
        description: "Test",
        frequency: 12,
        facilityIdList: [
          FacilityNew(
            limitNo: "LIM001",
            rimNo: 1,
            facilityTypeName: "",
            projectName: "",
            proposedLimit: 0,
          ),
        ],
        borrowers: [Customer(customerRimNo: 1, customerName: "John Doe")],
        status: "New",
        action: 2,
        isStandard: false,
        groupId: 10,
        periodTerm: 6,
        basisOfPreparation: 1,
        auditStatus: 2,
        timeForSubmition: 30,
        covenantSubType: 4,
        isInternalFinancial: true,
        threshold: 1000,
        thresholdType: 5,
        financialYearEndDate: "2025-12-31",
        nextMonitorDate: "2025-10-10",
        conditionType: 2,
        isDeleted: true,
        customerName: "Customer A",
        entityName: "Entity B",
        creditLensId: "CL123",
      );

      final json = covenant.toDeleteJson("APP123");
      // expect(json['facilityIdList'], ['LIM001']);
      expect(json["borrowerIdList"], isNotEmpty);
    });

    test("toSaveJson returns correct map", () {
      final covenant = Covenant(
        covenantConditionId: 1,
        covConMasterId: 2,
        appRefNum: "APP123",
        rimNo: 456,
        covenantConditionNo: "CCN001",
        isCovenant: true,
        covenantType: 3,
        isGeneric: true,
        description: "Test",
        frequency: 12,
        facilityIdList: [
          FacilityNew(
            limitNo: "LIM001",
            rimNo: 1,
            facilityTypeName: "",
            projectName: "",
            proposedLimit: 0,
          ),
        ],
        borrowers: [Customer(customerRimNo: 1, customerName: "John Doe")],
      );

      final json = covenant.toSaveJson();
      // expect(json['facilityIdList'], ['LIM001']);
      expect(json["borrowerIdList"], isNotEmpty);
    });

    test("toSaveNewJson handles all conditions", () {
      final covenant = Covenant(
        covConMasterId: 10,
        rimNo: 123,
        isCovenant: true,
        covenantType: 2,
        isGeneric: true,
        description: null,
        category: 5,
        facilityIdList: null,
        status: null,
        borrowers: [],
      );

      final json = covenant.toSaveNewJson();
      expect(json["description"], "5");
      expect(json["status"], "New");
      expect(json["borrowerIdList"], isEmpty);
    });

    test("toSaveNewJson uses description and borrowers when provided", () {
      final covenant = Covenant(
        covConMasterId: 1,
        rimNo: 456,
        isCovenant: true,
        covenantType: 3,
        isGeneric: false,
        description: "Valid Description",
        facilityIdList: [
          FacilityNew(
            limitNo: "LIM001",
            rimNo: 1,
            facilityTypeName: "",
            projectName: "",
            proposedLimit: 0,
          ),
        ],
        status: "New",
        borrowers: [Customer(customerRimNo: 1, customerName: "Alice")],
      );

      final json = covenant.toSaveNewJson();
      expect(json["description"], "Valid Description");
      expect(json["borrowerIdList"][0]["custName"], "Alice");
    });
  });
}
