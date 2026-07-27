import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

void main() {
  group("User", () {
    test("fromJson creates User object correctly", () {
      final Map<String, dynamic> json = {
        "userDetailId": 1,
        "userId": "user123",
        "userName": "Test User",
        "regionList": ["Region A", "Region B"],
        "segmentList": ["Segment X", "Segment Y"],
        "approveOnBehalfOf": 1,
        "approvalAccess": 1,
        "tranApprovalAccess": 0,
        "accessToVipCust": 1,
        "createdBy": "Admin",
        "createdDate": "2023-01-01",
        "designation": "Manager",
        "email": "test@example.com",
        "isIslamic": 1,
        "isActive": 1,
        "authenticated": true,
        "currentRole": {
          "roleId": 1,
          "roleName": "Admin",
          "roleCode": "ADM",
        },
        "availableRoles": [
          {
            "roleId": 1,
            "roleName": "Admin",
            "roleCode": "ADM",
          },
          {
            "roleId": 2,
            "roleName": "User",
            "roleCode": "USR",
          },
        ],
        "department": "IT",
      };

      final user = User.fromJson(json);

      expect(user.userDetailId, 1);
      expect(user.id, "user123");
      expect(user.name, "Test User");
      expect(user.userName, "Test User");
      expect(user.regions, ["Region A", "Region B"]);
      expect(user.segments, ["Segment X", "Segment Y"]);
      expect(user.approveOnBehalfOf, true);
      expect(user.approvalAccess, true);
      expect(user.tranApprovalAccess, false);
      expect(user.accessToVipCust, true);
      expect(user.createdBy, "Admin");
      expect(user.createdDate, "2023-01-01");
      expect(user.designation, "Manager");
      expect(user.email, "test@example.com");
      expect(user.isIslamic, true);
      expect(user.active, true);
      expect(user.authenticated, true);
      expect(user.currentRole, isA<Role>());
      expect(user.currentRole!.roleId, 1);
      expect(user.availableRoles, isA<List<Role>>());
      expect(user.availableRoles!.length, 2);
      expect(user.availableRoles![0].roleId, 1);
      expect(user.availableRoles![1].roleId, 2);
    });

    test("fromJson handles null and empty values", () {
      final Map<String, dynamic> json = {};
      final user = User.fromJson(json);

      expect(user.userDetailId, null);
      expect(user.id, null);
      expect(user.name, null);
      expect(user.regions, []);
      expect(user.segments, []);
      expect(user.approveOnBehalfOf, false);
      expect(user.approvalAccess, false);
      expect(user.tranApprovalAccess, false);
      expect(user.accessToVipCust, false);
      expect(user.createdBy, null);
      expect(user.createdDate, null);
      expect(user.designation, null);
      expect(user.email, null);
      expect(user.isIslamic, false);
      expect(user.active, false);
      expect(user.authenticated, false);
      expect(user.currentRole, null);
      expect(user.availableRoles, null);
      expect(user.department, null);
    });

    test("fromLocalJson creates User object correctly", () {
      final Map<String, dynamic> json = {
        "userDetailId": 1,
        "userId": "user123",
        "userName": "Test User",
        "regionList": ["Region A", "Region B"],
        "segmentList": ["Segment X", "Segment Y"],
        "approveOnBehalfOf": 1,
        "approvalAccess": 1,
        "tranApprovalAccess": 0,
        "accessToVipCust": 1,
        "createdBy": "Admin",
        "createdDate": "2023-01-01",
        "designation": "Manager",
        "email": "test@example.com",
        "isIslamic": 1,
        "isActive": 1,
        "authenticated": true,
        "currentRole": {
          "roleId": 1,
          "roleName": "Admin",
          "roleCode": "ADM",
        },
        "availableRoles": [
          {
            "roleId": 1,
            "roleName": "Admin",
            "roleCode": "ADM",
          },
          {
            "roleId": 2,
            "roleName": "User",
            "roleCode": "USR",
          },
        ],
        "department": "IT",
      };

      final user = User.fromLocalJson(json);

      expect(user.userDetailId, 1);
      expect(user.id, "user123");
      expect(user.name, "Test User");
      expect(user.userName, "Test User");
      expect(user.regions, ["Region A", "Region B"]);
      expect(user.segments, ["Segment X", "Segment Y"]);
      expect(user.approveOnBehalfOf, true);
      expect(user.approvalAccess, true);
      expect(user.tranApprovalAccess, false);
      expect(user.accessToVipCust, true);
      expect(user.createdBy, "Admin");
      expect(user.createdDate, "2023-01-01");
      expect(user.designation, "Manager");
      expect(user.email, "test@example.com");
      expect(user.isIslamic, true);
      expect(user.active, true);
      expect(user.authenticated, true);
      expect(user.currentRole, isA<Role>());
      expect(user.currentRole!.roleId, 1);
      expect(user.availableRoles, isA<List<Role>>());
      expect(user.availableRoles!.length, 2);
      expect(user.availableRoles![0].roleId, 1);
      expect(user.availableRoles![1].roleId, 2);
      expect(user.department, null);
    });

    test("fromLocalJson handles null and empty values", () {
      final Map<String, dynamic> json = {};
      final user = User.fromLocalJson(json);

      expect(user.userDetailId, null);
      expect(user.id, null);
      expect(user.name, null);
      expect(user.regions, []);
      expect(user.segments, []);
      expect(user.approveOnBehalfOf, false);
      expect(user.approvalAccess, false);
      expect(user.tranApprovalAccess, false);
      expect(user.accessToVipCust, false);
      expect(user.createdBy, null);
      expect(user.createdDate, null);
      expect(user.designation, null);
      expect(user.email, null);
      expect(user.isIslamic, false);
      expect(user.active, false);
      expect(user.authenticated, false);
      expect(user.currentRole, null);
      expect(user.availableRoles, null);
      expect(user.department, null);
    });

    test("toJson converts User object to JSON correctly", () {
      final user = User(
        userDetailId: 1,
        id: "user123",
        name: "Test User",
        userName: "Test User",
        regions: ["Region A", "Region B"],
        segments: ["Segment X", "Segment Y"],
        approveOnBehalfOf: true,
        approvalAccess: true,
        tranApprovalAccess: false,
        accessToVipCust: true,
        createdBy: "Admin",
        createdDate: "2023-01-01",
        designation: "Manager",
        email: "test@example.com",
        isIslamic: true,
        active: true,
        authenticated: true,
        currentRole: Role(roleId: 1, name: "Admin", code: "ADM"),
        availableRoles: [
          Role(roleId: 1, name: "Admin", code: "ADM"),
          Role(roleId: 2, name: "User", code: "USR"),
        ],
        department: "IT",
      );

      final json = user.toJson();

      expect(json["userDetailId"], 1);
      expect(json["userId"], "user123");
      expect(json["userName"], "Test User");
      expect(json["regionList"], ["Region A", "Region B"]);
      expect(json["segmentList"], ["Segment X", "Segment Y"]);
      expect(json["approveOnBehalfOf"], 1);
      expect(json["approvalAccess"], 1);
      expect(json["tranApprovalAccess"], 0);
      expect(json["accessToVipCust"], 1);
      expect(json["createdBy"], "Admin");
      expect(json["createdDate"], "2023-01-01");
      expect(json["designation"], "Manager");
      expect(json["email"], "test@example.com");
      expect(json["isIslamic"], 1);
      expect(json["isActive"], 1);
      expect(json["authenticated"], 1);
      expect(json["currentRole"], isA<Map<String, dynamic>>());
      expect(json["currentRole"]["roleId"], 1);
      expect(json["availableRoles"], isA<List>());
      expect(json["availableRoles"].length, 2);
      expect(json["availableRoles"][0]["roleId"], 1);
      expect(json["availableRoles"][1]["roleId"], 2);
      expect(json["department"], "IT"); // Department is included in toJson
    });

    test("toJson handles null values", () {
      final user = User();
      final json = user.toJson();

      expect(json["userDetailId"], null);
      expect(json["userId"], null);
      expect(json["userName"], null);
      expect(json["regionList"], null);
      expect(json["segmentList"], null);
      expect(json["approveOnBehalfOf"], 0);
      expect(json["approvalAccess"], 0);
      expect(json["tranApprovalAccess"], 0);
      expect(json["accessToVipCust"], 0);
      expect(json["createdBy"], null);
      expect(json["createdDate"], null);
      expect(json["designation"], null);
      expect(json["email"], null);
      expect(json["isIslamic"], 0);
      expect(json["isActive"], 0);
      expect(json["authenticated"], 0);
      expect(json["currentRole"], null);
      expect(json["availableRoles"], null);
      expect(json["department"], null);
    });
  });

  group("User.toSaveDetailsJson", () {
    test("toSaveDetailsJson converts filled User correctly", () {
      final user = User(
        userDetailId: 42,
        id: "u-001",
        name: "Display Name",
        userName: "login."
            "username", // NOTE: this should be the final value for userName
        regions: ["R1", "R2"],
        segments: ["S1", "S2"],
        approveOnBehalfOf: true,
        approvalAccess: true,
        tranApprovalAccess: false,
        accessToVipCust: true,
        createdBy: "System",
        createdDate: "2025-01-01",
        designation: "Lead",
        email: "user@example.com",
        isIslamic: true,
        active: true,
        authenticated: true,
        department: "IT",
        availableRoles: [
          Role(roleId: 1, name: "Admin", code: "ADM"),
          Role(roleId: 2, name: "User", code: "USR"),
        ],
        // currentRole is intentionally ignored by toSaveDetailsJson
      );

      final json = user.toSaveDetailsJson();

      // Scalars
      expect(json["userDetailId"], 42);
      expect(json["userId"], "u-001");

      // userName should reflect the field `user.userName`, since the method
      // assigns it last
      expect(json["userName"], "login.username");

      // Collections
      expect(json["regionList"], ["R1", "R2"]);
      expect(json["segmentList"], ["S1", "S2"]);

      // Booleans to 1/0
      expect(json["approveOnBehalfOf"], 1);
      expect(json["approvalAccess"], 1);
      expect(json["tranApprovalAccess"], 0);
      expect(json["accessToVipCust"], 1);
      expect(json["isIslamic"], 1);
      expect(json["isActive"], 1);
      expect(json["authenticated"], 1);

      // Other fields
      expect(json["createdBy"], "System");
      expect(json["createdDate"], "2025-01-01");
      expect(json["designation"], "Lead");
      expect(json["email"], "user@example.com");
      expect(json["department"], "IT");

      // currentRole is not part of toSaveDetailsJson
      expect(json.containsKey("currentRole"), false);

      // roleList should be derived from availableRoles.code
      expect(json["roleList"], isA<List>());
      expect(json["roleList"], ["ADM", "USR"]);
    });

    test("toSaveDetailsJson handles null/default values", () {
      final user = User(); // everything null/false by default

      final json = user.toSaveDetailsJson();

      // Nullables remain null
      expect(json["userDetailId"], null);
      expect(json["userId"], null);
      expect(json["userName"], null);
      expect(json["regionList"], null);
      expect(json["segmentList"], null);
      expect(json["createdBy"], null);
      expect(json["createdDate"], null);
      expect(json["designation"], null);
      expect(json["email"], null);
      expect(json["department"], null);

      // Booleans become 0
      expect(json["approveOnBehalfOf"], 0);
      expect(json["approvalAccess"], 0);
      expect(json["tranApprovalAccess"], 0);
      expect(json["accessToVipCust"], 0);
      expect(json["isIslamic"], 0);
      expect(json["isActive"], 0);
      expect(json["authenticated"], 0);

      // availableRoles is null → roleList should not be present
      expect(json.containsKey("roleList"), false);
    });

    test("toSaveDetailsJson trims codes for roleList", () {
      final user = User(
        availableRoles: [
          Role(roleId: 1, name: "Admin", code: " ADM "),
          Role(roleId: 2, name: "User", code: "  USR"),
          Role(roleId: 3, name: "Viewer", code: "VWR  "),
          Role(roleId: 4, name: "EmptyBecomesEmpty"),
        ],
      );

      final json = user.toSaveDetailsJson();

      expect(json["roleList"], ["ADM", "USR", "VWR", ""]);
    });
  });

  group("User.copyWith", () {
    test("copyWith updates only provided fields and preserves others", () {
      final original = User(
        userDetailId: 10,
        id: "id-10",
        name: "Original Name",
        userName: "original.username",
        regions: ["R-A"],
        segments: ["S-A"],
        approveOnBehalfOf: false,
        approvalAccess: false,
        tranApprovalAccess: true,
        accessToVipCust: true,
        createdBy: "Origin",
        createdDate: "2024-01-01",
        designation: "Engineer",
        email: "o@example.com",
        isIslamic: false,
        active: true,
        authenticated: true,
        department: "Ops",
        availableRoles: [Role(roleId: 1, name: "Admin", code: "ADM")],
      );

      final updated = original.copyWith(
        name: "Updated Name",
        userName: "updated.username",
        regions: ["R-A", "R-B"],
        approveOnBehalfOf: true,
        availableRoles: [
          Role(roleId: 1, name: "Admin", code: "ADM"),
          Role(roleId: 2, name: "User", code: "USR"),
        ],
      );

      // Updated fields
      expect(updated.name, "Updated Name");
      expect(updated.userName, "updated.username");
      expect(updated.regions, ["R-A", "R-B"]);
      expect(updated.approveOnBehalfOf, true);
      expect(updated.availableRoles!.length, 2);

      // Preserved fields
      expect(updated.userDetailId, original.userDetailId);
      expect(updated.id, original.id);
      expect(updated.segments, original.segments);
      expect(updated.approvalAccess, original.approvalAccess);
      expect(updated.tranApprovalAccess, original.tranApprovalAccess);
      expect(updated.accessToVipCust, original.accessToVipCust);
      expect(updated.createdBy, original.createdBy);
      expect(updated.createdDate, original.createdDate);
      expect(updated.designation, original.designation);
      expect(updated.email, original.email);
      expect(updated.isIslamic, original.isIslamic);
      expect(updated.active, original.active);
      expect(updated.authenticated, original.authenticated);
      expect(updated.department, original.department);
    });
  });
}
