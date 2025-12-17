import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Management Comments screen.
///
/// This class handles initialization, form validation, and saving of various
/// management-level comments using the BLoC pattern for state management.
class ManagementCommentsViewModel extends Cubit<ManagementCommentsState> {
  /// Constructor initializes the state with a loading status.
  ManagementCommentsViewModel()
      : super(ManagementCommentsState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Global key for validating the management comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Management comment fields

  /// Initial recommendation from the Credit Committee.
  String creditCommitteeRecommendations = 'Initial dummy recommendation';

  /// Comments from the Chief Credit Officer (CCO).
  String ccoComments = 'Dummy CCO comment';

  /// Comments from the Chief Executive Officer (CEO).
  String ceoComments = 'Dummy CEO comment';

  /// Comments from the BCIC (Board Credit Investment Committee).
  String bcicComments = 'Dummy BCIC comment';

  /// Initializes the ViewModel by setting up the repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  void init(context) async {
    logger.i('initialising ManagementCommentsViewModel');
    repository = RequestRepository.instance;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic for management comments.
  ///
  /// Validates the form, saves the input, and shows a success toast.
  /// Updates the loader status accordingly.
  Future<void> onSave() async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        AlertManager().showSuccessToast(
          "approval.managementComments.savedSuccessfully".tr(),
        );
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
