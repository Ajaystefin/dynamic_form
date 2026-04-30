import "package:flutter/material.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";

class Globals {
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static DeviceScreenType? deviceScreenType;
  static User? user;
  static Request? request = Request();
  static String currentRoute = "/";
  static String previousRoute = "/";
  static String sessionID = "";
  static List<Option>? dynamicFormCurrencyCodes = [];
  static List<Option>? dynamicFormEconomicZones = [];

  static Customer? selectedCustomer; //for remarks

  /// Callback set by the currently active screen's ViewModel to save its draft.
  /// Invoked fire-and-forget (not awaited) before navigation and logout.
  static Future<void> Function()? onAutoSave;

  /// Synchronous-safe autosave callback used exclusively by browser unload
  /// events (tab/window close, page refresh).
  ///
  /// This callback is triggered by [BrowserUnloadService] and must use
  /// `navigator.sendBeacon` (via [DraftRepository.saveDraftBeacon]) so the
  /// HTTP request survives page termination.
  static void Function()? onAutoSaveSync;

  static Customer? requestCustomerInfo; // for request information

  static List<Map<String?, int?>> requestStatus = [];
  static List<Map<String?, int?>> userAction = [];
  static List<Map<String?, int?>> folTypeAction = [];
  static List<Map<String, String>> superUserRoles = [];
  static List<Map<String, int>> superBpmRolesId = [];
  static List<String> superBpmRoles = [];
  static List<Map<String, int>> superRolesId = [];
  static ApplicationDetails? applicationDetails;
  static bool isAllReadOnly = Utils.checkIfAppReadOnly();
  static bool isInitiated = checkIsInitiated();
  static List<Reference> recommendReferences = [];
  static List<Reference> returnReferences = [];
  static List<Reference> delegationReferences = [];
  static List<Reference> approvalReferences = [];
  static List<Reference> documentStagesReferences = [];
  static List<String> reasonForDecline = [];
  static List<Reference> worklistStatusReferences = [];
  static List<Reference> limitReleaseStagesReferences = [];

  static bool checkIsInitiated() {
    if (applicationDetails == null) {
      // debugPrint("Null in app");
      return false;
    }
    debugPrint("createdBy : ${Globals.user!.id}");
    debugPrint(
      "createdBy : ${applicationDetails!.createdBy == Globals.user!.id}",
    );
    // not assigend to user & not created by user
    final bool isInitiated =
        (applicationDetails!.createdBy == Globals.user!.id);
    // &&    (Globals.user!.currentRole!.roleId == ServerConstants.roId);
    return isInitiated;
  }

  static bool checkCanEdit(String rights) {
    return Globals.user?.currentRole?.rights?[rights] == AccessType.edit;
  }

  static bool checkGroupAccess() {
    if (applicationDetails == null) {
      return false;
    }
    final bool isVisible = applicationDetails?.groupID != 0 &&
        applicationDetails?.groupApplication == true;
    return isVisible;
  }

  static bool checkLifeCycleStatus(String status) {
    if (applicationDetails == null ||
        applicationDetails?.applicationLifeCycle == null) {
      return false;
    }
    return applicationDetails?.applicationLifeCycle?.status == status;
  }

  static bool checkCurrentStatus(List<RequestStatus> statusList) {
    if (applicationDetails == null && statusList.isEmpty) {
      debugPrint("applicationDetails is null or statusList");
      return false;
    }
    if (requestStatus.isEmpty) {
      return false;
    }
    bool isCurrent = false;

    isCurrent = statusList.any((status) {
      final String title = ServerConstants.requestStatusTitle[status] ?? "";

      final int id = requestStatus.firstWhereOrNull(
            (map) => map.containsKey(title),
          )?[title] ??
          0;
      return applicationDetails?.status == id;
    });

    return isCurrent;
  }

  static bool isQueriesTabVisible() {
    return [
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.relationshipManager],
    ].contains(user?.currentRole?.roleId);
  }

  static bool checkAppSubStatus(String type) {
    if (applicationDetails == null) {
      return false;
    }
    return applicationDetails?.subType == type;
  }

  static bool checkMasterAccessibilityForRoute(
    String route, {
    bool forReadOnly = false,
  }) {
    if (!forReadOnly && !Utils.checkRole(UserRole.creditAnalyst)) {
      // check where the priority user role has the access to the route
      final bool hasAccess = ApprovalUtils.checkPriorityRoleAccess(route);
      if (hasAccess) {
        return hasAccess;
      }
    }

    switch (route) {
      case Routes.groupSummary:
        if ([
              ServerConstants.userRoleId[UserRole.relationshipOfficer],
              ServerConstants.userRoleId[UserRole.relationshipManager],
              ServerConstants.userRoleId[UserRole.businessUnitHead],
              ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
              ServerConstants.userRoleId[UserRole.commercialAreaManager],
              ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
              ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
              ServerConstants.userRoleId[UserRole.creditCordinator],
              ServerConstants.userRoleId[UserRole.creditAnalyst],
              ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
              ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
              ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
              ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
              ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
              ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
              ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
              ServerConstants.userRoleId[UserRole.boardDirectorProxy],
              ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
              ServerConstants.userRoleId[UserRole.documentationChecker],
              ServerConstants.userRoleId[UserRole.ccuChecker],
            ].contains(user?.currentRole?.roleId) &&
            checkGroupAccess() &&
            !ApprovalUtils.checkApplicationBusinessSegment(
              BusinessSegment.financialInstitution,
            )) {
          return true;
        } else {
          return false;
        }

      case Routes.proposedFacilities:
        if ([
          ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ServerConstants.userRoleId[UserRole.relationshipManager],
          ServerConstants.userRoleId[UserRole.businessUnitHead],
          ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
          ServerConstants.userRoleId[UserRole.commercialAreaManager],
          ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
          ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
          ServerConstants.userRoleId[UserRole.creditCordinator],
          ServerConstants.userRoleId[UserRole.creditAnalyst],
          ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
          ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
          ServerConstants.userRoleId[UserRole.boardDirectorProxy],
          ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
          ServerConstants.userRoleId[UserRole.documentationChecker],
          ServerConstants.userRoleId[UserRole.documentationMaker],
          ServerConstants.userRoleId[UserRole.ccuChecker],
          ServerConstants.userRoleId[UserRole.ccuMaker],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = checkCurrentStatus([
            RequestStatus.initiated,
            RequestStatus.pendingForApproval,
            RequestStatus.declined,
            RequestStatus.approved,
            RequestStatus.pendingFolIssuance,
            RequestStatus.completed,
            RequestStatus.folNotRequired,
            RequestStatus.pendingLimitRelease,
            RequestStatus.folIssuedPendingSignOff,
            RequestStatus.folSignOffCompletedPendingFitToLend,
            RequestStatus.fitToLendCompletedPendingLimitRelease,
          ]);
          return status;
        } else {
          return false;
        }

      case Routes.managementComments:
        if ([
          ServerConstants.userRoleId[UserRole.creditAnalyst],
          ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
          ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
          ServerConstants.userRoleId[UserRole.boardDirectorProxy],
          ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
          ServerConstants.userRoleId[UserRole.documentationChecker],
          ServerConstants.userRoleId[UserRole.ccuChecker],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = checkCurrentStatus([
            RequestStatus.initiated,
            RequestStatus.pendingForApproval,
            RequestStatus.declined,
            RequestStatus.approved,
            RequestStatus.pendingFolIssuance,
          ]);
          return status;
        } else {
          return false;
        }

      case Routes.creditAssessment:
        if ([
          ServerConstants.userRoleId[UserRole.creditAnalyst],
          ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
          ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
          ServerConstants.userRoleId[UserRole.boardDirectorProxy],
          ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
          ServerConstants.userRoleId[UserRole.documentationChecker],
          ServerConstants.userRoleId[UserRole.ccuChecker],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = checkCurrentStatus([
                RequestStatus.initiated,
                RequestStatus.pendingForApproval,
                RequestStatus.declined,
                RequestStatus.approved,
                RequestStatus.pendingFolIssuance,
              ]) &&
              !Utils.checkApplicationBusinessSegment(
                BusinessSegment.financialInstitution,
              );
          return status;
        } else {
          return false;
        }

      case Routes.requestForFOL:
        // if (AuthRepository.hasRight(RightConstants.requestForFol))
        if ([
          ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ServerConstants.userRoleId[UserRole.relationshipManager],
          ServerConstants.userRoleId[UserRole.documentationChecker],
          ServerConstants.userRoleId[UserRole.documentationMaker],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = checkCurrentStatus([
            RequestStatus.pendingFolIssuance,
            RequestStatus.folIssuedPendingSignOff,
            RequestStatus.folSignOffCompletedPendingFitToLend,
          ]);
          return status;
        } else {
          return false;
        }

      case Routes.requestForLimitRelease:
        // if (AuthRepository.hasRight(RightConstants.requestForLimitRelease))
        if ([
          ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ServerConstants.userRoleId[UserRole.relationshipManager],
          ServerConstants.userRoleId[UserRole.documentationChecker],
          ServerConstants.userRoleId[UserRole.ccuChecker],
          ServerConstants.userRoleId[UserRole.ccuMaker],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = checkCurrentStatus([
                RequestStatus.fitToLendCompletedPendingLimitRelease,
                RequestStatus.pendingLimitRelease,
                RequestStatus.folNotRequired,
              ]) &&
              !(checkAppSubStatus(
                ServerConstants
                        .applicationSubType[ApplicationSubType.riskRating] ??
                    "",
              ));
          return status;
        } else {
          return false;
        }

      case Routes.requestForClosure:
        if ([
          ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ServerConstants.userRoleId[UserRole.relationshipManager],
          ServerConstants.userRoleId[UserRole.creditCordinator],
          ServerConstants.userRoleId[UserRole.creditAnalyst],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = checkCurrentStatus(
            [RequestStatus.approved, RequestStatus.completed],
          );
          return status;
        } else {
          return false;
        }

      case Routes.countrySummary:
        if ([
          ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ServerConstants.userRoleId[UserRole.relationshipManager],
          ServerConstants.userRoleId[UserRole.businessUnitHead],
          ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
          ServerConstants.userRoleId[UserRole.commercialAreaManager],
          ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
          ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
          ServerConstants.userRoleId[UserRole.creditCordinator],
          ServerConstants.userRoleId[UserRole.creditAnalyst],
          ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
          ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
          ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
          ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
          ServerConstants.userRoleId[UserRole.boardDirectorProxy],
          ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
          ServerConstants.userRoleId[UserRole.documentationChecker],
          ServerConstants.userRoleId[UserRole.ccuChecker],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = ApprovalUtils.checkApplicationBusinessSegment(
            BusinessSegment.financialInstitution,
          );
          return status;
        } else {
          return false;
        }

      case Routes.creditAssessmentFI:
        if ([
          ServerConstants.userRoleId[UserRole.creditAnalyst],
        ].contains(user?.currentRole?.roleId)) {
          final bool status = Utils.checkApplicationBusinessSegment(
            BusinessSegment.financialInstitution,
          );
          return status;
        } else {
          return false;
        }
    }

    return true;
  }

  static bool hasRight(String? right) {
    if (Globals.user == null) return false;
    return Globals.user?.currentRole?.rights?[right] == AccessType.view ||
        Globals.user?.currentRole?.rights?[right] == AccessType.edit;
  }

  static bool checkVisibility({
    List<RequestStatus> status = const [],
    String? right,
  }) {
    bool access = false;
    access = checkCurrentStatus(status);
    if (right != null) {
      access = hasRight(right) && access;
    }
    return access;
  }

  static void cleanGlobalCache() {
    request = Request();
    applicationDetails = null;
    selectedCustomer = null;
    onAutoSave = null;
    onAutoSaveSync = null;
    requestCustomerInfo = null;
  }
}
