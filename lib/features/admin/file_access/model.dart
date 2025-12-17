import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/file_access.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';

import 'state.dart';

class FileAccessViewModel extends Cubit<FileAccessState> {
  FileAccessViewModel()
      : super(FileAccessState(loaderStatus: LoadingStatus.loading));
  AdminRepository repository = AdminRepository();

  Map<String, List<Reference>> referenceData = {};

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Reference? selectedRoleType;
  List<FileAccess> fileAccesses = [];
  List<FileAccess> firstLevelParentsWithChildren = [];
  List<FileAccess> updatedFileAccess = [];
  List<Reference>? roles = [];
  void init(context) async {
    logger.i('initialising FileAccessViewModel');
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when a role type is selected.
  ///
  /// It assigns the selected role type to [selectedRoleType] and calls
  /// [getFileAccess] to fetch file attachments for the selected role type.
  /// After the fetch is complete, it updates the [loaderStatus] to
  void onRoleTypeSelected(Reference data) async {
    selectedRoleType = data;
    await getFileAccess();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.roleType]);

      List<Reference> allRoles =
          referenceData[ReferenceDataKeys.roleType] ?? [];

      roles = allRoles.where((role) {
        int? roleId = role.id;
        if (roleId == null) return true;
        return (roleId != ServerConstants.financialPoolMaker &&
                roleId != ServerConstants.financialPoolChecker &&
                roleId != ServerConstants.financialPoolCoordinator) ||
            role.status == "inactive";
      }).toList();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetches file attachments for the selected role type from the server.
  ///
  /// Emits a [LoadingStatus] of [LoadingStatus.loading] to indicate that the
  /// file attachments are being fetched. If the fetch is successful, it
  /// assigns the fetched file attachments to [fileAccesses] and emits a
  /// [LoadingStatus] of [LoadingStatus.loaded]. If there is an error, it
  /// emits a [LoadingStatus] of [LoadingStatus.loaded] and logs the error.
  Future<void> getFileAccess() async {
    emit(state.copyWith(fileAccessStatus: LoadingStatus.loading));
    try {
      fileAccesses = await repository.getFileAttachments(selectedRoleType);
      firstLevelParentsWithChildren = fileAccesses
          .where((file) => file.children != null && file.children!.isNotEmpty)
          .toList();
      emit(state.copyWith(fileAccessStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(fileAccessStatus: LoadingStatus.error));
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Saves all file attachments to the server.
  ///
  /// Flattens all FileAccess and their children and calls
  /// [AdminRepository.saveFileAttachments] to save the file attachments.
  /// If the save is successful, it shows a success toast with the actual
  /// response message. If there is an error, it shows a failure toast with a
  /// generic error message and rethrows the error.
  ///
  /// This function is called when the user presses the save button.
  void onSave() async {
    // Flatten all FileAccess and their children

    List<FileAccess> fileAttachments = [
      for (final element in fileAccesses) ...[
        element,
        if (element.children?.isNotEmpty == true) ...element.children!
      ]
    ];

    emit(state.copyWith(savingStatus: LoadingStatus.loading));

    try {
      final response = await repository.saveFileAttachments(
        fileAttachments,
        selectedRoleType,
      );

      if (response != null && response.isNotEmpty) {
        AlertManager().showSuccessToast(response);
      }

      emit(state.copyWith(savingStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(savingStatus: LoadingStatus.error));
    }
  }
}
