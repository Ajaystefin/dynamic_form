import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/certification_data.dart";

void main() {
  group("CertificationData", () {
    test("should create CertificationData instance with all properties", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final selectedOption = Reference(
        id: 2,
        name: "Option A",
        reference1: "OPT001",
      );

      final certificationData = CertificationData(
        appCertificationId: 123,
        certificateInformation: certificateInfo,
        selectedOption: selectedOption,
        remarks: "Test remarks",
        certificationCategory: 1,
      );

      expect(certificationData.appCertificationId, 123);
      expect(certificationData.certificateInformation, certificateInfo);
      expect(certificationData.selectedOption, selectedOption);
      expect(certificationData.remarks, "Test remarks");
      expect(certificationData.certificationCategory, 1);
    });

    test("should create CertificationData instance with minimal properties",
        () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final certificationData = CertificationData(
        certificateInformation: certificateInfo,
      );

      expect(certificationData.appCertificationId, isNull);
      expect(certificationData.certificateInformation, certificateInfo);
      expect(certificationData.selectedOption, isNull);
      expect(certificationData.remarks, isNull);
      expect(certificationData.certificationCategory, isNull);
    });
    test("should create CertificationData from JSON with all properties", () {
      final json = {
        "appCertificationId": 123,
        "certificateInformation": {
          "referenceDataListId": 1,
          "name": "Certificate Type 1",
          "description": null,
          "isActive": true,
          "reference1": "CERT001",
          "reference2": null,
          "reference3": null,
          "reference4": null,
          "reference5": null,
          "referenceDataTypeId": null,
          "createdBy": "WCASTSP01",
          "createdDate": 1762846607259,
          "updatedBy": "wcastsp01",
          "updatedDate": 1762846607259,
          "srcMigratedId": 0,
        },
        "option": {
          "referenceDataListId": 2,
          "name": "Option A",
          "description": null,
          "isActive": false,
          "reference1": "OPT001",
          "reference2": null,
          "reference3": null,
          "reference4": null,
          "reference5": null,
          "referenceDataTypeId": null,
          "createdBy": "WCASTSP01",
          "createdDate": 1762846607259,
          "updatedBy": "wcastsp01",
          "updatedDate": 1762846607259,
          "srcMigratedId": 0,
        },
        "remarks": "Test remarks",
        "certificationCategory": 1,
      };

      final certificationData = CertificationData.fromJson(json);

      expect(certificationData.appCertificationId, 123);
      expect(certificationData.certificateInformation, isA<Reference>());
      expect(certificationData.certificateInformation.id, 1);
      expect(
        certificationData.certificateInformation.name,
        "Certificate Type 1",
      );
      expect(certificationData.certificateInformation.reference1, "CERT001");

      expect(certificationData.selectedOption, isA<Reference>());
      expect(certificationData.selectedOption!.id, 2);
      expect(certificationData.selectedOption!.name, "Option A");
      expect(certificationData.selectedOption!.reference1, "OPT001");

      expect(certificationData.remarks, "Test remarks");
      expect(certificationData.certificationCategory, 1);
      expect(certificationData.isUpdated, false); // default value
    });

    test(
        "should create CertificationData from JSON with"
        " null certificateInformation", () {
      final json = {
        "appCertificationId": 123,
        "certificateInformation": null,
        "option": null,
        "remarks": "Test remarks",
        "certificationCategory": 1,
      };

      final certificationData = CertificationData.fromJson(json);

      expect(certificationData.appCertificationId, 123);
      expect(certificationData.certificateInformation, isNotNull);
      expect(certificationData.certificateInformation.id, isNull);
      expect(certificationData.selectedOption, isNull);
      expect(certificationData.remarks, "Test remarks");
      expect(certificationData.certificationCategory, 1);
    });

    test(
        "should create "
        "CertificationData from "
        "JSON with missing certificateInformation", () {
      final json = {
        "appCertificationId": 123,
        "option": null,
        "remarks": "Test remarks",
        "certificationCategory": 1,
      };

      final certificationData = CertificationData.fromJson(json);

      expect(certificationData.appCertificationId, 123);
      expect(certificationData.certificateInformation, isNotNull);
      expect(certificationData.certificateInformation.id, isNull);
      expect(certificationData.selectedOption, isNull);
      expect(certificationData.remarks, "Test remarks");
      expect(certificationData.certificationCategory, 1);
    });
    test("should convert CertificationData to JSON with all properties", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final selectedOption = Reference(
        id: 2,
        name: "Option A",
        reference1: "OPT001",
      );

      final certificationData = CertificationData(
        appCertificationId: 123,
        certificateInformation: certificateInfo,
        selectedOption: selectedOption,
        remarks: "Test remarks",
        certificationCategory: 1,
      );

      final json = certificationData.toJson();

      expect(json["appCertificationId"], 123);
      expect(json["certificateInformation"], isA<Map<String, dynamic>>());
      expect(json["certificateInformation"]["referenceDataListId"], 1);
      expect(json["certificateInformation"]["name"], "Certificate Type 1");
      expect(json["certificateInformation"]["reference1"], "CERT001");

      expect(json["option"], isA<Map<String, dynamic>>());
      expect(json["option"]["referenceDataListId"], 2);
      expect(json["option"]["name"], "Option A");
      expect(json["option"]["reference1"], "OPT001");

      expect(json["remarks"], "Test remarks");
      expect(json["certificationCategory"], 1);
    });

    test("should convert CertificationData to JSON with null properties", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final certificationData = CertificationData(
        certificateInformation: certificateInfo,
      );

      final json = certificationData.toJson();

      expect(json["appCertificationId"], isNull);
      expect(json["option"], isNull);
      expect(json["remarks"], isNull);
      expect(json["certificationCategory"], isNull);
    });

    test("should handle different data types in JSON conversion", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final certificationData = CertificationData(
        appCertificationId: 123,
        certificateInformation: certificateInfo,
        selectedOption: null,
        remarks: r"Test remarks with special chars: !@#$%^&*()",
        certificationCategory: 999,
      );

      final json = certificationData.toJson();

      expect(json["appCertificationId"], 123);
      expect(json["option"], isNull);
      expect(json["remarks"], r"Test remarks with special chars: !@#$%^&*()");
      expect(json["certificationCategory"], 999);
    });

    test("should handle empty string values in JSON", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final certificationData = CertificationData(
        appCertificationId: 123,
        certificateInformation: certificateInfo,
        selectedOption: null,
        remarks: "",
        certificationCategory: 0,
      );

      final json = certificationData.toJson();

      expect(json["appCertificationId"], 123);
      expect(json["option"], isNull);
      expect(json["remarks"], "");
      expect(json["certificationCategory"], 0);
    });

    test("should handle large integer values", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final certificationData = CertificationData(
        appCertificationId: 999999999,
        certificateInformation: certificateInfo,
        selectedOption: null,
        remarks: "Large ID test",
        certificationCategory: 999999,
      );

      final json = certificationData.toJson();

      expect(json["appCertificationId"], 999999999);
      expect(json["certificationCategory"], 999999);
      expect(json["remarks"], "Large ID test");
    });

    test("should handle negative values", () {
      final certificateInfo = Reference(
        id: 1,
        name: "Certificate Type 1",
        reference1: "CERT001",
      );

      final certificationData = CertificationData(
        appCertificationId: -123,
        certificateInformation: certificateInfo,
        selectedOption: null,
        remarks: "Negative values test",
        certificationCategory: -1,
      );

      final json = certificationData.toJson();

      expect(json["appCertificationId"], -123);
      expect(json["certificationCategory"], -1);
      expect(json["remarks"], "Negative values test");
    });
  });
}
