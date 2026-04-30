import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/model.dart";

/// ---------------------------------------------------------------------------
/// MOCKS
/// ---------------------------------------------------------------------------

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

void main() {
  late QueriesAndResponsesDraftHandler handler;
  late QueriesAndResponsesViewModel vm;
  late MockUnifiedEditorController mockController;

  setUp(() {
    handler = QueriesAndResponsesDraftHandler();
    vm = QueriesAndResponsesViewModel();

    // ✅ Replace real HTML editor controller with a mock
    mockController = MockUnifiedEditorController();
    vm.controller = mockController;

    // ✅ Safe stubs
    when(() => mockController.currentText).thenReturn("");
    when(() => mockController.setText(any())).thenReturn(null);
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  test("buildDraftData returns initialText and canSubmit", () {
    when(() => mockController.currentText).thenReturn("draft text");
    vm.canSubmit = true;

    final draft = handler.buildDraftData(vm);

    expect(draft, isA<Map<String, dynamic>>());
    expect(draft["initialText"], "draft text");
    expect(draft["canSubmit"], true);
  });

  test("buildDraftData works when text is empty", () {
    when(() => mockController.currentText).thenReturn("");
    vm.canSubmit = false;

    final draft = handler.buildDraftData(vm);

    expect(draft["initialText"], "");
    expect(draft["canSubmit"], false);
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft restores initialText, pushes to editor, and sets canSubmit",
      () {
    handler.applyDraft(vm, {
      "initialText": "restored text",
      "canSubmit": true,
    });

    expect(vm.initialText, "restored text");
    expect(vm.canSubmit, true);

    // ✅ Editor interaction verified safely
    verify(() => mockController.setText("restored text")).called(1);
  });

  test("applyDraft updates only initialText when canSubmit missing", () {
    vm.canSubmit = false;

    handler.applyDraft(vm, {
      "initialText": "only text",
    });

    expect(vm.initialText, "only text");
    expect(vm.canSubmit, false);

    verify(() => mockController.setText("only text")).called(1);
  });

  test("applyDraft updates only canSubmit when initialText missing", () {
    vm.initialText = "before";

    handler.applyDraft(vm, {
      "canSubmit": true,
    });

    expect(vm.initialText, "before");
    expect(vm.canSubmit, true);

    verifyNever(() => mockController.setText(any()));
  });

  test("applyDraft ignores null values safely", () {
    vm.initialText = "before";
    vm.canSubmit = true;

    handler.applyDraft(vm, {
      "initialText": null,
      "canSubmit": null,
    });

    expect(vm.initialText, "before");
    expect(vm.canSubmit, true);

    verifyNever(() => mockController.setText(any()));
  });

  test("applyDraft ignores unrelated keys", () {
    vm.initialText = "before";
    vm.canSubmit = false;

    handler.applyDraft(vm, {
      "foo": "bar",
      "count": 123,
    });

    expect(vm.initialText, "before");
    expect(vm.canSubmit, false);

    verifyNever(() => mockController.setText(any()));
  });

  test("applyDraft does nothing when draft map is empty", () {
    vm.initialText = "before";
    vm.canSubmit = true;

    handler.applyDraft(vm, {});

    expect(vm.initialText, "before");
    expect(vm.canSubmit, true);

    verifyNever(() => mockController.setText(any()));
  });
}
