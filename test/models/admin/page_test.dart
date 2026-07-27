import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/page.dart";

void main() {
  group("AccessType", () {
    test('accessTypeFromString returns correct AccessType for "v"', () {
      expect(accessTypeFromString("v"), AccessType.view);
    });

    test('accessTypeFromString returns correct AccessType for "n"', () {
      expect(accessTypeFromString("n"), AccessType.none);
    });

    test('accessTypeFromString returns correct AccessType for "e"', () {
      expect(accessTypeFromString("e"), AccessType.edit);
    });

    test(
        "accessTypeFromString returns default"
        " AccessType.edit for invalid string", () {
      expect(accessTypeFromString("x"), AccessType.none);
      expect(accessTypeFromString(null), AccessType.none);
      expect(accessTypeFromString(""), AccessType.none);
    });

    test("accessTypeToString returns correct string for AccessType.view", () {
      expect(accessTypeToString(AccessType.view), "V");
    });

    test("accessTypeToString returns correct string for AccessType.none", () {
      expect(accessTypeToString(AccessType.none), "N");
    });

    test("accessTypeToString returns correct string for AccessType.edit", () {
      expect(accessTypeToString(AccessType.edit), "E");
    });

    test('accessTypeToString returns default "N" for null AccessType', () {
      expect(accessTypeToString(null), "N");
    });
  });

  group("Page", () {
    test("fromJson creates Page object correctly", () {
      final Map<String, dynamic> json = {
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
      };

      final page = Page.fromJson(json);

      expect(page.id, 1);
      expect(page.navigationOrder, 0);
      expect(page.accessType, AccessType.view);
      expect(page.componentName, "Dashboard");
      expect(page.moduleName, "Core");
      expect(page.name, "Home");
      expect(page.type, "Menu");
      expect(page.hasChild, 0);
      expect(page.menuOrder, 1);
      expect(page.parentPageId, 0);
      expect(page.pageUrl, "/dashboard");
      expect(page.roleRightMapId, 101);
      expect(page.activeFlag, 1);
    });

    test("toJson converts Page object to JSON correctly", () {
      final page = Page(
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
      );

      final json = page.toJson();

      expect(json["pageId"], 1);
      expect(json["navigationOrder"], 1);
      expect(json["accessType"], "V");
      expect(json["componentName"], "Dashboard");
      expect(json["moduleName"], "Core");
      expect(json["pageName"], "Home");
      expect(json["pageType"], "Menu");
      expect(json["hasChild"], 0);
      expect(json["menuOrder"], 1);
      expect(json["parentPageId"], 0);
      expect(json["pageUrl"], "/dashboard");
      expect(json["roleRightMapId"], 101);
      expect(json["activeFlag"], 1);
    });
  });
}
