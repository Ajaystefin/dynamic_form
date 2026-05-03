import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// A lightweight test helper to construct a VM in a controllable state.
class _TestVmBuilder {
  _TestVmBuilder() : vm = ConditionsSummaryViewModel();
  final ConditionsSummaryViewModel vm;

  _TestVmBuilder withVmComment(String? text) {
    vm.comment.comment = text;
    return this;
  }

  _TestVmBuilder withCommentsList(List<String> comments) {
    vm.comments = comments.map((t) => Comment(comment: t)).toList();
    return this;
  }

  _TestVmBuilder withPlainControllerText(String text) {
    vm.controller.text = text;
    return this;
  }
}

void main() {
  group("ConditionsSummaryDraftHandler", () {
    late ConditionsSummaryDraftHandler handler;

    setUp(() {
      handler = ConditionsSummaryDraftHandler();
    });

    group("buildDraftData", () {
      testWidgets("calls FormState.save() to flush onSaved callbacks",
          (tester) async {
        final vm = _TestVmBuilder().vm;
        var onSavedInvoked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: vm.formKey,
                child: TextFormField(
                  initialValue: "sample",
                  onSaved: (_) {
                    onSavedInvoked = true;
                  },
                ),
              ),
            ),
          ),
        );

        final data = handler.buildDraftData(vm);
        expect(data, isA<Map<String, dynamic>>());
        expect(
          onSavedInvoked,
          isTrue,
          reason: "buildDraftData must flush FormState.save()"
              " to capture onSaved values.",
        );
      });

      test("prefers vm.comment.comment over comments list and controller", () {
        final vm = _TestVmBuilder()
            .withVmComment("fromVm")
            .withCommentsList(["older", "fromList"])
            .withPlainControllerText("fromController")
            .vm;

        final data = handler.buildDraftData(vm);
        expect(data["lastComment"], "fromVm");
      });

      test(
          "falls back to vm.comments.last.comment when vm.comment is empty/null",
          () {
        final vm = _TestVmBuilder()
            .withVmComment(null)
            .withCommentsList(["c1", "fromList"])
            .withPlainControllerText("fromController")
            .vm;

        final data = handler.buildDraftData(vm);
        expect(data["lastComment"], "fromList");
      });

      test("falls back to controller text when vm.comment and list are empty",
          () {
        final vm = _TestVmBuilder()
            .withVmComment("   ")
            .withCommentsList([])
            .withPlainControllerText("fromController")
            .vm;

        final data = handler.buildDraftData(vm);
        expect(data["lastComment"], "fromController");
      });

      test("returns null lastComment when nothing is available", () {
        final vm = _TestVmBuilder()
            .withVmComment(null)
            .withCommentsList([])
            .withPlainControllerText("")
            .vm;

        final data = handler.buildDraftData(vm);
        expect(data["lastComment"], isNull);
      });
    });

    group("applyDraft", () {
      test("no-op when lastComment is null", () {
        final vm = _TestVmBuilder()
            .withVmComment(null)
            .withCommentsList([])
            .withPlainControllerText("")
            .vm;

        handler.applyDraft(vm, {"lastComment": null});

        expect(vm.comment.comment, isNull);
        expect(vm.comments, isEmpty);
        expect(vm.controller.text, "");
      });

      test(
          "writes restored text to "
          "vm.comment, creates last "
          "comment if list is empty, and updates controller", () async {
        final vm = _TestVmBuilder()
            .withVmComment(null)
            .withCommentsList([]) // empty list
            .withPlainControllerText("")
            .vm;

        await runZonedGuarded(
          () async {
            ConditionsSummaryDraftHandler()
                .applyDraft(vm, {"lastComment": "restored text"});
            await Future<void>.delayed(const Duration(milliseconds: 0));
          },
          (error, stack) {},
        );

        expect(vm.comment.comment, "restored text");
        expect(vm.controller.text, "restored text");
        expect(vm.comments.length, 1);
        expect(vm.comments.last.comment, "restored text");

        // Optional: Uncomment to inspect the suppressed error
        // if (zoneError != null) {
        //   debugPrint('Suppressed editor load error: $zoneError\n$zoneStack');
        // }
      });
    });
  });
}
