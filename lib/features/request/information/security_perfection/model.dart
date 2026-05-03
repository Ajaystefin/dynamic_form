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
import "package:wcas_frontend/models/request/security_perfection.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class SecurityPerfectionViewModel extends SafeCubit<SecurityPerfectionState>
    with DraftMixin<SecurityPerfectionViewModel> {
  SecurityPerfectionViewModel()
      : super(SecurityPerfectionState(loaderStatus: LoadingStatus.loading));

  late final RequestRepository repository;
  late final CommonRepository repositoryCommon;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PageMode pageMode = PageMode.na;
  bool isFI = false;

  bool get canEdit =>
      pageMode == PageMode.edit; //&& Utils.canEditApplication();

  List<Comment> comments = [Comment()];
  Comment? comment = Comment();
  List<Comment>? getReviewComments = [];
  SecurityPerfection securityDeferral = SecurityPerfection();

  @override
  String get draftModuleKey => DraftModuleKeys.requestInformation;

  @override
  String get draftFormKey => Routes.securityPerfection;

  @override
  DraftHandler<SecurityPerfectionViewModel> get draftHandler =>
      SecurityPerfectionDraftHandler();

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

  Future<void> getSecurityDeferralDetails() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      securityDeferral = await repository.getSecurityDeferralDetails();
    } catch (e) {
      logger.e("Error fetching security deferral details: $e");
      AlertManager().showFailureToast("$e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getReviewCommentsReference(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);

      getReviewComments = comments
          .where(
            (cmt) => cmt.applicationRefNo
                    ?.contains(Globals.request?.applicationRefNo ?? "") ??
                false,
          )
          .toList();
      if ((getReviewComments ?? []).isNotEmpty) {
        comment = getReviewComments?.first;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> onSaveButtonPressed() async {
    try {
      emit(state.copyWith(isButtonLoading: true));

      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        emit(state.copyWith(isButtonLoading: false));
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        return;
      }
      formKey.currentState?.save();

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
                .securityDeferralList //.where((e) => e.selected == true)
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

        securityDeferralList;
        covenantDeferralList;
        conditionDeferralList;

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
    } catch (e) {
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

  void updateTableStateChanges(String from, bool value, int index) {
    if (from == "s") {
      securityDeferral.securityDeferralList?[index].isChecked = value;
    }
    if (from == "c") {
      securityDeferral.covenant?[index].isChecked = value;
    }
    if (from == "cd") {
      securityDeferral.condition?[index].isChecked = value;
    }

    emit(
      state.copyWith(
        refreshKey: state.refreshKey + 1, // FORCE rebuild
      ),
    );
  }

  void onSavePressedLinkedFacilities(BuildContext context) {
    context.pop();
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
