import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/page.dart';
import 'package:wcas_frontend/models/login/user.dart';

class Role {
  int? id;
  int? roleId;
  String? name;
  UserRole? userRole;
  String? code;
  String? group;
  Map<String, AccessType>? rights;
  Map<String, MenuMode>? routesAccessibility;
  List<User>? users;
  String? bpmRole;

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
  });

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

  Role.fromJson(Map<String, dynamic> json) {
    Map<String, AccessType>? parsedRights;

    if (json['rights'] != null && json['rights'] is Map) {
      parsedRights = {};
      try {
        (json['rights'] as Map).forEach((key, value) {
          if (key is String && value is int) {
            parsedRights![key] = value < AccessType.values.length
                ? AccessType.values[value]
                : AccessType.none;
          }
        });
      } catch (e) {
        parsedRights = {};
      }
    }

    roleId = json['roleId'];
    name = json['roleName'] ?? json['role'];
    userRole = getUserRole(json['roleCode']);
    code = json['roleCode'];

    bpmRole = json['bpmRole'] ?? json['bpmRoleName'];

    group = json['roleGroup'];
    rights = parsedRights;

    if (json['userDetails'] != null && json['userDetails'] is List) {
      users = (json['userDetails'] as List)
          .map((value) => User.fromJson(value as Map<String, dynamic>))
          .toList();
    }
  }
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
    //   } catch (e) {
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
    //   } catch (e) {
    //     parsedMenuModes = {};
    //   }
    // }
    roleId = json['roleId'];
    name = json["roleName"];
    userRole = getUserRole(json["roleCode"]);
    code = json["roleCode"];
    bpmRole = json["bpmRole"];
    group = json["roleGroup"];

    // rights = parsedRights;
    // routesAccessibility = parsedMenuModes;

    rights = json['rights'] != null
        ? Map<String, AccessType>.from(json['rights']
            .map((key, value) => MapEntry(key, AccessType.values[value])))
        : null;
    routesAccessibility = json['routesAccessibility'] != null
        ? Map<String, MenuMode>.from(json['routesAccessibility']
            .map((key, value) => MapEntry(key, MenuMode.values[value])))
        : null;

    if (json['userDetails'] != null && json['userDetails'] is List) {
      users = (json['userDetails'] as List)
          .map((value) => User.fromJson(value as Map<String, dynamic>))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roleId'] = roleId;
    data['roleName'] = name;
    data['roleCode'] = code;
    data['roleGroup'] = group;
    data['bpmRole'] = bpmRole;
    data['rights'] = rights?.map((key, value) => MapEntry(key, value.index));
    data['routesAccessibility'] =
        routesAccessibility?.map((key, value) => MapEntry(key, value.index));
    // data['userDetails'] = users?.map((value) => value.toJson()).toList();
    return data;
  }
}
