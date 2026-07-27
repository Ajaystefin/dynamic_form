import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/approval/comments/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/comments/model.dart";

class MockCommentsViewModel extends Mock implements CommentsViewModel {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CommentsDraftHandler", () {
    late MockCommentsViewModel vm;
    late MockUnifiedEditorController controller;
    late CommentsDraftHandler handler;

    late String initialText;
    late String returnOptSelected;
    late int optsActionId;
    late String selectedUserId;
    late String selectedDelegation;
    late String selectedReason;
    late bool isReturnSelected;
    late bool isRecommendSelected;
    late GlobalKey<FormState> formKey;
    late String currentText;

    setUp(() {
      vm = MockCommentsViewModel();
      controller = MockUnifiedEditorController();
      handler = CommentsDraftHandler();

      initialText = "Original text";
      returnOptSelected = "Original Return Opt";
      optsActionId = 0;
      selectedUserId = "user:original";
      selectedDelegation = "del-original";
      selectedReason = "reason-original";
      isReturnSelected = false;
      isRecommendSelected = false;
      formKey = GlobalKey<FormState>();
      currentText = "Original text";

      when(() => vm.controller).thenReturn(controller);
      when(() => vm.formKey).thenReturn(formKey);

      when(() => controller.currentText).thenAnswer((_) => currentText);
      when(() => controller.setText(any())).thenAnswer((_) async {});
      when(() => controller.getText()).thenAnswer((_) async => currentText);

      when(() => vm.initialText).thenAnswer((_) => initialText);
      when(() => vm.returnOptSelected).thenAnswer((_) => returnOptSelected);
      when(() => vm.optsActionId).thenAnswer((_) => optsActionId);
      when(() => vm.selectedUserId).thenAnswer((_) => selectedUserId);
      when(() => vm.selectedDelegation).thenAnswer((_) => selectedDelegation);
      when(() => vm.selectedReason).thenAnswer((_) => selectedReason);
      when(() => vm.isReturnSelected).thenAnswer((_) => isReturnSelected);
      when(() => vm.isRecommendSelected).thenAnswer((_) => isRecommendSelected);

      when(() => vm.initialText = any()).thenAnswer(
        (invocation) =>
            initialText = invocation.positionalArguments.first as String,
      );

      when(() => vm.returnOptSelected = any()).thenAnswer((invocation) {
        returnOptSelected = invocation.positionalArguments.first as String;
        return null;
      });

      when(() => vm.optsActionId = any()).thenAnswer(
        (invocation) =>
            optsActionId = invocation.positionalArguments.first as int,
      );

      when(() => vm.selectedUserId = any()).thenAnswer(
        (invocation) =>
            selectedUserId = invocation.positionalArguments.first as String,
      );

      when(() => vm.selectedDelegation = any()).thenAnswer(
        (invocation) =>
            selectedDelegation = invocation.positionalArguments.first as String,
      );

      when(() => vm.selectedReason = any()).thenAnswer(
        (invocation) =>
            selectedReason = invocation.positionalArguments.first as String,
      );

      when(() => vm.isReturnSelected = any()).thenAnswer(
        (invocation) =>
            isReturnSelected = invocation.positionalArguments.first as bool,
      );

      when(() => vm.isRecommendSelected = any()).thenAnswer(
        (invocation) =>
            isRecommendSelected = invocation.positionalArguments.first as bool,
      );
    });

    test("buildDraftData returns sanitized serialized draft data", () {
      currentText = "  <p>Hello&nbsp;<b>Draft</b></p>  ";
      returnOptSelected = "Rework for Query";
      optsActionId = 88;
      selectedUserId = "123:RM";
      selectedDelegation = "DELEG-10";
      selectedReason = "Missing Docs";
      isReturnSelected = true;
      isRecommendSelected = true;

      final draft = handler.buildDraftData(vm);

      expect(draft, isA<Map<String, dynamic>>());

      expect(draft["initialText"], "Hello Draft");
      expect(draft["returnOptSelected"], "Rework for Query");
      expect(draft["optsActionId"], 88);
      expect(draft["selectedUserId"], "123:RM");
      expect(draft["selectedDelegation"], "DELEG-10");
      expect(draft["selectedReason"], "Missing Docs");
      expect(draft["isReturnSelected"], true);
      expect(draft["isRecommendSelected"], true);

      verify(() => vm.controller).called(greaterThanOrEqualTo(1));
      verify(() => controller.currentText).called(1);
    });

    test("buildDraftData trims text and removes html tags and nbsp", () {
      currentText = "\n <div>&nbsp;Clean <span>Text</span>&nbsp;</div> \n";

      final draft = handler.buildDraftData(vm);

      expect(draft["initialText"], "Clean Text");
    });

    test(
        "applyDraft restores editor text and boolean flags when valid values exist",
        () {
      final draft = {
        "initialText": "Restored Text!",
        "returnOptSelected": "Rework for Clarification",
        "optsActionId": 42,
        "selectedUserId": "999:HEAD",
        "selectedDelegation": "DEL-RESTORE",
        "selectedReason": "RestoredReason",
        "isReturnSelected": true,
        "isRecommendSelected": false,
      };

      handler.applyDraft(vm, draft);

      expect(initialText, "Restored Text!");
      expect(isReturnSelected, true);
      expect(isRecommendSelected, false);

      verify(() => vm.initialText = "Restored Text!").called(1);
      verify(() => controller.setText("Restored Text!")).called(1);
      verify(() => vm.isReturnSelected = true).called(1);
      verify(() => vm.isRecommendSelected = false).called(1);
    });

    test("applyDraft does not restore text when initialText is null", () {
      final draft = {
        "initialText": null,
        "isReturnSelected": true,
        "isRecommendSelected": true,
      };

      handler.applyDraft(vm, draft);

      expect(initialText, "Original text");
      expect(isReturnSelected, true);
      expect(isRecommendSelected, true);

      verifyNever(() => vm.initialText = any());
      verifyNever(() => controller.setText(any()));
      verify(() => vm.isReturnSelected = true).called(1);
      verify(() => vm.isRecommendSelected = true).called(1);
    });

    test("applyDraft does not restore text when initialText is empty", () {
      final draft = {
        "initialText": "",
        "isReturnSelected": false,
        "isRecommendSelected": true,
      };

      handler.applyDraft(vm, draft);

      expect(initialText, "Original text");
      expect(isReturnSelected, false);
      expect(isRecommendSelected, true);

      verifyNever(() => vm.initialText = any());
      verifyNever(() => controller.setText(any()));
      verify(() => vm.isReturnSelected = false).called(1);
      verify(() => vm.isRecommendSelected = true).called(1);
    });

    test("applyDraft ignores non boolean return and recommend values", () {
      final draft = {
        "initialText": "Valid Text",
        "isReturnSelected": "true",
        "isRecommendSelected": 1,
      };

      handler.applyDraft(vm, draft);

      expect(initialText, "Valid Text");
      expect(isReturnSelected, false);
      expect(isRecommendSelected, false);

      verify(() => vm.initialText = "Valid Text").called(1);
      verify(() => controller.setText("Valid Text")).called(1);
      verifyNever(() => vm.isReturnSelected = any());
      verifyNever(() => vm.isRecommendSelected = any());
    });

    test("applyDraft ignores missing values gracefully", () {
      final draft = <String, dynamic>{};

      handler.applyDraft(vm, draft);

      expect(initialText, "Original text");
      expect(isReturnSelected, false);
      expect(isRecommendSelected, false);

      verifyNever(() => vm.initialText = any());
      verifyNever(() => controller.setText(any()));
      verifyNever(() => vm.isReturnSelected = any());
      verifyNever(() => vm.isRecommendSelected = any());
    });
  });
}
