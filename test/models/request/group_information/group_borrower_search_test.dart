import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/group_information/group_borrower_search.dart";

void main() {
  group("GroupBorrowerSearchResponse & nested models", () {
    test("fromJson minimal: {responseData: {PartyId}}", () {
      final Map<String, dynamic> json = {
        "responseData": {
          "PartyId": "MIN123",
        },
      };

      final model = GroupBorrowerSearchResponse.fromJson(json);

      expect(model, isA<GroupBorrowerSearchResponse>());
      expect(model.responseData, isA<ResponseData>());
      expect(model.responseData!.partyId, "MIN123");
      // Absent branches stay null
      expect(model.responseData!.partyInfo, isNull);
      expect(model.responseData!.groupKeys, isNull);
    });

    test("fromJson rich nested: lists & deep fields live under PartyInfo", () {
      final Map<String, dynamic> json = {
        "responseData": {
          "PartyId": "1124512",
          "PartyInfo": {
            "PartyIdType": "",
            "ClassCode": "",
            "PersonData": {
              "PersonName": {
                "NamePrefix": "",
                "FirstName": "John",
                "MiddleName": "Q",
                "LastName": "RIM NO 1124512",
              },
              "Contact": {
                "Locator": {
                  "PostAddr": {
                    "AddressIdent": "ADDR-1",
                    "Addr1": "Line 1",
                    "Addr2": "Line 2",
                    "city": "Dubai",
                    "country": "AE",
                  },
                  "PhoneNum": [
                    {"PhoneType": "MOBILE", "Phone": "0500000000"},
                  ],
                  "Email": [
                    {"EmailType": "WORK", "EmailAddr": "test@example.com"},
                  ],
                },
              },
            },
            "IssuedIdent": [
              {
                "IssuedIdentName": "EID",
                "IssuedIdentValue": "784-XXXX-XXXXXXX-X",
              }
            ],
            "Nationality": [
              "784",
              null,
            ], // will become ['784', 'null'] in model
            "Segmentation": {"SegmentDesc": "Retail"},
            "FatcaDetails": {"USResidentStatus": "N"},
            "PartyAffiliateData": {
              "OrgName": "Org Inc.",
              "RelEstablishedDt": "",
              "OrgContact": {
                "Locator": {
                  "PostAddr": {
                    "AddressIdent": "ORG-ADDR",
                    "Addr1": "Org Street",
                    "country": "AE",
                  },
                },
              },
            },
            "FinancialData": {
              "FinancialType": "INCOME",
              "FinancialAmt": 12345,
              "RelEstablishedDt": "2024-01-01",
            },
            "RelationshipMgr": [
              {
                "RelationshipMgrIdent": "RM01",
                "RelationshipMgrName": "Alice RM",
              }
            ],
            "CreditRisk": {"RiskCategory": "Low", "InternalScore": "A"},
            "ListedStockExchange": "0",
            "StockMarket": "0",
          },
          "GroupKeys": {
            "GroupId": "G1",
            "GroupOwner": "Owner1",
            "GroupName": "Group One",
            "GroupStatus": "Active",
          },
        },
      };

      final model = GroupBorrowerSearchResponse.fromJson(json);
      expect(model.responseData!.partyId, "1124512");
      final pn = model.responseData!.partyInfo!.personData!.personName!;
      expect(pn.firstName, "John");
      expect(pn.middleName, "Q");
      expect(pn.lastName, "RIM NO 1124512");
      final locator =
          model.responseData!.partyInfo!.personData!.contact!.locator!;
      expect(locator.postAddr!.city, "Dubai");
      expect(locator.postAddr!.country, "AE");
      expect(locator.phoneNum.length, 1);
      expect(locator.phoneNum[0].phoneType, "MOBILE");
      expect(locator.phoneNum[0].phone, "0500000000");
      expect(locator.email.length, 1);
      expect(locator.email[0].emailType, "WORK");
      expect(locator.email[0].emailAddr, "test@example.com");

      final pi = model.responseData!.partyInfo!;
      expect(pi.issuedIdent.length, 1);
      expect(pi.issuedIdent[0].issuedIdentName, "EID");

      expect(pi.nationality.length, 2);

      expect(pi.segmentation!.segmentDesc, "Retail");
      expect(pi.fatcaDetails!.usResidentStatus, "N");
      expect(pi.partyAffiliateData!.orgName, "Org Inc.");
      expect(pi.financialData!.financialType, "INCOME");
      expect(pi.financialData!.financialAmt, 12345);

      expect(pi.relationshipMgr.length, 1);
      expect(pi.relationshipMgr[0].relationshipMgrName, "Alice RM");

      expect(pi.creditRisk!.riskCategory, "Low");
      final gk = model.responseData!.groupKeys!;
      expect(gk.groupId, "G1");
      expect(gk.groupOwner, "Owner1");
      expect(gk.groupName, "Group One");
      expect(gk.groupStatus, "Active");
    });

    test("handles absent/empty lists gracefully (wrong element types too)", () {
      final Map<String, dynamic> json = {
        "responseData": {
          "PartyId": "X1",
          "PartyInfo": {
            "PersonData": {
              "PersonName": {"LastName": ""},
              "Contact": {
                "Locator": {
                  "PostAddr": {"country": "AE"},
                  "PhoneNum": ["not-a-map"],
                  "Email": [42, true, null],
                },
              },
            },
            "IssuedIdent": ["oops"],
            "RelationshipMgr": ["oops"],
            "Nationality": [], // explicit empty list is OK
          },
        },
      };

      final model = GroupBorrowerSearchResponse.fromJson(json);

      final pi = model.responseData!.partyInfo!;
      final locator = pi.personData!.contact!.locator!;

      expect(locator.phoneNum, isEmpty);
      expect(locator.email, isEmpty);
      expect(pi.issuedIdent, isEmpty);
      expect(pi.relationshipMgr, isEmpty);
      expect(pi.nationality, isEmpty);
    });

    test("toJson round-trip of a fully populated object", () {
      final model = GroupBorrowerSearchResponse(
        responseData: ResponseData(
          partyId: "P123",
          partyInfo: PartyInfo(
            partyIdType: "PID",
            classCode: "CC",
            classCodeDesc: "Desc",
            partyStatus: "Active",
            originatingBranchCode: "BR01",
            originatingBranchName: "Main",
            issuingAuthority: "Auth",
            annualTurnover: "100M",
            idType: "EID",
            netWorth: "1B",
            organizationType: "ORG",
            commercialActivity: "Retail",
            registrationOffice: "Dubai",
            listedStockExchange: "0",
            stockMarket: "0",
            emplCategory: "A",
            monthlyDeposit: "1000",
            pepCategoryId: "N",
            personData: PersonData(
              personName: PersonName(
                namePrefix: "Mr",
                firstName: "First",
                middleName: "Middle",
                lastName: "Last",
                firstNameLocalLang: "F-LL",
                middleNameLocalLang: "M-LL",
                lastNameLocalLang: "L-LL",
                preferredName: "Pref",
                paternalName: "Pat",
                maternalName: "Mat",
              ),
              contact: Contact(
                locator: Locator(
                  postAddr: PostAddr(
                    addressIdent: "ID",
                    addr1: "A1",
                    addr2: "A2",
                    addr3: "A3",
                    city: "DXB",
                    country: "AE",
                    postalCode: "0000",
                  ),
                  phoneNum: [PhoneNum(phoneType: "M", phone: "050")],
                  email: [Email(emailType: "W", emailAddr: "x@y.com")],
                ),
              ),
            ),
            birthDt: "2000-01-01",
            cbdRelationshipStartDate: "2020-01-01",
            birthPlace: "DXB",
            gender: "M",
            qualification: "Grad",
            maritalStat: "S",
            occupation: "Dev",
            dependents: "0",
            issuedIdent: [
              IssuedIdent(issuedIdentName: "EID", issuedIdentValue: "784-..."),
            ],
            passportIssuedDt: "2010-01-01",
            tlExpiryDt: "2030-01-01",
            passportIssuedCountryCode: "AE",
            passportIssuedCity: "Dubai",
            emiratesIDExpiryDt: "2031-01-01",
            visaExpiryDt: "2026-01-01",
            nationality: ["784"],
            segmentation: Segmentation(segmentDesc: "Seg"),
            resident: "R",
            residentCountry: "AE",
            fatcaDetails:
                FatcaDetails(tin: "T", ssn: "S", usResidentStatus: "N"),
            partyAffiliateData: PartyAffiliateData(
              orgName: "Org",
              positionHeld: "Mgr",
              relEstablishedDt: "2022-01-01",
              orgContact: OrgContact(
                locator: Locator(
                  postAddr: PostAddr(addr1: "Org1", country: "AE"),
                  phoneNum: [],
                  email: [],
                ),
              ),
            ),
            financialData: FinancialData(
              financialType: "TYPE",
              financialAmt: 1,
              relEstablishedDt: "2024-01-01",
              incomeCurrency: "AED",
            ),
            openReason: "Reason",
            relationshipMgr: [
              RelationshipMgr(
                relationshipMgrIdent: "ID",
                relationshipMgrName: "Name",
              ),
            ],
            preferredLang: "EN",
            creditRisk: CreditRisk(riskCategory: "Low", internalScore: "A"),
            formW8: "N",
            formW9: "N",
            politicallyExposed: "N",
            tlIssueCountry: "AE",
            pepCategory: "N",
          ),
          groupKeys: GroupKeys(
            groupId: "G1",
            groupOwner: "Owner",
            groupName: "Name",
            groupStatus: "Active",
          ),
        ),
      );

      final encoded = model.toJson();
      final reparsed = GroupBorrowerSearchResponse.fromJson(encoded);

      // Spot-check a few fields across the tree to ensure round-trip integrity
      expect(reparsed.responseData!.partyId, "P123");
      final rp = reparsed.responseData!.partyInfo!;
      expect(rp.personData!.personName!.firstName, "First");
      expect(rp.personData!.contact!.locator!.postAddr!.city, "DXB");
      expect(rp.issuedIdent[0].issuedIdentName, "EID");
      expect(rp.financialData!.incomeCurrency, "AED");
      expect(reparsed.responseData!.groupKeys!.groupOwner, "Owner");
    });

    test("fromJson empty responseData yields null branches", () {
      final Map<String, dynamic> json = {"responseData": <String, dynamic>{}};

      final model = GroupBorrowerSearchResponse.fromJson(json);

      expect(model.responseData, isA<ResponseData>());
      expect(model.responseData!.partyId, isNull);
      // In your implementation, PartyInfo is null when absent
      expect(model.responseData!.partyInfo, isNull);
      expect(model.responseData!.groupKeys, isNull);
    });

    test(
        "PostAddr/PhoneNum/Email/IssuedIdent/Segmentation/FatcaDetails toJson smoke",
        () {
      final post = PostAddr(addressIdent: "ID", addr1: "A1").toJson();
      expect(post["AddressIdent"], "ID");
      expect(post["Addr1"], "A1");

      final ph = PhoneNum(phoneType: "M", phone: "050").toJson();
      expect(ph["PhoneType"], "M");
      expect(ph["Phone"], "050");

      final em = Email(emailType: "W", emailAddr: "x@y.com").toJson();
      expect(em["EmailType"], "W");
      expect(em["EmailAddr"], "x@y.com");

      final idn =
          IssuedIdent(issuedIdentName: "EID", issuedIdentValue: "VAL").toJson();
      expect(idn["IssuedIdentName"], "EID");
      expect(idn["IssuedIdentValue"], "VAL");

      final seg = Segmentation(segmentDesc: "S").toJson();
      expect(seg["SegmentDesc"], "S");

      final fat =
          FatcaDetails(tin: "T", ssn: "S", usResidentStatus: "N").toJson();
      expect(fat["TIN"], "T");
      expect(fat["SSN"], "S");
      expect(fat["USResidentStatus"], "N");
    });

    test(
        "OrgContact/Locator/FinancialData/RelationshipMgr/CreditRisk/GroupKeys toJson smoke",
        () {
      final loc = Locator(
        postAddr: PostAddr(addr1: "A1"),
        phoneNum: [PhoneNum(phoneType: "M")],
        email: [Email(emailType: "W")],
      ).toJson();

      expect((loc["PostAddr"] as Map)["Addr1"], "A1");
      expect((loc["PhoneNum"] as List).length, 1);
      expect((loc["Email"] as List).length, 1);

      final org = OrgContact(locator: Locator()).toJson();
      expect(org["Locator"], isA<Map<String, dynamic>>());

      final fin = FinancialData(financialType: "T", financialAmt: 2).toJson();
      expect(fin["FinancialType"], "T");
      expect(fin["FinancialAmt"], 2);

      final rm =
          RelationshipMgr(relationshipMgrIdent: "I", relationshipMgrName: "N")
              .toJson();
      expect(rm["RelationshipMgrIdent"], "I");
      expect(rm["RelationshipMgrName"], "N");

      final cr = CreditRisk(riskCategory: "R", internalScore: "S").toJson();
      expect(cr["RiskCategory"], "R");
      expect(cr["InternalScore"], "S");

      final gk = GroupKeys(groupId: "G").toJson();
      expect(gk["GroupId"], "G");
    });
  });
}
