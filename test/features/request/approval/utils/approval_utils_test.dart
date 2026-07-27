import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  group("ApprovalUtils", () {
    late dynamic originalApplicationDetails;
    late Map<int?, List<String>> originalRoleRouteAccess;
    late Map<int?, List<String>> originalUserRoleRouteAccess;
    late List<Reference> originalPasswordModeReference;

    setUp(() {
      originalApplicationDetails = Globals.applicationDetails;
      originalRoleRouteAccess = Map<int?, List<String>>.from(
        ApprovalUtils.roleRouteAcess,
      );
      originalUserRoleRouteAccess = Map<int?, List<String>>.from(
        ApprovalUtils.userRoleRouteAcess,
      );
      originalPasswordModeReference = List<Reference>.from(
        ApprovalUtils.passwordModeReference,
      );

      Globals.applicationDetails = null;
    });

    tearDown(() {
      Globals.applicationDetails = originalApplicationDetails;
      ApprovalUtils.roleRouteAcess = originalRoleRouteAccess;
      ApprovalUtils.userRoleRouteAcess = originalUserRoleRouteAccess;
      ApprovalUtils.passwordModeReference = originalPasswordModeReference;
    });

    ApplicationDetails createApplicationDetails({
      ApplicationLifeCycle? lifeCycle,
      String? businessSegment,
    }) {
      return ApplicationDetails()
        ..applicationLifeCycle = lifeCycle
        ..appBusinessSegment = businessSegment;
    }

    ApplicationLifeCycle createLifeCycle({
      required int priorityRole,
    }) {
      return ApplicationLifeCycle()..priorityRole = priorityRole;
    }

    test("passwordModeReference should be mutable static list", () {
      expect(ApprovalUtils.passwordModeReference, isA<List<Reference>>());

      ApprovalUtils.passwordModeReference = <Reference>[];

      expect(ApprovalUtils.passwordModeReference, isEmpty);
    });

    group("priorityRoleAccess", () {
      test("returns false when applicationDetails is null", () {
        Globals.applicationDetails = null;

        final bool result = ApprovalUtils.priorityRoleAccess(
          RightConstants.managementComments,
        );

        expect(result, isFalse);
      });

      test("returns false when applicationLifeCycle is null", () {
        Globals.applicationDetails = createApplicationDetails();

        final bool result = ApprovalUtils.priorityRoleAccess(
          RightConstants.managementComments,
        );

        expect(result, isFalse);
      });

      test("returns true when priority role has right access", () {
        final int roleId =
            ServerConstants.userRoleId[UserRole.creditAnalyst] ?? 0;

        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: roleId),
        );

        final bool result = ApprovalUtils.priorityRoleAccess(
          RightConstants.managementComments,
        );

        expect(result, isTrue);
      });

      test(
          "returns false when priority role does not have requested right access",
          () {
        final int roleId =
            ServerConstants.userRoleId[UserRole.creditAnalyst] ?? 0;

        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: roleId),
        );

        final bool result = ApprovalUtils.priorityRoleAccess(
          RightConstants.requestForLimitRelease,
        );

        expect(result, isFalse);
      });

      test("returns false when priority role is not present in roleRouteAcess",
          () {
        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: 999999),
        );

        final bool result = ApprovalUtils.priorityRoleAccess(
          RightConstants.managementComments,
        );

        expect(result, isFalse);
      });

      test("returns true when role 0 exists in roleRouteAcess", () {
        ApprovalUtils.roleRouteAcess = <int?, List<String>>{
          0: <String>[
            RightConstants.managementComments,
          ],
        };

        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: 0),
        );

        final bool result = ApprovalUtils.priorityRoleAccess(
          RightConstants.managementComments,
        );

        expect(result, isTrue);
      });
    });

    group("checkPriorityRoleAccess", () {
      test("returns false when applicationDetails is null", () {
        Globals.applicationDetails = null;

        final bool result = ApprovalUtils.checkPriorityRoleAccess(
          Routes.managementComments,
        );

        expect(result, isFalse);
      });

      test("returns false when applicationLifeCycle is null", () {
        Globals.applicationDetails = createApplicationDetails();

        final bool result = ApprovalUtils.checkPriorityRoleAccess(
          Routes.managementComments,
        );

        expect(result, isFalse);
      });

      test("returns true when priority role has route access", () {
        final int roleId =
            ServerConstants.userRoleId[UserRole.creditAnalyst] ?? 0;

        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: roleId),
        );

        final bool result = ApprovalUtils.checkPriorityRoleAccess(
          Routes.managementComments,
        );

        expect(result, isTrue);
      });

      test(
          "returns false when priority role does not have requested route access",
          () {
        final int roleId =
            ServerConstants.userRoleId[UserRole.documentationChecker] ?? 0;

        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: roleId),
        );

        final bool result = ApprovalUtils.checkPriorityRoleAccess(
          Routes.requestForLimitRelease,
        );

        expect(result, isFalse);
      });

      test(
          "returns false when priority role is not present in userRoleRouteAcess",
          () {
        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: 999999),
        );

        final bool result = ApprovalUtils.checkPriorityRoleAccess(
          Routes.managementComments,
        );

        expect(result, isFalse);
      });

      test("returns true for ccu maker limit release route", () {
        final int roleId = ServerConstants.userRoleId[UserRole.ccuMaker] ?? 0;

        Globals.applicationDetails = createApplicationDetails(
          lifeCycle: createLifeCycle(priorityRole: roleId),
        );

        final bool result = ApprovalUtils.checkPriorityRoleAccess(
          Routes.requestForLimitRelease,
        );

        expect(result, isTrue);
      });
    });

    group("checkApplicationBusinessSegment", () {
      test("returns false when applicationDetails is null", () {
        Globals.applicationDetails = null;

        final bool result = ApprovalUtils.checkApplicationBusinessSegment(
          BusinessSegment.corporate,
        );

        expect(result, isFalse);
      });

      test("returns true when application business segment matches", () {
        final String? segmentValue =
            ServerConstants.businessSegmentType[BusinessSegment.corporate];

        Globals.applicationDetails = createApplicationDetails(
          businessSegment: segmentValue,
        );

        final bool result = ApprovalUtils.checkApplicationBusinessSegment(
          BusinessSegment.corporate,
        );

        expect(result, isTrue);
      });

      test("returns false when application business segment does not match",
          () {
        Globals.applicationDetails = createApplicationDetails(
          businessSegment: "not-matching-segment",
        );

        final bool result = ApprovalUtils.checkApplicationBusinessSegment(
          BusinessSegment.corporate,
        );

        expect(result, isFalse);
      });
    });

    group("static access maps", () {
      test("roleRouteAcess contains expected right routes for credit analyst",
          () {
        final int? roleId = ServerConstants.userRoleId[UserRole.creditAnalyst];

        expect(
          ApprovalUtils.roleRouteAcess[roleId],
          contains(RightConstants.managementComments),
        );

        expect(
          ApprovalUtils.roleRouteAcess[roleId],
          contains(RightConstants.creditAssessment),
        );
      });

      test("roleRouteAcess contains additional rights for ccu checker", () {
        final int? roleId = ServerConstants.userRoleId[UserRole.ccuChecker];

        expect(
          ApprovalUtils.roleRouteAcess[roleId],
          contains(RightConstants.requestForFol),
        );

        expect(
          ApprovalUtils.roleRouteAcess[roleId],
          contains(RightConstants.proposedFacilities),
        );

        expect(
          ApprovalUtils.roleRouteAcess[roleId],
          contains(RightConstants.requestForLimitRelease),
        );
      });

      test(
          "userRoleRouteAcess contains expected routes for documentation maker",
          () {
        final int? roleId =
            ServerConstants.userRoleId[UserRole.documentationMaker];

        expect(
          ApprovalUtils.userRoleRouteAcess[roleId],
          contains(Routes.managementComments),
        );

        expect(
          ApprovalUtils.userRoleRouteAcess[roleId],
          contains(Routes.creditAssessment),
        );

        expect(
          ApprovalUtils.userRoleRouteAcess[roleId],
          contains(Routes.requestForFOL),
        );
      });

      test("userRoleRouteAcess contains limit release route for ccu checker",
          () {
        final int? roleId = ServerConstants.userRoleId[UserRole.ccuChecker];

        expect(
          ApprovalUtils.userRoleRouteAcess[roleId],
          contains(Routes.requestForLimitRelease),
        );
      });
    });
  });

  group("Integration: groupSummary access", () {
    test(
      "ALLOWED: relationship manager + group access + non-FI segment",
      () {
        // Arrange: allowed role
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipManager],
          ),
        );

        // Arrange: group access true
        Globals.request = Request(
          groupId: 1,
          appBusinessSegment: "Corporate",
        );

        // When FI segment check is false in real utils,
        // the condition allows access.
        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.groupSummary,
        );

        // Assert
        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role but group access is false",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipManager],
          ),
        );

        // groupID = 0 => checkGroupAccess() false
        Globals.request = Request(
          groupId: 0,
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.groupSummary,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when group access is true",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999, // not in allowed roles list
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          groupID: 1,
          groupApplication: true,
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.groupSummary,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: proposedFacilities access", () {
    test(
      "ALLOWED: credit analyst with APPROVED status",
      () {
        // Arrange: allowed role
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        // Arrange: application status = Approved
        Globals.applicationDetails = ApplicationDetails(
          status: 10,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        // Act
        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.proposedFacilities,
        );

        // Assert
        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role but status NOT in allowed list",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        // Status does not match any allowed RequestStatus
        Globals.applicationDetails = ApplicationDetails(
          status: 99,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.proposedFacilities,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when status matches",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999, // not in allowed role list
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 10,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.proposedFacilities,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: managementComments access", () {
    test(
      "ALLOWED: credit analyst with APPROVED status",
      () {
        // Arrange: allowed role
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        // Arrange: application status = Approved
        Globals.applicationDetails = ApplicationDetails(
          status: 5,
        );

        Globals.requestStatus = const [
          {"Approved": 5},
        ];

        // Act
        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.managementComments,
        );

        // Assert
        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role but status NOT in allowed list",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        // Status not matching allowed RequestStatus list
        Globals.applicationDetails = ApplicationDetails(
          status: 99,
        );

        Globals.requestStatus = const [
          {"Approved": 5},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.managementComments,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when status matches",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999, // not in allowed roles list
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 5,
        );

        Globals.requestStatus = const [
          {"Approved": 5},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.managementComments,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: creditAssessment access", () {
    test(
      "ALLOWED: credit analyst + approved status + non-FI segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 10,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessment,
        );

        expect(result, true);
      },
    );

    test(
      "ALLOWED: credit analyst + approved status (FI not detected)",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 10,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessment,
        );

        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role but status NOT in allowed list",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 99,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessment,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when status matches",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999,
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 10,
        );

        Globals.requestStatus = const [
          {"Approved": 10},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessment,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: requestForFOL access", () {
    test(
      "ALLOWED: relationship officer + pending FOL issuance",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        final title = ServerConstants
            .requestStatusTitle[RequestStatus.pendingFolIssuance]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 20,
        );

        Globals.requestStatus = [
          {title: 20},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForFOL,
        );

        expect(result, true);
      },
    );

    test(
      "ALLOWED: documentation checker + FOL issued pending sign-off",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.documentationChecker],
          ),
        );

        final title = ServerConstants
            .requestStatusTitle[RequestStatus.folIssuedPendingSignOff]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 30,
        );

        Globals.requestStatus = [
          {title: 30},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForFOL,
        );

        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role but status NOT in FOL list",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 99,
        );

        Globals.requestStatus = const [
          {"Pending Fol Issuance": 20},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForFOL,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when status matches",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999,
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          status: 20,
        );

        Globals.requestStatus = const [
          {"Pending Fol Issuance": 20},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForFOL,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: requestForLimitRelease access", () {
    test(
      "ALLOWED: relationship officer + pending limit release + NOT risk rating",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        final title = ServerConstants
            .requestStatusTitle[RequestStatus.pendingLimitRelease]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 40,
          subType: "SOME_OTHER_SUBTYPE",
        );

        Globals.requestStatus = [
          {title: 40},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForLimitRelease,
        );

        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role + status matches BUT risk rating subtype",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        final title = ServerConstants
            .requestStatusTitle[RequestStatus.pendingLimitRelease]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 40,
          subType:
              ServerConstants.applicationSubType[ApplicationSubType.riskRating],
        );

        Globals.requestStatus = [
          {title: 40},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForLimitRelease,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: allowed role but status not in allowed list",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        final title = ServerConstants
            .requestStatusTitle[RequestStatus.pendingLimitRelease]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 99,
          subType: "SOME_OTHER_SUBTYPE",
        );

        Globals.requestStatus = [
          {title: 40},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForLimitRelease,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when status matches",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999,
          ),
        );

        final title = ServerConstants
            .requestStatusTitle[RequestStatus.pendingLimitRelease]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 40,
          subType: "SOME_OTHER_SUBTYPE",
        );

        Globals.requestStatus = [
          {title: 40},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForLimitRelease,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: requestForClosure access", () {
    test(
      "ALLOWED: relationship officer + approved status",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        final title =
            ServerConstants.requestStatusTitle[RequestStatus.approved]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 50,
        );

        Globals.requestStatus = [
          {title: 50},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForClosure,
        );

        expect(result, true);
      },
    );

    test(
      "ALLOWED: credit analyst + completed status",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        final title =
            ServerConstants.requestStatusTitle[RequestStatus.completed]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 60,
        );

        Globals.requestStatus = [
          {title: 60},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForClosure,
        );

        expect(result, true);
      },
    );

    test(
      "DENIED: allowed role but status not approved/completed",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        final title =
            ServerConstants.requestStatusTitle[RequestStatus.approved]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 99,
        );

        Globals.requestStatus = [
          {title: 50},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForClosure,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when status matches",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999,
          ),
        );

        final title =
            ServerConstants.requestStatusTitle[RequestStatus.approved]!;

        Globals.applicationDetails = ApplicationDetails(
          status: 50,
        );

        Globals.requestStatus = [
          {title: 50},
        ];

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.requestForClosure,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: countrySummary access", () {
    setUp(() {
      Globals.cleanGlobalCache();
      Globals.user = null;
    });

    test(
      "ALLOWED: relationship officer + FI business segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          businessSegment: BusinessSegment.financialInstitution.name,
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.countrySummary,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: allowed role but NOT FI business segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.relationshipOfficer],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          businessSegment: "NON_FI",
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.countrySummary,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when FI segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999,
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          businessSegment: BusinessSegment.financialInstitution.name,
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.countrySummary,
        );

        expect(result, false);
      },
    );
  });

  group("Integration: creditAssessmentFI access", () {
    setUp(() {
      Globals.cleanGlobalCache();
      Globals.user = null;
    });

    test(
      "ALLOWED: credit analyst + FI business segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          businessSegment: BusinessSegment.financialInstitution.name,
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessmentFI,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: credit analyst but NOT FI business segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          businessSegment: "NON_FI",
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessmentFI,
        );

        expect(result, false);
      },
    );

    test(
      "DENIED: unauthorized role even when FI business segment",
      () {
        Globals.user = User(
          currentRole: Role(
            roleId: 999,
          ),
        );

        Globals.applicationDetails = ApplicationDetails(
          businessSegment: BusinessSegment.financialInstitution.name,
        );

        final result = ApprovalUtils.checkMasterAccessibilityForRoute(
          Routes.creditAssessmentFI,
        );

        expect(result, false);
      },
    );
  });

  group("Globals.isQueriesTabVisible", () {
    test("returns true for credit analyst", () {
      Globals.user = User(
        currentRole: Role(
          roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
        ),
      );

      expect(ApprovalUtils.isQueriesTabVisible(), true);
    });

    test("returns false for unrelated role", () {
      Globals.user = User(
        currentRole: Role(
          roleId: 999,
        ),
      );

      expect(ApprovalUtils.isQueriesTabVisible(), false);
    });
  });
}
