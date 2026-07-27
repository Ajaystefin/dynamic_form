import "package:flutter/material.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";

/// Draft handler for the Fee Structure screen.
///
/// Owns all autosave serialization and deserialization logic so that
/// [FeeStructureViewModel] stays focused on business logic only.
class FeeStructureDraftHandler extends DraftHandler<FeeStructureViewModel> {
  String? _normalize(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  @override
  Map<String, dynamic> buildDraftData(FeeStructureViewModel vm) {
    // Flush onSaved callbacks — required for any fields using `onSaved`.
    vm.formKey.currentState?.save();

    final rows = vm.combinedRows;
    final amountCtrls = vm.amountControllers;
    final commentCtrls = vm.commentsControllers;

    final int count = [
      rows.length,
      amountCtrls.length,
      commentCtrls.length,
    ].reduce((a, b) => a < b ? a : b);

    final String? customerKey = vm.selectedCustomer?.customerRimNo?.toString();

    final List<Map<String, dynamic>> draftRows = [];
    for (int i = 0; i < count; i++) {
      final row = rows[i];
      final bool isDefault = vm.defaultFeeTypes.contains(row.feeType);

      draftRows.add(<String, dynamic>{
        "id": row.id,
        "feeType": row.feeType,
        "amount": _normalize(amountCtrls[i].text),
        "comments": _normalize(commentCtrls[i].text),
        "isDefault": isDefault,
      });
    }

    return <String, dynamic>{
      "feeStructuresByCustomer": <String, dynamic>{
        if (customerKey != null) customerKey: draftRows,
      },
      "selectedCustomerRimNo": customerKey,
      "savedAt": DateTime.now().toIso8601String(),
    };
  }

  @override
  void applyDraft(FeeStructureViewModel vm, Map<String, dynamic> data) {
    final String? currentCustomerKey =
        vm.selectedCustomer?.customerRimNo?.toString();

    if (currentCustomerKey == null) {
      return;
    }

    final rawByCustomer = data["feeStructuresByCustomer"];
    if (rawByCustomer is! Map) {
      return;
    }

    final rawDraftList = rawByCustomer[currentCustomerKey];
    if (rawDraftList is! List || rawDraftList.isEmpty) {
      return;
    }

    List<FeeStructure> rows() => vm.combinedRows;
    List<TextEditingController> amountCtrls() => vm.amountControllers;
    List<TextEditingController> commentCtrls() => vm.commentsControllers;

    int? findExistingRowIndex({
      required String? draftedId,
      required String? draftedFeeType,
      required bool draftedIsDefault,
    }) {
      // 1) Match by stable row id first
      if (draftedId != null && draftedId.trim().isNotEmpty) {
        final int idx = rows().indexWhere((r) => r.id == draftedId);
        if (idx != -1) {
          return idx;
        }
      }

      // 2) For default rows, feeType is stable enough to match
      if (draftedIsDefault &&
          draftedFeeType != null &&
          draftedFeeType.trim().isNotEmpty) {
        final int idx = rows().indexWhere((r) => r.feeType == draftedFeeType);
        if (idx != -1) {
          return idx;
        }
      }

      // 🚫 No unsafe fallback by index for custom rows
      return null;
    }

    for (int draftIndex = 0; draftIndex < rawDraftList.length; draftIndex++) {
      final rawItem = rawDraftList[draftIndex];
      if (rawItem is! Map) {
        continue;
      }

      final Map<String, dynamic> d = Map<String, dynamic>.from(rawItem);

      final String? draftedId = d["id"]?.toString();
      final String? draftedFeeType = d["feeType"]?.toString();
      final String? draftedAmount = d["amount"]?.toString();
      final String? draftedComments = d["comments"]?.toString();

      final bool draftedIsDefault = d["isDefault"] ??
          false ||
              (draftedFeeType != null &&
                  vm.defaultFeeTypes.contains(draftedFeeType));

      int? targetIndex = findExistingRowIndex(
        draftedId: draftedId,
        draftedFeeType: draftedFeeType,
        draftedIsDefault: draftedIsDefault,
      );

      // If custom row does not exist yet, recreate it from draft
      if (targetIndex == null && !draftedIsDefault) {
        final String newId = (draftedId != null && draftedId.trim().isNotEmpty)
            ? draftedId
            : DateTime.now().millisecondsSinceEpoch.toString();

        final FeeStructure newRow = FeeStructure(
          id: newId,
          isNew: true,
          feeType: draftedFeeType ?? "",
          comments: draftedComments ?? "",
        );

        vm.feeRows.add(newRow);
        vm.amountControllers.add(
          TextEditingController(text: draftedAmount ?? ""),
        );
        vm.commentsControllers.add(
          TextEditingController(text: draftedComments ?? ""),
        );

        targetIndex = rows().indexWhere((r) => r.id == newId);
        if (targetIndex == -1) {
          targetIndex = rows().length - 1;
        }
      }

      if (targetIndex == null ||
          targetIndex < 0 ||
          targetIndex >= rows().length ||
          targetIndex >= amountCtrls().length ||
          targetIndex >= commentCtrls().length) {
        continue;
      }

      final FeeStructure row = rows()[targetIndex];
      final bool isDefault = vm.defaultFeeTypes.contains(row.feeType);

      // Restore feeType only for custom/editable rows
      if (!isDefault &&
          draftedFeeType != null &&
          draftedFeeType.trim().isNotEmpty) {
        row.feeType = draftedFeeType;
      }

      // Restore amount
      if (draftedAmount != null) {
        amountCtrls()[targetIndex].text = draftedAmount;
        vm.onAmountFieldChanged(targetIndex, draftedAmount);
      }

      // Restore comments
      if (draftedComments != null) {
        commentCtrls()[targetIndex].text = draftedComments;
        row.comments = draftedComments;
      }
    }
  }
}
