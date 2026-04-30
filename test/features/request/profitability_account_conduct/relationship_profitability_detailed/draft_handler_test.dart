import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/model.dart";

void main() {
  group("RelationshipProfitabilityDetailedDraftHandler", () {
    late RelationshipProfitabilityDetailedDraftHandler handler;

    setUp(() {
      handler = RelationshipProfitabilityDetailedDraftHandler();
    });

    testWidgets(
      "buildDraftData() flushes latest field value and"
      " returns JSON with updated strategyComment",
      (tester) async {
        // Arrange
        final vm = RelationshipProfitabilityDetailedViewModel();
        vm.strategyComment = "initial";
        vm.strategyCommentController.text = "initial";

        final host = _TestHostWidget(
          vm: vm,
          buildFields: (context, vm) {
            return TextFormField(
              controller: vm.strategyCommentController,
              onChanged: (value) {
                // Keep VM state in sync even though init() is not called in
                // test.
                vm.strategyComment = value;
              },
              onSaved: (value) {
                vm.strategyComment = value ?? "";
              },
            );
          },
        );

        await tester.pumpWidget(MaterialApp(home: host));

        // Act: simulate user typing
        final field = find.byType(TextFormField);
        expect(field, findsOneWidget);

        await tester.enterText(field, "updated via UI before autosave");
        await tester.pump();

        final draft = handler.buildDraftData(vm);

        // Assert
        expect(
          vm.strategyCommentController.text,
          "updated via UI before autosave",
        );
        expect(vm.strategyComment, "updated via UI before autosave");

        expect(
          draft,
          equals(<String, dynamic>{
            "strategyComment": "updated via UI before autosave",
          }),
        );
      },
    );

    test("buildDraftData() returns current strategyComment when already set",
        () {
      // Arrange
      final vm = RelationshipProfitabilityDetailedViewModel();
      vm.strategyComment = "already in vm";
      vm.strategyCommentController.text = "already in vm";

      // Act
      final draft = handler.buildDraftData(vm);

      // Assert
      expect(
        draft,
        equals(<String, dynamic>{
          "strategyComment": "already in vm",
        }),
      );
    });

    test("applyDraft() restores strategyComment when present", () {
      // Arrange
      final vm = RelationshipProfitabilityDetailedViewModel();
      vm.strategyComment = "existing";
      vm.strategyCommentController.text = "existing";

      final data = <String, dynamic>{
        "strategyComment": "restored from draft",
      };

      // Act
      handler.applyDraft(vm, data);

      // Assert
      expect(vm.strategyComment, equals("restored from draft"));

      // If handler syncs controller too, this should also pass.
      // Keeping this assertion is useful because the screen uses the
      // controller.
      expect(vm.strategyCommentController.text, equals("restored from draft"));
    });

    test("applyDraft() keeps existing strategyComment when key is missing", () {
      // Arrange
      final vm = RelationshipProfitabilityDetailedViewModel();
      vm.strategyComment = "existing";
      vm.strategyCommentController.text = "existing";

      // Act
      handler.applyDraft(vm, <String, dynamic>{});

      // Assert
      expect(vm.strategyComment, equals("existing"));
      expect(vm.strategyCommentController.text, equals("existing"));
    });

    test("applyDraft() keeps existing strategyComment when value is null", () {
      // Arrange
      final vm = RelationshipProfitabilityDetailedViewModel();
      vm.strategyComment = "existing";
      vm.strategyCommentController.text = "existing";

      // Act
      handler.applyDraft(vm, <String, dynamic>{
        "strategyComment": null,
      });

      // Assert
      expect(vm.strategyComment, equals("existing"));
      expect(vm.strategyCommentController.text, equals("existing"));
    });

    test("applyDraft() allows empty string when explicitly provided", () {
      // Arrange
      final vm = RelationshipProfitabilityDetailedViewModel();
      vm.strategyComment = "existing";
      vm.strategyCommentController.text = "existing";

      // Act
      handler.applyDraft(vm, <String, dynamic>{
        "strategyComment": "",
      });

      // Assert
      expect(vm.strategyComment, equals(""));
      expect(vm.strategyCommentController.text, equals(""));
    });
  });
}

/// Tiny host widget that wires Form(key: vm.formKey) and allows injecting
/// form fields that write into the VM.
class _TestHostWidget extends StatelessWidget {
  const _TestHostWidget({
    required this.vm,
    required this.buildFields,
  });

  final RelationshipProfitabilityDetailedViewModel vm;
  final Widget Function(
    BuildContext context,
    RelationshipProfitabilityDetailedViewModel vm,
  ) buildFields;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: vm.formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: buildFields(context, vm),
        ),
      ),
    );
  }
}
