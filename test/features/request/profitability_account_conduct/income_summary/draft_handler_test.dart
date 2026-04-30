import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/model.dart";

class MockIncomeSummaryViewModel extends Mock
    implements IncomeSummaryViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("IncomeSummaryDraftHandler Tests", () {
    late MockIncomeSummaryViewModel vm;
    late IncomeSummaryDraftHandler handler;
    late TextEditingController rmCommentsController;
    late GlobalKey<FormState> formKey;

    // backing field for mocked property
    String? rmComments;

    setUp(() {
      vm = MockIncomeSummaryViewModel();
      handler = IncomeSummaryDraftHandler();
      rmCommentsController = TextEditingController();
      formKey = GlobalKey<FormState>();

      rmComments = "Initial RM comment";

      // ----- Stub getters -----
      when(() => vm.formKey).thenReturn(formKey);
      when(() => vm.rmCommentsController).thenReturn(rmCommentsController);
      when(() => vm.rmComments).thenAnswer((_) => rmComments);

      // ----- Stub setter -----
      when(() => vm.rmComments = any()).thenAnswer((invocation) {
        return rmComments = invocation.positionalArguments[0] as String?;
      });

      // NOTE:
      // applyDraft() wraps emit/state in try/catch,
      // so we intentionally do not stub vm.state or vm.emit(...)
      // unless you want strict verification for them.
    });

    tearDown(() {
      rmCommentsController.dispose();
    });

    test(
      "buildDraftData uses trimmed controller text when controller has value",
      () {
        // Arrange
        rmComments = "Old VM value";
        rmCommentsController.text = "   Updated from controller   ";

        // Act
        final draft = handler.buildDraftData(vm);

        // Assert
        expect(draft["rmComments"], "Updated from controller");
      },
    );

    test(
      "buildDraftData falls back to vm.rmComments"
      " when controller text is empty",
      () {
        // Arrange
        rmComments = "Saved RM comment";
        rmCommentsController.text = "   ";

        // Act
        final draft = handler.buildDraftData(vm);

        // Assert
        expect(draft["rmComments"], "Saved RM comment");
      },
    );

    test(
        "buildDraftData returns "
        "null when both "
        "controller and vm value are empty", () {
      // Arrange
      rmComments = "   ";
      rmCommentsController.text = "   ";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(draft["rmComments"], isNull);
    });

    test("applyDraft restores direct rmComments and updates controller", () {
      // Arrange
      final rawData = {
        "rmComments": " Restored comment from draft ",
      };

      // Act
      handler.applyDraft(vm, rawData);

      // Assert
      expect(rmComments, "Restored comment from draft");
      expect(rmCommentsController.text, "Restored comment from draft");
      verify(() => vm.rmComments = "Restored comment from draft").called(1);
    });

    test("applyDraft supports payload as JSON string", () {
      // Arrange
      final rawData = {
        "payload": '{"rmComments":"JSON payload comment"}',
      };

      // Act
      handler.applyDraft(vm, rawData);

      // Assert
      expect(rmComments, "JSON payload comment");
      expect(rmCommentsController.text, "JSON payload comment");
      verify(() => vm.rmComments = "JSON payload comment").called(1);
    });

    test("applyDraft supports payload as nested map", () {
      // Arrange
      final rawData = {
        "payload": {
          "rmComments": "Nested map payload comment",
        },
      };

      // Act
      handler.applyDraft(vm, rawData);

      // Assert
      expect(rmComments, "Nested map payload comment");
      expect(rmCommentsController.text, "Nested map payload comment");
      verify(() => vm.rmComments = "Nested map payload comment").called(1);
    });

    test("applyDraft trims whitespace and sets null when rmComments is blank",
        () {
      // Arrange
      rmComments = "Existing comment";
      rmCommentsController.text = "Existing controller text";

      final rawData = {
        "rmComments": "    ",
      };

      // Act
      handler.applyDraft(vm, rawData);

      // Assert
      expect(rmComments, isNull);
      expect(rmCommentsController.text, "");
      verify(() => vm.rmComments = null).called(1);
    });

    test("applyDraft does nothing when rawData is empty", () {
      // Arrange
      rmComments = "Existing comment";
      rmCommentsController.text = "Existing controller text";

      // Act
      handler.applyDraft(vm, {});

      // Assert
      expect(rmComments, "Existing comment");
      expect(rmCommentsController.text, "Existing controller text");
      verifyNever(() => vm.rmComments = any());
    });

    test("applyDraft ignores malformed payload JSON and falls back to rawData",
        () {
      // Arrange
      final rawData = {
        "payload": "{bad json",
        "rmComments": "Fallback rawData comment",
      };

      // Act
      handler.applyDraft(vm, rawData);

      // Assert
      expect(rmComments, "Fallback rawData comment");
      expect(rmCommentsController.text, "Fallback rawData comment");
      verify(() => vm.rmComments = "Fallback rawData comment").called(1);
    });

    test(
        "applyDraft handles missing rmComments key by clearing controller/model",
        () {
      // Arrange
      rmComments = "Existing comment";
      rmCommentsController.text = "Existing controller text";

      final rawData = {
        "someOtherKey": "value",
      };

      // Act
      handler.applyDraft(vm, rawData);

      // Assert
      expect(rmComments, isNull);
      expect(rmCommentsController.text, "");
      verify(() => vm.rmComments = null).called(1);
    });
  });
}
