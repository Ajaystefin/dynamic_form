import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

import "../test_config.dart";
import "mock_api_manager.dart";

Matcher throwsExceptionWithMessage(String message) {
  return throwsA(
    isA<Exception>().having(
      (e) => e.toString(),
      "message",
      contains(message),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CustomerRepository Tests", () {
    late CustomerRepository customerRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();

      customerRepository = CustomerRepository(
        apiManager: mockAPIManager,
      );

      Globals.user = User(
        id: "test-user",
        name: "Test User",
        currentRole: Role(
          id: 1,
          code: "ADMIN",
          name: "Administrator",
        ),
      );

      Globals.request = Request(
        applicationRefNo: "APP123",
      );
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.user = null;
      Globals.request = null;
      Globals.selectedCustomer = null;
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection / Singleton", () {
      test("should use injected APIManager", () {
        final customMockAPIManager = MockAPIManager();

        final repository = CustomerRepository(
          apiManager: customMockAPIManager,
        );

        expect(repository, isA<CustomerRepository>());
      });

      test("should use singleton instance when requested", () {
        final repository = CustomerRepository.instance;
        expect(repository, isA<CustomerRepository>());
      });

      test("should maintain singleton behavior", () {
        final instance1 = CustomerRepository.instance;
        final instance2 = CustomerRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test("debugReplaceInstance should replace singleton instance", () {
        CustomerRepository.debugReplaceInstance = customerRepository;
        expect(CustomerRepository.instance, same(customerRepository));
      });
    });

    group("getApplicationDetails", () {
      test("should return ApplicationDetails on success", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "applicationRefNo": "APP-001",
              "branch": "Main Branch",
              "customerName": "Acme Corp",
              "status": 1,
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getApplicationDetails();

        expect(result, isA<ApplicationDetails>());
        expect(result!.applicationRefNo, equals("APP-001"));
        expect(result.branch, equals("Main Branch"));
        expect(result.customerName, equals("Acme Corp"));
      });

      test("should use passed appRefNo when provided", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "applicationRefNo": "OVERRIDE-REF",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getApplicationDetails(
          appRefNo: "OVERRIDE-REF",
        );

        expect(result, isA<ApplicationDetails>());
        expect(result!.applicationRefNo, equals("OVERRIDE-REF"));
      });

      test("should handle unexpected JSON structure gracefully", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "unexpectedField": "value",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getApplicationDetails();

        expect(result, isA<ApplicationDetails>());
        expect(result!.applicationRefNo, isNull);
      });

      test("should handle null applicationRefNo gracefully", () async {
        Globals.request = Request();

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "applicationRefNo": null,
              "branch": "Fallback Branch",
              "customerName": "Fallback Corp",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getApplicationDetails();

        expect(result, isA<ApplicationDetails>());
        expect(result!.applicationRefNo, isNull);
        expect(result.branch, equals("Fallback Branch"));
        expect(result.customerName, equals("Fallback Corp"));
      });

      test("should throw statusDescription when response status is error",
          () async {
        final mockResponse = AppResponse(
          message: "Failed",
          body: {
            "baseResponse": {
              "status": {
                "statusDescription": "Application not found",
              },
            },
          },
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getApplicationDetails(),
          throwsExceptionWithMessage("Application not found"),
        );
      });
    });

    group("getCustomerInformationByRim", () {
      test("should return Customer when response is success and data exists",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "CUST001",
              "rimNo": 12345,
              "customerName": "John Doe Corp",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result =
            await customerRepository.getCustomerInformationByRim(12345);

        expect(result, isA<Customer>());
      });

      test("should throw statusDescription when responseData is null",
          () async {
        final mockResponse = AppResponse(
          message: "No data",
          body: {
            "responseData": null,
            "baseResponse": {
              "status": {
                "statusDescription": "No data found",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getCustomerInformationByRim(12345),
          throwsExceptionWithMessage("No data found"),
        );
      });

      test("should throw statusDescription when response status is error",
          () async {
        final mockResponse = AppResponse(
          message: "Server error",
          body: {
            "baseResponse": {
              "status": {
                "statusDescription": "Server error",
              },
            },
          },
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getCustomerInformationByRim(12345),
          throwsA(predicate((e) => e.toString().contains("Server error"))),
        );
      });

      test("should rethrow API exceptions as string", () async {
        mockAPIManager.setMockException(Exception("Network issue"));

        expect(
          () async => customerRepository.getCustomerInformationByRim(12345),
          throwsA(predicate((e) => e.toString().contains("Network issue"))),
        );
      });
    });

    group("getCountries", () {
      test("should return list of Country objects", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"countryCode": "AE", "description": "United Arab Emirates"},
              {"countryCode": "IN", "description": "India"},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getCountries();

        expect(result, isA<List<Country>>());
        expect(result, hasLength(2));
        expect(result![0].code, equals("AE"));
        expect(result[0].description, equals("United Arab Emirates"));
        expect(result[1].code, equals("IN"));
        expect(result[1].description, equals("India"));
      });

      test("should handle empty countries list", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getCountries();

        expect(result, isEmpty);
      });

      test("should handle countries with null values gracefully", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"countryCode": null, "description": null},
              {"countryCode": "AE", "description": "United Arab Emirates"},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getCountries();

        expect(result, hasLength(2));
        expect(result![0].code, isNull);
        expect(result[0].description, isNull);
        expect(result[1].code, equals("AE"));
        expect(result[1].description, equals("United Arab Emirates"));
      });

      test("should throw error when response status is failure", () async {
        final mockResponse = AppResponse(
          message: "Server error",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getCountries(),
          throwsExceptionWithMessage("Server error"),
        );
      });

      test("should throw error when responseData is null", () async {
        final mockResponse = AppResponse(
          message: "No data",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getCountries(),
          throwsExceptionWithMessage("No data"),
        );
      });

      test("should rethrow exception as string on network failure", () async {
        mockAPIManager.setMockException(Exception("Connection failed"));

        expect(
          () async => customerRepository.getCountries(),
          throwsA(predicate((e) => e.toString().contains("Connection failed"))),
        );
      });
    });

    group("Country model", () {
      test("Country.fromJson should parse valid JSON correctly", () {
        final json = {"countryCode": "US", "description": "United States"};
        final country = Country.fromJson(json);

        expect(country.code, equals("US"));
        expect(country.description, equals("United States"));
      });

      test("Country.fromJson should handle missing fields gracefully", () {
        final json = {"country": "US"};
        final country = Country.fromJson(json);

        expect(country.code, isNull);
        expect(country.description, isNull);
      });

      test("Country.toJson should return correct map", () {
        final country = Country(code: "UK", description: "United Kingdom");
        final map = country.toJson();

        expect(map["countryCode"], equals("UK"));
        expect(map["description"], equals("United Kingdom"));
      });
    });

    group("searchUserDetails", () {
      test("should throw noUserFound when responseData is null", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": null,
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.searchUserDetails(
            "12345",
            "John Doe",
            "100",
            "Group A",
          ),
          throwsExceptionWithMessage("common.noUserFound"),
        );
      });

      test("should throw noUserFound when PartyInfo is missing", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "12345",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.searchUserDetails(
            "12345",
            "John Doe",
            "100",
            "Group A",
          ),
          throwsExceptionWithMessage("common.noUserFound"),
        );
      });

      test("should throw noUserFound when status is error", () async {
        final mockResponse = AppResponse(
          message: "Failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.searchUserDetails(
            "12345",
            "John Doe",
            "100",
            "Group A",
          ),
          throwsExceptionWithMessage("common.noUserFound"),
        );
      });

      test("should rethrow api failure", () async {
        mockAPIManager.setMockException("API failure");

        expect(
          () async => customerRepository.searchUserDetails(
            "12345",
            "John Doe",
            "100",
            "Group A",
          ),
          throwsA(predicate((e) => e.toString().contains("API failure"))),
        );
      });
    });

    group("searchUserDetailsForCL", () {
      test(
          "should return null when status is success"
          " but responseData is invalid", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.searchUserDetailsForCL(
          "12345",
          "John Doe",
          "100",
          "Group A",
        );

        expect(result, isNull);
      });

      test("should return null when response status is error", () async {
        final mockResponse = AppResponse(
          message: "Failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.searchUserDetailsForCL(
          "12345",
          "John Doe",
          "100",
          "Group A",
        );

        expect(result, isNull);
      });

      test("should rethrow exception as string", () async {
        mockAPIManager.setMockException(Exception("CL search failed"));

        expect(
          () async => customerRepository.searchUserDetailsForCL(
            "12345",
            "John Doe",
            "100",
            "Group A",
          ),
          throwsA(predicate((e) => e.toString().contains("CL search failed"))),
        );
      });
    });
    group("validateSubSegment", () {
      test("should throw response.message when response status is error",
          () async {
        final mockResponse = AppResponse(
          message: "Invalid sub segment",
          body: {},
          code: 400,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.validateSubSegment("RM001"),
          throwsExceptionWithMessage("Invalid sub segment"),
        );
      });
    });

    group("searchCustomerProfile", () {
      test("should deduplicate by group id when groupName is provided",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "PartyId": "301",
                "GroupKeys": {"groupId": "G1", "groupName": "Group 1"},
              },
              {
                "PartyId": "302",
                "GroupKeys": {"groupId": "G1", "groupName": "Group 1"},
              },
              {
                "PartyId": "303",
                "GroupKeys": {"groupId": "G2", "groupName": "Group 2"},
              },
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.searchCustomerProfile(
          null,
          null,
          "Has Group Name",
        );

        expect(result.length, lessThanOrEqualTo(3));
        expect(result.isNotEmpty, isTrue);
      });

      test("should return empty list when status is error", () async {
        final mockResponse = AppResponse(
          message: "Failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.searchCustomerProfile(
          "John",
          null,
          null,
        );

        expect(result, isEmpty);
      });

      test("should rethrow exception as string", () async {
        mockAPIManager.setMockException(Exception("Profile search failed"));

        expect(
          () async => customerRepository.searchCustomerProfile(
            "John",
            null,
            null,
          ),
          throwsA(
            predicate((e) => e.toString().contains("Profile search failed")),
          ),
        );
      });
    });
    group("saveUserDetails", () {
      test("should return statusDescription when save succeeds", () async {
        final customer = Customer(
          id: "123",
          customerName: "John Doe",
        );

        final ownership = <CustomerOwnerShipInfo>[
          CustomerOwnerShipInfo(
            identificationDetail: "Primary",
            custOwnershipName: "Owner 1",
          ),
        ];

        final exceptions = <CustomerException>[
          CustomerException(
            type: "TypeA",
            description: "Description A",
          ),
        ];

        final mockResponse = AppResponse(
          message: "Saved",
          body: {
            "baseResponse": {
              "status": {
                "statusDescription": "Customer information saved",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.saveUserDetails(
          customer,
          ownership,
          exceptions,
        );

        expect(result, equals("Customer information saved"));
      });

      test("should throw when save fails", () async {
        final mockResponse = AppResponse(
          message: "Save failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.saveUserDetails(null, null, null),
          throwsA(predicate((e) => e.toString().contains("Save failed"))),
        );
      });

      test("should rethrow exceptions as string", () async {
        mockAPIManager.setMockException(Exception("Network save failure"));

        expect(
          () async => customerRepository.saveUserDetails(null, null, null),
          throwsA(
            predicate((e) => e.toString().contains("Network save failure")),
          ),
        );
      });
    });

    group("getCustomerInformationByRimOwnership", () {
      test("should return list of CustomerOwnerShipInfo when response is valid",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "identificationDetails": "Primary",
                "custOwnerName": "John Doe",
              },
              {
                "identificationDetails": "Secondary",
                "custOwnerName": "Jane Smith",
              },
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository
            .getCustomerInformationByRimOwnership(12345);

        expect(result, isNotNull);
        expect(result, hasLength(2));
        expect(result![0], isA<CustomerOwnerShipInfo>());
      });

      test("should return empty list when responseData is empty", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository
            .getCustomerInformationByRimOwnership(12345);

        expect(result, isEmpty);
      });

      test("should throw exception when response status is error", () async {
        final mockResponse = AppResponse(
          message: "Failed to fetch ownership info",
          body: {"error": "Internal Server Error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async =>
              customerRepository.getCustomerInformationByRimOwnership(12345),
          throwsExceptionWithMessage("Failed to fetch ownership info"),
        );
      });

      test("should rethrow exception on network error", () async {
        mockAPIManager.setMockException(Exception("Network error"));

        expect(
          () async =>
              customerRepository.getCustomerInformationByRimOwnership(12345),
          throwsA(predicate((e) => e.toString().contains("Network error"))),
        );
      });
    });

    group("getCustomerInformationByRimException", () {
      test("should return list of CustomerException when response is valid",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"typeCode": "TypeA", "exceptionDescription": "Detail A"},
              {"typeCode": "TypeB", "exceptionDescription": "Detail B"},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository
            .getCustomerInformationByRimException(67890);

        expect(result, isNotNull);
        expect(result, hasLength(2));
        expect(result![0], isA<CustomerException>());
      });

      test("should return empty list when responseData is empty", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository
            .getCustomerInformationByRimException(67890);

        expect(result, isEmpty);
      });

      test("should throw exception when response status is error", () async {
        final mockResponse = AppResponse(
          message: "Failed to fetch exception info",
          body: {"error": "Internal Server Error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async =>
              customerRepository.getCustomerInformationByRimException(67890),
          throwsExceptionWithMessage("Failed to fetch exception info"),
        );
      });

      test("should rethrow exception on network error", () async {
        mockAPIManager.setMockException(Exception("Network error"));

        expect(
          () async =>
              customerRepository.getCustomerInformationByRimException(67890),
          throwsA(predicate((e) => e.toString().contains("Network error"))),
        );
      });
    });

    group("deleteOwnership", () {
      test("should return statusDescription when response is success",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusDescription": "Ownership deleted",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.deleteOwnership(1, 12345);

        expect(result, equals("Ownership deleted"));
      });

      test("should throw Exception when response status is failure", () async {
        final mockResponse = AppResponse(
          message: "Delete failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.deleteOwnership(1, 12345),
          throwsA(predicate((e) => e.toString().contains("Delete failed"))),
        );
      });

      test("should rethrow unexpected exception", () async {
        mockAPIManager
            .setMockException(Exception("Ownership delete network issue"));

        expect(
          () async => customerRepository.deleteOwnership(1, 12345),
          throwsA(
            predicate(
              (e) => e.toString().contains("Ownership delete network issue"),
            ),
          ),
        );
      });
    });

    group("deleteException", () {
      test("should return statusDescription when response is success",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusDescription": "Exception deleted",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.deleteException(1, 12345);

        expect(result, equals("Exception deleted"));
      });

      test("should throw Exception when response status is failure", () async {
        final mockResponse = AppResponse(
          message: "Delete failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.deleteException(1, 12345),
          throwsA(predicate((e) => e.toString().contains("Delete failed"))),
        );
      });

      test("should rethrow unexpected exception", () async {
        mockAPIManager
            .setMockException(Exception("Exception delete network issue"));

        expect(
          () async => customerRepository.deleteException(1, 12345),
          throwsA(
            predicate(
              (e) => e.toString().contains("Exception delete network issue"),
            ),
          ),
        );
      });
    });

    group("getBorrowerCustomers", () {
      test(
          "should return message and update borrowers/nonBorrowers when success",
          () async {
        Globals.request = Request(applicationRefNo: "APP123");

        final customerList = <Customer?>[
          Customer(id: "101", customerName: "John", customerRimNo: 101),
          Customer(id: "102", customerName: "Jane", customerRimNo: 102),
        ];

        final mockResponse = AppResponse(
          message: "Borrower data fetched",
          body: {
            "responseData": {
              "borrowers": ["101"],
              "nonBorrowers": ["102"],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getBorrowerCustomers(
          customerList,
          Customer(customerRimNo: 102),
        );

        expect(result, equals("Borrower data fetched"));
        expect(Globals.request?.borrowers, isNotNull);
        expect(Globals.request?.nonBorrowers, isNotNull);

        // non-borrower primary should be moved into borrower list
        expect(Globals.request?.borrowers?.length, equals(2));
        expect(Globals.request?.nonBorrowers?.length, equals(0));
        expect(
          Globals.request?.borrowers
              ?.any((c) => c.customerRimNo == 102 && c.isPrimary),
          isTrue,
        );
      });

      test("should mark primary borrower when primary is already borrower",
          () async {
        Globals.request = Request(applicationRefNo: "APP123");

        final customerList = <Customer?>[
          Customer(id: "201", customerName: "A", customerRimNo: 201),
          Customer(id: "202", customerName: "B", customerRimNo: 202),
        ];

        final mockResponse = AppResponse(
          message: "Borrower data fetched",
          body: {
            "responseData": {
              "borrowers": ["201"],
              "nonBorrowers": ["202"],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getBorrowerCustomers(
          customerList,
          Customer(customerRimNo: 201),
        );

        expect(result, equals("Borrower data fetched"));
        expect(
          Globals.request?.borrowers
              ?.any((c) => c.customerRimNo == 201 && c.isPrimary),
          isTrue,
        );
        expect(
          Globals.request?.nonBorrowers?.any((c) => c.customerRimNo == 201),
          isFalse,
        );
      });

      test("should handle empty customerList gracefully", () async {
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Borrower data fetched",
          body: {
            "responseData": {
              "borrowers": [],
              "nonBorrowers": [],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result =
            await customerRepository.getBorrowerCustomers([], Customer());

        expect(result, equals("Borrower data fetched"));
        expect(Globals.request?.borrowers?.isEmpty, isTrue);
        expect(Globals.request?.nonBorrowers?.isEmpty, isTrue);
      });

      test("should throw Exception when response status is failure", () async {
        final mockResponse = AppResponse(
          message: "Failed to fetch borrowers",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getBorrowerCustomers([], Customer()),
          throwsA(
            predicate(
              (e) => e.toString().contains("Failed to fetch borrowers"),
            ),
          ),
        );
      });

      test("should rethrow unexpected exception", () async {
        mockAPIManager
            .setMockException(Exception("Borrower fetch network issue"));

        expect(
          () async => customerRepository.getBorrowerCustomers([], Customer()),
          throwsA(
            predicate(
              (e) => e.toString().contains("Borrower fetch network issue"),
            ),
          ),
        );
      });
    });

    group("getChildRimsForGroup", () {
      test("should return list of customers when response is success",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"name": "John", "rimNo": 123},
              {"name": "Jane", "rimNo": 456},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getChildRimsForGroup();

        expect(result, isA<List<Customer>>());
        expect(result?.length, equals(2));
      });

      test("should throw error when responseData is null", () async {
        final mockResponse = AppResponse(
          message: "No data found",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getChildRimsForGroup(),
          throwsExceptionWithMessage("No data found"),
        );
      });

      test("should throw error when response status is failure", () async {
        final mockResponse = AppResponse(
          message: "Server error",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.getChildRimsForGroup(),
          throwsExceptionWithMessage("Server error"),
        );
      });

      test("should rethrow API exception as string", () async {
        mockAPIManager.setMockException(Exception("Child RIM fetch failed"));

        expect(
          () async => customerRepository.getChildRimsForGroup(),
          throwsA(
            predicate(
              (e) => e.toString().contains("Child RIM fetch failed"),
            ),
          ),
        );
      });
    });

    group("searchUserDetailsPartyInqOnly", () {
      test("should return Customer when PartyRec exists", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "partyInqOwnershipDTO": {
              "PartyInqRs": {
                "PartyRec": {
                  "PartyId": "12345",
                  "name": "John Doe",
                  "rimNo": 12345,
                },
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.searchUserDetailsPartyInqOnly(
          "12345",
          "John Doe",
          "",
          "",
        );

        expect(result, isA<Customer>());
      });

      test("should return null when PartyRec is missing", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "partyInqOwnershipDTO": {
              "PartyInqRs": {},
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.searchUserDetailsPartyInqOnly(
          "12345",
          "John Doe",
          "",
          "",
        );

        expect(result, isNull);
      });

      test("should throw response.message when response status is error",
          () async {
        final mockResponse = AppResponse(
          message: "Server error",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => customerRepository.searchUserDetailsPartyInqOnly(
            "12345",
            "John Doe",
            "",
            "",
          ),
          throwsExceptionWithMessage("Server error"),
        );
      });

      test("should rethrow exception from API manager", () async {
        mockAPIManager.setMockException(Exception("Party inquiry failed"));

        expect(
          () async => customerRepository.searchUserDetailsPartyInqOnly(
            "12345",
            "John Doe",
            "",
            "",
          ),
          throwsA(
            predicate((e) => e.toString().contains("Party inquiry failed")),
          ),
        );
      });
    });

    group("getPayload", () {
      test("should build payload with only customerRimNo", () {
        final payload = customerRepository.getPayload(
          "12345",
          "",
          "",
          "",
        );

        expect(payload["PartyInqRq"], isNotNull);
        expect(payload["PartyInqRq"]["RqUID"], isNotNull);
        expect(payload["PartyInqRq"]["MsgRqHdr"], isNotNull);
        expect(
          payload["PartyInqRq"]["PartySel"]["PartyKeys"]["PartyId"],
          equals("12345"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"].containsKey("FullName"),
          isFalse,
        );
        expect(
          payload["PartyInqRq"]["PartySel"].containsKey("GroupKeys"),
          isFalse,
        );
      });

      test("should build payload with only customerName", () {
        final payload = customerRepository.getPayload(
          "",
          "John Doe",
          "",
          "",
        );

        expect(
          payload["PartyInqRq"]["PartySel"]["FullName"],
          equals("John Doe"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"].containsKey("PartyKeys"),
          isFalse,
        );
      });

      test("should build payload with groupId only", () {
        final payload = customerRepository.getPayload(
          "",
          "",
          "G100",
          "",
        );

        expect(
          payload["PartyInqRq"]["PartySel"]["GroupKeys"]["GroupId"],
          equals("G100"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"]["GroupKeys"]
              .containsKey("groupName"),
          isFalse,
        );
      });

      test("should build payload with groupName only", () {
        final payload = customerRepository.getPayload(
          "",
          "",
          "",
          "My Group",
        );

        expect(
          payload["PartyInqRq"]["PartySel"]["GroupKeys"]["groupName"],
          equals("My Group"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"]["GroupKeys"].containsKey("GroupId"),
          isFalse,
        );
      });

      test("should build payload with all fields", () {
        final payload = customerRepository.getPayload(
          "555",
          "Full Name",
          "G200",
          "Mega Group",
        );

        expect(
          payload["PartyInqRq"]["PartySel"]["PartyKeys"]["PartyId"],
          equals("555"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"]["FullName"],
          equals("Full Name"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"]["GroupKeys"]["GroupId"],
          equals("G200"),
        );
        expect(
          payload["PartyInqRq"]["PartySel"]["GroupKeys"]["groupName"],
          equals("Mega Group"),
        );
      });

      test("should build payload with empty PartySel when all params are empty",
          () {
        final payload = customerRepository.getPayload(
          "",
          "",
          "",
          "",
        );

        expect(payload["PartyInqRq"]["PartySel"], isA<Map>());
        expect((payload["PartyInqRq"]["PartySel"] as Map).isEmpty, isTrue);
      });
    });

    group("Concurrency / Large dataset", () {
      test("should handle concurrent API calls", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "countryCode": "CONCURRENT",
                "description": "Concurrent Test Country",
              },
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final futures =
            List.generate(3, (_) => customerRepository.getCountries());
        final results = await Future.wait(futures);

        expect(results, hasLength(3));
        for (final result in results) {
          expect(result, hasLength(1));
          expect(result![0].code, equals("CONCURRENT"));
        }
        expect(mockAPIManager.callLog, hasLength(3));
      });

      test("should handle large countries dataset efficiently", () async {
        final largeCountriesList = List.generate(
          200,
          (index) => {
            "countryCode": 'C${index.toString().padLeft(3, '0')}',
            "description": "Country ${index + 1}",
          },
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": largeCountriesList},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getCountries();

        expect(result, hasLength(200));
        expect(result![0].code, equals("C000"));
        expect(result[0].description, equals("Country 1"));
        expect(result[199].code, equals("C199"));
        expect(result[199].description, equals("Country 200"));
      });

      test("should handle complex application details with nested structures",
          () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "applicationRefNo": "COMPLEX123",
              "customerInformation": {
                "custInfoId": 9999,
                "applicationRefNo": "COMPLEX123",
                "customerRimNumber": 99999,
                "customerName": "Complex Customer",
                "groupMappings": List.generate(
                  10,
                  (index) => {
                    "customerRimNumber": 90000 + index,
                    "customerName": "Subsidiary ${index + 1}",
                    "isPrimary": index == 0,
                    "sicCode": 'SIC${index.toString().padLeft(3, '0')}',
                    "isApplicant": index < 3,
                  },
                ),
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await customerRepository.getApplicationDetails();

        expect(result!.applicationRefNo, equals("COMPLEX123"));
        expect(result.customerInformation!.custInfoId, equals(9999));
        expect(result.customerInformation!.groupMappings, hasLength(10));
        expect(result.customerInformation!.groupMappings![0].isPrimary, isTrue);
        expect(
          result.customerInformation!.groupMappings![0].isApplicant,
          isTrue,
        );
        expect(
          result.customerInformation!.groupMappings![9].isPrimary,
          isFalse,
        );
        expect(
          result.customerInformation!.groupMappings![9].isApplicant,
          isFalse,
        );
      });
    });
  });
}
