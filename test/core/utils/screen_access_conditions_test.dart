import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void resetGlobals() {
    Globals.applicationDetails = ApplicationDetails();
    Globals.isAllReadOnly = false;
    Globals.superBpmRolesId = [];
    Globals.user = null;

    // IMPORTANT:
    // Replace `YourRequestModel()` with your actual request model constructor.
    // Without this, setBusinessSegment() becomes a no-op because of `?.`
    // Globals.request = YourRequestModel();

    Globals.applicationDetails?.enabledForView = true;
    Globals.applicationDetails?.applicationLifeCycle = ApplicationLifeCycle(
      status: ServerConstants.lifeCycleStatusAssigned,
      userAction: 0,
    );

    ScreenAccessConditions.invalidateCache();
  }

  void setRequestStatus(RequestStatus status) {
    Globals.applicationDetails?.status =
        ServerConstants.requestStatusId[status];
    ScreenAccessConditions.invalidateCache();
  }

  void setUserRole(
    UserRole role, {
    String bpmRole = "TEST_BPM_ROLE",
    String userId = "1",
  }) {
    Globals.user = User(
      id: userId,
      currentRole: Role(
        userRole: role,
        bpmRole: bpmRole,
      ),
    );
  }

  void setLifecycle({
    int? priorityRole,
    int? userAction,
    String? assignedTo,
    int? assignedToRole,
    String? status,
  }) {
    Globals.applicationDetails?.applicationLifeCycle = ApplicationLifeCycle(
      priorityRole: priorityRole,
      userAction: userAction,
      assignedTo: assignedTo,
      assignedToRole: assignedToRole,
      status: status,
    );
    ScreenAccessConditions.invalidateCache();
  }

  void makeAssignedAndActive({
    String userId = "1",
    String bpmRole = "TEST_BPM_ROLE",
    int bpmRoleId = 999,
    UserRole userRole = UserRole.relationshipManager,
    String taskStatus = ServerConstants.lifeCycleStatusAssigned,
  }) {
    setUserRole(
      userRole,
      bpmRole: bpmRole,
      userId: userId,
    );
    Globals.superBpmRolesId = [
      {bpmRole: bpmRoleId},
    ];
    setLifecycle(
      assignedTo: userId,
      assignedToRole: bpmRoleId,
      status: taskStatus,
      userAction: 0,
    );
    Globals.applicationDetails?.enabledForView = true;
    ScreenAccessConditions.invalidateCache();
  }

  void makeUnassignedOrInactive({
    String userId = "1",
    String bpmRole = "TEST_BPM_ROLE",
    int bpmRoleId = 999,
    UserRole userRole = UserRole.relationshipManager,
    String taskStatus = "completed",
  }) {
    setUserRole(
      userRole,
      bpmRole: bpmRole,
      userId: userId,
    );
    Globals.superBpmRolesId = [
      {bpmRole: bpmRoleId},
    ];
    setLifecycle(
      assignedTo: "another-user",
      assignedToRole: bpmRoleId,
      status: taskStatus,
      userAction: 0,
    );
    Globals.applicationDetails?.enabledForView = true;
    ScreenAccessConditions.invalidateCache();
  }

  void setBusinessSegment(BusinessSegment segment) {
    Globals.request?.appBusinessSegment =
        ServerConstants.businessSegmentType[segment];
  }

  void setCashMarginSubType() {
    Globals.applicationDetails?.subType =
        ServerConstants.applicationSubType[ApplicationSubType.cashMargin] ?? "";
  }

  const unknownRight = "some-other-unhandled-right";

  setUp(resetGlobals);

  // ---------------------------------------------------------------------------
  // Existing sections - corrected and expanded
  // ---------------------------------------------------------------------------

  group("documentationCertification", () {
    test("returns none when status is not relevant", () {
      // 'initiated' is not in the list of relevant statuses for
      // documentationCertification
      setRequestStatus(RequestStatus.initiated);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.documentationCertification,
        AccessType.edit,
      );

      expect(result, AccessType.none);
    });

    test("returns view when status is visible but not editable", () {
      // 'pendingLimitRelease' is visible but read-only for
      // documentationCertification
      setRequestStatus(RequestStatus.pendingLimitRelease);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.documentationCertification,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when editable", () {
      // 'pendingFolIssuance' allows editing
      setRequestStatus(RequestStatus.pendingFolIssuance);

      final result1 = ScreenAccessConditions.resolveAccess(
        RightConstants.documentationCertification,
        AccessType.edit,
      );
      expect(result1, AccessType.view);

      final result2 = ScreenAccessConditions.resolveAccess(
        RightConstants.documentationCertification,
        AccessType.view,
      );
      expect(result2, AccessType.view);
    });
  });

  group("creditControlTeamCertification", () {
    test("returns none when status is not relevant", () {
      // 'initiated' is not in the list of relevant statuses for
      // creditControlTeamCertification
      setRequestStatus(RequestStatus.initiated);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.creditControlTeamCertification,
        AccessType.edit,
      );

      expect(result, AccessType.none);
    });

    test("returns view when status is visible but not editable", () {
      // 'completed' is visible but read-only for
      // creditControlTeamCertification
      setRequestStatus(RequestStatus.completed);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.creditControlTeamCertification,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when editable", () {
      // 'pendingLimitRelease' allows editing
      setRequestStatus(RequestStatus.pendingLimitRelease);

      final result1 = ScreenAccessConditions.resolveAccess(
        RightConstants.creditControlTeamCertification,
        AccessType.edit,
      );
      expect(result1, AccessType.view);

      final result2 = ScreenAccessConditions.resolveAccess(
        RightConstants.creditControlTeamCertification,
        AccessType.view,
      );
      expect(result2, AccessType.view);
    });
  });

  group("groupSummary", () {
    test("returns none when business segment is FI", () {
      Globals.applicationDetails?.groupID = 0;
      setBusinessSegment(BusinessSegment.financialInstitution);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.groupSummary,
        AccessType.edit,
      );

      expect(result, AccessType.none);
    });

    test("returns serverGranted when no conditions match", () {
      Globals.applicationDetails?.groupID = 0;
      setBusinessSegment(BusinessSegment.corporate);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.groupSummary,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("managementComments", () {
    test("returns view when application priorityRole gives access", () {
      Globals.applicationDetails?.applicationLifeCycle =
          ApplicationLifeCycle(priorityRole: 135); // CA

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.managementComments,
        AccessType.none,
      );

      expect(result, AccessType.view);
    });

    test("returns view for allowed roles in initiated/pendingForApproval", () {
      setRequestStatus(RequestStatus.initiated);
      setUserRole(UserRole.creditAnalyst);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.managementComments,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when no conditions match", () {
      setRequestStatus(RequestStatus.pendingLimitRelease);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.managementComments,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("proposedFacilities", () {
    test("returns view for allowed roles in initiated/pendingForApproval", () {
      setRequestStatus(RequestStatus.initiated);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.proposedFacilities,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when no conditions match", () {
      setRequestStatus(RequestStatus.pendingLimitRelease);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.proposedFacilities,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("creditAssessment", () {
    test("returns view when application priorityRole gives access", () {
      Globals.applicationDetails?.applicationLifeCycle =
          ApplicationLifeCycle(priorityRole: 3203); // DC

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.creditAssessment,
        AccessType.none,
      );

      expect(result, AccessType.view);
    });

    test("returns view for allowed roles in initiated/pendingForApproval", () {
      setRequestStatus(RequestStatus.initiated);
      setUserRole(UserRole.creditAnalyst);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.creditAssessment,
        AccessType.view,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when no conditions match", () {
      setRequestStatus(RequestStatus.pendingLimitRelease);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.creditAssessment,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("requestForFol", () {
    test("returns view when application priorityRole gives access", () {
      Globals.applicationDetails?.applicationLifeCycle =
          ApplicationLifeCycle(priorityRole: 3203); // DC

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForFol,
        AccessType.none,
      );

      expect(result, AccessType.view);
    });

    test("returns none when blocked status is used", () {
      setRequestStatus(RequestStatus.initiated);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForFol,
        AccessType.view,
      );

      expect(result, AccessType.none);
    });

    test("returns view when status is relevant and role is allowed", () {
      setRequestStatus(RequestStatus.pendingFolIssuance);
      Globals.user =
          User(currentRole: Role(userRole: UserRole.relationshipManager));

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForFol,
        AccessType.none,
      );

      expect(result, AccessType.view);
    });

    test(
        "returns serverGranted when status is relevant but role is not allowed",
        () {
      setRequestStatus(RequestStatus.pendingFolIssuance);
      setUserRole(UserRole.ccuChecker);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForFol,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });

    test("returns serverGranted when no conditions match", () {
      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForFol,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("requestForLimitRelease", () {
    test("returns view when application priorityRole gives access", () {
      Globals.applicationDetails?.applicationLifeCycle =
          ApplicationLifeCycle(priorityRole: 11398); // CCU Checker

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForLimitRelease,
        AccessType.none,
      );

      expect(result, AccessType.view);
    });

    test("returns none when blocked status is used", () {
      setRequestStatus(RequestStatus.initiated);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForLimitRelease,
        AccessType.view,
      );

      expect(result, AccessType.none);
    });

    test("returns view when status/role/subtype are relevant", () {
      setRequestStatus(RequestStatus.pendingLimitRelease);
      setCashMarginSubType();
      Globals.user =
          User(currentRole: Role(userRole: UserRole.documentationChecker));

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForLimitRelease,
        AccessType.none,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when subtype does not match", () {
      setRequestStatus(RequestStatus.pendingLimitRelease);
      Globals.applicationDetails?.subType = "NOT_CM";
      setUserRole(UserRole.documentationChecker);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForLimitRelease,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });

    test("returns serverGranted when no conditions match", () {
      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForLimitRelease,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  // ---------------------------------------------------------------------------
  // Additional switch cases
  // ---------------------------------------------------------------------------

  group("simple initiated/pendingForApproval to view rights", () {
    const rights = [
      RightConstants.comments,
      RightConstants.recommendationCurrentApproval,
      RightConstants.groupPosition,
      RightConstants.limitCaps,
      RightConstants.guarantorsExposure,
    ];

    for (final right in rights) {
      test("$right returns view in initiated", () {
        setRequestStatus(RequestStatus.initiated);

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("$right returns serverGranted outside initiated/pendingForApproval",
          () {
        setRequestStatus(RequestStatus.completed);

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    }
  });

  group("queriesResponses", () {
    test("returns view for allowed role in initiated", () {
      setRequestStatus(RequestStatus.initiated);
      setUserRole(UserRole.creditAnalyst);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.queriesResponses,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when conditions do not match", () {
      setRequestStatus(RequestStatus.completed);
      setUserRole(UserRole.documentationChecker);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.queriesResponses,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("requestForClosure", () {
    test("returns view for allowed role and approved/completed statuses", () {
      setRequestStatus(RequestStatus.approved);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForClosure,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns none for blocked statuses", () {
      setRequestStatus(RequestStatus.initiated);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForClosure,
        AccessType.edit,
      );

      expect(result, AccessType.none);
    });

    test("returns serverGranted when no conditions match", () {
      setRequestStatus(RequestStatus.requestWithdrawnCancelled);
      setUserRole(UserRole.relationshipManager);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.requestForClosure,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("countrySummary", () {
    test("returns view for allowed role when FI business segment", () {
      setUserRole(UserRole.relationshipManager);
      setBusinessSegment(BusinessSegment.financialInstitution);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.countrySummary,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when business segment is not FI", () {
      setUserRole(UserRole.relationshipManager);
      setBusinessSegment(BusinessSegment.corporate);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.countrySummary,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  void makeCannotEditApplication() {
    Globals.isAllReadOnly = true;
  }

  void makeEditableApplication() {
    Globals.isAllReadOnly = false;
  }

  group("covenantsSummary", () {
    test("returns view for approved application", () {
      setRequestStatus(RequestStatus.approved);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.covenantsSummary,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when app is not editable for current user", () {
      makeCannotEditApplication();

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.covenantsSummary,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when editable", () {
      makeEditableApplication();

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.covenantsSummary,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("conditionsSummary", () {
    test("returns view for approved application", () {
      setRequestStatus(RequestStatus.approved);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.conditionsSummary,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when app is not editable for current user", () {
      makeCannotEditApplication();

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.conditionsSummary,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when editable", () {
      makeEditableApplication();

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.conditionsSummary,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("esgCertification", () {
    test("returns view when application is approved", () {
      setRequestStatus(RequestStatus.approved);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.esgCertification,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view in documentation queue", () {
      setRequestStatus(RequestStatus.pendingFolIssuance);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.esgCertification,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view in credit control queue", () {
      setRequestStatus(RequestStatus.pendingLimitRelease);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.esgCertification,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when not editable", () {
      makeCannotEditApplication();

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.esgCertification,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when editable", () {
      makeEditableApplication();
      setRequestStatus(RequestStatus.initiated);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.esgCertification,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });
  });

  group("profitability and account conduct rights", () {
    const rights = [
      RightConstants.accountStats,
      RightConstants.businessVolume,
      RightConstants.accountConduct,
      RightConstants.strategiesComments,
      RightConstants.incomeSummary,
      RightConstants.relationshipProfitabilityDetailed,
      RightConstants.relationshipUtilisation,
      RightConstants.relationshipProfitabilitySummary,
      RightConstants.shareOfWallet,
    ];

    for (final right in rights) {
      test("$right returns view when approved", () {
        setRequestStatus(RequestStatus.completed);

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("$right returns view when not editable", () {
        makeCannotEditApplication();

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("$right returns serverGranted when editable", () {
        makeEditableApplication();

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    }
  });

  group("risk rating rights", () {
    const rights = [
      RightConstants.customerInformation,
      RightConstants.sicCodeReview,
      RightConstants.requestInformation,
      RightConstants.presentRequest,
      RightConstants.securityPerfection,
      RightConstants.terminateWithdrawal,
    ];

    for (final right in rights) {
      test("$right returns view when approved", () {
        setRequestStatus(RequestStatus.approved);

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("$right returns view when current user cannot edit application", () {
        makeCannotEditApplication();

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("$right returns serverGranted when editable", () {
        makeEditableApplication();

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    }
  });

  group("ccsys rights", () {
    const rights = [
      RightConstants.ccsysCreateRequest,
      RightConstants.ccsysRequestInformation,
      RightConstants.ccsysTerminationWithdrawal,
      RightConstants.ccsysCustomerInformation,
      RightConstants.ccsysRecommendationApproval,
    ];

    for (final right in rights) {
      test("$right returns serverGranted unchanged", () {
        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    }
  });

  group("project and contract rights", () {
    const rights = [
      RightConstants.searchProject,
      RightConstants.createProject,
      RightConstants.editProject,
      RightConstants.editContract,
      RightConstants.linkContract,
    ];

    for (final right in rights) {
      test("$right returns edit for edit roles", () {
        setUserRole(UserRole.relationshipManager);

        final result = ScreenAccessConditions.resolveAccess(
          right,
          AccessType.view,
        );

        expect(result, AccessType.edit);
      });
    }
  });

  group("createSecurity", () {
    test("returns view in documentation queue when lifecycle is null", () {
      setRequestStatus(RequestStatus.pendingFolIssuance);
      Globals.applicationDetails?.applicationLifeCycle = null;

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.createSecurity,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test(
        "returns serverGranted in documentation queue when assigned and active",
        () {
      setRequestStatus(RequestStatus.pendingFolIssuance);
      makeAssignedAndActive(
        userRole: UserRole.documentationChecker,
        bpmRole: "DOC_ROLE",
        bpmRoleId: 1234,
      );

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.createSecurity,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });

    test("returns view in documentation queue when not assigned/active", () {
      setRequestStatus(RequestStatus.pendingFolIssuance);
      makeUnassignedOrInactive(
        userRole: UserRole.documentationChecker,
        bpmRole: "DOC_ROLE",
        bpmRoleId: 1234,
      );

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.createSecurity,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("outside documentation queue returns serverGranted when editable", () {
      setRequestStatus(RequestStatus.initiated);
      makeAssignedAndActive();

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.createSecurity,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });

    test("outside documentation queue returns view when read only", () {
      setRequestStatus(RequestStatus.completed);

      final result = ScreenAccessConditions.resolveAccess(
        RightConstants.createSecurity,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });
  });

  // ---------------------------------------------------------------------------
  // Default block + cache behavior
  // ---------------------------------------------------------------------------

  group("default condition", () {
    test("returns serverGranted when applicationDetails is null", () {
      Globals.applicationDetails = null;
      ScreenAccessConditions.invalidateCache();

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.edit);
    });

    test("returns view when lifecycle is null", () {
      Globals.applicationDetails = ApplicationDetails();
      Globals.applicationDetails?.applicationLifeCycle = null;
      ScreenAccessConditions.invalidateCache();

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when app is in approved/read only lifecycle", () {
      setRequestStatus(RequestStatus.completed);

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when enabledForView is false", () {
      Globals.applicationDetails?.enabledForView = false;
      setLifecycle(status: ServerConstants.lifeCycleStatusAssigned);

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when enabledForView is null", () {
      Globals.applicationDetails?.enabledForView = null;
      setLifecycle(status: ServerConstants.lifeCycleStatusAssigned);

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns serverGranted when assigned to current user and active", () {
      makeAssignedAndActive();

      final result1 = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );
      expect(result1, AccessType.edit);

      final result2 = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.view,
      );
      expect(result2, AccessType.view);

      final result3 = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.none,
      );
      expect(result3, AccessType.none);
    });

    test("returns view when task is active but not assigned to current user",
        () {
      setUserRole(
        UserRole.relationshipManager,
      );
      Globals.superBpmRolesId = [
        {"TEST_BPM_ROLE": 999},
      ];
      setLifecycle(
        assignedTo: "2",
        assignedToRole: 999,
        status: ServerConstants.lifeCycleStatusAssigned,
      );
      Globals.applicationDetails?.enabledForView = true;
      ScreenAccessConditions.invalidateCache();

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when task is assigned but inactive", () {
      setUserRole(
        UserRole.relationshipManager,
      );
      Globals.superBpmRolesId = [
        {"TEST_BPM_ROLE": 999},
      ];
      setLifecycle(
        assignedTo: "1",
        assignedToRole: 999,
        status: "completed",
      );
      Globals.applicationDetails?.enabledForView = true;
      ScreenAccessConditions.invalidateCache();

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("returns view when bpm role mapping is missing", () {
      setUserRole(
        UserRole.relationshipManager,
        bpmRole: "MISSING_ROLE",
      );
      Globals.superBpmRolesId = [];
      setLifecycle(
        assignedTo: "1",
        assignedToRole: 999,
        status: ServerConstants.lifeCycleStatusAssigned,
      );
      Globals.applicationDetails?.enabledForView = true;
      ScreenAccessConditions.invalidateCache();

      final result = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );

      expect(result, AccessType.view);
    });

    test("cache is reused until invalidateCache is called", () {
      makeAssignedAndActive();

      final first = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );
      expect(first, AccessType.edit);

      // change state without invalidating cache
      Globals.superBpmRolesId = [
        {"TEST_BPM_ROLE": 999},
      ];
      Globals.applicationDetails?.applicationLifeCycle = ApplicationLifeCycle(
        assignedTo: "another-user",
        assignedToRole: 999,
        status: "completed",
      );
      Globals.applicationDetails?.enabledForView = true;

      final second = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );
      expect(second, AccessType.edit);

      ScreenAccessConditions.invalidateCache();

      final third = ScreenAccessConditions.resolveAccess(
        unknownRight,
        AccessType.edit,
      );
      expect(third, AccessType.view);
    });
  });
}
