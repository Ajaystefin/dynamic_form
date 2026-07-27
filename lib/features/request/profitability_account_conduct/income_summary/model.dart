import "dart:async";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/income_summary.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

// model.dart (IncomeSummaryViewModel)
// ... other imports

/// Income summary view model.
class IncomeSummaryViewModel extends SafeCubit<IncomeSummaryState>
    with DraftMixin<IncomeSummaryViewModel> {
  /// Creates an income summary view model.
  IncomeSummaryViewModel()
      : super(
          const IncomeSummaryState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Profitability repository instance.
  late ProfitabilityRepository repository;

  /// Income summary list.
  List<IncomeSummary>? incomeSummaryList;

  // Form
  /// Form key for income summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Comments model data
  /// RM comments.
  String? rmComments;

  // NEW: Controller to reliably update UI from VM/draft
  /// RM comments text editing controller.
  final TextEditingController rmCommentsController = TextEditingController();

  // Comments
  /// Comments list.
  List<Comment> comments = [];

  /// Income comment.
  IncomeComment? comment;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether page can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  // DraftMixin impl
  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.incomeSummary;

  @override
  DraftHandler<IncomeSummaryViewModel> get draftHandler =>
      IncomeSummaryDraftHandler();

  /// Initializes the income summary view model.
  Future<void> init(BuildContext context) async {
    logger.i("initialising IncomeSummaryViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.incomeSummary);

    repository = ProfitabilityRepository.instance;

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    await getIncomeSummary();

    // Initialize controller from fetched value (server/comment)
    rmCommentsController.text = rmComments ?? "";

    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable(); // draft handler will update vm + controller
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Gets income summary data.
  Future<void> getIncomeSummary() async {
    try {
      final IncomeSummaryResponseData result =
          await repository.getIncomeSummary();

      incomeSummaryList = result.incomeSummaryDataList.toList();

      // Pre-fill RM comments
      comment = result.comment;
      rmComments = comment?.comment;
      // Do not set controller here; we do in init after this call, and also
      // after draft load

      emit(
        state.copyWith(
          loaderStatus: incomeSummaryList!.isEmpty
              ? LoadingStatus.empty
              : LoadingStatus.loaded,
        ),
      );
    } on Object {
      logger.e("getIncomeSummary failed");
      incomeSummaryList = const [];
      emit(state.copyWith(loaderStatus: LoadingStatus.empty));
    }
  }

  /// Saves income summary data.
  Future<void> saveIncomeSummaryData(
    BuildContext context, {
    required bool navigateNext,
  }) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      final form = formKey.currentState;
      if (form != null) {
        final isValid = form.validate();
        if (!isValid) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        }
        form.save();
      }

      // Ensure rmComments mirrors controller text before saving
      rmComments = rmCommentsController.text.trim().isEmpty
          ? null
          : rmCommentsController.text.trim();

      if (incomeSummaryList == null) {
        AlertManager()
            .showFailureToast("No data to save. Please refresh and try again.");
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      final responseMessage = await repository.saveIncomeSummary(
        incomeSummaryList!,
        rmComments,
      );

      // Clear backend draft on successful save
      unawaited(deleteDraft());

      AlertManager().showSuccessToast(responseMessage);

      if (navigateNext && context.mounted) {
        LayoutViewModel()
            .goToNextRoute(); // replace with provided instance if you have DI
      }
    } on Object catch (e) {
      logger.e("saveIncomeSummaryData error");
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    rmCommentsController.dispose();
    return super.close();
  }
}
