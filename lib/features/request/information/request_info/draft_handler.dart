import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";

class RequestInfoDraftHandler extends DraftHandler<RequestInfoViewModel> {
  @override
  Map<String, dynamic> buildDraftData(RequestInfoViewModel vm) {
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "_version": 1,

      // HTML / text
      "purpose": vm.controllerPurpose.currentText.isNotEmpty
          ? vm.controllerPurpose.currentText
          : (vm.applicationDetails?.purpose ?? ""),
      "details": vm.controllerDetail.currentText.isNotEmpty
          ? vm.controllerDetail.currentText
          : (vm.comment.strategyComment ??
              ((vm.comments != null && vm.comments!.isNotEmpty)
                  ? (vm.comments!.first.strategyComment ?? "")
                  : "")),
      "ultimate": vm.controllerUltimate.currentText.isNotEmpty
          ? vm.controllerUltimate.currentText
          : (vm.applicationDetails?.ultimateOwnership ?? ""),
      "mainSector": vm.controllerMainSec.text.isNotEmpty
          ? vm.controllerMainSec.text
          : (vm.applicationDetails?.mainSectorIndustry ?? ""),

      // Refs
      "selectedProductType": vm.selectedProductType?.toJson(),
      "selectedTpanRequired": vm.selectedTpanRequired?.toJson(),
      "selectedShariaApproval": vm.selectedShariaApproval?.toJson(),
      "selectedErmApproval": vm.selectedErmApproval?.toJson(),
      "selectedEsg": vm.selectedEsg?.toJson(),
      "selectedPricinCommittee": vm.selectedPricinCommittee?.toJson(),
      "selectedInterimReviewDateRequired":
          vm.selectedInterimReviewDateRequired?.toJson(),
      "selectedRestructuredRescheduled":
          vm.selectedRestructuredRescheduled?.toJson(),
      "selectedExposureStrategy": vm.selectedExposureStrategy?.toJson(),
      "selectedCancellationReason": vm.selectedCancellationReason?.toJson(),

      // // Policy deviations
      // 'policyDeviations': vm.applicationDetails?.policyDeviations
      //     ?.map((e) => e.toJson())
      //     .toList(),

      // Dates: save from state first, fallback to applicationDetails
      "allDocRecvdDate":
          vm.applicationDetails?.dateAllDocumentReceived?.toIso8601String(),
      "custRequestReceived":
          vm.applicationDetails?.custRequestReceived?.toIso8601String(),
      "presentReviewDate": (vm.state.presentReviewDate ??
              vm.applicationDetails?.presentReviewDate)
          ?.toIso8601String(),
      "nextReviewDate":
          (vm.state.nextReviewDate ?? vm.applicationDetails?.nextReviewDate)
              ?.toIso8601String(),
      "markForwardDate":
          (vm.state.markForwardDate ?? vm.applicationDetails?.markForwardDate)
              ?.toIso8601String(),
      "defaultPresentReviewDate":
          vm.state.defaultPresentReviewDate?.toIso8601String(),
      "defaultNextReviewDate":
          vm.state.defaultNextReviewDate?.toIso8601String(),

      "overrideDate": vm.state.overrideDate,
    };
  }

  @override
  void applyDraft(RequestInfoViewModel vm, Map<String, dynamic> data) {
    Reference? decodeRef(dynamic json) {
      if (json is Map) {
        return Reference.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }

    Reference? matchRef(List<Reference> items, dynamic json) {
      final restored = decodeRef(json);
      if (restored == null) return null;

      try {
        return items.firstWhere(
          (item) =>
              (restored.id != null && item.id == restored.id) ||
              ((restored.reference1 ?? "").isNotEmpty &&
                  item.reference1 == restored.reference1) ||
              ((restored.name ?? "").isNotEmpty && item.name == restored.name),
        );
      } catch (_) {
        return restored;
      }
    }

    DateTime? parseDate(dynamic raw) =>
        (raw is String && raw.isNotEmpty) ? DateTime.tryParse(raw) : null;

    vm.applicationDetails ??= ApplicationDetails();

    // -----------------------------
    // Restore HTML / text
    // -----------------------------
    final String purpose = (data["purpose"] ?? "").toString();
    final String details = (data["details"] ?? "").toString();
    final String ultimate = (data["ultimate"] ?? "").toString();
    final String mainSector = (data["mainSector"] ?? "").toString();

    try {
      vm.controllerPurpose.setText(purpose);
    } catch (_) {}

    try {
      vm.controllerDetail.setText(details);
    } catch (_) {}

    try {
      vm.controllerUltimate.setText(ultimate);
    } catch (_) {}

    vm.controllerMainSec.text = mainSector;
    //final bool hasSavedPresentReviewDate =
    //vm.applicationDetails?.presentReviewDate != null;
    //if (!hasSavedPresentReviewDate) {
    vm.applicationDetails?.isAutoSave = "1"; //true
    // }
    vm.applicationDetails?.purpose = purpose;
    vm.applicationDetails?.ultimateOwnership = ultimate;
    vm.applicationDetails?.mainSectorIndustry = mainSector;

    vm.comment.strategyComment = details;
    if (vm.comments != null && vm.comments!.isNotEmpty) {
      vm.comments!.first.strategyComment = details;
    }

    // -----------------------------
    // Restore refs THROUGH VM METHODS
    // -----------------------------
    final productType =
        matchRef(vm.productTypeItems, data["selectedProductType"]);
    if (productType != null) {
      vm.onProductTypeSelected(productType);
    } else {
      vm.selectedProductType = null;
    }

    final tpan = matchRef(vm.tpanRequiredItems, data["selectedTpanRequired"]);
    if (tpan != null) {
      vm.onTPANTypeSelected(tpan);
    } else {
      vm.selectedTpanRequired = null;
    }

    final sharia =
        matchRef(vm.shariaApprovalItems, data["selectedShariaApproval"]);
    if (sharia != null) {
      vm.onShariaApprovalSelected(sharia);
    } else {
      vm.selectedShariaApproval = null;
    }

    final erm = matchRef(vm.ermApprovalItems, data["selectedErmApproval"]);
    if (erm != null) {
      vm.onErmApprovalSelected(erm);
    } else {
      vm.selectedErmApproval = null;
    }

    final esg = matchRef(vm.esgItems, data["selectedEsg"]);
    if (esg != null) {
      vm.onEsgSelected(esg);
    } else {
      vm.selectedEsg = null;
    }

    final pricing = matchRef(
      vm.pricingCommitteeItems,
      data["selectedPricinCommittee"],
    );
    if (pricing != null) {
      vm.onPricingCommitteeSelected(pricing);
    } else {
      vm.selectedPricinCommittee = null;
    }

    final interim = matchRef(
      vm.interimReviewDateRequiredItems,
      data["selectedInterimReviewDateRequired"],
    );
    if (interim != null) {
      vm.onInterimReviewDateRequiredSelected(interim);
    } else {
      vm.selectedInterimReviewDateRequired = null;
    }

    final restructured = matchRef(
      vm.restructuredRescheduledItems,
      data["selectedRestructuredRescheduled"],
    );
    if (restructured != null) {
      vm.onRestructuredRescheduledSelected(restructured);
    } else {
      vm.selectedRestructuredRescheduled = null;
    }

    final exposure = matchRef(
      vm.exposureStrategyItems,
      data["selectedExposureStrategy"],
    );
    if (exposure != null) {
      vm.onExposureStrategySelected(exposure);
    } else {
      vm.selectedExposureStrategy = null;
    }

    final cancellation = matchRef(
      vm.cancellationReason,
      data["selectedCancellationReason"],
    );
    if (cancellation != null) {
      vm.onCancellationSelected(cancellation);
    } else {
      vm.selectedCancellationReason = null;
    }

    // -----------------------------
    // Restore policy deviations
    // -----------------------------
    // final rawPolicies = data['policyDeviations'];
    // if (rawPolicies is List) {
    //   final restoredPolicies = rawPolicies
    //       .map((e) => matchRef(vm.policyDeviationItems, e))
    //       .whereType<Reference>()
    //       .toList();

    //   vm.onPolicyDeviationSelected(restoredPolicies);
    // } else {
    //   vm.onPolicyDeviationSelected(<Reference>[]);
    // }

    // -----------------------------
    // Restore dates
    // -----------------------------
    final DateTime? defaultDateAllDocumentReceived =
        parseDate(data["allDocRecvdDate"]);
    final DateTime? defaultCustReqRecvdDate =
        parseDate(data["custRequestReceived"]);

    final DateTime? present = parseDate(data["presentReviewDate"]);
    final DateTime? next = parseDate(data["nextReviewDate"]);
    final DateTime? markForward = parseDate(data["markForwardDate"]);
    final DateTime? defaultPresent =
        parseDate(data["defaultPresentReviewDate"]);
    final DateTime? defaultNext = parseDate(data["defaultNextReviewDate"]);
    final bool overrideDate = data["overrideDate"] is bool
        ? data["overrideDate"] as bool
        : (vm.state.overrideDate ?? false);

    // Patch applicationDetails directly too
    vm.applicationDetails?.presentReviewDate = present;
    vm.applicationDetails?.nextReviewDate = next;
    vm.applicationDetails?.markForwardDate = markForward;
    vm.applicationDetails?.isOverrideNextReviewDate = overrideDate;
    vm.applicationDetails?.dateAllDocumentReceived =
        defaultDateAllDocumentReceived;
    vm.applicationDetails?.custRequestReceived = defaultCustReqRecvdDate;

    // Update VM methods (keeps any internal sync logic)
    vm
      ..updatePresentReviewDate(present)
      ..updateNextReviewDate(next)
      ..updateMarkForwardDate(markForward)
      // Final state patch: make sure date pickers see the exact restored state
      ..emit(
        vm.state.copyWith(
          presentReviewDate: present,
          nextReviewDate: next,
          markForwardDate: markForward,
          defaultPresentReviewDate: defaultPresent,
          defaultNextReviewDate: defaultNext,
          overrideDate: overrideDate,
        ),
      );
  }
}
