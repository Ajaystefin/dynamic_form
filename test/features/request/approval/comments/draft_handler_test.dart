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

  group("CommentsDraftHandler Tests", () {
    late MockCommentsViewModel vm;
    late MockUnifiedEditorController controller;
    late CommentsDraftHandler handler;

    // Backing store for mocked properties
    late String initialText;
    late String returnOptSelected;
    late int optsActionId;
    late String selectedUserId;
    late String selectedDelegation;
    late String selectedReason;
    late bool isReturnSelected;
    late bool isRecommendSelected;
    late GlobalKey<FormState> formKey;

    setUp(() {
      vm = MockCommentsViewModel();
      controller = MockUnifiedEditorController();
      handler = CommentsDraftHandler();

      // Initial state
      initialText = "Original text";
      returnOptSelected = "Original Return Opt";
      optsActionId = 0;
      selectedUserId = "user:original";
      selectedDelegation = "del-original";
      selectedReason = "reason-original";
      isReturnSelected = false;
      isRecommendSelected = false;
      formKey = GlobalKey<FormState>();

      // ----- Stub ViewModel object references -----
      when(() => vm.controller).thenReturn(controller);
      when(() => vm.formKey).thenReturn(formKey);

      // ----- Stub controller -----
      when(() => controller.setText(any())).thenAnswer((_) async {});
      when(() => controller.getText()).thenAnswer((_) async => initialText);

      // ----- Stub getters -----
      when(() => vm.initialText).thenAnswer((_) => initialText);
      when(() => vm.returnOptSelected).thenAnswer((_) => returnOptSelected);
      when(() => vm.optsActionId).thenAnswer((_) => optsActionId);
      when(() => vm.selectedUserId).thenAnswer((_) => selectedUserId);
      when(() => vm.selectedDelegation).thenAnswer((_) => selectedDelegation);
      when(() => vm.selectedReason).thenAnswer((_) => selectedReason);
      when(() => vm.isReturnSelected).thenAnswer((_) => isReturnSelected);
      when(() => vm.isRecommendSelected).thenAnswer((_) => isRecommendSelected);

      // ----- Stub setters -----
      when(() => vm.initialText = any()).thenAnswer((invocation) {
        return initialText = invocation.positionalArguments[0] as String;
      });

      when(() => vm.returnOptSelected = any()).thenAnswer((invocation) {
        return returnOptSelected = invocation.positionalArguments[0] as String;
      });

      when(() => vm.optsActionId = any()).thenAnswer((invocation) {
        return optsActionId = invocation.positionalArguments[0] as int;
      });

      when(() => vm.selectedUserId = any()).thenAnswer((invocation) {
        return selectedUserId = invocation.positionalArguments[0] as String;
      });

      when(() => vm.selectedDelegation = any()).thenAnswer((invocation) {
        return selectedDelegation = invocation.positionalArguments[0] as String;
      });

      when(() => vm.selectedReason = any()).thenAnswer((invocation) {
        return selectedReason = invocation.positionalArguments[0] as String;
      });

      when(() => vm.isReturnSelected = any()).thenAnswer((invocation) {
        return isReturnSelected = invocation.positionalArguments[0] as bool;
      });

      when(() => vm.isRecommendSelected = any()).thenAnswer((invocation) {
        return isRecommendSelected = invocation.positionalArguments[0] as bool;
      });
    });

    // test('buildDraftData returns correct serialized fields', () {
    //   // Arrange
    //   vm.controller = UnifiedEditorController();
    //   vm.controller.setText('Hello draft!');
    //   initialText = 'Hello draft!';
    //   returnOptSelected = 'Rework for Query';
    //   optsActionId = 88;
    //   selectedUserId = '123:RM';
    //   selectedDelegation = 'DELEG-10';
    //   selectedReason = 'Missing Docs';
    //   isReturnSelected = true;
    //   isRecommendSelected = true;

    //   // Act
    //   final draft = handler.buildDraftData(vm);

    //   // Assert
    //   expect(draft['initialText'], 'Hello draft!');
    //   expect(draft['returnOptSelected'], 'Rework for Query');
    //   expect(draft['optsActionId'], 88);
    //   expect(draft['selectedUserId'], '123:RM');
    //   expect(draft['selectedDelegation'], 'DELEG-10');
    //   expect(draft['selectedReason'], 'Missing Docs');
    //   expect(draft['isReturnSelected'], true);
    //   expect(draft['isRecommendSelected'], true);
    // });

    test("applyDraft restores all fields into ViewModel", () async {
      // Arrange
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

      // Act
      handler.applyDraft(vm, draft);

      // Assert state
      expect(initialText, "Restored Text!");
      expect(returnOptSelected, "Rework for Clarification");
      expect(optsActionId, 42);
      expect(selectedUserId, "999:HEAD");
      expect(selectedDelegation, "DEL-RESTORE");
      expect(selectedReason, "RestoredReason");
      expect(isReturnSelected, true);
      expect(isRecommendSelected, false);

      // Assert editor sync happened
      verify(() => controller.setText("Restored Text!")).called(1);
    });

    test("applyDraft handles missing or null fields gracefully", () {
      // Arrange
      final draft = {
        "initialText": null, // should not overwrite original
        "optsActionId": "77", // should parse string -> int
      };

      // Act
      handler.applyDraft(vm, draft);

      // Assert
      expect(initialText, "Original text");
      expect(optsActionId, 77);

      // No text push because initialText was null
      verifyNever(() => controller.setText(any()));
    });
  });
}
