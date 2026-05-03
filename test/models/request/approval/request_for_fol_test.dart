import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/approval/request_for_fol.dart";

void main() {
  group("LegalAndLimitDetails", () {
    const bool approved = true;
    const int action = 42;
    const int role = 7;

    final jsonMap = <String, dynamic>{
      "isFOLApproved": approved,
      "userAction": action,
      "roleId": role,
    };

    test("fromJson should create instance with correct field values", () {
      final model = LegalAndLimitDetails.fromJson(jsonMap);

      expect(model.isFOLApproved, approved);
      expect(model.userAction, action);
      expect(model.roleId, role);
    });

    test("toJson should return correct Map representation", () {
      final model = LegalAndLimitDetails(
        isFOLApproved: approved,
        userAction: action,
        roleId: role,
      );

      final result = model.toJson();
      expect(result, isA<Map<String, dynamic>>());
      expect(result, equals(jsonMap));
    });

    test("round-trip: toJson -> fromJson yields equal field values", () {
      final original = LegalAndLimitDetails(
        isFOLApproved: false,
        userAction: 0,
        roleId: 999,
      );

      final mapped = LegalAndLimitDetails.fromJson(original.toJson());

      expect(mapped.isFOLApproved, original.isFOLApproved);
      expect(mapped.userAction, original.userAction);
      expect(mapped.roleId, original.roleId);
    });

    test(
      "fromJson should throw when required keys are missing or of wrong type",
      () {
        // missing all keys
        expect(
          () => LegalAndLimitDetails.fromJson({}),
          throwsA(isA<TypeError>()),
        );

        // wrong type for isFOLApproved
        final badMap1 = Map<String, dynamic>.from(jsonMap)
          ..["isFOLApproved"] = "not_a_bool";
        expect(
          () => LegalAndLimitDetails.fromJson(badMap1),
          throwsA(isA<TypeError>()),
        );

        // wrong type for userAction
        final badMap2 = Map<String, dynamic>.from(jsonMap)
          ..["userAction"] = "not_an_int";
        expect(
          () => LegalAndLimitDetails.fromJson(badMap2),
          throwsA(isA<TypeError>()),
        );

        // wrong type for roleId
        final badMap3 = Map<String, dynamic>.from(jsonMap)..["roleId"] = 3.14;
        expect(
          () => LegalAndLimitDetails.fromJson(badMap3),
          throwsA(isA<TypeError>()),
        );
      },
    );
  });
}
