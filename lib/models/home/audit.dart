class Audit {
  String? role;
  int? roleID;
  String? channelID;
  String? sessionID;
  String? userID;
  String? userName;
  int? pageId;
  String? rqUID;
  String? requestData;
  String? appRefNo;

  Audit(
      {this.role,
      this.roleID,
      this.channelID,
      this.sessionID,
      this.userID,
      this.userName,
      this.pageId,
      this.rqUID,
      this.requestData,
      this.appRefNo});

  Audit.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    roleID = json['roleID'];
    channelID = json['channelID'];
    sessionID = json['sessionID'];
    userID = json['userID'];
    userName = json['userName'];
    pageId = json['pageId'];
    rqUID = json['rqUID'];
    requestData = json['requestData'];
    appRefNo = json['appRefNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['roleID'] = roleID;
    data['channelID'] = channelID;
    data['sessionID'] = sessionID;
    data['userID'] = userID;
    data['userName'] = userName;
    data['pageId'] = pageId;
    data['rqUID'] = rqUID;
    data['requestData'] = requestData;
    data['appRefNo'] = appRefNo;
    return data;
  }
}
