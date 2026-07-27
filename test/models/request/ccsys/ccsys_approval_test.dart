import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/ccsys/ccsys_approval.dart";

void main() {
  group("CCSYSApproval", () {
    test("constructor should assign all provided values", () {
      final CCSYSApproval approval = CCSYSApproval(
        appRefNo: "APP-001",
        mode: 1,
        assignedTo: "user-001",
        assignedRole: "role-001",
        userAction: 2,
        commentId: 10,
        avoidWarning: true,
        approveOnBehalfOf: "user-002",
        approveOnBehalfOfRole: 5,
        returnToUser: true,
      );

      expect(approval.appRefNo, "APP-001");
      expect(approval.mode, 1);
      expect(approval.assignedTo, "user-001");
      expect(approval.assignedRole, "role-001");
      expect(approval.userAction, 2);
      expect(approval.commentId, 10);
      expect(approval.avoidWarning, true);
      expect(approval.approveOnBehalfOf, "user-002");
      expect(approval.approveOnBehalfOfRole, 5);
      expect(approval.returnToUser, true);
    });

    test("fromJson should parse all non-null json values correctly", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "appRefNo": "APP-002",
        "mode": 0,
        "assignedTo": "assigned-user",
        "assignedRole": "assigned-role",
        "userAction": 3,
        "commentId": 99,
        "avoidWarning": true,
        "approveOnBehalfOf": "behalf-user",
        "approveOnBehalfOfRole": 7,
        "returnToUser": false,
      };

      final CCSYSApproval approval = CCSYSApproval.fromJson(json);

      expect(approval.appRefNo, "APP-002");
      expect(approval.mode, 0);
      expect(approval.assignedTo, "assigned-user");
      expect(approval.assignedRole, "assigned-role");
      expect(approval.userAction, 3);
      expect(approval.commentId, 99);
      expect(approval.avoidWarning, true);
      expect(approval.approveOnBehalfOf, "behalf-user");
      expect(approval.approveOnBehalfOfRole, 7);
      expect(approval.returnToUser, false);
    });

    test("fromJson should parse nullable approve on behalf fields as null", () {
      final Map<String, dynamic> json = <String, dynamic>{
        "appRefNo": "APP-003",
        "mode": 0,
        "assignedTo": "assigned-user",
        "assignedRole": "assigned-role",
        "userAction": 1,
        "commentId": 15,
        "avoidWarning": false,
        "approveOnBehalfOf": null,
        "approveOnBehalfOfRole": null,
        "returnToUser": true,
      };

      final CCSYSApproval approval = CCSYSApproval.fromJson(json);

      expect(approval.appRefNo, "APP-003");
      expect(approval.mode, 0);
      expect(approval.assignedTo, "assigned-user");
      expect(approval.assignedRole, "assigned-role");
      expect(approval.userAction, 1);
      expect(approval.commentId, 15);
      expect(approval.avoidWarning, false);
      expect(approval.approveOnBehalfOf, isNull);
      expect(approval.approveOnBehalfOfRole, isNull);
      expect(approval.returnToUser, true);
    });

    test("toJson should return all assigned values correctly", () {
      final CCSYSApproval approval = CCSYSApproval(
        appRefNo: "APP-004",
        mode: 2,
        assignedTo: "user-a",
        assignedRole: "role-a",
        userAction: 4,
        commentId: 20,
        avoidWarning: true,
        approveOnBehalfOf: "user-b",
        approveOnBehalfOfRole: 8,
        returnToUser: true,
      );

      final Map<String, dynamic> json = approval.toJson();

      expect(json, <String, dynamic>{
        "appRefNo": "APP-004",
        "mode": 2,
        "assignedTo": "user-a",
        "assignedRole": "role-a",
        "userAction": 4,
        "commentId": 20,
        "avoidWarning": true,
        "approveOnBehalfOf": "user-b",
        "approveOnBehalfOfRole": 8,
        "returnToUser": true,
      });
    });

    test("toJson should apply default values when nullable fields are not set", () {
      final CCSYSApproval approval = CCSYSApproval();

      final Map<String, dynamic> json = approval.toJson();

      expect(json["appRefNo"], isNull);
      expect(json["mode"], 0);
      expect(json["assignedTo"], "");
      expect(json["assignedRole"], "");
      expect(json["userAction"], 0);
      expect(json["commentId"], 0);
      expect(json["avoidWarning"], false);
      expect(json["approveOnBehalfOf"], isNull);
      expect(json["approveOnBehalfOfRole"], isNull);
      expect(json["returnToUser"], false);
    });

    test("toJson should mutate nullable fields that use null-aware assignment", () {
      final CCSYSApproval approval = CCSYSApproval()

      ..toJson();

      expect(approval.mode, 0);
      expect(approval.assignedTo, "");
      expect(approval.assignedRole, "");
      expect(approval.userAction, 0);
      expect(approval.commentId, 0);
      expect(approval.avoidWarning, false);
      expect(approval.returnToUser, false);

      expect(approval.appRefNo, isNull);
      expect(approval.approveOnBehalfOf, isNull);
      expect(approval.approveOnBehalfOfRole, isNull);
    });
  });
}
