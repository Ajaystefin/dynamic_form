import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/view.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/view.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/draft_handler.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

/// View model for the Facilities with Other Banks section.
class FacilitiesWithOtherBanksViewModel
    extends SafeCubit<FacilitiesWithOtherBanksState>
    with DraftMixin<FacilitiesWithOtherBanksViewModel> {
  /// Creates a [FacilitiesWithOtherBanksViewModel].
  FacilitiesWithOtherBanksViewModel()
      : super(
          FacilitiesWithOtherBanksState(loaderStatus: LoadingStatus.loading),
        );

  /// Group information repository instance.
  GroupInformationRepository? repository;

  /// Common repository instance.
  CommonRepository? repositoryCommon;

  /// Reference data service instance.
  ReferenceDataService? repositoryDataService;

  /// Form key used for validation and submission.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Central Bank Risk Bureau data.
  RiskBureau? riskBureau = RiskBureau();

  /// Facilities maintained with other banks.
  List<Facility>? facilitiesOtherBanks = [];

  /// Comments associated with facilities maintained with other banks.
  List<Comment>? comments;

  /// Current facilities with other banks comment.
  Comment? comment;

  /// Strategy comment for facilities maintained with other banks.
  String? strategyComment = "";

  /// Comments associated with Central Bank Risk Bureau data.
  List<Comment>? commentsCBRB;

  /// Current Central Bank Risk Bureau comment.
  Comment? commentCBRB;

  /// Strategy comment for Central Bank Risk Bureau data.
  String? strategyCommentCBRB = "";

  /// Available bank name options.
  List<Reference> bankNameOptions = [];

  /// Available facility type options.
  List<Reference> typeOfFacilityOptions = [];

  /// Available security options.
  List<Reference> securityOptions = [];

  /// Controller for the facilities with other banks strategy comment.
  final TextEditingController strategyCommentController =
      TextEditingController();

  /// Controller for the Central Bank Risk Bureau strategy comment.
  final TextEditingController strategyCommentCBRBController =
      TextEditingController();

  /// Indicates whether the application is a cancellation application.
  bool get isCancellationApp =>
      Utils.checkApplicationType(ApplicationType.cancellation);

  /// Indicates whether the section can be edited.
  bool get canEdit => pageMode == PageMode.edit && !isCancellationApp;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.groupInformation;

  @override
  String get draftFormKey => Routes.facilitiesWithOtherBanks;

  @override
  DraftHandler<FacilitiesWithOtherBanksViewModel> get draftHandler =>
      FacilitiesWithOtherBanksDraftHandler();

  // ---------------------------------------------------------------------------

  /// It first logs the initialization of the view model, then sets the
  /// [repository] to an instance of [GroupInformationRepository]. Finally, it
  /// awaits
  /// the completion of the following two futures:
  ///
  /// - [getApplicationStrategyDetails]
  /// - [getReferenceDatas]
  /// - [getFacilitiesOtherBanks]
  /// - [getFacilitiesCentralRiskBureau]
  Future<void> init(BuildContext? context) async {
    logger.i("initialising FacilitiesWithOtherBanksViewModel");
    repository ??= GroupInformationRepository.instance;
    repositoryCommon ??= CommonRepository.instance;
    repositoryDataService ??= ReferenceDataService();
    await getApplicationStrategyDetails();
    await Future.wait([
      getReferenceDatas(),
      getFacilitiesCentralRiskBureau(),
      getFacilitiesOtherBanks(),
    ]);
    pageMode =
        AuthRepository.getPageMode(RightConstants.facilitiesWithOtherBanks);
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches reference data for the list of banks and updates the state
  /// accordingly.
  ///
  /// This asynchronous function retrieves reference data using the
  /// [ReferenceDataService]
  /// for the key [ReferenceDataKeys.bankList]. The resulting list of banks is
  /// stored in
  /// `nameofBanksRef`. It then updates the state to reflect the loading status:
  ///
  /// - If the data is successfully fetched, the state is updated with
  /// [LoadingStatus.loaded].
  /// - If an error occurs during the fetch, the state is updated with
  /// [LoadingStatus.error].

  Future<void> getReferenceDatas() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await repositoryDataService!.getReferenceData([
        ReferenceDataKeys.bankList,
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.securityType,
      ]);
      bankNameOptions = referenceData[ReferenceDataKeys.bankList] ?? [];
      typeOfFacilityOptions =
          referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      securityOptions = referenceData[ReferenceDataKeys.securityType] ?? [];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves the group facilities with Other Bank from the repository and
  /// updates the state.
  ///
  /// This method is called when the page is first loaded. It retrieves the
  /// group
  /// facilities with Other Bank from the repository and logs the fetched
  /// details. If the
  /// fetch is successful, it updates the state with the fetched details. If an
  /// error occurs during the process, the loading status is set to error.
  Future<void> getFacilitiesOtherBanks() async {
    try {
      emit(state.copyWith(otherBankLoader: LoadingStatus.loading));
      facilitiesOtherBanks = [];
      facilitiesOtherBanks = await repository!.getFacilitiesOtherBanks();
      emit(state.copyWith(otherBankLoader: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(otherBankLoader: LoadingStatus.error));
    }
  }

  /// Retrieves the group Central Risk Bureau  from the repository and updates
  /// the state.
  ///
  /// This method is called when the page is first loaded. It retrieves the
  /// group
  /// facilities with Other Bank of Central Risk Bureau from the repository and
  /// logs the fetched details.
  /// If the fetch is successful, it updates the state with the fetched details.
  /// If an
  /// error occurs during the process, the loading status is set to error.
  Future<void> getFacilitiesCentralRiskBureau() async {
    try {
      emit(state.copyWith(cbrbTableLoader: LoadingStatus.loading));
      riskBureau = await repository!.getFacilitiesCentralRiskBureau();
      emit(state.copyWith(cbrbTableLoader: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(cbrbTableLoader: LoadingStatus.error));
    }
  }

  /// Fetches application strategy details and updates state.
  ///
  /// This method retrieves the application strategy details from the repository
  /// and logs the fetched details. It filters the `commentList` to find
  /// comments
  /// with the category type "GROUP INFORMATION" and updates `strategyComment`
  /// with
  /// the first matching comment's strategyComment. If an error occurs during
  /// the
  /// process, the loading status is set to error.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await repositoryCommon!.getApplicationStrategyDetails(
        CommentsType.facilitiesWithOtherBank,
        EntityIdentifier.facilitiesWithOtherBank,
      );
      final List<Comment>? commentItem = comments
          ?.where(
            (item) => item.categoryId == ServerConstants.otherBankCategoryID,
          )
          .toList();

      strategyComment = commentItem != null && commentItem.isNotEmpty
          ? commentItem.first.strategyComment
          : "";

      strategyCommentController.text = strategyComment ?? "";

      commentsCBRB = await repositoryCommon!.getApplicationStrategyDetails(
        CommentsType.centralBankRiskBureauData,
        EntityIdentifier.centralBankRiskBureauData,
      );
      final List<Comment>? commentItemCBRB = commentsCBRB
          ?.where((item) => item.categoryId == ServerConstants.cbrbCategoryID)
          .toList();

      strategyCommentCBRB =
          commentItemCBRB != null && commentItemCBRB.isNotEmpty
              ? commentItemCBRB.first.strategyComment
              : "";

      strategyCommentCBRBController.text = strategyCommentCBRB ?? "";

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the present request form data to the server.
  /// If the form is valid, it saves the form data, and then calls
  /// [`GroupInformationRepository.saveGroupFacilitiesWithCbd`] Constant
  /// [ServerConstants.otherBankStrategyCommentsType]
  ///  to save the form data to the server. If there is an error, it emits a new
  /// [`FacilitiesWithCbdState`] with
  /// the loader status set to [LoadingStatus.error].
  ///
  /// If the save is successful, it navigates to the next page.
  Future<void> onSaveComment() async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        logger.i("strategyComment: $strategyComment");
        commentCBRB = Comment();
        commentCBRB?.applicationRefNo = Globals.request?.applicationRefNo;
        commentCBRB?.draft = false;
        commentCBRB?.userId = Globals.user?.id;
        commentCBRB?.userRole = Globals.user?.currentRole?.roleId;
        commentCBRB?.type = CommentsType.centralBankRiskBureauData;
        commentCBRB?.entityType = EntityIdentifier.centralBankRiskBureauData;
        commentCBRB?.categoryId = ServerConstants.cbrbCategoryID;
        commentCBRB?.categoryType = ServerConstants.cbrbCategoryType;
        commentCBRB?.strategyComment = strategyCommentCBRB;

        String? result =
            await CommonRepository.instance.saveApplicationStrategyDetails(
          ServerConstants.cbrbStrategyCommentsType,
          ServerConstants.cbrbAppStrategyCommentsId,
          commentCBRB,
        );

        logger.i("strategyComment: $strategyCommentCBRB");
        comment = Comment();
        comment?.applicationRefNo = Globals.request?.applicationRefNo;
        comment?.draft = false;
        comment?.userId = Globals.user?.id;
        comment?.userRole = Globals.user?.currentRole?.roleId;
        comment?.type = CommentsType.facilitiesWithOtherBank;
        comment?.entityType = EntityIdentifier.facilitiesWithOtherBank;
        comment?.categoryId = ServerConstants.otherBankCategoryID;
        comment?.categoryType = ServerConstants.otherBankCategoryType;
        comment?.strategyComment = strategyComment;

        result = await CommonRepository.instance.saveApplicationStrategyDetails(
          ServerConstants.otherBankStrategyCommentsType,
          ServerConstants.otherBankAppStrategyCommentsId,
          comment,
        );
        unawaited(
          deleteDraft(),
        ); // fire-and-forget: remove backend draft now that data is saved
        AlertManager().showSuccessToast(result.toString());
        LayoutViewModel().goToNextRoute();

        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Displays a custom dialog for adding or editing facilities with another
  /// bank.
  ///
  /// This function opens a modal dialog using [DialogHelper.showCustomDialog]
  /// with a
  /// full-screen height [AddOtherBankDialogView] widget as its content. The
  /// dialog is
  /// not dismissible by tapping outside its bounds.
  ///
  /// The dialog is intended to be used for adding a new facility or editing an
  /// existing
  /// one, with the initial state set to `null` for `facilitiesList` and `-1`
  /// for `index`,
  /// indicating a new entry.

  Future<void> addOtherBank(BuildContext context, Facility? data) async {
    try {
      await DialogHelper.showCustomDialog(
        barrierDismissible: false,
        title: "groupInformation.facilitiesWithOtherBanks.title".tr(),
        content: SizedBox(
          child: AddOtherBankDialogView(
            facilities: data,
          ),
        ),
        context: context,
      );
    } finally {
      await getFacilitiesOtherBanks();
    }
  }

  /// Displays a custom dialog for adding or editing facilities with another
  /// bank.
  ///
  /// This function opens a modal dialog using [DialogHelper.showCustomDialog]
  /// with a
  /// full-screen height [AddCbrbDialogView] widget as its content. The dialog
  /// is
  /// not dismissible by tapping outside its bounds.
  ///
  /// The dialog is intended to be used for adding a new facility or editing an
  /// existing
  /// one, with the initial state set to `null` for `cbrbDataList` and `-1` for
  /// `index`,
  /// indicating a new entry.

  Future<void> addCBRB(BuildContext context, CBRB? data) async {
    try {
      await DialogHelper.showCustomDialog(
        barrierDismissible: false,
        title: "groupInformation.facilitiesWithOtherBanks.title_central".tr(),
        content: SizedBox(
          child: AddCbrbDialogView(
            cbrb: data,
          ),
        ),
        context: context,
      );
    } finally {
      await getFacilitiesCentralRiskBureau();
    }
  }

  /// Displays a warning dialog to confirm deletion or cancellation actions.
  ///
  /// This function uses [DialogHelper.showCustomDialog] to present a modal
  /// dialog
  /// with a warning message and a single "OK" button. The dialog is intended to
  /// inform the user about potential consequences of their action, such as
  /// deleting
  /// or canceling a facility.

  Future<void> deleteOtherBankFacility(
    BuildContext context,
    Facility? data,
  ) async {
    try {
      await DialogHelper.showCustomDialog(
        actions: [
          CustomButton(
            label: "groupInformation.facilitiesWithOtherBanks.delete".tr(),
            onPressed: () async {
              final String? resp =
                  await repository!.deleteOtherBankFacility(data);
              AlertManager().showSuccessToast(resp.toString());
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          const Gap(direction: Axis.horizontal),
          CustomButton(
            label: "groupInformation.facilitiesWithOtherBanks.cancel".tr(),
            onPressed: () => context.pop(),
          ),
        ],
        title: "groupInformation.facilitiesWithOtherBanks.warning".tr(),
        content: CustomSelectableText(
          text: "groupInformation.facilitiesWithOtherBanks.warningmsg".tr(),
        ),
        context: context,
      );
    } finally {
      await getFacilitiesOtherBanks();
    }
  }

  /// Displays a warning dialog to confirm deletion or cancellation actions.
  ///
  /// This function uses [DialogHelper.showCustomDialog] to present a modal
  /// dialog
  /// with a warning message and a single "OK" button. The dialog is intended to
  /// inform the user about potential consequences of their action, such as
  /// deleting
  /// or canceling a facility.

  Future<void> deleteCBRBData(BuildContext context, CBRB? data) async {
    try {
      await DialogHelper.showCustomDialog(
        actions: [
          CustomButton(
            label: "groupInformation.facilitiesWithOtherBanks.delete".tr(),
            onPressed: () async {
              final String? resp = await repository!.deleteCBRBData(data);
              AlertManager().showSuccessToast(resp.toString());
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          const Gap(direction: Axis.horizontal),
          CustomButton(
            label: "groupInformation.facilitiesWithOtherBanks.cancel".tr(),
            onPressed: () => context.pop(),
          ),
        ],
        title: "groupInformation.facilitiesWithOtherBanks.warning".tr(),
        content: CustomSelectableText(
          text: "groupInformation.facilitiesWithOtherBanks.warningmsg".tr(),
        ),
        context: context,
      );
    } finally {
      await getFacilitiesCentralRiskBureau();
    }
  }

  /// Unified helper:
  /// - If `refs` is provided (non-null), it maps list of Reference -> "name,
  /// name".
  /// - Otherwise, if `id` is provided, it maps single id -> name.
  /// - If neither yields data, returns "--".
  String buildNames({
    required List<Reference> options,
    List<Reference>? refs,
    int? id,
  }) {
    // Case 1: List<Reference> -> names
    if (refs != null) {
      if (refs.isEmpty) {
        return "--";
      }
      return refs
          .map(
            (ref) =>
                options
                    .firstWhere(
                      (e) => e.id == ref.id,
                      orElse: () =>
                          Reference(id: 0, name: "--", reference4: "--"),
                    )
                    .name ??
                "--",
          )
          .join(", ");
    }
    // Case 2: Single id -> name
    if (id != null) {
      return options
              .firstWhere(
                (e) => e.id == id,
                orElse: () => Reference(id: 0, name: "--"),
              )
              .name ??
          "--";
    }
    // Fallback
    return "--";
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
