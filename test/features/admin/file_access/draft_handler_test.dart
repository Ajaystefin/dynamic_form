import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/admin/file_access/draft_handler.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";

void main() {
  group("FileAccessDraftHandler", () {
    late FileAccessDraftHandler handler;

    setUp(() {
      handler = FileAccessDraftHandler();
    });

    FileAccessViewModel buildVm({
      Reference? role,
      List<FileAccess>? accesses,
    }) {
      final vm = FileAccessViewModel();
      vm.selectedRoleType = role;
      vm.fileAccesses = accesses ?? [];
      return vm;
    }

    // -------------------------------------------------------------------------
    // resolveDraftKey
    // -------------------------------------------------------------------------
    test("resolveDraftKey returns role-based key when role exists", () {
      final vm = buildVm(
        role: Reference(id: 10, name: "Admin"),
      );

      final key = handler.resolveDraftKey(vm);

      expect(key, "file_access_10");
    });

    test("resolveDraftKey returns fallback key when role is null", () {
      final vm = buildVm();

      final key = handler.resolveDraftKey(vm);

      expect(key, "file_access_no_role");
    });

    // -------------------------------------------------------------------------
    // buildDraftData
    // -------------------------------------------------------------------------
    test("buildDraftData returns skip flag when role is null", () {
      final vm = buildVm();

      final data = handler.buildDraftData(vm);

      expect(data, const {"__skip__": true});
    });

    test("buildDraftData builds valid API JSON when role exists", () {
      final vm = buildVm(
        role: Reference(id: 1, name: "Admin"),
        accesses: [
          FileAccess(
            id: 1,
            name: "Root",
            parentId: null,
            access: AccessType.view,
            children: [
              FileAccess(
                id: 2,
                name: "Child",
                parentId: 1,
                access: AccessType.edit,
              ),
            ],
          ),
        ],
      );

      final data = handler.buildDraftData(vm);

      expect(data["roleId"], 1);
      expect(data["fileAccesses"], isA<List>());
      expect((data["fileAccesses"] as List).length, 1);
      expect(
        (data["fileAccesses"] as List).first["children"].length,
        1,
      );
    });

    // -------------------------------------------------------------------------
    // applyDraft – ignored paths
    // -------------------------------------------------------------------------
    test("applyDraft ignores draft when roleId mismatches", () {
      final vm = buildVm(
        role: Reference(id: 2, name: "User"),
      );

      handler.applyDraft(vm, {
        "roleId": 1,
        "fileAccesses": [],
      });

      expect(vm.fileAccesses, isEmpty);
    });

    test("applyDraft ignores draft when roleId is missing", () {
      final vm = buildVm(
        role: Reference(id: 1, name: "Admin"),
      );

      handler.applyDraft(vm, {
        "fileAccesses": [],
      });

      expect(vm.fileAccesses, isEmpty);
    });

    test("applyDraft returns early when fileAccesses list is empty", () {
      final vm = buildVm(
        role: Reference(id: 1, name: "Admin"),
      );

      handler.applyDraft(vm, {
        "roleId": 1,
        "fileAccesses": [],
      });

      expect(vm.fileAccesses, isEmpty);
    });

    // -------------------------------------------------------------------------
    // applyDraft – success restore
    // -------------------------------------------------------------------------
    test("applyDraft restores fileAccesses and parents-with-children list", () {
      final vm = buildVm(
        role: Reference(id: 1, name: "Admin"),
      );

      handler.applyDraft(vm, {
        "roleId": 1,
        "fileAccesses": [
          {
            "id": 1,
            "name": "Parent",
            "parentId": null,
            "access": "view",
            "children": [
              {
                "id": 2,
                "name": "Child",
                "parentId": 1,
                "access": "edit",
                "children": [],
              },
            ],
          },
        ],
      });

      expect(vm.fileAccesses.length, 1);
      expect(vm.firstLevelParentsWithChildren.length, 1);
    });

    // -------------------------------------------------------------------------
    // applyDraft – exception safety
    // -------------------------------------------------------------------------
    test("applyDraft handles malformed JSON without crashing", () {
      final vm = buildVm(
        role: Reference(id: 1, name: "Admin"),
      );

      handler.applyDraft(vm, {
        "roleId": 1,
        "fileAccesses": ["invalid"],
      });

      expect(vm.fileAccesses, isEmpty);
    });
  });
}
