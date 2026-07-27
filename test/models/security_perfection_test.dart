import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";

void main() {
  group("SecurityPerfection", () {
    test("should create instance with constructor values", () {
      final securityDeferralList = [
        SecurityDeferral(securityNo: "SEC001"),
      ];

      final covenantList = [
        SecurityCovenantCondition(
          number: "COV001",
          isCovenant: true,
          isChecked: true,
        ),
      ];

      final conditionList = [
        SecurityCovenantCondition(
          number: "CON001",
        ),
      ];

      final perfection = SecurityPerfection(
        securityDeferralList: securityDeferralList,
        covenant: covenantList,
        condition: conditionList,
      );

      expect(perfection.securityDeferralList, securityDeferralList);
      expect(perfection.covenant, covenantList);
      expect(perfection.condition, conditionList);
    });

    test("should create instance from JSON with all lists populated", () {
      final json = {
        "securityDeferralList": [
          {
            "securityNo": "SEC001",
            "securityMasterId": 1,
            "selected": true,
          }
        ],
        "covenantDeferralList": [
          {
            "covenantConditionNo": "COV001",
            "description": "Test Covenant",
            "deferralDate": 20260425,
            "selected": true,
            "isCovenant": true,
          }
        ],
        "conditionDeferralList": [
          {
            "covenantConditionNo": "CON001",
            "description": "Test Condition",
            "deferralDate": 20260430,
            "selected": false,
            "isCovenant": false,
          }
        ],
      };

      final perfection = SecurityPerfection.fromJson(json);

      expect(perfection.securityDeferralList, isNotNull);
      expect(perfection.covenant, isNotNull);
      expect(perfection.condition, isNotNull);

      expect(perfection.securityDeferralList!.length, 1);
      expect(perfection.covenant!.length, 1);
      expect(perfection.condition!.length, 1);

      expect(perfection.securityDeferralList!.first.securityNo, "SEC001");
      expect(perfection.securityDeferralList!.first.selected, true);

      expect(perfection.covenant!.first.number, "COV001");
      expect(perfection.covenant!.first.isCovenant, true);
      expect(perfection.covenant!.first.isChecked, true);

      expect(perfection.condition!.first.number, "CON001");
      expect(perfection.condition!.first.isCovenant, false);
      expect(perfection.condition!.first.isChecked, false);
    });

    test("should create instance from JSON with empty lists", () {
      final json = {
        "securityDeferralList": [],
        "covenantDeferralList": [],
        "conditionDeferralList": [],
      };

      final perfection = SecurityPerfection.fromJson(json);

      expect(perfection.securityDeferralList, isEmpty);
      expect(perfection.covenant, isEmpty);
      expect(perfection.condition, isEmpty);
    });

    test("should handle missing lists in JSON gracefully", () {
      final json = <String, dynamic>{};

      final perfection = SecurityPerfection.fromJson(json);

      expect(perfection.securityDeferralList, isNull);
      expect(perfection.covenant, isNull);
      expect(perfection.condition, isNull);
    });

    test("should handle partially available lists", () {
      final json = {
        "securityDeferralList": [
          {"securityNo": "SEC002"},
        ],
      };

      final perfection = SecurityPerfection.fromJson(json);

      expect(perfection.securityDeferralList, isNotNull);
      expect(perfection.securityDeferralList!.length, 1);
      expect(perfection.securityDeferralList!.first.securityNo, "SEC002");

      expect(perfection.covenant, isNull);
      expect(perfection.condition, isNull);
    });
  });
}
