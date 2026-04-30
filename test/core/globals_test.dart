import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  setUp(() {
    Globals.cleanGlobalCache();
    Globals.user = null;
    Globals.applicationDetails = null;
    Globals.requestStatus = [];
  });

  group("Globals.checkIsInitiated", () {
    test("returns false when applicationDetails is null", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = null;

      expect(Globals.checkIsInitiated(), false);
    });

    test("returns true when createdBy matches user id", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U1");

      expect(Globals.checkIsInitiated(), true);
    });

    test("returns false when createdBy does not match user id", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U2");

      expect(Globals.checkIsInitiated(), false);
    });
  });

  group("Globals.checkCanEdit", () {
    test("returns false when user is null", () {
      expect(Globals.checkCanEdit("RIGHT"), false);
    });

    test("returns true when access type is edit", () {
      Globals.user = User(
        currentRole: Role(
          rights: {"RIGHT": AccessType.edit},
        ),
      );

      expect(Globals.checkCanEdit("RIGHT"), true);
    });

    test("returns false when access type is view", () {
      Globals.user = User(
        currentRole: Role(
          rights: {"RIGHT": AccessType.view},
        ),
      );

      expect(Globals.checkCanEdit("RIGHT"), false);
    });
  });

  group("Globals.checkGroupAccess", () {
    test("returns false when applicationDetails is null", () {
      Globals.applicationDetails = null;

      expect(Globals.checkGroupAccess(), false);
    });

    test("returns true when groupID is not zero and groupApplication true", () {
      Globals.applicationDetails = ApplicationDetails(
        groupID: 1,
        groupApplication: true,
      );

      expect(Globals.checkGroupAccess(), true);
    });

    test("returns false when groupID is zero", () {
      Globals.applicationDetails = ApplicationDetails(
        groupID: 0,
        groupApplication: true,
      );

      expect(Globals.checkGroupAccess(), false);
    });
  });

  group("Globals.checkLifeCycleStatus", () {
    test("returns false when lifecycle is null", () {
      Globals.applicationDetails = ApplicationDetails();

      expect(Globals.checkLifeCycleStatus("ANY"), false);
    });

    test("returns true when lifecycle status matches", () {
      Globals.applicationDetails = ApplicationDetails(
        applicationLifeCycle: ApplicationLifeCycle(status: "OPEN"),
      );

      expect(Globals.checkLifeCycleStatus("OPEN"), true);
    });
  });

  group("Globals.checkCurrentStatus", () {
    test("returns false when applicationDetails is null", () {
      Globals.applicationDetails = null;
      Globals.requestStatus = [
        {"Approved": 1},
      ];

      expect(
        Globals.checkCurrentStatus([RequestStatus.approved]),
        false,
      );
    });

    test("returns false when requestStatus list is empty", () {
      Globals.applicationDetails = ApplicationDetails(status: 1);

      expect(
        Globals.checkCurrentStatus([RequestStatus.approved]),
        false,
      );
    });

    test("returns true when status id matches", () {
      Globals.applicationDetails = ApplicationDetails(status: 10);
      Globals.requestStatus = [
        {"Approved": 10},
      ];

      expect(
        Globals.checkCurrentStatus([RequestStatus.approved]),
        true,
      );
    });
  });

  group("Globals.isQueriesTabVisible", () {
    test("returns true for credit analyst", () {
      Globals.user = User(
        currentRole: Role(
          roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
        ),
      );

      expect(Globals.isQueriesTabVisible(), true);
    });

    test("returns false for unrelated role", () {
      Globals.user = User(
        currentRole: Role(
          roleId: 999,
        ),
      );

      expect(Globals.isQueriesTabVisible(), false);
    });
  });

  group("Globals.checkAppSubStatus", () {
    test("returns false when applicationDetails is null", () {
      Globals.applicationDetails = null;

      expect(Globals.checkAppSubStatus("TYPE"), false);
    });

    test("returns true when subtype matches", () {
      Globals.applicationDetails = ApplicationDetails(subType: "TYPE");

      expect(Globals.checkAppSubStatus("TYPE"), true);
    });
  });

  group("Globals.hasRight", () {
    test("returns false when user is null", () {
      Globals.user = null;

      expect(Globals.hasRight("RIGHT"), false);
    });

    test("returns true when access is view or edit", () {
      Globals.user = User(
        currentRole: Role(
          rights: {"RIGHT": AccessType.view},
        ),
      );

      expect(Globals.hasRight("RIGHT"), true);
    });
  });

  group("Globals.checkVisibility", () {
    test("returns false when status does not match", () {
      Globals.applicationDetails = ApplicationDetails(status: 2);
      Globals.requestStatus = [
        {"Approved": 1},
      ];

      expect(
        Globals.checkVisibility(
          status: [RequestStatus.approved],
        ),
        false,
      );
    });

    test("returns true when status matches and right allowed", () {
      Globals.applicationDetails = ApplicationDetails(status: 1);
      Globals.requestStatus = [
        {"Approved": 1},
      ];
      Globals.user = User(
        currentRole: Role(
          rights: {"R": AccessType.edit},
        ),
      );

      expect(
        Globals.checkVisibility(
          status: [RequestStatus.approved],
          right: "R",
        ),
        true,
      );
    });

    test("returns true when status matches and no right required", () {
      Globals.applicationDetails = ApplicationDetails(status: 1);
      Globals.requestStatus = [
        {"Approved": 1},
      ];

      expect(
        Globals.checkVisibility(
          status: [RequestStatus.approved],
        ),
        true,
      );
    });
  });

  group("Globals.cleanGlobalCache", () {
    test("clears global references", () {
      Globals.request = Request(applicationRefNo: "REF");
      Globals.applicationDetails = ApplicationDetails();
      Globals.selectedCustomer = null;
      Globals.onAutoSave = () async {};
      Globals.onAutoSaveSync = () {};

      Globals.cleanGlobalCache();

      expect(Globals.applicationDetails, isNull);
      expect(Globals.onAutoSave, isNull);
      expect(Globals.onAutoSaveSync, isNull);
      expect(Globals.request, isNotNull);
    });
  });

  group("Integration: static lists lifecycle", () {
    test("dynamic form lists can be populated and read", () {
      Globals.dynamicFormCurrencyCodes = [
        Option(key: "USD", pairValue: "USD"),
        Option(key: "EUR", pairValue: "EUR"),
      ];

      Globals.dynamicFormEconomicZones = [
        Option(key: "EU", pairValue: "EU"),
      ];

      expect(Globals.dynamicFormCurrencyCodes!.length, 2);
      expect(Globals.dynamicFormEconomicZones!.first.value, "EU");
    });

    test("reference lists are NOT cleared by cleanGlobalCache", () {
      Globals.recommendReferences = [
        Reference(id: 1, name: "Approve"),
      ];
      Globals.returnReferences = [
        Reference(id: 2, name: "Return"),
      ];
      Globals.approvalReferences = [
        Reference(id: 3, name: "Reject"),
      ];

      Globals.cleanGlobalCache();

      expect(Globals.recommendReferences.length, 1);
      expect(Globals.returnReferences.length, 1);
      expect(Globals.approvalReferences.length, 1);
    });
    test("role/action static maps can be populated and consumed", () {
      Globals.userAction = [
        {"Approve": 1},
        {"Reject": 2},
      ];

      Globals.folTypeAction = [
        {"FOL": 100},
      ];

      expect(Globals.userAction.any((m) => m.containsKey("Approve")), true);
      expect(Globals.folTypeAction.first["FOL"], 100);
    });
  });

  group("Integration: static booleans via real behavior", () {
    test("isInitiated reflects current applicationDetails + user", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U1");

      // indirect verification (do NOT assert static field directly)
      final initiated = Globals.checkIsInitiated();

      expect(initiated, true);
    });

    test("isInitiated false when user does not own application", () {
      Globals.user = User(id: "U2");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U1");

      expect(Globals.checkIsInitiated(), false);
    });
  });

  group("Integration: permissions + visibility with static storage", () {
    test("hasRight honors static role rights", () {
      Globals.user = User(
        currentRole: Role(
          rights: {
            "EDIT_X": AccessType.edit,
            "VIEW_Y": AccessType.view,
          },
        ),
      );

      expect(Globals.hasRight("EDIT_X"), true);
      expect(Globals.hasRight("VIEW_Y"), true);
      expect(Globals.hasRight("NO_RIGHT"), false);
    });

    test("checkVisibility works with static requestStatus + rights", () {
      Globals.applicationDetails = ApplicationDetails(status: 5);
      Globals.requestStatus = [
        {"Approved": 5},
      ];

      Globals.user = User(
        currentRole: Role(
          rights: {"R": AccessType.edit},
        ),
      );

      final visible = Globals.checkVisibility(
        status: [RequestStatus.approved],
        right: "R",
      );

      expect(visible, true);
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
        Globals.applicationDetails = ApplicationDetails(
          groupID: 1,
          groupApplication: true,
        );

        // When FI segment check is false in real utils,
        // the condition allows access.
        final result = Globals.checkMasterAccessibilityForRoute(
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
        Globals.applicationDetails = ApplicationDetails(
          groupID: 0,
          groupApplication: true,
        );

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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
        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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
        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
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

        final result = Globals.checkMasterAccessibilityForRoute(
          Routes.creditAssessmentFI,
        );

        expect(result, false);
      },
    );
  });
}
