import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Draft handler for the Link Contract screen.
class LinkContractDraftHandler extends DraftHandler<LinkContractViewModel> {
  /// Resolves the draft key for the Link Contract screen.
  String resolveDraftKey(LinkContractViewModel vm) {
    return vm.draftFormKey;
  }

  // --------------------------------------------------
  // BUILD DRAFT
  // --------------------------------------------------

  /// Builds draft data from the Link Contract view model.
  @override
  Map<String, dynamic> buildDraftData(LinkContractViewModel vm) {
    if (vm.formKey.currentState?.mounted ?? false) {
      vm.formKey.currentState?.save();
    }

    return {
      "linkContract": {
        ...vm.contract.toSaveLinkJson(),
        // Explicitly persist submit-time fields
        "projectId": vm.project?.projectId.toString(),
        "projectCode": vm.project?.projectCode,
        "projectName": vm.project?.projectName,
        "customerName": vm.customerNameController.text.isNotEmpty
            ? vm.customerNameController.text
            : (vm.custName ?? ""),
        "customerRimNo":
            vm.contract.customerRimNo ?? int.tryParse(vm.custRimNo.toString()),
        "appRefNo": vm.borrowerAppRefNo ?? "",
      },
    };
  }

  // --------------------------------------------------
  // APPLY DRAFT FIXED
  // --------------------------------------------------

  /// Applies saved draft data back to the Link Contract view model.
  @override
  void applyDraft(
    LinkContractViewModel vm,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic>? json =
        data["linkContract"] as Map<String, dynamic>?;
    if (json == null) {
      return;
    }

    // correct guard
    final String? draftProjectCode = json["projectCode"];
    final String? currentProjectCode = vm.project?.projectCode;

    if (draftProjectCode != currentProjectCode) {
      logger.i(
        "LinkContract draft ignored "
        "(draft=$draftProjectCode, current=$currentProjectCode)",
      );
      return;
    }

    // --------------------------------------------------
    // Restore CONTRACT model
    // --------------------------------------------------
    vm.contract
      ..projectCode = json["projectCode"]
      ..projectName = json["projectName"]
      ..projectId = json["projectId"]?.toString()
      ..contractName = json["contractName"]
      ..customerRimNo = json["rimNo"]
      ..borrowerRole = json["borrowerRole"]
      ..contractCurrency = json["contractCurrency"]
      ..paymasterName = json["paymasterName"]
      ..projectTenor = json["projectTenor"]
      ..contractValue = json["contractValue"]
      ..initialContractValue = json["initialContractValue"]
      ..contractValueAedAmount = json["contractValueAedAmount"]
      ..appReffNo = json["appRefNo"]
      ..isMainContractor = json["isMainContractor"]
      ..contractScope = json["contractScope"]
      ..customerName = json["customerName"]
      ..appRefNo = json["appRefNo"]
      ..completionPercentage =
          (json["completionPercentage"] as num?)?.toDouble();

    // --------------------------------------------------
    // Restore controllers
    // --------------------------------------------------
    vm.searchNameController.text = vm.contract.customerName ?? "";
    vm.customerNameController.text = vm.contract.customerName ?? "";

    vm.searchRimController.text = vm.contract.customerRimNo?.toString() ?? "";
    vm.customerRimController.text = vm.contract.customerRimNo?.toString() ?? "";

    vm.paymasterNameController.text = vm.contract.paymasterName ?? "";

    vm.contractorScopeController.text = vm.contract.contractScope ?? "";

    vm.contractorValueController.text = vm.contract.contractValue ?? "";

    vm.convertedAmountController.text =
        vm.contract.contractValueAedAmount ?? "";

    vm.projectTenorController.text = vm.contract.projectTenor != null
        ? "${vm.contract.projectTenor} Months"
        : "";

    vm.selectedCurrencyLabel = vm.contract.contractCurrency ?? "";

    // --------------------------------------------------
    // Restore dates (STRING → DateTime → ViewModel APIs)
    // --------------------------------------------------
    DateTime? parseDdMmYyyy(String? v) {
      if (v == null || v.isEmpty) {
        return null;
      }
      final parts = v.split("/");
      if (parts.length != 3) {
        return null;
      }
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }

    final start = parseDdMmYyyy(json["expectedStartDate"]);
    final end = parseDdMmYyyy(json["expectedEndDate"]);

    vm.startDateController.text = json["expectedStartDate"];
    vm.completionDateController.text = json["expectedEndDate"];

    if (start != null) {
      vm.onStartDateSubmitted2(start);
    }

    if (end != null) {
      vm.onCompletionDateSubmitted2(end);
    }

    // --------------------------------------------------
    // Restore borrower role dropdown
    // --------------------------------------------------
    vm.contract.borrowerRole = json["borrowerRole"];
    vm.contract.isMainContractor = json["isMainContractor"];

    final String? roleName = json["borrowerRole"];

    if (roleName != null &&
        vm.borrowerRole != null &&
        vm.borrowerRole!.isNotEmpty) {
      final Reference selected = vm.borrowerRole!.firstWhere(
        (r) => r.name == roleName,
        orElse: () => vm.borrowerRole!.first,
      );

      // THIS triggers isMainContractor + paymaster logic
      vm.onBorrowerRoleSelected(selected);
    }

    // --------------------------------------------------
    // Final emit
    // --------------------------------------------------
    vm.emit(
      vm.state.copyWith(loaderStatus: LoadingStatus.loaded),
    );

    logger.i(
      "LinkContract draft applied "
      "for projectCode=$draftProjectCode",
    );
  }
}
