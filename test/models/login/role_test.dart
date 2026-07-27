import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

void main() {
  group("Role", () {
    test("fromJson creates Role object correctly", () {
      final Map<String, dynamic> json = {
        "roleId": 1,
        "roleName": "Admin",
        "roleCode": "ADMIN",
        "bpmRole": "BPM_ADMIN",
        "roleGroup": "GroupA",
        "rights": {"canView": 0, "canEdit": 1},
        "userDetails": [
          {
            "userId": "1",
            "userName": "TestUser",
            "regionList": ["region1"],
            "segmentList": ["segment1"],
          }
        ],
      };

      final role = Role.fromJson(json);

      expect(role.roleId, 1);
      expect(role.name, "Admin");
      expect(role.code, "ADMIN");
      expect(role.bpmRole, "BPM_ADMIN");
      expect(role.group, "GroupA");
      expect(role.rights!["canView"], AccessType.view);
      expect(role.rights!["canEdit"], AccessType.edit);
      expect(role.users!.length, 1);
      expect(role.users![0].userName, "TestUser");
    });

    test("fromJson handles null and empty values", () {
      final Map<String, dynamic> json = {};
      final role = Role.fromJson(json);

      expect(role.roleId, null);
      expect(role.name, null);
      expect(role.code, null);
      expect(role.bpmRole, null);
      expect(role.group, null);
      expect(role.rights, null);
      expect(role.users, null);
    });

    test("toJson converts Role object to JSON correctly", () {
      final roleWithUsers = Role(
        roleId: 1,
        name: "Admin",
        code: "ADMIN",
        bpmRole: "BPM_ADMIN",
        group: "GroupA",
        rights: {"canView": AccessType.none, "canEdit": AccessType.edit},
        users: [
          User(
            id: "1",
            userName: "TestUser",
            regions: ["region1"],
            segments: ["segment1"],
          ),
        ],
        routesAccessibility: {
          "dashboard": MenuMode.hidden,
          "settings": MenuMode.enabled,
        },
      );

      final jsonWithUsers = roleWithUsers.toJson();

      expect(jsonWithUsers["roleId"], 1);
      expect(jsonWithUsers["roleName"], "Admin");
      expect(jsonWithUsers["roleCode"], "ADMIN");
      expect(jsonWithUsers["bpmRole"], "BPM_ADMIN");
      expect(jsonWithUsers["roleGroup"], "GroupA");
      // expect(jsonWithUsers['rights']['canView'], 2);
      // expect(jsonWithUsers['rights']['canEdit'], 1);
      expect(jsonWithUsers["routesAccessibility"]["dashboard"], 2);
      // expect(jsonWithUsers['routesAccessibility']['settings'], 2);
      // expect(jsonWithUsers['userDetails'][0]['userId'], '1');
      // expect(jsonWithUsers['userDetails'][0]['userName'], 'TestUser');
      // expect(jsonWithUsers['userDetails'][0]['regionList'], ['region1']);
      // expect(jsonWithUsers['userDetails'][0]['segmentList'], ['segment1']);

      final role = Role(
        roleId: 1,
        name: "Admin",
        code: "ADMIN",
        bpmRole: "BPM_ADMIN",
        group: "GroupA",
        rights: {"canView": AccessType.none, "canEdit": AccessType.edit},
      );

      final json = role.toJson();

      expect(json["roleId"], 1);
      expect(json["roleName"], "Admin");
      expect(json["roleCode"], "ADMIN");
      expect(json["bpmRole"], "BPM_ADMIN");
      expect(json["roleGroup"], "GroupA");
      // expect(json['rights']['canView'], 2);
      expect(json["rights"]["canEdit"], 1);
    });

    test("getUserRole returns correct UserRole for valid code", () {
      expect(Role().getUserRole("ADM"), UserRole.admin);
      expect(Role().getUserRole("SHB"), UserRole.segmentHeadBusiness);
      expect(Role().getUserRole("RO"), UserRole.relationshipOfficer);
      expect(Role().getUserRole("CCOOD"), UserRole.creditCordinator);
      expect(Role().getUserRole("INQUSR"), UserRole.inquiryUser);
      expect(Role().getUserRole("TLB"), UserRole.teamLeaderBusiness);
      expect(Role().getUserRole("RMB"), UserRole.relationshipManagerBussiness);
      expect(Role().getUserRole("CAM"), UserRole.commercialAreaManager);
      expect(Role().getUserRole("CA"), UserRole.creditAnalyst);
      expect(Role().getUserRole("FPCOOD"), UserRole.financialPoolCoordinator);
      expect(Role().getUserRole("FPM"), UserRole.financialPoolMaker);
      expect(Role().getUserRole("FPC"), UserRole.financialPoolChecker);
      expect(Role().getUserRole("TL-D1"), UserRole.teamLeaderCreditLevelD1);
      expect(Role().getUserRole("SH-D"), UserRole.segmentHeadCreditLevelD);
      expect(Role().getUserRole("SH-C"), UserRole.segmentHeadLevelC);
      expect(Role().getUserRole("SH-B"), UserRole.segmentHeadLevelB);
      expect(Role().getUserRole("CCP"), UserRole.creditCommitteeProxy);
      expect(Role().getUserRole("BDP"), UserRole.boardDirectorProxy);
      expect(Role().getUserRole("CC"), UserRole.creditCommittee);
      expect(Role().getUserRole("BD"), UserRole.boardOfDirectors);
      expect(Role().getUserRole("LIT"), UserRole.limitInputTeam);
      expect(Role().getUserRole("LT"), UserRole.legalTeam);
      expect(Role().getUserRole("IAMADM"), UserRole.icsAdmin);
      expect(Role().getUserRole("LTCOOD"), UserRole.legalTeamCoordinator);
    });

    test("getUserRole returns null for invalid code", () {
      expect(Role().getUserRole("INVALID_CODE"), null);
    });

    test("fromLocalJson creates Role object correctly", () {
      final Map<String, dynamic> json = {
        "roleId": 1,
        "roleName": "Admin",
        "roleCode": "ADMIN",
        "bpmRole": "BPM_ADMIN",
        "roleGroup": "GroupA",
        "rights": {"canView": 0, "canEdit": 1},
        "routesAccessibility": {"dashboard": 2, "settings": 0},
        "userDetails": [
          {
            "userId": "1",
            "userName": "TestUser",
            "regionList": ["region1"],
            "segmentList": ["segment1"],
          }
        ],
      };

      final role = Role.fromLocalJson(json);

      expect(role.roleId, 1);
      expect(role.name, "Admin");
      expect(role.code, "ADMIN");
      expect(role.bpmRole, "BPM_ADMIN");
      expect(role.group, "GroupA");
      expect(role.rights!["canView"], AccessType.view);
      expect(role.rights!["canEdit"], AccessType.edit);
      expect(role.routesAccessibility!["dashboard"], MenuMode.hidden);
      expect(role.routesAccessibility!["settings"], MenuMode.enabled);
      expect(role.users!.length, 1);
      expect(role.users![0].userName, "TestUser");
    });

    test("fromLocalJson creates Role object correctly with null values", () {
      final json = {
        "roleId": 1,
        "roleName": "Test Role",
        "roleCode": "ADM",
        "bpmRole": "BPM_USER",
        "roleGroup": "GROUP_A",
        "rights": null,
        "routesAccessibility": null,
        "userDetails": null,
      };

      final role = Role.fromLocalJson(json);

      expect(role.id, null);
      expect(role.roleId, 1);
      expect(role.name, "Test Role");
      expect(role.userRole, UserRole.admin);
      expect(role.code, "ADM");
      expect(role.group, "GROUP_A");
      expect(role.bpmRole, "BPM_USER");
      expect(role.rights, null);
      expect(role.routesAccessibility, null);
      expect(role.users, null);
    });

    test("fromLocalJson handles null and empty values", () {
      final Map<String, dynamic> json = {};
      final role = Role.fromLocalJson(json);

      expect(role.roleId, null);
      expect(role.name, null);
      expect(role.code, null);
      expect(role.bpmRole, null);
      expect(role.group, null);
      expect(role.rights, null);
      expect(role.routesAccessibility, null);
      expect(role.users, null);
    });
  });

  group("Role.fromJsonCCSYS", () {
    test("parses CCSYS role JSON correctly", () {
      final json = {
        "roleId": 10,
        "roleRM": "Relationship Manager",
        "createdRM": "AdminUser",
      };

      final role = Role.fromJsonCCSYS(json);

      expect(role.roleId, 10);
      expect(role.roleRM, "Relationship Manager");
      expect(role.createdRM, "AdminUser");
    });

    test("handles null or missing values safely", () {
      final Map<String, dynamic> json = <String, dynamic>{}; // empty
      final role = Role.fromJsonCCSYS(json);

      expect(role.roleId, null);
      expect(role.roleRM, "null"); // because code uses '${json['roleRM']}'
      expect(role.createdRM, null);
    });
  });

  group("Role.fromJsonUsersByRoles", () {
    test("parses role with nested userDetails list", () {
      final json = {
        "roleId": 5,
        "role": "Supervisor",
        "bpmRoleName": "BPM_SUPERVISOR",
        "userDetails": [
          {
            "userId": "U100",
            "userName": "John Doe",
            "regionList": ["R1"],
            "segmentList": ["S1"],
            "isActive": 1,
            "isIslamic": 0,
            "authenticated": true,
          },
          {
            "userId": "U200",
            "userName": "Jane Smith",
            "regionList": ["R2"],
            "segmentList": ["S2"],
            "isActive": 1,
            "isIslamic": 1,
            "authenticated": false,
          }
        ],
      };

      final role = Role.fromJsonUsersByRoles(json);

      expect(role.roleId, 5);
      expect(role.code, "Supervisor");
      expect(role.bpmRole, "BPM_SUPERVISOR");

      // Validate user list
      expect(role.users, isA<List<User>>());
      expect(role.users!.length, 2);

      expect(role.users![0].id, "U100");
      expect(role.users![0].name, "John Doe");
      expect(role.users![0].regions, ["R1"]);
      expect(role.users![0].segments, ["S1"]);
      expect(role.users![0].active, true);
      expect(role.users![0].isIslamic, false);

      expect(role.users![1].id, "U200");
      expect(role.users![1].name, "Jane Smith");
      expect(role.users![1].regions, ["R2"]);
      expect(role.users![1].segments, ["S2"]);
      expect(role.users![1].active, true);
      expect(role.users![1].isIslamic, true);
    });

    test("handles null JSON and missing userDetails gracefully", () {
      final role = Role.fromJsonUsersByRoles(null);

      // Should still create a Role object without crashing
      expect(role.roleId, null);
      expect(role.name, null);
      expect(role.bpmRole, null);
      expect(role.users, isA<List<User>>());
      expect(role.users!.isEmpty, true);
    });

    test("handles empty userDetails list", () {
      final json = {
        "roleId": 3,
        "role": "Approver",
        "bpmRoleName": "BPM_APPR",
        "userDetails": [],
      };

      final role = Role.fromJsonUsersByRoles(json);

      expect(role.roleId, 3);
      expect(role.code, "Approver");
      expect(role.bpmRole, "BPM_APPR");
      expect(role.users, isA<List<User>>());
      expect(role.users!.isEmpty, true);
    });
  });
}
