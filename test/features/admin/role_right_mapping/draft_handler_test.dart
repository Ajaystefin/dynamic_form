import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/draft_handler.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/reference.dart";

void main() {
  late RoleRightMappingsDraftHandler handler;
  late RoleRightMappingViewModel vm;

  setUp(() {
    handler = RoleRightMappingsDraftHandler();
    vm = RoleRightMappingViewModel();
  });

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------
  group("resolveDraftKey", () {
    test("role + request type", () {
      vm.selectedRole = Reference(id: 1);
      vm.selectedRequestType = Reference(id: 2);

      expect(
        handler.resolveDraftKey(vm),
        "role_right_mapping_1_2",
      );
    });

    test("role only", () {
      vm.selectedRole = Reference(id: 5);
      vm.selectedRequestType = null;

      expect(
        handler.resolveDraftKey(vm),
        "role_right_mapping_5",
      );
    });

    test("no role", () {
      vm.selectedRole = null;
      vm.selectedRequestType = Reference(id: 9);

      expect(
        handler.resolveDraftKey(vm),
        "role_right_mapping_no_role",
      );
    });
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  group("buildDraftData", () {
    test("skip when role is null", () {
      vm.selectedRole = null;
      vm.selectedRequestType = Reference(id: 1);

      expect(
        handler.buildDraftData(vm),
        const {"__skip__": true},
      );
    });

    test("skip when request type is null", () {
      vm.selectedRole = Reference(id: 1);
      vm.selectedRequestType = null;

      expect(
        handler.buildDraftData(vm),
        const {"__skip__": true},
      );
    });

    test("skip when updatedAccessRight is null", () {
      vm.selectedRole = Reference(id: 1);
      vm.selectedRequestType = Reference(id: 2);
      vm.updatedAccessRight = null;

      expect(
        handler.buildDraftData(vm),
        const {"__skip__": true},
      );
    });

    test("builds valid draft JSON", () {
      vm.selectedRole = Reference(id: 1);
      vm.selectedRequestType = Reference(id: 2);

      vm.updatedAccessRight = AccessRight.fromJson({
        "role": "ROLE_ADMIN",
        "requestType": "REQUEST_A",
        "subType": "SUB",
        "pageList": [],
      });

      final result = handler.buildDraftData(vm);

      expect(result["roleId"], 1);
      expect(result["requestTypeId"], 2);

      final ar = result["accessRight"] as Map<String, dynamic>;
      expect(ar["role"], "ROLE_ADMIN");
      expect(ar["requestType"], "REQUEST_A");
      expect(ar["subType"], "SUB");
      expect(ar["pageList"], isA<List>());
    });
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------
  group("applyDraft", () {
    setUp(() {
      vm.selectedRole = Reference(id: 1);
      vm.selectedRequestType = Reference(id: 2);
    });

    test("ignores when roleId mismatches", () {
      handler.applyDraft(vm, {
        "roleId": 99,
        "requestTypeId": 2,
        "accessRight": {},
      });

      expect(vm.accessRight, isNull);
      expect(vm.updatedAccessRight, isNull);
    });

    test("ignores when requestType mismatches", () {
      handler.applyDraft(vm, {
        "roleId": 1,
        "requestTypeId": 99,
        "accessRight": {},
      });

      expect(vm.accessRight, isNull);
      expect(vm.updatedAccessRight, isNull);
    });

    test("returns when accessRight is null", () {
      handler.applyDraft(vm, {
        "roleId": 1,
        "requestTypeId": 2,
        "accessRight": null,
      });

      expect(vm.accessRight, isNull);
      expect(vm.updatedAccessRight, isNull);
    });

    test("restores accessRight successfully", () {
      handler.applyDraft(vm, {
        "roleId": 1,
        "requestTypeId": 2,
        "accessRight": {
          "role": "ROLE_USER",
          "requestType": "REQ_X",
          "subType": "SUB_X",
          "pageList": [],
        },
      });

      expect(vm.accessRight, isNotNull);
      expect(vm.updatedAccessRight, isNotNull);
      expect(vm.state.referencesLoaderStatus, LoadingStatus.loaded);
    });

    test("catch block executes and still emits loaded", () {
      handler.applyDraft(vm, {
        "roleId": 1,
        "requestTypeId": 2,
        "accessRight": "INVALID_TYPE", // forces catch
      });

      expect(vm.accessRight, isNull);
      expect(vm.updatedAccessRight, isNull);
      expect(vm.state.referencesLoaderStatus, LoadingStatus.loaded);
    });
  });
}
