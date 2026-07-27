import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

/// View model that manages CCSYS request information state and actions.
class RequestInformationViewModel extends SafeCubit<RequestInformationState> {
  /// Creates a [RequestInformationViewModel] with initial loading state.
  RequestInformationViewModel()
      : super(RequestInformationState(loaderStatus: LoadingStatus.loading));

  /// Application details used by the request information form.
  ApplicationDetails? applicationDetails = ApplicationDetails();

  /// Repository used for CCSYS request information API operations.
  late CcsysRepository repository;

  /// Repository used for customer-related API operations.
  late CustomerRepository repositoryCustomer;

  /// Focus node used by the request information form.
  final FocusNode formFocusNode = FocusNode();

  /// Form key used to validate and save request information form data.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// List of application type reference values.
  List<Reference> applicationType = [];

  /// Selected request type reference.
  Reference? selectedRequestType;

  /// Selected business segment reference.
  Reference? selectedBusinessSegment;

  /// Selected application type reference.
  Reference? selectedApplicationType;

  /// Current request status.
  int? status;

  /// Indicates whether the request is a new request.
  bool isNewRequest = false; //Default false for create request.

  /// Indicates whether an API error occurred.
  bool isApiError = false; //Default false.

  /// Indicates whether an existing application reference number is available.
  bool isExisitngAppRefNo = false; //Default false.

  /// Selected last approved application reference number.
  String? selectedLastApprovedAppRefNum;

  /// Approved date of the current application.
  String? approvedDate;

  /// Last approved application date.
  String? lastApprovedAppDate;

  /// Reference data grouped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  /// Indicates whether the current page can be edited.
  bool canEdit = false;

  // State

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Initializes edit rights and page mode for the given request.
  void initRightsAndMode(Request request) {
    final bool rights = request.ccsysCanEditReadOnly ?? true;
    pageMode =
        AuthRepository.getPageMode(RightConstants.ccsysRequestInformation);
    if (!rights) {
      canEdit = false;
      return;
    }
    canEdit = pageMode == PageMode.edit;
  }

  // --- Lifecycle ---

  /// Initializes repositories, selected values, rights, and request details.
  Future<void> init(BuildContext context) async {
    repository = CcsysRepository.instance;
    repositoryCustomer = CustomerRepository.instance;

    //from previous screen
    selectedApplicationType =
        Globals.request?.applicationType ?? Reference(name: "");
    selectedRequestType = Globals.request?.requestType ?? Reference(name: "");
    selectedBusinessSegment =
        Globals.request?.businessSegment ?? Reference(name: "");

    isNewRequest = Globals.request?.isCreateRequest ?? false;
    canEdit = Globals.request?.ccsysCanEditReadOnly ?? true;
    initRightsAndMode(Globals.request ?? Request());

    try {
      await Future.wait([
        getReferenceDatas(),
        getApplicationDetails(),
      ]);

      isApiError = false;
    } on Object catch (e) {
      isApiError = true;
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches reference data required for the request information screen.
  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.yesNoNa,
        ReferenceDataKeys.ccsysCountryList,
        ReferenceDataKeys.ccsysEmirateList,
        ReferenceDataKeys.ccsysGender,
        ReferenceDataKeys.ccsysPsLegalStatus,
        ReferenceDataKeys.ccsysPsResidence,
        ReferenceDataKeys.ccsysPsType,
        ReferenceDataKeys.yesNoNa,
      ]);
      applicationType = referenceData[ReferenceDataKeys.applicationType] ?? [];
    } on Object catch (e) {
      e.toString();
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Handles application type selection.
  void onSelectApplicationType(Reference? applicationType) {
    // request.applicationType = applicationType;
  }

  /// Returns filtered application type items based on selected segment and type.
  List<Reference> applicationTypeItems() {
    if (selectedBusinessSegment?.id ==
        ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution]) {
      return applicationType
          .where(
            (element) =>
                element.reference4 == selectedRequestType?.reference1 &&
                (element.reference3 ?? "")
                    .contains(ServerConstants.financialCode),
          )
          .toList();
    }
    return applicationType
        .where(
          (element) =>
              element.reference4 == selectedRequestType?.reference1 &&
              (element.reference3 ?? "")
                  .contains(ServerConstants.corperateCode),
        )
        .toList();
  }

  /// Fetch last approved application for a RIM and map into `request`.
  /// Keeps your `Request` model unchanged; performs safe type conversions.
  Future<void> getApplicationDetails() async {
    try {
      if (isNewRequest) {
        applicationDetails = await repository.getLastApprovedApplication() ??
            ApplicationDetails();
        selectedLastApprovedAppRefNum = applicationDetails?.applicationRefNo;
        lastApprovedAppDate = applicationDetails?.approvedDate;
        approvedDate = applicationDetails?.approvedDate;
      } else {
        applicationDetails = await repository.getApplicationDetails(); // use
        selectedLastApprovedAppRefNum =
            applicationDetails?.lastApprovedAppRefNum;
        approvedDate = applicationDetails?.approvedDate;
        // status = applicationDetails?.status;
        isExisitngAppRefNo =
            applicationDetails?.applicationRefNo?.trim().isNotEmpty ?? false;
        Globals.request?.isCreateRequest = false;
        isNewRequest = Globals.request?.isCreateRequest ?? false;
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      // rethrow;
      logger.i(e.toString());
    }
  }

  /// Saves request information and shows the application reference confirmation.
  Future<void> onSavePressed(BuildContext context) async {
    try {
      formKey.currentState?.save();
      final Reference appType = applicationType.firstWhere(
        (e) => e.id == ServerConstants.ccsysAppReferenceId,
        orElse: () => Reference(
          id: ServerConstants.ccsysAppReferenceId,
          name: ServerConstants.ccsysAppReferenceName,
          reference1: ServerConstants.ccsysAppReference1,
          reference2: ServerConstants.ccsysAppReference2,
          reference3: ServerConstants.ccsysAppReference3,
          reference4: ServerConstants.ccsysAppReference4,
          reference5: ServerConstants.ccsysAppReference5,
        ),
      );
      final isCreateRequest = Globals.request?.isCreateRequest ?? true;
      logger.i("lastApprovedappdate1 ${applicationDetails?.status}");

      applicationDetails ??= ApplicationDetails();
      applicationDetails
        ?..applicationRefNo =
            isCreateRequest ? null : applicationDetails?.applicationRefNo
        ..instanceId = isCreateRequest ? null : applicationDetails?.instanceId
        ..lastApprovedAppRefNum = selectedLastApprovedAppRefNum
        ..approvedDate = applicationDetails?.approvedDate
        ..appBusinessSegment = Globals.request?.businessSegment?.name ?? ""
        ..subType = Globals.request?.applicationType?.reference1 ??
            appType.reference1 ??
            ""
        ..requestType =
            Globals.request?.requestType?.reference1 ?? appType.reference2 ?? ""
        ..businessSegment = applicationDetails?.businessSegment ??
            Globals.request?.businessSegment?.name
        ..branch = applicationDetails?.branch ??
            Globals.request?.branch ??
            ServerConstants.defaultBranch
        ..region = applicationDetails?.region ??
            Globals.user?.regions?.first ??
            ServerConstants.defaultRegion
        ..lastApprovedAppDate = applicationDetails?.approvedDate
        // ..groupID = Globals.request?.groupId ?? 0
        // ..groupName = Globals.request?.groupName
        ..rimNo = Globals.request?.customerRimNo
        ..customerName = Globals.request?.customerName
        ..enabledForView = applicationDetails?.enabledForView ?? false
        ..status = applicationDetails?.status;

      // logger.i(applicationDetails?.toString());
      // logger.i(applicationDetails?.toSaveApplicationJson());
      logger.i("lastApprovedappdate2 ${applicationDetails?.approvedDate}");

      final String resultAppRefNo =
          await repository.saveApplicationInformation(applicationDetails);

      // logger.i(resultAppRefNo);
      if (resultAppRefNo.isNotEmpty) {
        Globals.request?.applicationRefNo = resultAppRefNo;
        Globals.request?.isCreateRequest = false;

        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

        if (context.mounted) {
          showDialogSuccessAppRefNo(
            context,
            appRefNo: resultAppRefNo,
            isNew: isExisitngAppRefNo ? null : true,
            otherRolesCheck: otherRolesCheck(),
            otherRolesCheckCC: otherRolesCheck(),
          );
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      // moveToNext();
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }

    //  try {
    //   router.go(Routes.ccsysCustomerInformation);
    // } on Object catch (_) {
    //   // swallow or log
    // }
  }

  /// Checks whether the user has applicable business roles.
  bool otherRolesCheck() {
    return Utils.checkRoles([
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.relationshipManagerBussiness,
      UserRole.segmentHeadBusiness,
    ]);
  }

  /// Checks whether the user has applicable credit control roles.
  bool otherRolesCheckCC() {
    return Utils.checkRoles([
      UserRole.ccuChecker,
    ]);
  }

  /// Shows the application reference number success dialog or toast.
  void showDialogSuccessAppRefNo(
    BuildContext context, {
    String? appRefNo,
    bool? isNew,
    bool? otherRolesCheck,
    bool? otherRolesCheckCC,
  }) {
    if (isNew != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogHelper.showCustomDialog(
          barrierDismissible: false,
          onClosePressed: () {
            context.pop();
            moveToNext();
          },
          width: Scale.scaleHorizontally(350),
          context: context,
          title: "requestInformation.requestInformation.confirmation".tr(),
          content: CustomSelectableText(
            text: isNew
                ? "requestInformation.requestInformation.informationMsg".tr() +
                    (appRefNo ?? "")
                : (otherRolesCheck ?? false)
                    ? "requestInformation.requestInformation.informationMsgRole"
                        .tr(
                        namedArgs: {
                          "refno": appRefNo ?? "",
                          "userid":
                              Globals.user?.userDetailId?.toString() ?? "",
                        },
                      )
                    : (otherRolesCheckCC ?? false)
                        ? "requestInformation.requestInformation."
                                "informationMsgRoleCC"
                            .tr(
                            namedArgs: {
                              "refno": appRefNo ?? "",
                            },
                          )
                        : "",
          ),
          actions: [
            CustomButton(
              label: "requestInformation.requestInformation.okay".tr(),
              onPressed: () {
                context.pop();
                moveToNext();
              },
            ),
          ],
        );
      });
    } else {
      AlertManager().showSuccessToast("common.saveSuccess".tr());
      moveToNext();
    }
  }

  /// Navigates to the CCSYS customer information screen.
  void moveToNext() {
    router.go(Routes.ccsysCustomerInformation);
  }
}
