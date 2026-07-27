import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/state.dart";

// -----------------------------------------------------------------------------
// Mocks
// -----------------------------------------------------------------------------
class MockRequestForLimitReleaseViewModel extends Mock
    implements RequestForLimitReleaseViewModel {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockRequestForLimitReleaseState extends Mock
    implements RequestForLimitReleaseState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(MockRequestForLimitReleaseState());
  });

  group("RequestForLimitReleaseDraftHandler", () {
    late RequestForLimitReleaseDraftHandler handler;
    late MockRequestForLimitReleaseViewModel vm;
    late MockUnifiedEditorController controller;
    late MockRequestForLimitReleaseState state;

    // Backing stores
    late String currentText;
    late String selectedUserId;
    late String selectedStage;

    setUp(() {
      handler = RequestForLimitReleaseDraftHandler();
      vm = MockRequestForLimitReleaseViewModel();
      controller = MockUnifiedEditorController();
      state = MockRequestForLimitReleaseState();

      currentText = "";
      selectedUserId = "";
      selectedStage = "";

      // ---- ViewModel wiring ----
      when(() => vm.controller).thenReturn(controller);

      when(() => vm.selectedUserId).thenAnswer((_) => selectedUserId);
      when(() => vm.selectedUserId = any()).thenAnswer((inv) {
        return selectedUserId = inv.positionalArguments[0] as String;
      });

      when(() => vm.selectedStage).thenAnswer((_) => selectedStage);
      when(() => vm.selectedStage = any()).thenAnswer((inv) {
        return selectedStage = inv.positionalArguments[0] as String;
      });

      when(() => vm.initialText).thenAnswer((_) => currentText);
      when(() => vm.initialText = any()).thenAnswer((inv) {
        return currentText = inv.positionalArguments[0] as String;
      });

      when(() => vm.state).thenReturn(state);
      when(() => vm.emit(any())).thenReturn(null);
      when(() => state.copyWith()).thenReturn(state);

      // ---- Controller wiring ----
      // Bug 2 fix: buildDraftData reads controller.currentText (not
      // initialText)
      when(() => controller.currentText).thenAnswer((_) => currentText);
      when(() => controller.setText(any())).thenAnswer((inv) async {
        currentText = inv.positionalArguments[0] as String;
      });
    });

    // -------------------------------------------------------------------------
    // buildDraftData
    // -------------------------------------------------------------------------

    test("buildDraftData serializes live editor text via currentText", () {
      currentText = "<p>Hello draft</p>";

      final data = handler.buildDraftData(vm);

      // Bug 2 fix: reads controller.currentText, NOT initialText
      expect(data["htmlComment"], "<p>Hello draft</p>");
    });

    test("buildDraftData returns empty string when editor is empty", () {
      currentText = "";

      final data = handler.buildDraftData(vm);

      expect(data["htmlComment"], "");
    });

    test("buildDraftData serializes selectedUserId and selectedStage", () {
      currentText = "<p>content</p>";
      selectedUserId = "user-42";
      selectedStage = "StageB";

      final data = handler.buildDraftData(vm);

      expect(data["selectedUserId"], "user-42");
      expect(data["selectedStage"], "StageB");
    });

    test("buildDraftData with null-equivalent empty fields", () {
      currentText = "";
      selectedUserId = "";
      selectedStage = "";

      final data = handler.buildDraftData(vm);

      expect(data["htmlComment"], "");
      expect(data["selectedUserId"], "");
      expect(data["selectedStage"], "");
    });

    // -------------------------------------------------------------------------
    // applyDraft
    // -------------------------------------------------------------------------

    test("applyDraft restores HTML, userId, and stage", () {
      final draft = {
        "htmlComment": "<div>Restored</div>",
        "selectedUserId": "12",
        "selectedStage": "StageA",
      };

      handler.applyDraft(vm, draft);

      expect(currentText, "<div>Restored</div>");
      expect(selectedUserId, "12");
      expect(selectedStage, "StageA");
      verify(() => controller.setText("<div>Restored</div>")).called(1);
      verify(() => vm.emit(any())).called(1);
    });

    test("applyDraft ignores null htmlComment — does not call setText", () {
      handler.applyDraft(vm, {
        "htmlComment": null,
        "selectedUserId": "u1",
        "selectedStage": "S1",
      });

      verifyNever(() => controller.setText(any()));
      expect(selectedUserId, "u1");
      expect(selectedStage, "S1");
      verify(() => vm.emit(any())).called(1);
    });

    test("applyDraft ignores whitespace-only htmlComment", () {
      handler.applyDraft(vm, {"htmlComment": "   "});

      verifyNever(() => controller.setText(any()));
    });

    test("applyDraft converts non-string values to string", () {
      handler.applyDraft(vm, {
        "htmlComment": 999,
        "selectedUserId": 42,
        "selectedStage": true,
      });

      expect(currentText, "999");
      expect(selectedUserId, "42");
      expect(selectedStage, "true");
    });

    test("applyDraft with empty map does not crash or call setText", () {
      handler.applyDraft(vm, {});

      verifyNever(() => controller.setText(any()));
    });
  });
}
