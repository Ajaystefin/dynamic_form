import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";

void main() {
  group("customerTypeFromJson()", () {
    test("returns enum for matching string literal", () {
      expect(
        customerTypeFromJson("country"),
        CustomerType.country,
      );
    });

    test("is case-insensitive for string values", () {
      expect(
        customerTypeFromJson("CoUnTrY"),
        CustomerType.country,
      );
    });

    test("returns enum for valid int index", () {
      expect(
        customerTypeFromJson(0),
        CustomerType.values[0],
      );
    });

    test("returns null for null input", () {
      expect(customerTypeFromJson(null), isNull);
    });

    test("throws ArgumentError for unknown string", () {
      expect(
        () => customerTypeFromJson("unknown-type"),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("throws RangeError for invalid int index", () {
      expect(
        () => customerTypeFromJson(999),
        throwsA(isA<RangeError>()),
      );
    });

    test("throws ArgumentError for unsupported type", () {
      expect(
        () => customerTypeFromJson(true),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group("customerTypeToJson()", () {
    test("returns null for null", () {
      expect(customerTypeToJson(null), isNull);
    });
  });

  group("Customer()", () {
    test("constructor sets default values", () {
      final customer = Customer();

      expect(customer.isSelected, false);
      expect(customer.isSelectedBelowGrade, false);
      expect(customer.isLimitWithinPolicy, true);
      expect(customer.isCountryFI, false);
      expect(customer.isSelectedCountryFI, false);
    });
  });

  group("Customer.fromJsonCustomerCCSYS()", () {
    test("maps basic CCSYS fields", () {
      final customer = Customer.fromJsonCustomerCCSYS({
        "rimNo": 12345,
        "customerName": "ABC Corp",
        "segment": "Corporate",
        "branchName": "Dubai Main",
      });

      expect(customer.customerRimNo, 12345);
      expect(customer.customerName, "ABC Corp");
      expect(customer.segment, "Corporate");
      expect(customer.branch, "Dubai Main");
    });
  });

  group("Customer.fromJsonGetChildRimsForGroup()", () {
    test("uses customerName when provided", () {
      final customer = Customer.fromJsonGetChildRimsForGroup({
        "customerRimNo": 2001,
        "customerName": "Given Name",
        "groupName": "Group A",
        "groupId": 10,
        "groupOwner": 99,
        "firstName": "John",
        "middleName": "M",
        "lastName": "Doe",
        "preferredName": "Johnny",
        "rimType": "country",
      });

      expect(customer.customerRimNo, 2001);
      expect(customer.customerName, "Given Name");
      expect(customer.groupName, "Group A");
      expect(customer.groupId, 10);
      expect(customer.groupOwner, 99);
      expect(customer.firstName, "John");
      expect(customer.middleName, "M");
      expect(customer.lastName, "Doe");
      expect(customer.preferredName, "Johnny");
      expect(customer.type, CustomerType.country);
    });

    test("builds full name when customerName is blank", () {
      final customer = Customer.fromJsonGetChildRimsForGroup({
        "customerRimNo": 2002,
        "customerName": "   ",
        "firstName": "Jane",
        "middleName": "Q",
        "lastName": "Public",
      });

      expect(customer.customerName, "Jane Q Public");
    });
  });

  group("Customer.fromJson()", () {
    test("maps nested and flat fields correctly", () {
      final customer = Customer.fromJson({
        "rimType": "country",
        "PartyId": "123",
        "customerName": "Customer A",
        "primaryBusinessActivity": "Trading",
        "existingSICCode": "EX1",
        "proposedSicCode": "PR1",
        "isBorrower": true,
        "custInfoId": 900,
        "appRefNo": "APP-001",
        "groupName": "Group Z",
        "groupId": 111,
        "groupOwner": 222,
        "legalStatus": "LLC",
        "tradeLicenseNo": "TL123",
        "tlIssuingAuthority": "Dubai",
        "tlExpiryDate": "2026-12-31",
        "establishmentDate": "2020-01-01",
        "cbdRltnStartDate": "2021-01-01",
        "borrowRltnFrom": "2022-01-01",
        "industryDescription": "Industry Desc",
        "industryCbdSicCode": "SIC999",
        "countryOfIncorporation": "UAE",
        "healthCode": 5,
        "purpose": 2,
        "cccStatus": "Good",
        "locationAddress": "Location 1",
        "correspondenceAddress": "Correspondence 1",
        "createdDate": "2024-01-01",
        "createdBy": "maker",
        "updatedDate": "2024-02-01",
        "updatedBy": "checker",
        "cbrbClassification": "CBRB-A",
        "cbdCBRBClassification": "CBD-CBRB-A",
        "ifrsStaging": "Stage1",
        "deviationJustification": "Deviation text",
        "worldRank": 10,
        "countryRank": 20,
        "custCategory": "CAT-A",
        "poBox": "12345",
        "addressLine1": "Addr1",
        "addressLine2": "Addr2",
        "addressLine3": "Addr3",
        "emailAddress": "a@test.com",
        "phone": "999999",
        "reasonForWaiver": "Reason",
        "countriesTradedWith": "UAE, India",
        "countryOfBusiness": "UAE, KSA",
        "countryOfRisk": "India, Egypt",
        "policyDeviation": "PD1, PD2",
        "applicationBorrowerId": 777,
        "isLimitWithinPolicy": false,
        "borrowRelnDateEditable": true,
        "isBorrowerBelowGrade": true,
        "PartyInfo": {
          "PersonData": {
            "PersonName": {
              "NamePrefix": "Mr",
              "FirstName": "Ahmed",
              "MiddleName": "Ali",
              "LastName": "Khan",
              "PreferredName": "AK",
            },
            "Contact": {
              "Locator": {
                "PostAddr": {
                  "Addr1": "PAddr1",
                  "Addr2": "PAddr2",
                  "Addr3": "PAddr3",
                  "city": "Dubai",
                  "country": "UAE",
                },
              },
            },
          },
          "TLIssueCountry": "AE",
          "Resident": "Y",
          "ResidentCountry": " UAE ",
          "PartyIdType": "Passport",
          "IssuedIdent": [
            {
              "IssuedIdentName": "Passport",
              "IssuedIdentValue": "P123",
            },
            {
              "IssuedIdentName": "Emirates ID",
              "IssuedIdentValue": "E999",
            },
          ],
          "OriginatingBranchCode": "001",
          "OriginatingBranchName": "Main Branch",
          "Segmentation": {
            "SegmentDesc": "SME",
          },
          "PartyStatus": "Active",
          "ClassCode": "C1",
          "ClassCodeDesc": "Class 1",
          "RelationshipMgr": [
            {
              "RelationshipMgrIdent": "RM01",
              "RelationshipMgrName": "Manager One",
            },
            {
              "RelationshipMgrIdent": "RM02",
              "RelationshipMgrName": "Manager Two",
            },
          ],
        },
        "Nationality": ["UAE", "India"],
      });

      expect(customer.type, CustomerType.country);
      expect(customer.id, "123");
      expect(customer.customerRimNo, 123);
      expect(customer.customerName, "Customer A");
      expect(customer.primaryBusinessActivity, "Trading");
      expect(customer.existingSICCode, "EX1");
      expect(customer.proposedSICCode, "PR1");
      expect(customer.isBorrower, true);
      expect(customer.custInfoId, 900);
      expect(customer.applicationRefNo, "APP-001");
      expect(customer.groupName, "Group Z");
      expect(customer.groupId, 111);
      expect(customer.groupOwner, 222);

      expect(customer.namePrefix, "Mr");
      expect(customer.firstName, "Ahmed");
      expect(customer.middleName, "Ali");
      expect(customer.lastName, "Khan");
      expect(customer.preferredName, "AK");
      expect(customer.tLIssueCountry, "AE");
      expect(customer.resident, "Y");
      expect(customer.residentCountry, "UAE");
      expect(customer.partyIdType, "Passport");

      expect(customer.legalStatus, "LLC");
      expect(customer.tradeLicenseNumber, "TL123");
      expect(customer.tlIssuingAuthority, "Dubai");
      expect(customer.tlExpiryDate, "2026-12-31");
      expect(customer.establishmentDate, "2020-01-01");
      expect(customer.relatnStartDate, "2021-01-01");
      expect(customer.borrowRelationShipDate, "2022-01-01");

      expect(customer.industryDescription, "Industry Desc");
      expect(customer.industrySicCode, "SIC999");
      expect(customer.incorporateCountry, "UAE");
      expect(customer.healthCode, 5);
      expect(customer.purpose, 2);
      expect(customer.cccStatus, "Good");
      expect(customer.locationAddress, "Location 1");
      expect(customer.correspondanceAddress, "Correspondence 1");

      expect(customer.createdDate, "2024-01-01");
      expect(customer.createdBy, "maker");
      expect(customer.updatedDate, "2024-02-01");
      expect(customer.updatedBy, "checker");

      expect(customer.cbrbClassification, "CBRB-A");
      expect(customer.cbdCBRBClassification, "CBD-CBRB-A");
      expect(customer.ifrsStaging, "Stage1");
      expect(customer.deviationBreachJustification, "Deviation text");

      expect(customer.worldRank, 10);
      expect(customer.countryRank, 20);
      expect(customer.category, "CAT-A");
      expect(customer.poBox, "12345");
      expect(customer.addressLine1, "Addr1");
      expect(customer.addressLine2, "Addr2");
      expect(customer.addressLine3, "Addr3");
      expect(customer.emailAddress, "a@test.com");
      expect(customer.phone, "999999");
      expect(customer.reasonForWaiver, "Reason");

      expect(customer.customerAddress1, "PAddr1");
      expect(customer.customerAddress2, "PAddr2");
      expect(customer.customerAddress3, "PAddr3");
      expect(customer.city, "Dubai");
      expect(customer.country, "UAE");

      expect(customer.countriesTradedWith, hasLength(2));
      expect(customer.countriesTradedWith!.first.description, "UAE");
      expect(customer.countriesTradedWith![1].description, "India");

      expect(customer.countriesofBussinessOperation, hasLength(2));
      expect(customer.countriesofBussinessOperation!.first.description, "UAE");
      expect(customer.countriesofBussinessOperation![1].description, "KSA");

      expect(customer.countryRiskWith, hasLength(2));
      expect(customer.countryRiskWith!.first.description, "India");
      expect(customer.countryRiskWith![1].description, "Egypt");

      expect(customer.policyDeviations, hasLength(2));
      expect(customer.policyDeviations!.first.name, "PD1");
      expect(customer.policyDeviations![1].name, "PD2");

      expect(customer.applicationBorrowerId, 777);
      expect(customer.isLimitWithinPolicy, false);
      expect(customer.borrowRelnDateEditable, true);
      expect(customer.isBorrowerBelowGrade, true);

      expect(customer.issuedIdent, hasLength(2));
      expect(customer.issuedIdent!.first.name, "Passport");
      expect(customer.issuedIdent!.first.description, "P123");

      expect(customer.branchCode, "001");
      expect(customer.branch, "Main Branch");
      expect(customer.segment, "SME");
      expect(customer.partyStatus, "Active");
      expect(customer.classCode, "C1");
      expect(customer.classCodeDesc, "Class 1");

      expect(customer.relationshipMgr, hasLength(2));
      expect(customer.relationshipMgr!.first["RelationshipMgrIdent"], "RM01");
      expect(
        customer.relationshipMgr!.first["RelationshipMgrName"],
        "Manager One",
      );

      expect(customer.nationality, ["UAE", "India"]);
    });

    test("treats invalid string values as null where expected", () {
      final customer = Customer.fromJson({
        "legalStatus": "null",
        "tradeLicenseNo": "",
        "tlIssuingAuthority": null,
        "cccStatus": "",
        "locationAddress": "null",
        "countryOfIncorporation": "",
        "proposedSicCode": "null",
      });

      expect(customer.legalStatus, isNull);
      expect(customer.tradeLicenseNumber, isNull);
      expect(customer.tlIssuingAuthority, isNull);
      expect(customer.cccStatus, isNull);
      expect(customer.locationAddress, isNull);
      expect(customer.incorporateCountry, isNull);
      expect(customer.proposedSICCode, isNull);
    });

    test("falls back to rimNo when PartyId cannot be parsed", () {
      final customer = Customer.fromJson({
        "PartyId": "abc",
        "rimNo": 888,
      });

      expect(customer.customerRimNo, 888);
    });

    test("throws for invalid rimType literal", () {
      expect(
        () => Customer.fromJson({
          "rimType": "not-a-valid-type",
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group("Customer getters", () {
    test("displayName prefers customerName first", () {
      final customer = Customer(
        customerName: "Customer X",
        firstName: "First",
        preferredName: "Pref",
        lastName: "Last",
        middleName: "Mid",
      );

      expect(customer.displayName, "Customer X");
    });

    test(
        "displayName falls back through firstName/preferredName/lastName/middleName",
        () {
      expect(
        Customer(firstName: "First").displayName,
        "First",
      );
      expect(
        Customer(preferredName: "Pref").displayName,
        "Pref",
      );
      expect(
        Customer(lastName: "Last").displayName,
        "Last",
      );
      expect(
        Customer(middleName: "Mid").displayName,
        "Mid",
      );
    });

    test("fullName joins first middle last", () {
      final customer = Customer(
        firstName: "John",
        middleName: "M",
        lastName: "Doe",
      );

      expect(customer.fullName, "John M Doe");
    });

    test("displayRIMName uses customerName first", () {
      final customer = Customer(
        customerName: "Customer Name",
        firstName: "First",
      );

      expect(customer.displayRIMName, "Customer Name");
    });

    test(
        "displayRIMName falls back to firstName/preferredName/lastName/middleName",
        () {
      expect(Customer(firstName: "First").displayRIMName, "First");
      expect(Customer(preferredName: "Pref").displayRIMName, "Pref");
      expect(Customer(lastName: "Last").displayRIMName, "Last");
      expect(Customer(middleName: "Mid").displayRIMName, "Mid");
    });

    test("displayRIMName returns null when all values are empty", () {
      final customer = Customer();
      expect(customer.displayRIMName, isNull);
    });

    test("concatCustomerFullName joins first middle last and ignores blanks",
        () {
      final customer = Customer(
        firstName: "A",
        middleName: "",
        lastName: "B",
      );

      expect(customer.concatCustomerFullName, "A B");
    });

    test(
        "concatCustomerFullName returns empty string"
        " when all name parts missing", () {
      final customer = Customer();
      expect(customer.concatCustomerFullName, "");
    });

    test("concatNonEmpty joins only non-empty values", () {
      final customer = Customer();
      expect(
        customer.concatNonEmpty(["A", "", null, "B"]),
        "A B",
      );
    });
  });

  group("Customer.toJson()", () {
    test("serializes main fields", () {
      final customer = Customer(
        id: "P1",
        customerRimNo: 1001,
        primaryBusinessActivity: "Trade",
        customerName: "Name 1",
        existingSICCode: "EX",
        proposedSICCode: "PR",
        custInfoId: 50,
        applicationRefNo: "APP-1",
        groupName: "Group 1",
        groupId: 70,
        legalStatus: "LLC",
        tradeLicenseNumber: "TL1",
        tlIssuingAuthority: "Dubai",
        tlExpiryDate: "2026-12-31",
        industryDescription: "Desc",
        industrySicCode: "SIC1",
        incorporateCountry: "UAE",
        establishmentDate: "2020-01-01",
        relatnStartDate: "2021-01-01",
        borrowRelationShipDate: "2022-01-01",
        cccStatus: "Good",
        locationAddress: "Loc",
        correspondanceAddress: "Corr",
        createdDate: "2024-01-01",
        createdBy: "maker",
        updatedDate: "2024-02-01",
        updatedBy: "checker",
        cbrbClassification: "A",
        cbdCBRBClassification: "B",
        ifrsStaging: "Stage1",
        deviationBreachJustification: "Justification",
        policyDeviations: [
          Reference(name: "PD1"),
          Reference(name: "PD2"),
        ],
        worldRank: 1,
        countryRank: 2,
        category: "Cat1",
        countriesTradedWith: [
          Country(description: "UAE"),
          Country(description: "India"),
        ],
        poBox: "123",
        addressLine1: "Addr1",
        addressLine2: "Addr2",
        emailAddress: "x@test.com",
        phone: "123456",
        reasonForWaiver: "Waiver",
        isLimitWithinPolicy: false,
      );

      final json = customer.toJson();

      expect(json["PartyId"], "P1");
      expect(json["rimNo"], 1001);
      expect(json["primaryBusinessActivity"], "Trade");
      expect(json["customerName"], "Name 1");
      expect(json["existingSICCode"], "EX");
      expect(json["proposedSicCode"], "PR");
      expect(json["custInfoId"], 50);
      expect(json["appRefNo"], "APP-1");
      expect(json["groupName"], "Group 1");
      expect(json["groupId"], 70);
      expect(json["legalStatus"], "LLC");
      expect(json["tradeLicenseNo"], "TL1");
      expect(json["tlIssuingAuthority"], "Dubai");
      expect(json["tlExpiryDate"], "2026-12-31");
      expect(json["industryDescription"], "Desc");
      expect(json["industryCbdSicCode"], "SIC1");
      expect(json["countryOfIncorporation"], "UAE");
      expect(json["establishmentDate"], "2020-01-01");
      expect(json["cbdRltnStartDate"], "2021-01-01");
      expect(json["borrowRltnFrom"], "2022-01-01");
      expect(json["cccStatus"], "Good");
      expect(json["locationAddress"], "Loc");
      expect(json["correspondanceAddress"], "Corr");
      expect(json["createdDate"], "2024-01-01");
      expect(json["createdBy"], "maker");
      expect(json["updatedDate"], "2024-02-01");
      expect(json["updatedBy"], "checker");
      expect(json["cbrbClassification"], "A");
      expect(json["cbdCBRBClassification"], "B");
      expect(json["ifrsStaging"], "Stage1");
      expect(json["deviationJustification"], "Justification");
      expect(json["policyDeviation"], isA<List<Reference>>());
      expect(json["worldRank"], 1);
      expect(json["countryRank"], 2);
      expect(json["custCategory"], "Cat1");
      expect(json["countriesTradedWith"], isA<List<Country>>());
      expect(json["poBox"], "123");
      expect(json["addressLine1"], "Addr1");
      expect(json["addressLine2"], "Addr2");
      expect(json["addressLine3"], "DUBAI"); // default fallback
      expect(json["emailAddress"], "x@test.com");
      expect(json["phone"], "123456");
      expect(json["reasonForWaiver"], "Waiver");
      expect(json["isLimitWithinPolicy"], false);
    });
  });

  group("Customer.toSaveJson()", () {
    test("serializes transformed save payload correctly", () {
      final customer = Customer(
        id: "P1",
        custInfoId: 10,
        applicationRefNo: "APP-10",
        customerRimNo: 999,
        businessSegment: "Corporate",
        customerName: "Save Name",
        groupName: "Group Save",
        groupId: 12,
        primaryBusinessActivity: "Manufacturing",
        legalStatus: "LLC",
        tradeLicenseNumber: "TL-1",
        tlIssuingAuthority: "Dubai",
        industryDescription: "Industry",
        industrySicCode: "SIC001",
        incorporateCountry: "UAE",
        tlExpiryDateLong: 1111,
        countriesofBussinessOperation: [
          Country(description: "UAE"),
          Country(description: "KSA"),
        ],
        countryRiskWith: [
          Country(description: "India"),
        ],
        countriesTradedWith: [
          Country(description: "Egypt"),
          Country(description: "Jordan"),
        ],
        policyDeviations: [
          Reference(name: "PD1"),
          Reference(name: "PD2"),
        ],
        cbdCBRBClassification: "CBD-X",
        cbrbClassification: "CBRB-X",
        purpose: 5,
        healthCode: 8,
        locationAddress: "Loc Save",
        correspondanceAddress: "Corr Save",
        poBox: "1000",
        addressLine1: "L1",
        addressLine2: "L2",
        emailAddress: "save@test.com",
        phone: "777",
        cccStatus: "OK",
        proposedSICCode: "PSIC",
        ifrsStaging: "Stage2",
        deviationBreachJustification: "Need waiver",
        reasonForWaiver: "Because",
        worldRank: 1,
        isLimitWithinPolicy: true,
        countryRank: 2,
        category: "CatSave",
      );

      final json = customer.toSaveJson();

      expect(json["PartyId"], "P1");
      expect(json["custInfoId"], 10);
      expect(json["appRefNo"], "APP-10");
      expect(json["rimNo"], 999);
      expect(json["businessSegment"], "Corporate");
      expect(json["customerName"], "Save Name");
      expect(json["groupName"], "Group Save");
      expect(json["groupId"], 12);
      expect(json["primaryBusinessActivity"], "Manufacturing");
      expect(json["legalStatus"], "LLC");
      expect(json["tradeLicenseNo"], "TL-1");
      expect(json["tlIssuingAuthority"], "Dubai");
      expect(json["industryDescription"], "Industry");
      expect(json["industryCbdSicCode"], "SIC001");
      expect(json["countryOfIncorporation"], "UAE");
      expect(json["tlExpiryDate"], 1111);
      expect(json["establishmentDate"], isNull);
      expect(json["cbdRltnStartDate"], isNull);
      expect(json["borrowRltnFrom"], isNull);

      expect(json["countryOfBusiness"], "UAE, KSA");
      expect(json["countryOfRisk"], "India");
      expect(json["countriesTradedWith"], "Egypt, Jordan");
      expect(json["policyDeviation"], "PD1, PD2");

      expect(json["cbdCBRBClassification"], "CBD-X");
      expect(json["cbrbClassification"], "CBRB-X");
      expect(json["purposeCode"], 5);
      expect(json["healthCode"], 8);
      expect(json["locationAddress"], "Loc Save");
      expect(json["correspondenceAddress"], "Corr Save");
      expect(json["poBox"], "1000");
      expect(json["addressLine1"], "L1");
      expect(json["addressLine2"], "L2");
      expect(json["addressLine3"], "DUBAI"); // default fallback
      expect(json["emailAddress"], "save@test.com");
      expect(json["phone"], "777");
      expect(json["cccStatus"], "OK");
      expect(json["proposedSicCode"], "PSIC");
      expect(json["ifrsStaging"], "Stage2");
      expect(json["deviationJustification"], "Need waiver");
      expect(json["reasonForWaiver"], "Because");
      expect(json["worldRank"], 1);
      expect(json["isLimitWithinPolicy"], true);
      expect(json["countryRank"], 2);
      expect(json["custCategory"], "CatSave");
    });

    test(
        "uses raw "
        "borrowRelationShipDate when "
        "isBorrowerRelationshipDate is false", () {
      final customer = Customer(
        borrowRelationShipDate: "2024-01-01",
      );

      final json = customer.toSaveJson();

      expect(json["borrowRltnFrom"], "2024-01-01");
    });
  });

  group("CustomerOwnerShipInfo", () {
    test("fromJson maps fields", () {
      final info = CustomerOwnerShipInfo.fromJson({
        "custOwnershipId": 1,
        "custOwnerName": "Owner A",
        "custOwnerRim": 999,
        "custInfoId": 777,
        "nationality": "UAE",
        "shareHoldingPerc": 40.5,
        "resident": "Y",
        "beneficialOwnershipPerc": 30.0,
        "identificationDetails": "Passport",
        "identificationNumber": "P123",
        "createdBy": "maker",
        "updatedBy": "checker",
        "custOwnerType": "Individual",
      });

      expect(info.custOwnId, 1);
      expect(info.custOwnershipName, "Owner A");
      expect(info.custOwnershipRim, 999);
      expect(info.rim, 777);
      expect(info.nationality, "UAE");
      expect(info.shareHoldingPercentage, 40.5);
      expect(info.resident, "Y");
      expect(info.beneficialOwnerhipPercentage, 30.0);
      expect(info.identificationDetail, "Passport");
      expect(info.identificationNumber, "P123");
      expect(info.createdBy, "maker");
      expect(info.updatedBy, "checker");
      expect(info.custOwnershipType, "Individual");
    });

    test("toJson serializes fields", () {
      final info = CustomerOwnerShipInfo(
        custOwnId: 1,
        custOwnershipName: "Owner A",
        custOwnershipRim: 999,
        rim: 777,
        nationality: "UAE",
        shareHoldingPercentage: 40.5,
        resident: "Y",
        beneficialOwnerhipPercentage: 30,
        identificationDetail: "Passport",
        identificationNumber: "P123",
        createdBy: "maker",
        updatedBy: "checker",
        custOwnershipType: "Individual",
      );

      final json = info.toJson();

      expect(json["custOwnershipId"], 1);
      expect(json["custOwnerName"], "Owner A");
      expect(json["custOwnerRim"], 999);
      expect(json["custInfoId"], 777);
      expect(json["nationality"], "UAE");
      expect(json["shareHoldingPerc"], 40.5);
      expect(json["resident"], "Y");
      expect(json["beneficialOwnershipPerc"], 30.0);
      expect(json["identificationDetails"], "Passport");
      expect(json["identificationNumber"], "P123");
      expect(json["createdBy"], "maker");
      expect(json["updatedBy"], "checker");
      expect(json["custOwnerType"], "Individual");
    });
  });

  group("CustomerException", () {
    test("fromJson maps fields", () {
      final ex = CustomerException.fromJson({
        "exceptionId": 11,
        "custInfoId": 22,
        "typeCode": "TYPE-A",
        "facility": "FAC-1",
        "exceptionDescription": "Something happened",
        "dueDate": "2025-12-01",
        "status": "Open",
        "recommendation": "Fix it",
        "delete": true,
      });

      expect(ex.exceptionId, 11);
      expect(ex.custInfoId, 22);
      expect(ex.type, "TYPE-A");
      expect(ex.facilityId, "FAC-1");
      expect(ex.description, "Something happened");
      expect(ex.dueDate, "2025-12-01");
      expect(ex.status, "Open");
      expect(ex.recommendations, "Fix it");
      expect(ex.delete, true);
    });

    test("toJson serializes fields", () {
      final ex = CustomerException(
        exceptionId: 11,
        custInfoId: 22,
        type: "TYPE-A",
        facilityId: "FAC-1",
        description: "Something happened",
        dueDateLong: 123456789,
        status: "Open",
        recommendations: "Fix it",
        delete: true,
      );

      final json = ex.toJson();

      expect(json["exceptionId"], 11);
      expect(json["custInfoId"], 22);
      expect(json["typeCode"], "TYPE-A");
      expect(json["facility"], "FAC-1");
      expect(json["exceptionDescription"], "Something happened");
      expect(json["dueDate"], 123456789);
      expect(json["status"], "Open");
      expect(json["recommendation"], "Fix it");
      expect(json["delete"], true);
    });

    test("delete defaults to false when not provided in fromJson", () {
      final ex = CustomerException.fromJson({
        "exceptionId": 1,
      });

      expect(ex.delete, false);
    });
  });
}
