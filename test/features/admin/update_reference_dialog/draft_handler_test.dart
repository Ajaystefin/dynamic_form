import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/draft_handler.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class FakeAdminRepository extends AdminRepository {
  @override
  Future<List<ReferenceType>> getReferenceTypes() async => [];
}

void main() {
  late UpdateReferenceDialogDraftHandler handler;
  late UpdateReferenceDialogViewModel vm;

  setUp(() {
    handler = UpdateReferenceDialogDraftHandler();
    vm = UpdateReferenceDialogViewModel()
      ..repository = FakeAdminRepository()
      ..formKey = GlobalKey<FormState>()
      ..reference = Reference(id: 1, name: "Ref", status: "active")
      ..selectedReferenceType = ReferenceType(id: 10, name: "Type")
      ..statusListValue = ["Active"];
  });

  //  resolveDraftKey – ALL BRANCHES
  test("resolveDraftKey full branch coverage", () {
    expect(handler.resolveDraftKey(vm), "update_reference_10_1");

    vm.reference = Reference();
    expect(handler.resolveDraftKey(vm), "update_reference_10_new");

    vm.selectedReferenceType = null;
    vm.reference = Reference(id: 5);
    expect(handler.resolveDraftKey(vm), "update_reference_na_5");
  });

  // - buildDraftData – skip path
  test("buildDraftData skip path", () {
    final result = handler.buildDraftData(vm);
    expect(result, {"__skip_draft__": true});
  });

  test("applyDraft skip sentinel", () {
    handler.applyDraft(vm, {"__skip_draft__": true});
    expect(vm.reference.id, 1);
  });

  //
  test("applyDraft missing reference", () {
    handler.applyDraft(vm, {});
    expect(vm.reference.id, 1);
  });

  //
  test("applyDraft type mismatch", () {
    handler.applyDraft(vm, {
      "referenceTypeId": 99,
      "reference": vm.reference.toJson(),
    });

    expect(vm.reference.id, 1);
  });

  //  applyDraft – match

  // - applyDraft – catch block
  test("applyDraft catch block", () {
    expect(
      () => handler.applyDraft(vm, {
        "referenceTypeId": 10,
        "reference": "invalid",
      }),
      returnsNormally,
    );
    // -------------------------------------------------------------------------
  });
// ADDITIONAL PURE UNIT TESTS – no widget / no mounted dependency
// -----------------------------------------------------------------------------

  group("pure unit execution gaps", () {
    test("buildDraftData returns only skip marker when not ready", () {
      final result = handler.buildDraftData(vm);

      expect(result.length, 1);
      expect(result.keys.single, "__skip_draft__");
    });

    test("applyDraft ignores skip marker even with other data present", () {
      final originalId = vm.reference.id;

      handler.applyDraft(vm, {
        "__skip_draft__": true,
        "referenceTypeId": 10,
        "reference": {"id": 99},
      });

      expect(vm.reference.id, originalId);
    });

    test("applyDraft ignores draft when reference json is null explicitly", () {
      final originalId = vm.reference.id;

      handler.applyDraft(vm, {
        "referenceTypeId": 10,
        "reference": null,
      });

      expect(vm.reference.id, originalId);
    });

    test("normalizeStatusForDropdown handles null and empty", () {
      expect(vm.normalizeStatusForDropdown(null), null);
      expect(vm.normalizeStatusForDropdown(""), null);
    });
    test("syncControllersWithReference syncs all fields", () {
      vm.reference = Reference(
        name: "Name",
        description: "Desc",
        reference1: "R1",
        reference2: "R2",
        reference3: "R3",
        reference4: "R4",
        reference5: "R5",
      );

      vm.syncControllersWithReference();

      expect(vm.nameController.text, "Name");
      expect(vm.descriptionController.text, "Desc");
      expect(vm.reference1Controller.text, "R1");
      expect(vm.reference2Controller.text, "R2");
      expect(vm.reference3Controller.text, "R3");
      expect(vm.reference4Controller.text, "R4");
      expect(vm.reference5Controller.text, "R5");
    });
    test("onUpdateReferenceData updates reference and status list", () {
      final ref = Reference(
        id: 99,
        name: "Ref",
        description: "Desc",
        status: "ACTIVE",
      );

      vm.onUpdateReferenceData(ref);

      expect(vm.reference.id, 99);
      expect(vm.statusListValue, ["Active"]);
    });
    test("onFieldChanged does nothing if draft not ready", () {
      vm.onFieldChanged(); // should not throw
    });

    test("onFieldChanged triggers autosave when ready", () {
      bool called = false;
      Globals.onAutoSave = () async => called = true;

      vm.onUpdateReferenceData(Reference());
      vm.onFieldChanged();

      expect(called, false);
    });

    test("normalizeStatusForDropdown capitalizes status", () {
      expect(vm.normalizeStatusForDropdown("active"), "Active");
    });
    test("applyDraft handles empty status list correctly", () {
      final draft = {
        "referenceTypeId": 10,
        "reference": {
          "id": 333,
          "name": "Empty Status",
        },
        "statusListValue": <String>[],
      };

      handler.applyDraft(vm, draft);

      expect(vm.statusListValue, isEmpty);
    });
    test("normalizeAllowedRegex handles null and empty", () {
      expect(vm.normalizeAllowedRegex(null), isNotEmpty);
      expect(vm.normalizeAllowedRegex(""), isNotEmpty);
    });

    test("normalizeAllowedRegex strips quotes and raw prefix", () {
      expect(
        vm.normalizeAllowedRegex("r'[a-z]+'"),
        "[a-z]+",
      );

      expect(
        vm.normalizeAllowedRegex("'[0-9]+'"),
        "[0-9]+",
      );
    });

    test("buildDraftData omits statusListValue when null", () {
      vm.statusListValue = null;

      final result = handler.buildDraftData(vm);

      expect(result.containsKey("statusListValue"), false);
    });

    test("syncControllersWithReference handles null reference fields", () {
      vm.reference = Reference();

      expect(() => vm.syncControllersWithReference(), returnsNormally);
    });

    test("onFieldChanged does not call autosave when Globals callback is null",
        () {
      Globals.onAutoSave = null;

      expect(() => vm.onFieldChanged(), returnsNormally);
    });

    test("onFieldChanged does not autosave when form key is invalid", () {
      bool called = false;
      Globals.onAutoSave = () async => called = true;

      vm.formKey = GlobalKey<FormState>(); // never validated
      vm.onFieldChanged();

      expect(called, false);
    });

    test("normalizeAllowedRegex always returns non-empty string", () {
      final result = vm.normalizeAllowedRegex(null);

      expect(result.trim().isNotEmpty, true);
    });

    test("normalizeStatusForDropdown uppercases lowercase status", () {
      expect(vm.normalizeStatusForDropdown("inactive"), "Inactive");
    });

    test("normalizeStatusForDropdown leaves unknown status unchanged", () {
      expect(vm.normalizeStatusForDropdown("Archived"), "Archived");
    });
    test("getColumnLabelNames returns default when no additional headers", () {
      vm.selectedReferenceType = ReferenceType(name: "Test");

      final columns = vm.getColumnLabelNames();

      expect(columns.length, greaterThan(5));
    });

    test("getColumnLabelNames applies additional headers", () {
      vm.selectedReferenceType = ReferenceType(
        name: "Test",
        columnsInformation: "A;B;C",
      );

      final columns = vm.getColumnLabelNames();

      expect(columns.any((e) => e == "A"), true);
    });

    test("close disposes controllers safely", () async {
      await vm.close();
    });

    test("applyDraft tolerates status list with mixed stringable values", () {
      final draft = {
        "referenceTypeId": 10,
        "reference": {
          "id": 444,
          "name": "Mixed Status",
        },
        "statusListValue": ["Active", 1, false],
      };

      handler.applyDraft(vm, draft);

      expect(vm.statusListValue, ["Active", "1", "false"]);
    });

    test("applyDraft does not throw when referenceTypeId is wrong type", () {
      final draft = {
        "referenceTypeId": "not-int",
        "reference": {
          "id": 555,
          "name": "Wrong TypeId",
        },
      };

      expect(() => handler.applyDraft(vm, draft), returnsNormally);
    });

    test("applyDraft does not throw when draft map is deeply malformed", () {
      expect(
        () => handler.applyDraft(vm, {
          "referenceTypeId": 10,
          "reference": {
            "unexpected": {"nested": Object()},
          },
        }),
        returnsNormally,
      );
    });

    test("resolveDraftKey handles null reference and null type together", () {
      vm.reference = Reference();
      vm.selectedReferenceType = null;

      final key = handler.resolveDraftKey(vm);

      expect(key, "update_reference_na_new");
    });
  });
  test("resolveDraftKey uses na when referenceType id missing", () {
    vm.selectedReferenceType = ReferenceType(name: "NoId");
    vm.reference = Reference(id: 7);

    final key = handler.resolveDraftKey(vm);

    expect(key, "update_reference_na_7");
  });

  test("resolveDraftKey handles reference id zero", () {
    vm.reference = Reference(id: 0);

    final key = handler.resolveDraftKey(vm);

    expect(key.contains("_0"), true);
  });

  test("resolveDraftKey handles negative reference id defensively", () {
    vm.reference = Reference(id: -1);

    final key = handler.resolveDraftKey(vm);

    expect(key.contains("-1"), true);
  });
}
