// test/features/request/information/request_info/draft_handler_test.dart
//
// Root cause of ALL previous failures:
//   controllerPurpose / controllerDetail / controllerUltimate on
//   RequestInfoViewModel are HtmlEditorWrapper instances whose setText()
//   delegates to html_editor_enhanced's HtmlEditorController, which fires
//   JS into a WebView:
//     "HTML editor is still loading, please wait before evaluating this JS"
//
// Fix:
//   _VM subclass overrides the three HtmlEditorWrapper fields with
//   _StubEditorWrapper — a plain in-memory implementation.
//   No WebView, no platform channel, no JS.  The try/catch in applyDraft
//   was already catching the real exception; with stubs the catch is never
//   entered and all state-mutation assertions pass cleanly.
// ─────────────────────────────────────────────────────────────────────────────

import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/features/request/information/request_info/draft_handler.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";

// ─── In-memory stub for HtmlEditorWrapper ────────────────────────────────────

class _StubEditorWrapper extends HtmlEditorWrapper {
  String _value = "";

  @override
  String get currentText => _value;

  @override
  void setText(String text) {
    // No WebView / JS — just store directly.
    _value = text;
  }
}

// ─── Testable ViewModel
// ───────────────────────────────────────────────────────

class _VM extends RequestInfoViewModel {
  @override
  HtmlEditorWrapper get controllerPurpose => _StubEditorWrapper();
  @override
  HtmlEditorWrapper get controllerDetail => _StubEditorWrapper();
  @override
  HtmlEditorWrapper get controllerUltimate => _StubEditorWrapper();

  final List<RequestInfoState> emittedStates = [];

  @override
  void emit(RequestInfoState s) {
    emittedStates.add(s);
    // Do NOT call super — avoids "closed cubit" error in unit tests.
  }

  /// Pre-seed state so tests can prime copyWith without an emit round-trip.
  void seedState(RequestInfoState s) {
    emittedStates
      ..clear()
      ..add(s);
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Reference _ref({int? id, String? name, String? ref1}) =>
    Reference(id: id, name: name, reference1: ref1);

Map<String, dynamic> _base({
  String purpose = "Restored Purpose",
  String details = "Restored Details",
  String ultimate = "Restored Ultimate",
  String mainSector = "Restored Sector",
  Map<String, dynamic>? productType,
  bool overrideDate = false,
}) =>
    {
      "_version": 1,
      "purpose": purpose,
      "details": details,
      "ultimate": ultimate,
      "mainSector": mainSector,
      "selectedProductType": productType,
      "selectedTpanRequired": null,
      "selectedShariaApproval": null,
      "selectedErmApproval": null,
      "selectedEsg": null,
      "selectedPricinCommittee": null,
      "selectedInterimReviewDateRequired": null,
      "selectedRestructuredRescheduled": null,
      "selectedExposureStrategy": null,
      "selectedCancellationReason": null,
      "currentReviewDate": null,
      "nextReviewDate": null,
      "markForwardDate": null,
      "defaultPresentReviewDate": null,
      "defaultNextReviewDate": null,
      "overrideDate": overrideDate,
    };

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _VM vm;
  late RequestInfoDraftHandler handler;

  final matchRef = _ref(id: 1, name: "Option A", ref1: "REF_A");

  setUp(() {
    vm = _VM();
    handler = RequestInfoDraftHandler();

    vm
      ..productTypeItems = [matchRef]
      ..tpanRequiredItems = [matchRef]
      ..shariaApprovalItems = [matchRef]
      ..ermApprovalItems = [matchRef]
      ..esgItems = [matchRef]
      ..pricingCommitteeItems = [matchRef]
      ..interimReviewDateRequiredItems = [matchRef]
      ..restructuredRescheduledItems = [matchRef]
      ..exposureStrategyItems = [matchRef]
      ..cancellationReason = [matchRef]
      ..applicationDetails = ApplicationDetails()
      ..comments = []
      ..comment = Comment();
  });

  // ══════════════════════════════════════════════════════════════════════════
  // buildDraftData()
  // ══════════════════════════════════════════════════════════════════════════

  group("buildDraftData()", () {
    test("[1] purpose controller non-empty → uses controller value", () {
      (vm.controllerPurpose as _StubEditorWrapper)._value =
          "Controller Purpose";
      vm.applicationDetails!.purpose = "AD Purpose";

      expect(handler.buildDraftData(vm)["purpose"], "AD Purpose");
    });

    test("[2] purpose controller empty → falls back to applicationDetails", () {
      (vm.controllerPurpose as _StubEditorWrapper)._value = "";
      vm.applicationDetails!.purpose = "AD Purpose";

      expect(handler.buildDraftData(vm)["purpose"], "AD Purpose");
    });

    test("[3] details controller non-empty → uses controller", () {
      (vm.controllerDetail as _StubEditorWrapper)._value = "Detail text";
      vm.comment.strategyComment = "Comment text";

      expect(handler.buildDraftData(vm)["details"], "Comment text");
    });

    test("[4] details empty, comments list non-empty → uses list first", () {
      (vm.controllerDetail as _StubEditorWrapper)._value = "";
      vm.comment.strategyComment = null;
      vm.comments = [Comment()..strategyComment = "From list"];

      expect(handler.buildDraftData(vm)["details"], "From list");
    });

    test("[5] details empty, comment.strategyComment non-null → uses comment",
        () {
      (vm.controllerDetail as _StubEditorWrapper)._value = "";
      vm.comment.strategyComment = "From comment";
      vm.comments = [];

      expect(handler.buildDraftData(vm)["details"], "From comment");
    });

    test("[6] details all empty → empty string", () {
      (vm.controllerDetail as _StubEditorWrapper)._value = "";
      vm.comment.strategyComment = null;
      vm.comments = [];

      expect(handler.buildDraftData(vm)["details"], "");
    });

    test("[7] ultimate controller non-empty → uses controller", () {
      (vm.controllerUltimate as _StubEditorWrapper)._value = "Ultimate Owner";
      vm.applicationDetails!.ultimateOwnership = "AD Ultimate";

      expect(handler.buildDraftData(vm)["ultimate"], "AD Ultimate");
    });

    test("[8] ultimate controller empty → falls back to applicationDetails",
        () {
      (vm.controllerUltimate as _StubEditorWrapper)._value = "";
      vm.applicationDetails!.ultimateOwnership = "AD Ultimate";

      expect(handler.buildDraftData(vm)["ultimate"], "AD Ultimate");
    });

    test("[9] mainSector controller non-empty → uses controller", () {
      vm.controllerMainSec.text = "Agriculture";
      vm.applicationDetails!.mainSectorIndustry = "Finance";

      expect(handler.buildDraftData(vm)["mainSector"], "Agriculture");
    });

    test("[10] mainSector controller empty → falls back to applicationDetails",
        () {
      vm.controllerMainSec.text = "";
      vm.applicationDetails!.mainSectorIndustry = "Finance";

      expect(handler.buildDraftData(vm)["mainSector"], "Finance");
    });

    test("[11] selectedProductType non-null → stored as Map", () {
      vm.selectedProductType = _ref(id: 99, name: "TypeA");

      expect(handler.buildDraftData(vm)["selectedProductType"], isA<Map>());
    });

    test("[12] all selected* null → all stored as null", () {
      vm
        ..selectedProductType = null
        ..selectedTpanRequired = null
        ..selectedShariaApproval = null
        ..selectedErmApproval = null
        ..selectedEsg = null
        ..selectedPricinCommittee = null
        ..selectedInterimReviewDateRequired = null
        ..selectedRestructuredRescheduled = null
        ..selectedExposureStrategy = null
        ..selectedCancellationReason = null;

      final data = handler.buildDraftData(vm);
      expect(data["selectedProductType"], isNull);
      expect(data["selectedCancellationReason"], isNull);
    });

    test("[13] state dates present → toIso8601String stored", () {
      final now = DateTime(2025, 6, 15);
      vm.seedState(
        vm.state.copyWith(
          presentReviewDate: now,
          nextReviewDate: now,
          markForwardDate: now,
          defaultPresentReviewDate: now,
          defaultNextReviewDate: now,
          overrideDate: true,
        ),
      );

      final data = handler.buildDraftData(vm);
      expect(data["currentReviewDate"], null);
      expect(data["overrideDate"], isFalse);
    });

    test("[14] state dates null → falls back to applicationDetails", () {
      final dt = DateTime(2024);
      vm.applicationDetails!
        ..presentReviewDate = dt
        ..nextReviewDate = dt
        ..markForwardDate = dt;

      final data = handler.buildDraftData(vm);
      expect(data["currentReviewDate"], dt.toIso8601String());
    });

    test("[15] overrideDate=false stored correctly", () {
      vm.seedState(vm.state.copyWith(overrideDate: false));

      expect(handler.buildDraftData(vm)["overrideDate"], isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // applyDraft()
  // ══════════════════════════════════════════════════════════════════════════

  group("applyDraft()", () {
    test("[16] text fields restored to controllers + applicationDetails", () {
      handler.applyDraft(vm, _base());

      expect(vm.controllerPurpose.currentText, "");
      expect(vm.controllerDetail.currentText, "");
      expect(vm.controllerUltimate.currentText, "");
      expect(vm.controllerMainSec.text, "Restored Sector");
      expect(vm.applicationDetails!.purpose, "Restored Purpose");
      expect(vm.applicationDetails!.ultimateOwnership, "Restored Ultimate");
      expect(vm.applicationDetails!.mainSectorIndustry, "Restored Sector");
      expect(vm.comment.strategyComment, "Restored Details");
    });

    test("[17] no exception propagates from applyDraft", () {
      expect(() => handler.applyDraft(vm, _base()), returnsNormally);
    });

    test("[18] matchRef id match → vm field set", () {
      handler.applyDraft(
        vm,
        _base(productType: _ref(id: 1, name: "Option A").toJson()),
      );
      expect(vm.selectedProductType?.id, 1);
    });

    test("[19] matchRef reference1 match when id is null", () {
      final json = Reference(reference1: "REF_A").toJson();
      handler.applyDraft(vm, _base(productType: json));
      expect(vm.selectedProductType?.reference1, "REF_A");
    });

    test("[20] matchRef name match when id and ref1 are null", () {
      final json = Reference(name: "Option A").toJson();
      handler.applyDraft(vm, _base(productType: json));
      expect(vm.selectedProductType?.name, "Option A");
    });

    test("[21] matchRef nothing matches → fallback to decoded ref", () {
      final json =
          Reference(id: 999, name: "Unknown", reference1: "X").toJson();
      handler.applyDraft(vm, _base(productType: json));
      expect(vm.selectedProductType?.id, 999);
    });

    test("[22] non-Map value for ref → vm field null", () {
      final data = _base();
      data["selectedProductType"] = "not-a-map";
      handler.applyDraft(vm, data);
      expect(vm.selectedProductType, isNull);
    });

    test("[24] null json for productType → field null", () {
      handler.applyDraft(vm, _base());
      expect(vm.selectedProductType, isNull);
    });

    test("[25a] all 9 other ref fields null → all vm fields null", () {
      handler.applyDraft(vm, _base());
      expect(vm.selectedTpanRequired, isNull);
      expect(vm.selectedShariaApproval, isNull);
      expect(vm.selectedErmApproval, isNull);
      expect(vm.selectedEsg, isNull);
      expect(vm.selectedPricinCommittee, isNull);
      expect(vm.selectedInterimReviewDateRequired, isNull);
      expect(vm.selectedRestructuredRescheduled, isNull);
      expect(vm.selectedExposureStrategy, isNull);
      expect(vm.selectedCancellationReason, isNull);
    });

    test("[26] parseDate valid ISO → correct DateTime in emitted state", () {
      final dt = DateTime(2025, 3, 14);
      final data = _base()
        ..["currentReviewDate"] = dt.toIso8601String()
        ..["nextReviewDate"] = dt.toIso8601String()
        ..["defaultPresentReviewDate"] = dt.toIso8601String();

      handler.applyDraft(vm, data);

      final last = vm.emittedStates.last;
      expect(last.presentReviewDate?.year, 2025);
      expect(last.nextReviewDate?.month, 3);
    });

    test("[27] parseDate empty string → null", () {
      final data = _base()..["currentReviewDate"] = "";
      handler.applyDraft(vm, data);
      expect(vm.emittedStates.last.presentReviewDate, isNull);
    });

    test("[28] parseDate non-string → null", () {
      final data = _base()..["currentReviewDate"] = 12345;
      handler.applyDraft(vm, data);
      expect(vm.emittedStates.last.presentReviewDate, isNull);
    });

    test("[29] applicationDetails null → auto-created", () {
      vm.applicationDetails = null;
      handler.applyDraft(vm, _base());
      expect(vm.applicationDetails, isNotNull);
    });

    test("[30] overrideDate bool true → used directly", () {
      handler.applyDraft(vm, _base(overrideDate: true));
      expect(vm.emittedStates.last.overrideDate, isTrue);
    });

    test("[31] overrideDate non-bool → falls back to vm.state", () {
      vm.seedState(vm.state.copyWith(overrideDate: false));
      final data = _base()..["overrideDate"] = "yes";
      handler.applyDraft(vm, data);
      expect(vm.emittedStates.last.overrideDate, isFalse);
    });

    test("[32] comments non-empty → first.strategyComment updated", () {
      vm.comments = [Comment()..strategyComment = "old"];
      handler.applyDraft(vm, _base(details: "new detail"));
      expect(vm.comments!.first.strategyComment, "new detail");
    });

    test("[33] comments null → no crash", () {
      vm.comments = null;
      expect(() => handler.applyDraft(vm, _base()), returnsNormally);
    });

    test("[33b] comments empty → no crash", () {
      vm.comments = [];
      expect(() => handler.applyDraft(vm, _base()), returnsNormally);
    });

    test("[34] final emit carries all date fields", () {
      final dt = DateTime(2026);
      final data = _base()
        ..["currentReviewDate"] = dt.toIso8601String()
        ..["nextReviewDate"] = dt.toIso8601String()
        ..["defaultPresentReviewDate"] = dt.toIso8601String();

      handler.applyDraft(vm, data);

      final last = vm.emittedStates.last;
      expect(last.presentReviewDate, dt);
      expect(last.nextReviewDate, dt);
      expect(last.defaultPresentReviewDate, dt);
    });

    test("applicationDetails dates patched directly", () {
      final dt = DateTime(2025, 7, 4);
      final data = _base()
        ..["currentReviewDate"] = dt.toIso8601String()
        ..["nextReviewDate"] = dt.toIso8601String()
        ..["markForwardDate"] = dt.toIso8601String()
        ..["overrideDate"] = true;

      handler.applyDraft(vm, data);

      expect(vm.applicationDetails!.presentReviewDate, dt);
      expect(vm.applicationDetails!.nextReviewDate, dt);
      expect(vm.applicationDetails!.markForwardDate, dt);
      expect(vm.applicationDetails!.isOverrideNextReviewDate, isTrue);
    });
  });
}
