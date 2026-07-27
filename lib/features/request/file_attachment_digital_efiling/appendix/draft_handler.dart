import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";

/// Draft Handler for Appendix
class AppendixDraftHandler extends DraftHandler<AppendixViewModel> {
  @override
  Map<String, dynamic> buildDraftData(AppendixViewModel vm) {
    return <String, dynamic>{
      // Section selection
      "selectedSectionType": vm.selectedSectionType,
      "selectedRimNumber": vm.selectedRimNumber,

      // Corporate section
      "groupCorporateStructure": vm.gcsController.currentText.isNotEmpty
          ? vm.gcsController.currentText
          : vm.appendix.groupCorporateStructure,
      "entries": vm.appendix.entries.asMap().entries.map((entry) {
        final int index = entry.key;
        final AppendixEntry row = entry.value;

        final String value = index < vm.commentControllers.length
            ? vm.commentControllers[index].currentText
            : row.value;

        return <String, dynamic>{
          "id": row.id,
          "label": row.label,
          "value": value,
        };
      }).toList(),

      // Country / financial editable values
      "countryName": vm.appendix.countryName,
      "populationText": vm.appendix.populationText,
      "gdpText": vm.appendix.gdpText,
      "selectedRating": vm.selectedRating,
      "importPartners": List<String>.from(vm.appendix.importPartners),
      "exportPartners": List<String>.from(vm.appendix.exportPartners),
      "strengths": List<String>.from(vm.appendix.strengths),
      "threats": List<String>.from(vm.appendix.threats),
    };
  }

  @override
  void applyDraft(AppendixViewModel vm, Map<String, dynamic> data) {
    // -----------------------------
    // Restore section selections
    // -----------------------------
    final String? selectedSectionType = data["selectedSectionType"]?.toString();
    if (selectedSectionType != null && selectedSectionType.isNotEmpty) {
      vm.selectedSectionType = selectedSectionType;
    }

    final String? selectedRimNumber = data["selectedRimNumber"]?.toString();
    if (selectedRimNumber != null && selectedRimNumber.isNotEmpty) {
      vm.selectedRimNumber = selectedRimNumber;
    }

    // -----------------------------
    // Restore corporate section
    // -----------------------------
    final String gcs = (data["groupCorporateStructure"] ?? "").toString();

    vm.appendix.groupCorporateStructure = gcs;

    try {
      vm.gcsController.setText(gcs);
    } on Object catch (_) {
      // Editor may not be mounted yet.
    }

    final dynamic rawEntries = data["entries"];

    vm.appendix.entries.clear();
    vm.commentControllers.clear();

    if (rawEntries is List) {
      for (final row in rawEntries) {
        if (row is! Map) {
          continue;
        }

        final String id = (row["id"] ?? const Uuid().v4()).toString();
        final String label = (row["label"] ?? "").toString();
        final String value = (row["value"] ?? "").toString();

        final AppendixEntry entry = AppendixEntry(
          id: id,
          label: label,
          value: value,
        );

        vm.appendix.entries.add(entry);

        final UnifiedEditorController controller = UnifiedEditorController();

        try {
          controller.setText(value);
        } on Object catch (_) {}

        vm.commentControllers.add(controller);
      }
    }

    // -----------------------------
    // Restore country / financial state
    // -----------------------------
    vm.appendix.countryName = data["countryName"]?.toString();
    vm.appendix.populationText = data["populationText"]?.toString() ?? "";
    vm.appendix.gdpText = data["gdpText"]?.toString() ?? "";
    vm.selectedRating = data["selectedRating"]?.toString();

    final dynamic importPartners = data["importPartners"];
    if (importPartners is List) {
      vm.appendix.importPartners =
          importPartners.map((e) => e.toString()).toList();
    }

    final dynamic exportPartners = data["exportPartners"];
    if (exportPartners is List) {
      vm.appendix.exportPartners =
          exportPartners.map((e) => e.toString()).toList();
    }

    final dynamic strengths = data["strengths"];
    if (strengths is List) {
      vm.appendix.strengths = strengths.map((e) => e.toString()).toList();
    }

    final dynamic threats = data["threats"];
    if (threats is List) {
      vm.appendix.threats = threats.map((e) => e.toString()).toList();
    }

    vm
      ..markDraftApplied()
      ..emit(vm.state.copyWith());
  }
}
