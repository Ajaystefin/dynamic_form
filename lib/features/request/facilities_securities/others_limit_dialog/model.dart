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

/// Represents the nature of fund associated with a product or limit.
enum Naturefund {
  /// Funded nature of fund.
  funded,

  /// Non-funded nature of fund.
  nonfunded,
}

/// View model responsible for managing the state and business logic of the
/// "Others Limit" dialog.
///
/// Responsibilities:
/// - Load reference data required by the dialog
/// - Maintain form state and selected values
/// - Validate user input before save
/// - Save the newly created limit reference
/// - Navigate to the Create Facility screen with the prepared payload
///
/// View model responsible for managing the Others Limit dialog state,
/// reference data loading, validation, and save operations.
class OthersLimitDialogViewModel extends SafeCubit<OthersLimitDialogState> {
  /// Creates an others limit dialog view model with the initial state.
  OthersLimitDialogViewModel()
      : super(
          OthersLimitDialogState(
            loaderStatus: LoadingStatus.loading,
            saveButtonStatus: LoadingStatus.loaded,
          ),
        );

  /// Repository used for reference data administration operations.
  late AdminRepository repository;

  /// Service used to retrieve reference data for dropdowns and lookups.
  ReferenceDataService referenceDataService = ReferenceDataService();

  /// Focus node used to manage form focus behavior.
  FocusNode formFocusNode = FocusNode();

  /// Global key for the others limit dialog form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Reference record being created or edited.
  Reference reference = Reference();

  /// Available reference types retrieved from the backend.
  List<ReferenceType> allReferences = [];

  /// Available limit type options.
  List<Reference> limitTypes = [];

  /// Available facility type options.
  List<Reference> facilityTypes = [];

  /// Selected reference data type identifier.
  int? referenceDataTypeID = 0;

  /// Currently selected reference type.
  ReferenceType? selectedReferenceType;

  /// Input formatters used for limit code validation.
  ///
  /// Allows uppercase alphabetic characters only.
  final List<TextInputFormatter> limitCodeFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp("[A-Z]")),
  ];

  /// Reserved input formatters for future description field validation
  /// and formatting requirements.
  final List<TextInputFormatter> descriptionFormatters = [];

  /// Reserved input formatters for future reference1 field validation
  /// and formatting requirements.
  final List<TextInputFormatter> reference1Formatters = [];

  /// Reserved input formatters for future reference2 field validation
  /// and formatting requirements.
  final List<TextInputFormatter> reference2Formatters = [];

  /// Reserved input formatters for future reference3 field validation
  /// and formatting requirements.
  final List<TextInputFormatter> reference3Formatters = [];

  /// Reserved input formatters for future reference4 field validation
  /// and formatting requirements.
  final List<TextInputFormatter> reference4Formatters = [];

  /// Reserved input formatters for future reference5 field validation
  /// and formatting requirements.
  final List<TextInputFormatter> reference5Formatters = [];

  /// Display labels for Nature of Fund options.
  List<String> natureOfFund = [
    Naturefund.funded.name.capitalizeFirstLetter(),
    Naturefund.nonfunded.name.capitalizeFirstLetter(),
  ];

  /// Available product type options.
  List<Reference> productTypeOptions = [];

  /// Currently selected product type option.
  ///
  /// Examples include Conventional and Islamic.
  Reference? selectedProductTypeOption;

  /// Facility context associated with the others limit dialog.
  Facility facility = Facility();

  /// Currently selected nature of fund.
  Naturefund? selectedNatureFund;

  /// Limit group identifier passed to the dialog context.
  int? limitGroupId;

  /// RIM number associated with the selected limit.
  int? rimNo;

  /// Selected limit description identifier.
  int? selectedDescriptionId;

  /// Limit number associated with the selected facility.
  String? limitNumber;

  /// Indicates whether the selected limit is a main limit.
  bool? isMainLimit;

  /// Indicates whether product type selection is enabled.
  bool? isProductTyopeEnabled;

  /// Selected product type value.
  Reference? productTypeValue;

  /// Returns whether the current request belongs to the
  /// Financial Institution business segment.
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Controller used for Limit Type custom edit mode text.
  final TextEditingController limitTypeEditController = TextEditingController();

  /// Indicates whether Limit Type is currently in edit mode.
  bool isLimitTypeInEditMode = false;

  /// Stores the custom Limit Type text entered in edit mode.
  String customLimitTypeText = "";

  /// Controls whether required validation message should be shown
  /// below the Limit Type field.
  bool showLimitTypeRequiredError = false;

  /// Initializes the dialog by:
  /// - storing incoming context
  /// - loading reference data and facility types
  /// - preselecting product type
  /// - applying default Nature of Fund if needed
  Future<void> init(
    Reference? reference,
    ReferenceType? referenceType,
    int? limitGroupId,
    int? selectedDescriptionId,
    int? rimNo,
    String? limitNumber,
    Reference? productTypeValue, {
    bool? isMainLimit,
    bool? isProductTypeEnabled,
  }) async {
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
        Reference? matchedProductType;
        for (final Reference option in productTypeOptions) {
          if (option.id == incomingId) {
            matchedProductType = option;
            break;
          }
        }
        selectedProductTypeOption = matchedProductType ??
            (selectedProductTypeOption ?? productTypeOptions.first);
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

  /// Loads the latest facility type references.
  ///
  /// This is used to validate duplicate limit code values before save
  Future<void> getUpdatedFacilityReference() async {
    final String facilityTypeKey = isFIFlow
        ? ReferenceDataKeys.fiFacilityTypes
        : ReferenceDataKeys.facilityTypes;

    try {
      final List<ReferenceType> getReferenceData =
          await HomeRepository.instance.getReferenceData([facilityTypeKey]);

      facilityTypes = getReferenceData[0].references ?? [];
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Loads reference data used by the dialog, such as:
  /// - product types
  /// - limit types
  /// - supporting lookup data
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
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Returns the display label for the selected nature of fund.
  String natureOfFundLabel(Naturefund natureOfFundType) {
    // If you have localization keys, map them here.
    switch (natureOfFundType) {
      case Naturefund.funded:
        return "Funded".tr();
      case Naturefund.nonfunded:
        return "Non-Funded".tr();
    }
  }

  /// Updates the selected nature of fund and persists a stable code:
  /// - `F` for Funded
  /// - `N` for Non-Funded
  void changeNatureOfFund(Naturefund natureOfFundType) {
    selectedNatureFund = natureOfFundType;
    // Persist a compact code: 'F' or 'NF'
    reference.reference2 = (natureOfFundType == Naturefund.funded) ? "F" : "N";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected product type and synchronizes it with the draft facility.
  ///
  /// If the product type changes, the selected facility type is reset to avoid
  /// carrying forward an incompatible limit/facility type
  void changeProductTypeOptions(Reference selectedOption) {
    final bool hasProductTypeChanged =
        selectedProductTypeOption?.id != selectedOption.id;
    selectedProductTypeOption = selectedOption;

    reference.reference1 = (selectedOption.reference1 ?? "").trim();

    facility.selectedProductTypeValue = selectedOption;
    if (hasProductTypeChanged) {
      facility.facilityTypeSelectedValue = null;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the newly created facility reference to backend reference data storage.
  Future<void> createReference(Reference referenceToSave) async {
    try {
      await AdminRepository.instance.saveReferenceDataInformation(
        ServerConstants.facilityTypeReferenceID,
        referenceToSave,
      );
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Validates the Limit Code entered by the user.
  ///
  /// Validation rules:
  /// - value is required
  /// - value must contain only letters and digits
  /// - value must be 1 to 4 characters long
  /// - a 4-digit numeric-only code is not allowed
  ///
  /// Returns a localized validation error message if invalid,
  /// otherwise returns `null`
  String? validateProductCode(String? value) {
    final String code = (value ?? "").trim().toUpperCase();

    if (code.isEmpty) {
      return "common.validation.emptyField".tr();
    }

    // allow only 1 to 4 alphanumeric characters
    if (!RegExp(r"^[A-Z0-9]{1,4}$").hasMatch(code)) {
      return "facilities.facilitySummary.limitCodeMaxLength".tr();
    }

    // reject exactly 4 numeric digits like 1234
    if (RegExp(r"^\d{4}$").hasMatch(code)) {
      return "facilities.facilitySummary.invalidLimitCodeMessage".tr();
    }

    return null;
  }

  /// Handles Save button click.
  ///
  /// Workflow:
  /// 1. Validate mandatory selections
  /// 2. Validate form fields
  /// 3. Check duplicate limit code
  /// 4. Save the reference
  /// 5. Navigate to Create Facility screen
  Future<void> onSaveButtonClick(BuildContext context) async {
    final bool isFormValid = formKey.currentState?.validate() ?? false;

    // Check only non-text-field required selections here
    final bool hasMissingSelections = selectedProductTypeOption == null ||
        selectedNatureFund == null ||
        isLimitTypeMissing;

    if (hasMissingSelections) {
      showLimitTypeRequiredError = isLimitTypeMissing;

      AlertManager().showFailureToast(
        "facilities.facilitySummary.fillRequiredFields".tr(),
      );
      emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    if (!isFormValid) {
      final String code = (reference.reference3 ?? "").trim().toUpperCase();
      if (RegExp(r"^\d{4}$").hasMatch(code)) {
        AlertManager().showFailureToast(
          "facilities.facilitySummary.invalidLimitCodeMessage".tr(),
        );
      }
      emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      return;
    }

    if (facilityTypes.any(
      (facilityType) => facilityType.reference3 == reference.reference3,
    )) {
      AlertManager().showFailureToast(
        "facilities.facilitySummary.uniqueLimitCode".tr(),
      );
      return;
    }

    try {
      formKey.currentState?.save();

      emit(state.copyWith(saveButtonStatus: LoadingStatus.loading));

      final Reference facilityDescriptionRef = Reference(
        name: reference.name,
        description: reference.description,
        reference1: reference.reference1,
        reference2: reference.reference2,
        reference3: reference.reference3,
        reference4: reference.reference4,
        reference5: ServerConstants.newProductCode,
        isActive: true,
        status: Status.active.name,
        createdBy: Globals.user?.id,
        createdDate: DateTime.now(),
        updatedBy: Globals.user?.id,
      );

      await createReference(facilityDescriptionRef);

      final int? limitGroup = limitGroupId;
      final Reference? selectedProductTypeValue = selectedProductTypeOption;

      final String? productCodeProject =
          reference.reference4?.trim().toUpperCase();

      router.go(
        Routes.createFacility,
        extra: {
          "facilityArgs": CreateFacilityArgs(
            facility: Facility(
              facilityDescription: facilityDescriptionRef,
              limitDescription: facilityDescriptionRef.name,
              limitCode: facilityDescriptionRef.id,
              limitGroup: limitGroup,
              rimNo: rimNo,
              facilityTypeSelectedValue: facility.facilityTypeSelectedValue,
              selectedProductTypeValue: selectedProductTypeValue,
              limitNumber: limitNumber,
              isMainLimit: isMainLimit,
              productCodeProject: productCodeProject,
              limitCategory: reference.reference2,
            ),
            showCreateFacilityForm: true,
          ),
        },
      );

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
  }

  /// Activates edit mode for Limit Type.
  ///
  /// Clears the previously selected dropdown value so that validation
  /// is based on the manually entered text instead of the old selection.
  ///
  /// Note:
  /// The common CustomDropdown pre-fills edit mode text using
  /// `selectedItem.toString()`. Since [Reference] does not override `toString()`,
  /// it shows `Instance of 'Reference'`.
  /// To avoid changing the shared dropdown component, the controller is cleared
  /// again in a post-frame callback.
  void activateLimitTypeEditMode() {
    isLimitTypeInEditMode = true;
    customLimitTypeText = "";
    showLimitTypeRequiredError = false;

    facility.facilityTypeSelectedValue = null;
    reference.reference4 = null;
    limitTypeEditController.clear();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      limitTypeEditController.clear();
    });
  }

  /// Updates the custom Limit Type text while user types in edit mode.
  void onLimitTypeEditTextChanged(String value) {
    customLimitTypeText = value.trim();
    reference.reference4 = customLimitTypeText;

    if (customLimitTypeText.isNotEmpty && showLimitTypeRequiredError) {
      showLimitTypeRequiredError = false;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Stores the final Limit Type value entered in edit mode.
  void onLimitTypeEditCompleted(String value) {
    customLimitTypeText = value.trim();
    reference.reference4 = customLimitTypeText;

    if (customLimitTypeText.isNotEmpty && showLimitTypeRequiredError) {
      showLimitTypeRequiredError = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles Limit Type selection from dropdown mode.
  ///
  /// Resets edit-mode state and stores the selected dropdown value.
  void onLimitTypeSelected(Reference selectedLimitType) {
    isLimitTypeInEditMode = false;
    customLimitTypeText = "";
    showLimitTypeRequiredError = false;
    limitTypeEditController.clear();

    facility.facilityTypeSelectedValue = selectedLimitType;
    reference.reference4 =
        (selectedLimitType.reference1 ?? selectedLimitType.name ?? "").trim();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Clears Limit Type selection and custom text.
  void clearLimitTypeValue() {
    facility.facilityTypeSelectedValue = null;
    customLimitTypeText = "";
    reference.reference4 = null;
    limitTypeEditController.clear();
    showLimitTypeRequiredError = false;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns true if Limit Type is missing.
  ///
  /// In dropdown mode, a selected item is required.
  /// In edit mode, non-empty custom text is required.
  bool get isLimitTypeMissing {
    if (isLimitTypeInEditMode) {
      return customLimitTypeText.trim().isEmpty;
    }
    return facility.facilityTypeSelectedValue == null;
  }
}
