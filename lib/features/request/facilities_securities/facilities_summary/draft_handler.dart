import "package:flutter/material.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";

class FacilitySummaryDraftHandler
    extends DraftHandler<FacilitiesSummaryViewModel> {
  String resolveDraftKey(FacilitiesSummaryViewModel vm) {
    return vm.draftFormKey;
  }

  @override
  Map<String, dynamic> buildDraftData(FacilitiesSummaryViewModel vm) {
    if (vm.formKey.currentState?.mounted ?? false) {
      vm.formKey.currentState?.save();
    }

    // =======================================================
    // A) Existing logic: Save edited facilities per RIM
    // =======================================================
    final Map<String, List<Map<String, dynamic>>> byRim = {};
    final facilities = vm.customerFacilities ?? const [];

    for (final summary in facilities) {
      for (final rim in summary.rims ?? const []) {
        for (final group in rim.groups ?? const []) {
          for (final dis in group.facilityLimits ?? const []) {
            final f = dis.facility;
            if (f?.isEdited != true) continue;

            final int? rimNo = f!.rimNo;
            if (rimNo == null) continue;

            byRim
                .putIfAbsent(rimNo.toString(), () => <Map<String, dynamic>>[])
                .add(f.toSaveJson());
          }
        }
      }
    }

    // =======================================================
    // B) New fields: Product type / Limit group / Description
    // =======================================================
    final draftSelectedProductType =
        vm.selectedProductTypeOption?.id?.toString();

    final draftSelectedFacilityType =
        vm.facility.facilityTypeSelectedValue?.id?.toString();

    final draftSelectedFacilityDescription =
        vm.facility.facilityDescription?.id?.toString();

    // =======================================================
    // C) Header controllers: Project Specific + Standby
    // =======================================================
    final Map<String, String> psNameCtrls = {};
    final Map<String, String> psProposedCtrls = {};
    final Map<String, String> standbyNameCtrls = {};
    final Map<String, String> standbyProposedCtrls = {};

    vm.psNameCtrls.forEach((key, ctrl) {
      psNameCtrls[key] = ctrl.text;
    });

    vm.psProposedCtrls.forEach((key, ctrl) {
      psProposedCtrls[key] = ctrl.text;
    });

    vm.psStandbyNameCtrls.forEach((key, ctrl) {
      standbyNameCtrls[key] = ctrl.text;
    });

    vm.psStandbyProposedCtrls.forEach((key, ctrl) {
      standbyProposedCtrls[key] = ctrl.text;
    });

    // =======================================================
    // D) Header Currency
    // =======================================================
    final Map<String, String> headerCurrencyCtrls = {};

    vm.headerCurrencyByKey.forEach((key, ref) {
      if (ref != null) {
        headerCurrencyCtrls[key] = ref.name ?? "";
      }
    });

    // =======================================================
    // Final draft map
    // =======================================================
    return {
      "byRim": byRim,
      "selectedProductTypeOption": draftSelectedProductType,
      "selectedFacilityType": draftSelectedFacilityType,
      "selectedFacilityDescription": draftSelectedFacilityDescription,
      "psNameCtrls": psNameCtrls,
      "psProposedCtrls": psProposedCtrls,
      "standbyNameCtrls": standbyNameCtrls,
      "standbyProposedCtrls": standbyProposedCtrls,
      "headerCurrencyCtrls": headerCurrencyCtrls,
    };
  }

  @override
  void applyDraft(
    FacilitiesSummaryViewModel vm,
    Map<String, dynamic> data,
  ) {
    // =======================================================
    // A) Restore existing facility data per RIM
    // =======================================================
    final Map<String, dynamic>? byRim = data["byRim"] as Map<String, dynamic>?;

    if (byRim != null) {
      for (final summary in vm.customerFacilities ?? const []) {
        for (final rim in summary.rims ?? const []) {
          for (final group in rim.groups ?? const []) {
            for (final dis in group.facilityLimits ?? const []) {
              final f = dis.facility;
              if (f == null) continue;

              final int? rimNo = f.rimNo;
              if (rimNo == null) continue;

              final List? rimDraft = byRim[rimNo.toString()];
              if (rimDraft == null) continue;

              final Map<String, dynamic> match =
                  rimDraft.cast<Map<String, dynamic>>().firstWhere(
                        (e) => e["facilityId"] == f.facilityId,
                        orElse: () => <String, dynamic>{},
                      );

              if (match.isEmpty) continue;

              f
                ..proposedLimit = match["proposedLimit"]
                ..currency = match["currency"]
                ..tenorUnit = match["tenorUnit"]
                ..tenorValue = match["tenorValue"]
                ..index = match["index"]
                ..marginSign = match["marginSign"]
                ..marginValue = match["marginValue"]
                ..sustainabilityClassification =
                    match["sustainabilityClassification"]
                ..projectName = match["projectName"]
                ..isEdited = true;
            }
          }
        }
      }
    }

    // =======================================================
    // B) Restore: Product Type
    // =======================================================
    final savedProductTypeId = data["selectedProductTypeOption"] as String?;
    if (savedProductTypeId != null) {
      final ref =
          vm.matchOrFirstById(vm.productTypeOptions, savedProductTypeId);
      vm.selectedProductTypeOption = ref;
      vm.facility.selectedProductTypeValue = ref;
    }

    // =======================================================
    // C) Restore: LIMIT GROUP (must run BEFORE description restore)
    // =======================================================
    final savedFacilityTypeId = data["selectedFacilityType"] as String?;

    if (savedFacilityTypeId != null) {
      final typeRef = vm.matchOrFirstById(vm.limitTypes, savedFacilityTypeId);

      // This regenerates facilityDescriptions list correctly
      vm.selectLimittedGroup(typeRef);
    }

    // =======================================================
    // D) Restore: LIMIT DESCRIPTION (AFTER facilityDescriptions is built)
    // =======================================================
    final savedFacilityDescId = data["selectedFacilityDescription"] as String?;

    if (savedFacilityDescId != null) {
      final descRef =
          vm.matchOrFirstById(vm.facilityDescriptions, savedFacilityDescId);

      vm.facility.facilityDescription = descRef;
    }

    // =======================================================
    // E) Restore Project-Specific & Standby Controllers
    // =======================================================
    final savedPsNameCtrls = data["psNameCtrls"] as Map?;
    savedPsNameCtrls?.forEach((key, value) {
      vm.psNameCtrls.putIfAbsent(key, TextEditingController.new).text = value;
    });

    final savedPsProposedCtrls = data["psProposedCtrls"] as Map?;
    savedPsProposedCtrls?.forEach((key, value) {
      vm.psProposedCtrls.putIfAbsent(key, TextEditingController.new).text =
          value;
    });

    final savedStandbyNameCtrls = data["standbyNameCtrls"] as Map?;
    savedStandbyNameCtrls?.forEach((key, value) {
      vm.psStandbyNameCtrls.putIfAbsent(key, TextEditingController.new).text =
          value;
    });

    final savedStandbyProposedCtrls = data["standbyProposedCtrls"] as Map?;
    savedStandbyProposedCtrls?.forEach((key, value) {
      vm.psStandbyProposedCtrls
          .putIfAbsent(key, TextEditingController.new)
          .text = value;
    });

    // =======================================================
    // F) Restore Header Currency
    // =======================================================
    final savedHeaderCurrency = data["headerCurrencyCtrls"] as Map?;
    if (savedHeaderCurrency != null) {
      savedHeaderCurrency.forEach((key, currencyName) {
        if (currencyName == null || currencyName.toString().trim().isEmpty) {
          return;
        }

        final ref = vm.matchOrFirstByName(vm.currencyCodes, currencyName);

        vm.headerCurrencyByKey[key] = ref;
      });
    }

    vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
