import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
// import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  setUp(() {
    Globals.cleanGlobalCache();
    Globals.user = null;
    Globals.applicationDetails = null;
    Globals.requestStatus = [];
  });

  group("Globals.checkIsInitiated", () {
    test("returns false when applicationDetails is null", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = null;

      expect(Globals.checkIsInitiated(), false);
    });

    test("returns true when createdBy matches user id", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U1");

      expect(Globals.checkIsInitiated(), true);
    });

    test("returns false when createdBy does not match user id", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U2");

      expect(Globals.checkIsInitiated(), false);
    });
  });

  group("Globals.checkCurrentStatus", () {
    test("returns false when applicationDetails is null", () {
      Globals.applicationDetails = null;
      Globals.requestStatus = [
        {"Approved": 1},
      ];

      expect(
        Globals.checkCurrentStatus([RequestStatus.approved]),
        false,
      );
    });

    test("returns false when requestStatus list is empty", () {
      Globals.applicationDetails = ApplicationDetails(status: 1);

      expect(
        Globals.checkCurrentStatus([RequestStatus.approved]),
        false,
      );
    });

    test("returns true when status id matches", () {
      Globals.applicationDetails = ApplicationDetails(status: 10);
      Globals.requestStatus = [
        {"Approved": 10},
      ];

      expect(
        Globals.checkCurrentStatus([RequestStatus.approved]),
        true,
      );
    });
  });

  group("Globals.checkAppSubStatus", () {
    test("returns false when applicationDetails is null", () {
      Globals.applicationDetails = null;

      expect(Globals.checkAppSubStatus("TYPE"), false);
    });

    test("returns true when subtype matches", () {
      Globals.applicationDetails = ApplicationDetails(subType: "TYPE");

      expect(Globals.checkAppSubStatus("TYPE"), true);
    });
  });

  group("Globals.cleanGlobalCache", () {
    test("clears global references", () {
      Globals.request = Request(applicationRefNo: "REF");
      Globals.applicationDetails = ApplicationDetails();
      Globals.selectedCustomer = null;
      Globals.onAutoSave = () async {};
      Globals.onAutoSaveSync = () {};

      Globals.cleanGlobalCache();

      expect(Globals.applicationDetails, isNull);
      expect(Globals.onAutoSave, isNull);
      expect(Globals.onAutoSaveSync, isNull);
      expect(Globals.request, isNotNull);
    });
  });

  group("Integration: static lists lifecycle", () {
    test("dynamic form lists can be populated and read", () {
      Globals.dynamicFormCurrencyCodes = [
        Option(key: "USD", pairValue: "USD"),
        Option(key: "EUR", pairValue: "EUR"),
      ];

      Globals.dynamicFormEconomicZones = [
        Option(key: "EU", pairValue: "EU"),
      ];

      expect(Globals.dynamicFormCurrencyCodes!.length, 2);
      expect(Globals.dynamicFormEconomicZones!.first.value, "EU");
    });

    test("reference lists are NOT cleared by cleanGlobalCache", () {
      Globals.recommendReferences = [
        Reference(id: 1, name: "Approve"),
      ];
      Globals.returnReferences = [
        Reference(id: 2, name: "Return"),
      ];
      Globals.approvalReferences = [
        Reference(id: 3, name: "Reject"),
      ];

      Globals.cleanGlobalCache();

      expect(Globals.recommendReferences.length, 1);
      expect(Globals.returnReferences.length, 1);
      expect(Globals.approvalReferences.length, 1);
    });
    test("role/action static maps can be populated and consumed", () {
      Globals.userAction = [
        {"Approve": 1},
        {"Reject": 2},
      ];

      Globals.folTypeAction = [
        {"FOL": 100},
      ];

      expect(Globals.userAction.any((m) => m.containsKey("Approve")), true);
      expect(Globals.folTypeAction.first["FOL"], 100);
    });
  });

  group("Integration: static booleans via real behavior", () {
    test("isInitiated reflects current applicationDetails + user", () {
      Globals.user = User(id: "U1");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U1");

      // indirect verification (do NOT assert static field directly)
      final initiated = Globals.checkIsInitiated();

      expect(initiated, true);
    });

    test("isInitiated false when user does not own application", () {
      Globals.user = User(id: "U2");
      Globals.applicationDetails = ApplicationDetails(createdBy: "U1");

      expect(Globals.checkIsInitiated(), false);
    });
  });
}
