/// Represents audit information for a request.
class Audit {
  /// Creates an [Audit] instance.
  Audit({
    this.role,
    this.roleID,
    this.channelID,
    this.sessionID,
    this.userID,
    this.userName,
    this.pageId,
    this.rqUID,
    this.requestData,
    this.appRefNo,
  });

  /// Creates an [Audit] instance from a JSON map.
  Audit.fromJson(Map<String, dynamic> json) {
    role = json["role"];
    roleID = json["roleID"];
    channelID = json["channelID"];
    sessionID = json["sessionID"];
    userID = json["userID"];
    userName = json["userName"];
    pageId = json["pageId"];
    rqUID = json["rqUID"];
    requestData = json["requestData"];
    appRefNo = json["appRefNo"];
  }

  /// Role name.
  String? role;

  /// Role identifier.
  int? roleID;

  /// Channel identifier.
  String? channelID;

  /// Session identifier.
  String? sessionID;

  /// User identifier.
  String? userID;

  /// User name.
  String? userName;

  /// Page identifier.
  int? pageId;

  /// Request unique ID.
  String? rqUID;

  /// Request payload data.
  String? requestData;

  /// Application reference number.
  String? appRefNo;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["role"] = role;
    data["roleID"] = roleID;
    data["channelID"] = channelID;
    data["sessionID"] = sessionID;
    data["userID"] = userID;
    data["userName"] = userName;
    data["pageId"] = pageId;
    data["rqUID"] = rqUID;
    data["requestData"] = requestData;
    data["appRefNo"] = appRefNo;
    return data;
  }
}
