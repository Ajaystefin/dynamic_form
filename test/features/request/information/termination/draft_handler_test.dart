// test/termination_draft_handler_test.dart
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/information/termination/draft_handler.dart";
import "package:wcas_frontend/features/request/information/termination/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

void main() {
  group("TerminationDraftHandler", () {
    testWidgets(
        "buildDraftData flushes Form.onSaved and serializes comment fields",
        (tester) async {
      final vm = TerminationViewModel();
      final handler = TerminationDraftHandler();

      // Ensure there is a comment object to write into.
      vm.comment = Comment()..comment = "";

      // Mount a Form tied to vm.formKey; onSaved writes back into vm.comment
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "Typed reason details",
                onSaved: (value) => vm.comment!.comment = value ?? "",
              ),
            ),
          ),
        ),
      );

      // Act: handler should call vm.formKey.currentState?.save() internally
      final data = handler.buildDraftData(vm);

      // Assert: the 'comment' field reflects the flushed value
      expect(data, contains("comment"));
      expect(data["comment"], equals("Typed reason details"));
    });

    test(
        "applyDraft restores reasonList, categoryId"
        " (string -> int), and comment", () {
      final vm = TerminationViewModel();
      final handler = TerminationDraftHandler();

      // Provide a place to mirror reasonList in the UI (first review comment)
      vm.getReviewComments = [Comment()];

      final Map<String, dynamic> draft = {
        "reasonList": "42", // string form (typical JSON)
        "categoryId": "7", // also string -> should parse to int
        "comment": "Please terminate due to X.",
      };

      // Act
      handler.applyDraft(vm, draft);

      // Assert: vm.comment is present and hydrated
      expect(vm.comment, isNotNull);
      expect(vm.comment!.reasonList, equals("42")); // stored as string
      expect(vm.comment!.categoryId, equals(7)); // parsed as int
      expect(vm.comment!.comment, equals("Please terminate due to X."));

      // Mirror into getReviewComments.first.reasonList (your screen’s pattern)
      expect(vm.getReviewComments, isNotNull);
      expect(vm.getReviewComments!.first.reasonList, equals("42"));
    });

    test("applyDraft restores categoryId when provided as int", () {
      final vm = TerminationViewModel();
      final handler = TerminationDraftHandler();

      final Map<String, dynamic> draft = {
        "reasonList": "11",
        "categoryId": 5, // already int
        "comment": "Direct int id test",
      };

      handler.applyDraft(vm, draft);

      expect(vm.comment, isNotNull);
      expect(vm.comment!.categoryId, equals(5));
      expect(vm.comment!.reasonList, equals("11"));
      expect(vm.comment!.comment, equals("Direct int id test"));
    });

    test("applyDraft with empty draft does not throw and leaves VM unchanged",
        () {
      final vm = TerminationViewModel();
      final handler = TerminationDraftHandler();

      // Seed with some values
      vm.comment = Comment()
        ..reasonList = "seed"
        ..categoryId = 9
        ..comment = "keep me";

      handler.applyDraft(vm, <String, dynamic>{});

      // Unchanged
      expect(vm.comment!.reasonList, equals("seed"));
      expect(vm.comment!.categoryId, equals(9));
      expect(vm.comment!.comment, equals("keep me"));
    });

    test("round-trip: applyDraft -> buildDraftData preserves values", () {
      final vm = TerminationViewModel();
      final handler = TerminationDraftHandler();

      final draft = <String, dynamic>{
        "reasonList": "77",
        "categoryId": "21",
        "comment": "Round-trip test",
      };

      handler.applyDraft(vm, draft);
      final rebuilt = handler.buildDraftData(vm);

      expect(rebuilt["reasonList"], equals("77"));
      expect(
        rebuilt["categoryId"],
        equals(21),
      ); // parsed to int in VM, still emitted as int
      expect(rebuilt["comment"], equals("Round-trip test"));
    });
  });
}
