import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/access_right.dart';
import 'package:wcas_frontend/models/admin/page.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';

import 'state.dart';

class RoleRightMappingViewModel extends Cubit<RoleRightMappingState> {
  RoleRightMappingViewModel()
      : super(RoleRightMappingState(loaderStatus: LoadingStatus.loading));
  late AdminRepository repository;
  int currentPage = 0;

  Future<void> init(context) async {
    logger.i('initialising RoleRightMappingViewModel');
    repository = AdminRepository.instance;
    await getReferenceData();
  }

  List<Reference>? roles = [];
  List<Reference>? requestTypes = [];
  Reference? selectedRequestType;
  Reference? selectedRole;
  AccessRight? accessRight;
  AccessRight? updatedAccessRight;
  List<Page>? updatedPages = [];

  /// Fetches role and request types and populates the state with them.
  /// If there is an error, shows a toast and rethrows the error.
  Future<void> getReferenceData() async {
    try {
      Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.roleType,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.transactionType
      ]);
      roles = referenceData[ReferenceDataKeys.roleType];
      roles = roles?.where((role) {
        int? roleId = role.id;
        if (roleId == null) return true;
        return role.status == "active";
      }).toList();
      requestTypes = [
        ...?referenceData[ReferenceDataKeys.applicationType],
        // ...?referenceData[ReferenceDataKeys.transactionType]
      ];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// When a role is selected, this function is called.
  /// If the selected role is valid, it is stored in the state.
  /// If a request type is also selected, it calls [getAccessRights] to fetch the access rights for the selected role and request type.
  void onRoleSelected(Reference role) async {
    if (role.name != null) {
      selectedRole = role;
      if (selectedRole != null && selectedRequestType != null) {
        emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loading));
        getAccessRights();
      }
    }
  }

  /// Called when a request type is selected.
  /// If the selected request type is valid, it is stored in the state.
  /// If both a request type and a role are selected, it triggers the loading status
  /// and fetches access rights for the selected combination.
  void onRequestTypeSelected(Reference request) async {
    if (request.name != null) {
      selectedRequestType = request;

      if (selectedRequestType != null && selectedRole != null) {
        emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loading));
        await getAccessRights();
      }
    }
  }

  /// Fetches access rights for the selected role and request type.
  Future<void> getAccessRights() async {
    currentPage = 0;
    try {
      accessRight = await repository.getAccessRights(
        selectedRole!,
        selectedRequestType!,
      );
      removeNullPages();
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Removes pages with `AccessType.None` from the `accessRight` object.
  ///
  /// This function filters the `pages` list within the `accessRight` object

  /// to exclude pages that have an access type of `AccessType.None`. After
  /// filtering, it assigns the modified `accessRight` to `updatedAccessRight`.
  /// If `accessRight` or its `pages` list is null, no action is taken.
  void removeNullPages() {
    if (accessRight != null && accessRight!.pages != null) {
      // accessRight!.pages = accessRight!.pages!
      //     .where((page) => page.accessType != AccessType.none)
      //     .toList();
    }
    //clone the accessRight object to updatedAccessRight
    updatedAccessRight = accessRight;
  }

  //function to check any values are difff in updatedAccessRight and accessRight if diff then return true
  // else return false

  bool isAccessRightUpdated() {
    // Early return if either object is null
    if (updatedAccessRight == null || accessRight == null) {
      return false;
    }
    final updated = updatedAccessRight!;
    final current = accessRight!;

    // Check top-level properties using null-aware operators
    if (updated.role != current.role ||
        updated.requestType != current.requestType ||
        updated.subType != current.subType) {
      return true;
    }

    // Compare pages using null-aware operators and collection equality
    if (!const ListEquality().equals(updated.pages, current.pages)) {
      return true;
    }
    return false;
  }

  /// Saves the access rights to the server.
  ///
  /// This function is called when the user presses the save button.
  /// It first checks if the access rights have been updated by calling
  /// [isAccessRightUpdated]. If the access rights have been updated, it
  /// calls [saveAccessRights] on the repository to save the access
  /// rights. If the save is successful, it shows a success toast with the
  /// response message. If there is an error, it shows a failure toast with
  /// the error message and rethrows the error.
  void onSave() async {
    emit(state.copyWith(saveReferenceStatus: LoadingStatus.loading));
    try {
      // updatedAccessRight?.pages = updatedPages;
      String? response = await repository.saveAccessRights(
          updatedAccessRight!, isAccessRightUpdated());
      logger.i('Reference data save: $response');
      AlertManager().showSuccessToast("common.saveSuccess".tr());
      // await getAccessRights();
      emit(state.copyWith(saveReferenceStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(saveReferenceStatus: LoadingStatus.loaded));
    }
  }
}
