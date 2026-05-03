import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

void main() {
  group("ServerConstants – primitive constants", () {
    test("service cinst test", () {
      expect(ServerConstants.defaultFacilityList, isA<List<FacilityNew>>());
    });
    test("role IDs are correct", () {
      testServerConstants();
      expect(ServerConstants.roId, 125);
      expect(ServerConstants.rmId, 126);
      expect(ServerConstants.caId, 135);
      expect(ServerConstants.tlbId, 127);
      expect(ServerConstants.camId, 128);
      expect(ServerConstants.rmbId, 129);
      expect(ServerConstants.shbId, 130);
      expect(ServerConstants.tldId, 136);
      expect(ServerConstants.ccpId, 140);
      expect(ServerConstants.bdpId, 141);
      expect(ServerConstants.bdId, 3189);
      expect(ServerConstants.ccId, 140);
      expect(ServerConstants.shlbId, 139);
      expect(ServerConstants.shlcId, 138);
      expect(ServerConstants.shldId, 137);
      expect(ServerConstants.lgtId, 3203);
      expect(ServerConstants.lmtId, 3202);
      expect(ServerConstants.ccoodId, 134);
      expect(ServerConstants.admId, 2024);
      expect(ServerConstants.inqusrId, 3251);
      expect(ServerConstants.ltId, 3203);
      expect(ServerConstants.ltcoodId, 6343);
      expect(ServerConstants.optionNAid, 1906);
      expect(ServerConstants.optionNOid, 1905);
      expect(ServerConstants.optionYESid, 1904);
      expect(ServerConstants.optionBothId, 15739);
      expect(ServerConstants.mainLimitTypeID, 280);
    });

    test("financialDescriptionTemplates", () {
      expect(
        ServerConstants.financialDescriptionTemplates,
        isA<Map<int, String>>(),
      );
    });

    test("request and admin IDs and strings are correct", () {
      expect(ServerConstants.financialInstitutionId, 14486);
      expect(ServerConstants.applicationIsolatedId, 102);
      expect(ServerConstants.applicationFullCAId, 100);
      expect(ServerConstants.applicationTypeFIOneOff, 11389);

      expect(ServerConstants.referenceDataIdTitle, "Reference Data ID");
      expect(ServerConstants.referenceNameTitle, "Name");
      expect(ServerConstants.referenceDescriptionTitle, "Description");
      expect(ServerConstants.reference1Title, "Reference 1");
      expect(ServerConstants.reference2Title, "Reference 2");
      expect(ServerConstants.reference3Title, "Reference 3");
      expect(ServerConstants.reference4Title, "Reference 4");
      expect(ServerConstants.reference5Title, "Reference 5");
      expect(ServerConstants.referenceStatusTitle, "Status");

      expect(ServerConstants.accessRightUpdate, "NW");
      expect(ServerConstants.accessRightSave, "AM");

      expect(ServerConstants.bySegmentOrRegionId, 4269);
      expect(ServerConstants.groupId, 4263);
      expect(ServerConstants.advancedRequestTypeId, 4266);
      expect(ServerConstants.customerRIMNumberId, 4262);
      expect(ServerConstants.applicationReferenceNumberId, 4261);

      expect(ServerConstants.securityStrategyCommentsType, 4255);
      expect(ServerConstants.securityAppStrategyCommentsId, 451974);
      expect(ServerConstants.securityCategoryID, 4256);
      expect(ServerConstants.securityCategoryType, "Security Perfection");
      expect(ServerConstants.appRefNo, "201902APNAR000039");
      expect(ServerConstants.rmNameId, 4264);
      expect(ServerConstants.pendingWithId, 4265);

      expect(ServerConstants.presentRequestStrategyCommentsType, 1158);
      expect(ServerConstants.presentRequestAppStrategyCommentsId, 451974);
      expect(ServerConstants.presentRequestCategoryID, 1177);
      expect(ServerConstants.presentRequestCategoryType, "PRESENT REQUEST");

      expect(ServerConstants.conditionGeneralId, 14214);
      expect(ServerConstants.conditionSpecificId, 14215);
      expect(ServerConstants.conditionStandardId, 13945);
      expect(ServerConstants.conditionCustomId, 13946);

      expect(ServerConstants.terminateCategoryID, 1842);

      expect(ServerConstants.customerName, "RIM 50");
      expect(ServerConstants.groupName, "DCMM MM");
      expect(ServerConstants.requestName, "Isolate CRPR");

      expect(ServerConstants.attachmentCertificatesID, "WCAS");

      expect(ServerConstants.groupStrategyCommentsType, 3139);
      expect(ServerConstants.groupAppStrategyCommentsId, 28);
      expect(ServerConstants.groupCategoryID, 937);
      expect(ServerConstants.groupCategoryType, "Group Information");

      expect(ServerConstants.otherBankStrategyCommentsType, 3132);
      expect(ServerConstants.otherBankAppStrategyCommentsId, 451916);
      expect(ServerConstants.otherBankCategoryID, 938);
      expect(
        ServerConstants.otherBankCategoryType,
        "Facilities with Other Bank",
      );

      expect(ServerConstants.cbrbStrategyCommentsType, 3132);
      expect(ServerConstants.cbrbAppStrategyCommentsId, 451916);
      expect(ServerConstants.cbrbCategoryID, 936);
      expect(ServerConstants.cbrbCategoryType, "Central Bank Risk Bureau Data");

      expect(ServerConstants.fiCreditRisk, 1);
      expect(ServerConstants.fiCreditRiskType, "FI Credit Application");

      expect(ServerConstants.largeExposureBreachId, 8393);
      // expect(ServerConstants.largeExposureBreachName, 'Large Exposure
      // Breach');

      expect(ServerConstants.applicationTypeCancelId, 108);
      expect(ServerConstants.applicationTypeReconsiderationId, 15813);
    });
  });

  group("ServerConstants – map constants", () {
    test("requestTypeId contains all RequestType keys with int values", () {
      const map = ServerConstants.requestTypeId;
      expect(map.keys.toSet(), RequestType.values.toSet());
      map.forEach((rt, id) => expect(id, isA<int>()));
    });

    test("applicationTypeId contains all ApplicationType keys with int values",
        () {
      const map = ServerConstants.applicationTypeId;
      expect(map.keys.toSet(), ApplicationType.values.toSet());
      map.forEach((at, id) => expect(id, isA<int>()));
    });

    test("documentTypeId contains all DocumentType keys with int values", () {
      const map = ServerConstants.documentTypeId;
      expect(map.keys.toSet(), DocumentType.values.toSet());
      map.forEach((dt, id) => expect(id, isA<int>()));
    });

    test("userRoleCode only contains valid UserRole keys with non-empty codes",
        () {
      const map = ServerConstants.userRoleCode;

      // No unexpected keys: every key must be from the UserRole enum
      expect(
        map.keys.every((key) => UserRole.values.contains(key)),
        isTrue,
        reason: "Found a key not in UserRole enum: "
            "${map.keys.toSet().difference(UserRole.values.toSet())}",
      );

      // Each code is a non-empty String
      map.forEach((role, code) {
        expect(code, isA<String>());
        expect(code, isNotEmpty);
      });
    });

    test(
        "businessSegmentId only contains valid"
        " BusinessSegment keys with int values", () {
      const map = ServerConstants.businessSegmentId;

      expect(
        map.keys.every((key) => BusinessSegment.values.contains(key)),
        isTrue,
        reason: "Unexpected BusinessSegment keys: "
            "${map.keys.toSet().difference(BusinessSegment.values.toSet())}",
      );

      map.forEach((seg, id) {
        expect(id, isA<int>());
      });
    });

    test("customerTypeId only contains valid CustomerType keys with int values",
        () {
      const map = ServerConstants.customerTypeId;

      expect(
        map.keys.every((key) => CustomerType.values.contains(key)),
        isTrue,
        reason: "Unexpected CustomerType keys: "
            "${map.keys.toSet().difference(CustomerType.values.toSet())}",
      );

      map.forEach((ct, id) {
        expect(id, isA<int>());
      });
    });

    test("commentTypeId only contains valid CommentsType keys with int values",
        () {
      const map = ServerConstants.commentTypeId;

      expect(
        map.keys.every((key) => CommentsType.values.contains(key)),
        isTrue,
        reason: "Unexpected CommentsType keys: "
            "${map.keys.toSet().difference(CommentsType.values.toSet())}",
      );

      map.forEach((ct, id) {
        expect(id, isA<int>());
      });
    });

    test("entityId only contains valid EntityIdentifier keys with int values",
        () {
      const map = ServerConstants.entityId;
      expect(
        map.keys.every((key) => EntityIdentifier.values.contains(key)),
        isTrue,
        reason: "Unexpected EntityIdentifier keys: "
            "${map.keys.toSet().difference(EntityIdentifier.values.toSet())}",
      );

      map.forEach((eid, id) {
        expect(id, isA<int>());
      });
    });

    test("covenantTypeId contains all CovenantType keys with int values", () {
      const map = ServerConstants.covenantTypeId;
      expect(map.keys.toSet(), CovenantType.values.toSet());
      map.forEach((ct, id) => expect(id, isA<int>()));
    });

    test("covenantSubTypeId contains all CovenantSubType keys with int values",
        () {
      const map = ServerConstants.covenantSubTypeId;
      expect(map.keys.toSet(), CovenantSubType.values.toSet());
      map.forEach((st, id) => expect(id, isA<int>()));
    });
  });
}
