import "package:flutter/material.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";

/// Draft handler for the Create Security screen.
///
/// Keeps [CreateSecurityViewModel] focused on business logic by
/// owning auto-save serialization/deserialization of user-entered state.
class CreateSecurityDraftHandler extends DraftHandler<CreateSecurityViewModel> {
  /// Helper to serialize a Reference safely.
  Map<String, dynamic>? _refToJson(Reference? ref) {
    if (ref == null) return null;
    return {
      "id": ref.id,
      "name": ref.name,
      "description": ref.description,
      "reference1": ref.reference1,
      "reference2": ref.reference2,
      "reference3": ref.reference3,
      "reference4": ref.reference4,
      "reference5": ref.reference5,
      "isActive": ref.isActive,
    };
  }

  /// Helper to restore a Reference safely.
  Reference? _refFromJson(dynamic json) {
    if (json == null || json is! Map) return null;
    return Reference(
      id: json["id"] as int?,
      name: json["name"] as String?,
      description: json["description"] as String?,
      reference1: json["reference1"] as String?,
      reference2: json["reference2"] as String?,
      reference3: json["reference3"] as String?,
      reference4: json["reference4"] as String?,
      reference5: json["reference5"] as String?,
      isActive: json["isActive"] as bool? ?? false,
    );
  }

  /// Build a JSON-safe draft payload.
  @override
  Map<String, dynamic> buildDraftData(CreateSecurityViewModel vm) {
    // Flush onSaved callbacks
    vm.formKey.currentState?.save();
    vm.dynamicFormKey.currentState?.save();

    final security = vm.security;

    return <String, dynamic>{
      "securityGroup": _refToJson(security.securityGroup),
      "securityType": _refToJson(security.securityType),
      "securityStatus": _refToJson(security.securityStatus),
      "selectedIsSecurityProviderCbdCustomerValue":
          _refToJson(security.selectedIsSecurityProviderCbdCustomerValue),
      "securityProviderCategory": security.securityProviderCategory,
      "securityProviderLegalStatus":
          _refToJson(security.securityProviderLegalStatus),
      "securityProviderTlNo": security.securityProviderTlNo,
      "securityProviderAddress": security.securityProviderAddress,
      "securityProviderEmiratesId": security.securityProviderEmiratesId,
      "securityProviderNationality": security.securityProviderNationality,
      "securityProvidedRim": security.securityProvidedRim,
      "securityProvidedName": security.securityProvidedName,
      "securityProvidedCountry": security.securityProvidedCountry == null
          ? null
          : {
              "code": security.securityProvidedCountry!.code,
              "description": security.securityProvidedCountry!.description,
            },
      "countryOfSecurity": security.countryOfSecurity,
      "proposedSecurityAmtCurrency":
          _refToJson(security.proposedSecurityAmtCurrency),
      "proposedSecurityAmount": security.proposedSecurityAmount,
      "presentSecurityAmtCurrency":
          _refToJson(security.presentSecurityAmtCurrency),
      "presentSecurityAmount": security.presentSecurityAmount,
      "borrowerRole": _refToJson(security.borrowerRole),
      "securityHeldAs": _refToJson(security.securityHeldAs),
      "isLimitCtrlSecurity": security.isLimitCtrlSecurity,
      "isTangibleSecurity": security.isTangibleSecurity,
      "isCashCollateral": security.isCashCollateral,
      "isSecurityExpiryOpenEnded": security.isSecurityExpiryOpenEnded,
      "securityExpireDate": security.securityExpireDate?.toIso8601String(),
      "emirates": _refToJson(security.emirates),
      "deferredWaived": security.deferredWaived,
      "selectedCashCollateralValue":
          _refToJson(security.selectedCashCollateralValue),
      "allFacilities": security.allFacilities,
      "remarks": security.remarks,
      "cmoRemarks": security.cmoRemark,
      "currentDepositAccountNumber": security.currentDepositAccountNumber,
      "securityNumber": security.securityNumber,
      "dynamicFormDocument": vm.dynamicFormDocument,
      "securityProviderCbdCustomer": vm.securityProviderCbdCustomer,
      "isEntityProvider": vm.isEntityProvider,
      "isCountrySecurityUAE": vm.isCountrySecurityUAE,
      "proposedSecurityAmountControllerText":
          vm.proposedSecurityAmountController.text,
      "presentSecurityAmountControllerText":
          vm.presentSecurityAmountController.text,
      "securityProviderRimNumberControllerText":
          vm.securityProviderRimNumberController.text,
      "securityNumberControllerText": vm.securityNumberController.text,
      "securityProviderNameControllerText":
          vm.securityProviderNameController.text,
    };
  }

  /// Restore previously saved draft into the ViewModel.
  @override
  void applyDraft(
    CreateSecurityViewModel vm,
    Map<String, dynamic> data,
  ) {
    final security = vm.security;

    security.securityGroup =
        _refFromJson(data["securityGroup"]) ?? security.securityGroup;
    security.securityType =
        _refFromJson(data["securityType"]) ?? security.securityType;
    security.securityStatus =
        _refFromJson(data["securityStatus"]) ?? security.securityStatus;
    security.selectedIsSecurityProviderCbdCustomerValue =
        _refFromJson(data["selectedIsSecurityProviderCbdCustomerValue"]) ??
            security.selectedIsSecurityProviderCbdCustomerValue;
    security.securityProviderCategory =
        data["securityProviderCategory"] as String? ??
            security.securityProviderCategory;
    security.securityProviderLegalStatus =
        _refFromJson(data["securityProviderLegalStatus"]) ??
            security.securityProviderLegalStatus;
    security.securityProviderTlNo = data["securityProviderTlNo"] as String? ??
        security.securityProviderTlNo;
    security.securityProviderAddress =
        data["securityProviderAddress"] as String? ??
            security.securityProviderAddress;
    security.securityProviderEmiratesId =
        data["securityProviderEmiratesId"] as int? ??
            security.securityProviderEmiratesId;
    security.securityProviderNationality =
        data["securityProviderNationality"] as String? ??
            security.securityProviderNationality;
    security.securityProvidedRim =
        data["securityProvidedRim"] as String? ?? security.securityProvidedRim;
    security.securityProvidedName = data["securityProvidedName"] as String? ??
        security.securityProvidedName;

    final dynamic countryJson = data["securityProvidedCountry"];
    if (countryJson != null && countryJson is Map) {
      security.securityProvidedCountry = Country(
        code: countryJson["code"] as String?,
        description: countryJson["description"] as String?,
      );
    }

    security.countryOfSecurity =
        data["countryOfSecurity"] as String? ?? security.countryOfSecurity;
    security.proposedSecurityAmtCurrency =
        _refFromJson(data["proposedSecurityAmtCurrency"]) ??
            security.proposedSecurityAmtCurrency;
    security.proposedSecurityAmount =
        data["proposedSecurityAmount"] as double? ??
            security.proposedSecurityAmount;
    security.presentSecurityAmtCurrency =
        _refFromJson(data["presentSecurityAmtCurrency"]) ??
            security.presentSecurityAmtCurrency;
    security.presentSecurityAmount = data["presentSecurityAmount"] as double? ??
        security.presentSecurityAmount;
    security.borrowerRole =
        _refFromJson(data["borrowerRole"]) ?? security.borrowerRole;
    security.securityHeldAs =
        _refFromJson(data["securityHeldAs"]) ?? security.securityHeldAs;
    security.isLimitCtrlSecurity =
        data["isLimitCtrlSecurity"] as bool? ?? security.isLimitCtrlSecurity;
    security.isTangibleSecurity =
        data["isTangibleSecurity"] as bool? ?? security.isTangibleSecurity;
    security.isCashCollateral =
        data["isCashCollateral"] as bool? ?? security.isCashCollateral;
    security.isSecurityExpiryOpenEnded =
        data["isSecurityExpiryOpenEnded"] as bool? ??
            security.isSecurityExpiryOpenEnded;

    if (data["securityExpireDate"] != null) {
      security.securityExpireDate =
          DateTime.tryParse(data["securityExpireDate"] as String) ??
              security.securityExpireDate;
    }

    security.emirates = _refFromJson(data["emirates"]) ?? security.emirates;
    security.deferredWaived =
        data["deferredWaived"] as String? ?? security.deferredWaived;
    security.selectedCashCollateralValue =
        _refFromJson(data["selectedCashCollateralValue"]) ??
            security.selectedCashCollateralValue;
    security.allFacilities =
        data["allFacilities"] as bool? ?? security.allFacilities;
    security.remarks = data["remarks"] as String? ?? security.remarks;
    security.cmoRemark = data["cmoRemarks"] as String? ?? security.cmoRemark;
    security.currentDepositAccountNumber =
        data["currentDepositAccountNumber"] as String? ??
            security.currentDepositAccountNumber;
    security.securityNumber =
        data["securityNumber"] as String? ?? security.securityNumber;

    if (data["dynamicFormDocument"] != null &&
        data["dynamicFormDocument"] is Map) {
      vm.dynamicFormDocument =
          Map<String, dynamic>.from(data["dynamicFormDocument"] as Map);
    }

    vm.securityProviderCbdCustomer =
        data["securityProviderCbdCustomer"] as bool? ??
            vm.securityProviderCbdCustomer;
    vm.isEntityProvider =
        data["isEntityProvider"] as bool? ?? vm.isEntityProvider;
    vm.isCountrySecurityUAE =
        data["isCountrySecurityUAE"] as bool? ?? vm.isCountrySecurityUAE;

    vm.proposedSecurityAmountController.text =
        data["proposedSecurityAmountControllerText"] as String? ??
            vm.proposedSecurityAmountController.text;
    vm.presentSecurityAmountController.text =
        data["presentSecurityAmountControllerText"] as String? ??
            vm.presentSecurityAmountController.text;
    vm.securityProviderRimNumberController.text =
        data["securityProviderRimNumberControllerText"] as String? ??
            vm.securityProviderRimNumberController.text;
    vm.securityNumberController.text =
        data["securityNumberControllerText"] as String? ??
            vm.securityNumberController.text;
    vm.securityProviderNameController.text =
        data["securityProviderNameControllerText"] as String? ??
            vm.securityProviderNameController.text;

    // Apply rte fields text if they are active
    if (vm.isFIFlow) {
      if (vm.remarksController != null && security.remarks != null) {
        vm.remarksController!.setText(security.remarks!);
      }
      if (vm.cmoRemarksController != null && security.cmoRemark != null) {
        vm.cmoRemarksController!.setText(security.cmoRemark!);
      }
    }

    // Removed early emit to prevent premature rendering before loadDynamicForm
    // completes

    // Also trigger dynamic form state update if there is any dynamic document
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.dynamicFormKey.currentState?.updateFields(vm.dynamicFormDocument);
    });
  }
}
