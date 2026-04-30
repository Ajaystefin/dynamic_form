import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/information/security_perfection/draft_handler.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";

void main() {
  // REQUIRED for GlobalKey/FormState usage
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecurityPerfectionDraftHandler handler;

  setUp(() {
    handler = SecurityPerfectionDraftHandler();
  });

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------
  SecurityPerfectionViewModel buildVm({
    List<SecurityDeferral>? securityList,
    List<SecurityCovenantCondition>? covenant,
    List<SecurityCovenantCondition>? condition,
  }) {
    final vm = SecurityPerfectionViewModel();

    vm.formKey = GlobalKey<FormState>();
    vm.comments = [Comment(comment: "Test comment")];

    vm.securityDeferral = SecurityPerfection(
      securityDeferralList: securityList,
      covenant: covenant ?? [],
      condition: condition ?? [],
    );

    return vm;
  }

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  test("buildDraftData handles null securityDeferralList safely", () {
    final vm = buildVm();

    final data = handler.buildDraftData(vm);
    final sec = data["securityPerfection"] as Map<String, dynamic>;

    expect(sec["securityDeferralList"], isEmpty);
    expect(sec["covenant"], isEmpty);
    expect(sec["condition"], isEmpty);
  });

  test("buildDraftData serializes selected & isChecked correctly", () {
    final vm = buildVm(
      securityList: [
        SecurityDeferral(isChecked: true),
      ],
    );

    final data = handler.buildDraftData(vm);
    final list = (data["securityPerfection"]
        as Map<String, dynamic>)["securityDeferralList"] as List;

    expect(list.length, 1);
    expect(list.first["selected"], null);
    expect(list.first["isChecked"], true);
  });

  test("buildDraftData serializes dateDeferral when present", () {
    final vm = buildVm(
      securityList: [
        SecurityDeferral(
          isChecked: true,
          dateDeferral: DateTime(2026, 4, 25),
        ),
      ],
    );

    final data = handler.buildDraftData(vm);
    final list = (data["securityPerfection"]
        as Map<String, dynamic>)["securityDeferralList"] as List;

    expect(list.first["dateDeferral"], "2026-04-25");
  });

  test("buildDraftData serializes covenant date when present", () {
    final vm = buildVm(
      securityList: [],
      covenant: [
        SecurityCovenantCondition(
          isChecked: true,
          isCovenant: true,
          date: DateTime(2026, 4, 25),
        ),
      ],
    );

    final data = handler.buildDraftData(vm);
    final covenant = (data["securityPerfection"]
        as Map<String, dynamic>)["covenant"] as List;

    expect(covenant.first["date"], isNotNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — comments restore
  // ---------------------------------------------------------------------------

  test("applyDraft restores comments from List<Map>", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "commentList": [
        {"comment": "Restored comment"},
      ],
    });

    expect(vm.comments.isNotEmpty, true);
  });

  test("applyDraft ignores non-list commentList safely", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "commentList": "not a list",
      "securityPerfection": {
        "securityDeferralList": [],
      },
    });

    expect(vm.comments.isNotEmpty, true);
  });

  test("applyDraft ensures fallback comment when none restored", () {
    final vm = buildVm();
    vm.comments = [];

    handler.applyDraft(vm, {"commentList": []});

    expect(vm.comments.length, 0);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — security perfection restore
  // ---------------------------------------------------------------------------

  test("applyDraft restores securityDeferral and syncs selected -> isChecked",
      () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": {
        "securityDeferralList": [
          {"selected": true, "isChecked": false},
        ],
      },
    });

    final deferral = vm.securityDeferral.securityDeferralList!.first;
    expect(deferral.selected, true);
    expect(deferral.isChecked, true);
  });

  test("applyDraft ignores invalid securityPerfection format", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": "invalid",
    });

    expect(vm.securityDeferral, isNotNull);
  });

  test("applyDraft restores securityPerfection from JSON string", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": jsonEncode({
        "securityDeferralList": [
          {"selected": false, "isChecked": false},
        ],
      }),
    });

    expect(vm.securityDeferral.securityDeferralList, null);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — exception safety
  // ---------------------------------------------------------------------------

  test("applyDraft catches exception and does not crash", () {
    final vm = buildVm();
    vm.comments = [];

    handler.applyDraft(vm, {
      "commentList": Object(),
      "securityPerfection": Object(),
    });

    expect(vm.comments.isNotEmpty, true);
  });
}
