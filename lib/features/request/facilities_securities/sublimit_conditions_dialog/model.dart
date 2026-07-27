import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/state.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// View model responsible for managing standard and non-standard
/// sub-limit conditions.
///
/// Handles condition selection, pagination, persistence, and
/// condition-related actions within the conditions dialog.
class SubLimitConditionsViewModel extends SafeCubit<SubLimitConditionsState> {
  /// Creates a sub-limit conditions view model.
  SubLimitConditionsViewModel({
    required this.standardConditions,
    required this.nonStandardConditions,
    required this.canEdit,
    required void Function() onAddNonStandard,
    this.initialPageStandard = 0,
    this.initialPageNonStandard = 0,
  })  : _onAddNonStandard = onAddNonStandard,
        super(
          const SubLimitConditionsState(
            loaderStatus: LoadingStatus.loaded,
          ),
        );

  /// Available standard conditions.
  final List<Condition> standardConditions;

  /// Available non-standard conditions.
  final List<Condition> nonStandardConditions;

  /// Indicates whether condition data can be modified.
  final bool canEdit;

  /// Callback invoked when a new non-standard condition is added.
  final void Function() _onAddNonStandard;

  /// Repository used for condition-related operations.
  final FacilitySecurityRepository _repository =
      FacilitySecurityRepository.instance;

  /// Initial page index for the standard conditions table.
  int initialPageStandard = 0;

  /// Initial page index for the non-standard conditions table.
  int initialPageNonStandard = 0;

  /// Returns whether the specified non-standard condition can be deleted.
  ///
  /// Non-standard conditions can only be deleted when editing is allowed
  /// and the condition has not yet been persisted.
  bool canDeleteNonStandard(int index) {
    if (!canEdit) {
      return false;
    }
    return (nonStandardConditions[index].facilityMasterId ?? 0) == 0;
  }

  /// Adds a new non-standard condition and refreshes the view state.
  void addNonStandard() {
    _onAddNonStandard();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes the specified non-standard condition.
  ///
  /// Deletes the condition locally and, when available, removes the
  /// corresponding persisted record.
  Future<void> removeNonStandard(
    int index, {
    int? facilityConditionId,
  }) async {
    nonStandardConditions.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    await _repository.deleteFacilityCondition(facilityConditionId);
  }

  /// Updates the selected status of a standard condition.
  ///
  /// Selecting a standard condition clears any amended or waived-off
  /// status for the same condition.
  void changeStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    standardConditions[index].isSelected = value;
    if (value) {
      standardConditions[index].isAmended = false;
      standardConditions[index].isWaivedOff = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the amended status of a standard condition.
  ///
  /// Selecting the amended status clears any selected or waived-off
  /// status for the same condition.
  void changeAmendStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    standardConditions[index].isAmended = value;
    if (value) {
      standardConditions[index].isWaivedOff = false;
      standardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the waived-off status of a standard condition.
  ///
  /// Selecting the waived-off status clears any selected or amended
  /// status for the same condition.
  void changeWaivedOffStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    standardConditions[index].isWaivedOff = value;
    if (value) {
      standardConditions[index].isAmended = false;
      standardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected status of a non-standard condition.
  ///
  /// Selecting a non-standard condition clears any amended or waived-off
  /// status for the same condition.
  void changeNonStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    nonStandardConditions[index].isSelected = value;
    if (value) {
      nonStandardConditions[index].isAmended = false;
      nonStandardConditions[index].isWaivedOff = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the amended status of a non-standard condition.
  ///
  /// Selecting the amended status clears any selected or waived-off
  /// status and disables text-field editing for the same condition.
  void changeAmendNonStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    nonStandardConditions[index].isAmended = value;
    if (value) {
      nonStandardConditions[index].isWaivedOff = false;
      nonStandardConditions[index].isSelected = false;
      nonStandardConditions[index].isShowAsTextField = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the waived-off status of a non-standard condition.
  ///
  /// Selecting the waived-off status clears any selected or amended
  /// status for the same condition.
  void changeWaivedOffNonStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    nonStandardConditions[index].isWaivedOff = value;
    if (value) {
      nonStandardConditions[index].isAmended = false;
      nonStandardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
