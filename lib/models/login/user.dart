import "package:wcas_frontend/models/login/role.dart";

class User {
  User({
    this.availableRoles,
    this.selectedRole,
    this.userDetailId,
    this.id,
    this.name,
    this.selectedRoleId,
    this.selectedRoleName,
    this.regions,
    this.segments,
    this.approveOnBehalfOf,
    this.approvalAccess,
    this.tranApprovalAccess,
    this.accessToVipCust,
    this.createdBy,
    this.createdDate,
    this.designation,
    this.email,
    this.isIslamic,
    this.authenticated,
    this.active,
    this.userName,
    this.currentRole,
    this.department,
  });
  User.fromJson(
    Map<String, dynamic> json, {
    String? selectedRole,
    int? selectedRoleId,
    String? selectedRoleName,
  }) {
    // debugPrint("segmentList is ${json['segmentList']}");
    userDetailId = json["userDetailId"];
    id = json["userId"];
    name = json["userName"];
    userName = json["userName"];
    regions = List<String>.from(json["regionList"] ?? []);
    segments = List<String>.from(json["segmentList"] ?? []);
    approveOnBehalfOf = (json["approveOnBehalfOf"] is bool
        ? json["approveOnBehalfOf"]
        : json["approveOnBehalfOf"] == 1);

    approvalAccess = (json["approvalAccess"] is bool
        ? json["approvalAccess"]
        : json["approvalAccess"] == 1);

    tranApprovalAccess = (json["tranApprovalAccess"] is bool
        ? json["tranApprovalAccess"]
        : json["tranApprovalAccess"] == 1);

    accessToVipCust = (json["accessToVipCust"] is bool
        ? json["accessToVipCust"]
        : json["accessToVipCust"] == 1);

    isIslamic = (json["isIslamic"] is bool
        ? json["isIslamic"]
        : json["isIslamic"] == 1);

    active =
        (json["isActive"] is bool ? json["isActive"] : json["isActive"] == 1);

    authenticated = (json["authenticated"] is bool
        ? json["authenticated"]
        : json["authenticated"] == 1);

    createdBy = json["createdBy"];
    createdDate = json["createdDate"];
    designation = json["designation"];
    email = json["email"];

    currentRole = json["currentRole"] != null
        ? Role.fromJson(Map<String, dynamic>.from(json["currentRole"]))
        : null;
    availableRoles = json["availableRoles"] != null
        ? List<Role>.from(
            (json["availableRoles"] as List).map(
              (item) => Role.fromJson(Map<String, dynamic>.from(item)),
            ),
          )
        : null;
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    userDetailId = json["userDetailId"];
    id = json["userId"];
    name = json["userName"];
    userName = json["userName"];
    regions = List<String>.from(json["regionList"] ?? []);
    segments = List<String>.from(json["segmentList"] ?? []);
    approveOnBehalfOf = json["approveOnBehalfOf"] == 1;
    approvalAccess = json["approvalAccess"] == 1;
    tranApprovalAccess = json["tranApprovalAccess"] == 1;
    accessToVipCust = json["accessToVipCust"] == 1;
    createdBy = json["createdBy"];
    createdDate = json["createdDate"];
    designation = json["designation"];
    email = json["email"];

    isIslamic = json["isIslamic"] == 1;
    active = json["isActive"] == 1;

    authenticated = (json["authenticated"] is bool
        ? json["authenticated"]
        : json["authenticated"] == 1);
    currentRole = json["currentRole"] != null
        ? Role.fromLocalJson(Map<String, dynamic>.from(json["currentRole"]))
        : null;
    availableRoles = json["availableRoles"] != null
        ? List<Role>.from(
            (json["availableRoles"] as List).map(
              (item) => Role.fromLocalJson(Map<String, dynamic>.from(item)),
            ),
          )
        : null;
  }
  List<Role>? availableRoles;
  int? userDetailId;
  String? id;
  String? name;
  List<String>? regions;
  List<String>? segments;
  bool? approveOnBehalfOf;
  bool? approvalAccess;
  bool? tranApprovalAccess;
  bool? accessToVipCust;
  String? createdBy;
  String? createdDate;
  String? designation;
  String? email;
  bool? isIslamic;
  bool? active;
  bool? authenticated;
  Role? currentRole;
  String? userName;
  String? department;
  String? selectedRole;
  int? selectedRoleId;
  String? selectedRoleName;

  int? expiresIn;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["userDetailId"] = userDetailId;
    data["userId"] = id;
    data["userName"] = name;
    data["regionList"] = regions;
    data["segmentList"] = segments;
    data["approveOnBehalfOf"] = approveOnBehalfOf == true ? 1 : 0;
    data["approvalAccess"] = approvalAccess == true ? 1 : 0;
    data["tranApprovalAccess"] = tranApprovalAccess == true ? 1 : 0;
    data["accessToVipCust"] = accessToVipCust == true ? 1 : 0;
    data["createdBy"] = createdBy;
    data["createdDate"] = createdDate;
    data["designation"] = designation;
    data["email"] = email;
    data["isIslamic"] = isIslamic == true ? 1 : 0;
    data["isActive"] = active == true ? 1 : 0;

    data["authenticated"] = authenticated == true ? 1 : 0;
    data["currentRole"] = currentRole?.toJson();
    data["userName"] = userName;

    if (availableRoles != null) {
      data["availableRoles"] =
          availableRoles!.map((value) => value.toJson()).toList();
    }
    data["department"] = department;
    if (availableRoles != null) {
      data["roleList"] =
          availableRoles!.map((role) => role.code?.trim() ?? "").toList();
    }

    return data;
  }

  Map<String, dynamic> toSaveDetailsJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["userDetailId"] = userDetailId;
    data["userId"] = id;
    data["userName"] = name;
    data["regionList"] = regions;
    data["segmentList"] = segments;
    data["approveOnBehalfOf"] = approveOnBehalfOf == true ? 1 : 0;
    data["approvalAccess"] = approvalAccess == true ? 1 : 0;
    data["tranApprovalAccess"] = tranApprovalAccess == true ? 1 : 0;
    data["accessToVipCust"] = accessToVipCust == true ? 1 : 0;
    data["createdBy"] = createdBy;
    data["createdDate"] = createdDate;
    data["designation"] = designation;
    data["email"] = email;
    data["isIslamic"] = isIslamic == true ? 1 : 0;
    data["isActive"] = active == true ? 1 : 0;
    data["authenticated"] = authenticated == true ? 1 : 0;
    data["userName"] = userName;
    data["department"] = department;
    if (availableRoles != null) {
      data["roleList"] =
          availableRoles!.map((role) => role.code?.trim() ?? "").toList();
    }
    return data;
  }

  //For only unit testing purpose
  User copyWith({
    List<Role>? availableRoles,
    int? userDetailId,
    String? id,
    String? name,
    List<String>? regions,
    List<String>? segments,
    bool? approveOnBehalfOf,
    bool? approvalAccess,
    bool? tranApprovalAccess,
    bool? accessToVipCust,
    String? createdBy,
    String? createdDate,
    String? designation,
    String? email,
    bool? isIslamic,
    bool? active,
    bool? authenticated,
    Role? currentRole,
    String? userName,
    String? department,
    String? selectedRole,
    int? selectedRoleId,
    String? selectedRoleName,
  }) {
    return User(
      availableRoles: availableRoles ?? this.availableRoles,
      userDetailId: userDetailId ?? this.userDetailId,
      id: id ?? this.id,
      name: name ?? this.name,
      regions: regions ?? this.regions,
      segments: segments ?? this.segments,
      approveOnBehalfOf: approveOnBehalfOf ?? this.approveOnBehalfOf,
      approvalAccess: approvalAccess ?? this.approvalAccess,
      tranApprovalAccess: tranApprovalAccess ?? this.tranApprovalAccess,
      accessToVipCust: accessToVipCust ?? this.accessToVipCust,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      isIslamic: isIslamic ?? this.isIslamic,
      active: active ?? this.active,
      authenticated: authenticated ?? this.authenticated,
      currentRole: currentRole ?? this.currentRole,
      userName: userName ?? this.userName,
      department: department ?? this.department,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedRoleId: selectedRoleId ?? this.selectedRoleId,
      selectedRoleName: selectedRoleName ?? this.selectedRoleName,
    );
  }
}
