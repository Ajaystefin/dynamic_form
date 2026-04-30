import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/ccsys/approval/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/state.dart";
import "package:wcas_frontend/models/request/comment.dart";

// -----------------------------------------------------------------------------
// Mocks
// -----------------------------------------------------------------------------

class MockCcsysApprovalViewModel extends Mock
    implements CcsysApprovalViewModel {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockCcsysApprovalState extends Mock implements CcsysApprovalState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Required for any<CcsysApprovalState>()
  setUpAll(() {
    registerFallbackValue(MockCcsysApprovalState());
  });

  group("CcsysApprovalDraftHandler Tests", () {
    late CcsysApprovalDraftHandler handler;
    late MockCcsysApprovalViewModel vm;
    late MockUnifiedEditorController controller;
    late MockCcsysApprovalState state;

    // Backing store
    late String currentText;
    Comment? comment;

    setUp(() {
      handler = CcsysApprovalDraftHandler();
      vm = MockCcsysApprovalViewModel();
      controller = MockUnifiedEditorController();
      state = MockCcsysApprovalState();

      currentText = "";
      comment = null;

      // ---------------- ViewModel ----------------
      when(() => vm.controller).thenReturn(controller);

      when(() => vm.comment).thenAnswer((_) => comment);
      when(() => vm.comment = any()).thenAnswer((invocation) {
        comment = invocation.positionalArguments[0] as Comment?;
        return comment;
      });

      when(() => vm.state).thenReturn(state);
      when(() => vm.emit(any())).thenReturn(null);

      // - CRITICAL FIX
      when(() => state.copyWith()).thenReturn(state);

      // ---------------- Controller ----------------
      when(() => controller.currentText).thenAnswer((_) => currentText);
      when(() => controller.setText(any())).thenAnswer((invocation) async {
        currentText = invocation.positionalArguments[0] as String;
      });
    });

    // -------------------------------------------------------------------------
    // buildDraftData
    // -------------------------------------------------------------------------

    test("buildDraftData serializes editor text", () {
      currentText = "Draft comment";

      final draft = handler.buildDraftData(vm);

      expect(draft["comment"], "Draft comment");
    });

    test("buildDraftData allows empty text", () {
      final draft = handler.buildDraftData(vm);

      expect(draft["comment"], "");
    });

    // -------------------------------------------------------------------------
    // applyDraft
    // -------------------------------------------------------------------------

    test("applyDraft ignores empty payload", () {
      handler.applyDraft(vm, {});

      expect(comment, isNull);
      verifyNever(() => controller.setText(any()));
      verifyNever(() => vm.emit(any()));
    });

    test("applyDraft restores comment and updates editor", () {
      handler.applyDraft(vm, {
        "comment": "Approved",
      });

      expect(comment!.comment, "Approved");
      expect(currentText, "Approved");

      verify(() => controller.setText("Approved")).called(1);
      verify(() => vm.emit(any())).called(1);
    });

    test("applyDraft trims whitespace-only comment", () {
      handler.applyDraft(vm, {
        "comment": "   ",
      });

      expect(comment!.comment, isNull);
      verifyNever(() => controller.setText(any()));
      verify(() => vm.emit(any())).called(1);
    });

    test("applyDraft converts non-string comment", () {
      handler.applyDraft(vm, {
        "comment": 123,
      });

      expect(comment!.comment, "123");
      expect(currentText, "123");
    });
  });
}
