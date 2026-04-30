import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/model.dart";

import "package:wcas_frontend/models/request/comment.dart";

class MockCovenantsSummaryViewModel extends Mock
    implements CovenantsSummaryViewModel {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CovenantsSummaryDraftHandler Tests", () {
    late MockCovenantsSummaryViewModel vm;
    late MockUnifiedEditorController unifiedEditorController;
    late CovenantsSummaryDraftHandler handler;

    late GlobalKey<FormState> formKey;
    late TextEditingController controller;

    Comment? currentComment;
    List<Comment> currentComments;

    setUpAll(() {
      registerFallbackValue(<Comment>[]);
    });

    setUp(() {
      vm = MockCovenantsSummaryViewModel();
      unifiedEditorController = MockUnifiedEditorController();
      handler = CovenantsSummaryDraftHandler();

      formKey = GlobalKey<FormState>();
      controller = TextEditingController();

      currentComment = null;
      currentComments = <Comment>[];

      // ----- getters -----
      when(() => vm.formKey).thenReturn(formKey);
      when(() => vm.comment).thenAnswer((_) => currentComment);
      when(() => vm.comments).thenAnswer((_) => currentComments);
      when(() => vm.controller).thenReturn(controller);
      when(() => vm.unifiedEditorController)
          .thenReturn(unifiedEditorController);

      // ----- setters -----
      when(() => vm.comment = any()).thenAnswer((invocation) {
        return currentComment = invocation.positionalArguments[0] as Comment?;
      });

      when(() => vm.comments = any()).thenAnswer((invocation) {
        return currentComments = List<Comment>.from(
          invocation.positionalArguments[0] as List<Comment>,
        );
      });

      // ----- editor -----
      when(() => unifiedEditorController.setText(any()))
          .thenAnswer((_) async {});
    });

    tearDown(() {
      controller.dispose();
    });

    test("buildDraftData prefers vm.comment.comment", () {
      // Arrange
      currentComment = Comment(comment: "Primary VM comment");
      currentComments = [
        Comment(comment: "Older comment"),
        Comment(comment: "Last server comment"),
      ];
      controller.text = "Controller fallback";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["lastComment"], "Primary VM comment");
    });

    test("buildDraftData falls back to vm.comments.last.comment", () {
      // Arrange
      currentComment = Comment(comment: "   "); // blank => ignored
      currentComments = [
        Comment(comment: "First"),
        Comment(comment: "Last server-backed comment"),
      ];
      controller.text = "Controller fallback";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["lastComment"], "Last server-backed comment");
    });

    test(
        "buildDraftData falls back to controller.text when model/list are blank",
        () {
      // Arrange
      currentComment = Comment(comment: "");
      currentComments = [
        Comment(comment: "   "),
      ];
      controller.text = "Controller entered text";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["lastComment"], "Controller entered text");
    });

    test("buildDraftData returns null when all sources are empty", () {
      // Arrange
      currentComment = Comment(comment: "   ");
      currentComments = [];
      controller.text = "   ";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["lastComment"], isNull);
    });

    test("applyDraft creates vm.comment and comments list when empty", () {
      // Arrange
      currentComment = null;
      currentComments = [];
      controller.text = "";

      final data = {
        "lastComment": "Restored draft comment",
      };

      // Act
      handler.applyDraft(vm, data);

      // Assert
      expect(currentComment, isNotNull);
      expect(currentComment!.comment, "Restored draft comment");

      expect(currentComments.length, 1);
      expect(currentComments.last.comment, "Restored draft comment");

      expect(controller.text, "Restored draft comment");

      verify(() => unifiedEditorController.setText("Restored draft comment"))
          .called(1);
    });

    test("applyDraft updates existing vm.comment and last list item", () {
      // Arrange
      currentComment = Comment(comment: "Old main comment");
      currentComments = [
        Comment(comment: "First comment"),
        Comment(comment: "Last comment before restore"),
      ];
      controller.text = "Old controller text";

      final data = {
        "lastComment": "Updated restored comment",
      };

      // Act
      handler.applyDraft(vm, data);

      // Assert
      expect(currentComment!.comment, "Updated restored comment");

      expect(currentComments.length, 2);
      expect(currentComments.first.comment, "First comment");
      expect(currentComments.last.comment, "Updated restored comment");

      expect(controller.text, "Updated restored comment");

      verify(() => unifiedEditorController.setText("Updated restored comment"))
          .called(1);
    });

    test("applyDraft does nothing when lastComment is null", () {
      // Arrange
      currentComment = Comment(comment: "Existing comment");
      currentComments = [Comment(comment: "Existing list comment")];
      controller.text = "Existing controller text";

      final data = {
        "lastComment": null,
      };

      // Act
      handler.applyDraft(vm, data);

      // Assert
      expect(currentComment!.comment, "Existing comment");
      expect(currentComments.single.comment, "Existing list comment");
      expect(controller.text, "Existing controller text");

      verifyNever(() => unifiedEditorController.setText(any()));
    });

    test(
        "applyDraft still restores comment/list/controller even if rich editor throws",
        () {
      // Arrange
      currentComment = null;
      currentComments = [];
      controller.text = "";

      when(() => unifiedEditorController.setText(any()))
          .thenThrow(Exception("Editor not mounted"));

      final data = {
        "lastComment": "Recovered despite editor failure",
      };

      // Act
      handler.applyDraft(vm, data);

      // Assert
      expect(currentComment, isNotNull);
      expect(currentComment!.comment, "Recovered despite editor failure");

      expect(currentComments.length, 1);
      expect(currentComments.last.comment, "Recovered despite editor failure");

      expect(controller.text, "Recovered despite editor failure");

      verify(
        () =>
            unifiedEditorController.setText("Recovered despite editor failure"),
      ).called(1);
    });
  });
}
