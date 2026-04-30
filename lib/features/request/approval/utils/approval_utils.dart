import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ApprovalUtils {
  static List<Reference> passwordModeReference = [];

  static bool priorityRoleAccess(String route) {
    if (Globals.applicationDetails == null) {
      return false;
    }
    if (Globals.applicationDetails?.applicationLifeCycle == null) {
      return false;
    }
    final int priorityRole =
        Globals.applicationDetails?.applicationLifeCycle?.priorityRole ?? 0;
    debugPrint("priorityRole $priorityRole");
    final bool hasAccess =
        roleRouteAcess[priorityRole]?.contains(route) ?? false;
    return hasAccess;
  }

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

  static bool checkApplicationBusinessSegment(BusinessSegment segment) {
    return Globals.applicationDetails?.appBusinessSegment ==
        ServerConstants.businessSegmentType[segment];
  }
}
