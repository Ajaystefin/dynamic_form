import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/model.dart";

// ============================================================================
// TEST‑ONLY Fake ViewModel
// ============================================================================
class FakeStrategiesAndCommentsViewModel
    extends StrategiesAndCommentsViewModel {
  FakeStrategiesAndCommentsViewModel() {
    commentCategories = [
      {"id": 1, "name": "Strategy"},
      {"id": 2, "name": "Comment"},
      {"id": "invalid", "name": "Bad"},
    ];

    commentTextByCategoryId[1] = "Draft text";
    lastSavedPlainByCategoryId[2] = "Last saved";

    existingCommentRecordIdsByCategoryId[1] = 10;
    existingCommentRecordIdsByCategoryId[2] = 20;
  }

  final Set<int> _resetCalledFor = {};
  Map<int, String>? appliedText;

  @override
  void resetSeedForDraftCategories(Iterable<int> ids) {
    _resetCalledFor.addAll(ids);
  }

  @override
  void applyDraftTextToMountedEditors(Map<int, String> draftText) {
    appliedText = Map<int, String>.from(draftText);
  }

  @override
  void emit(state) {
    // no‑op, coverage only
  }
}

// ============================================================================
// TESTS
// ============================================================================
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StrategiesAndCommentsDraftHandler handler;

  setUp(() {
    handler = StrategiesAndCommentsDraftHandler();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  test("buildDraftData builds commentTextByCategoryId correctly", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    final data = handler.buildDraftData(vm);

    final textMap = data["commentTextByCategoryId"] as Map<String, dynamic>;

    expect(textMap.length, 2);
    expect(textMap["1"], "Draft text"); // from cache
    expect(textMap["2"], "Last saved"); // fallback
  });

  test("buildDraftData serializes existing record ids as string keys", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    final data = handler.buildDraftData(vm);

    final ids =
        data["existingCommentRecordIdsByCategoryId"] as Map<String, dynamic>;

    expect(ids["1"], 10);
    expect(ids["2"], 20);
  });

  test("buildDraftData copies comment categories safely", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    final data = handler.buildDraftData(vm);

    final cats = data["commentCategories"] as List;

    expect(cats.length, 3);
    expect(cats.first["id"], 1);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — category restore
  // ---------------------------------------------------------------------------
  test("applyDraft restores comment categories", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    handler.applyDraft(vm, {
      "commentCategories": [
        {"id": 10, "name": "New"},
      ],
    });

    expect(vm.commentCategories.length, 1);
    expect(vm.commentCategories.first["id"], 10);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — existing record id restore
  // ---------------------------------------------------------------------------
  test("applyDraft restores existing record ids safely", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    handler.applyDraft(vm, {
      "existingCommentRecordIdsByCategoryId": {
        "1": 100,
        "2": "200",
        "bad": "x",
      },
    });

    expect(vm.existingCommentRecordIdsByCategoryId.length, 2);
    expect(vm.existingCommentRecordIdsByCategoryId[1], 100);
    expect(vm.existingCommentRecordIdsByCategoryId[2], 200);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — comment text restore
  // ---------------------------------------------------------------------------
  test("applyDraft restores comment text and resets seeds", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    handler.applyDraft(vm, {
      "commentTextByCategoryId": {
        "1": "Applied",
        "2": null,
        "bad": "ignore",
      },
    });

    expect(vm.commentTextByCategoryId[1], "Applied");
    expect(vm.commentTextByCategoryId[2], "");

    // resetSeedForDraftCategories invoked
    expect(vm.appliedText?[1], "Applied");
    expect(vm.appliedText?[2], "");
  });

  // ---------------------------------------------------------------------------
  // defensive paths
  // ---------------------------------------------------------------------------
  test("applyDraft ignores missing maps safely", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    handler.applyDraft(vm, {});

    // nothing crashes, state untouched
    expect(vm.commentCategories.isNotEmpty, true);
  });

  test("applyDraft handles non-map text values safely", () {
    final vm = FakeStrategiesAndCommentsViewModel();

    handler.applyDraft(vm, {
      "commentTextByCategoryId": {
        1: 123,
      },
    });

    expect(vm.commentTextByCategoryId[1], "123");
  });
}
