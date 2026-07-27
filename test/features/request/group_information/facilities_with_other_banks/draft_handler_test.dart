import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/draft_handler.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";

class MockFacilitiesWithOtherBanksViewModel extends Mock
    implements FacilitiesWithOtherBanksViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("FacilitiesWithOtherBanksDraftHandler Tests", () {
    late MockFacilitiesWithOtherBanksViewModel vm;
    late FacilitiesWithOtherBanksDraftHandler handler;

    // Backing variables for mocked properties
    late String? strategyComment;
    late String? strategyCommentCBRB;
    late GlobalKey<FormState> formKey;

    // Real controllers used by the handler
    late TextEditingController strategyCommentController;
    late TextEditingController strategyCommentCBRBController;

    setUp(() {
      vm = MockFacilitiesWithOtherBanksViewModel();
      handler = FacilitiesWithOtherBanksDraftHandler();

      strategyComment = "Initial strategy comment";
      strategyCommentCBRB = "Initial CBRB comment";
      formKey = GlobalKey<FormState>();

      strategyCommentController =
          TextEditingController(text: strategyComment ?? "");
      strategyCommentCBRBController =
          TextEditingController(text: strategyCommentCBRB ?? "");

      // Keep backing vars in sync if handler writes directly to controller.text
      strategyCommentController.addListener(() {
        strategyComment = strategyCommentController.text;
      });

      strategyCommentCBRBController.addListener(() {
        strategyCommentCBRB = strategyCommentCBRBController.text;
      });

      // ----- Stub getters -----
      when(() => vm.formKey).thenReturn(formKey);
      when(() => vm.strategyComment).thenAnswer((_) => strategyComment);
      when(() => vm.strategyCommentCBRB).thenAnswer((_) => strategyCommentCBRB);

      // IMPORTANT: handler reads/writes controllers
      when(() => vm.strategyCommentController)
          .thenReturn(strategyCommentController);

      // If your actual VM property is named differently, replace only this
      // line.
      when(() => vm.strategyCommentCBRBController)
          .thenReturn(strategyCommentCBRBController);

      // ----- Stub setters -----
      when(() => vm.strategyComment = any()).thenAnswer((invocation) {
        final value = invocation.positionalArguments[0] as String?;
        strategyComment = value;
        strategyCommentController.text = value ?? "";
        return value;
      });

      when(() => vm.strategyCommentCBRB = any()).thenAnswer((invocation) {
        final value = invocation.positionalArguments[0] as String?;
        strategyCommentCBRB = value;
        strategyCommentCBRBController.text = value ?? "";
        return value;
      });

      // NOTE:
      // We intentionally do NOT stub vm.state / vm.emit(...)
      // because applyDraft() may wrap those in try/catch.
      // Any missing stub there is often swallowed by production code,
      // and these tests stay focused on draft serialization/restore behavior.
    });

    tearDown(() {
      strategyCommentController.dispose();
      strategyCommentCBRBController.dispose();
    });

    test("buildDraftData returns correct serialized fields", () {
      // Arrange
      strategyComment = "Business strategy updated";
      strategyCommentCBRB = "CBRB strategy updated";
      strategyCommentController.text = "Business strategy updated";
      strategyCommentCBRBController.text = "CBRB strategy updated";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["strategyComment"], "Business strategy updated");
      expect(draft["strategyCommentCBRB"], "CBRB strategy updated");
    });

    test("buildDraftData converts empty/whitespace values to null", () {
      // Arrange
      strategyComment = "   ";
      strategyCommentCBRB = "";
      strategyCommentController.text = "   ";
      strategyCommentCBRBController.text = "";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["strategyComment"], isNull);
      expect(draft["strategyCommentCBRB"], isNull);
    });

    test("buildDraftData preserves null values as null", () {
      // Arrange
      strategyComment = null;
      strategyCommentCBRB = null;
      strategyCommentController.text = "";
      strategyCommentCBRBController.text = "";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["strategyComment"], isNull);
      expect(draft["strategyCommentCBRB"], isNull);
    });

    test("applyDraft restores valid fields into ViewModel", () {
      // Arrange
      final draft = {
        "strategyComment": "Restored strategy comment",
        "strategyCommentCBRB": "Restored CBRB comment",
      };

      // Act
      handler.applyDraft(vm, draft);

      // Assert
      expect(strategyComment, "Restored strategy comment");
      expect(strategyCommentCBRB, "Restored CBRB comment");

      expect(strategyCommentController.text, "Restored strategy comment");
      expect(strategyCommentCBRBController.text, "Restored CBRB comment");

      verify(() => vm.strategyComment = "Restored strategy comment").called(1);
      verify(() => vm.strategyCommentCBRB = "Restored CBRB comment").called(1);
    });

    test("applyDraft ignores null/empty/whitespace values", () {
      // Arrange
      strategyComment = "Original strategy";
      strategyCommentCBRB = "Original CBRB";
      strategyCommentController.text = "Original strategy";
      strategyCommentCBRBController.text = "Original CBRB";

      final draft = {
        "strategyComment": "   ",
        "strategyCommentCBRB": null,
      };

      // Act
      handler.applyDraft(vm, draft);

      // Assert
      expect(strategyComment, "Original strategy");
      expect(strategyCommentCBRB, "Original CBRB");

      expect(strategyCommentController.text, "Original strategy");
      expect(strategyCommentCBRBController.text, "Original CBRB");

      verifyNever(() => vm.strategyComment = any());
      verifyNever(() => vm.strategyCommentCBRB = any());
    });

    test("applyDraft does nothing when draft map is empty", () {
      // Arrange
      strategyComment = "Original strategy";
      strategyCommentCBRB = "Original CBRB";
      strategyCommentController.text = "Original strategy";
      strategyCommentCBRBController.text = "Original CBRB";

      // Act
      handler.applyDraft(vm, {});

      // Assert
      expect(strategyComment, "Original strategy");
      expect(strategyCommentCBRB, "Original CBRB");

      expect(strategyCommentController.text, "Original strategy");
      expect(strategyCommentCBRBController.text, "Original CBRB");

      verifyNever(() => vm.strategyComment = any());
      verifyNever(() => vm.strategyCommentCBRB = any());
    });

    test("applyDraft updates only the provided valid field", () {
      // Arrange
      strategyComment = "Original strategy";
      strategyCommentCBRB = "Original CBRB";
      strategyCommentController.text = "Original strategy";
      strategyCommentCBRBController.text = "Original CBRB";

      final draft = {
        "strategyComment": "Only strategy restored",
        "strategyCommentCBRB": "   ", // invalid => should be ignored
      };

      // Act
      handler.applyDraft(vm, draft);

      // Assert
      expect(strategyComment, "Only strategy restored");
      expect(strategyCommentCBRB, "Original CBRB");

      expect(strategyCommentController.text, "Only strategy restored");
      expect(strategyCommentCBRBController.text, "Original CBRB");

      verify(() => vm.strategyComment = "Only strategy restored").called(1);
      verifyNever(() => vm.strategyCommentCBRB = any());
    });
  });
}
