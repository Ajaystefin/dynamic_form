import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/models/information/customer_information.dart";

void main() {
  group("CustomerInformation", () {
    test("fromJson creates a valid CustomerInformation object", () {
      final Map<String, dynamic> json = {
        "custInfoId": 1,
        "applicationRefNo": "APP001",
        "customerRimNumber": 12345,
        "customerName": "Test Customer",
        "groupName": "Test Group",
        "groupId": 101,
        "legalStatus": "Active",
        "tradeLicenseNumber": "TLN001",
        "tlIssuingAuthority": "Authority A",
        "tlExpiryDate": 20241231,
        "industryDescription": "IT Services",
        "industrySicCode": "7379",
        "incorporateCountry": "USA",
        "businessCountryList": ["USA", "CAN"],
        "establishmentDate": 20200101,
        "relatnStartDate": 20210101,
        "borrowRelationShipDate": 20220101,
        "healthCode": 1,
        "purpose": 2,
        "cccStatus": "Approved",
        "locationAddress": "123 Main St",
        "correspondanceAddress": "456 Oak Ave",
        "customerOwnerShipInfoList": [
          {
            "custOwnId": 1,
            "custOwnershipName": "Owner 1",
            "custOwnershipRim": 1001,
            "rim": 2001,
            "nationality": "US",
            "shareHoldingPercentage": 50,
            "resident": "Yes",
            "beneficialOwnerhipPercentage": 50,
            "identificationDetail": "Passport",
            "identificationNumber": "ID001",
            "createdDate": 20230101,
            "createdBy": "UserA",
            "updatedDate": 20230102,
            "updatedBy": "UserB",
            "custOwnershipType": "Individual",
          }
        ],
        "exceptionList": [
          {
            "type": "TypeA",
            "facilityId": 1,
            "description": "Exception A",
            "dueDate": 20240630,
            "status": "Open",
            "recommendations": "Rec A",
            "delete": false,
          },
        ],
        "createdDate": 20230101,
        "createdBy": "UserX",
        "updatedDate": 20230102,
        "updatedBy": "UserY",
        "cbrbClasification": "Class A",
        "tradedCountryList": ["GBR", "DEU"],
        "cbdCBRBClassification": "CBD Class A",
        "borrowRelnDateEditable": true,
        "countryOfBusiness": {"id": "US", "name": "United States"},
        "countryTradedWith": {"id": "GB", "name": "United Kingdom"},
        "existingcode": "EX001",
        "primaryBussinessActivity": "Software Development",
        "accountLevelSicCode": "SIC001",
      };

      final customerInfo = CustomerInformation.fromJson(json);

      expect(customerInfo.custInfoId, 1);
      expect(customerInfo.applicationRefNo, "APP001");
      expect(customerInfo.customerRimNumber, 12345);
      expect(customerInfo.customerName, "Test Customer");
      expect(customerInfo.groupName, "Test Group");
      expect(customerInfo.groupId, 101);
      expect(customerInfo.legalStatus, "Active");
      expect(customerInfo.tradeLicenseNumber, "TLN001");
      expect(customerInfo.tlIssuingAuthority, "Authority A");
      expect(customerInfo.tlExpiryDate, DateTimeUtils.intToDateTime(20241231));
      expect(customerInfo.industryDescription, "IT Services");
      expect(customerInfo.industrySicCode, "7379");
      expect(customerInfo.incorporateCountry, "USA");
      expect(customerInfo.businessCountryList, ["USA", "CAN"]);
      expect(
        customerInfo.establishmentDate,
        DateTimeUtils.intToDateTime(20200101),
      );
      expect(
        customerInfo.relationStartDate,
        DateTimeUtils.intToDateTime(20210101),
      );
      expect(
        customerInfo.borrowRelationShipDate,
        DateTimeUtils.intToDateTime(20220101),
      );
      expect(customerInfo.healthCode, 1);
      expect(customerInfo.purpose, 2);
      expect(customerInfo.cccStatus, "Approved");
      expect(customerInfo.locationAddress, "123 Main St");
      expect(customerInfo.correspondanceAddress, "456 Oak Ave");
      expect(customerInfo.customerOwnerShipInfoList!.length, 1);
      expect(
        customerInfo.customerOwnerShipInfoList![0].custOwnershipName,
        "Owner 1",
      );
      expect(customerInfo.customerExceptionList!.length, 1);
      expect(customerInfo.customerExceptionList![0].description, "Exception A");
      expect(customerInfo.createdDate, 20230101);
      expect(customerInfo.createdBy, "UserX");
      expect(customerInfo.updatedDate, 20230102);
      expect(customerInfo.updatedBy, "UserY");
      expect(customerInfo.cbrbClasification, "Class A");
      expect(customerInfo.tradedCountryList, ["GBR", "DEU"]);
      expect(customerInfo.cbdCBRBClassification, "CBD Class A");
      expect(customerInfo.borrowRelnDateEditable, true);
      expect(customerInfo.countryOfBusiness?.id, null);
      expect(customerInfo.countryTradedWith?.id, null);
    });

    test("toJson converts a CustomerInformation object to JSON", () {
      final customerInfo = CustomerInformation(
        custInfoId: 1,
        applicationRefNo: "APP001",
        customerRimNumber: 12345,
        customerName: "Test Customer",
        groupName: "Test Group",
        groupId: 101,
        legalStatus: "Active",
        tradeLicenseNumber: "TLN001",
        tlIssuingAuthority: "Authority A",
        tlExpiryDate: DateTimeUtils.intToDateTime(20241231),
        industryDescription: "IT Services",
        industrySicCode: "7379",
        incorporateCountry: "USA",
        businessCountryList: ["USA", "CAN"],
        establishmentDate: DateTimeUtils.intToDateTime(20200101),
        relationStartDate: DateTimeUtils.intToDateTime(20210101),
        borrowRelationShipDate: DateTimeUtils.intToDateTime(20220101),
        healthCode: 1,
        purpose: 2,
        cccStatus: "Approved",
        locationAddress: "123 Main St",
        correspondanceAddress: "456 Oak Ave",
        customerOwnerShipInfoList: [
          CustomerOwnerShipInfo(
            custOwnId: 1,
            custOwnershipName: "Owner 1",
            custOwnershipRim: 1001,
            rim: 2001,
            nationality: "US",
            shareHoldingPercentage: 50,
            resident: "Yes",
            beneficialOwnerhipPercentage: 50,
            identificationDetail: "Passport",
            identificationNumber: "ID001",
            createdDate: 20230101,
            createdBy: "UserA",
            updatedDate: 20230102,
            updatedBy: "UserB",
          ),
        ],
        createdDate: 20230101,
        createdBy: "UserX",
        updatedDate: 20230102,
        updatedBy: "UserY",
        cbrbClasification: "Class A",
        tradedCountryList: ["GBR", "DEU"],
        cbdCBRBClassification: "CBD Class A",
        borrowRelnDateEditable: true,
        existingcode: "EX001",
        primaryBussinessActivity: "Software Development",
        accountLevelSicCode: "SIC001",
      );

      final json = customerInfo.toJson();

      expect(json["custInfoId"], 1);
      expect(json["applicationRefNo"], "APP001");
      expect(json["customerRimNumber"], 12345);
      expect(json["customerName"], "Test Customer");
      expect(json["groupName"], "Test Group");
      expect(json["groupId"], 101);
      expect(json["legalStatus"], "Active");
      expect(json["tradeLicenseNumber"], "TLN001");
      expect(json["tlIssuingAuthority"], "Authority A");
      expect(json["tlExpiryDate"], 20241231);
      expect(json["industryDescription"], "IT Services");
      expect(json["industrySicCode"], "7379");
      expect(json["incorporateCountry"], "USA");
      expect(json["businessCountryList"], ["USA", "CAN"]);

      expect(json["relatnStartDate"], 20210101);
      expect(json["borrowRelationShipDate"], 20220101);
      expect(json["healthCode"], 1);
      expect(json["purpose"], 2);
      expect(json["cccStatus"], "Approved");
      expect(json["locationAddress"], "123 Main St");
      expect(json["correspondanceAddress"], "456 Oak Ave");
      expect(json["customerOwnerShipInfoList"]!.length, 1);

      expect(json["createdDate"], 20230101);
      expect(json["createdBy"], "UserX");
      expect(json["updatedDate"], 20230102);
      expect(json["updatedBy"], "UserY");
      expect(json["cbrbClasification"], "Class A");
      expect(json["tradedCountryList"], ["GBR", "DEU"]);
      expect(json["cbdCBRBClassification"], "CBD Class A");
      expect(json["borrowRelnDateEditable"], true);
    });

    test("toJson handles null values correctly", () {
      final customerInfo = CustomerInformation();
      final json = customerInfo.toJson();

      expect(json["custInfoId"], null);
      expect(json["applicationRefNo"], null);
      expect(json["customerRimNumber"], null);
      expect(json["customerName"], null);
      expect(json["groupName"], null);
      expect(json["groupId"], null);
      expect(json["legalStatus"], null);
      expect(json["tradeLicenseNumber"], null);
      expect(json["tlIssuingAuthority"], null);

      expect(json["industryDescription"], null);
      expect(json["industrySicCode"], null);
      expect(json["incorporateCountry"], null);
      expect(json["businessCountryList"], null);

      expect(json["healthCode"], null);
      expect(json["purpose"], null);
      expect(json["cccStatus"], null);
      expect(json["locationAddress"], null);
      expect(json["correspondanceAddress"], null);
      expect(json["customerOwnerShipInfoList"], null);
      expect(json["exceptionList"], null);
      expect(json["createdDate"], null);
      expect(json["createdBy"], null);
      expect(json["updatedDate"], null);
      expect(json["updatedBy"], null);
      expect(json["cbrbClasification"], null);
      expect(json["tradedCountryList"], null);
      expect(json["cbdCBRBClassification"], null);
      expect(json["borrowRelnDateEditable"], null);
      expect(json["countryOfBusiness"], null);
      expect(json["countryTradedWith"], null);
      expect(json["existingcode"], null);
      expect(json["primaryBussinessActivity"], null);
      expect(json["accountLevelSicCode"], null);
    });
  });

  group("CustomerOwnerShipInfo", () {
    test("fromJson creates a valid CustomerOwnerShipInfo object", () {
      final Map<String, dynamic> json = {
        "custOwnId": 1,
        "custOwnershipName": "Owner 1",
        "custOwnershipRim": 1001,
        "rim": 2001,
        "nationality": "US",
        "shareHoldingPercentage": 50,
        "resident": "Yes",
        "beneficialOwnerhipPercentage": 50,
        "identificationDetail": "Passport",
        "identificationNumber": "ID001",
        "createdDate": 20230101,
        "createdBy": "UserA",
        "updatedDate": 20230102,
        "updatedBy": "UserB",
        "custOwnershipType": "Individual",
      };

      final ownerInfo = CustomerOwnerShipInfo.fromJson(json);

      expect(ownerInfo.custOwnId, 1);
      expect(ownerInfo.custOwnershipName, "Owner 1");
      expect(ownerInfo.custOwnershipRim, 1001);
      expect(ownerInfo.rim, 2001);
      expect(ownerInfo.nationality, "US");
      expect(ownerInfo.shareHoldingPercentage, 50);
      expect(ownerInfo.resident, "Yes");
      expect(ownerInfo.beneficialOwnerhipPercentage, 50);
      expect(ownerInfo.identificationDetail, "Passport");
      expect(ownerInfo.identificationNumber, "ID001");
      expect(ownerInfo.createdDate, 20230101);
      expect(ownerInfo.createdBy, "UserA");
      expect(ownerInfo.updatedDate, 20230102);
      expect(ownerInfo.updatedBy, "UserB");
      expect(ownerInfo.custOwnershipType, "Individual");
    });

    test("toJson converts a CustomerOwnerShipInfo object to JSON", () {
      final ownerInfo = CustomerOwnerShipInfo(
        custOwnId: 1,
        custOwnershipName: "Owner 1",
        custOwnershipRim: 1001,
        rim: 2001,
        nationality: "US",
        shareHoldingPercentage: 50,
        resident: "Yes",
        beneficialOwnerhipPercentage: 50,
        identificationDetail: "Passport",
        identificationNumber: "ID001",
        createdDate: 20230101,
        createdBy: "UserA",
        updatedDate: 20230102,
        updatedBy: "UserB",
      );

      final json = ownerInfo.toJson();

      expect(json["custOwnId"], 1);
      expect(json["custOwnershipName"], "Owner 1");
      expect(json["custOwnershipRim"], 1001);
      expect(json["rim"], 2001);
      expect(json["nationality"], "US");
      expect(json["shareHoldingPercentage"], 50);
      expect(json["resident"], "Yes");
      expect(json["beneficialOwnerhipPercentage"], 50);
      expect(json["identificationDetail"], "Passport");
      expect(json["identificationNumber"], "ID001");
      expect(json["createdDate"], 20230101);
      expect(json["createdBy"], "UserA");
      expect(json["updatedDate"], 20230102);
      expect(json["updatedBy"], "UserB");
    });

    test("fromJson handles null values correctly", () {
      final Map<String, dynamic> json = {};
      final ownerInfo = CustomerOwnerShipInfo.fromJson(json);

      expect(ownerInfo.custOwnId, null);
      expect(ownerInfo.custOwnershipName, null);
      expect(ownerInfo.custOwnershipRim, null);
      expect(ownerInfo.rim, null);
      expect(ownerInfo.nationality, null);
      expect(ownerInfo.shareHoldingPercentage, null);
      expect(ownerInfo.resident, null);
      expect(ownerInfo.beneficialOwnerhipPercentage, null);
      expect(ownerInfo.identificationDetail, null);
      expect(ownerInfo.identificationNumber, null);
      expect(ownerInfo.createdDate, null);
      expect(ownerInfo.createdBy, null);
      expect(ownerInfo.updatedDate, null);
      expect(ownerInfo.updatedBy, null);
      expect(ownerInfo.custOwnershipType, null);
    });

    test("toJson handles null values correctly", () {
      final ownerInfo = CustomerOwnerShipInfo();
      final json = ownerInfo.toJson();

      expect(json["custOwnId"], null);
      expect(json["custOwnershipName"], null);
      expect(json["custOwnershipRim"], null);
      expect(json["rim"], null);
      expect(json["nationality"], null);
      expect(json["shareHoldingPercentage"], null);
      expect(json["resident"], null);
      expect(json["beneficialOwnerhipPercentage"], null);
      expect(json["identificationDetail"], null);
      expect(json["identificationNumber"], null);
      expect(json["createdDate"], null);
      expect(json["createdBy"], null);
      expect(json["updatedDate"], null);
      expect(json["updatedBy"], null);
      expect(json["custOwnershipType"], null);
    });
  });

  group("CustomerException", () {
    test("fromJson creates a valid CustomerException object", () {
      final Map<String, dynamic> json = {
        "type": "TypeA",
        "facilityId": 1,
        "description": "Exception A",
        "dueDate": 20240630,
        "status": "Open",
        "recommendations": "Rec A",
        "delete": false,
      };

      final exception = CustomerException.fromJson(json);

      expect(exception.type, "TypeA");
      expect(exception.facilityId, 1);
      expect(exception.description, "Exception A");
      expect(exception.dueDate, 20240630);
      expect(exception.status, "Open");
      expect(exception.recommendations, "Rec A");
      expect(exception.delete, false);
    });

    test("toJson converts a CustomerException object to JSON", () {
      final exception = CustomerException(
        type: "TypeA",
        facilityId: 1,
        description: "Exception A",
        dueDate: 20240630,
        status: "Open",
        recommendations: "Rec A",
        delete: false,
      );

      final json = exception.toJson();

      expect(json["type"], "TypeA");
      expect(json["facilityId"], 1);
      expect(json["description"], "Exception A");
      expect(json["dueDate"], 20240630);
      expect(json["status"], "Open");
      expect(json["recommendations"], "Rec A");
      expect(json["delete"], false);
    });

    test("fromJson handles null values correctly", () {
      final Map<String, dynamic> json = {};
      final exception = CustomerException.fromJson(json);

      expect(exception.type, null);
      expect(exception.facilityId, null);
      expect(exception.description, null);
      expect(exception.dueDate, null);
      expect(exception.status, null);
      expect(exception.recommendations, null);
      expect(exception.delete, null);
    });

    test("toJson handles null values correctly", () {
      final exception = CustomerException();
      final json = exception.toJson();

      expect(json["type"], null);
      expect(json["facilityId"], null);
      expect(json["description"], null);
      expect(json["dueDate"], null);
      expect(json["status"], null);
      expect(json["recommendations"], null);
      expect(json["delete"], null);
    });
  });
}
