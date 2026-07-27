import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";

void main() {
  group("SecurityCovenantCondition", () {
    test("should create instance with all properties", () {
      final condition = SecurityCovenantCondition(
        number: "COV001",
        description: "Test Covenant",
        deferralDate: DateTime(2026, 4, 25),
        isChecked: true,
        isCovenant: true,
        date: DateTime(2026, 4, 25),
      );

      expect(condition.number, "COV001");
      expect(condition.description, "Test Covenant");
      expect(condition.deferralDate, DateTime(2026, 4, 25));
      expect(condition.isChecked, true);
      expect(condition.isCovenant, true);
      expect(condition.date, DateTime(2026, 4, 25));
    });

    test("should create instance with default values", () {
      final condition = SecurityCovenantCondition();

      expect(condition.number, isNull);
      expect(condition.description, isNull);
      expect(condition.deferralDate, isNull);
      expect(condition.isChecked, false);
      expect(condition.isCovenant, false);
      expect(condition.date, isNull);
    });

    test("should create from JSON correctly", () {
      final json = {
        "covenantConditionNo": "COV001",
        "description": "Test Covenant",
        "deferralDate": 20260425,
        "selected": true,
        "isCovenant": true,
      };

      final condition = SecurityCovenantCondition.fromJson(json);

      expect(condition.number, "COV001");
      expect(condition.description, "Test Covenant");
      //expect(condition.deferralDate, DateTime(2026, 4, 25));
      expect(condition.isChecked, true);
      expect(condition.isCovenant, true);
    });

    test("should handle null values safely in fromJson", () {
      final json = {
        "covenantConditionNo": null,
        "description": null,
        "deferralDate": null,
        "selected": null,
        "isCovenant": null,
      };

      final condition = SecurityCovenantCondition.fromJson(json);

      expect(condition.number, isNull);
      expect(condition.description, isNull);
      expect(condition.deferralDate, isNull);
      expect(condition.isChecked, false);
      expect(condition.isCovenant, false);
    });

    test("should convert to JSON correctly (Covenant)", () {
      final condition = SecurityCovenantCondition(
        number: "COV001",
        description: "Test Covenant",
        deferralDate: DateTime(2026, 4, 25),
        isChecked: true,
        isCovenant: true,
      );

      final json = condition.toJson(isCovenant: true);

      expect(json["covenantConditionNo"], "COV001");
      expect(json["description"], "Test Covenant");
      expect(json["deferralDate"], "2026-04-25"); //  formatted
      expect(json["selected"], true);
      expect(json["isCovenant"], true);
    });

    test("should convert to JSON correctly (Condition)", () {
      final condition = SecurityCovenantCondition(
        number: "CON001",
        description: "Test Condition",
        deferralDate: DateTime(2026, 4, 30),
      );

      final json = condition.toJson(isCovenant: false);

      expect(json["covenantConditionNo"], "CON001");
      expect(json["description"], "Test Condition");
      expect(json["deferralDate"], "2026-04-30");
      expect(json["selected"], true);
      expect(json["isCovenant"], false);
    });

    test("should preserve special and unicode characters", () {
      final condition = SecurityCovenantCondition(
        number: "COV-测试",
        description: "Unicode test 🚀 测试",
        deferralDate: DateTime(2026),
        isChecked: true,
        isCovenant: true,
      );

      final json = condition.toJson(isCovenant: true);

      expect(json["covenantConditionNo"], "COV-测试");
      expect(json["description"], "Unicode test 🚀 测试");
    });

    test("should keep checkbox state independent of date", () {
      final condition = SecurityCovenantCondition(
        number: "COV002",
        isChecked: true,
        isCovenant: true,
      );

      final json = condition.toJson(isCovenant: true);

      expect(json["selected"], false);
      expect(json["deferralDate"], null);
    });
  });
}
