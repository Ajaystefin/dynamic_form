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
  setUp(() {
    Globals.applicationDetails = ApplicationDetails();
    // Default to a state where the application can be edited
    Globals.isAllReadOnly = false;
  });

  void setRequestStatus(RequestStatus status) {
    Globals.applicationDetails?.status =
        ServerConstants.requestStatusId[status];
  }

  group("ScreenAccessConditions", () {
    group("documentationCertification", () {
      test("should return AccessType.none when status is not relevant", () {
        // 'initiated' is not in the list of relevant statuses for
        // documentationCertification
        setRequestStatus(RequestStatus.initiated);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.documentationCertification,
          AccessType.edit,
        );

        expect(result, AccessType.none);
      });

      test(
          "should return AccessType.view when status"
          " is visible but not editable", () {
        // 'pendingLimitRelease' is visible but read-only for
        // documentationCertification
        setRequestStatus(RequestStatus.pendingLimitRelease);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.documentationCertification,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("should return serverGranted when status is editable", () {
        // 'pendingFolIssuance' allows editing
        setRequestStatus(RequestStatus.pendingFolIssuance);

        final result1 = ScreenAccessConditions.resolveAccess(
          RightConstants.documentationCertification,
          AccessType.edit,
        );
        expect(result1, AccessType.edit);

        final result2 = ScreenAccessConditions.resolveAccess(
          RightConstants.documentationCertification,
          AccessType.view,
        );
        expect(result2, AccessType.view);
      });
    });

    group("creditControlTeamCertification", () {
      test("should return AccessType.none when status is not relevant", () {
        // 'initiated' is not in the list of relevant statuses for
        // creditControlTeamCertification
        setRequestStatus(RequestStatus.initiated);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.creditControlTeamCertification,
          AccessType.edit,
        );

        expect(result, AccessType.none);
      });

      test(
          "should return "
          "AccessType.view when "
          "status is visible but not editable", () {
        // 'completed' is visible but read-only for
        // creditControlTeamCertification
        setRequestStatus(RequestStatus.completed);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.creditControlTeamCertification,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("should return serverGranted when status is editable", () {
        // 'pendingLimitRelease' allows editing
        setRequestStatus(RequestStatus.pendingLimitRelease);

        final result1 = ScreenAccessConditions.resolveAccess(
          RightConstants.creditControlTeamCertification,
          AccessType.edit,
        );
        expect(result1, AccessType.edit);

        final result2 = ScreenAccessConditions.resolveAccess(
          RightConstants.creditControlTeamCertification,
          AccessType.view,
        );
        expect(result2, AccessType.view);
      });
    });

    group("groupSummary", () {
      test("should return AccessType.none when the application type is FI", () {
        Globals.applicationDetails?.groupID = 0;
        Globals.request?.appBusinessSegment = ServerConstants
            .businessSegmentType[BusinessSegment.financialInstitution];

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.groupSummary,
          AccessType.edit,
        );

        expect(result, AccessType.none);
      });

      test(
          "should return AccessType.edit when "
          "the application groupId is non zero", () {
        Globals.applicationDetails?.groupID = 10;

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.groupSummary,
          AccessType.edit,
        );

        expect(result, AccessType.none);
      });

      test("should return AccessType.edit when no conditions are matched", () {
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.groupSummary,
          AccessType.edit,
        );

        expect(result, AccessType.none);
      });
    });

    group("managementComments", () {
      test(
          "should return AccessType.view when the "
          "application priorityRole is higher than CA", () {
        Globals.applicationDetails?.applicationLifeCycle =
            ApplicationLifeCycle(priorityRole: 135); // CA

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.managementComments,
          AccessType.none,
        );

        expect(result, AccessType.view);
      });

      test(
          "should return AccessType.edit when "
          "the application status is not relevant", () {
        setRequestStatus(RequestStatus.pendingLimitRelease);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.managementComments,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });

      test("should return AccessType.edit when no conditions are matched", () {
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.managementComments,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    });

    group("proposedFacilities", () {
      test(
          "should return AccessType.none when "
          "the application status is not relevant", () {
        setRequestStatus(RequestStatus.pendingLimitRelease);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.proposedFacilities,
          AccessType.none,
        );

        expect(result, AccessType.none);
      });

      test("should return AccessType.edit when no conditions are matched", () {
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.proposedFacilities,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    });

    group("creditAssessment", () {
      test(
          "should return AccessType.view when the "
          "application priorityRole is higher than CA", () {
        Globals.applicationDetails?.applicationLifeCycle =
            ApplicationLifeCycle(priorityRole: 3203); // DC

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.creditAssessment,
          AccessType.none,
        );

        expect(result, AccessType.view);
      });

      test(
          "should return AccessType.view when "
          "the application status is not relevant", () {
        setRequestStatus(RequestStatus.pendingLimitRelease);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.creditAssessment,
          AccessType.view,
        );

        expect(result, AccessType.view);
      });

      test("should return AccessType.edit when no conditions are matched", () {
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.creditAssessment,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    });

    group("requestForFol", () {
      test(
          "should return AccessType.view when the "
          "application priorityRole is higher than CA", () {
        Globals.applicationDetails?.applicationLifeCycle =
            ApplicationLifeCycle(priorityRole: 3203); // DC

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForFol,
          AccessType.none,
        );

        expect(result, AccessType.view);
      });

      test(
          "should return AccessType.none when "
          "the application status is not relevant", () {
        setRequestStatus(RequestStatus.initiated);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForFol,
          AccessType.view,
        );

        expect(result, AccessType.none);
      });

      test(
          "should return AccessType.view when "
          "the application status is relevant", () {
        setRequestStatus(RequestStatus.pendingFolIssuance);
        Globals.user =
            User(currentRole: Role(userRole: UserRole.relationshipManager));
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForFol,
          AccessType.none,
        );

        expect(result, AccessType.view);
      });

      test("should return AccessType.edit when no conditions are matched", () {
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForFol,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    });

    group("requestForLimitRelease", () {
      test(
          "should return AccessType.view when the "
          "application priorityRole is higher than CA", () {
        Globals.applicationDetails?.applicationLifeCycle =
            ApplicationLifeCycle(priorityRole: 11398); // CCU Checker

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForLimitRelease,
          AccessType.none,
        );

        expect(result, AccessType.view);
      });

      test(
          "should return AccessType.none when "
          "the application status is not relevant", () {
        setRequestStatus(RequestStatus.initiated);

        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForLimitRelease,
          AccessType.view,
        );

        expect(result, AccessType.none);
      });

      test(
          "should return AccessType.view when "
          "the application status is relevant", () {
        setRequestStatus(RequestStatus.pendingLimitRelease);
        Globals.applicationDetails?.subType = "CM";
        Globals.user =
            User(currentRole: Role(userRole: UserRole.documentationChecker));
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForLimitRelease,
          AccessType.none,
        );

        expect(result, AccessType.view);
      });

      test("should return AccessType.edit when no conditions are matched", () {
        final result = ScreenAccessConditions.resolveAccess(
          RightConstants.requestForLimitRelease,
          AccessType.edit,
        );

        expect(result, AccessType.edit);
      });
    });

    group("default condition", () {
      const rightKey = "some-other-unhandled-right";

      test(
          "should return AccessType.view if the "
          "application is globally read-only", () {
        // Simulate Utils.canEditApplication() returning false
        Globals.isAllReadOnly = true;

        final result = ScreenAccessConditions.resolveAccess(
          rightKey,
          AccessType.edit,
        );

        expect(result, AccessType.view);
      });

      test("should return serverGranted if the application is fully editable",
          () {
        Globals.isAllReadOnly = false;

        final result1 = ScreenAccessConditions.resolveAccess(
          rightKey,
          AccessType.edit,
        );
        expect(result1, AccessType.view);

        final result2 = ScreenAccessConditions.resolveAccess(
          rightKey,
          AccessType.view,
        );
        expect(result2, AccessType.view);

        final result3 = ScreenAccessConditions.resolveAccess(
          rightKey,
          AccessType.none,
        );
        expect(result3, AccessType.view);
      });
    });
  });
}
