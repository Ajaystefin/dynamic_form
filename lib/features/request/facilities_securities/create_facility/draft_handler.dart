import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

/// Draft handler for the Create Facility screen.
///
/// Keeps [CreateFacilityViewModel] focused on business logic by
/// owning auto-save serialization/deserialization of user-entered state.
class CreateFacilityDraftHandler extends DraftHandler<CreateFacilityViewModel> {
  /// Helper to serialize a Reference safely.
  Map<String, dynamic>? _refToJson(Reference? ref) {
    if (ref == null) {
      return null;
    }
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
  Reference? _refFromJson(json) {
    if (json == null || json is! Map) {
      return null;
    }
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
  Map<String, dynamic> buildDraftData(CreateFacilityViewModel vm) {
    vm.formKey.currentState?.save();
    vm.dynamicFormKey.currentState?.save();

    final facility = vm.getFacility;

    return <String, dynamic>{
      "facilityDescription": _refToJson(facility.facilityDescription),
      "selectedProductTypeValue": _refToJson(facility.selectedProductTypeValue),
      "selectedProjectFinanceRelatedActivityValue":
          _refToJson(facility.selectedProjectFinanceRelatedActivityValue),
      "sharedLimit": _refToJson(facility.sharedLimit),
      "selectedCollateralDepantantValue":
          _refToJson(facility.selectedCollateralDepantantValue),
      "selectedpromissoryNoteValue":
          _refToJson(facility.selectedpromissoryNoteValue),
      "selectedRegulatorySpecialisedLandingValue":
          _refToJson(facility.selectedRegulatorySpecialisedLandingValue),
      "seniorityValue": _refToJson(facility.seniorityValue),
      "advanceTypeValue": _refToJson(facility.advanceTypeValue),
      "sector": _refToJson(facility.sector),
      "sicCode": _refToJson(facility.sicCode),
      "accountTypeValue": _refToJson(facility.accountTypeValue),
      "purposeValue": _refToJson(facility.purpose),
      "propertyType": _refToJson(facility.propertyType),
      "propertySubType": _refToJson(facility.propertySubType),
      "emirates": _refToJson(facility.emirates),
      "committedValues": _refToJson(facility.committedValues),
      "regulatorySpecification": _refToJson(facility.regulatorySpecification),
      "selectedLimitTypeValue": _refToJson(facility.selectedLimitTypeValue),

      // Lists
      "sustainabilityClassification":
          facility.sustainabilityClassification?.map(_refToJson).toList(),
      "policyDeviation": facility.policyDeviation?.map(_refToJson).toList(),
      "feeDefualtRate": vm.feeDefualtRate.map((e) => e.toJson()).toList(),
      "standardCondition": vm.standardCondition.map((e) => e.toJson()).toList(),
      "nonStandardCondition":
          vm.nonStandardCondition.map((e) => e.toJson()).toList(),
      "contractingStandardCondition":
          vm.contractingStandardCondition.map((e) => e.toJson()).toList(),

      // Numeric/String
      "proposedLimit": facility.proposedLimit,
      "presentLimit": facility.presentLimit,
      "originalLimit": facility.originalLimit,
      "currency": facility.currency,
      "countryOfRisk": facility.countryOfRisk,
      "remarks": facility.remarks,
      "facilityTitle": facility.facilityTitle,
      "index": facility.index,
      "marginSign": facility.marginSign,
      "marginValue": facility.marginValue,
      "limitAvailabilityPeriod": facility.limitAvailabilityPeriod,
      "limitLabel": facility.limitLabel,
      "isMainLimit": facility.isMainLimit,
      "isCommitted": facility.isCommitted,
      "limitCategory": facility.limitCategory,
      "productCodeProject": facility.productCodeProject,

      // Tenor
      "tenorUnit": _refToJson(facility.tenorUnit),
      "tenorValue": facility.tenorValue,

      // Date fields
      "limitExpireDate": facility.limitExpireDate?.toIso8601String(),
      "limitAvailabilityDate":
          facility.limitAvailabilityDate?.toIso8601String(),

      // FI specific
      if (vm.isFIFlow) ...{
        "excessOverMaxLimitAllowanceByFi":
            facility.excessOverMaxLimitAllowanceByFi,
        "excessOverMaxLimitAllowanceCurrencyByFi":
            _refToJson(facility.excessOverMaxLimitAllowanceCurrencyByFi),
        "cbdEquityTier325Percent": facility.cbdEquityTier325Percent,
        "cbdEquityTier325PercentCurrency":
            _refToJson(facility.cbdEquityTier325PercentCurrency),
        "counterpartyEquity5Percent": facility.counterpartyEquity5Percent,
        "counterpartyEquity5PercentCurrency":
            _refToJson(facility.counterpartyEquity5PercentCurrency),
        "counterpartyTotalAssets2Percent":
            facility.counterpartyTotalAssets2Percent,
        "counterpartyTotalAssets2PercentCurrency":
            _refToJson(facility.counterpartyTotalAssets2PercentCurrency),
        "excessOverMaxLimitAllowanceByCredit":
            facility.excessOverMaxLimitAllowanceByCredit,
        "excessOverMaxLimitAllowanceCurrencyByCredit":
            _refToJson(facility.excessOverMaxLimitAllowanceCurrencyByCredit),
      },

      // Controllers
      "limitTypeControllerText": vm.limitTypeController.text,
      "limitDescriptionControllerText": vm.limitDescriptionController.text,
      "proposedLimitControllerText": vm.proposedLimitController.text,
      "newProposedLimitControllerText": vm.newProposedLimitController.text,
      "presentLimitControllerText": vm.presentLimitController.text,
      "newPresentLimitControllerText": vm.newPresentLimitController.text,

      // FI controllers
      if (vm.isFIFlow) ...{
        "revisedBankLimitProposedByFiControllerText":
            vm.proposedLimitController.text,
        "excessOverMaxLimitAllowanceProposedByFiControllerText":
            vm.excessOverMaxLimitAllowanceProposedByFiController.text,
        "cbdEquityTier325PercentControllerText":
            vm.cbdEquityTier325PercentController.text,
        "counterpartyEquity5PercentControllerText":
            vm.counterpartyEquity5PercentController.text,
        "counterpartyTotalAssets2PercentControllerText":
            vm.counterpartyTotalAssets2PercentController.text,
        "revisedBankLimitRecommendedByCreditControllerText":
            vm.proposedByccController.text,
        "excessOverMaxLimitAllowanceRecommendedByCreditControllerText":
            vm.excessOverMaxLimitAllowanceRecommendedByCreditController.text,
      },

      // VM state
      "isLimitCaps": vm.isLimitCaps,
      "isFeeRowMandatory": vm.isFeeRowMandatory,
      "subLimit": vm.subLimit,
      "limitCategoryVM": vm.limitCategory,
      "productType": vm.productType,
      "selectedAccountTypes": vm.selectedAccountTypes.map(_refToJson).toList(),

      // Map Borrowers list back to clean list of maps
      "borrowersByRimInTable":
          vm.borrowersByRimInTable.map(_refToJson).toList(),

      // Dynamic Form Map
      "dynamicFormDocument": vm.dynamicFormDocument,

      // facilityDetails
      "facilityDetailsLimitCapType": vm.facilityDetails.limitCapType,
    };
  }

  /// Restore previously saved draft into the ViewModel.
  @override
  void applyDraft(
    CreateFacilityViewModel vm,
    Map<String, dynamic> data,
  ) {
    final facility = vm.getFacility;

    facility
      ..facilityDescription = _refFromJson(data["facilityDescription"]) ??
          facility.facilityDescription
      ..selectedProductTypeValue =
          _refFromJson(data["selectedProductTypeValue"]) ??
              facility.selectedProductTypeValue
      ..selectedProjectFinanceRelatedActivityValue =
          _refFromJson(data["selectedProjectFinanceRelatedActivityValue"]) ??
              facility.selectedProjectFinanceRelatedActivityValue
      ..sharedLimit = _refFromJson(data["sharedLimit"]) ?? facility.sharedLimit
      ..selectedCollateralDepantantValue =
          _refFromJson(data["selectedCollateralDepantantValue"]) ??
              facility.selectedCollateralDepantantValue
      ..selectedpromissoryNoteValue =
          _refFromJson(data["selectedpromissoryNoteValue"]) ??
              facility.selectedpromissoryNoteValue
      ..selectedRegulatorySpecialisedLandingValue =
          _refFromJson(data["selectedRegulatorySpecialisedLandingValue"]) ??
              facility.selectedRegulatorySpecialisedLandingValue
      ..seniorityValue =
          _refFromJson(data["seniorityValue"]) ?? facility.seniorityValue
      ..advanceTypeValue =
          _refFromJson(data["advanceTypeValue"]) ?? facility.advanceTypeValue
      ..sector = _refFromJson(data["sector"]) ?? facility.sector
      ..sicCode = _refFromJson(data["sicCode"]) ?? facility.sicCode
      ..accountTypeValue =
          _refFromJson(data["accountTypeValue"]) ?? facility.accountTypeValue
      ..purpose = _refFromJson(data["purposeValue"]) ?? facility.purpose
      ..propertyType =
          _refFromJson(data["propertyType"]) ?? facility.propertyType
      ..propertySubType =
          _refFromJson(data["propertySubType"]) ?? facility.propertySubType
      ..emirates = _refFromJson(data["emirates"]) ?? facility.emirates
      ..committedValues =
          _refFromJson(data["committedValues"]) ?? facility.committedValues
      ..regulatorySpecification =
          _refFromJson(data["regulatorySpecification"]) ??
              facility.regulatorySpecification
      ..selectedLimitTypeValue = _refFromJson(data["selectedLimitTypeValue"]) ??
          facility.selectedLimitTypeValue;

    if (data["sustainabilityClassification"] != null &&
        data["sustainabilityClassification"] is List) {
      facility.sustainabilityClassification =
          (data["sustainabilityClassification"] as List)
              .map(_refFromJson)
              .whereType<Reference>()
              .toList();
    }
    if (data["policyDeviation"] != null && data["policyDeviation"] is List) {
      facility.policyDeviation = (data["policyDeviation"] as List)
          .map(_refFromJson)
          .whereType<Reference>()
          .toList();
    }
    if (data["feeDefualtRate"] != null && data["feeDefualtRate"] is List) {
      vm.feeDefualtRate = (data["feeDefualtRate"] as List)
          .map((e) => FeeRate.fromJson(e))
          .toList();
    }
    if (data["standardCondition"] != null &&
        data["standardCondition"] is List) {
      vm.standardCondition = (data["standardCondition"] as List)
          .map((e) => Condition.fromJson(e))
          .toList();
    }
    if (data["nonStandardCondition"] != null &&
        data["nonStandardCondition"] is List) {
      vm.nonStandardCondition = (data["nonStandardCondition"] as List)
          .map((e) => Condition.fromJson(e))
          .toList();
    }
    if (data["contractingStandardCondition"] != null &&
        data["contractingStandardCondition"] is List) {
      vm.contractingStandardCondition =
          (data["contractingStandardCondition"] as List)
              .map((e) => Condition.fromJson(e))
              .toList();
    }

    facility
      ..proposedLimit = data["proposedLimit"] as int? ?? facility.proposedLimit
      ..presentLimit = data["presentLimit"] as int? ?? facility.presentLimit
      ..originalLimit = data["originalLimit"] as int? ?? facility.originalLimit
      ..currency = data["currency"] as String? ?? facility.currency
      ..countryOfRisk =
          data["countryOfRisk"] as String? ?? facility.countryOfRisk
      ..remarks = data["remarks"] as String? ?? facility.remarks
      ..facilityTitle =
          data["facilityTitle"] as String? ?? facility.facilityTitle
      ..index = data["index"] as String? ?? facility.index
      ..marginSign = data["marginSign"] as String? ?? facility.marginSign
      ..marginValue = data["marginValue"] as String? ?? facility.marginValue
      ..limitAvailabilityPeriod = data["limitAvailabilityPeriod"] as String? ??
          facility.limitAvailabilityPeriod
      ..limitLabel = data["limitLabel"] as String? ?? facility.limitLabel
      ..isMainLimit = data["isMainLimit"] as bool? ?? facility.isMainLimit
      ..isCommitted = data["isCommitted"] as bool? ?? facility.isCommitted
      ..limitCategory =
          data["limitCategory"] as String? ?? facility.limitCategory
      ..productCodeProject =
          data["productCodeProject"] as String? ?? facility.productCodeProject
      ..tenorUnit = _refFromJson(data["tenorUnit"]) ?? facility.tenorUnit
      ..tenorValue = data["tenorValue"] as num? ?? facility.tenorValue;

    if (data["limitExpireDate"] != null) {
      facility.limitExpireDate =
          DateTime.tryParse(data["limitExpireDate"] as String) ??
              facility.limitExpireDate;
    }
    if (data["limitAvailabilityDate"] != null) {
      facility.limitAvailabilityDate =
          DateTime.tryParse(data["limitAvailabilityDate"] as String) ??
              facility.limitAvailabilityDate;
    }

    if (vm.isFIFlow) {
      facility
        ..excessOverMaxLimitAllowanceByFi =
            data["excessOverMaxLimitAllowanceByFi"] as double? ??
                facility.excessOverMaxLimitAllowanceByFi
        ..excessOverMaxLimitAllowanceCurrencyByFi =
            _refFromJson(data["excessOverMaxLimitAllowanceCurrencyByFi"]) ??
                facility.excessOverMaxLimitAllowanceCurrencyByFi
        ..cbdEquityTier325Percent =
            data["cbdEquityTier325Percent"] as double? ??
                facility.cbdEquityTier325Percent
        ..cbdEquityTier325PercentCurrency =
            _refFromJson(data["cbdEquityTier325PercentCurrency"]) ??
                facility.cbdEquityTier325PercentCurrency
        ..counterpartyEquity5Percent =
            data["counterpartyEquity5Percent"] as double? ??
                facility.counterpartyEquity5Percent
        ..counterpartyEquity5PercentCurrency =
            _refFromJson(data["counterpartyEquity5PercentCurrency"]) ??
                facility.counterpartyEquity5PercentCurrency
        ..counterpartyTotalAssets2Percent =
            data["counterpartyTotalAssets2Percent"] as double? ??
                facility.counterpartyTotalAssets2Percent
        ..counterpartyTotalAssets2PercentCurrency =
            _refFromJson(data["counterpartyTotalAssets2PercentCurrency"]) ??
                facility.counterpartyTotalAssets2PercentCurrency
        ..excessOverMaxLimitAllowanceByCredit =
            data["excessOverMaxLimitAllowanceByCredit"] as double? ??
                facility.excessOverMaxLimitAllowanceByCredit
        ..excessOverMaxLimitAllowanceCurrencyByCredit =
            _refFromJson(data["excessOverMaxLimitAllowanceCurrencyByCredit"]) ??
                facility.excessOverMaxLimitAllowanceCurrencyByCredit;
    }

    vm.limitTypeController.text = data["limitTypeControllerText"] as String? ??
        vm.limitTypeController.text;
    vm.limitDescriptionController.text =
        data["limitDescriptionControllerText"] as String? ??
            vm.limitDescriptionController.text;
    vm.proposedLimitController.text =
        data["proposedLimitControllerText"] as String? ??
            vm.proposedLimitController.text;
    vm.newProposedLimitController.text =
        data["newProposedLimitControllerText"] as String? ??
            vm.newProposedLimitController.text;
    vm.presentLimitController.text =
        data["presentLimitControllerText"] as String? ??
            vm.presentLimitController.text;
    vm.newPresentLimitController.text =
        data["newPresentLimitControllerText"] as String? ??
            vm.newPresentLimitController.text;

    if (vm.isFIFlow) {
      vm.proposedLimitController.text =
          data["revisedBankLimitProposedByFiControllerText"] as String? ??
              vm.proposedLimitController.text;
      vm.excessOverMaxLimitAllowanceProposedByFiController.text =
          data["excessOverMaxLimitAllowanceProposedByFiControllerText"]
                  as String? ??
              vm.excessOverMaxLimitAllowanceProposedByFiController.text;
      vm.cbdEquityTier325PercentController.text =
          data["cbdEquityTier325PercentControllerText"] as String? ??
              vm.cbdEquityTier325PercentController.text;
      vm.counterpartyEquity5PercentController.text =
          data["counterpartyEquity5PercentControllerText"] as String? ??
              vm.counterpartyEquity5PercentController.text;
      vm.counterpartyTotalAssets2PercentController.text =
          data["counterpartyTotalAssets2PercentControllerText"] as String? ??
              vm.counterpartyTotalAssets2PercentController.text;
      vm.proposedByccController.text =
          data["revisedBankLimitRecommendedByCreditControllerText"]
                  as String? ??
              vm.proposedByccController.text;
      vm.excessOverMaxLimitAllowanceRecommendedByCreditController.text =
          data["excessOverMaxLimitAllowanceRecommendedByCreditControllerText"]
                  as String? ??
              vm.excessOverMaxLimitAllowanceRecommendedByCreditController.text;
    }

    vm
      ..isLimitCaps = data["isLimitCaps"] as bool? ?? vm.isLimitCaps
      ..isFeeRowMandatory =
          data["isFeeRowMandatory"] as bool? ?? vm.isFeeRowMandatory
      ..subLimit = data["subLimit"] as bool? ?? vm.subLimit
      ..limitCategory = data["limitCategoryVM"] as String? ?? vm.limitCategory
      ..productType = data["productType"] as int? ?? vm.productType;

    if (data["selectedAccountTypes"] != null &&
        data["selectedAccountTypes"] is List) {
      vm.selectedAccountTypes = (data["selectedAccountTypes"] as List)
          .map(_refFromJson)
          .whereType<Reference>()
          .toList();
    }

    if (data["borrowersByRimInTable"] != null &&
        data["borrowersByRimInTable"] is List) {
      vm.borrowersByRimInTable = (data["borrowersByRimInTable"] as List)
          .map(_refFromJson)
          .whereType<Reference>()
          .toList();
    }

    if (data["facilityDetailsLimitCapType"] != null) {
      vm.facilityDetails.limitCapType =
          data["facilityDetailsLimitCapType"] as int;
    }

    if (data["dynamicFormDocument"] != null &&
        data["dynamicFormDocument"] is Map) {
      vm.dynamicFormDocument =
          Map<String, dynamic>.from(data["dynamicFormDocument"] as Map);
    }
  }
}
