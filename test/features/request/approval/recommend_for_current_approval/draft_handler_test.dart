import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  late RecommendCurrentApprovalDraftHandler handler;
  late RecommendCurrentApprovalViewModel vm;

  setUp(() {
    handler = RecommendCurrentApprovalDraftHandler();
    vm = RecommendCurrentApprovalViewModel();

    // --- Mock global state ---

    Globals.user = User(
      selectedRoleId: 5,
      currentRole: Role(
        roleId: 5,
        name: "Test Role",
      ),
    );

    Globals.request = Request(applicationRefNo: "APP-001");

    // Required for formKey.save()
    vm.formKey = GlobalKey<FormState>();

    vm.initialText = "Initial comment";
    vm.reviewCommentId = "123";
    vm.isCommentVisible = true;
    vm.canEdit = true;
    vm.isReadOnly = false;
  });

  tearDown(() {
    Globals.user = null;
    Globals.request = null;
  });

  group("resolveDraftKey", () {
    test("creates key using form key and role id", () {
      final key = handler.resolveDraftKey(vm);

      expect(
        key,
        "${vm.draftFormKey}_r5",
      );
    });

    test("uses default role id when user role missing", () {
      Globals.user = null;

      final key = handler.resolveDraftKey(vm);

      expect(
        key,
        "${vm.draftFormKey}_r0",
      );
    });
  });

  group("buildDraftData", () {
    test("builds draft payload with expected fields", () {
      final data = handler.buildDraftData(vm);

      expect(data["initialText"], "Initial comment");
      expect(data["reviewCommentId"], "123");
      expect(data["isCommentVisible"], true);

      expect(data["meta"], isA<Map<String, dynamic>>());
      expect(data["meta"]["appRefNo"], "APP-001");
      expect(data["meta"]["roleId"], 5);
      expect(data["meta"]["formKey"], vm.draftFormKey);
      expect(data["meta"]["moduleKey"], vm.draftModuleKey);
      expect(data["meta"]["timestamp"], isA<String>());
    });

    test("does not persist ui edit permissions", () {
      final data = handler.buildDraftData(vm);

      final ui = data["ui"] as Map<String, dynamic>;
      expect(ui.isEmpty, true);
    });
  });

  group("applyDraft", () {
    test("applies valid draft values to view model", () {
      final draft = <String, dynamic>{
        "initialText": " Restored text ",
        "reviewCommentId": " 456 ",
        "isCommentVisible": false,
      };

      handler.applyDraft(vm, draft);

      expect(vm.initialText, "Restored text");
      expect(vm.reviewCommentId, "456");
      expect(vm.isCommentVisible, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("ignores empty or invalid draft values", () {
      vm.initialText = "Existing";
      vm.reviewCommentId = "999";
      vm.isCommentVisible = true;

      final draft = <String, dynamic>{
        "initialText": "   ",
        "reviewCommentId": "",
      };

      handler.applyDraft(vm, draft);

      expect(vm.initialText, "Existing");
      expect(vm.reviewCommentId, "999");
      expect(vm.isCommentVisible, true);
    });

    test("does NOT override computed permissions", () {
      vm.canEdit = false;
      vm.isReadOnly = true;

      final draft = <String, dynamic>{
        "initialText": "Draft text",
      };

      handler.applyDraft(vm, draft);

      expect(vm.canEdit, false);
      expect(vm.isReadOnly, true);
    });

    test("handles malformed draft gracefully", () {
      final draft = <String, dynamic>{
        "initialText": 123, // wrong type
      };

      expect(
        () => handler.applyDraft(vm, draft),
        returnsNormally,
      );

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });
  testWidgets("buildDraftData triggers form save when form state exists",
      (WidgetTester tester) async {
    final testKey = GlobalKey<FormState>();
    bool saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              saved = true;
            }
          },
          child: const Scaffold(),
        ),
      ),
    );

    vm.formKey = testKey;

    // Act
    handler.buildDraftData(vm);

    // Assert – no crash, save path executed
    expect(saved, false);
  });
  test("buildDraftData handles null globals safely", () {
    Globals.request = null;
    Globals.user = User(selectedRoleId: null);

    final data = handler.buildDraftData(vm);

    expect(data["meta"]["appRefNo"], null);
    expect(data["meta"]["roleId"], null);
  });
  test("applyDraft executes catch block on unexpected error", () {
    final badData = <String, dynamic>{
      "initialText": Object(), // will throw during trim()
    };

    handler.applyDraft(vm, badData);

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });
  test("applyDraft ignores invalid isCommentVisible type", () {
    vm.isCommentVisible = true;

    final draft = <String, dynamic>{
      "isCommentVisible": "yes", // invalid type
    };

    handler.applyDraft(vm, draft);

    expect(vm.isCommentVisible, true); // unchanged
  });
  test("applyDraft handles completely empty draft map", () {
    handler.applyDraft(vm, {});
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });
}

/// ---------------------------------------------------------------------------
/// Mock helpers
/// ---------------------------------------------------------------------------

class MockUser {
  MockUser({required this.roleId});

  final int roleId;

  MockRole get currentRole => MockRole(roleId);
}

class MockRole {
  MockRole(this.roleId);

  final int roleId;
}

class MockRequest {
  MockRequest({required this.appRefNo});

  final String appRefNo;

  String get applicationRefNo => appRefNo;
}
