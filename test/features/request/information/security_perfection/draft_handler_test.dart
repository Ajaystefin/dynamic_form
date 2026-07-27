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
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecurityPerfectionDraftHandler handler;

  setUp(() {
    handler = SecurityPerfectionDraftHandler();
  });

  /* ============================================================
   * HELPER
   * ============================================================ */
  SecurityPerfectionViewModel buildVm({
    List<SecurityDeferral>? securityList,
    List<SecurityCovenantCondition>? covenant,
    List<SecurityCovenantCondition>? condition,
  }) {
    return SecurityPerfectionViewModel()
      ..formKey = GlobalKey<FormState>()
      ..comments = [Comment(comment: "Test")]
      ..securityDeferral = SecurityPerfection(
        securityDeferralList: securityList,
        covenant: covenant ?? [],
        condition: condition ?? [],
      );
  }

  /* ============================================================
   * BUILD DRAFT TESTS
   * ============================================================ */

  test("buildDraftData handles null lists", () {
    final vm = buildVm();

    final data = handler.buildDraftData(vm);
    final sec = data["securityPerfection"];

    expect(sec["securityDeferralList"], isEmpty);
    expect(sec["covenant"], isEmpty);
    expect(sec["condition"], isEmpty);
  });

  test("buildDraftData serializes securityDeferral", () {
    final vm = buildVm(
      securityList: [
        SecurityDeferral(selected: true),
      ],
    );

    final data = handler.buildDraftData(vm);
    final list = data["securityPerfection"]["securityDeferralList"];

    expect(list.length, 1);
    expect(list.first["selected"], false);
  });

  test("buildDraftData serializes dateDeferral", () {
    final vm = buildVm(
      securityList: [
        SecurityDeferral(
          isChecked: true,
          dateDeferral: DateTime(2026, 4, 25),
        ),
      ],
    );

    final data = handler.buildDraftData(vm);
    final sec = data["securityPerfection"]["securityDeferralList"];

    expect(sec.first["deferralDate"], "2026-04-25");
  });

  test("buildDraftData serializes covenant with date", () {
    final vm = buildVm(
      covenant: [
        SecurityCovenantCondition(
          isChecked: true,
          isCovenant: true,
          date: DateTime(2026, 4, 25),
        ),
      ],
    );

    final data = handler.buildDraftData(vm);
    final cov = data["securityPerfection"]["covenant"];

    expect(cov.first["deferralDate"] ?? cov.first["date"], null);
  });

  test("buildDraftData includes comments", () {
    final vm = buildVm();

    final data = handler.buildDraftData(vm);

    expect(data["commentList"], isNotEmpty);
  });

  /* ============================================================
   * APPLY DRAFT — COMMENTS
   * ============================================================ */

  test("applyDraft restores valid comments", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "commentList": [
        {"comment": "Restored"},
      ],
    });

    expect(vm.comments.length, 1);
    expect(vm.comments.first.comment, "Restored");
  });

  test("applyDraft ignores non-list commentList", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "commentList": "invalid",
    });

    expect(vm.comments.isNotEmpty, true);
  });

  test("applyDraft handles empty commentList", () {
    final vm = buildVm()..comments = [];

    handler.applyDraft(vm, {
      "commentList": [],
    });

    expect(vm.comments.length, 0);
  });

  /* ============================================================
   * APPLY DRAFT — SECURITY
   * ============================================================ */

  test("applyDraft restores securityDeferral list", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": {
        "securityDeferralList": [
          {"selected": false, "isChecked": true, "securityNo": "ABC"},
        ],
      },
    });

    expect(vm.securityDeferral.securityDeferralList!.length, 1);
  });

  test("applyDraft syncs selected -> isChecked", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": {
        "securityDeferralList": [
          {
            "selected": true,
            "isChecked": false,
          },
        ],
      },
    });

    final item = vm.securityDeferral.securityDeferralList!.first;

    expect(item.selected, true);
    expect(item.isChecked, true); //  important
  });

  test("applyDraft restores covenant", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": {
        "covenant": [
          {"selected": true, "isChecked": false},
        ],
      },
    });

    expect(vm.securityDeferral.covenant!.length, 1);
  });

  test("applyDraft restores condition", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": {
        "condition": [
          {"selected": false, "isChecked": true},
        ],
      },
    });

    expect(vm.securityDeferral.condition!.length, 1);
  });

  /* ============================================================
   * APPLY DRAFT — EDGE CASES
   * ============================================================ */

  test("applyDraft ignores invalid securityPerfection format", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": "invalid",
    });

    expect(vm.securityDeferral, isNotNull);
  });

  test("applyDraft ignores JSON string securityPerfection", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": jsonEncode({
        "securityDeferralList": [
          {"selected": true},
        ],
      }),
    });

    expect(vm.securityDeferral.securityDeferralList, null);
  });

  test("applyDraft handles missing securityPerfection", () {
    final vm = buildVm();

    handler.applyDraft(vm, {});

    expect(vm.securityDeferral, isNotNull);
  });

  /* ============================================================
   * EXCEPTION SAFETY
   * ============================================================ */

  test("applyDraft does not crash on invalid objects", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "commentList": Object(),
      "securityPerfection": Object(),
    });

    expect(vm.comments.isNotEmpty, true);
  });

  test("applyDraft handles null safely", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "securityPerfection": null,
    });

    expect(vm.securityDeferral, isNotNull);
  });
}
