/// Represents CCSYS approval request details including assignment,
/// user action, comments, warning handling, and return-to-user flags.
class CCSYSApproval {
  /// Creates a [CCSYSApproval] instance.
  CCSYSApproval({
    this.appRefNo,
    this.mode,
    this.assignedTo,
    this.assignedRole,
    this.userAction,
    this.commentId,
    this.avoidWarning,
    this.approveOnBehalfOf,
    this.approveOnBehalfOfRole,
    this.returnToUser,
  });

  /// Creates a [CCSYSApproval] instance from a JSON map.
  factory CCSYSApproval.fromJson(Map<String, dynamic> json) {
    return CCSYSApproval(
      appRefNo: json["appRefNo"] as String,
      mode: (json["mode"] as num).toInt(),
      assignedTo: json["assignedTo"] as String,
      assignedRole: json["assignedRole"] as String,
      userAction: (json["userAction"] as num).toInt(),
      commentId: (json["commentId"] as num).toInt(),
      avoidWarning: json["avoidWarning"] as bool,
      approveOnBehalfOf: json["approveOnBehalfOf"] as String?,
      approveOnBehalfOfRole: json["approveOnBehalfOfRole"] == null
          ? null
          : (json["approveOnBehalfOfRole"] as num).toInt(),
      returnToUser: json["returnToUser"] as bool,
    );
  }

  /// Application reference number.
  String? appRefNo;

  /// Approval mode.
  int? mode; // always 0 per your note

  /// User ID to whom the task is assigned.
  String? assignedTo; // userId to whom the task is assigned

  /// Role ID to whom the task is assigned.
  String? assignedRole; // role id to whom the task is assigned

  /// User action value.
  int? userAction;

  /// Review comment identifier.
  int? commentId; // review comment Id

  /// Indicates whether warning should be avoided.
  bool? avoidWarning;

  /// User on behalf of whom approval is performed.
  String? approveOnBehalfOf; // nullable

  /// Role on behalf of which approval is performed.
  int? approveOnBehalfOfRole; // nullable

  /// Indicates whether the task should be returned to user.
  bool? returnToUser;

  /// Converts this [CCSYSApproval] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "appRefNo": appRefNo,
      "mode": mode ??= 0,
      "assignedTo": assignedTo ??= "",
      "assignedRole": assignedRole ??= "",
      "userAction": userAction ??= 0,
      "commentId": commentId ??= 0,
      "avoidWarning": avoidWarning ??= false,
      "approveOnBehalfOf": approveOnBehalfOf,
      "approveOnBehalfOfRole": approveOnBehalfOfRole,
      "returnToUser": returnToUser ??= false,
    };
  }
}
