import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/draft/draft_mixin.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/information/security_perfection/draft_handler.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/features/request/information/security_perfection/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// View model for the Security Perfection feature.
class SecurityPerfectionViewModel extends SafeCubit<SecurityPerfectionState>
    with DraftMixin<SecurityPerfectionViewModel> {
  /// Creates a [SecurityPerfectionViewModel].
  SecurityPerfectionViewModel()
      : super(
          const SecurityPerfectionState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for request-related operations.
  late final RequestRepository repository;

  /// Repository used for common operations.
  late final CommonRepository repositoryCommon;

  /// Form key used for validation and submission.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the current business segment is a financial institution.
  bool isFI = false;

  /// Indicates whether the current page can be edited.
  bool get canEdit =>
      pageMode == PageMode.edit; //&& Utils.canEditApplication();

  /// Comments associated with security perfection.
  List<Comment> comments = [Comment()];

  /// Current security perfection comment.
  Comment? comment = Comment();

  /// Review comments associated with the current application.
  List<Comment>? getReviewComments = [];

  /// Security deferral details.
  SecurityPerfection securityDeferral = SecurityPerfection();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.requestInformation;

  @override
  String get draftFormKey =>
      "${Routes.securityPerfection}_${Globals.request?.customerRimNo}";

  @override
  DraftHandler<SecurityPerfectionViewModel> get draftHandler =>
      SecurityPerfectionDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the view model and loads security perfection data.
  Future<void> init(BuildContext context) async {
    logger.i("Initializing SecurityPerfectionViewModel");

    repository = RequestRepository.instance;
    repositoryCommon = CommonRepository.instance;
    pageMode = AuthRepository.getPageMode(RightConstants.securityPerfection);

    // for checkup with request type creditRisk
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    await getReviewCommentsReference(
      CommentsType.securityPerfection,
      EntityIdentifier.securityPerfection,
    );
    await getSecurityDeferralDetails();

    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
      if (comments.isEmpty) {
        comments = [Comment()];
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves security deferral details and updates table states.
  Future<void> getSecurityDeferralDetails() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      securityDeferral = await repository.getSecurityDeferralDetails();

      final List<SecurityDeferral> list =
          securityDeferral.securityDeferralList ?? [];
      for (var i = 0; i < list.length; i++) {
        final SecurityDeferral row = list[i];
        updateTableStateChanges("s", i, value: row.selected ?? false);
      }

      final List<SecurityCovenantCondition> listc =
          securityDeferral.covenant ?? [];
      for (var i = 0; i < listc.length; i++) {
        final SecurityCovenantCondition row = listc[i];
        updateTableStateChanges("c", i, value: row.selected);
      }

      final List<SecurityCovenantCondition> listcd =
          securityDeferral.condition ?? [];
      for (var i = 0; i < listcd.length; i++) {
        final SecurityCovenantCondition row = listcd[i];
        updateTableStateChanges("cd", i, value: row.selected);
      }
    } on Object catch (e) {
      logger.e("Error fetching security deferral details: $e");
      AlertManager().showFailureToast("$e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves review comments for the specified type and entity.
  Future<void> getReviewCommentsReference(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);

      getReviewComments = comments
          .where(
            (cmt) =>
                cmt.applicationRefNo
                    ?.contains(Globals.request?.applicationRefNo ?? "") ??
                false,
          )
          .toList();
      if ((getReviewComments ?? []).isNotEmpty) {
        comment = getReviewComments?.first;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Validates and saves the security perfection details.
  Future<void> onSaveButtonPressed() async {
    try {
      emit(state.copyWith(isButtonLoading: true));

      /* -------------------------------
     1️ Form Validation (UI Fields)
    -------------------------------- */
      final isValid = formKey.currentState?.validate() ?? false;
      /* ------------------------------------------
     2 Custom Table Validation (IMPORTANT )
    ------------------------------------------- */
      final List<String> tableErrors = <String>[
        ...validateCondition(),
        ...validateCovenant(),
        ...validateSecurity(),
      ];

      if (tableErrors.isNotEmpty) {
        emit(state.copyWith(isButtonLoading: false));

        // Show first error (recommended)
        //AlertManager().showFailureToast(tableErrors.first);

        // OR show all errors
        AlertManager().showFailureToast(tableErrors.join("\n"));

        return;
      }

      if (!isValid) {
        emit(state.copyWith(isButtonLoading: false));
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        return;
      }

      formKey.currentState?.save();

      /* -------------------------------
     3 Continue Save Flow
    -------------------------------- */
      if (!canEdit || isValid) {
        /* -------------------------------
         1 Save Comment (Existing Flow)
      -------------------------------- */
        comment?.strategyComment = comment?.comment;
        comment = Comment.fromInputData(
          comment: comment?.comment,
          type: CommentsType.securityPerfection,
          entityType: EntityIdentifier.securityPerfection,
          categoryId:
              ServerConstants.commentTypeId[CommentsType.securityPerfection],
        );

        await CommonRepository.instance.saveComment(comment ?? Comment());

        /* ------------------------------------------
         2 Prepare SAVE SECURITY DEFERRAL REQUEST
      ------------------------------------------- */
        ///  Selected Securities
        final List<Map<String, dynamic>> securityDeferralList = securityDeferral
                .securityDeferralList //.where((e) => e.selected ?? false)
                ?.map((e) => e.toJson())
                .toList() ??
            [];

        ///  Selected Covenants
        final List<Map<String, dynamic>> covenantDeferralList =
            securityDeferral.covenant //.where((e) => e.isChecked)
                    ?.map((e) => e.toJson(isCovenant: true))
                    .toList() ??
                [];

        ///  Selected Conditions
        final List<Map<String, dynamic>> conditionDeferralList =
            securityDeferral.condition //.where((e) => e.isChecked)
                    ?.map((e) => e.toJson(isCovenant: false))
                    .toList() ??
                [];

        // securityDeferralList;
        // covenantDeferralList;
        // conditionDeferralList;
        if ((securityDeferral.securityDeferralList ?? []).isNotEmpty) {
          logger.i(
            "SEC: ${securityDeferral.securityDeferralList![0].isChecked}",
          );
        }
        if ((securityDeferral.covenant ?? []).isNotEmpty) {
          logger.i("COV: ${securityDeferral.covenant![0].isChecked}");
        }

        if ((securityDeferral.condition ?? []).isNotEmpty) {
          logger.i("CON: ${securityDeferral.condition![0].isChecked}");
        }
        /* ------------------------------------------
         3️Call SAVE API (Edited Version)
      ------------------------------------------- */
        await repository.saveSecurityDeferralDetails(
          securityDeferralList: securityDeferralList,
          covenantDeferralList: covenantDeferralList,
          conditionDeferralList: conditionDeferralList,
        );

        /* ------------------------------------------
         4️Post Save Actions
      ------------------------------------------- */
        unawaited(deleteDraft());

        AlertManager().showSuccessToast(
          "requestInformation.securityPerfection.savedSuccessfully".tr(),
        );

        LayoutViewModel().goToNextRoute();
      }

      emit(state.copyWith(isButtonLoading: false));
    } on Object catch (e) {
      logger.e("Error during saveSecurityDeferralDetails: $e");
      AlertManager().showFailureToast(e.toString());

      emit(
        state.copyWith(
          isButtonLoading: false,
          loaderStatus: LoadingStatus.error,
        ),
      );
    }
  }

  /// Updates the selected state of a security, covenant, or condition row.
  void updateTableStateChanges(
    String from,
    int index, {
    required bool value,
  }) {
    if (from == "s") {
      securityDeferral.securityDeferralList?[index].isChecked = value;
      securityDeferral.securityDeferralList?[index].selected = value;
      if (!value) {
        securityDeferral.securityDeferralList?[index].dateDeferral = null;
      }
    }
    if (from == "c") {
      securityDeferral.covenant?[index].isChecked = value;
      securityDeferral.covenant?[index].selected = value;
      if (!value) {
        securityDeferral.covenant?[index].deferralDate = null;
      }
    }
    if (from == "cd") {
      securityDeferral.condition?[index].isChecked = value;
      securityDeferral.condition?[index].selected = value;
      if (!value) {
        securityDeferral.condition?[index].deferralDate = null;
      }
    }

    emit(
      state.copyWith(
        refreshKey: state.refreshKey + 1, // FORCE rebuild
      ),
    );
  }

  /// Closes the linked facilities dialog.
  void onSavePressedLinkedFacilities(BuildContext context) {
    context.pop();
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  /// Validates the selected condition deferral dates.
  List<String> validateCondition() {
    final List<String> errors = <String>[];
    final List<SecurityCovenantCondition> list =
        securityDeferral.condition ?? [];
    for (var i = 0; i < list.length; i++) {
      final SecurityCovenantCondition row = list[i];
      if (row.isChecked) {
        if (row.deferralDate == null) {
          errors.add(
            "requestInformation.securityPerfection.conditionDateRequired"
                .tr(namedArgs: {"row": "${i + 1}"}),
          );
          // errors.add("Condition Row ${i + 1}: Deferral date is required");
        }
      }
    }
    return errors;
  }

  /// Validates the selected covenant deferral dates.
  List<String> validateCovenant() {
    final List<String> errors = <String>[];
    final List<SecurityCovenantCondition> list =
        securityDeferral.covenant ?? [];
    for (var i = 0; i < list.length; i++) {
      final SecurityCovenantCondition row = list[i];
      if (row.isChecked) {
        if (row.deferralDate == null) {
          errors.add(
            "requestInformation.securityPerfection.covenantDateRequired"
                .tr(namedArgs: {"row": "${i + 1}"}),
          );
          //  errors.add("Covenant Row ${i + 1}: Deferral date is required");
        }
      }
    }
    return errors;
  }

  /// Validates the selected security deferral dates.
  List<String> validateSecurity() {
    final List<String> errors = <String>[];
    final List<SecurityDeferral> list =
        securityDeferral.securityDeferralList ?? [];
    for (var i = 0; i < list.length; i++) {
      final SecurityDeferral row = list[i];
      if (row.selected ?? false) {
        if (row.dateDeferral == null) {
          errors.add(
            "requestInformation.securityPerfection.securityDateRequired"
                .tr(namedArgs: {"row": "${i + 1}"}),
          );
          //  errors.add("Security Row ${i + 1}: Deferral date is required");
        }
      }
    }
    return errors;
  }
}
