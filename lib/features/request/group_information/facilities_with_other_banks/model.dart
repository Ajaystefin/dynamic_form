import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
// import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/view.dart';
import 'package:wcas_frontend/features/request/group_information/add_other_bank_dialog/view.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_other_banks.dart';
import 'package:wcas_frontend/models/request/group_information/risk_bureau.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/group_information_repository.dart';

import 'state.dart';

class FacilitiesWithOtherBanksViewModel
    extends Cubit<FacilitiesWithOtherBanksState> {
  FacilitiesWithOtherBanksViewModel()
      : super(
            FacilitiesWithOtherBanksState(loaderStatus: LoadingStatus.loading));
  GroupInformationRepository? repository;
  CommonRepository? repositoryCommon;
  ReferenceDataService? repositoryDataService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RiskBureau? riskBureau = RiskBureau();
  FacilitiesOtherBanks? facilitiesOtherBanks = FacilitiesOtherBanks();

  List<Comment>? comments;
  Comment? comment;
  String? strategyComment;

  List<Comment>? commentsCBRB;
  Comment? commentCBRB;
  String? strategyCommentCBRB;

  List<Reference> bankNameOptions = [];
  List<Reference> typeOfFacilityOptions = [];
  List<Reference> securityOptions = [];

  /// It first logs the initialization of the view model, then sets the
  /// [repository] to an instance of [GroupInformationRepository]. Finally, it awaits
  /// the completion of the following two futures:
  ///
  /// - [getApplicationStrategyDetails]
  /// - [getReferenceDatas]
  /// - [getFacilitiesOtherBanks]
  /// - [getFacilitiesCentralRiskBureau]
  void init(context) async {
    logger.i('initialising FacilitiesWithOtherBanksViewModel');
    repository ??= GroupInformationRepository.instance;
    repositoryCommon ??= CommonRepository.instance;
    repositoryDataService ??= ReferenceDataService();
    await Future.wait([
      getReferenceDatas(),
      getFacilitiesOtherBanks(),
      getFacilitiesCentralRiskBureau(),
      getApplicationStrategyDetails()
    ]);
  }

  /// Fetches reference data for the list of banks and updates the state accordingly.
  ///
  /// This asynchronous function retrieves reference data using the [ReferenceDataService]
  /// for the key [ReferenceDataKeys.bankList]. The resulting list of banks is stored in
  /// [nameofBanksRef]. It then updates the state to reflect the loading status:
  ///
  /// - If the data is successfully fetched, the state is updated with [LoadingStatus.loaded].
  /// - If an error occurs during the fetch, the state is updated with [LoadingStatus.error].

  Future<void> getReferenceDatas() async {
    try {
      Map<String, List<Reference>> referenceData =
          await repositoryDataService!.getReferenceData([
        ReferenceDataKeys.bankList,
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.securityType
      ]);
      bankNameOptions = referenceData[ReferenceDataKeys.bankList] ?? [];
      typeOfFacilityOptions =
          referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      securityOptions = referenceData[ReferenceDataKeys.securityType] ?? [];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves the group facilities with Other Bank from the repository and updates the state.
  ///
  /// This method is called when the page is first loaded. It retrieves the group
  /// facilities with Other Bank from the repository and logs the fetched details. If the
  /// fetch is successful, it updates the state with the fetched details. If an
  /// error occurs during the process, the loading status is set to error.
  Future<void> getFacilitiesOtherBanks() async {
    try {
      facilitiesOtherBanks = await repository!.getFacilitiesOtherBanks();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves the group Central Risk Bureau  from the repository and updates the state.
  ///
  /// This method is called when the page is first loaded. It retrieves the group
  /// facilities with Other Bank of Central Risk Bureau from the repository and logs the fetched details.
  /// If the fetch is successful, it updates the state with the fetched details. If an
  /// error occurs during the process, the loading status is set to error.
  Future<void> getFacilitiesCentralRiskBureau() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      riskBureau = await repository!.getFacilitiesCentralRiskBureau();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Fetches application strategy details and updates state.
  ///
  /// This method retrieves the application strategy details from the repository
  /// and logs the fetched details. It filters the `commentList` to find comments
  /// with the category type "GROUP INFORMATION" and updates `strategyComment` with
  /// the first matching comment's strategyComment. If an error occurs during the
  /// process, the loading status is set to error.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await repositoryCommon!.getApplicationStrategyDetails(
          CommentsType.facilitiesWithOtherBank,
          EntityIdentifier.facilitiesWithOtherBank);
      logger.i('Application strategy details: $comments');
      final List<Comment>? commentItem = comments
          ?.where(
              (item) => item.categoryId == ServerConstants.otherBankCategoryID)
          .toList();

      strategyComment = commentItem != null && commentItem.isNotEmpty
          ? commentItem.first.strategyComment
          : "";
      logger.i('Strategy comment: $strategyComment');

      commentsCBRB = await repositoryCommon!.getApplicationStrategyDetails(
          CommentsType.centralBankRiskBureauData,
          EntityIdentifier.centralBankRiskBureauData);
      logger.i('Application strategy details: $commentsCBRB');
      final List<Comment>? commentItemCBRB = commentsCBRB
          ?.where((item) => item.categoryId == ServerConstants.cbrbCategoryID)
          .toList();

      strategyCommentCBRB =
          commentItemCBRB != null && commentItemCBRB.isNotEmpty
              ? commentItemCBRB.first.strategyComment
              : "";
      logger.i('Strategy comment: $strategyCommentCBRB');
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the present request form data to the server.
  /// If the form is valid, it saves the form data, and then calls
  /// [GroupInformationRepository.saveGroupFacilitiesWithCbd] Constant [ServerConstants.otherBankStrategyCommentsType]
  ///  to save the form data to the server. If there is an error, it emits a new [FacilitiesWithCbdState] with
  /// the loader status set to [LoadingStatus.error].
  ///
  /// If the save is successful, it navigates to the next page.
  Future<void> onSaveButtonPressed() async {
    try {
      // if (formKey.currentState!.validate()) {
      //   formKey.currentState?.save();
      //   emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      //   logger.i('strategyComment: $strategyComment');
      //   comment?.applicationRefNo = Globals.request?.applicationRefNo;
      //   comment?.draft = false;
      //   comment?.userId = Globals.user?.id;
      //   comment?.userRole = Globals.user?.currentRole?.roleId;
      //   comment?.type = CommentsType.facilitiesWithOtherBank;
      //   comment?.entityType = EntityIdentifier.facilitiesWithOtherBank;
      //   comment?.categoryId = ServerConstants.otherBankCategoryID;
      //   comment?.categoryType = ServerConstants.otherBankCategoryType;
      //   comment?.strategyComment = strategyComment;

      //   String? result = await CommonRepository.instance
      //       .saveApplicationStrategyDetails(
      //           ServerConstants.otherBankStrategyCommentsType,
      //           ServerConstants.otherBankAppStrategyCommentsId,
      //           comment!);
      //   logger.i('onSaveButtonPressed: $result');

      //   logger.i('strategyComment: $strategyCommentCBRB');
      //   commentCBRB?.applicationRefNo = Globals.request?.applicationRefNo;
      //   commentCBRB?.draft = false;
      //   commentCBRB?.userId = Globals.user?.id;
      //   commentCBRB?.userRole = Globals.user?.currentRole?.roleId;
      //   commentCBRB?.type = CommentsType.centralBankRiskBureauData;
      //   commentCBRB?.entityType = EntityIdentifier.centralBankRiskBureauData;
      //   commentCBRB?.categoryId = ServerConstants.cbrbCategoryID;
      //   commentCBRB?.categoryType = ServerConstants.cbrbCategoryType;
      //   commentCBRB?.strategyComment = strategyCommentCBRB;

      //   String? resultCBRB = await CommonRepository.instance
      //       .saveApplicationStrategyDetails(
      //           ServerConstants.cbrbStrategyCommentsType,
      //           ServerConstants.cbrbAppStrategyCommentsId,
      //           commentCBRB!);
      LayoutViewModel().goToNextRoute();
      //   logger.i('onSaveButtonPressed: $resultCBRB');
      // }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Displays a custom dialog for adding or editing facilities with another bank.
  ///
  /// This function opens a modal dialog using [DialogHelper.showCustomDialog] with a
  /// full-screen height [AddOtherBankDialogView] widget as its content. The dialog is
  /// not dismissible by tapping outside its bounds.
  ///
  /// The dialog is intended to be used for adding a new facility or editing an existing
  /// one, with the initial state set to `null` for `facilitiesList` and `-1` for `index`,
  /// indicating a new entry.

  void addViewDialogClick(BuildContext context) {
    DialogHelper.showCustomDialog(
      barrierDismissible: false,
      title: 'groupInformation.facilitiesWithOtherBanks.title'.tr(),
      content: const SizedBox(
          child: AddOtherBankDialogView(
        facilities: null,
      )),
      context: context,
    );
  }

  /// Displays a custom dialog for adding or editing facilities with another bank.
  ///
  /// This function opens a modal dialog using [DialogHelper.showCustomDialog] with a
  /// full-screen height [AddCbrbDialogView] widget as its content. The dialog is
  /// not dismissible by tapping outside its bounds.
  ///
  /// The dialog is intended to be used for adding a new facility or editing an existing
  /// one, with the initial state set to `null` for `cbrbDataList` and `-1` for `index`,
  /// indicating a new entry.

  void addViewDialogClickCBRB(BuildContext context) {
    DialogHelper.showCustomDialog(
      barrierDismissible: false,
      title: 'groupInformation.facilitiesWithOtherBanks.title_central'.tr(),
      content: const SizedBox(child: AddCbrbDialogView(cbrb: null)),
      context: context,
    );
  }

  /// Displays a warning dialog to confirm deletion or cancellation actions.
  ///
  /// This function uses [DialogHelper.showCustomDialog] to present a modal dialog
  /// with a warning message and a single "OK" button. The dialog is intended to
  /// inform the user about potential consequences of their action, such as deleting
  /// or canceling a facility.

  void showDeletionDialog(BuildContext context) {
    DialogHelper.showCustomDialog(
      actions: [
        CustomButton(
          label: "groupInformation.facilitiesWithOtherBanks.cancelOk".tr(),
          onPressed: () => context.pop(),
        )
      ],
      title: "groupInformation.facilitiesWithOtherBanks.warning".tr(),
      content: CustomSelectableText(
          text: "groupInformation.facilitiesWithOtherBanks.warningmsg".tr()),
      context: context,
    );
  }

  /// Unified helper:
  /// - If `refs` is provided (non-null), it maps list of Reference -> "name, name".
  /// - Otherwise, if `id` is provided, it maps single id -> name.
  /// - If neither yields data, returns "--".
  String buildNames({
    List<Reference>? refs,
    required List<Reference> options,
    int? id,
  }) {
    // Case 1: List<Reference> -> names
    if (refs != null) {
      if (refs.isEmpty) return "--";
      return refs
          .map((ref) =>
              options
                  .firstWhere(
                    (e) => e.id == ref.id,
                    orElse: () =>
                        Reference(id: 0, name: "--", reference4: "--"),
                  )
                  .name ??
              "--")
          .join(', ');
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
}
