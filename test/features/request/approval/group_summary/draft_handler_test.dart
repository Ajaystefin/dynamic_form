import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/approval/group_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/group_summary/model.dart";
import "package:wcas_frontend/features/request/approval/group_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";

// -----------------------------------------------------------------------------
// Mocks
// -----------------------------------------------------------------------------

class MockGroupSummaryViewModel extends Mock implements GroupSummaryViewModel {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockGroupSummaryState extends Mock implements GroupSummaryState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Required for any<GroupSummaryState>()
  setUpAll(() {
    registerFallbackValue(MockGroupSummaryState());
  });

  group("GroupSummaryTabsDraftHandler Tests", () {
    late GroupSummaryTabsDraftHandler handler;
    late MockGroupSummaryViewModel vm;
    late MockUnifiedEditorController controller;
    late MockGroupSummaryState state;

    // Backing store
    late String currentText;
    Comment? comment;

    setUp(() {
      handler = GroupSummaryTabsDraftHandler();
      vm = MockGroupSummaryViewModel();
      controller = MockUnifiedEditorController();
      state = MockGroupSummaryState();

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

      expect(draft["strategyComment"], "Draft comment");
    });

    test("buildDraftData allows empty text", () {
      final draft = handler.buildDraftData(vm);

      expect(draft["strategyComment"], "");
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
        "strategyComment": "Approved",
      });

      expect(comment!.comment, "Approved");
      expect(currentText, "Approved");

      verify(() => controller.setText("Approved")).called(1);
      verify(() => vm.emit(any())).called(1);
    });

    test("applyDraft trims whitespace-only comment", () {
      handler.applyDraft(vm, {
        "strategyComment": "   ",
      });

      expect(comment, isNull);
      verifyNever(() => controller.setText(any()));
      verifyNever(() => vm.emit(any()));
    });

    test("applyDraft converts non-string comment", () {
      handler.applyDraft(vm, {
        "strategyComment": 123,
      });

      expect(comment!.comment, "123");
      expect(currentText, "123");
    });
  });
}
