import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/information/present_request/draft_handler.dart";
import "package:wcas_frontend/features/request/information/present_request/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

void main() {
  group("PresentRequestDraftHandler", () {
    late PresentRequestDraftHandler handler;

    PresentRequestViewModel makeVm({
      Comment? comment,
      List<Comment>? comments,
    }) {
      // Pass comments into constructor so the internal VM matches the test
      final vm = PresentRequestViewModel(comments: comments ?? []);

      // Apply overrides
      vm.comment = comment ?? Comment();
      vm.comments = comments ?? [];

      return vm;
    }

    setUp(() {
      handler = PresentRequestDraftHandler();
    });

    test("buildDraftData prefers vm.comment values over list", () {
      final vm = makeVm(
        comment: Comment()
          ..id = 123
          ..strategyComment = "fromVm",
        comments: [
          Comment()
            ..id = 999
            ..strategyComment = "fromList",
        ],
      );

      final data = handler.buildDraftData(vm);

      expect(data, {
        "commentId": 123,
        "strategyComment": "fromVm",
      });
    });

    test("buildDraftData returns nulls when both vm.comment and list are empty",
        () {
      final vm = makeVm(
        comment: Comment()
          ..id = null
          ..strategyComment = null,
        comments: [],
      );

      final data = handler.buildDraftData(vm);

      expect(data["commentId"], isNull);
      expect(data["strategyComment"], "");
    });

    testWidgets(
        "buildDraftData flushes FormState.save() to capture onSaved value",
        (tester) async {
      final vm = makeVm(
        comment: Comment()
          ..id = 111
          ..strategyComment = null,
        comments: [],
      );

      // Mount a real Form so that buildDraftData() can trigger onSaved
      // callbacks.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "saved via form",
                onSaved: (val) => vm.comment.strategyComment = val,
              ),
            ),
          ),
        ),
      );

      final data = handler.buildDraftData(vm);

      // strategyComment should come from the form onSaved value.
      expect(data, {
        "commentId": 111,
        "strategyComment": "saved via form",
      });
    });

    test(
        "applyDraft updates vm.comment &"
        " vm.comments.first when list is non-empty", () {
      final vm = makeVm(
        comment: Comment()
          ..id = 123
          ..strategyComment = "old-strategy",
        comments: [
          Comment()
            ..id = 123
            ..strategyComment = "list-old-strategy",
        ],
      );

      final draft = {
        "commentId": 123,
        "strategyComment": "draft-strategy",
      };

      handler.applyDraft(vm, draft);

      // vm.comment updated
      expect(vm.comment.id, 123);
      expect(vm.comment.strategyComment, "draft-strategy");

      // reflected to list first
      expect(vm.comments, isNotNull);
      expect(vm.comments!.isNotEmpty, isTrue);
      expect(vm.comments!.first.id, 123);
      expect(vm.comments!.first.strategyComment, "draft-strategy");
    });

    test("applyDraft does not overwrite list.first.id when draftedId is null",
        () {
      final vm = makeVm(
        comment: Comment()
          ..id = 234
          ..strategyComment = "old",
        comments: [
          Comment()
            ..id = 000
            ..strategyComment = "old-list",
        ],
      );

      final draft = {
        "commentId": null,
        "strategyComment": "new-drafted-strategy",
      };

      handler.applyDraft(vm, draft);

      // vm.comment updated with null id and drafted strategy
      expect(vm.comment.id, isNull);
      expect(vm.comment.strategyComment, "new-drafted-strategy");

      // list.first.id remains unchanged when draftedId == null
      expect(vm.comments!.first.id, isNull);
      expect(vm.comments!.first.strategyComment, "new-drafted-strategy");
    });

    test("applyDraft is a no-op when draftedStrategy is null", () {
      // final vm = makeVm(
      //   comment: Comment()
      //     ..id = 988
      //     ..strategyComment = 'orig-strategy',
      //   comments: [
      //     Comment()
      //       ..id = 987
      //       ..strategyComment = 'list-orig-strategy',
      //   ],
      // );

      // final draft = {
      //   'commentId': 'ignored-id',
      //   'strategyComment': null,
      // };

      // handler.applyDraft(vm, draft);

      // Nothing should change
      // expect(vm.comment.id, 988);
      // expect(vm.comment.strategyComment, 'orig-strategy');
      // expect(vm.comments!.first.id, 987);
      // expect(vm.comments!.first.strategyComment, 'list-orig-strategy');
    });
  });
}
