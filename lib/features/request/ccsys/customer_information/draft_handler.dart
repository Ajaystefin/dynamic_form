import "dart:convert";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";

/// Handles draft data build and restore logic for CCSYS customer information.
class CustomerInformationDraftHandler
    extends DraftHandler<CustomerInformationViewModel> {
  /// Builds the draft data from the customer information view model.
  @override
  Map<String, dynamic> buildDraftData(CustomerInformationViewModel vm) {
    vm.formKey.currentState?.save();

    // Update model from UI
    vm.customerInformation
      ..groupImmediateParent = _normalize(vm.controllerGroupImmediate.text)
      ..groupUltimateParent = _normalize(vm.controllerGroupUltimate.text)
      ..leiNumber = _normalize(vm.leiController.text)
      ..capital = _normalize(vm.capitalController.text)
      ..turnover = _normalize(vm.turnoverController.text)
      ..auditor = _normalize(vm.auditorController.text)
      ..numberOfEmployee = int.tryParse(vm.numberOfEmployeeController.text)
      ..borrowerSubsidiary =
          vm.selectedBorroweSubsidiary?.id == ServerConstants.yesRefId
      ..legalEntityIdentifier =
          vm.selectedLegalEntityIdentifier?.id == ServerConstants.yesRefId
      ..emiLic = vm.selectedEmirateLicense != null
          // ? "${vm.selectedEmirateLicense!.id}-${vm.selectedEmirateLicense!.name}"
          ? "${vm.selectedEmirateLicense!.name}"
          : null
      ..emiEst = vm.selectedEmirateEstablishment != null
          // ? "${vm.selectedEmirateEstablishment!.id}-${vm.selectedEmirateEstablishment!.name}"
          ? "${vm.selectedEmirateEstablishment!.name}"
          : null
      ..ccsysCustomerPartnerShareholderList = vm.rows;

    ///  MAIN LINE (IMPORTANT)
    final customerJson =
        _jsonSafe(vm.customerInformation.toJsonGetCCSYSCustomerInfo());

    return {
      "customerInformation": customerJson,
    };
  }

  /// Applies saved draft data back to the customer information view model.
  @override
  void applyDraft(CustomerInformationViewModel vm, Map<String, dynamic> data) {
    try {
      final raw = data["customerInformation"];

      Map<String, dynamic>? jsonMap;

      if (raw is String && raw.isNotEmpty) {
        jsonMap = Map<String, dynamic>.from(jsonDecode(raw));
      } else if (raw is Map) {
        jsonMap = Map<String, dynamic>.from(raw);
      }

      ///  MAIN LINE (IMPORTANT)
      if (jsonMap != null) {
        vm.customerInformation =
            CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(jsonMap);
      }

      ///  Restore Partner List
      vm.rows =
          vm.customerInformation.ccsysCustomerPartnerShareholderList ?? [];

      ///  Rebuild controllers
      vm.ctrls.clear();
      for (final m in vm.rows) {
        final ctrl = PartnerShareholderControllers()..attach(m);
        vm.ctrls.add(ctrl);
      }

      ///  Restore UI fields
      vm.capitalController.text =
          vm.customerInformation.capital?.toString() ?? "";
      vm.turnoverController.text =
          vm.customerInformation.turnover?.toString() ?? "";
      vm.auditorController.text = vm.customerInformation.auditor ?? "";
      vm.numberOfEmployeeController.text =
          vm.customerInformation.numberOfEmployee?.toString() ?? "";

      //vm.selectedEmirateEstablishment = null;
      if (vm.customerInformation.emiEst != null) {
        vm.selectedEmirateEstablishment = vm.ccsysEmirateList.firstWhere(
          (element) => element.name == vm.customerInformation.emiEst,
          orElse: () => Reference(name: vm.customerInformation.emiEst),
        );
      }

      //vm.selectedEmirateLicense = null;
      if (vm.customerInformation.emiLic != null) {
        vm.selectedEmirateLicense = vm.ccsysEmirateList.firstWhere(
          (element) => element.name == vm.customerInformation.emiLic,
          orElse: () => Reference(name: vm.customerInformation.emiLic),
        );
      }

      /// Borrower Subsidiary
      ///
      final List<Reference> yesNoNa =
          vm.yesNoNaItems.isEmpty ? vm.radioButtonItems : vm.yesNoNaItems;

      final bool? borroweSubsidiary = vm.customerInformation.borrowerSubsidiary;
      final bool? legalEntityIdentifier =
          vm.customerInformation.legalEntityIdentifier;
      final int target = borroweSubsidiary ?? false
          ? ServerConstants.yesRefId
          : ServerConstants.noRefId;
      final int targetlegal = legalEntityIdentifier ?? false
          ? ServerConstants.yesRefId
          : ServerConstants.noRefId;

      vm
        ..selectedBorroweSubsidiary = yesNoNa.firstWhere(
          (e) => e.id == target,
          orElse: Reference.new,
        )
        ..selectedLegalEntityIdentifier = yesNoNa.firstWhere(
          (e) => e.id == targetlegal,
          orElse: Reference.new,
        )
        ..emit(
          vm.state.copyWith(
            borrowerSubsidiary: borroweSubsidiary ?? false,
            legalEntityIdentifier: legalEntityIdentifier ?? false,
          ),
        );

      if (vm.selectedBorroweSubsidiary?.id == ServerConstants.noRefId) {
        vm.controllerGroupImmediate.text = "NA";
        vm.controllerGroupUltimate.text = "NA";
      } else {
        vm.controllerGroupImmediate.text =
            vm.customerInformation.groupUltimateParent != null
                ? vm.customerInformation.groupUltimateParent?.toString() ?? ""
                : "";
        vm.controllerGroupUltimate.text =
            vm.customerInformation.groupImmediateParent != null
                ? vm.customerInformation.groupImmediateParent?.toString() ?? ""
                : "";
      }

      if (vm.selectedLegalEntityIdentifier?.id == ServerConstants.noRefId) {
        vm.leiController.text = "NA";
        vm
          ..selectedEmirateLicense = null
          ..selectedEmirateEstablishment = null;
      } else {
        if (vm.selectedEmirateLicense?.name == "NA") {
          vm.selectedEmirateLicense = null;
        }
        if (vm.selectedEmirateEstablishment?.name == "NA") {
          vm.selectedEmirateEstablishment = null;
        }

        vm.leiController.text = vm.customerInformation.leiNumber != null ||
                vm.customerInformation.leiNumber.toString() != "null"
            ? vm.customerInformation.leiNumber.toString() != "NA"
                ? vm.customerInformation.leiNumber.toString()
                : ""
            : "";
      }
    } on Object catch (e, st) {
      logger
        ..e("Draft restore failed: $e")
        ..e(st.toString());
    }
  }

  String? _normalize(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  dynamic _jsonSafe(v) {
    if (v == null) {
      return null;
    }
    if (v is DateTime) {
      return v.toIso8601String();
    }
    if (v is List) {
      return v.map(_jsonSafe).toList();
    }
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), _jsonSafe(val)));
    }
    return v;
  }
}
