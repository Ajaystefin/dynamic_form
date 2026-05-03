class CCSYSApproval {
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
  String? appRefNo;
  int? mode; // always 0 per your note
  String? assignedTo; // userId to whom the task is assigned
  String? assignedRole; // role id to whom the task is assigned
  int? userAction;
  int? commentId; // review comment Id
  bool? avoidWarning;
  String? approveOnBehalfOf; // nullable
  int? approveOnBehalfOfRole; // nullable
  bool? returnToUser;

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
