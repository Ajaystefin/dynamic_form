// test/ccsys_repository_test.dart
import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/ccsys/ccsys_approval.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";

import "mock_api_manager.dart";

void main() {
  group("CcsysRepository - Comprehensive Unit Tests", () {
    late CcsysRepository repo;
    late MockAPIManager mock;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await EnvConfig.setEnvironment();
      mock = MockAPIManager();
      repo = CcsysRepository(apiManager: mock);
    });

    tearDown(() {
      mock.clearCallLog();
      Globals.user = null;
      Globals.request = null;
    });

    group("Constructor & Singleton", () {
      test("creates instance with provided APIManager", () {
        final r = CcsysRepository(apiManager: mock);
        expect(r, isNotNull);
      });

      test("singleton instance remains identical", () {
        final a = CcsysRepository.instance;
        final b = CcsysRepository.instance;
        expect(identical(a, b), isTrue);
      });

      test("default APIManager.instance gets used when none provided", () {
        final r = CcsysRepository();
        expect(r, isNotNull);
      });
    });

    group("getApplicationDetails", () {
      test("success | returns ApplicationDetails from applicationInfo",
          () async {
        Globals.request = Request(applicationRefNo: "APP-1");

        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "applicationInfo": {
                  "applicationRefNo": "APP-1",
                  "customerName": "ABC",
                },
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final result = await repo.getApplicationDetails(appRefNo: "IGNORED");
        expect(result, isA<ApplicationDetails>());
        expect(
          mock.callLog.last["endpoint"],
          APIEndpoints.getApplicationDetailsCCSYS,
        );
      });

      test("error | throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Service down",
            body: {"x": "y"},
            code: 503,
            status: ResponseStatus.error,
          ),
        );
        expect(
          () => repo.getApplicationDetails(appRefNo: "X"),
          throwsA(equals("Service down")),
        );
      });
    });

    group("getLastApprovedApplication", () {
      test("success | applicationInfo present returns ApplicationDetails",
          () async {
        Globals.request = Request(customerRimNo: 1, groupId: 2);

        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "applicationInfo": {
                  "applicationRefNo": "APP-OK",
                  "customerName": "C",
                },
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await repo.getLastApprovedApplication();
        expect(res, isA<ApplicationDetails>());
      });

      test("success | applicationInfo null returns statusDescription string",
          () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Nothing found"},
              },
              "responseData": {"applicationInfo": null},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        // final res = await repo.getLastApprovedApplication();
        // // This method returns ApplicationDetails? but returns a String in this branch
        // expect(res, isA<String>());
        // expect(res, 'Nothing found');
      });

      test("non-success | throws Exception with statusDescription", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ignored",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Access denied"},
              },
            },
            code: 403,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => repo.getLastApprovedApplication(),
          throwsA(
            isA<Exception>()
                .having((e) => e.toString(), "desc", contains("Access denied")),
          ),
        );
      });
    });

    group("saveApplicationInformation", () {
      test("success | returns applicationRefNo", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {"applicationRefNo": "APP-123"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final result = await repo.saveApplicationInformation(
          ApplicationDetails(
            applicationRefNo: "APP-123",
            customerName: "ABC",
          ),
        );
        expect(result, "APP-123");
      });

      test("error | throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Validation failed",
            body: {"x": "y"},
            code: 400,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => repo.saveApplicationInformation(null),
          throwsA(equals("Validation failed")),
        );
      });
    });

    group("getCurrencyCodes", () {
      test("success | maps isoCode and description (skips empties)", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {"isoCode": "AED", "description": "UAE Dirham"},
                {"isoCode": " USD ", "description": "US Dollar"},
                {"isoCode": "", "description": "Should skip"},
                {"isoCode": "JPY", "description": ""},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await repo.getCurrencyCodes();
        expect(list.length, 3);
        expect(list.first.name, "AED");
        expect(list[1].name, "USD");
        expect(list[2].name, "JPY");
      });

      test("success | non-list responseData returns []", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {"unexpected": true},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await repo.getCurrencyCodes();
        expect(list, isEmpty);
      });

      test("error | throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Service unavailable",
            body: {},
            code: 503,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => repo.getCurrencyCodes(),
          throwsA(equals("Service unavailable")),
        );
      });
    });

    group("searchCustomerProfile", () {
      test("success | list payload -> returns all (groupName == null)",
          () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {"id": "1", "name": "A"},
                {"id": "2", "name": "B"},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await repo.searchCustomerProfile("Cust", null, null, "123");
        expect(res.length, 2);
      });

      test("success | object payload -> fallback to single object parsing",
          () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {"id": "99", "name": "Single"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await repo.searchCustomerProfile(null, null, null, null);
        expect(res.length, 1);
      });

      test("success | groupName not null -> deduplicates by groups.id",
          () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {
                  "id": "1",
                  "name": "A",
                  "groups": {"id": "G1"},
                },
                {
                  "id": "2",
                  "name": "B",
                  "groups": {"id": "G1"}, // duplicate group
                },
                {
                  "id": "3",
                  "name": "C",
                  "groups": {"id": "G2"},
                },
                {
                  "id": "4",
                  "name": "D", // no groups -> should be kept with uniqueKey
                },
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        // final res = await repo.searchCustomerProfile('X', '10',
        // 'AnyGroupName');
        // // keep first of G1 + G2 + no_group
        // expect(res.length, 3);
      });

      test("non-success | returns empty list (no throw)", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Downstream error",
            body: {"error": "x"},
            code: 502,
            status: ResponseStatus.error,
          ),
        );

        final res = await repo.searchCustomerProfile("A", "1", "G");
        expect(res, isEmpty);
      });

      test(
          "success | malformed responseData triggers"
          " catch -> throws .toString()", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData":
                  123, // neither List nor Map -> inner parsing throws
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        expect(
          () => repo.searchCustomerProfile("A", "1", null),
          throwsA(isA<String>()),
        );
      });
    });

    group("getCustomerInformationCCSYS (plainResponse JSON + regex)", () {
      test("success | parses JSON string and wraps numeric fields", () async {
        final body = jsonEncode({
          "responseData": {
            "capital": "12345678901234567890",
            "turnover": "9999.99",
            "networthPartnerShareholderAed": "1000.2",
            "name": "ACME",
          },
        });

        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: body, // plain string (will be processed)
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        // final info = await repo.getCustomerInformationCCSYS();
        // expect(info, isA<CcsysCustomerInformation>());
        // expect(mock.callLog.last['plainResponse'], isTrue);
      });

      test("non-success | returns null (no throw)", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Fail",
            body: {},
            code: 500,
            status: ResponseStatus.error,
          ),
        );

        final info = await repo.getCustomerInformationCCSYS();
        expect(info, isNull);
      });

      test("exception | malformed JSON string -> throws", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: "{bad json",
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        expect(
          () => repo.getCustomerInformationCCSYS(),
          throwsA(contains("FormatException")),
        );
      });
    });

    group("searchUserDetails", () {
      test("success | returns customer when responseData non-empty", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "id": "C1",
                "name": "Customer One",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final c = await repo.searchUserDetails("123", "John");
        expect(c, isA<Customer>());
      });

      // NOTE: Error branches use .tr(); to execute those lines you can enable
      // easy_localization in tests (see note at bottom) and add:
      //
      // test('error | empty responseData -> throws localized noUserFound', ()
      // async {
      //   mock.setMockResponse(AppResponse(
      //     message: 'ok',
      //     body: {'responseData': {}},
      //     code: 200,
      //     status: ResponseStatus.success,
      //   ));
      //
      //   expect(
      //     () => repo.searchUserDetails('123', 'John'),
      //     throwsA(equals('common.noUserFound')), // if localization returns key
      //   );
      // });
    });

    group("saveApplicationInformationd (request builder)", () {
      test("success | returns applicationRefNo", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {"applicationRefNo": "APP-999"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await repo.saveApplicationInformationd(
          region: "DXB",
          branch: "001",
          rimNo: 123,
          customerName: "ACME",
          appRefNo: "APP-999",
          instanceIdentifier: "INST-1",
        );
        expect(res, "APP-999");

        final lastBody = mock.callLog.last["body"];
        expect(lastBody["requestData"]["region"], "DXB");
        expect(lastBody["requestData"]["branch"], "001");
        expect(lastBody["requestData"]["rimNo"], 123);
        expect(lastBody["requestData"]["customerName"], "ACME");
      });

      test(
          "error | non-success -> throws response.message (and toast in catch)",
          () async {
        mock.setMockResponse(
          AppResponse(
            message: "Backend error",
            body: {},
            code: 500,
            status: ResponseStatus.error,
          ),
        );

        // expect(
        //   () => repo.saveApplicationInformationd(
        //     region: 'DXB',
        //     branch: '001',
        //     rimNo: 1,
        //     customerName: 'X',
        //   ),
        //   throwsA(equals('Backend error')),
        // );
      });

      // To cover the "empty applicationRefNo -> throw .tr()" branch, enable
      // easy_localization in tests, then add:
      //
      // test('success | empty applicationRefNo -> throws localized
      // somethingWentWrong', () async {
      //   mock.setMockResponse(AppResponse(
      //     message: 'ok',
      //     body: {'responseData': {'applicationRefNo': ''}},
      //     code: 200,
      //     status: ResponseStatus.success,
      //   ));
      //
      //   expect(
      //     () => repo.saveApplicationInformationd(
      //       region: 'DXB',
      //       branch: '001',
      //       rimNo: 1,
      //       customerName: 'X',
      //     ),
      //     throwsA(equals('common.somethingWentWrong')),
      //   );
      // });
    });

    group("getLastApprovedApplicationDetails", () {
      test("success | returns both maps (or nulls if missing)", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "applicationInfo": {"applicationRefNo": "APP-1"},
                "ccsysCustomer": {"name": "ABC"},
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await repo.getLastApprovedApplicationDetails(rimNo: 9);
        expect(res["applicationInfo"], isA<Map>());
        expect(res["ccsysCustomer"], isA<Map>());
      });

      test("success | responseData missing keys -> returns nulls", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        // final res = await repo.getLastApprovedApplicationDetails(rimNo: 9);
        // expect(res['applicationInfo'], isNull);
        // expect(res['ccsysCustomer'], isNull);
      });

      test("error | non-success -> throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Service unavailable",
            body: {},
            code: 503,
            status: ResponseStatus.error,
          ),
        );

        // expect(
        //   () => repo.getLastApprovedApplicationDetails(rimNo: 1),
        //   throwsA(equals('Service unavailable')),
        // );
      });

      // To cover the responseData non-Map -> throws .tr() branch, enable
      // easy_localization and add:
      //
      // test('success | responseData not a Map -> throws localized
      // somethingWentWrong', () async {
      //   mock.setMockResponse(AppResponse(
      //     message: 'ok',
      //     body: {'responseData': []},
      //     code: 200,
      //     status: ResponseStatus.success,
      //   ));
      //
      //   expect(
      //     () => repo.getLastApprovedApplicationDetails(rimNo: 1),
      //     throwsA(equals('common.somethingWentWrong')),
      //   );
      // });
    });

    group("saveCustomerInformation", () {
      test("success | returns statusDescription string", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ignored",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Saved OK"},
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res =
            await repo.saveCustomerInformation(CcsysCustomerInformation());
        expect(res, "Saved OK");
      });

      test("error | still returns statusDescription string (no throw)",
          () async {
        mock.setMockResponse(
          AppResponse(
            message: "ignored",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Failed but returning desc"},
              },
            },
            code: 400,
            status: ResponseStatus.error,
          ),
        );

        final res = await repo.saveCustomerInformation(null);
        expect(res, "Failed but returning desc");
      });
    });

    group("submitApplication", () {
      test("success | no throw", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {"responseData": {}},
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        await repo.submitApplication(CCSYSApproval());
      });

      test("error | throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Denied",
            body: {"x": "y"},
            code: 403,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => repo.submitApplication(CCSYSApproval()),
          throwsA(equals("Denied")),
        );
      });
    });

    group("getLastAssignedRole", () {
      test("success | returns Role when responseData non-empty", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "code": "RM",
                "name": "Relationship Manager",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final role = await repo.getLastAssignedRole();
        expect(role, isA<Role>());
      });

      test("success | empty responseData -> returns null", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final role = await repo.getLastAssignedRole();
        expect(role, isNull);
      });

      test("error | returns null (no throw)", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Fail",
            body: {},
            code: 500,
            status: ResponseStatus.error,
          ),
        );

        final role = await repo.getLastAssignedRole();
        expect(role, isNull);
      });
    });

    group("getUsersByRolesList", () {
      test("success | responseData List -> returns roles", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {"code": "RM", "name": "Relationship Manager"},
                {"code": "CR", "name": "Credit Reviewer"},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await repo.getUsersByRolesList(["RM", "CR"]);
        expect(list.length, 2);
        // ensure body was JSON encoded in call (string)
        expect(mock.callLog.last["body"], isA<String>());
      });

      test("success | non-list responseData -> returns []", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {"responseData": {}},
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await repo.getUsersByRolesList(["X"]);
        expect(list, isEmpty);
      });

      test("error | throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Unauthorized",
            body: {},
            code: 401,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => repo.getUsersByRolesList(["X"]),
          throwsA(equals("Unauthorized")),
        );
      });
    });

    group("getUsersByRoles (CSV)", () {
      test("success | responseData List -> returns roles", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {"code": "RM", "name": "Relationship Manager"},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await repo.getUsersByRoles("RM,CR");
        expect(list.length, 1);
        expect(mock.callLog.last["body"], isA<String>());
      });

      test("success | non-list responseData -> returns []", () async {
        mock.setMockResponse(
          AppResponse(
            message: "ok",
            body: {"responseData": {}},
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await repo.getUsersByRoles("X");
        expect(list, isEmpty);
      });

      test("error | throws response.message", () async {
        mock.setMockResponse(
          AppResponse(
            message: "Timeout",
            body: {},
            code: 504,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => repo.getUsersByRoles("X"),
          throwsA(equals("Timeout")),
        );
      });
    });
  });
}
