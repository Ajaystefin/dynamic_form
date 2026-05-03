import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/state.dart";
import "package:wcas_frontend/models/request/approval/output_form.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";

/// ViewModel for managing the state and logic of the Output Forms selection
/// dialog.
///
/// This class handles fetching output forms from the repository, managing
/// selection state,
/// and updating the UI using the BLoC pattern.
class ListOutputFormsDialogViewModel
    extends SafeCubit<ListOutputFormsDialogState> {
  /// Constructor initializes the state with a loading status.
  ListOutputFormsDialogViewModel()
      : super(ListOutputFormsDialogState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository repository;

  /// Internal list of output forms fetched from the repository.
  List<OutputForm> _outputForms = [];

  /// Public getter for the list of output forms.
  List<OutputForm> get outputForms => _outputForms;

  String? selectedPreviewDoctype;
  String? selectedDownloadDoctype;

  /// Initializes the ViewModel by setting up the repository and fetching output
  /// forms.
  ///
  /// Logs the initialization and triggers data loading.
  ///
  /// [context] - The build context used for localization or navigation if
  /// needed.
  Future<void> init(context) async {
    logger.i("initialising ListOutputFormsDialogViewModel");
    repository = ApprovalRepository.instance;
    await fetchOutputForms();
  }

  /// Fetches the list of output forms from the repository.
  ///
  /// Updates the state to `loaded` on success or `error` on failure.
  Future<void> fetchOutputForms() async {
    try {
      _outputForms = await repository.getOutputForms();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error Fetching Output Forms: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> downloadOutputForm(bool isDownload, String? docType) async {
    try {
      final hasSelected = outputForms.any((form) => form.isSelected);

      if (!hasSelected) {
        AlertManager()
            .showFailureToast("approval.comments.outputFormsValidation".tr());
      }

      await repository.downloadOutputForms(_outputForms, isDownload, docType);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Toggles the selection state of an output form at the given index.
  ///
  /// If the index is valid, it updates the `isSelected` flag and emits a new
  /// state.
  ///
  /// [index] - The index of the output form to toggle.
  void toggleSelection(int index) {
    if (index < 0 || index >= _outputForms.length) return;

    final current = _outputForms[index];
    _outputForms[index] = OutputForm(
      name: current.name,
      id: current.id,
      isSelected: !current.isSelected,
      url: current.url,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
