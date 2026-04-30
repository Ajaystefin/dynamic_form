import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";

enum AccessType { view, edit, none }

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

class Page {
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
  int? id;
  int? navigationOrder;
  AccessType accessType;
  String? componentName;
  String? name;
  String? type;
  String? moduleName;
  int? hasChild;
  int? menuOrder;
  int? parentPageId;
  String? pageUrl;
  int? roleRightMapId;
  int? activeFlag;
  bool isUpdated = false;

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
