import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/risk_rating/external_rating.dart';
import 'package:wcas_frontend/models/request/risk_rating/internal_rating.dart';
import 'package:wcas_frontend/models/request/risk_rating/risk_rating.dart';
import 'package:wcas_frontend/models/request/risk_rating/updated_rating.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/repositories/risk_rating_repository.dart';
import 'state.dart';

class RiskRatingViewModel extends Cubit<RiskRatingState> {
  RiskRatingViewModel()
      : super(RiskRatingState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for accessing risk rating data.
  late RiskRatingRepository repository;
  bool isCreditLensAvailable = true;
  List<int?> rimWithNoEntity = [];
  Map<String, List<Reference>> referenceData = {};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int initialInternalRatingPage = 0;
  int initialExternalRatingPage = 0;

  bool isViewOnly = true;

  TextEditingController rimNoController = TextEditingController();

  /// Holds the current risk rating data.
  late RiskRating riskRating;
  late List<UpdatedRating?> updatedRiskRating;

  /// Lists of reference data for external rating agencies.
  List<Reference> sAndP = [];
  List<Reference> moodys = [];
  List<Reference> fitch = [];
  List<Reference> ifrsStagings = [];

  int tableRow = 10;

  /// Initializes the ViewModel by fetching risk rating and reference data.
  ///
  /// Emits a loaded state once data is successfully retrieved.
  void init(context) async {
    repository = RiskRatingRepository.instance;
    checkViewAccess();
    await getRiskRating();
    await getComments();
    await getReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void checkViewAccess() {
    if (Utils.checkRoles([
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.relationshipManagerBussiness,
      UserRole.segmentHeadBusiness,
    ])) {
      isViewOnly = false;
    }

    if (Utils.checkApplicationType(ApplicationType.riskRatingChange)) {
      if (Utils.checkRoles([
        UserRole.creditAnalyst,
        UserRole.creditCordinator,
      ])) {
        isViewOnly = false;
      }
    }
  }

  bool isProposedbyCreditEditables() {
    final role = Globals.user?.currentRole?.userRole;
    // Check if application type is Risk Rating or Staging
    // if (Utils.checkApplicationType(ApplicationType.riskRatingChange)) {
    //   // Check if user role is allowed
    //   if (role == UserRole.creditAnalyst || role == UserRole.creditCordinator) {
    //     return true;
    //   } else {
    //     return false;
    //   }
    // }

    // Check if user role is allowed
    return role == UserRole.boardOfDirectorsProxy ||
        role == UserRole.creditAnalyst ||
        role == UserRole.creditCommitteeProxy;
  }

  /// Adds a new row to the external ratings table if the last entry is valid.
  ///
  /// This asynchronous function performs the following:
  /// - Checks if the last entry in `externalRatings` has a `customerRimNo` of `-1`,
  ///   which indicates an incomplete or placeholder row. If so, it exits early.
  /// - If the last entry is valid, it emits a loading state for the external table.
  /// - Adds a new `ExternalRating` object with default values to the `externalRatings` list.
  /// - Introduces a short delay to simulate UI update timing.
  /// - Emits a loaded state to indicate the row has been added.
  Future<void> addExternalTableRow() async {
    if ((riskRating.externalRatings?.isNotEmpty ?? false) &&
        riskRating.externalRatings?.last.customerRimNo == -1) {
      return;
    } else {
      int itemCount = (riskRating.externalRatings ?? []).length;
      initialExternalRatingPage = (itemCount / tableRow).ceil();
      riskRating.externalRatings?.add(ExternalRating(
        customerName: "",
        customerRimNo: -1,
        isDeleted: true,
      ));
      rimNoController.text = ""; // clear if -1

      emit(state.copyWith(externalTableStatus: LoadingStatus.loaded));
    }
  }

  Future<void> addInternalTableRow() async {
    if (riskRating.internalRatings.isNotEmpty &&
        riskRating.internalRatings.last.customerRimNo == -1) {
      return;
    } else {
      int itemCount = riskRating.internalRatings.length;
      initialInternalRatingPage = (itemCount / tableRow).ceil();

      riskRating.internalRatings.add(InternalRating(
          entityFilled: false,
          customerName: null,
          fromWcasDB: false,
          customerRimNo: null,
          isDeletable: true));
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<String?> fetchCustomerIfrs(String rim) async {
    Customer? customerInformation = await CustomerRepository.instance
        .getCustomerInformationByRim(int.tryParse(rim));
    Reference? ifrsStaging;
    if (customerInformation?.ifrsStaging != null) {
      ifrsStaging = ifrsStagings.firstWhere(
        (element) => element.name == customerInformation?.ifrsStaging,
        orElse: () => Reference(name: customerInformation?.ifrsStaging),
      );
    }
    return ifrsStaging?.name ?? "";
  }

  Future<void> searchByRim(int index, String rim) async {
    try {
      Customer? customerDetails =
          await CustomerRepository().searchUserDetailsForCL(rim, '', '', '');

      if (customerDetails == null) {
        throw "common.noUserFound".tr();
      }

      if (customerDetails.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw "common.noUserFoundClosedPartyStatus".tr();
      } else {
        riskRating.internalRatings[index].customerName =
            customerDetails.customerName;
        riskRating.internalRatings[index].customerRimNo = int.tryParse(rim);
        if (!isCreditLensAvailable) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        }
        // if (riskRating.internalRatings[index].entityId != null) {
        final List<UpdatedRating?> updatedInternalRating =
            await repository.getUpdatedRatingDetails(
          rimNo: int.tryParse(rim),
        );
        if ((updatedInternalRating).any((e) => e?.isClDown == true)) {
          isCreditLensAvailable = false;
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        } else {
          isCreditLensAvailable = true;
        }
        var filteredRatingFromCL =
            updatedInternalRating.where((e) => int.tryParse(rim) == e?.rimNo);

        List<int?> entities = filteredRatingFromCL.map((e) {
          return e?.entityId;
        }).toList();

        String? ifrsStaging = await fetchCustomerIfrs(rim);
        bool isRimAvailable =
            updatedInternalRating.any((e) => e?.rimNo == int.tryParse(rim));
        if (isRimAvailable) {
          for (UpdatedRating? updatedRating in updatedInternalRating) {
            if (updatedRating?.rimNo == int.tryParse(rim)) {
              // if (riskRating.internalRatings.any((e) =>
              //     e.customerRimNo == updatedRating?.rimNo &&
              //     e.entityId == updatedRating?.entityId)) {
              //   AlertManager().showFailureToast(
              //     "Entered Customer RIM and Entity Combination Already Exists. Please enter a valid RIM Number",
              //   );
              //   return;
              // }
              riskRating.internalRatings[index] =
                  InternalRating().fromUpdatedRatings(
                      InternalRating(
                        isDeletable: true,
                        entityFilled: entities.length == 1,
                        entities: entities,
                        fromWcasDB: false,
                        ifrs: ifrsStaging,
                        entityId: entities.length == 1 ? entities[0] : null,
                        customerRimNo: int.tryParse(rim),
                        customerName: customerDetails.customerName,
                      ),
                      updatedRating,
                      isMultipleEntity: entities.length > 1);
            }
          }
        } else {
          riskRating.internalRatings[index].searchedRim = int.tryParse(rim);
          if (!rimWithNoEntity.contains(int.tryParse(rim))) {
            rimWithNoEntity.add(int.tryParse(rim));
            AlertManager().showWarningToast("riskRating.warning".tr());
          }
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> onSelectedEntities(
      {int? rim, int? entity, int? index, bool? isSearchEntity}) async {
    if (isCreditLensAvailable &&
        isInternalDuplicate(rim: rim, entityId: entity)) {
      AlertManager().showFailureToast(
        "Entered Customer RIM and Entity Combination Already Exists. Please enter a valid RIM Number",
      );
      return;
    }
    if (!isCreditLensAvailable && index != null) {
      riskRating.internalRatings[index].entityId = entity;
      return;
    }
    if (index != null) {
      riskRating.internalRatings[index].supportParam = true;
    }
    bool showAlert = true;
    final updatedInternalRating = await repository.getUpdatedRatingDetails(
        rimNo: isSearchEntity == true ? null : rim, entityId: entity);

    if ((updatedInternalRating).any((e) => e?.isClDown == true)) {
      if (index != null) {
        riskRating.internalRatings[index].entityId = entity;
      }
      isCreditLensAvailable = false;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    } else {
      isCreditLensAvailable = true;
    }

    for (int i = 0; i < riskRating.internalRatings.length; i++) {
      bool supportCondition = index != null
          ? riskRating.internalRatings[i].supportParam == true
          : true;
      if (riskRating.internalRatings[i].customerRimNo == rim &&
          supportCondition) {
        for (UpdatedRating? updatedRating in updatedInternalRating) {
          if (entity == updatedRating?.entityId) {
            if (isSearchEntity == true
                //  &&
                //     riskRating.internalRatings[i].searchedRim == rim
                ) {
              riskRating.internalRatings[i] = InternalRating()
                  .fromUpdatedRatings(
                      riskRating.internalRatings[i], updatedRating);
              riskRating.internalRatings[i].searchedRim = null;
              rimWithNoEntity.removeWhere((e) => e == rim);
              AlertManager().showSuccessToast("Entity Id updated for $rim");
            } else if (isSearchEntity != true) {
              riskRating.internalRatings[i] = InternalRating()
                  .fromUpdatedRatings(
                      riskRating.internalRatings[i], updatedRating);
            }
            showAlert = false;
          }
        }
      }
    }
    if (index != null) {
      riskRating.internalRatings[index].supportParam = false;
    }
    if (showAlert) {
      AlertManager().showFailureToast("riskRating.invalidEntity".tr());
    } else {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Removes a row from the external ratings table at the specified index.
  void removeExternalTableRow(int index) {
    riskRating.externalRatings?.removeAt(index);
    emit(state.copyWith(externalTableStatus: LoadingStatus.loaded));
  }

  /// Removes a row from the internal ratings table at the specified index.
  void removeInternalTableRow(int index) {
    riskRating.internalRatings.removeAt(index);
    if (!(riskRating.internalRatings).any((item) => item.isDeletable == true)) {
      isCreditLensAvailable = true;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool isInternalDuplicate({required int? rim, int? entityId}) {
    return riskRating.internalRatings.any((e) {
      if (e.customerRimNo == rim && e.entityId == entityId) {
        return true;
      } else {
        return false;
      }
    });
  }

  bool isInternalDuplicateonSave() {
    List<int?> entities =
        riskRating.internalRatings.map((e) => e.entityId).toList();

    bool isEntityPresent = entities.contains(null);

    if (isEntityPresent) {
      AlertManager().showFailureToast(
        "Please enter a valid Entity ID in Internal Rating",
      );
      return true;
    } else {
      return false;
    }
  }

  bool isExternalDuplicate({required int? rim}) {
    List<int?> rims =
        (riskRating.externalRatings ?? []).map((e) => e.customerRimNo).toList();

    bool isRimPresent = rims.contains(rim);
    if (isRimPresent) {
      return true;
    } else {
      return false;
    }
  }

  /// Triggers a search for external rating RIM data.
  Future<void> searchExternalRatingRim(String rim, int i) async {
    try {
      bool isDuplicate = isExternalDuplicate(rim: int.tryParse(rim));
      if (isDuplicate) {
        AlertManager().showFailureToast(
          "Entered Customer RIM Number Already Exists. Please enter a valid RIM Number",
        );
        return;
      }
      Customer? customerDetails =
          await CustomerRepository().searchUserDetails(rim, '', '', '');
      if (customerDetails == null) {
        throw "common.noUserFound".tr();
      }

      if (customerDetails.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw "common.noUserFoundClosedPartyStatus".tr();
      } else {
        riskRating.externalRatings?[i] = ExternalRating(
          isDeleted: true,
          customerRimNo: int.tryParse(customerDetails.id ?? ""),
          customerName:
              customerDetails.preferredName ?? customerDetails.lastName,
        );
      }
      emit(state.copyWith(externalTableStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Identifies and returns a list of duplicate internal RIM numbers.
  ///
  /// Populates the [multipleRims] map with the corresponding internal ratings.
  List<int?> multipleEntities(int? customerRimNo) {
    List<int?> multiEntities = [];
    List<int?> customerRims = updatedRiskRating.map((e) => e?.rimNo).toList();

    if (customerRims.isEmpty) {
      return [];
    }

    for (int i = 0; i < updatedRiskRating.length; i++) {
      if (updatedRiskRating[i]?.rimNo == customerRimNo) {
        multiEntities.add(updatedRiskRating[i]?.entityId);
      }
    }

    return multiEntities;
  }

  Future<void> updateRatingsFromCL() async {
    try {
      for (InternalRating existingRating in riskRating.internalRatings) {
        List<UpdatedRating?> updatedRatings =
            await repository.getUpdatedRatingDetails(
                entityId: existingRating.entityId == 0
                    ? null
                    : existingRating.entityId,
                rimNo: existingRating.customerRimNo);
        if ((updatedRatings).any((e) => e?.isClDown == true)) {
          isCreditLensAvailable = false;
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        } else {
          isCreditLensAvailable = true;
        }
        updatedRiskRating.addAll(updatedRatings);
      }

      if (updatedRiskRating.isNotEmpty) {
        for (InternalRating internalRating in (riskRating.internalRatings)) {
          List<int?> entities = updatedRiskRating
              .map((e) =>
                  e?.rimNo == internalRating.customerRimNo ? e?.entityId : null)
              .toList();

          for (UpdatedRating? updatedRating in updatedRiskRating) {
            bool entityCheck = (internalRating.entityId == 0 ||
                    internalRating.entityId == null)
                ? true
                : internalRating.entityId == updatedRating?.entityId;

            if ((internalRating.customerRimNo == updatedRating?.rimNo) &&
                updatedRating != null &&
                entityCheck) {
              internalRating = InternalRating().fromUpdatedRatings(
                  internalRating, updatedRating,
                  entities: internalRating.entityId != null ? [] : entities,
                  isMultipleEntity: internalRating.entityId != null
                      ? false
                      : entities.length > 1);
            }
          }
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Fetches the current risk rating data from the repository.
  Future<void> getRiskRating() async {
    try {
      updatedRiskRating = [];
      riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );

      riskRating = await repository.getRatingDetails();
      bool isNewRefNo = riskRating.internalRatings.any(
          (e) => e.customerRiskRatingId == 0 || e.customerRiskRatingId == null);
      if (isNewRefNo) {
        await onRefreshPressed();
      }

      for (InternalRating data in riskRating.internalRatings) {
        if (data.entityId == null &&
            (data.entities == null || (data.entities ?? []).isEmpty)) {
          rimWithNoEntity.add(data.customerRimNo!);
        }
      }

      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  ///get comments which was saved
  Future<void> getComments() async {
    try {
      List<Comment> comments = await CommonRepository.instance.getComments(
        CommentsType.riskRating,
        EntityIdentifier.strategyComments,
      );
      if (comments.isEmpty) return;
      List<Comment> filteredComments = comments
          .where((comment) =>
              (comment.applicationRefNo == Globals.request?.applicationRefNo))
          .toList();
      if (filteredComments.isEmpty) return;
      filteredComments.sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
      riskRating.comments = filteredComments.first.comment;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetches reference data for external rating agencies.
  Future<void> getReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.sAndP,
        ReferenceDataKeys.moodys,
        ReferenceDataKeys.fitch,
        ReferenceDataKeys.ifrsStaging
      ]);
      sAndP = referenceData[ReferenceDataKeys.sAndP] ?? [];
      moodys = referenceData[ReferenceDataKeys.moodys] ?? [];
      fitch = referenceData[ReferenceDataKeys.fitch] ?? [];
      ifrsStagings = referenceData[ReferenceDataKeys.ifrsStaging] ?? [];

      emit(state.copyWith(externalTableStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the current risk rating data to the repository.
  ///
  /// Displays a success or error toast based on the result.
  Future<void> onSavePressed({bool isReadOnly = false}) async {
    try {
      if (isReadOnly) {
        LayoutViewModel().goToNextRoute();
        return;
      }
      if (isInternalDuplicateonSave()) {
        return;
      }
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        bool hasInvalidRim = (riskRating.externalRatings ?? [])
            .any((rating) => rating.customerRimNo == -1);

        if (hasInvalidRim) {
          AlertManager().showFailureToast('riskRating.emptyfeildRim'.tr());
          return;
        }

        Comment comment = Comment.fromInputData(
          comment: riskRating.comments,
          type: CommentsType.riskRating,
          categoryId: ServerConstants.commentTypeId[CommentsType.riskRating]!,
        );

        await CommonRepository.instance.saveComment(comment);
        await repository.saveRatings(
          customerRating: RiskRating.toJson(
              internalRatings: riskRating.internalRatings,
              externalRatings: riskRating.externalRatings ?? [],
              isClDown: !isCreditLensAvailable),
        );
        LayoutViewModel().goToNextRoute();
        AlertManager().showSuccessToast("riskRating.savedSuccefully".tr());
      }
    } catch (e) {
      AlertManager().showFailureToast('common.serverError'.tr());
    }
  }

  /// Refreshes the risk rating and reference data.
  ///
  /// [from] determines whether to refresh internal (0) or external (1) data.
  Future<void> onRefreshPressed() async {
    emit(state.copyWith(refreshLoader: LoadingStatus.loading));
    await updateRatingsFromCL();
    emit(state.copyWith(
        refreshLoader: LoadingStatus.loaded,
        loaderStatus: LoadingStatus.loaded));
  }

  void emitInternalRating() {
    emit(RiskRatingState(loaderStatus: LoadingStatus.loaded));
  }
}
