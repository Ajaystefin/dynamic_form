import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/page.dart";

void main() {
  group("AccessRight", () {
    test("fromJson creates AccessRight object correctly", () {
      final Map<String, dynamic> json = {
        "role": "Admin",
        "requestType": "View",
        "subType": "All",
        "pageIds": [
          {
            "pageId": 1,
            "navigationOrder": 1,
            "accessType": "v",
            "componentName": "Dashboard",
            "moduleName": "Core",
            "pageName": "Home",
            "pageType": "Menu",
            "hasChild": 0,
            "menuOrder": 1,
            "parentPageId": 0,
            "pageUrl": "/dashboard",
            "roleRightMapId": 101,
            "activeFlag": 1,
            "srcMigratedId": 1001,
          }
        ],
      };

      final accessRight = AccessRight.fromJson(json);

      expect(accessRight.role, "Admin");
      expect(accessRight.requestType, "View");
      expect(accessRight.subType, "All");
      expect(accessRight.pages, isNotNull);
      expect(accessRight.pages!.length, 1);
      expect(accessRight.pages![0].id, 1);
      expect(accessRight.pages![0].accessType, AccessType.view);
    });

    test("toJson converts AccessRight object to JSON correctly", () {
      final accessRight = AccessRight(
        role: "Admin",
        requestType: "View",
        subType: "All",
        pages: [
          Page(
            id: 1,
            navigationOrder: 1,
            accessType: AccessType.view,
            componentName: "Dashboard",
            moduleName: "Core",
            name: "Home",
            type: "Menu",
            hasChild: 0,
            menuOrder: 1,
            parentPageId: 0,
            pageUrl: "/dashboard",
            roleRightMapId: 101,
            activeFlag: 1,
          ),
        ],
      );

      final json = accessRight.toJson();

      expect(json["role"], "Admin");
      expect(json["requestType"], "View");
      expect(json["subType"], "All");
      expect(json["pageIds"], isNotNull);
      expect(json["pageIds"].length, 0);
    });

    test("fromJson handles null pageIds correctly", () {
      final Map<String, dynamic> json = {
        "role": "User",
        "requestType": "Edit",
        "subType": "None",
        "pageIds": null,
      };

      final accessRight = AccessRight.fromJson(json);

      expect(accessRight.role, "User");
      expect(accessRight.pages, isNull);
    });

    test("fromJson handles empty pageIds list correctly", () {
      final Map<String, dynamic> json = {
        "role": "Guest",
        "requestType": "View",
        "subType": "Limited",
        "pageIds": [],
      };

      final accessRight = AccessRight.fromJson(json);

      expect(accessRight.role, "Guest");
      expect(accessRight.pages, isEmpty);
    });
  });
}
