import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/user.dart";

/// Represents role information including role details, rights,
/// route accessibility, assigned users, and RM mapping details.
class Role {
  /// Creates a [Role] instance.
  Role({
    this.id,
    this.bpmRole,
    this.name,
    this.code,
    this.group,
    this.roleId,
    this.rights,
    this.users,
    this.routesAccessibility,
    this.userRole,
    this.createdRM,
    this.roleRM,
  });

  /// Creates a [Role] instance from CCSYS JSON data.
  Role.fromJsonCCSYS(Map<String, dynamic> json) {
    roleId = json["roleId"];
    roleRM = '${json['roleRM']}';
    //createdBy = json['createdBy'];
    createdRM = json["createdRM"];
  }

  /// Creates a [Role] instance from users-by-roles JSON data.
  factory Role.fromJsonUsersByRoles(Map<String, dynamic>? json) {
    final List<User> users = ((json?["userDetails"] as List?) ?? [])
        .map((e) => User.fromJson(e))
        .toList();
    return Role(
      roleId: json?["roleId"] as int?,
      code: json?["role"] as String?,
      bpmRole: json?["bpmRoleName"] as String?,
      users: users,
    );
  }

  /// Creates a [Role] instance from a JSON map.
  Role.fromJson(Map<String, dynamic> json) {
    Map<String, AccessType>? parsedRights;

    if (json["rights"] != null && json["rights"] is Map) {
      parsedRights = {};
      try {
        (json["rights"] as Map).forEach((key, value) {
          if (key is String && value is int) {
            logger.i("value is $value length is ${AccessType.values.length}");
            parsedRights![key] = value < AccessType.values.length
                ? AccessType.values[value]
                : AccessType.none;
          }
        });
      } on Object {
        parsedRights = {};
      }
    }

    roleId = json["roleId"];
    name = json["roleName"] ?? json["role"];
    userRole = getUserRole(json["roleCode"]);
    code = json["roleCode"];

    bpmRole = json["bpmRole"] ?? json["bpmRoleName"];

    group = json["roleGroup"];
    rights = parsedRights;

    if (json["userDetails"] != null && json["userDetails"] is List) {
      users = (json["userDetails"] as List)
          .map((value) => User.fromJson(value as Map<String, dynamic>))
          .toList();
    }
  }

  /// Creates a [Role] instance from local JSON data.
  Role.fromLocalJson(Map<String, dynamic> json) {
    // Map<String, AccessType>? parsedRights;
    // Map<String, MenuMode>? parsedMenuModes;
    // if (json['rights'] != null && json['rights'] is Map) {
    //   parsedRights = {};
    //   try {
    //     (json['rights'] as Map).forEach((key, value) {
    //       if (key is String && value is int) {
    //         parsedRights![key] = value < AccessType.values.length
    //             ? AccessType.values[value]
    //             : AccessType.none;
    //       }
    //     });

    //     parsedRights = {};
    //   } on Object catch (e) {
    //     parsedRights = {};
    //   }
    // }
    // if (json['routesAccessibility'] != null &&
    //     json['routesAccessibility'] is Map) {
    //   parsedMenuModes = {};
    //   try {
    //     (json['routesAccessibility'] as Map).forEach((key, value) {
    //       if (key is String && value is int) {
    //         parsedMenuModes![key] = value < MenuMode.values.length
    //             ? MenuMode.values[value]
    //             : MenuMode.hidden;
    //       }
    //     });

    //     parsedMenuModes = {};
    //   } on Object catch (e) {
    //     parsedMenuModes = {};
    //   }
    // }
    roleId = json["roleId"];
    name = json["roleName"];
    userRole = getUserRole(json["roleCode"]);
    code = json["roleCode"];
    bpmRole = json["bpmRole"];
    group = json["roleGroup"];

    // rights = parsedRights;
    // routesAccessibility = parsedMenuModes;

    rights = json["rights"] != null
        ? Map<String, AccessType>.from(
            json["rights"]
                .map((key, value) => MapEntry(key, AccessType.values[value])),
          )
        : null;
    routesAccessibility = json["routesAccessibility"] != null
        ? Map<String, MenuMode>.from(
            json["routesAccessibility"]
                .map((key, value) => MapEntry(key, MenuMode.values[value])),
          )
        : null;

    if (json["userDetails"] != null && json["userDetails"] is List) {
      users = (json["userDetails"] as List)
          .map((value) => User.fromJson(value as Map<String, dynamic>))
          .toList();
    }
  }

  /// Unique identifier of the role.
  int? id;

  /// Role identifier.
  int? roleId;

  /// Name of the role.
  String? name;

  /// User role associated with this role.
  UserRole? userRole;

  /// Role code.
  String? code;

  /// Role group.
  String? group;

  /// Access rights mapped by feature or page key.
  Map<String, AccessType>? rights;

  /// Route accessibility mapped by route key.
  Map<String, MenuMode>? routesAccessibility;

  /// List of users assigned to this role.
  List<User>? users;

  /// BPM role name associated with this role.
  String? bpmRole;

  /// Created RM value.
  String? createdRM;

  /// Role RM value.
  String? roleRM;

  /// Returns the [UserRole] matching the provided role code.
  UserRole? getUserRole(String? roleId) {
    UserRole? userRole;
    if (ServerConstants.userRoleCode.containsValue(roleId)) {
      ServerConstants.userRoleCode.forEach((UserRole role, String roleCode) {
        if (roleId == roleCode) {
          userRole = role;
        }
      });
    }
    return userRole;
  }

  /// Converts this [Role] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["roleId"] = roleId;
    data["roleName"] = name;
    data["roleCode"] = code;
    data["roleGroup"] = group;
    data["bpmRole"] = bpmRole;
    data["rights"] = rights?.map((key, value) => MapEntry(key, value.index));
    data["routesAccessibility"] =
        routesAccessibility?.map((key, value) => MapEntry(key, value.index));
    // data['userDetails'] = users?.map((value) => value.toJson()).toList();
    return data;
  }
}
