import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/home_repository.dart";

enum Naturefund {
  funded,
  nonfunded,
}

enum Segment {
  corporate,
  fi,
}

class OthersLimitDialogViewModel extends SafeCubit<OthersLimitDialogState> {
  OthersLimitDialogViewModel()
      : super(
          OthersLimitDialogState(
            loaderStatus: LoadingStatus.loading,
            saveButtonStatus: LoadingStatus.loaded,
          ),
        );
  late AdminRepository repository;
  ReferenceDataService referenceDataService = ReferenceDataService();
  FocusNode formFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Reference reference = Reference();
  List<ReferenceType> allReferences = [];
  List<Reference> limitTypes = [];
  List<Reference> facilityTypes = [];
  int? referenceDataTypeID = 0;

  ReferenceType? selectedReferenceType;

  final List<TextInputFormatter> limitCodeFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp("[A-Z]")),
      ];
  final List<TextInputFormatter> descriptionFormatters = [];
  final List<TextInputFormatter> reference1Formatters = [];
  final List<TextInputFormatter> reference2Formatters = [];
  final List<TextInputFormatter> reference3Formatters = [];
  final List<TextInputFormatter> reference4Formatters = [];
  final List<TextInputFormatter> reference5Formatters = [];

  List<String> natureOfFund = [
    Naturefund.funded.name.capitalizeFirstLetter(),
    Naturefund.nonfunded.name.capitalizeFirstLetter(),
  ];

  // Product type
  List<Reference> productTypeOptions = [];
  Reference? selectedProductTypeOption;

  Facility facility = Facility();

  // radio selections
  Naturefund? selectedNatureFund;
  Segment? selectedSegment;

  // hold incoming context (for later API decisions, validation, etc.)
  int? limitGroupId;
  int? rimNo;
  int? selectedDescriptionId;
  String? limitNumber;
  bool? isMainLimit;
  bool? isProductTyopeEnabled;
  Reference? productTypeValue;
  Future<void> init(
    Reference? reference,
    ReferenceType? referenceType,
    int? limitGroupId,
    int? selectedDescriptionId,
    int? rimNo,
    bool? isMainLimit,
    String? limitNumber,
    Reference? productTypeValue,
    bool? isProductTypeEnabled,
  ) async {
    logger.i("initialising UpdateReferenceDialogViewModel");

    repository = AdminRepository.instance;
    //Store incoming values FIRST (so we can use them right after loading
    //options)
    this.rimNo = rimNo;
    this.productTypeValue = productTypeValue;
    isProductTyopeEnabled = isProductTypeEnabled;
    this.limitGroupId = limitGroupId;
    this.isMainLimit = isMainLimit;
    this.limitNumber = limitNumber;
    this.productTypeValue = productTypeValue;
    this.selectedDescriptionId = selectedDescriptionId;
    await Future.wait([
      getReferenceData(),
      getUpdatedFacilityReference(),
    ]);

    if (productTypeOptions.isNotEmpty) {
      if (this.productTypeValue != null) {
        final int? incomingId = this.productTypeValue!.id;
        // Try to match by ID; fall back to first option if not found
        Reference? matched;
        for (final r in productTypeOptions) {
          if (r.id == incomingId) {
            matched = r;
            break;
          }
        }
        selectedProductTypeOption =
            matched ?? (selectedProductTypeOption ?? productTypeOptions.first);
      } else {
        // Keep existing selection or default to first
        selectedProductTypeOption ??= productTypeOptions.first;
      }

      // Keep Facility mirror in sync so Create Facility screen sees it
      facility.selectedProductTypeValue = selectedProductTypeOption;

      // reuse your setter so both VM + facility are kept in sync
      if (selectedProductTypeOption != null) {
        changeProductTypeOptions(selectedProductTypeOption!);
      }
    }

    if (selectedNatureFund == null) {
      changeNatureOfFund(
        Naturefund.funded,
      ); // sets selectedNatureFund + reference.reference2
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// used for geting the updated list with newly created Facility types
  Future<void> getUpdatedFacilityReference() async {
    final String facilityTypeKey = isFIFlow
        ? ReferenceDataKeys.fiFacilityTypes
        : ReferenceDataKeys.facilityTypes;

    try {
      final List<ReferenceType> getReferenceData =
          await HomeRepository.instance.getReferenceData([facilityTypeKey]);

      facilityTypes = getReferenceData[0].references ?? [];
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
  Future<void> getReferenceData() async {
    try {
      final String limitTypeKey = isFIFlow
          ? ReferenceDataKeys.fiLimitType
          : ReferenceDataKeys.limitType;
      final Map<String, List<Reference>> referenceData =
          await referenceDataService.getReferenceData([
        ReferenceDataKeys.productType,
        limitTypeKey,
        ReferenceDataKeys.sustanabilityClassification,
        ReferenceDataKeys.period,
        ReferenceDataKeys.marginSign,
        ReferenceDataKeys.benchMark,
        ReferenceDataKeys.limitCapsType,
      ]);
      limitTypes = referenceData[limitTypeKey] ?? [];
      productTypeOptions = (referenceData[ReferenceDataKeys.productType] ?? [])
          .where((data) => data.id != ServerConstants.optionBothId)
          .toList();
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  // Handy label method for UI
  String natureOfFundLabel(Naturefund natureOfFundType) {
    // If you have localization keys, map them here.
    switch (natureOfFundType) {
      case Naturefund.funded:
        return "Funded".tr();
      case Naturefund.nonfunded:
        return "Non-Funded".tr();
    }
  }

  /// Call in radio onChanged; stores to reference.reference2 as a stable code.
  void changeNatureOfFund(Naturefund natureOfFundType) {
    selectedNatureFund = natureOfFundType;
    // Persist a compact code: 'F' or 'NF'
    reference.reference2 = (natureOfFundType == Naturefund.funded) ? "F" : "N";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Label helper for Segment
  String segmentLabel(Segment segmentType) {
    switch (segmentType) {
      case Segment.corporate:
        return "Corporate".tr();
      case Segment.fi:
        return "FI".tr();
    }
  }

  // setter + persist a compact code in reference.reference3
  void changeSegment(Segment segmentType) {
    selectedSegment = segmentType;
    // Persist a stable code: 'C' for Corporate, 'FI' for Financial Institution
    reference.reference3 = (segmentType == Segment.corporate) ? "C" : "FI";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeProductTypeOptions(Reference selectedProductType) {
    final bool hasChanged =
        selectedProductTypeOption?.id != selectedProductType.id;
    selectedProductTypeOption = selectedProductType;

    reference.reference1 = (selectedProductType.reference1 ?? "").trim();

    facility.selectedProductTypeValue = selectedProductType;
    if (hasChanged) {
      facility.facilityTypeSelectedValue = null;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> createReference(Reference ref) async {
    try {
      await AdminRepository.instance.saveReferenceDataInformation(
        ServerConstants.facilityTypeReferenceID,
        ref,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> onSaveButtonClick(BuildContext context) async {
    if (facilityTypes.any(
      (facilityType) => facilityType.reference3 == reference.reference3,
    )) {
      AlertManager().showFailureToast(
        "Limit code already exists. Please enter a unique code",
      );
      return;
    }
    try {
      if (!formKey.currentState!.validate()) {
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      } else {
        // Persist current field values into the VM.reference
        formKey.currentState?.save();

        emit(state.copyWith(saveButtonStatus: LoadingStatus.loading));

        // Build a facility payload mirroring AddFacilitySubLimitBox usage
        //    NOTE: We pack dialog values inside
        // facilityDescription.reference{1..5}
        //    so Create Facility screen can read everything from one object.
        final Reference facilityDescriptionRef = Reference(
          id: null, // "Others" id coming from parent
          name: reference.name, // Limit Description (entered)
          description: reference.description, // Comments
          reference1: reference.reference1, // (free for future use)
          reference2: reference.reference2, // Nature of Fund: 'F' / 'N' or 'NF'
          reference3: reference.reference3, // Segment: 'C' / 'FI'
          reference4: reference.reference4, // Sub Type
          reference5: ServerConstants.newProductCode,
          typeId: null,
          isActive: true,
          status: Status.active.name,
          createdBy: Globals.user?.id,
          createdDate: DateTime.now(),
          updatedBy: Globals.user?.id,
        );
        await createReference(facilityDescriptionRef);

        // Limit group that this facility belongs to (from parent)
        final int? limitGroup = limitGroupId;

        // Product type selected in this dialog (Conventional/Islamic radio)
        final Reference? selectedProductTypeValue = selectedProductTypeOption;

        // You didn’t pass these into the dialog. Keep them null/false for now.
        // const int? selectedRim = null;
        // const bool isMainLimit = false;
        const int? proposedLimit = null;
        // const String? limitNumber = null;
        const Reference? projectName = null;
        // const String? productCodeProject = null;
        // Extract Product Code from the saved form state
        final String? productCodeProject =
            reference.reference4?.trim().toUpperCase();

        const bool limitType = false;

        // Navigate to Create Facility screen with the payload
        router.go(
          Routes.createFacility,
          extra: CreateFacilityArgs(
            facility: Facility(
              facilityDescription: facilityDescriptionRef,
              // helpful mirrors for quick access in the next screen:
              limitDescription: facilityDescriptionRef.name,
              limitCode: facilityDescriptionRef.id,
              limitGroup: limitGroup,
              limitType: limitType,
              rimNo: rimNo,
              proposedLimit: proposedLimit,

              // if you capture this in dialog later, set it here:
              facilityTypeSelectedValue: facility.facilityTypeSelectedValue,
              selectedProductTypeValue: selectedProductTypeValue,
              limitNumber: limitNumber,
              isMainLimit: isMainLimit,
              projectName: projectName,
              productCodeProject: productCodeProject,

              // set a default category to what user chose in Nature of Fund
              // (your other flows read limitCategory as 'F'/'NF')
              limitCategory: reference.reference2,
            ),
            showCreateFacilityForm: true,
          ),
        );

        // Optionally close the dialog if navigation is instantaneous:
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
  }
}
