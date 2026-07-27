import "package:test/test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";

bool _isIso8601String(s) {
  if (s is! String) {
    return false;
  }
  try {
    DateTime.parse(s);
    return true;
  } on Object catch (_) {
    return false;
  }
}

void main() {
  group("CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo", () {
    test("parses full JSON correctly (happy path)", () {
      final json = <String, dynamic>{
        "ccsysCustomerId": 41,
        "rimNo": 1023564,
        "groupId": 0,
        "customerName": "RIM NO 1023564",
        "groupName": null,
        "borrowerSubsidiary": "N", // -> false
        "groupUltimateParent": "NA",
        "groupImmediateParent": "NA",
        "legalEntityIdentifier": "Y", // -> true
        "leiNumber": "NA",
        "emiEst": "NA",
        "emiLic": "NA",
        "capital": "10000000.0",
        "turnover": "10000000.0",
        "auditor": "TEST AUDITOR",
        "dateAuditedFs": "2025-11-26T20:00:00.000Z",
        "numberOfEmployee": 180,
        "countryOfRiskFundUtilization": "Saudi Arabia,  UAE , , Oman",
        "appRefNo": "202601APNCS000687",
        "ccsysCustomerPartnerShareholderList": [
          {
            "ccsysCustomerPartnerShareholderId": 41,
            "ccsysCustomerId": 41,
            "partnerShareholderInEnglish": "TEST PARTNER",
            "partnerShareholderResidence": "RE",
            "partnerShareholderType": "SH2",
            "shareholdingPartnershipPercentage": 40,
            "networthPartnerShareholderAed": "100000000",
            "legalStatusOfPartnerShareholder": "NP",
            "emiratesIdPartnerShareholder": "1000987",
            "emiratesIdExpiryDatePartnerShareholder":
                "2025-11-29T00:00:00.000Z",
            "passportNumberPartnerShareholder": null,
            "passportNumberExpiryDatePartnerShareholder": null,
            "nationalityPartnerShareholder": "Saudi Arabia",
            "tradeLicenseNumberPartnerShareholder": null,
            "placeIssueTradeLicenseNumberPartnerShareholder": null,
            "psLei": "N",
            "leiNumberPartnerShareholder": null,
            "gender": "Male",
          }
        ],
      };

      final model = CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(json);
      expect(model.ccsysCustomerId, 41);
      expect(model.rimNo, 1023564);
      expect(model.groupId, 0);
      expect(model.customerName, "RIM NO 1023564");
      expect(model.groupName, isNull);
      expect(model.borrowerSubsidiary, isFalse);
      expect(model.groupUltimateParent, "NA");
      expect(model.groupImmediateParent, "NA");
      expect(model.legalEntityIdentifier, isTrue);
      expect(model.leiNumber, "NA");
      expect(model.emiEst, "NA");
      expect(model.emiLic, "NA");
      expect(model.capital, "10000000.0");
      expect(model.turnover, "10000000.0");
      expect(model.auditor, "TEST AUDITOR");
      expect(model.dateAuditedFs, isA<DateTime>());
      expect(model.numberOfEmployee, 180);
      expect(model.appRefNo, "202601APNCS000687");

      // countryOfRiskFundUtilization -> parsed and trimmed, empty segments
      // removed
      final countries = model.countryOfRiskFundUtilization ?? [];
      expect(countries.length, 3);
      expect(
        countries.map((c) => c.name),
        containsAll(["Saudi Arabia", "UAE", "Oman"]),
      );

      // nested list parsed
      final partners = model.ccsysCustomerPartnerShareholderList ?? [];
      expect(partners.length, 1);
      final p = partners.first;
      expect(p.ccsysCustomerPartnerShareholderId, 41);
      expect(p.ccsysCustomerId, 41);
      expect(p.partnerShareholderInEnglish, "TEST PARTNER");
      expect(p.partnerShareholderResidence, "RE");
      expect(p.partnerShareholderType, "SH2");
      expect(p.shareholdingPartnershipPercentage, 40);
      expect(p.networthPartnerShareholderAed, "100000000");
      expect(p.legalStatusOfPartnerShareholder, "NP");
      expect(p.emiratesIdPartnerShareholder, "1000987");
      expect(p.emiratesIdExpiryDatePartnerShareholder, isA<DateTime>());
      expect(p.passportNumberPartnerShareholder, isNull);
      expect(p.passportNumberExpiryDatePartnerShareholder, isNull);
      expect(p.nationalityPartnerShareholder, "Saudi Arabia");
      expect(p.tradeLicenseNumberPartnerShareholder, isNull);
      expect(p.placeIssueTradeLicenseNumberPartnerShareholder, isNull);
      expect(p.psLei, "N");
      expect(p.leiNumberPartnerShareholder, isNull);
      expect(p.gender, "Male");
    });

    test("handles nulls and empty strings", () {
      final json = <String, dynamic>{
        "ccsysCustomerId": null,
        "rimNo": null,
        "groupId": null,
        "customerName": null,
        "groupName": null,
        "borrowerSubsidiary": null, // -> false
        "groupUltimateParent": null,
        "groupImmediateParent": null,
        "legalEntityIdentifier": null, // -> false
        "leiNumber": null,
        "emiEst": null,
        "emiLic": null,
        "capital": null,
        "turnover": null,
        "auditor": null,
        "dateAuditedFs": "", // -> null
        "numberOfEmployee": null,
        "countryOfRiskFundUtilization": null, // -> []
        "appRefNo": null,
        "ccsysCustomerPartnerShareholderList": null, // -> []
      };

      final model = CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(json);
      expect(model.ccsysCustomerId, isNull);
      expect(model.rimNo, isNull);
      expect(model.groupId, isNull);
      expect(model.customerName, isNull);
      expect(model.groupName, isNull);
      expect(model.borrowerSubsidiary, isFalse);
      expect(model.legalEntityIdentifier, isFalse);
      expect(model.dateAuditedFs, isNull);
      expect(model.countryOfRiskFundUtilization, isEmpty);
      expect(model.ccsysCustomerPartnerShareholderList, isEmpty);
    });
  });

  group("CcsysCustomerInformation.toJsonGetCCSYSCustomerInfo", () {
    test("serializes correctly including nested list and audit fields", () {
      final model = CcsysCustomerInformation(
        ccsysCustomerId: 41,
        rimNo: 1023564,
        groupId: 0,
        customerName: "RIM NO 1023564",
        groupName: "G",
        borrowerSubsidiary: true, // -> 'Y'
        groupUltimateParent: "NA",
        groupImmediateParent: "NA",
        legalEntityIdentifier: false, // -> 'N'
        leiNumber: "NA",
        emiEst: "NA",
        emiLic: "NA",
        capital: "10000000.0",
        turnover: "10000000.0",
        auditor: "TEST AUDITOR",
        dateAuditedFs: DateTime.parse("2025-11-26T20:00:00.000Z"),
        numberOfEmployee: 180,
        countryOfRiskFundUtilization: [
          Reference(name: "Saudi Arabia"),
          Reference(name: "UAE"),
        ],
        appRefNo: "202601APNCS000687",
        ccsysCustomerPartnerShareholderList: [
          PartnerShareholder(
            ccsysCustomerPartnerShareholderId: 41,
            ccsysCustomerId: 41,
            partnerShareholderInEnglish: "TEST PARTNER",
            partnerShareholderResidence: "RE",
            partnerShareholderType: "SH2",
            shareholdingPartnershipPercentage: 40,
            networthPartnerShareholderAed: "100000000",
            legalStatusOfPartnerShareholder: "NP",
            emiratesIdPartnerShareholder: "1000987",
            emiratesIdExpiryDatePartnerShareholder:
                DateTime.parse("2025-11-29T00:00:00.000Z"),
            nationalityPartnerShareholder: "Saudi Arabia",
            psLei: "N",
            gender: "Male",
          ),
        ],
      );

      final map = model.toJsonGetCCSYSCustomerInfo();
      expect(map["ccsysCustomerId"], 41);
      expect(map["borrowerSubsidiary"], "Y"); // true -> 'Y'
      expect(map["legalEntityIdentifier"], "N"); // false -> 'N'
      expect(map["dateAuditedFs"], "2025-11-26T20:00:00.000Z");
      expect(map["countryOfRiskFundUtilization"], "Saudi Arabia, UAE");

      // partner list -> toJson
      final list = map["ccsysCustomerPartnerShareholderList"] as List<dynamic>?;
      expect(list, isNotNull);
      expect(list!.length, 1);
      final p = list.first as Map<String, dynamic>;
      expect(p["partnerShareholderInEnglish"], "TEST PARTNER");
      expect(
        p["emiratesIdExpiryDatePartnerShareholder"],
        "2025-11-29T00:00:00.000Z",
      );

      // Audit fields exist and are ISO strings (created/updated dates are dynamic)
      expect(map.containsKey("createdBy"), isTrue);
      expect(map.containsKey("updatedBy"), isTrue);
      expect(map.containsKey("createdDate"), isTrue);
      expect(map.containsKey("updatedDate"), isTrue);
      expect(_isIso8601String(map["createdDate"]), isTrue);
      expect(_isIso8601String(map["updatedDate"]), isTrue);
    });

    test("handles empty countries and null list", () {
      final model = CcsysCustomerInformation(
        borrowerSubsidiary: false,
        legalEntityIdentifier: false,
        countryOfRiskFundUtilization: [], // -> ''
      );
      final map = model.toJsonGetCCSYSCustomerInfo();
      expect(map["borrowerSubsidiary"], "N");
      expect(map["legalEntityIdentifier"], "N");
      expect(map["dateAuditedFs"], isNull);
      expect(map["countryOfRiskFundUtilization"], "");
      expect(map["ccsysCustomerPartnerShareholderList"], isNull);
    });
  });

  group("CcsysCustomerInformation.fromJson (secondary) + toJson", () {
    test("maps nullable Reference fields safely and serializes basics", () {
      final json = <String, dynamic>{
        "auditor": "A1",
        "borrowingSubsidiary": null, // Reference? -> null
        "capital": "123.0",
        "dateAuditedFS": 1700000000, // int (kept as-is in this ctor)
        "emirateLicense": "LIC",
        "emirateEstablishment": "EST",
        "emiratesIdExpiry": 1700000001,
        "emiratesIdPartner": "EID",
        "gender": null,
        "groupImmediateParent": "GIP",
        "groupUltimateParent": "GUP",
        "legalEntityIdentifier": true,
        "legalStatusPartners": "LSP",
        "leiNumberPartner": "LEIP",
        "leiNumber": "LEI",
        "residencyStatus": null,
        "nationalityPartner": null,
        "networkPartner": "NET",
        "numberEmployees": 42,
        "turnOver": "345.67", // note the different casing (turnOver)
        "tradeLicenseNumber": "TL",
        "shareholding": 12.34,
        "shareholderType": null,
        "placeOfIssue": null,
        "passportNumber": "P123",
        "passportExpiryDate": 1700000002,
        "partnerShareholderResidence": null,
        "partnerEng": "ENG",
        "radioButtonItems": null,
      };

      final model = CcsysCustomerInformation.fromJson(json);
      expect(model.auditor, "A1");
      expect(model.borrowingSubsidiary, isNull); // in this ctor it's Reference?
      expect(model.capital, "123.0");
      expect(model.dateAuditedFS, 1700000000);
      expect(model.emirateLicense, "LIC");
      expect(model.emirateEstablishment, "EST");
      expect(model.emiratesIdExpiry, 1700000001);
      expect(model.emiratesIdPartner, "EID");
      expect(model.gender, isNull);
      expect(model.groupImmediateParent, "GIP");
      expect(model.groupUltimateParent, "GUP");
      expect(model.legalEntityIdentifier, true);
      expect(model.legalStatusPartners, "LSP");
      expect(model.leiNumberPartner, "LEIP");
      expect(model.leiNumber, "LEI");
      expect(model.residencyStatus, isNull);
      expect(model.nationalityPartner, isNull);
      expect(model.networkPartner, "NET");
      expect(model.numberEmployees, 42);
      expect(model.turnover, "345.67");
      expect(model.tradeLicenseNumber, "TL");
      expect(model.shareholding, 12.34);
      expect(model.shareholderType, isNull);
      expect(model.placeOfIssue, isNull);
      expect(model.passportNumber, "P123");
      expect(model.passportExpiryDate, 1700000002);
      expect(model.partnerShareholderResidence, isNull);
      expect(model.partnerEng, "ENG");
      expect(model.radioButtonItems, isNull);

      final map = model.toJson();
      expect(map["auditor"], "A1");
      expect(map["borrowingSubsidiary"], isNull);
      expect(map["capital"], "123.0");
      expect(map["dateAuditedFS"], 1700000000);
      expect(map["emirateLicense"], "LIC");
      expect(map["emirateEstablishment"], "EST");
      expect(map["emiratesIdExpiry"], 1700000001);
      expect(map["emiratesIdPartner"], "EID");
      expect(map["gender"], isNull);
      expect(map["groupImmediateParent"], "GIP");
      expect(map["groupUltimateParent"], "GUP");
      expect(map["legalEntityIdentifier"], true);
      expect(map["legalStatusPartners"], "LSP");
      expect(map["leiNumberPartner"], "LEIP");
      expect(map["leiNumber"], "LEI");
      expect(map["residencyStatus"], isNull);
      expect(map["nationalityPartner"], isNull);
      expect(map["networkPartner"], "NET");
      expect(map["numberEmployees"], 42);
      expect(map["turnOver"], "345.67");
      expect(map["tradeLicenseNumber"], "TL");
      expect(map["shareholding"], 12.34);
      expect(map["shareholderType"], isNull);
      expect(map["placeOfIssue"], isNull);
      expect(map["passportNumber"], "P123");
      expect(map["passportExpiryDate"], 1700000002);
      expect(map["partnerShareholderResidence"], isNull);
      expect(map["partnerEng"], "ENG");
      expect(map["radioButtonItems"], isNull);
    });
  });

  group("PartnerShareholder.fromJson & toJson", () {
    test("parses and serializes all fields", () {
      final json = <String, dynamic>{
        "ccsysCustomerPartnerShareholderId": 41,
        "ccsysCustomerId": 41,
        "partnerShareholderInEnglish": "TEST PARTNER",
        "partnerShareholderResidence": "RE",
        "partnerShareholderType": "SH2",
        "shareholdingPartnershipPercentage": 40,
        "networthPartnerShareholderAed": "100000000",
        "legalStatusOfPartnerShareholder": "NP",
        "emiratesIdPartnerShareholder": "1000987",
        "emiratesIdExpiryDatePartnerShareholder": "2025-11-29T00:00:00.000Z",
        "passportNumberPartnerShareholder": null,
        "passportNumberExpiryDatePartnerShareholder": null,
        "nationalityPartnerShareholder": "Saudi Arabia",
        "tradeLicenseNumberPartnerShareholder": null,
        "placeIssueTradeLicenseNumberPartnerShareholder": null,
        "psLei": "N",
        "leiNumberPartnerShareholder": null,
        "gender": "Male",
      };

      final p = PartnerShareholder.fromJson(json);
      expect(p.ccsysCustomerPartnerShareholderId, 41);
      expect(p.ccsysCustomerId, 41);
      expect(p.partnerShareholderInEnglish, "TEST PARTNER");
      expect(p.partnerShareholderResidence, "RE");
      expect(p.partnerShareholderType, "SH2");
      expect(p.shareholdingPartnershipPercentage, 40);
      expect(p.networthPartnerShareholderAed, "100000000");
      expect(p.legalStatusOfPartnerShareholder, "NP");
      expect(p.emiratesIdPartnerShareholder, "1000987");
      expect(p.emiratesIdExpiryDatePartnerShareholder, isA<DateTime>());
      expect(p.passportNumberPartnerShareholder, isNull);
      expect(p.passportNumberExpiryDatePartnerShareholder, isNull);
      expect(p.nationalityPartnerShareholder, "Saudi Arabia");
      expect(p.tradeLicenseNumberPartnerShareholder, isNull);
      expect(p.placeIssueTradeLicenseNumberPartnerShareholder, isNull);
      expect(p.psLei, "N");
      expect(p.leiNumberPartnerShareholder, isNull);
      expect(p.gender, "Male");

      final map = p.toJson();
      expect(map["ccsysCustomerPartnerShareholderId"], 41);
      expect(map["ccsysCustomerId"], 41);
      expect(map["partnerShareholderInEnglish"], "TEST PARTNER");
      expect(
        map["emiratesIdExpiryDatePartnerShareholder"],
        "2025-11-29T00:00:00.000Z",
      );
      // Audit fields exist
      expect(map.containsKey("createdBy"), isTrue);
      expect(map.containsKey("updatedBy"), isTrue);
      expect(map.containsKey("createdDate"), isTrue);
      expect(map.containsKey("updatedDate"), isTrue);
      expect(_isIso8601String(map["createdDate"]), isTrue);
      expect(_isIso8601String(map["updatedDate"]), isTrue);
    });

    test("date parsing returns null for empty strings", () {
      final json = <String, dynamic>{
        "ccsysCustomerPartnerShareholderId": 1,
        "ccsysCustomerId": 1,
        "partnerShareholderInEnglish": "X",
        "partnerShareholderResidence": "R",
        "partnerShareholderType": "T",
        "shareholdingPartnershipPercentage": 10,
        "networthPartnerShareholderAed": "100",
        "legalStatusOfPartnerShareholder": "L",
        "emiratesIdPartnerShareholder": "E",
        "emiratesIdExpiryDatePartnerShareholder": "", // -> null
        "passportNumberPartnerShareholder": "P",
        "passportNumberExpiryDatePartnerShareholder": "", // -> null
        "nationalityPartnerShareholder": "N",
        "tradeLicenseNumberPartnerShareholder": "TL",
        "placeIssueTradeLicenseNumberPartnerShareholder": "PI",
        "psLei": "Y",
        "leiNumberPartnerShareholder": "LEI",
        "gender": "M",
      };

      final p = PartnerShareholder.fromJson(json);
      expect(p.emiratesIdExpiryDatePartnerShareholder, isNull);
      expect(p.passportNumberExpiryDatePartnerShareholder, isNull);
    });
  });
}
