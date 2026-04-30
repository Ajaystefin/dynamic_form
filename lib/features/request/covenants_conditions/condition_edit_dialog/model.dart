import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class ConditionEditDialogViewModel extends SafeCubit<ConditionEditDialogState> {
  ConditionEditDialogViewModel()
      : super(ConditionEditDialogState(loaderStatus: LoadingStatus.loading));
  RequestRepository repository = RequestRepository();
  ReferenceDataService referenceDataService = ReferenceDataService();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  CovenantCondition? conditionData;
  List<Facility> facilityList = [];
  Map<String, List<Reference>> referenceData = {};
  bool isUpdateCondition = false;

  // IDs that allow editing of Status and Action
  static const int _editableStatusId = ServerConstants.conditionStatusNewId;
  static const int _editableActionId = ServerConstants.conditionActionCreateId;

  // Frozen for this dialog session based on the response used to open it
  bool _allowStatusActionEditing = false;

  // Final gate for UI (combine with page-mode if you want to respect it)
  bool get canEditStatusAction => _allowStatusActionEditing && canEdit;

  Reference? generalField;
  Reference? selectedAction;
  Reference? selectedTypeValue;
  Reference? selectedFrequency;
  Reference selectedInlineValue = Reference(
    name: "",
  );
  Reference editedInlineValue = Reference(
    name: "",
  );
  Reference? selectedSubTypeValue;
  // String? updatedDescription;
  Reference? selectedDescriptionType;
  Customer? selectedCustomer;
  // List<String> conditionTypes = [];
  Reference? selectedType;
  Reference? selectedStatus;
  String? selectedTargetDate;
  bool includeInTermField = false;
  PageMode pageMode = PageMode.na;

  PageMode? conditionEditPageMode;
  bool get canEdit => (conditionEditPageMode ==
      PageMode.edit); // && Utils.canEditApplication();

  List<Customer>? customerList = [];

  /// Initializes the view model.
  ///
  /// Sets up the repository, loads reference data, and pre-fills condition
  /// details if available.
  ///
  /// [context] - The BuildContext, if needed for additional setup.
  /// [condition] - The existing covenant condition, if provided.
  Future<void> init(
    context,
    overridePageMode,
    CovenantCondition? condition,
  ) async {
    logger.i("initialising ConditionEditDialogViewModel");
    conditionEditPageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.conditionsSummary);
    await loadReferenceData();
    await getChildRimsForGroup();
    if (condition != null) {
      isUpdateCondition = true;
      conditionData = condition;

      // Freeze this flag based on the *response* that opened the dialog
      _allowStatusActionEditing = (condition.status != _editableStatusId) &&
          (condition.action != _editableActionId);

      getModifyData();
    } else {
      _allowStatusActionEditing = false;
      conditionData = CovenantCondition(includeInTerms: true);
      includeInTermField = true;
      referenceData[ReferenceDataKeys.conditionAction]?.forEach((value) {
        if (value.id == ServerConstants.conditionActionCreateId) {
          selectedAction = value;
        }
      });
      referenceData[ReferenceDataKeys.conditionStatus]?.forEach((value) {
        if (value.id == ServerConstants.conditionStatusNewId) {
          selectedStatus = value;
        }
      });
      referenceData[ReferenceDataKeys.conditionStandard]?.forEach((value) {
        if (value.id == ServerConstants.conditionStandardId) {
          selectedDescriptionType = value;
        }
      });
    }
    selectedSubTypeValue =
        referenceData[ReferenceDataKeys.conditionDescriptionTemplate]
            ?.firstWhere(
      (element) => element.id == conditionData?.covenantSubType,
      orElse: Reference.new,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool get isActionEditable => canEditStatusAction;

  //get child rim list for customer name  dropdown
  // Fallback for non-GroupOwner: use customers already in this request
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList =
            (await CustomerRepository.instance.getChildRimsForGroup() ?? []);
      } else {
        customerList = Globals.request?.customers ?? [];
      }
    } catch (e) {
      logger.i("Error fetching getChildRimsForGroup : $e");
      rethrow;
    }
  }

  /// Pre-fills condition data based on provided information.
  void getModifyData() {
    try {
      if (conditionData?.facilityDetailList != null &&
          conditionData!.facilityDetailList!.isNotEmpty) {
        facilityList = conditionData!.facilityDetailList!;
      }
      if (conditionData?.customerName != null) {
        selectedCustomer = Customer(firstName: conditionData?.customerName);
      }
      if (conditionData?.includeInTerms != null) {
        includeInTermField = conditionData?.includeInTerms ?? false;
      }
      if (conditionData?.targetDate != null) {
        selectedTargetDate = conditionData?.targetDate;
      }

      if (conditionData?.frequency != null) {
        referenceData[ReferenceDataKeys.conditionFrequency]?.forEach((value) {
          if (value.id == conditionData?.frequency) {
            selectedFrequency = value;
          }
        });
      }

      if (conditionData?.action != null) {
        referenceData[ReferenceDataKeys.conditionAction]?.forEach((value) {
          if (value.id == conditionData?.action) {
            selectedAction = value;
          }
        });
      }
      if (conditionData?.status != null) {
        referenceData[ReferenceDataKeys.conditionStatus]?.forEach((value) {
          if (value.id == conditionData?.status) {
            selectedStatus = value;
          }
        });
      }
      if (conditionData?.conditionType != null) {
        referenceData[ReferenceDataKeys.covenantConditionType]
            ?.forEach((value) {
          if (value.id == conditionData?.conditionType) {
            selectedType = value;
          }
        });
      }
      final List<Reference> list =
          referenceData[ReferenceDataKeys.conditionStandard] ?? <Reference>[];
      final String standardId = ServerConstants.conditionStandardId.toString();
      final String customId = ServerConstants.conditionCustomId.toString();

      if (conditionData?.isStandard ?? false) {
        selectedDescriptionType = list.firstWhere(
          (ref) => ref.id?.toString() == standardId,
          orElse: () => list.isNotEmpty ? list.first : Reference(),
        );
      } else {
        selectedDescriptionType = list.firstWhere(
          (ref) => ref.id?.toString() == customId,
          orElse: () => list.isNotEmpty ? list.first : Reference(),
        );
      }

      if (conditionData?.description != null) {
        editedInlineValue = Reference(name: conditionData?.description);
        selectedInlineValue = Reference(name: conditionData?.description);
      }
      if (conditionData?.isGeneric ?? false) {
        referenceData[ReferenceDataKeys.conditionGeneral]?.map(
          (element) {
            if (element.id == ServerConstants.conditionGeneralId) {
              generalField = element;
            }
          },
        ).toList();
      } else {
        referenceData[ReferenceDataKeys.conditionGeneral]?.map(
          (element) {
            if (element.id == ServerConstants.conditionSpecificId) {
              generalField = element;
            }
          },
        ).toList();
      }
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].
  Future<void> loadReferenceData() async {
    try {
      referenceData = await referenceDataService.getReferenceData([
        ReferenceDataKeys.conditionDescriptionTemplate,
        ReferenceDataKeys.conditionAction,
        ReferenceDataKeys.conditionFrequency,
        ReferenceDataKeys.conditionGeneral,
        ReferenceDataKeys.conditionStandard,
        ReferenceDataKeys.conditionStatus,
        ReferenceDataKeys.covenantConditionType,
      ]);
    } catch (e) {
      AlertManager().showFailureToast("common.error".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

  /// Saves the covenant condition details.
  ///
  /// Validates the form and then attempts to save the condition data via the
  /// repository.
  /// Returns `true` if the save is successful, otherwise `false`.

  Future<bool> onSavePress() async {
    try {
      if (!Utils.checkBusinessSegment(BusinessSegment.financialInstitution) &&
          (editedInlineValue.name?.isEmpty ?? false)) {
        AlertManager().showSuccessToast(
          "covenantsConditions.conditionsEditDialog.enterDescription".tr(),
        );
        return false;
      }
      if (Utils.checkBusinessSegment(BusinessSegment.financialInstitution)) {
        if (selectedCustomer == null) {
          router.pop();
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return true;
        }
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      if (!isUpdateCondition) {
        conditionData?.isNew = true;
        conditionData?.appRefNum = Globals.request?.applicationRefNo;
        conditionData?.mode = TypeMode.create.name.capitalizeFirstLetter();
        conditionData?.rimNo = selectedCustomer?.customerRimNo;
        conditionData?.customerName = selectedCustomer?.customerName;
        conditionData?.action = ServerConstants.conditionActionCreateId;
        conditionData?.status = ServerConstants.conditionStatusNewId;
      } else {
        conditionData?.isNew = false;
        conditionData?.mode = TypeMode.edit.name.capitalizeFirstLetter();
        conditionData?.status = selectedStatus?.id;
      }
      conditionData?.isGeneric =
          (generalField?.id == ServerConstants.conditionGeneralId);
      conditionData?.isStandard =
          (selectedDescriptionType?.id == ServerConstants.conditionStandardId);
      conditionData?.facilityDetailList = facilityList;
      conditionData?.description = editedInlineValue.name;
      conditionData?.covenantSubType = selectedSubTypeValue?.id;

      final String response =
          await repository.saveConditionDetails(conditionData);
      AlertManager().showSuccessToast(
        response.toString(),
      );
      router.pop();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return true;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      return false;
    }
  }

  /// Handles subtype selection and triggers UI update.
  void onSubtypeSelection(Reference selectedValue) {
    try {
      selectedSubTypeValue = selectedValue;
      selectedInlineValue = selectedValue;
      editedInlineValue = selectedValue;
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          emit(state.copyWith(fieldStatus: LoadingStatus.loaded));
        },
      );
    } catch (e) {
      logger.i(e);
    }
  }

  //parse target date field
  DateTime parseTargetDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.now();
    }
    try {
      return DateFormat("dd/MM/yyyy").parseStrict(raw);
    } catch (_) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return DateTime.now(); // last fallback
      }
    }
  }

  /// Converts timestamp into a readable date format (Dubai timezone).
  String getTimeAsString(int? timestamp) {
    if (timestamp == null) return "";
    // Convert to UTC and then adjust to Dubai time
    final dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    final dubaiTime = dateTimeUtc.add(const Duration(hours: 4));

    // Format using intl
    final formattedDate = DateFormat("dd/MM/yyyy").format(dubaiTime);
    return formattedDate;
  }

  /// Updates the selected condition type and triggers UI update.
  void onConditionTypeSelection(Reference data) {
    emit(state.copyWith(fieldStatus: LoadingStatus.loading));
    selectedType = data;
    conditionData?.conditionType = data.id;
    selectedSubTypeValue = null;
    selectedInlineValue = Reference(name: " ");
    editedInlineValue = Reference(name: " ");

    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        emit(state.copyWith(fieldStatus: LoadingStatus.loaded));
      },
    );
  }

  List<Reference>? getDescritionSubTypes() {
    final List<Reference> filteredData = [];
    referenceData[ReferenceDataKeys.conditionDescriptionTemplate]?.map((data) {
      if (data.reference2 == selectedType?.id.toString()) {
        filteredData.add(data);
      }
    }).toList();
    return filteredData;
  }

  /// Filters description subtypes based on the selected type.
  void onDescriptionTypeChanged(Reference value) {
    emit(state.copyWith(fieldStatus: LoadingStatus.loading));
    selectedDescriptionType = value;
    editedInlineValue = Reference(name: " ");
    selectedSubTypeValue = null;
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        emit(state.copyWith(fieldStatus: LoadingStatus.loaded));
      },
    );
  }

  /// Determines whether inline editing is allowed.
  bool isInlineEditable() => (!isStandartList());

  /// Check whether the standartList selected or Not
  bool isStandartList() =>
      ServerConstants.conditionStandardId == selectedDescriptionType?.id;

  /// On include Term Sheet button pressed
  void onIncludeTermChange(bool? value) {
    includeInTermField = value ?? false;
    conditionData?.includeInTerms = includeInTermField;
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        emit(state.copyWith(fieldStatus: LoadingStatus.loaded));
      },
    );
  }

  /// Check whether the Specific value selected or Not
  bool isSpecificSelected() =>
      ServerConstants.conditionSpecificId == generalField?.id;

  /// on general or Specific field selection changed
  Future<void> onGeneralFieldChanged(
    Reference selectedValue,
    BuildContext context,
  ) async {
    generalField = selectedValue;
    if (isSpecificSelected()) {
      final data = await DialogHelper.showCustomDialog(
        barrierDismissible: false,
        title: "security.securityFacilityLinkage.select_facilities".tr(),
        content: SelectFacilitiesDialogView(
          selectedFacility: facilityList,
          isLinakage: false,
          isSecuritySummary: false,
        ),
        context: context,
      );

      if (data != null) {
        await setFacility(data);
      }
    } else {
      //  emit(state.copyWith(fieldStatus: LoadingStatus.loading));
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          emit(state.copyWith(fieldStatus: LoadingStatus.loaded));
        },
      );
    }
  }

  void onActionFieldChange(Reference selectedValue) {
    selectedAction = selectedValue;
    conditionData?.action = selectedValue.id;
  }

  void onFrequencyChange(Reference selectedValue) {
    selectedFrequency = selectedValue;
    conditionData?.frequency = selectedValue.id;
  }

  void onTargetDateChanged(DateTime? selectedDate) {
    selectedTargetDate = selectedDate?.toIso8601String();
    conditionData?.targetDate =
        DateTimeUtils.getDateAsString(selectedTargetDate);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onStatusFieldChanged(Reference data) {
    selectedStatus = data;
  }

  Future<void> setFacility(data) async {
    facilityList = [];
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    if (data != null) {
      facilityList = data as List<Facility>;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  List<Reference>? getActionvalues() {
    return referenceData[ReferenceDataKeys.conditionAction]
        ?.where(
          (element) => element.id != ServerConstants.conditionActionCreateId,
        )
        .toList();
  }
}
