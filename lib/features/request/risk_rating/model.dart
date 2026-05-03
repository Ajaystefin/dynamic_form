import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/risk_rating/draft_handler.dart";
import "package:wcas_frontend/features/request/risk_rating/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/risk_rating_repository.dart";

typedef CustomerRepositoryFactory = CustomerRepository Function();
typedef NavigationCallback = void Function();

class RiskRatingViewModel extends SafeCubit<RiskRatingState>
    with DraftMixin<RiskRatingViewModel> {
  RiskRatingViewModel({
    RiskRatingRepository? repositoryOverride,
    CustomerRepositoryFactory? customerRepositoryFactory,
    NavigationCallback? goToNextRoute,
  })  : _customerRepositoryFactory = customerRepositoryFactory,
        _goToNextRoute = goToNextRoute,
        super(RiskRatingState(loaderStatus: LoadingStatus.loading)) {
    repository = repositoryOverride ?? RiskRatingRepository.instance;
  }

  final CustomerRepositoryFactory? _customerRepositoryFactory;
  final NavigationCallback? _goToNextRoute;

  CustomerRepository get _customerRepository =>
      _customerRepositoryFactory?.call() ?? CustomerRepository.instance;

  void _nextRoute() {
    if (_goToNextRoute != null) {
      _goToNextRoute();
      return;
    }
    LayoutViewModel().goToNextRoute();
  }

  /// Repository instance for accessing risk rating data.
  late RiskRatingRepository repository;
  bool isCreditLensAvailable = true;
  List<int?> rimWithNoEntity = [];
  Map<String, List<Reference>> referenceData = {};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int initialInternalRatingPage = 0;
  int initialExternalRatingPage = 0;

  bool isViewOnly = true;

  bool isFiFlow = false;

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

  /// if navigated using amend button [isProposedFieldEditable] field will get
  /// updated
  bool isProposedFieldEditable = false;
  PageMode? amendPagemode;

  List<int> fiCRR = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
  ];

  final ScrollController internalRatingScrollController =
      ScrollController(keepScrollOffset: false);

  final ScrollController externalRatingScrollController =
      ScrollController(keepScrollOffset: false);

  TextEditingController internalRatingTextController = TextEditingController();
  UnifiedEditorController internalRatingControler = UnifiedEditorController();
  UnifiedEditorController externalRatingControler = UnifiedEditorController();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.riskRating;

  @override
  String get draftFormKey => Routes.riskRating;

  @override
  DraftHandler<RiskRatingViewModel> get draftHandler =>
      RiskRatingDraftHandler();

  // ---------------------------------------------------------------------------
  bool isInitializing = true;

  bool get canEdit =>
      pageMode == PageMode.edit; // && Utils.canEditApplication();

  PageMode pageMode = PageMode.na;

  /// Initializes the ViewModel by fetching risk rating and reference data.
  ///
  /// Emits a loaded state once data is successfully retrieved.
  /// [amendPagemode] will be need when user navigates using amend button
  Future<void> init(context, {PageMode? amendPagemode}) async {
    repository = RiskRatingRepository.instance;
    this.amendPagemode =
        // assign to variable to use in isProposedbyCreditEditables()
        amendPagemode;
    isFiFlow = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    pageMode = amendPagemode ??
        AuthRepository.getPageMode(RightConstants.customerRiskRating);
    // pageMode = AuthRepository.getPageMode(RightConstants.customerRiskRating);
    // if (pagemode == PageMode.edit) {
    //   isViewOnly = false;
    // }

    await getReferenceData();
    await getRiskRating();
    checkViewAccess();
    await getComments();

    if (!isViewOnly) {
      // registerDraftCallback();
      // await loadDraftIfAvailable();
      isInitializing = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    // unregisterDraftCallback();
    return super.close();
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

  /// Fetches reference data for external rating agencies.
  Future<void> getReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.sAndP,
        ReferenceDataKeys.moodys,
        ReferenceDataKeys.fitch,
        ReferenceDataKeys.ifrsStaging,
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

  bool isProposedbyCreditEditables() {
    final role = Globals.user?.currentRole?.userRole;
    // Check if application type is Risk Rating or Staging
    // if (Utils.checkApplicationType(ApplicationType.riskRatingChange)) {
    //   // Check if user role is allowed
    //   if (role == UserRole.creditAnalyst || role ==
    // UserRole.creditCordinator) {
    //     return true;
    //   } else {
    //     return false;
    //   }
    // }

    // if it is FI flow then all fields are editable
    if (isFiFlow) {
      amendPagemode = PageMode.edit;
    }

    // Check if user role is allowed
    return (role == UserRole.boardDirectorProxy ||
            role == UserRole.creditAnalyst ||
            role == UserRole.creditCommitteeProxy) &&
        (amendPagemode == PageMode.edit);
  }

  Future<String?> fetchCustomerIfrs(String rim) async {
    final Customer? customerInformation = await _customerRepository
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
      final Customer? customerDetails =
          await _customerRepository.searchUserDetailsForCL(rim, "", "", "");

      if (customerDetails == null) {
        throw "common.noUserFound".tr();
      }

      if (customerDetails.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw "common.noUserFoundClosedPartyStatus".tr();
      } else if (isFiFlow) {
        riskRating.internalRatings[index].customerName =
            customerDetails.concatCustomerFullName;
        riskRating.internalRatings[index].customerRimNo = int.tryParse(rim);
      } else {
        riskRating.internalRatings[index].customerName =
            customerDetails.concatCustomerFullName;
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
        if (updatedInternalRating.any((e) => e?.isClDown == true)) {
          isCreditLensAvailable = false;
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        } else {
          isCreditLensAvailable = true;
        }
        final filteredRatingFromCL =
            updatedInternalRating.where((e) => int.tryParse(rim) == e?.rimNo);

        final List<int?> entities = filteredRatingFromCL.map((e) {
          return e?.entityId;
        }).toList();

        final String? ifrsStaging = await fetchCustomerIfrs(rim);
        final bool isRimAvailable =
            updatedInternalRating.any((e) => e?.rimNo == int.tryParse(rim));
        if (isRimAvailable) {
          for (final UpdatedRating? updatedRating in updatedInternalRating) {
            if (updatedRating?.rimNo == int.tryParse(rim)) {
              // if (riskRating.internalRatings.any((e) =>
              //     e.customerRimNo == updatedRating?.rimNo &&
              //     e.entityId == updatedRating?.entityId)) {
              //   AlertManager().showFailureToast(
              //     "Entered Customer RIM and Entity Combination Already
              // Exists. Please enter a valid RIM Number",
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
                  customerName: customerDetails.concatCustomerFullName,
                ),
                updatedRating,
                isMultipleEntity: entities.length > 1,
              );
            }
          }
        } else {
          riskRating.internalRatings[index].searchedRim = int.tryParse(rim);
          if (!rimWithNoEntity.contains(int.tryParse(rim))) {
            riskRating.internalRatings[index].rimWithNoEntity = true;
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

  Future<void> onSelectedEntities({
    int? rim,
    int? entity,
    int? index,
    bool? isSearchEntity,
  }) async {
    if (isCreditLensAvailable &&
        isInternalDuplicate(rim: rim, entityId: entity)) {
      AlertManager().showFailureToast(
        "Entered Customer RIM "
        "and Entity Combination "
        "Already Exists. Please enter a valid RIM Number",
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
      rimNo: isSearchEntity == true ? null : rim,
      entityId: entity,
    );

    if (updatedInternalRating.any((e) => e?.isClDown == true)) {
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
      final bool supportCondition = index != null
          ? riskRating.internalRatings[i].supportParam == true
          : true;
      if (riskRating.internalRatings[i].customerRimNo == rim &&
          supportCondition) {
        for (final UpdatedRating? updatedRating in updatedInternalRating) {
          if (entity == updatedRating?.entityId) {
            if (isSearchEntity == true
                //  &&
                //     riskRating.internalRatings[i].searchedRim == rim
                ) {
              riskRating.internalRatings[i] =
                  InternalRating().fromUpdatedRatings(
                riskRating.internalRatings[i],
                updatedRating,
              );
              riskRating.internalRatings[i].searchedRim = null;
              rimWithNoEntity.removeWhere((e) => e == rim);
              AlertManager().showSuccessToast("Entity Id updated for $rim");
            } else if (isSearchEntity != true) {
              riskRating.internalRatings[i] =
                  InternalRating().fromUpdatedRatings(
                riskRating.internalRatings[i],
                updatedRating,
              );
            }
            showAlert = false;
          }
        }
      }
    }
    if (riskRating.internalRatings.isEmpty) {
      for (final UpdatedRating? updatedRating in updatedInternalRating) {
        if (entity == updatedRating?.entityId) {
          if (isSearchEntity == true
              //  &&
              //     riskRating.internalRatings[i].searchedRim == rim
              ) {
            riskRating.internalRatings.add(
              InternalRating().fromUpdatedRatings(
                InternalRating(customerRimNo: rim),
                updatedRating,
              ),
            );
            riskRating.internalRatings[0].searchedRim = null;
            rimWithNoEntity.removeWhere((e) => e == rim);
            AlertManager().showSuccessToast("Entity Id updated for $rim");
          } else if (isSearchEntity != true) {
            riskRating.internalRatings.add(
              InternalRating().fromUpdatedRatings(
                InternalRating(customerRimNo: rim),
                updatedRating,
              ),
            );
          }
          showAlert = false;
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

  Future<void> addInternalTableRow() async {
    if (riskRating.internalRatings.isNotEmpty &&
        riskRating.internalRatings.last.customerRimNo == -1) {
      return;
    } else {
      final int itemCount = riskRating.internalRatings.length;
      initialInternalRatingPage = (itemCount / tableRow).ceil();

      riskRating.internalRatings.add(
        InternalRating(
          entityFilled: false,
          customerName: null,
          fromWcasDB: false,
          customerRimNo: null,
          isDeletable: true,
          customerRiskRatingId: Utils.randomDigits(),
          isManualEntry: true,
        ),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Removes a row from the internal ratings table at the specified index.
  Future<void> removeInternalTableRow(int? customerRiskRatingId) async {
    final internalRating = riskRating.internalRatings.firstWhere(
      (item) => item.customerRiskRatingId == customerRiskRatingId,
    );

    if (internalRating.customerRiskRatingId == customerRiskRatingId) {
      if (internalRating.rimWithNoEntity == true) {
        rimWithNoEntity.removeWhere(
          (e) => e == internalRating.customerRimNo,
        );
      }

      internalRating.isDeleted = true;
    }

    riskRating.internalRatings.removeWhere(
      (item) => item.customerRiskRatingId == customerRiskRatingId,
    );

    if (internalRating.isManualEntry != true) {
      await repository.saveRatings(
        customerRating: RiskRating.toJson(
          isFiFlow: false,
          internalRatings: [internalRating],
          externalRatings: riskRating.externalRatings ?? [],
          isClDown: !isCreditLensAvailable,
        ),
      );
    }

    if (!riskRating.internalRatings.any(
      (item) => item.isDeletable == true && item.isDeleted != true,
    )) {
      isCreditLensAvailable = true;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new row to the external ratings table if the last entry is valid.
  ///
  /// This asynchronous function performs the following:
  /// - Checks if the last entry in `externalRatings` has a `customerRimNo` of
  /// `-1`,
  ///   which indicates an incomplete or placeholder row. If so, it exits early.
  /// - If the last entry is valid, it emits a loading state for the external
  /// table.
  /// - Adds a new `ExternalRating` object with default values to the
  /// `externalRatings` list.
  /// - Introduces a short delay to simulate UI update timing.
  /// - Emits a loaded state to indicate the row has been added.
  Future<void> addExternalTableRow() async {
    if ((riskRating.externalRatings?.isNotEmpty ?? false) &&
        riskRating.externalRatings?.last.customerRimNo == -1) {
      return;
    } else {
      final int itemCount = (riskRating.externalRatings ?? []).length;
      initialExternalRatingPage = (itemCount / tableRow).ceil();
      riskRating.externalRatings?.add(
        ExternalRating(
          customerName: "",
          customerRimNo: -1,
          isDeleted: false,
          isDeletable: true,
        ),
      );
      rimNoController.text = ""; // clear if -1

      emit(state.copyWith(externalTableStatus: LoadingStatus.loaded));
    }
  }

  /// Removes a row from the external ratings table at the specified index.
  Future<void> removeExternalTableRow(int index) async {
    final externalRating = riskRating.externalRatings?[index];
    if (externalRating != null) {
      externalRating.isDeleted = true;
    }
    riskRating.externalRatings?.removeAt(index);
    await repository.saveRatings(
      customerRating: RiskRating.toJson(
        isFiFlow: false,
        internalRatings: riskRating.internalRatings,
        externalRatings: [externalRating ?? ExternalRating()],
        isClDown: !isCreditLensAvailable,
      ),
    );
    emit(state.copyWith(externalTableStatus: LoadingStatus.loaded));
  }

  bool isInternalDuplicate({required int? rim, int? entityId}) {
    return riskRating.internalRatings.any((e) {
      if (e.customerRimNo != null &&
          e.customerRimNo == rim &&
          e.entityId == entityId) {
        return true;
      } else {
        return false;
      }
    });
  }

  bool isInternalDuplicateonSave() {
    final Map hashMap = {};
    for (int i = 0; i < riskRating.internalRatings.length; i++) {
      hashMap["${riskRating.internalRatings[i].customerRimNo} $i"] =
          "${riskRating.internalRatings[i].entityId} $i";
    }
    hashMap;
    if (hasDuplicatePairs(hashMap)) {
      AlertManager().showFailureToast(
        "Entered Customer RIM and Entity Combination "
        "Already Exists. Please enter a valid RIM Number",
      );
      return true;
    }

    final List<int?> entities = riskRating.internalRatings
        .where((e) => e.isDeleted != true)
        .map((e) => e.entityId)
        .toList();

    final bool isEntityPresent = entities.contains(null);

    if (isEntityPresent && isCreditLensAvailable) {
      AlertManager().showFailureToast(
        "Please enter a valid Entity ID in Internal Rating",
      );
      return true;
    } else {
      return false;
    }
  }

  //Find duplicate in hashMap
  bool hasDuplicatePairs(Map<dynamic, dynamic> raw) {
    final RegExp reg =
        RegExp(r"^(\d+)\s+\d+$"); // captures the number before the last index

    int? parseAndStrip(dynamic x) {
      final String stripedString = x.toString().trim();
      final RegExpMatch? matchedRegEx = reg.firstMatch(stripedString);
      final String core = (matchedRegEx != null)
          ? matchedRegEx.group(1)!
          : stripedString; // if no match, keep as-is
      return int.tryParse(core); // expects numeric after stripping
    }

    final Set<String> seen = <String>{};
    for (final MapEntry<dynamic, dynamic> entry in raw.entries) {
      final int? keyParseStrip = parseAndStrip(entry.key);
      final int? valueParseStrip = parseAndStrip(entry.value);
      final String pair = "$keyParseStrip:$valueParseStrip";
      if (!seen.add(pair)) {
        // seen.add returns false if sig was already present
        return true; // duplicate (key,value) pair found
      }
    }
    return false; // no duplicates
  }

  bool isExternalDuplicate({required int? rim}) {
    final List<int?> rims =
        (riskRating.externalRatings ?? []).map((e) => e.customerRimNo).toList();

    final bool isRimPresent = rims.contains(rim);
    if (isRimPresent) {
      return true;
    } else {
      return false;
    }
  }

  /// Triggers a search for external rating RIM data.
  Future<void> searchExternalRatingRim(String rim, int i) async {
    try {
      final bool isDuplicate = isExternalDuplicate(rim: int.tryParse(rim));
      if (isDuplicate) {
        AlertManager().showFailureToast(
          "Entered Customer RIM Number Already "
          "Exists. Please enter a valid RIM Number",
        );
        return;
      }
      final Customer? customerDetails =
          await _customerRepository.searchUserDetails(rim, "", "", "");
      if (customerDetails == null) {
        throw "common.noUserFound".tr();
      }

      if (customerDetails.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw "common.noUserFoundClosedPartyStatus".tr();
      } else {
        riskRating.externalRatings?[i] = ExternalRating(
          isDeletable: true,
          customerRimNo: int.tryParse(customerDetails.id ?? ""),
          customerName: customerDetails.concatCustomerFullName,
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
    final List<int?> multiEntities = [];
    final List<int?> customerRims =
        updatedRiskRating.map((e) => e?.rimNo).toList();

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
      for (final InternalRating existingRating in riskRating.internalRatings) {
        final List<UpdatedRating?> updatedRatings =
            await repository.getUpdatedRatingDetails(
          entityId:
              existingRating.entityId == 0 ? null : existingRating.entityId,
          rimNo: existingRating.customerRimNo,
        );
        if (updatedRatings.any((e) => e?.isClDown == true)) {
          isCreditLensAvailable = false;
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        } else {
          isCreditLensAvailable = true;
        }
        updatedRiskRating.addAll(updatedRatings);
      }

      if (updatedRiskRating.isNotEmpty) {
        for (InternalRating internalRating in riskRating.internalRatings) {
          final List<int?> entities = updatedRiskRating
              .map(
                (e) => e?.rimNo == internalRating.customerRimNo
                    ? e?.entityId
                    : null,
              )
              .toList();

          for (final UpdatedRating? updatedRating in updatedRiskRating) {
            final bool entityCheck = (internalRating.entityId == 0 ||
                    internalRating.entityId == null)
                ? true
                : internalRating.entityId == updatedRating?.entityId;

            if ((internalRating.customerRimNo == updatedRating?.rimNo) &&
                updatedRating != null &&
                entityCheck) {
              internalRating = InternalRating().fromUpdatedRatings(
                internalRating,
                updatedRating,
                entities: internalRating.entityId != null ? [] : entities,
                isMultipleEntity: internalRating.entityId != null
                    ? false
                    : entities.length > 1,
              );
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
      final bool isNewRefNo = riskRating.internalRatings.any(
        (e) => e.customerRiskRatingId == 0 || e.customerRiskRatingId == null,
      );
      if (isNewRefNo) {
        await onRefreshPressed();
      }

      for (final InternalRating data in riskRating.internalRatings) {
        if (data.entityId == null &&
            (data.entities == null || (data.entities ?? []).isEmpty)) {
          rimWithNoEntity.add(data.customerRimNo);
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
      final List<Comment> comments =
          await CommonRepository.instance.getComments(
        CommentsType.riskRating,
        EntityIdentifier.strategyComments,
      );
      if (comments.isNotEmpty) {
        final List<Comment> filteredComments = comments
            .where(
              (comment) => comment.applicationRefNo ==
                  Globals.request?.applicationRefNo,
            )
            .toList()
          ..sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
        riskRating.comments = filteredComments.first.comment;
        internalRatingTextController.text =
            filteredComments.first.comment ?? "";
      }
      if (isFiFlow) {
        final List<Comment> externalComments =
            await CommonRepository.instance.getComments(
          CommentsType.externalRiskRatingFi,
          EntityIdentifier.strategyComments,
        );
        final List<Comment> filteredCommentsExternal = externalComments
            .where(
              (comment) => comment.applicationRefNo ==
                  Globals.request?.applicationRefNo,
            )
            .toList();
        if (filteredCommentsExternal.isNotEmpty) {
          filteredCommentsExternal
              .sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
          riskRating.externalComments = filteredCommentsExternal.first.comment;
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Helper to clean HTML tags and spaces
  Future<String> getCleanText(UnifiedEditorController controller) async {
    final rawHtml = await controller.getText();
    return rawHtml
        .replaceAll(RegExp("<[^>]*>"), "") // Remove HTML tags
        .replaceAll("&nbsp;", " ") // Handle non-breaking spaces
        .replaceAll("\u00A0", " ") // Replace non-breaking spaces
        .trim();
  }

  /// Saves the current risk rating data to the repository.
  ///
  /// Displays a success or error toast based on the result.
  Future<void> onSavePressed({bool isReadOnly = false}) async {
    try {
      isProposedFieldEditable = isProposedbyCreditEditables();
      debugPrint("isProposedFieldEditable $isProposedFieldEditable");
      //is proposed by credit in internal tble is editable
      if (isProposedFieldEditable) {
        final bool isEmpty = riskRating.internalRatings
            .any((value) => value.proposedByCredit?.isEmpty ?? true);
        if (isEmpty) {
          AlertManager()
              .showFailureToast("riskRating.emptyProposedByCredit".tr());
          return;
        }
        await repository.saveRatings(
          customerRating: RiskRating.toJson(
            isFiFlow: false,
            internalRatings: riskRating.internalRatings,
            externalRatings: riskRating.externalRatings ?? [],
            isClDown: !isCreditLensAvailable,
          ),
        );
        _nextRoute();
        AlertManager().showSuccessToast("riskRating.savedSuccefully".tr());
      }
      //if all fields are just read only
      if (isReadOnly) {
        _nextRoute();
        return;
      }
      //for Financial Inst. FLow
      if (isFiFlow) {
        if (formKey.currentState?.validate() ?? false) {
          formKey.currentState?.save();
          final bool hasInvalidRimExt = (riskRating.externalRatings ?? [])
              .any((rating) => rating.customerRimNo == -1);
          final bool hasInvalidRimInt = riskRating.internalRatings.any(
            (rating) =>
                rating.customerRimNo == -1 || rating.customerRimNo == null,
          );

          if (hasInvalidRimExt || hasInvalidRimInt) {
            AlertManager().showFailureToast("riskRating.emptyfeildRim".tr());
            return;
          }
          // Get raw HTML text from controllers
          final String internalCommentStr =
              await getCleanText(internalRatingControler);
          final String externalCommentStr =
              await getCleanText(externalRatingControler);

          final Comment internalComment = Comment.fromInputData(
            comment: internalCommentStr,
            type: CommentsType.riskRating,
            categoryId: ServerConstants.commentTypeId[CommentsType.riskRating],
          );

          final Comment externalComment = Comment.fromInputData(
            comment: externalCommentStr,
            type: CommentsType.riskRating,
            categoryId: ServerConstants
                .commentTypeId[CommentsType.externalRiskRatingFi],
          );

          await Future.wait([
            CommonRepository.instance.saveComment(internalComment),
            CommonRepository.instance.saveComment(externalComment),
            repository.saveRatings(
              customerRating: RiskRating.toJson(
                internalRatings: riskRating.internalRatings,
                externalRatings: riskRating.externalRatings ?? [],
                isClDown: !isCreditLensAvailable,
                isFiFlow: true,
              ),
            ),
          ]);
          // Remove draft once user explicitly saves the validated data
          // deleteDraft();
          AlertManager().showSuccessToast("riskRating.savedSuccefully".tr());
          _nextRoute();
          return;
        }
      }

      //if we have any duplicate entry in risk rating table
      if (isInternalDuplicateonSave()) {
        return;
      }

      // form validation
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        final bool hasInvalidRim = (riskRating.externalRatings ?? [])
            .any((rating) => rating.customerRimNo == -1);

        if (hasInvalidRim) {
          AlertManager().showFailureToast("riskRating.emptyfeildRim".tr());
          return;
        }

        // if (Utils.checkRole(UserRole.creditAnalyst) &&
        //     proposedByCredit.isEmpty) {
        //   AlertManager()
        //       .showFailureToast('riskRating.emptyProposedByCredit'.tr());
        //   return;
        // }

        final Comment comment = Comment.fromInputData(
          comment: riskRating.comments,
          type: CommentsType.riskRating,
          categoryId: ServerConstants.commentTypeId[CommentsType.riskRating],
        );

        await CommonRepository.instance.saveComment(comment);
        await repository.saveRatings(
          customerRating: RiskRating.toJson(
            isFiFlow: false,
            internalRatings: riskRating.internalRatings,
            externalRatings: riskRating.externalRatings ?? [],
            isClDown: !isCreditLensAvailable,
          ),
        );

        // Remove draft once user explicitly saves the validated data
        // deleteDraft();

        _nextRoute();
        AlertManager().showSuccessToast("riskRating.savedSuccefully".tr());
      }
    } catch (e) {
      AlertManager().showFailureToast("common.serverError".tr());
    }
  }

  /// Refreshes the risk rating and reference data.
  ///
  /// [from] determines whether to refresh internal (0) or external (1) data.
  Future<void> onRefreshPressed() async {
    emit(state.copyWith(refreshLoader: LoadingStatus.loading));
    await updateRatingsFromCL();
    emit(
      state.copyWith(
        refreshLoader: LoadingStatus.loaded,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  void emitInternalRating() {
    emit(RiskRatingState(loaderStatus: LoadingStatus.loaded));
  }
}
