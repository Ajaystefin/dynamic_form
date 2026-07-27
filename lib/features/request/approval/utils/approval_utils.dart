import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Utility methods for approval screen access and visibility checks.
class ApprovalUtils {
  /// Password mode reference values used in approval flows.
  static List<Reference> passwordModeReference = [];

  /// Returns whether the queries tab should be visible for the current role.
  static bool isQueriesTabVisible() {
    return [
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.relationshipManager],
    ].contains(Globals.user?.currentRole?.roleId);
  }

  /// Checks whether the current priority role has access to the given route.
  static bool priorityRoleAccess(String route) {
    if (Globals.applicationDetails == null) {
      return false;
    }
    if (Globals.applicationDetails?.applicationLifeCycle == null) {
      return false;
    }
    final int priorityRole =
        Globals.applicationDetails?.applicationLifeCycle?.priorityRole ?? 0;
    logger.i("priorityRole $priorityRole");
    final bool hasAccess =
        roleRouteAcess[priorityRole]?.contains(route) ?? false;
    return hasAccess;
  }

  /// Maps role ids to right constants accessible by priority roles.
  static Map<int?, List<String>> roleRouteAcess = {
    ServerConstants.userRoleId[UserRole.creditAnalyst]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB1]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelC]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.creditCommitteeProxy]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.boardDirectorProxy]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.documentationChecker]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
      RightConstants.proposedFacilities,
      RightConstants.requestForFol,
    ],
    ServerConstants.userRoleId[UserRole.documentationMaker]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
      RightConstants.proposedFacilities,
      RightConstants.requestForFol,
    ],
    ServerConstants.userRoleId[UserRole.ccuChecker]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
      RightConstants.requestForFol,
      RightConstants.proposedFacilities,
      RightConstants.requestForLimitRelease,
    ],
    ServerConstants.userRoleId[UserRole.ccuMaker]: [
      RightConstants.managementComments,
      RightConstants.creditAssessment,
      RightConstants.requestForFol,
      RightConstants.proposedFacilities,
      RightConstants.requestForLimitRelease,
    ],
  };

  /// Checks whether the current priority role has access to the given route.
  static bool checkPriorityRoleAccess(String route) {
    if (Globals.applicationDetails == null) {
      return false;
    }
    if (Globals.applicationDetails?.applicationLifeCycle == null) {
      return false;
    }
    final int priorityRole =
        Globals.applicationDetails?.applicationLifeCycle?.priorityRole ?? 0;
    final bool hasAccess =
        userRoleRouteAcess[priorityRole]?.contains(route) ?? false;
    return hasAccess;
  }

  /// Maps role ids to route constants accessible by priority roles.
  static Map<int?, List<String>> userRoleRouteAcess = {
    ServerConstants.userRoleId[UserRole.creditAnalyst]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB1]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelC]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.creditCommitteeProxy]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.boardDirectorProxy]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval]: [
      Routes.managementComments,
      Routes.creditAssessment,
    ],
    ServerConstants.userRoleId[UserRole.documentationChecker]: [
      Routes.managementComments,
      Routes.creditAssessment,
      Routes.requestForFOL,
    ],
    ServerConstants.userRoleId[UserRole.documentationMaker]: [
      Routes.managementComments,
      Routes.creditAssessment,
      Routes.requestForFOL,
    ],
    ServerConstants.userRoleId[UserRole.ccuChecker]: [
      Routes.managementComments,
      Routes.creditAssessment,
      Routes.requestForFOL,
      Routes.requestForLimitRelease,
    ],
    ServerConstants.userRoleId[UserRole.ccuMaker]: [
      Routes.managementComments,
      Routes.creditAssessment,
      Routes.requestForFOL,
      Routes.requestForLimitRelease,
    ],
  };

  /// Checks whether the current application belongs to the given business segment.
  static bool checkApplicationBusinessSegment(BusinessSegment segment) {
    return Globals.applicationDetails?.appBusinessSegment ==
        ServerConstants.businessSegmentType[segment];
  }

  /// Checks master accessibility for a given route based on role, status,
  /// application type, and business segment.
  static bool checkMasterAccessibilityForRoute(
    String route, {
    bool forReadOnly = false,
  }) {
    if (!forReadOnly && !Utils.checkRole(UserRole.creditAnalyst)) {
      // check where the priority user role has the access to the route
      final bool hasAccess = checkPriorityRoleAccess(route);
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
            ].contains(Globals.user?.currentRole?.roleId) &&
            Utils.isGroupApplication() &&
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          final bool status = Globals.checkCurrentStatus([
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          final bool status = Globals.checkCurrentStatus([
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          final bool status = Globals.checkCurrentStatus([
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          final bool status = Globals.checkCurrentStatus([
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          final bool status = Globals.checkCurrentStatus([
                RequestStatus.fitToLendCompletedPendingLimitRelease,
                RequestStatus.pendingLimitRelease,
                RequestStatus.folNotRequired,
              ]) &&
              !Globals.checkAppSubStatus(
                ServerConstants
                        .applicationSubType[ApplicationSubType.riskRating] ??
                    "",
              );
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          final bool status = Globals.checkCurrentStatus(
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
        ].contains(Globals.user?.currentRole?.roleId)) {
          // Visible only for group type application in FI Flow
          final bool status = ApprovalUtils.checkApplicationBusinessSegment(
                BusinessSegment.financialInstitution,
              ) &&
              Utils.isGroupApplication();
          return status;
        } else {
          return false;
        }

      case Routes.creditAssessmentFI:
        if ([
          ServerConstants.userRoleId[UserRole.creditAnalyst],
        ].contains(Globals.user?.currentRole?.roleId)) {
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
}
