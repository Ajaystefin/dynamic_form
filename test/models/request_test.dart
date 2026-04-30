import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  group("Request", () {
    test("should create Request instance with all properties", () {
      final request = Request(
        businessSegment: Reference(id: 1, name: "Corporate"),
        businessSegmentEnum: BusinessSegment.corporate,
        requestType: Reference(id: 1, name: "New"),
        requestSubType: Reference(id: 1, name: "SubType"),
        applicationType: Reference(id: 1, name: "New"),
        customerType: Reference(id: 1, name: "Corporate"),
        requestStatus: Reference(id: 1, name: "Draft"),
        customerRimNo: 12345,
        customerName: "Test Customer",
        groupName: "Test Group",
        caDate: 20240101,
        groupId: 1,
        applicationRefNo: "APP123",
        requestRefNo: "REQ123",
        applicantRim: "12345",
        applicantName: "Test Applicant",
        requestedBy: "User",
        createdDate: DateTime(2024, 1, 1),
        purpose: "Test Purpose",
        status: "Draft",
        creditAppDate: 20240101,
        terminatedReason: "Test Reason",
        customers: [Customer(customerName: "Test Customer")],
        cda: "CDA123",
        region: "Region1",
        branch: "Branch1",
        presentReviewDate: DateTime(2024, 1, 1),
        nextReviewDate: DateTime(2024, 12, 31),
        customerRequestReceived: DateTime(2024, 1, 1),
        dateAllDocumentReceived: DateTime(2024, 1, 2),
        tpanRequestDate: DateTime(2024, 1, 3),
        tpanRecievedDate: DateTime(2024, 1, 4),
        interimReviewDate: DateTime(2024, 6, 1),
        markForwardDate: DateTime(2024, 1, 5),
        purposeOfApplicationSummary: "Summary",
        purposeOfApplicationDetailed: "Detailed",
        mainSectorIndustry: "Technology",
        ultimateOwnership: "Private",
        deviationBreachJustification: "Justification",
        restructuredRescheduled: "No",
        exposureStrategy: "Conservative",
        productType: "Term Loan",
        reconsiderations: "None",
        islamic: true,
        conventional: false,
        tpanRequired: true,
        ermApproval: true,
        esg: true,
        shariaApproval: true,
        pricingCommittee: true,
        interimReviewDateRequired: true,
        policyDeviations: [Reference(id: 1, name: "Deviation")],
        //coBorrower: [CoBorrower(customerName: 'Co Borrower')],
      );

      expect(request.businessSegment?.id, 1);
      expect(request.businessSegmentEnum, BusinessSegment.corporate);
      expect(request.requestType?.id, 1);
      expect(request.requestSubType?.id, 1);
      expect(request.applicationType?.id, 1);
      expect(request.customerType?.id, 1);
      expect(request.requestStatus?.id, 1);
      expect(request.customerRimNo, 12345);
      expect(request.customerName, "Test Customer");
      expect(request.groupName, "Test Group");
      expect(request.caDate, 20240101);
      expect(request.groupId, 1);
      expect(request.applicationRefNo, "APP123");
      expect(request.requestRefNo, "REQ123");
      expect(request.applicantRim, "12345");
      expect(request.applicantName, "Test Applicant");
      expect(request.requestedBy, "User");
      expect(request.createdDate, DateTime(2024, 1, 1));
      expect(request.purpose, "Test Purpose");
      expect(request.status, "Draft");
      expect(request.creditAppDate, 20240101);
      expect(request.terminatedReason, "Test Reason");
      expect(request.customers?.length, 1);
      expect(request.cda, "CDA123");
      expect(request.region, "Region1");
      expect(request.branch, "Branch1");
      expect(request.presentReviewDate, DateTime(2024, 1, 1));
      expect(request.nextReviewDate, DateTime(2024, 12, 31));
      expect(request.customerRequestReceived, DateTime(2024, 1, 1));
      expect(request.dateAllDocumentReceived, DateTime(2024, 1, 2));
      expect(request.tpanRequestDate, DateTime(2024, 1, 3));
      expect(request.tpanRecievedDate, DateTime(2024, 1, 4));
      expect(request.interimReviewDate, DateTime(2024, 6, 1));
      expect(request.markForwardDate, DateTime(2024, 1, 5));
      expect(request.purposeOfApplicationSummary, "Summary");
      expect(request.purposeOfApplicationDetailed, "Detailed");
      expect(request.mainSectorIndustry, "Technology");
      expect(request.ultimateOwnership, "Private");
      expect(request.deviationBreachJustification, "Justification");
      expect(request.restructuredRescheduled, "No");
      expect(request.exposureStrategy, "Conservative");
      expect(request.productType, "Term Loan");
      expect(request.reconsiderations, "None");
      expect(request.islamic, true);
      expect(request.conventional, false);
      expect(request.tpanRequired, true);
      expect(request.ermApproval, true);
      expect(request.esg, true);
      expect(request.shariaApproval, true);
      expect(request.pricingCommittee, true);
      expect(request.interimReviewDateRequired, true);
      expect(request.policyDeviations?.length, 1);
      // expect(request.coBorrower?.length, 1);
    });

    test("should create Request instance with minimal properties", () {
      final request = Request();

      expect(request.businessSegment, isNull);
      expect(request.businessSegmentEnum, isNull);
      expect(request.requestType, isNull);
      expect(request.requestSubType, isNull);
      expect(request.applicationType, isNull);
      expect(request.customerType, isNull);
      expect(request.requestStatus, isNull);
      expect(request.customerRimNo, isNull);
      expect(request.customerName, isNull);
      expect(request.groupName, isNull);
      expect(request.caDate, isNull);
      expect(request.groupId, isNull);
      expect(request.applicationRefNo, isNull);
      expect(request.requestRefNo, isNull);
      expect(request.applicantRim, isNull);
      expect(request.applicantName, isNull);
      expect(request.requestedBy, isNull);
      expect(request.createdDate, isNull);
      expect(request.purpose, isNull);
      expect(request.status, isNull);
      expect(request.creditAppDate, isNull);
      expect(request.terminatedReason, isNull);
      expect(request.customers, isNull);
      expect(request.cda, isNull);
      expect(request.region, isNull);
      expect(request.branch, isNull);
      expect(request.presentReviewDate, isNull);
      expect(request.nextReviewDate, isNull);
      expect(request.customerRequestReceived, isNull);
      expect(request.dateAllDocumentReceived, isNull);
      expect(request.tpanRequestDate, isNull);
      expect(request.tpanRecievedDate, isNull);
      expect(request.interimReviewDate, isNull);
      expect(request.markForwardDate, isNull);
      expect(request.purposeOfApplicationSummary, isNull);
      expect(request.purposeOfApplicationDetailed, isNull);
      expect(request.mainSectorIndustry, isNull);
      expect(request.ultimateOwnership, isNull);
      expect(request.deviationBreachJustification, isNull);
      expect(request.restructuredRescheduled, isNull);
      expect(request.exposureStrategy, isNull);
      expect(request.productType, isNull);
      expect(request.reconsiderations, isNull);
      expect(request.islamic, false);
      expect(request.conventional, false);
      expect(request.tpanRequired, false);
      expect(request.ermApproval, false);
      expect(request.esg, false);
      expect(request.shariaApproval, false);
      expect(request.pricingCommittee, false);
      expect(request.interimReviewDateRequired, false);
      expect(request.policyDeviations, isNull);
      // expect(request.coBorrower, isNull);
    });

    test("should check if request is group request", () {
      final groupRequest = Request(groupId: 1);
      final individualRequest = Request(groupId: null);

      expect(groupRequest.isGroupRequest, true);
      expect(individualRequest.isGroupRequest, false);
    });

    test("should convert business segment string to enum", () {
      final request = Request();

      expect(
        request.convertToBusinessSegmentEnum("institutional"),
        BusinessSegment.financialInstitution,
      );
      expect(
        request.convertToBusinessSegmentEnum("corporate"),
        BusinessSegment.corporate,
      );
      expect(
        request.convertToBusinessSegmentEnum("business"),
        BusinessSegment.business,
      );
      expect(request.convertToBusinessSegmentEnum("baf"), BusinessSegment.baf);
      expect(
        request.convertToBusinessSegmentEnum("personal"),
        BusinessSegment.personal,
      );
      expect(
        request.convertToBusinessSegmentEnum("unknown"),
        BusinessSegment.na,
      );
      expect(request.convertToBusinessSegmentEnum(null), BusinessSegment.na);
      expect(request.convertToBusinessSegmentEnum(""), BusinessSegment.na);
      expect(
        request.convertToBusinessSegmentEnum("CORPORATE"),
        BusinessSegment.corporate,
      );
      expect(
        request.convertToBusinessSegmentEnum(" Corporate "),
        BusinessSegment.corporate,
      );
    });
    test("should create Request from close request JSON", () {
      final json = {
        "requestType": "New",
        "requestTypeId": 1,
        "requestTypeName": "New Request",
        "requestSubType": "SubType",
        "customerRim": 12345,
        "applicationRefNo": "APP123",
        "customerName": "Test Customer",
        "groupId": 1,
        "businessSegment": "corporate",
        "businessSegmentId": 1,
        "applicationType": "New",
        "applicationTypeId": 1,
        "terminatedReason": "Test Reason",
        "purpose": "Test Purpose",
        "requestedBy": "User",
        "requestStatus": "Draft",
        "tpanRecievedDate": 20240104,
        "creditAppDate": 20240101,
        "createdDate": 20240101,
      };

      final request = Request.fromCloseRequestJson(json);

      expect(request.requestType?.reference1, "New");
      expect(request.requestType?.id, 1);
      expect(request.requestType?.name, "New Request");
      expect(request.requestSubType?.reference1, "SubType");
      expect(request.customerRimNo, 12345);
      expect(request.applicationRefNo, "APP123");
      expect(request.customerName, "Test Customer");
      expect(request.groupId, 1);
      expect(request.businessSegmentEnum, BusinessSegment.corporate);
      expect(request.terminatedReason, "Test Reason");
      expect(request.purpose, "Test Purpose");
      expect(request.requestedBy, "User");
      expect(request.status, "Draft");
      expect(request.tpanRecievedDate, isNotNull);
      expect(request.creditAppDate, 20240101);
      expect(request.createdDate, isNotNull);
      expect(request.businessSegment?.id, 1);
      expect(request.businessSegment?.name, "corporate");
      expect(request.applicationType?.id, 1);
      expect(request.applicationType?.name, "New");
    });

    test("should convert Request to JSON with all properties", () {
      final request = Request(
        businessSegment: Reference(id: 1, name: "Corporate"),
        requestType: Reference(id: 1, name: "New"),
        applicationType: Reference(id: 1, name: "New"),
        customerType: Reference(id: 1, name: "Corporate"),
        customerRimNo: 12345,
        applicationRefNo: "APP123",
        customerName: "Test Customer",
        groupName: "Test Group",
        groupId: 1,
        terminatedReason: "Test Reason",
        purpose: "Test Purpose",
        requestedBy: "User",
        status: "Draft",
        tpanRecievedDate: DateTime(2024, 1, 4),
        creditAppDate: 20240101,
        createdDate: DateTime(2024, 1, 1),
        cda: "CDA123",
        region: "Region1",
        branch: "Branch1",
        presentReviewDate: DateTime(2024, 1, 1),
        nextReviewDate: DateTime(2024, 12, 31),
        customerRequestReceived: DateTime(2024, 1, 1),
        dateAllDocumentReceived: DateTime(2024, 1, 2),
        islamic: true,
        conventional: false,
        tpanRequired: true,
        tpanRequestDate: DateTime(2024, 1, 3),
        interimReviewDate: DateTime(2024, 6, 1),
        markForwardDate: DateTime(2024, 1, 5),
        purposeOfApplicationSummary: "Summary",
        purposeOfApplicationDetailed: "Detailed",
        mainSectorIndustry: "Technology",
        ultimateOwnership: "Private",
        deviationBreachJustification: "Justification",
        restructuredRescheduled: "No",
        ermApproval: true,
        esg: true,
        shariaApproval: true,
        pricingCommittee: true,
        interimReviewDateRequired: true,
        exposureStrategy: "Conservative",
        productType: "Term Loan",
        reconsiderations: "None",
        policyDeviations: [Reference(id: 1, name: "Deviation")],
        requestSubType: Reference(id: 1, name: "SubType"),
        requestStatus: Reference(id: 1, name: "Draft"),
        // coBorrower: [CoBorrower(customerName: 'Co Borrower')],
      );

      final json = request.toJson();

      expect(json["BusinessSegment"], isNotNull);
      expect(json["RequestType"], isNotNull);
      expect(json["ApplicationType"], isNotNull);
      expect(json["CustomerType"], isNotNull);
      expect(json["CustomerRimNo"], 12345);
      expect(json["applicationRefNo"], "APP123");
      expect(json["CustomerName"], "Test Customer");
      expect(json["GroupName"], "Test Group");
      expect(json["GroupId"], 1);
      expect(json["terminatedReason"], "Test Reason");
      expect(json["purpose"], "Test Purpose");
      expect(json["requestedBy"], "User");
      expect(json["status"], "Draft");
      expect(json["tpanRecievedDate"], isNotNull);
      expect(json["creditAppDate"], 20240101);
      expect(json["createdDate"], isNotNull);
      expect(json["CDA"], "CDA123");
      expect(json["Region"], "Region1");
      expect(json["Branch"], "Branch1");
      expect(json["PresentReviewDate"], isNotNull);
      expect(json["NextReviewDate"], isNotNull);
      expect(json["CustomerRequestReceived"], isNotNull);
      expect(json["DateAllDocumentReceived"], isNotNull);
      expect(json["PurposeOfApplicationSummary"], "Summary");
      expect(json["PurposeOfApplicationDetailed"], "Detailed");
      expect(json["islamic"], true);
      expect(json["conventional"], false);
      expect(json["tpanRequired"], true);
      expect(json["tpanRequestDate"], isNotNull);
      expect(json["interimReviewDate"], isNotNull);
      expect(json["markForwardDate"], isNotNull);
      expect(json["mainSectorIndustry"], "Technology");
      expect(json["ultimateOwnership"], "Private");
      expect(json["deviationBreachJustification"], "Justification");
      expect(json["ermApproval"], true);
      expect(json["esg"], true);
      expect(json["shariaApproval"], true);
      expect(json["pricingCommittee"], true);
      expect(json["restructuredRescheduled"], "No");
      expect(json["interimReviewDateRequired"], true);
      expect(json["exposureStrategy"], "Conservative");
      expect(json["productType"], "Term Loan");
      expect(json["reconsiderations"], "None");
      expect(json["policyDeviations"], isNotNull);
      // expect(json['coBorrowerMappings'], isNotNull);
    });
  });

  group("Request.fromJson Tests", () {
    test("should create Request from JSON with all properties", () {
      final json = {
        "BusinessSegment": "Corporate",
        "RequestType": {"referenceDataListId": 1, "name": "New"},
        "ApplicationType": {"referenceDataListId": 2, "name": "Loan"},
        "CustomerType": {"referenceDataListId": 3, "name": "Corporate"},
        "CustomerRimNo": 12345,
        "applicationRefNo": "APP123",
        "CustomerName": "Test Customer",
        "GroupName": "Test Group",
        "GroupId": 1,
        "GroupOwner": 99,
        "terminatedReason": "Test Reason",
        "purpose": "Test Purpose",
        "requestedBy": "User",
        "status": 0,
        "creditAppDate": 20240101,
        "createdDate": 20240101,
        "CDA": "CDA123",
        "Region": "Region1",
        "Branch": "Branch1",
        "PresentReviewDate": 20240101,
        "NextReviewDate": 20241231,
        "CustomerRequestReceived": 20240101,
        "DateAllDocumentReceived": 20240102,
        "tpanRequestDate": 20240103,
        "tpanRecievedDate": 20240104,
        "interimReviewDate": 20240601,
        "markForwardDate": 20240105,
        "PurposeOfApplicationSummary": "Summary",
        "PurposeOfApplicationDetailed": "Detailed",
        "islamic": 1,
        "conventional": 1,
        "tpanRequired": 1,
        "ermApproval": 1,
        "esg": true,
        "shariaApproval": 1,
        "pricingCommittee": 1,
        "interimReviewDateRequired": true,
        "mainSectorIndustry": "Technology",
        "ultimateOwnership": "Private",
        "deviationBreachJustification": "Justification",
        "restructuredRescheduled": "No",
        "exposureStrategy": "Conservative",
        "productType": "Term Loan",
        "reconsiderations": "None",
        "policyDeviations": [
          {"referenceDataListId": 1, "name": "Deviation"},
        ],
        "coBorrowerMappings": [
          {
            "borrowerId": 1,
            "customerName": "Co Borrower",
            "customerRimNumber": 12345,
            "delete": false,
            "added": true,
          }
        ],
        "appBorrower": [
          {"customerName": "Borrower", "customerRimNo": 111},
        ],
        "appNonBorrower": [
          {"customerName": "NonBorrower", "customerRimNo": 222},
        ],
      };

      final request = Request.fromJson(
        json,
        requestStatuses: [Reference(id: 0, name: "Draft")],
        bussinessSegments: [Reference(name: "Corporate")],
      );

      // Validate scalar fields
      expect(request.customerRimNo, 12345);
      expect(request.applicationRefNo, "APP123");
      expect(request.customerName, "Test Customer");
      expect(request.groupName, "Test Group");
      expect(request.groupId, 1);
      expect(request.groupOwner, 99);
      expect(request.purpose, "Test Purpose");
      expect(request.requestedBy, "User");
      // expect(request.status, 0);
      expect(request.cda, "CDA123");
      expect(request.region, "Region1");
      expect(request.branch, "Branch1");
      expect(request.purposeOfApplicationSummary, "Summary");
      expect(request.purposeOfApplicationDetailed, "Detailed");
      expect(request.mainSectorIndustry, "Technology");
      expect(request.ultimateOwnership, "Private");
      expect(request.deviationBreachJustification, "Justification");
      expect(request.restructuredRescheduled, "No");
      expect(request.exposureStrategy, "Conservative");
      expect(request.productType, "Term Loan");
      expect(request.reconsiderations, "None");

      // Validate booleans
      expect(request.islamic, true);
      expect(request.conventional, true);
      expect(request.tpanRequired, true);
      expect(request.ermApproval, true);
      expect(request.esg, false);
      expect(request.shariaApproval, true);
      expect(request.pricingCommittee, true);
      expect(request.interimReviewDateRequired, false);

      // Validate dates
      expect(request.createdDate, isNotNull);
      expect(request.presentReviewDate, isNotNull);
      expect(request.nextReviewDate, isNotNull);
      expect(request.customerRequestReceived, isNotNull);
      expect(request.dateAllDocumentReceived, isNotNull);
      expect(request.tpanRequestDate, isNotNull);
      expect(request.tpanRecievedDate, isNotNull);
      expect(request.interimReviewDate, isNotNull);
      expect(request.markForwardDate, isNotNull);

      // Validate nested lists
      expect(request.policyDeviations?.length, 1);
      expect(request.coBorrower?.length, 1);
      expect(request.borrowers?.length, 1);
      expect(request.nonBorrowers?.length, 1);

      // Validate references
      // expect(request.businessSegment?.name, 'Corporate');
      // expect(request.requestType?.name, 'New');
      // expect(request.applicationType?.name, 'Loan');
      // expect(request.customerType?.name, 'Corporate');

      // Validate isGroupRequest getter
      expect(request.isGroupRequest, true);
    });

    test("should handle null RequestType and ApplicationType", () {
      final json = {"requestType": "Simple", "subType": "Subtype"};
      final request = Request.fromJson(json);
      expect(request.requestType?.reference1, "Simple");
      expect(request.applicationType?.reference1, "Subtype");
    });

    test(
        "should handle empty lists for policyDeviations and coBorrowerMappings",
        () {
      final json = {"policyDeviations": [], "coBorrowerMappings": []};
      final request = Request.fromJson(json);
      expect(request.policyDeviations?.isEmpty, true);
      expect(request.coBorrower?.isEmpty, true);
    });
  });
}
