import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';
import 'state.dart';

class UserDetailViewModel extends Cubit<UserDetailState> {
  UserDetailViewModel()
      : super(UserDetailState(
            loaderStatus: LoadingStatus.loading,
            saveUserDetailStatus: LoadingStatus.loaded));

  late AdminRepository repository;
  final FocusNode formFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  User? userDetails, userListItem;
  List<Reference>? userAccessToRegionValues = [];
  List<Reference>? userAccessToCustomerSegmentValues = [];
  String? selectedUserRoles = "";

  List<Reference> islamicRelationshipUserOptions = [];

  Reference? selectedIslamicRelationshipUserValue;
  Map<String, List<Reference>> referenceData = {};

  /// Initializes the `UserDetailViewModel` by setting up the repository and loading user details.
  ///
  /// This method assigns the singleton instance of `AdminRepository` to the view model
  /// and calls [getUserDetailsResponse] to fetch and populate user-specific data such as
  /// regions, segments, and access rights.
  ///
  /// Logs the initialization process for debugging purposes.
  ///
  /// - Parameters:
  ///   - context: The [BuildContext] used for widget-related operations if needed.
  Future<void> init(BuildContext context, User? userListItem) async {
    logger.i('Initializing UserDetailViewModel');
    repository = AdminRepository.instance;
    userListItem = userListItem;
    await loadReferenceData();
    await getUserDetailsResponse(userListItem);
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.yesNoNa,
        ReferenceDataKeys.regionList,
        ReferenceDataKeys.segmentType,
      ]);
      islamicRelationshipUserOptions =
          referenceData[ReferenceDataKeys.yesNoNa] ?? [];
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Fetches user details from the repository and updates the view model state.
  ///
  /// This asynchronous method retrieves user-specific data such as regions,
  /// customer segments, and access rights using the `AdminRepository`.
  /// It maps the retrieved regions and segments into [Reference] objects
  /// for UI compatibility and emits a new [UserDetailState] with the
  /// fetched access flags and a `LoadingStatus.loaded` status.
  ///
  /// If an error occurs during the fetch, it logs the error, shows a failure toast,
  /// and emits a state with `LoadingStatus.error`.
  Future<void> getUserDetailsResponse(User? userListItem) async {
    try {
      userDetails = await repository.getUserDetailList(userListItem);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      userDetails?.regions?.map((region) {
        userAccessToRegionValues?.add(
            (referenceData[ReferenceDataKeys.regionList] ?? []).firstWhere(
          (Reference item) => item.name?.trim() == region,
        ));
      }).toList();

      userDetails?.segments?.map((segment) {
        userAccessToCustomerSegmentValues?.add(
            (referenceData[ReferenceDataKeys.segmentType] ?? []).firstWhere(
          (Reference item) => item.name?.trim() == segment,
        ));
      }).toList();

      emit(UserDetailState(
          approveOnBehalfOf: userDetails?.approveOnBehalfOf ?? false,
          approvalAccess: userDetails?.approvalAccess ?? false,
          tranApprovalAccess: userDetails?.tranApprovalAccess ?? false,
          accessToVipCust: userDetails?.accessToVipCust ?? false,
          loaderStatus: LoadingStatus.loaded,
          saveUserDetailStatus: LoadingStatus.loaded));
    } catch (error) {
      logger.e("User detail fetch failed: $error");
      AlertManager().showFailureToast(
        error.toString(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Called when a Region-chip’s delete icon is tapped
  void onUserRegionDeleted(int index) {
    final list = userDetails?.regions;
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    userDetails?.regions = list;
    //     list.map((c) => c.description ?? '').toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when a Segment-chip’s delete icon is tapped
  void onUserSegmentDeleted(int index) {
    final list = userDetails?.segments;
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    userDetails?.regions = list;
    //     list.map((c) => c.description ?? '').toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSelectedRegion(List<Reference>? selectedRegionValues) {
    userDetails?.regions = selectedRegionValues
            ?.map((region) => region.name?.trim() ?? '')
            .toList() ??
        [];
  }

  void onSelectedSegments(List<Reference>? selectedSegmentValues) {
    userDetails?.segments =
        selectedSegmentValues?.map((seg) => seg.name?.trim() ?? '').toList() ??
            [];
  }

  void islamicRelationshipUserSelected(Reference selected) {
    selectedIslamicRelationshipUserValue = selected;
    userDetails?.isIslamic =
        (selected.name == 'requestInformation.requestInformation.yes'.tr());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Checkbox toggles
  void onApproveOnBehalfOfSelected(bool? isChecked) {
    userDetails?.approveOnBehalfOf = isChecked ?? false;
    emit(state.copyWith(approveOnBehalfOf: isChecked ?? false));
  }

  // Checkbox toggles
  void onApprovalAccessSelected(bool? isChecked) {
    userDetails?.approvalAccess = isChecked ?? false;
    emit(state.copyWith(approvalAccess: isChecked ?? false));
  }

// Checkbox toggles
  void onTranApprovalAccessSelected(bool? isChecked) {
    userDetails?.tranApprovalAccess = isChecked ?? false;
    emit(state.copyWith(tranApprovalAccess: isChecked ?? false));
  }

// Checkbox toggles
  void onAccessToVipCustSelected(bool? isChecked) {
    userDetails?.accessToVipCust = isChecked ?? false;
    emit(state.copyWith(accessToVipCust: isChecked ?? false));
  }

  /// Validates and saves user detail information to the server.
  ///
  /// This method first checks if the form is valid using [formKey]. If valid,
  /// it saves the form data, emits a loading state, and sends the user details
  /// to the server via the repository. It includes user metadata such as roles,
  /// regions, customer segments, and access flags.
  ///
  /// On successful save, it logs the result and navigates to the user list screen.
  /// If an error occurs, it logs the error, shows a failure toast, and updates
  /// the state to reflect the error.
  ///
  /// Emits:
  /// - `LoadingStatus.loading` before the save operation.
  /// - `LoadingStatus.loaded` on success.
  /// - `LoadingStatus.error` on failure.
  Future<void> onSaveButtonPressed() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        formKey.currentState?.save();
        emit(state.copyWith(saveUserDetailStatus: LoadingStatus.loading));

        logger.i('Saving user: ${userDetails?.toSaveDetailsJson()}');
        final saveResult = await repository.saveUserDetailsList(userDetails);

        logger.i('User save result: $saveResult');
        AlertManager().showSuccessToast("common.saveSuccess".tr());
        emit(state.copyWith(saveUserDetailStatus: LoadingStatus.loaded));
        router.go(Routes.userList);
      } catch (error) {
        logger.e("Save failed: $error");
        AlertManager().showFailureToast(error.toString());
        emit(state.copyWith(saveUserDetailStatus: LoadingStatus.error));
      }
    }
  }

// onCancel, navigate to Previous page
  void onCancelButtonPressed() {
    router.go(Routes.userList);
  }

// Reusable method to Validator
  String? validateSelection(
      String? value, List<Reference> options, String errorKey) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  // Reusable method to filter out 'NA'
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options
        .where((ref) =>
            ref.name != 'requestInformation.requestInformation.na'.tr())
        .toList();
  }

  // Reusable method to get selected value with fallback
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final filtered = getFilteredOptions(options);

    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    final fallbackName = fallbackFlag == true
        ? 'requestInformation.requestInformation.yes'.tr()
        : 'requestInformation.requestInformation.no'.tr();

    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }
}
