import "dart:async";

import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/draft_handler.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";

void main() {
  //  Required for widgets / controllers
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppendixDraftHandler handler;

  setUp(() {
    handler = AppendixDraftHandler();
  });

  // ---------------------------------------------------------------------------
  //  WORKAROUND: swallow async HTML editor errors (TEST-ONLY)
  // ---------------------------------------------------------------------------
  Future<void> applyDraftSafely(
    AppendixDraftHandler handler,
    AppendixViewModel vm,
    Map<String, dynamic> data,
  ) async {
    await runZonedGuarded(
      () async {
        handler.applyDraft(vm, data);
      },
      (Object error, StackTrace stack) {
        //  Ignore known HTML editor loading error
        if (error.toString().contains("HTML editor is still loading")) {
          return;
        }
        //  Re-throw all real errors
        // ignore: only_throw_errors
        throw error;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helper (NO editor setText calls)
  // ---------------------------------------------------------------------------
  AppendixViewModel buildVm() {
    final vm = AppendixViewModel();

    vm.selectedSectionType = "corporate";
    vm.selectedRimNumber = "RIM-001";

    // DO NOT call gcsController.setText in unit tests
    // Editor is intentionally unmounted

    vm.appendix.entries.clear();
    vm.appendix.entries.addAll([
      AppendixEntry(
        id: "1",
        label: "Entry 1",
        value: "Stored value 1",
      ),
      AppendixEntry(
        id: "2",
        label: "Entry 2",
        value: "Stored value 2",
      ),
    ]);

    vm.commentControllers.clear();

    vm.appendix.countryName = "UAE";
    vm.appendix.populationText = "10M";
    vm.appendix.gdpText = "500B";
    vm.selectedRating = "A";

    vm.appendix.importPartners
      ..clear()
      ..add("India");

    vm.appendix.exportPartners
      ..clear()
      ..add("China");

    vm.appendix.strengths
      ..clear()
      ..add("Strong banking");

    vm.appendix.threats
      ..clear()
      ..add("Inflation");

    return vm;
  }

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  test("buildDraftData builds appendix draft safely", () {
    final vm = buildVm();

    final data = handler.buildDraftData(vm);

    expect(data["selectedSectionType"], "corporate");
    expect(data["selectedRimNumber"], "RIM-001");

    // Editor not mounted → fallback path
    expect(data["groupCorporateStructure"], "");

    final entries = data["entries"] as List;
    expect(entries.length, 2);
    expect(entries[0]["value"], "Stored value 1");
    expect(entries[1]["value"], "Stored value 2");

    expect(data["countryName"], "UAE");
    expect(data["populationText"], "10M");
    expect(data["gdpText"], "500B");
    expect(data["selectedRating"], "A");
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------
  test("applyDraft restores entries and financial data safely", () async {
    final vm = buildVm();

    await applyDraftSafely(handler, vm, {
      "entries": [
        {
          "id": "x1",
          "label": "New Entry",
          "value": "Restored value",
        }
      ],
      "countryName": "KSA",
      "populationText": "35M",
      "gdpText": "900B",
    });

    expect(vm.appendix.entries.length, 1);
    expect(vm.appendix.entries.first.label, "New Entry");
    expect(vm.appendix.entries.first.value, "Restored value");

    expect(vm.appendix.countryName, "KSA");
    expect(vm.appendix.populationText, "35M");
    expect(vm.appendix.gdpText, "900B");
  });

  test("applyDraft ignores invalid entry rows safely", () async {
    final vm = buildVm();

    await applyDraftSafely(handler, vm, {
      "entries": ["invalid"],
    });

    expect(vm.appendix.entries, isEmpty);
    expect(vm.commentControllers, isEmpty);
  });

  test("applyDraft handles missing optional keys without crash", () async {
    final vm = buildVm();

    await applyDraftSafely(handler, vm, {
      "entries": [],
    });

    expect(vm.appendix.entries, isEmpty);
  });
  test("buildDraftData handles empty appendix entries", () {
    final vm = buildVm();
    vm.appendix.entries.clear();

    final data = handler.buildDraftData(vm);

    expect(data["entries"], isEmpty);
  });
  test("buildDraftData handles empty country financial lists", () {
    final vm = buildVm();

    vm.appendix.importPartners.clear();
    vm.appendix.exportPartners.clear();
    vm.appendix.strengths.clear();
    vm.appendix.threats.clear();

    final data = handler.buildDraftData(vm);

    expect(data["importPartners"], isEmpty);
    expect(data["exportPartners"], isEmpty);
    expect(data["strengths"], isEmpty);
    expect(data["threats"], isEmpty);
  });
  test("applyDraft skips non-map entry rows", () async {
    final vm = buildVm();

    await applyDraftSafely(handler, vm, {
      "entries": [
        "invalid",
        123,
        null,
      ],
    });

    expect(vm.appendix.entries, isEmpty);
    expect(vm.commentControllers, isEmpty);
  });
  test("applyDraft does not overwrite selectedSectionType with empty value",
      () async {
    final vm = buildVm();
    vm.selectedSectionType = "corporate";

    await applyDraftSafely(handler, vm, {
      "selectedSectionType": "",
      "entries": [],
    });

    expect(vm.selectedSectionType, "corporate");
  });
  test("applyDraft does not overwrite selectedRimNumber with empty value",
      () async {
    final vm = buildVm();
    vm.selectedRimNumber = "RIM-001";

    await applyDraftSafely(handler, vm, {
      "selectedRimNumber": "",
      "entries": [],
    });

    expect(vm.selectedRimNumber, "RIM-001");
  });
  test("applyDraft ignores missing partner and SWOT lists safely", () async {
    final vm = buildVm();

    await applyDraftSafely(handler, vm, {
      "entries": [],
      "countryName": "UAE",
    });

    expect(vm.appendix.importPartners, isNotNull);
    expect(vm.appendix.exportPartners, isNotNull);
    expect(vm.appendix.strengths, isNotNull);
    expect(vm.appendix.threats, isNotNull);
  });
}
