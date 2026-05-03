import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";

void main() {
  group("ApplicationDetails", () {
    test("should create ApplicationDetails instance with all properties", () {
      final applicationDetails = ApplicationDetails(
        applicationRefNo: "APP001",
        allDocRecievedDate: 1640995200,
        branch: "Main Branch",
        businessSegment: "Corporate",
        creditAppDate: 1640995200,
        // presentReviewDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        // custRequestRecieved: DateTime.fromMillisecondsSinceEpoch(1640995200),
        instanceId: "INST001",
        conventional: true,
        islamic: false,
        // lastApprovedAppDate: 1640995200,
        lastApprovedAppRefNum: "REF001",
        // nextReviewDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        purpose: "Business Loan",
        reconAppReNumber: "RECON001",
        region: "Dubai",
        requestType: "New",
        status: 1,
        subType: "Standard",
        // tpanRecievedDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        // tpanRequestDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        tpanRequired: true,
        groupApplication: false,
        createdBy: "user1",
        // createdDate: 1640995200,
        pendingWithRole: "Manager",
        pendingWith: "John Doe",
        deferralReasonCode: 1,
        deferredNextReviewDate: 1640995200,
        approvedDate: 1640995200,
        relationshipOwner: "Jane Smith",
        enabledForView: true,
        highlightEnabled: false,
        groupID: 123,
        customerName: "Test Customer",
        groupName: "Test Group",
        rimNo: 456,
        customerInformation: ApplicationCustomerInformation(
          custInfoId: 1,
          applicationRefNo: "APP001",
          customerRimNumber: 456,
          customerName: "Test Customer",
          groupName: "Test Group",
          groupId: 123,
          sicCode: "12345",
        ),
        appWorkedByCA: true,
        audit: false,
        closed: false,
      );

      expect(applicationDetails.applicationRefNo, "APP001");
      expect(applicationDetails.allDocRecievedDate, 1640995200);
      expect(applicationDetails.branch, "Main Branch");
      expect(applicationDetails.businessSegment, "Corporate");
      expect(applicationDetails.creditAppDate, 1640995200);
      // expect(applicationDetails.presentReviewDate, 1640995200);
      // expect(applicationDetails.custRequestRecieved, 1640995200);
      expect(applicationDetails.instanceId, "INST001");
      expect(applicationDetails.conventional, true);
      expect(applicationDetails.islamic, false);
      // expect(applicationDetails.lastApprovedAppDate, 1640995200);
      expect(applicationDetails.lastApprovedAppRefNum, "REF001");
      // expect(applicationDetails.nextReviewDate, 1640995200);
      expect(applicationDetails.purpose, "Business Loan");
      expect(applicationDetails.reconAppReNumber, "RECON001");
      expect(applicationDetails.region, "Dubai");
      expect(applicationDetails.requestType, "New");
      expect(applicationDetails.status, 1);
      expect(applicationDetails.subType, "Standard");
      // expect(applicationDetails.tpanRecievedDate, 1640995200);
      // expect(applicationDetails.tpanRequestDate, 1640995200);
      expect(applicationDetails.tpanRequired, true);
      expect(applicationDetails.groupApplication, false);
      expect(applicationDetails.createdBy, "user1");
      // expect(applicationDetails.createdDate, 1640995200);
      expect(applicationDetails.pendingWithRole, "Manager");
      expect(applicationDetails.pendingWith, "John Doe");
      expect(applicationDetails.deferralReasonCode, 1);
      expect(applicationDetails.deferredNextReviewDate, 1640995200);
      expect(applicationDetails.approvedDate, 1640995200);
      expect(applicationDetails.relationshipOwner, "Jane Smith");
      expect(applicationDetails.enabledForView, true);
      expect(applicationDetails.highlightEnabled, false);
      expect(applicationDetails.groupID, 123);
      expect(applicationDetails.customerName, "Test Customer");
      expect(applicationDetails.groupName, "Test Group");
      expect(applicationDetails.rimNo, 456);
      expect(applicationDetails.customerInformation, isNotNull);
      expect(applicationDetails.appWorkedByCA, true);
      expect(applicationDetails.audit, false);
      expect(applicationDetails.closed, false);
    });

    test("should create ApplicationDetails from JSON", () {
      final json = {
        "applicationRefNo": "APP001",
        "allDocRecievedDate": 1640995200,
        "branch": "Main Branch",
        "businessSegment": "Corporate",
        "creditAppDate": 1640995200,
        // 'presentReviewDate': 1640995200,
        // 'custRequestRecieved': 1640995200,
        "instanceId": "INST001",
        "conventional": 1,
        "islamic": 0,
        // 'lastApprovedAppDate': 1640995200,
        "lastApprovedAppRefNum": "REF001",
        // 'nextReviewDate': 1640995200,
        "purpose": "Business Loan",
        "reconAppReNumber": "RECON001",
        "region": "Dubai",
        "requestType": "New",
        "status": 1,
        "subType": "Standard",
        // 'tpanRecievedDate': 1640995200,
        // 'tpanRequestDate': 1640995200,
        "tpanRequired": true,
        "isGroupApplication": 0,
        "createdBy": "user1",
        // 'createdDate': 1640995200,
        "pendingWithRole": "Manager",
        "pendingWith": "John Doe",
        "deferralReasonCode": 1,
        "deferredNextReviewDate": 1640995200,
        "approvedDate": 1640995200,
        "relationshipOwner": "Jane Smith",
        "enabledForView": true,
        "highlightEnabled": false,
        "groupID": 123,
        "customerName": "Test Customer",
        "groupName": "Test Group",
        "rimNo": 456,
        "customerInformation": {
          "custInfoId": 1,
          "applicationRefNo": "APP001",
          "customerRimNumber": 456,
          "customerName": "Test Customer",
          "groupName": "Test Group",
          "groupId": 123,
          "sicCode": "12345",
          "groupMappings": [
            {
              "customerRimNumber": 456,
              "customerName": "Test Customer",
              "isPrimary": true,
              "sicCode": "12345",
              "isApplicant": true,
            }
          ],
        },
        "appWorkedByCA": true,
        "audit": false,
        "closed": false,
      };

      final applicationDetails = ApplicationDetails.fromJson(json);

      expect(applicationDetails.applicationRefNo, "APP001");
      expect(applicationDetails.allDocRecievedDate, 1640995200);
      expect(applicationDetails.branch, "Main Branch");
      expect(applicationDetails.businessSegment, "Corporate");
      expect(applicationDetails.creditAppDate, 1640995200);
      // expect(applicationDetails.presentReviewDate, 1640995200);
      // expect(applicationDetails.custRequestRecieved, 1640995200);
      expect(applicationDetails.instanceId, "INST001");
      expect(applicationDetails.conventional, true);
      expect(applicationDetails.islamic, false);
      // expect(applicationDetails.lastApprovedAppDate, 1640995200);
      expect(applicationDetails.lastApprovedAppRefNum, "REF001");
      // expect(applicationDetails.nextReviewDate, 1640995200);
      expect(applicationDetails.purpose, "Business Loan");
      expect(applicationDetails.reconAppReNumber, "RECON001");
      expect(applicationDetails.region, "Dubai");
      expect(applicationDetails.requestType, "New");
      expect(applicationDetails.status, 1);
      expect(applicationDetails.subType, "Standard");
      // expect(applicationDetails.tpanRecievedDate, 1640995200);
      // expect(applicationDetails.tpanRequestDate, 1640995200);
      expect(applicationDetails.tpanRequired, true);
      expect(applicationDetails.groupApplication, false);
      expect(applicationDetails.createdBy, "user1");
      // expect(applicationDetails.createdDate, 1640995200);
      expect(applicationDetails.pendingWithRole, "Manager");
      expect(applicationDetails.pendingWith, "John Doe");
      expect(applicationDetails.deferralReasonCode, 1);
      expect(applicationDetails.deferredNextReviewDate, 1640995200);
      expect(applicationDetails.approvedDate, 1640995200);
      expect(applicationDetails.relationshipOwner, "Jane Smith");
      expect(applicationDetails.enabledForView, true);
      expect(applicationDetails.highlightEnabled, false);
      expect(applicationDetails.groupID, 123);
      expect(applicationDetails.customerName, "Test Customer");
      expect(applicationDetails.groupName, "Test Group");
      expect(applicationDetails.rimNo, 456);
      expect(applicationDetails.customerInformation, isNotNull);
      expect(applicationDetails.customerInformation!.custInfoId, 1);
      expect(
        applicationDetails.customerInformation!.applicationRefNo,
        "APP001",
      );
      expect(applicationDetails.customerInformation!.customerRimNumber, 456);
      expect(
        applicationDetails.customerInformation!.customerName,
        "Test Customer",
      );
      expect(applicationDetails.customerInformation!.groupName, "Test Group");
      expect(applicationDetails.customerInformation!.groupId, 123);
      expect(applicationDetails.customerInformation!.sicCode, "12345");
      expect(applicationDetails.customerInformation!.groupMappings, isNotNull);
      expect(applicationDetails.customerInformation!.groupMappings!.length, 1);
      expect(applicationDetails.appWorkedByCA, true);
      expect(applicationDetails.audit, false);
      expect(applicationDetails.closed, false);
    });

    test(
        "should create ApplicationDetails from JSON"
        " with null customerInformation", () {
      final json = {
        "applicationRefNo": "APP001",
        "customerInformation": null,
      };

      final applicationDetails = ApplicationDetails.fromJson(json);

      expect(applicationDetails.applicationRefNo, "APP001");
      expect(applicationDetails.customerInformation, isNull);
    });

    test("should convert ApplicationDetails to JSON", () {
      final customerInformation = ApplicationCustomerInformation(
        custInfoId: 1,
        applicationRefNo: "APP001",
        customerRimNumber: 456,
        customerName: "Test Customer",
        groupName: "Test Group",
        groupId: 123,
        sicCode: "12345",
        groupMappings: [
          GroupMapping(
            rimNumber: 456,
            name: "Test Customer",
            isPrimary: true,
            sicCode: "12345",
            isApplicant: true,
          ),
        ],
      );

      final applicationDetails = ApplicationDetails(
        applicationRefNo: "APP001",
        allDocRecievedDate: 1640995200,
        branch: "Main Branch",
        businessSegment: "Corporate",
        creditAppDate: 1640995200,
        // presentReviewDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        // custRequestRecieved: DateTime.fromMillisecondsSinceEpoch(1640995200),
        instanceId: "INST001",
        conventional: true,
        islamic: false,
        // lastApprovedAppDate: 1640995200,
        lastApprovedAppRefNum: "REF001",
        // nextReviewDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        purpose: "Business Loan",
        reconAppReNumber: "RECON001",
        region: "Dubai",
        requestType: "New",
        status: 1,
        subType: "Standard",
        // tpanRecievedDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        // tpanRequestDate: DateTime.fromMillisecondsSinceEpoch(1640995200),
        tpanRequired: true,
        groupApplication: false,
        createdBy: "user1",
        // createdDate: 1640995200,
        pendingWithRole: "Manager",
        pendingWith: "John Doe",
        deferralReasonCode: 1,
        deferredNextReviewDate: 1640995200,
        approvedDate: 1640995200,
        relationshipOwner: "Jane Smith",
        enabledForView: true,
        highlightEnabled: false,
        groupID: 123,
        customerName: "Test Customer",
        groupName: "Test Group",
        rimNo: 456,
        customerInformation: customerInformation,
        appWorkedByCA: true,
        audit: false,
        closed: false,
      );

      final json = applicationDetails.toJson();

      expect(json["applicationRefNo"], "APP001");
      expect(json["allDocRecievedDate"], 1640995200);
      expect(json["branch"], "Main Branch");
      expect(json["businessSegment"], "Corporate");
      expect(json["creditAppDate"], 1640995200);
      // expect(json['presentReviewDate'], 1640995200);
      // expect(json['custRequestRecieved'], 1640995200);
      expect(json["instanceId"], "INST001");
      expect(json["conventional"], true);
      expect(json["islamic"], false);
      // expect(json['lastApprovedAppDate'], 1640995200);
      expect(json["lastApprovedAppRefNum"], "REF001");
      // expect(json['nextReviewDate'], 1640995200);
      expect(json["purpose"], "Business Loan");
      expect(json["reconAppReNumber"], "RECON001");
      expect(json["region"], "Dubai");
      expect(json["requestType"], "New");
      expect(json["status"], 1);
      expect(json["subType"], "Standard");
      // expect(json['tpanRecievedDate'], 1640995200);
      // expect(json['tpanRequestDate'], 1640995200);
      expect(json["tpanRequired"], true);
      expect(json["groupApplication"], false);
      expect(json["createdBy"], "user1");
      // expect(json['createdDate'], 1640995200);
      expect(json["pendingWithRole"], "Manager");
      expect(json["pendingWith"], "John Doe");
      expect(json["deferralReasonCode"], 1);
      expect(json["deferredNextReviewDate"], 1640995200);
      expect(json["approvedDate"], 1640995200);
      expect(json["relationshipOwner"], "Jane Smith");
      expect(json["enabledForView"], true);
      expect(json["highlightEnabled"], false);
      expect(json["groupID"], 123);
      expect(json["customerName"], "Test Customer");
      expect(json["groupName"], "Test Group");
      expect(json["rimNo"], 456);
      expect(json["customerInformation"], isNotNull);
      expect(json["appWorkedByCA"], true);
      expect(json["audit"], false);
      expect(json["closed"], false);
    });

    test(
        "should convert "
        "ApplicationDetails to "
        "JSON with null customerInformation", () {
      final applicationDetails = ApplicationDetails(
        applicationRefNo: "APP001",
        customerInformation: null,
      );

      final json = applicationDetails.toJson();

      expect(json["applicationRefNo"], "APP001");
      expect(json["customerInformation"], isNull);
    });
  });

  group("ApplicationCustomerInformation", () {
    test("should create ApplicationCustomerInformation instance", () {
      final customerInfo = ApplicationCustomerInformation(
        custInfoId: 1,
        applicationRefNo: "APP001",
        customerRimNumber: 456,
        customerName: "Test Customer",
        groupName: "Test Group",
        groupId: 123,
        sicCode: "12345",
        groupMappings: [
          GroupMapping(
            rimNumber: 456,
            name: "Test Customer",
            isPrimary: true,
            sicCode: "12345",
            isApplicant: true,
          ),
        ],
      );

      expect(customerInfo.custInfoId, 1);
      expect(customerInfo.applicationRefNo, "APP001");
      expect(customerInfo.customerRimNumber, 456);
      expect(customerInfo.customerName, "Test Customer");
      expect(customerInfo.groupName, "Test Group");
      expect(customerInfo.groupId, 123);
      expect(customerInfo.sicCode, "12345");
      expect(customerInfo.groupMappings, isNotNull);
      expect(customerInfo.groupMappings!.length, 1);
    });

    test("should create ApplicationCustomerInformation from JSON", () {
      final json = {
        "custInfoId": 1,
        "applicationRefNo": "APP001",
        "customerRimNumber": 456,
        "customerName": "Test Customer",
        "groupName": "Test Group",
        "groupId": 123,
        "sicCode": "12345",
        "groupMappings": [
          {
            "customerRimNumber": 456,
            "customerName": "Test Customer",
            "isPrimary": true,
            "sicCode": "12345",
            "isApplicant": true,
          }
        ],
      };

      final customerInfo = ApplicationCustomerInformation.fromJson(json);

      expect(customerInfo.custInfoId, 1);
      expect(customerInfo.applicationRefNo, "APP001");
      expect(customerInfo.customerRimNumber, 456);
      expect(customerInfo.customerName, "Test Customer");
      expect(customerInfo.groupName, "Test Group");
      expect(customerInfo.groupId, 123);
      expect(customerInfo.sicCode, "12345");
      expect(customerInfo.groupMappings, isNotNull);
      expect(customerInfo.groupMappings!.length, 1);
    });

    test(
        "should create ApplicationCustomerInformation "
        "from JSON with null groupMappings", () {
      final json = {
        "custInfoId": 1,
        "applicationRefNo": "APP001",
        "customerRimNumber": 456,
        "customerName": "Test Customer",
        "groupName": "Test Group",
        "groupId": 123,
        "sicCode": "12345",
        "groupMappings": null,
      };

      final customerInfo = ApplicationCustomerInformation.fromJson(json);

      expect(customerInfo.custInfoId, 1);
      expect(customerInfo.groupMappings, isNull);
    });

    test("should convert ApplicationCustomerInformation to JSON", () {
      final customerInfo = ApplicationCustomerInformation(
        custInfoId: 1,
        applicationRefNo: "APP001",
        customerRimNumber: 456,
        customerName: "Test Customer",
        groupName: "Test Group",
        groupId: 123,
        sicCode: "12345",
        groupMappings: [
          GroupMapping(
            rimNumber: 456,
            name: "Test Customer",
            isPrimary: true,
            sicCode: "12345",
            isApplicant: true,
          ),
        ],
      );

      final json = customerInfo.toJson();

      expect(json["custInfoId"], 1);
      expect(json["appRefNo"], "APP001");
      expect(json["customerRimNumber"], 456);
      expect(json["customerName"], "Test Customer");
      expect(json["groupName"], "Test Group");
      expect(json["groupId"], 123);
      expect(json["sicCode"], "12345");
      expect(json["groupMappings"], isNotNull);
      expect(json["groupMappings"].length, 1);
    });

    test(
        "should convert ApplicationCustomerInformation "
        "to JSON with null groupMappings", () {
      final customerInfo = ApplicationCustomerInformation(
        custInfoId: 1,
        applicationRefNo: "APP001",
        customerRimNumber: 456,
        customerName: "Test Customer",
        groupName: "Test Group",
        groupId: 123,
        sicCode: "12345",
        groupMappings: null,
      );

      final json = customerInfo.toJson();

      expect(json["custInfoId"], 1);
      expect(json["groupMappings"], isNull);
    });
  });

  group("GroupMapping", () {
    test("should create GroupMapping instance", () {
      final groupMapping = GroupMapping(
        rimNumber: 456,
        name: "Test Customer",
        isPrimary: true,
        sicCode: "12345",
        isApplicant: true,
      );

      expect(groupMapping.rimNumber, 456);
      expect(groupMapping.name, "Test Customer");
      expect(groupMapping.isPrimary, true);
      expect(groupMapping.sicCode, "12345");
      expect(groupMapping.isApplicant, true);
    });

    test("should create GroupMapping from JSON", () {
      final json = {
        "customerRimNumber": 456,
        "customerName": "Test Customer",
        "isPrimary": true,
        "sicCode": "12345",
        "isApplicant": true,
      };

      final groupMapping = GroupMapping.fromJson(json);

      expect(groupMapping.rimNumber, 456);
      expect(groupMapping.name, "Test Customer");
      expect(groupMapping.isPrimary, true);
      expect(groupMapping.sicCode, "12345");
      expect(groupMapping.isApplicant, true);
    });

    test("should create GroupMapping from JSON with rimNo field", () {
      final json = {
        "rimNo": 789,
        "customerName": "Test Customer 2",
        "isPrimary": false,
        "sicCode": "67890",
        "isApplicant": false,
      };

      final groupMapping = GroupMapping.fromJson(json);

      expect(groupMapping.rimNumber, 789);
      expect(groupMapping.name, "Test Customer 2");
      expect(groupMapping.isPrimary, false);
      expect(groupMapping.sicCode, "67890");
      expect(groupMapping.isApplicant, false);
    });

    test("should convert GroupMapping to JSON", () {
      final groupMapping = GroupMapping(
        rimNumber: 456,
        name: "Test Customer",
        isPrimary: true,
        sicCode: "12345",
        isApplicant: true,
      );

      final json = groupMapping.toJson();

      expect(json["rimNo"], 456);
      expect(json["customerName"], "Test Customer");
      expect(json["isPrimary"], true);
      expect(json["sicCode"], "12345");
      expect(json["isApplicant"], true);
    });
  });

  group("CoBorrower", () {
    test("should create CoBorrower instance", () {
      final coBorrower = CoBorrower(
        borrowerId: 1,
        customerName: "Co-Borrower 1",
        customerRimNumber: 123,
        deleted: false,
        added: true,
      );

      expect(coBorrower.borrowerId, 1);
      expect(coBorrower.customerName, "Co-Borrower 1");
      expect(coBorrower.customerRimNumber, 123);
      expect(coBorrower.deleted, false);
      expect(coBorrower.added, true);
    });

    test("should create CoBorrower from JSON", () {
      final json = {
        "borrowerId": 2,
        "customerName": "Co-Borrower 2",
        "customerRimNumber": 456,
        "delete": true,
        "added": false,
      };

      final coBorrower = CoBorrower.fromJson(json);

      expect(coBorrower.borrowerId, 2);
      expect(coBorrower.customerName, "Co-Borrower 2");
      expect(coBorrower.customerRimNumber, 456);
      expect(coBorrower.deleted, true);
      expect(coBorrower.added, false);
    });

    test("should convert CoBorrower to JSON", () {
      final coBorrower = CoBorrower(
        borrowerId: 3,
        customerName: "Co-Borrower 3",
        customerRimNumber: 789,
        deleted: true,
        added: true,
      );

      final json = coBorrower.toJson();

      expect(json["borrowerId"], 3);
      expect(json["customerName"], "Co-Borrower 3");
      expect(json["customerRimNumber"], 789);
      expect(json["isDeleted"], true);
      expect(json["isAdded"], true);
    });
  });

  group("ApplicationDetails fromJson edge cases", () {
    test("should handle instanceIdentifier field", () {
      final json = {
        "instanceIdentifier": "INST002",
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.instanceId, "INST002");
    });

    test("should handle groupId field", () {
      final json = {
        "groupId": 999,
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.groupID, 999);
    });

    test("should handle isConventional and isIslamic fields", () {
      final json = {
        "isConventional": 1,
        "isIslamic": 0,
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.conventional, true);
      expect(applicationDetails.islamic, false);
    });

    test("should handle enabledForView as 0", () {
      final json = {
        "enabledForView": 0,
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.enabledForView, false);
    });

    test("should handle enabledForView as non-zero", () {
      final json = {
        "enabledForView": 1,
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.enabledForView, true);
    });

    test("should parse policyDeviation as comma-separated string", () {
      final json = {
        "policyDeviation": "Deviation 1, Deviation 2, Deviation 3",
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.policyDeviations, isNotNull);
      expect(applicationDetails.policyDeviations!.length, 3);
      expect(applicationDetails.policyDeviations![0].name, "Deviation 1");
      expect(applicationDetails.policyDeviations![1].name, "Deviation 2");
      expect(applicationDetails.policyDeviations![2].name, "Deviation 3");
    });

    test("should handle reconAppRefNum field", () {
      final json = {
        "reconAppRefNum": "RECON002",
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.reconAppReNumber, "RECON002");
    });

    test("should handle appBorrower list", () {
      final json = {
        "appBorrower": [
          {"id": "123", "preferredName": "Borrower 1"},
          {"id": "456", "preferredName": "Borrower 2"},
        ],
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.borrowers, isNotNull);
      expect(
        applicationDetails.borrowers!.length,
        2,
      ); // Bug in original code, only adds last one
    });

    test("should handle appNonBorrower list", () {
      final json = {
        "appNonBorrower": [
          {"id": "789", "preferredName": "Non-Borrower 1"},
        ],
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.nonBorrowers, isNotNull);
      expect(applicationDetails.nonBorrowers!.length, 1);
    });

    test("should handle coBorrowerMappings in customerInformation", () {
      final json = {
        "customerInformation": {
          "coBorrowerMappings": [
            {
              "borrowerId": 1,
              "customerName": "CoBorrower 1",
              "customerRimNumber": 111,
            },
          ],
        },
      };

      final applicationDetails = ApplicationDetails.fromJson(json);
      expect(applicationDetails.customerInformation, isNotNull);
      expect(applicationDetails.customerInformation!.coBorrower, isNotNull);
      expect(applicationDetails.customerInformation!.coBorrower!.length, 1);
    });
  });

  group("ApplicationDetails toSaveApplicationJson", () {
    test("should convert ApplicationDetails to save format", () {
      final applicationDetails = ApplicationDetails(
        applicationRefNo: "APP002",
        instanceId: "INST002",
        cda: "11/11/2025",
        branch: "Branch A",
        businessSegment: "Segment B",
        customerType: "Type C",
        presentReviewDate: DateTime(2024, 6, 15),
        custRequestReceived: DateTime(2024, 6, 10),
        requestType: "New Request",
        conventional: true,
        islamic: false,
        groupApplication: true,
      )
        ..shariaApproval = true
        ..ermApproval = false
        ..esgApproval = true
        ..pricingCommitteApproval = false
        ..interimReviewDateRequired = true
        ..isOverrideNextReviewDate = false;

      final json = applicationDetails.toSaveApplicationJson();

      expect(json["appRefNo"], "APP002");
      expect(json["instanceIdentifier"], "INST002");
      expect(json["caDate"], "2025-11-11T00:00:00.000");
      expect(json["branch"], "Branch A");
      expect(json["businessSegment"], "Segment B");
      expect(json["cusType"], "Type C");
      expect(json["reqType"], "New Request");
      expect(json["isConventional"], 1);
      expect(json["isIslamic"], 0);
      expect(json["isGroupApplication"], 1);
      expect(json["isShariaApproval"], 1);
      expect(json["isERMApproval"], 0);
      expect(json["isEsgApproval"], 1);
      expect(json["isPricingCommitteeApproval"], 0);
      expect(json["interimReviewDateRequired"], 1);
      expect(json["isOverrideNextReviewDate"], 0);
    });

    test("should handle policyDeviations in toSaveApplicationJson", () {
      final applicationDetails = ApplicationDetails(
        cda: "11/11/2025",
        policyDeviations: [
          Reference(name: "Policy 1"),
          Reference(name: "Policy 2"),
        ],
      );

      final json = applicationDetails.toSaveApplicationJson();
      expect(json["caDate"], "2025-11-11T00:00:00.000");
      expect(json["policyDeviation"], "Policy 1, Policy 2");
    });

    test("should handle empty policyDeviations", () {
      final applicationDetails = ApplicationDetails(
        cda: "11/11/2025",
        policyDeviations: [],
      );

      final json = applicationDetails.toSaveApplicationJson();
      expect(json["caDate"], "2025-11-11T00:00:00.000");
      expect(json.containsKey("policyDeviation"), false);
    });

    test("should handle null policyDeviations", () {
      final applicationDetails = ApplicationDetails(
        cda: "11/11/2025",
        policyDeviations: null,
      );

      final json = applicationDetails.toSaveApplicationJson();
      expect(json["caDate"], "2025-11-11T00:00:00.000");
      expect(json.containsKey("policyDeviation"), false);
    });

    test("should handle customerInformation in toSaveApplicationJson", () {
      final customerInfo = ApplicationCustomerInformation(
        custInfoId: 1,
        applicationRefNo: "APP003",
        customerRimNumber: 555,
      );

      final applicationDetails = ApplicationDetails(
        customerInformation: customerInfo,
        cda: "11/11/2025",
      );

      final json = applicationDetails.toSaveApplicationJson();
      expect(json["customerInformation"], isNotNull);
      expect(json["caDate"], "2025-11-11T00:00:00.000");
    });

    test("should handle borrowers and nonBorrowers", () {
      final applicationDetails = ApplicationDetails()
        ..cda = "11/11/2025"
        ..borrowers = [
          Customer(id: "123", preferredName: "Borrower 1"),
        ]
        ..nonBorrowers = [
          Customer(id: "456", preferredName: "Non-Borrower 1"),
        ];

      final json = applicationDetails.toSaveApplicationJson();
      expect(json["caDate"], "2025-11-11T00:00:00.000");

      expect(json["applicationBorrowers"], isNotNull);
      expect(json["applicationNonBorrowers"], isNotNull);
    });
  });

  group("ApplicationCustomerInformation with CoBorrower", () {
    test("should handle coBorrower in toJson", () {
      final customerInfo = ApplicationCustomerInformation(
        custInfoId: 1,
        coBorrower: [
          CoBorrower(
            borrowerId: 1,
            customerName: "CoBorrower 1",
            customerRimNumber: 111,
          ),
        ],
      );

      final json = customerInfo.toJson();

      expect(json["coBorrower"], isNotNull);
      expect(json["coBorrower"].length, 1);
    });

    test("should handle null coBorrower", () {
      final customerInfo = ApplicationCustomerInformation(
        custInfoId: 1,
        coBorrower: null,
      );

      final json = customerInfo.toJson();

      expect(json["coBorrower"], isNull);
    });
  });
}
