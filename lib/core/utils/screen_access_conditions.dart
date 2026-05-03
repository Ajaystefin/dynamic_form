import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/application_details.dart";

/// Centralized access condition registry for all screens.
///
/// Called by `AuthRepository._applyConditions` once per application open.
///
/// To register a condition for a screen, add a `case` for its [RightConstants]
/// key inside [resolveAccess] and return the [AccessType] that should apply:
///
/// | Return value        | Effect
/// |
/// |---------------------|-----------------------------------------------------
/// | `serverGranted`     | No change — server's decision stands (default)
/// |
/// | `AccessType.view`   | Downgrade to read-only (`canEdit = false`)
/// |
/// | `AccessType.none`   | Fully hidden — `hasRight()` returns false,
/// |
/// |                     | side menu item disappears
/// |
///
/// Screens with no explicit case fall through to `default`.
class ScreenAccessConditions {
  ScreenAccessConditions._(); // static-only

  // ---------------------------------------------------------------------------
  // Per-batch read-only cache
  // ---------------------------------------------------------------------------

  /// Cached result of [_checkIfReadOnly] for the current [_applyConditions]
  /// batch.
  ///
  /// The value does not change between iterations of the loop (it depends only
  /// on [Globals.applicationDetails] and the current user, both of which are
  /// fixed for the entire batch). Recomputing it for every [RightConstants] key
  /// is therefore redundant.
  ///
  /// Call [invalidateCache] once before starting a new batch to clear this.
  /// `null` means the value has not yet been computed for the current batch.
  static bool? _cachedIsReadOnly;

  /// Clears the cached read-only result so the next [resolveAccess] call
  /// recomputes it from [Globals] state.
  ///
  /// Must be called by [AuthRepository._applyConditions] **before** iterating
  /// the rights map — once per application open.
  static void invalidateCache() {
    _cachedIsReadOnly = null;
  }

  /// Resolves the effective [AccessType] for the given [rightKey] screen,
  /// taking the server-granted access as a starting point.
  ///
  /// [rightKey]      — the [RightConstants] key identifying the screen.
  /// [serverGranted] — the [AccessType] the server originally assigned.
  ///
  /// Rules:
  ///   - Return [serverGranted] to keep the server's decision unchanged.
  ///   - Return [AccessType.view] to make the screen read-only.
  ///   - Return [AccessType.none] to fully block and hide the screen.
  ///   - Never return a type with MORE privilege than [serverGranted];
  ///     [_applyConditions] enforces this as a safety net.
  static AccessType resolveAccess(String rightKey, AccessType serverGranted) {
    switch (rightKey) {
      // -----------------------------------------------------------------------
      // Screen-specific conditions override the default.
      // -----------------------------------------------------------------------

      case RightConstants.documentationCertification:
        // Not in any relevant status → fully hidden (side menu + navigation).
        if (!Utils.inDocumentationQueue()) {
          return AccessType.none;
        }
        // In visible statuses but not editable → read-only.
        if (!Utils.checkRequestStatuses([
          RequestStatus.pendingFolIssuance,
          RequestStatus.folIssuedPendingSignOff,
          RequestStatus.folSignOffCompletedPendingFitToLend,
        ])) {
          return AccessType.view;
        }
        // In editable statuses → keep whatever the server granted.
        return serverGranted;

      case RightConstants.creditControlTeamCertification:
        // Not in any relevant status → fully hidden.
        if (!Utils.inCreditControlQueue()) {
          return AccessType.none;
        }
        // Visible but not editable (e.g. completed) → read-only.
        if (!Utils.checkRequestStatuses([
          RequestStatus.fitToLendCompletedPendingLimitRelease,
          RequestStatus.pendingLimitRelease,
          RequestStatus.folNotRequired,
        ])) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.groupSummary:
        // Visible only if it is group type application
        if (Globals.checkGroupAccess() &&
            !Utils.checkApplicationBusinessSegment(
              BusinessSegment.financialInstitution,
            )) {
          return AccessType.view;
        }
        // Not Visible for FI flow
        if (Utils.checkApplicationBusinessSegment(
          BusinessSegment.financialInstitution,
        )) {
          return AccessType.none;
        }
        return serverGranted;

      case RightConstants.managementComments:
        // [priorityRole] is used in approval such that if the application is
        // returned from the higher roles,
        // the section must be visible to the roles which are under the higher
        // roles
        final bool hasAccess =
            ApprovalUtils.priorityRoleAccess(RightConstants.managementComments);
        if (hasAccess) {
          return AccessType.view;
        }
        // Access to the specific roles
        final List<UserRole> userRoleList = [
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
          UserRole.documentationChecker,
          UserRole.ccuChecker,
        ];
        // Access for specific application status
        if (Utils.checkRequestStatuses([
              RequestStatus.initiated,
              RequestStatus.pendingForApproval,
            ]) &&
            Utils.checkRoles(userRoleList)) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.proposedFacilities:
        // Access to the specific roles
        final List<UserRole> userRoleList = [
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.businessUnitHead,
          UserRole.teamLeaderBusiness,
          UserRole.commercialAreaManager,
          UserRole.relationshipManagerBussiness,
          UserRole.segmentHeadBusiness,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
          UserRole.documentationChecker,
          UserRole.ccuChecker,
        ];
        // Access for specific application status
        if (Utils.checkRequestStatuses([
              RequestStatus.initiated,
              RequestStatus.pendingForApproval,
            ]) &&
            Utils.checkRoles(userRoleList)) {
          return AccessType.view;
        }

        return serverGranted;

      case RightConstants.creditAssessment:
        // [priorityRole] is used in approval such that if the application is
        // returned from the higher roles,
        // the section must be visible to the roles which are under the higher
        // roles
        final bool hasAccess =
            ApprovalUtils.priorityRoleAccess(RightConstants.creditAssessment);
        if (hasAccess) {
          return AccessType.view;
        }
        // Only visible for specific roles
        final List<UserRole> userRoleList = [
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
          UserRole.documentationChecker,
          UserRole.ccuChecker,
        ];
        // Access for specific application status
        if (Utils.checkRequestStatuses([
              RequestStatus.initiated,
              RequestStatus.pendingForApproval,
            ]) &&
            Utils.checkRoles(userRoleList)) {
          return AccessType.view;
        }

        return serverGranted;

      case RightConstants.comments:
        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
        ])) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.queriesResponses:
        // Only visible for specific roles
        final List<UserRole> userRoleList = [
          UserRole.creditAnalyst,
          UserRole.relationshipManager,
        ];
        // Access for specific application status
        if (Utils.checkRequestStatuses([
              RequestStatus.initiated,
              RequestStatus.pendingForApproval,
            ]) &&
            Utils.checkRoles(userRoleList)) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.recommendationCurrentApproval:
        // Access for specific application status
        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
        ])) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.groupPosition:
        // Access for specific application status
        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
        ])) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.limitCaps:
        // Access for specific application status
        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
        ])) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.guarantorsExposure:
        // Access for specific application status
        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
        ])) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.requestForFol:
        // Applicable for Approval Documentation Flow
        // [priorityRole] is used in approval such that if the application is
        // returned from the higher roles,
        // the section must be visible to the roles which are under the higher
        // roles
        final bool hasAccess =
            ApprovalUtils.priorityRoleAccess(RightConstants.requestForFol);
        if (hasAccess) {
          return AccessType.view;
        }
        // Only visible for specific roles
        final List<UserRole> userRoleList = [
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ];
        // Access for specific application status
        if (Utils.checkRequestStatuses([
              RequestStatus.pendingFolIssuance,
              RequestStatus.folIssuedPendingSignOff,
              RequestStatus.folSignOffCompletedPendingFitToLend,
            ]) &&
            Utils.checkRoles(userRoleList)) {
          return AccessType.view;
        }

        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
          RequestStatus.declined,
          RequestStatus.approved,
          RequestStatus.completed,
          RequestStatus.pendingLimitRelease,
          RequestStatus.fitToLendCompletedPendingLimitRelease,
          RequestStatus.folNotRequired,
        ])) {
          return AccessType.none;
        }

        return serverGranted;

      case RightConstants.requestForLimitRelease:
        // Applicable for Approval Documentation Flow
        // [priorityRole] is used in approval such that if the application is
        // returned from the higher roles,
        // the section must be visible to the roles which are under the higher
        // roles
        final bool hasAccess = ApprovalUtils.priorityRoleAccess(
          RightConstants.requestForLimitRelease,
        );
        if (hasAccess) {
          return AccessType.view;
        }
        // Only visible for specific roles
        final List<UserRole> userRoleList = [
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationChecker,
          UserRole.ccuChecker,
          UserRole.ccuMaker,
        ];
        // Access for specific application status
        if (Utils.checkRoles(userRoleList)) {
          if (Utils.checkRequestStatuses([
                RequestStatus.fitToLendCompletedPendingLimitRelease,
                RequestStatus.pendingLimitRelease,
                RequestStatus.folNotRequired,
              ]) &&
              Globals.checkAppSubStatus(
                ServerConstants
                        .applicationSubType[ApplicationSubType.cashMargin] ??
                    "",
              )) {
            return AccessType.view;
          }
        }

        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
          RequestStatus.declined,
          RequestStatus.approved,
          RequestStatus.completed,
          RequestStatus.pendingFolIssuance,
          RequestStatus.folIssuedPendingSignOff,
          RequestStatus.folSignOffCompletedPendingFitToLend,
        ])) {
          return AccessType.none;
        }

        return serverGranted;

      case RightConstants.requestForClosure:
        // [priorityRole] is used in approval such that if the application is
        // returned from the higher roles,
        // the section must be visible to the roles which are under the higher
        // roles
        final bool hasAccess =
            ApprovalUtils.priorityRoleAccess(RightConstants.requestForClosure);
        if (hasAccess) {
          return AccessType.view;
        }
        // Access for specific application status
        final List<UserRole> userRoleList = [
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
        ];
        if (Utils.checkRoles(userRoleList) &&
            (Utils.checkRequestStatuses([
              RequestStatus.approved,
              RequestStatus.completed,
            ]))) {
          return AccessType.view;
        }

        if (Utils.checkRequestStatuses([
          RequestStatus.initiated,
          RequestStatus.pendingForApproval,
          RequestStatus.declined,
          RequestStatus.pendingFolIssuance,
          RequestStatus.folNotRequired,
          RequestStatus.pendingLimitRelease,
          RequestStatus.folIssuedPendingSignOff,
          RequestStatus.folSignOffCompletedPendingFitToLend,
          RequestStatus.fitToLendCompletedPendingLimitRelease,
        ])) {
          return AccessType.none;
        }

        return serverGranted;

      case RightConstants.countrySummary:
        // [priorityRole] is used in approval such that if the application is
        // returned from the higher roles,
        // the section must be visible to the roles which are under the higher
        // roles
        final bool hasAccess =
            ApprovalUtils.priorityRoleAccess(RightConstants.countrySummary);
        if (hasAccess) {
          return AccessType.view;
        }
        final List<UserRole> userRoleList = [
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.businessUnitHead,
          UserRole.teamLeaderBusiness,
          UserRole.commercialAreaManager,
          UserRole.relationshipManagerBussiness,
          UserRole.segmentHeadBusiness,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
          UserRole.documentationChecker,
          UserRole.ccuChecker,
        ];
        if (Utils.checkRoles(userRoleList) &&
            Utils.checkApplicationBusinessSegment(
              BusinessSegment.financialInstitution,
            )) {
          return AccessType.view;
        }

        return serverGranted;

      case RightConstants.covenantsSummary:
        //  After credit decision / post-approval lifecycle => covenants are read-only
        //    (covenants/conditions cannot be modified in the same approved application)
        if (Utils.isApprovedApplication()) {
          return AccessType.view;
        }

        // If the application is not editable for current user (not assigned / not active task)
        //    => view-only (FSD: after recommendation, previous user becomes
        // view-only)
        if (!Utils.canEditApplication()) {
          return AccessType.view;
        }
        return serverGranted;

      case RightConstants.conditionsSummary:
        // After credit decision / post-approval lifecycle => conditions are read-only
        if (Utils.isApprovedApplication()) {
          return AccessType.view;
        }

        // Not assigned / not active => view-only
        if (!Utils.canEditApplication()) {
          return AccessType.view;
        }

        return serverGranted;

      case RightConstants.esgCertification:
        // ESG Certification should be editable only while the application is
        // editable
        // for the current user (assigned + active task) and BEFORE credit
        // decision.
        // Post-decision / post-approval lifecycle -> view-only.
        if (Utils.isApprovedApplication()) {
          return AccessType.view;
        }

        //if application is in Documentation or CCU queue,
        // ESG certification should remain view-only (post-approval processing
        // happens in other screens).
        if (Utils.inDocumentationQueue() || Utils.inCreditControlQueue()) {
          return AccessType.view;
        }

        // If not assigned / not active for current user => view-only
        if (!Utils.canEditApplication()) {
          return AccessType.view;
        }
        return serverGranted;

      // Profitability & Account Conduct (FS-016) - access gating
      case RightConstants.accountStats:
      case RightConstants.businessVolume:
      case RightConstants.accountConduct:
      case RightConstants.strategiesComments:
      case RightConstants.incomeSummary:
      case RightConstants.relationshipProfitabilityDetailed:
      case RightConstants.relationshipUtilisation:
      case RightConstants.relationshipProfitabilitySummary:
      case RightConstants.shareOfWallet:
        // Editable only when application is actively editable for the user
        // (assigned + active task). Otherwise view-only.
        // Post-decision / post-approval lifecycle → view-only
        if (Utils.isApprovedApplication()) {
          return AccessType.view;
        }

        // If case is in Documentation/CCU queues, Profitability screens stay view-only
        if (Utils.inDocumentationQueue() || Utils.inCreditControlQueue()) {
          return AccessType.view;
        }

        // If not assigned / not active for current user → view-only
        if (!Utils.canEditApplication()) {
          return AccessType.view;
        }

        // Otherwise keep server granted (edit/view)
        return serverGranted;

      case RightConstants.customerInformation:
      case RightConstants.sicCodeReview:
      case RightConstants.requestInformation:
      case RightConstants.presentRequest:
      case RightConstants.securityPerfection:
      case RightConstants.terminateWithdrawal:
        if (Utils.isApprovedApplication()) {
          return AccessType.view;
        }
        // If not assigned / not active for current user → view-only
        if (!Utils.canEditApplication()) {
          return AccessType.view;
        }
        return serverGranted;
      case RightConstants.ccsysCreateRequest:
        return serverGranted;
      case RightConstants.ccsysRequestInformation:
        return serverGranted;
      case RightConstants.ccsysTerminationWithdrawal:
        return serverGranted;
      case RightConstants.ccsysCustomerInformation:
        return serverGranted;
      case RightConstants.ccsysRecommendationApproval:
        return serverGranted;

      //This is need for Project & Contract
      case RightConstants.searchProject:
      case RightConstants.createProject:
      case RightConstants.editProject:
      case RightConstants.editContract:
      case RightConstants.linkContract:
        final List<UserRole> viewOnlyRoles = [
          // Board / Committee
          UserRole.boardDirectorProxyApproval,
          UserRole.boardOfDirectors,
          UserRole.creditCommittee,
          UserRole.creditCommitteeProxyApprover,

          // Credit
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,

          // Documentation / CCU
          UserRole.documentationMaker,
          UserRole.documentationChecker,
          UserRole.ccuMaker,
          UserRole.ccuChecker,

          // Financial Pool
          UserRole.financialPoolCoordinator,
          UserRole.financialPoolMaker,
          UserRole.financialPoolChecker,

          // Legal
          UserRole.legalTeam,
          UserRole.legalTeamCoordinator,

          // Admin / Ops
          UserRole.admin,
          UserRole.businessAdmin,
          UserRole.icsAdmin,

          // Others
          UserRole.inquiryUser,
          UserRole.limitInputTeam,
          UserRole.na,

          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ];

        final List<UserRole> editRoles = [
          UserRole.relationshipManager,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.teamLeaderBusiness,
          UserRole.commercialAreaManager,
          UserRole.segmentHeadBusiness,
        ];

        if (Utils.checkRoles(viewOnlyRoles)) {
          return AccessType.view;
        }

        if (Utils.checkRoles(editRoles)) {
          return AccessType.edit;
        }

        return serverGranted;
      // -----------------------------------------------------------------------
      // Default: applied to ALL screens with no case above.
      // -----------------------------------------------------------------------
      default:
        // Downgrade to view if the application is read-only for the current
        // user.
        // Uses [_checkIfReadOnly], which extends the generic check with a
        // broader
        // post-approval status set. The application is considered read-only if
        // any
        // of the following apply:
        // - The application is in a post-approval status (Approved → Completed)
        //   or a terminal status (Declined, Cancelled, Terminated).
        // - The active task is not assigned to the current user's role and ID.
        // - The active task is not in an active status (Waiting or Assigned).
        // - Application lifecycle details are missing.
        if (EnvConfig.disableRestriction) {
          // TODO: Temporary ability to disable restriction for all screens, to
          // be removed later
          debugPrint(
            "Restriction is disabled temporarily, returning"
            " serverGranted for all screens",
          );
        } else {
          // Lazily compute once and cache for the entire _applyConditions
          // batch.
          // _cachedIsReadOnly is reset to null by invalidateCache() before the
          // loop.
          _cachedIsReadOnly ??= _checkIfReadOnly();
          if (_cachedIsReadOnly!) {
            return AccessType.view;
          }
        }
        // Otherwise, return the server's original access decision.
        return serverGranted;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Determines if the current application should be read-only for the
  /// purposes of the [resolveAccess] `default` block.
  ///
  /// Extends [Utils.checkIfAppReadOnly] by replacing the
  /// [ServerConstants.lifeCycleReadOnlyStatuses] terminal check with
  /// [Utils.isApprovedApplication], which covers the full set of
  /// credit-decision and post-approval statuses (see that method for the
  /// canonical status list).
  ///
  /// All other rules (enabledForView, task assignment & ownership) are
  /// identical to [Utils.checkIfAppReadOnly].
  static bool _checkIfReadOnly() {
    if (Globals.applicationDetails == null) {
      return false;
    }
    // Safety check: Cannot edit if lifecycle details are missing.
    if (Globals.applicationDetails?.applicationLifeCycle == null) {
      return true;
    }

    // Rule: Post-Decision & Post-Approval Statuses
    // [Utils.isApprovedApplication] now covers the full set — credit-decision
    // statuses (Approved, Declined, Cancelled, Terminated) plus the entire
    // FOL / CCU post-approval lifecycle through to Completed.
    if (Utils.isApprovedApplication()) {
      return true; // Read-only
    }

    final bool? enabledForView = Globals.applicationDetails!.enabledForView;
    final ApplicationLifeCycle lifeCycles =
        Globals.applicationDetails!.applicationLifeCycle!;

    // Rule: Backend Edit Override
    // When enabledForView is explicitly false, it signals an editable state
    // (e.g., when a status update is pending from the backend).
    if (enabledForView == false) {
      return false; // Editable
    }

    // Rule: Graceful fallback for missing config
    // If enabledForView is null, default to Read-Only for safety.
    if (enabledForView == null) {
      return true; // Read-only
    }

    // Rule: Task Assignment & Ownership
    // At this point, enabledForView is exactly true.
    // Verify if the current user is the rightful owner and allowed to act.
    final String assignedToUserId = (lifeCycles.assignedTo ?? "").trim();
    final int assignedToRole = lifeCycles.assignedToRole ?? 0;
    final String currentTaskStatus =
        (lifeCycles.status ?? "").trim().toLowerCase();

    final String currentUserBpmRole =
        (Globals.user?.currentRole?.bpmRole ?? "").trim();
    final String currentUserId = Globals.user?.id ?? "0";

    // Step a: Resolve the current user's roleId from bpmRole string.
    int currentUserRoleId = 0;
    for (final Map<String, int> roleMap in Globals.superBpmRolesId) {
      if (roleMap.containsKey(currentUserBpmRole) &&
          roleMap[currentUserBpmRole] != 0) {
        currentUserRoleId = roleMap[currentUserBpmRole]!;
        break;
      }
    }

    // Step b: Validate if the task is assigned to the current user's ID and
    // Role.
    final bool isAssignedToCurrentUser =
        (assignedToRole == currentUserRoleId) &&
            (assignedToUserId == currentUserId);

    // Step c: Validate if the task is actively awaiting user action.
    final bool isTaskActive =
        currentTaskStatus == ServerConstants.lifeCycleStatusWaiting ||
            currentTaskStatus == ServerConstants.lifeCycleStatusAssigned;

    // If the task is active AND assigned to the current user → editable.
    // Otherwise → read-only.
    final bool canEdit = isAssignedToCurrentUser && isTaskActive;
    return !canEdit;
  }
}
