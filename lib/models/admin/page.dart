import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Represents the access type available for a page.
enum AccessType {
  /// View-only access.
  view,

  /// Edit access.
  edit,

  /// No access.
  none,
}

/// Converts the backend access type string into an [AccessType].
AccessType accessTypeFromString(String? type) {
  switch (type?.toLowerCase()) {
    case "v":
      return AccessType.view;
    case "n":
      return AccessType.none;
    case "e":
      return AccessType.edit;
    default:
      return AccessType.none;
  }
}

/// Returns the localized display text for the given [AccessType].
String accessTypeDisplayText(AccessType type) {
  switch (type) {
    case AccessType.view:
      return "common.view".tr();
    case AccessType.edit:
      return "common.edit".tr();
    case AccessType.none:
      return "common.none".tr();
  }
}

/// Converts an [AccessType] into the backend access type string.
String accessTypeToString(AccessType? type) {
  switch (type) {
    case AccessType.view:
      return "V";
    case AccessType.none:
      return "N";
    case AccessType.edit:
      return "E";
    default:
      return "N";
  }
}

/// Represents a page with access details, navigation information,
/// module information, and role-right mapping details.
class Page {
  /// Creates a [Page] instance.
  Page({
    required this.accessType,
    this.id,
    this.componentName,
    this.navigationOrder,
    this.moduleName,
    this.name,
    this.type,
    this.hasChild,
    this.menuOrder,
    this.parentPageId,
    this.pageUrl,
    this.roleRightMapId,
    this.activeFlag,
  });

  /// Creates a [Page] instance from a JSON map.
  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json["pageId"],
      navigationOrder:
          navigationOrderMap.containsKey("${json['componentName']}")
              ? navigationOrderMap["${json['componentName']}"]
              : 0, //json['navigationOrder'],
      accessType: accessTypeFromString(json["accessType"]),
      componentName: json["componentName"],
      moduleName: json["moduleName"],
      name: json["pageName"],
      type: json["pageType"],
      hasChild: json["hasChild"],
      menuOrder: json["menuOrder"],
      parentPageId: json["parentPageId"],
      pageUrl: json["pageUrl"],
      roleRightMapId: json["roleRightMapId"],
      activeFlag: json["activeFlag"],
    );
  }

  /// Unique identifier of the page.
  int? id;

  /// Navigation order of the page.
  int? navigationOrder;

  /// Access type assigned to the page.
  AccessType accessType;

  /// Component name associated with the page.
  String? componentName;

  /// Display name of the page.
  String? name;

  /// Type of the page.
  String? type;

  /// Module name associated with the page.
  String? moduleName;

  /// Indicates whether the page has child pages.
  int? hasChild;

  /// Menu order of the page.
  int? menuOrder;

  /// Parent page identifier.
  int? parentPageId;

  /// URL associated with the page.
  String? pageUrl;

  /// Role-right mapping identifier for the page.
  int? roleRightMapId;

  /// Active status flag of the page.
  int? activeFlag;

  /// Indicates whether this page has been updated.
  bool isUpdated = false;

  /// Converts this [Page] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "pageId": id,
      "accessType": accessTypeToString(accessType),
      "componentName": componentName,
      "navigationOrder": navigationOrder,
      "moduleName": moduleName,
      "pageName": name,
      "pageType": type,
      "hasChild": hasChild ??= 0,
      "menuOrder": menuOrder ??= 0,
      "parentPageId": parentPageId ??= 0,
      "pageUrl": pageUrl ??= "",
      "roleRightMapId": roleRightMapId,
      "activeFlag": activeFlag,
    };
  }
}
