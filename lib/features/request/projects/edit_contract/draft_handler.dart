import "package:flutter/material.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";

class EditContractDraftHandler extends DraftHandler<EditContractViewModel> {
  // --------------------------------------------------
  // Draft key
  // --------------------------------------------------
  String resolveDraftKey(EditContractViewModel vm) {
    return vm.draftFormKey;
  }

  // --------------------------------------------------
  // BUILD DRAFT
  // --------------------------------------------------
  @override
  Map<String, dynamic> buildDraftData(EditContractViewModel vm) {
    if (vm.formKey.currentState?.mounted ?? false) {
      vm.formKey.currentState?.save();
    }

    vm.syncModelFromControllers();
    vm.contract.ppcList = vm.ppc;

    return {
      "editContract": {
        ...vm.contract.toSaveContractJson(),

        // guards
        "contractCode": vm.contract.contractCode,
        "contractId": vm.contract.contractId,
        "projectId": vm.contract.projectId,

        // EXPLICIT DATE PERSISTENCE
        "expectedStartDate": vm.startDateController.text,
        "expectedEndDate": vm.completionDateController.text,

        //SAVE COMMENT INPUTS (UI DRAFT)
        "commentInputs": vm.commentInputs,

        // nested
        "ppcList": vm.ppc.map((e) => e.toJson()).toList(),
        "linkCommitmentNumberWith": vm.contract.linkCommitmentNumberWith
            ?.map((e) => e.toJson())
            .toList(),
      },
    };
  }

  // --------------------------------------------------
  // APPLY DRAFT
  // --------------------------------------------------

  @override
  void applyDraft(
    EditContractViewModel vm,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic>? json =
        data["editContract"] as Map<String, dynamic>?;

    if (json == null) return;

    vm.isRestoringDraft = true;
    try {
      // --------------------------------------------------
      // Guard: wrong contract
      // --------------------------------------------------
      final String? draftCode = json["contractCode"];
      final String? currentCode = vm.contract.contractCode;

      if (draftCode != currentCode) {
        logger.i(
          "EditContract draft ignored "
          "(draft=$draftCode, current=$currentCode)",
        );
        return;
      }

      // --------------------------------------------------
      // 1Restore MODEL (raw state)
      // --------------------------------------------------
      vm.contract = Contract.fromContractByContractCodeJson(json);

      // --------------------------------------------------
      // 2Restore STATIC controllers
      // --------------------------------------------------
      vm.syncControllersFromModel();

      DateTime? parseDdMmYyyy(String? v) {
        if (v == null || v.isEmpty) return null;
        final parts = v.split("/");
        if (parts.length != 3) return null;
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }

      // --------------------------------------------------
      // Restore START & END DATES (CORRECT WAY)
      // --------------------------------------------------
      final String? startStr = json["expectedStartDate"];
      final String? endStr = json["expectedEndDate"];

      vm.startDateController.text = startStr ?? "";
      vm.completionDateController.text = endStr ?? "";

      final DateTime? start = parseDdMmYyyy(startStr);
      final DateTime? end = parseDdMmYyyy(endStr);

      if (start != null) {
        vm.onStartDateSubmitted2(start);
      }

      if (end != null) {
        vm.onCompletionDateSubmitted2(end);
      }

      // 3 Restore comments (UI buffer)
      final List<dynamic>? rawComments = json["commentInputs"];

      if (rawComments != null && rawComments.isNotEmpty) {
        vm.commentInputs
          ..clear()
          ..addAll(rawComments.cast<String>());

        // sync last value to controller for currently focused field
        vm.contractorCommentsController.text = vm.commentInputs.last;
      } else {
        vm.clearCommentInputs(leaveOneBlank: true);
      }

      // --------------------------------------------------
      // 5️ Restore borrower role (logic-aware)
      // --------------------------------------------------
      final String? roleName = vm.contract.borrowerRole;

      if (roleName != null &&
          vm.borrowerRole != null &&
          vm.borrowerRole!.isNotEmpty) {
        final Reference selected = vm.borrowerRole!.firstWhere(
          (r) => r.name == roleName,
          orElse: () => vm.borrowerRole!.first,
        );
        vm.onBorrowerRoleSelected(selected);
      }

      // --------------------------------------------------
      // 6 Restore link commitments
      // --------------------------------------------------
      final links = (json["linkCommitmentNumberWith"] as List?)
          ?.map((e) => LinkCommitmentNumber.fromJson(e))
          .toList();

      if (links != null && links.isNotEmpty) {
        vm.updateLinkCommitmentNumberWith(links);
      }

      // --------------------------------------------------
      // 7Restore PPC (RECREATE controllers)
      // --------------------------------------------------
      final restoredPpc =
          (json["ppcList"] as List?)?.map((e) => PPC.fromJson(e)).toList() ??
              <PPC>[];

      vm.ppc = List<PPC>.from(restoredPpc);
      vm.isNewRow = List<bool>.filled(vm.ppc.length, true, growable: true);

      vm.initializeControllers(vm.ppc);
      logger.i(
        "EditContract draft applied for contractCode=$draftCode",
      );
    } finally {
      // Unfreeze safely AFTER rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.isRestoringDraft = false;
      });
    }
    // --------------------------------------------------
    //Final UI emit
    // --------------------------------------------------
    vm.emit(
      vm.state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
        linkCommitmentStatus: LoadingStatus.loaded,
      ),
    );
  }
}
