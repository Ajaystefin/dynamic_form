import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "state.dart";

class SubLimitConditionsViewModel extends SafeCubit<SubLimitConditionsState> {
  SubLimitConditionsViewModel({
    required this.standardConditions,
    required this.nonStandardConditions,
    required this.canEdit,
    required void Function() onAddNonStandard,
    this.initialPageStandard = 0,
    this.initialPageNonStandard = 0,
  })  : _onAddNonStandard = onAddNonStandard,
        super(SubLimitConditionsState(loaderStatus: LoadingStatus.loaded));

  final List<Condition> standardConditions;
  final List<Condition> nonStandardConditions;
  final bool canEdit;
  final void Function() _onAddNonStandard;
  final FacilitySecurityRepository _repository = FacilitySecurityRepository.instance;

  int initialPageStandard = 0;
  int initialPageNonStandard = 0;

  bool canDeleteNonStandard(int index) {
    if (!canEdit) {
      return false;
    }
    return (nonStandardConditions[index].facilityMasterId ?? 0) == 0;
  }

  void addNonStandard() {
    _onAddNonStandard();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> removeNonStandard(
    int index, {
    int? facilityConditionId,
  }) async {
    nonStandardConditions.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    await _repository.deleteFacilityCondition(facilityConditionId);
  }

  void changeStandardConditionSelect(int index, {required bool value}) {
    standardConditions[index].isSelected = value;
    if (value) {
      standardConditions[index].isAmended = false;
      standardConditions[index].isWaivedOff = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendStandardConditionSelect(int index, {required bool value}) {
    standardConditions[index].isAmended = value;
    if (value) {
      standardConditions[index].isWaivedOff = false;
      standardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeWaivedOffStandardConditionSelect(int index, {required bool value}) {
    standardConditions[index].isWaivedOff = value;
    if (value) {
      standardConditions[index].isAmended = false;
      standardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeNonStandardConditionSelect(int index, {required bool value}) {
    nonStandardConditions[index].isSelected = value;
    if (value) {
      nonStandardConditions[index].isAmended = false;
      nonStandardConditions[index].isWaivedOff = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendNonStandardConditionSelect(int index, {required bool value}) {
    nonStandardConditions[index].isAmended = value;
    if (value) {
      nonStandardConditions[index].isWaivedOff = false;
      nonStandardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeWaivedOffNonStandardConditionSelect(int index, {required bool value}) {
    nonStandardConditions[index].isWaivedOff = value;
    if (value) {
      nonStandardConditions[index].isAmended = false;
      nonStandardConditions[index].isSelected = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
