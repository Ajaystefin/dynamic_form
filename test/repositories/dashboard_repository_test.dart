import "dart:convert";

import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/home/aging_summary.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";
import "package:wcas_frontend/models/home/home.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class FakeAPIManager extends APIManager {
  FakeAPIManager()
      : super(
          dio: Dio(BaseOptions()),
          addDefaultInterceptors: false,
        );

  AppResponse? response;
  Exception? exception;
  final List<Map<String, dynamic>> callLog = [];

  void setResponse(AppResponse value) {
    exception = null;
    response = value;
  }

  void setException(Exception value) {
    response = null;
    exception = value;
  }

  void clearMock() {
    response = null;
    exception = null;
    callLog.clear();
  }

  @override
  Future<AppResponse> post(
    String endPoint,
    Object? body, {
    Map<String, dynamic> additionalHeaders = const {},
    bool plainResponse = false,
  }) async {
    callLog.add({
      "method": "POST",
      "endpoint": endPoint,
      "body": body,
      "additionalHeaders": additionalHeaders,
      "plainResponse": plainResponse,
    });

    final Exception? currentException = exception;
    if (currentException != null) {
      throw currentException;
    }

    return response ??
        AppResponse(
          message: "OK",
          body: <String, dynamic>{},
          code: 200,
          status: ResponseStatus.success,
        );
  }
}

class FakeReferenceDataService extends Mock implements ReferenceDataService {
  Map<String, List<Reference>> _data = <String, List<Reference>>{};
  Exception? _exception;

  set mockData(Map<String, List<Reference>> value) {
    _exception = null;
    _data = value;
  }

  set mockException(Exception value) {
    _exception = value;
  }

  void clearMock() {
    _data = <String, List<Reference>>{};
    _exception = null;
  }

  @override
  Future<Map<String, List<Reference>>> getReferenceData(
    List<String> keys,
  ) async {
    final Exception? error = _exception;
    if (error != null) {
      throw error;
    }
    return _data;
  }
}

class OpenApplicationTestDashboardRepository extends DashboardRepository {
  OpenApplicationTestDashboardRepository({
    required APIManager apiManager,
    required ReferenceDataService referenceDataService,
  }) : super(
          apiManager: apiManager,
          referenceDataService: referenceDataService,
        );

  Request? nextApplicationDetails;
  bool lastIsCcsys = false;
  String? lastAppRefNo;

  @override
  Future<Request?> getApplicationDetails({
    required List<Reference> requestStatuses,
    required List<Reference> bussinessSegments,
    String? appRefNo,
    bool isCCSYS = false,
  }) async {
    lastIsCcsys = isCCSYS;
    lastAppRefNo = appRefNo;
    return nextApplicationDetails;
  }
}

Matcher throwsMessage(String message) {
  return throwsA(
    predicate<Object>(
      (Object error) => error.toString().contains(message),
      "throws object containing $message",
    ),
  );
}

void setupConnectivityMock() {
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    connectivityChannel,
    (MethodCall methodCall) async => <String>["wifi"],
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel("plugins.flutter.io/connectivity"),
    (MethodCall methodCall) async => "wifi",
  );
}

void resetGlobals() {
  Globals.user = null;
  Globals.request = Request();
  Globals.applicationDetails = null;
  Globals.superBpmRolesId = [];
  Utils.request = Request();
}

Map<String, List<Reference>> standardReferenceData() {
  return {
    ReferenceDataKeys.applicationType: [
      Reference(id: 1, name: "New Application", reference1: "NEW"),
      Reference(id: 2, name: "Normal Application", reference1: "NORMAL"),
      Reference(
        id: 99,
        name: "CCSYS",
        reference1: ServerConstants.ccsysAppReference1,
      ),
    ],
    ReferenceDataKeys.customApplicationType: [
      Reference(id: 3, name: "Custom Application", reference1: "CUSTOM"),
    ],
    ReferenceDataKeys.requestType: [
      Reference(id: 10, name: "Credit Facility", reference1: "CREDIT"),
      Reference(id: 11, name: "Trade Finance", reference1: "TRADE"),
      Reference(id: 12, name: "Credit", reference1: "Credit"),
    ],
    ReferenceDataKeys.transactionType: [
      Reference(id: 20, name: "Letter of Credit", reference1: "LC"),
      Reference(id: 21, name: "Bank Guarantee", reference1: "BG"),
    ],
    ReferenceDataKeys.requestStatus: [
      Reference(id: 30, name: "Pending"),
      Reference(id: 31, name: "Approved"),
      Reference(id: 32, name: "Completed"),
      Reference(id: 33, name: "Returned"),
      Reference(id: 34, name: "Rejected"),
    ],
    ReferenceDataKeys.applicationSegment: [
      Reference(id: 1, name: "Corporate"),
      Reference(id: 2, name: "Financial Institution"),
    ],
    ReferenceDataKeys.roleType: [
      Reference(id: 40, name: "RM", reference1: "RM"),
      Reference(id: 41, name: "CA", reference1: "CA"),
      Reference(id: 42, name: "DM", reference1: "DM"),
    ],
  };
}

Map<String, dynamic> worklistItem({
  String appRef = "APP-WL-001",
  String subType = "NEW",
  String status = "Pending",
}) {
  return <String, dynamic>{
    "applicationRefNo": appRef,
    "appRefNo": appRef,
    "customerName": "Worklist Customer",
    "customerRimNo": 12345,
    "customerRim": 12345,
    "rimNo": 12345,
    "groupId": 100,
    "requestType": "CREDIT",
    "requestTypeId": 10,
    "requestTypeName": "Credit Facility",
    "requestSubType": subType,
    "subType": subType,
    "requestStatus": status,
    "pendingWith": "RM",
    "region": "DXB",
    "segment": "CORP",
    "groupName": "Group",
    "requestedBy": "RM User",
    "purpose": "Purpose",
    "createdDate": "2024-01-01T10:00:00.000Z",
    "dateOfCreation": "01/01/2024 10:00:00 AM",
    "receivedFrom": "Branch A",
    "businessSegment": "Corporate",
    "terminatedReason": "",
  };
}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage =
      <String, Map<String, dynamic>>{};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    _storage[box] ??= <String, dynamic>{};
    _storage[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _storage[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _storage[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _storage[box]?.clear();
  }

  void clearMock() {
    _storage.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAPIManager api;
  late FakeReferenceDataService refs;
  late DashboardRepository repository;
  late MockLocalStorageService mockStorage;

  setUpAll(() async {
    setupConnectivityMock();
    EasyLocalization.logger.enableBuildModes = [];
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    api = FakeAPIManager();
    refs = FakeReferenceDataService()..mockData = standardReferenceData();

    mockStorage = MockLocalStorageService();
    LocalStorageService().getStorage = mockStorage;

    ReferenceDataService.overrideInstance = refs;

    repository = DashboardRepository(
      apiManager: api,
      referenceDataService: refs,
    );

    Globals.user = User(
      id: "U1",
      name: "Test User",
      regions: ["DXB"],
      segments: ["CORP"],
      currentRole: Role(
        id: 1,
        roleId: 1,
        code: "ADMIN",
        name: "Admin",
        bpmRole: "RM",
      ),
    );

    Globals.request = Request(applicationRefNo: "APP-001");
  });

  tearDown(() {
    resetGlobals();
    api.clearMock();
    refs.clearMock();
    mockStorage.clearMock();
  });

  group("constructor and singleton", () {
    test("creates repository with injected dependencies", () {
      expect(repository, isA<DashboardRepository>());
    });

    test("returns singleton instance", () {
      expect(
        identical(DashboardRepository.instance, DashboardRepository.instance),
        isTrue,
      );
    });
  });

  group("getSummary", () {
    test("returns Summary when responseData exists", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"key": "pendingWithMe", "count": 5},
              {"key": "pendingWithBusiness", "count": 12},
              {"key": "pendingWithCredit", "count": 6},
              {"key": "pendingWithDocumentation", "count": 9},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final Summary? result = await repository.getSummary();

      expect(result, isA<Summary>());
      expect(api.callLog.last["endpoint"], APIEndpoints.getSummary);
    });

    test("returns null when responseData is null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getSummary(), isNull);
    });

    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Summary failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(() => repository.getSummary(), throwsMessage("Summary failed"));
    });

    test("rethrows API exception", () async {
      api.setException(Exception("connection failed"));

      expect(
        () => repository.getSummary(),
        throwsMessage("connection failed"),
      );
    });
  });

  group("getDashboardAgeingCount", () {
    test("returns AgingSummary when chart_data exists", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "chart_data": {
                "0_7_days": 10.0,
                "8_15_days": 20.0,
                "16_30_days": 30.0,
                "abv_30_days": 40.0,
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final AgingSummary? result =
          await repository.getDashboardAgeingCount(SummaryType.me);

      expect(result, isA<AgingSummary>());
      expect(result?.zeroToSevenDays, 10.0);
      expect(result?.eightToFifteenDays, 20.0);
      expect(result?.sixteenToThirtyDays, 30.0);
      expect(result?.aboveThirtyDays, 40.0);
      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.getDashboardAgeingCount,
      );
    });

    test("returns null when responseData is null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(
        await repository.getDashboardAgeingCount(SummaryType.me),
        isNull,
      );
    });

    test("returns null when chart_data is null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {"chart_data": null},
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(
        await repository.getDashboardAgeingCount(SummaryType.me),
        isNull,
      );
    });

    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Ageing failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getDashboardAgeingCount(SummaryType.me),
        throwsMessage("Ageing failed"),
      );
    });

    test("rethrows API exception", () async {
      api.setException(Exception("Ageing API failed"));

      expect(
        () => repository.getDashboardAgeingCount(SummaryType.me),
        throwsMessage("Ageing API failed"),
      );
    });
  });

  group("getDocumentationSummary", () {
    test("returns DocumentationSummary when responseData list exists",
        () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"key": "pending", "count": 10},
              {"key": "completed", "count": 5},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final DocumentationSummary? result =
          await repository.getDocumentationSummary(
        type: SummaryType.documentation,
        ageing: DashboardAgeingType.zeroToSevenDays,
      );

      expect(result, isA<DocumentationSummary>());
      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.getDocumentationSummary,
      );
    });

    test("returns DocumentationSummary with ageing selected", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {"key": "pending", "count": 1},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getDocumentationSummary(
        type: SummaryType.documentation,
        ageing: DashboardAgeingType.zeroToSevenDays,
        isAgeingSelected: true,
      );

      expect(result, isA<DocumentationSummary>());
    });

    test("returns DocumentationSummary for empty list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": []},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getDocumentationSummary(
        type: SummaryType.documentation,
        ageing: DashboardAgeingType.zeroToSevenDays,
      );

      expect(result, isA<DocumentationSummary>());
    });

    test("returns null when responseData is null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(
        await repository.getDocumentationSummary(
          type: SummaryType.documentation,
          ageing: DashboardAgeingType.zeroToSevenDays,
        ),
        isNull,
      );
    });

    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Documentation failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getDocumentationSummary(
          type: SummaryType.documentation,
          ageing: DashboardAgeingType.zeroToSevenDays,
        ),
        throwsMessage("Documentation failed"),
      );
    });

    test("rethrows API exception", () async {
      api.setException(Exception("Documentation API failed"));

      expect(
        () => repository.getDocumentationSummary(
          type: SummaryType.documentation,
          ageing: DashboardAgeingType.zeroToSevenDays,
        ),
        throwsMessage("Documentation API failed"),
      );
    });
  });

  group("getRequestDetailsWorkList", () {
    test("returns empty list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "status": {
              "statusCode": 0,
              "statusDescription": "No requests",
            },
            "responseData": {"requestSummary": []},
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getRequestDetailsWorkList(), isEmpty);
    });

    test("returns mapped list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "status": {
              "statusCode": 0,
              "statusDescription": "Success",
            },
            "responseData": {
              "requestSummary": [
                worklistItem(appRef: "APP001"),
                worklistItem(appRef: "APP002", subType: "LC"),
                worklistItem(appRef: "APP003", subType: ""),
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getRequestDetailsWorkList();

      expect(result, hasLength(3));
    });

    test("throws ApiException when status code is not zero", () async {
      api.setResponse(
        AppResponse(
          message: "Invalid request",
          body: {
            "status": {"statusCode": 1, "statusDescription": "Invalid"},
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(
        () => repository.getRequestDetailsWorkList(),
        throwsMessage("Invalid request"),
      );
    });

    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Request details failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getRequestDetailsWorkList(),
        throwsMessage("Request details failed"),
      );
    });

    test("rethrows reference data exception", () async {
      refs.mockException = Exception("Reference data failed");

      expect(
        () => repository.getRequestDetailsWorkList(),
        throwsMessage("Reference data failed"),
      );
    });
  });

  group("getClosedRequestDetailsWorkList", () {
    test("returns mapped closed request list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
              },
            },
            "responseData": [
              worklistItem(appRef: "APP-CLOSED-1"),
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result =
          await repository.getClosedRequestDetailsWorkList("completed");

      expect(result, hasLength(1));
      expect(result?.first.applicationRefNo, "APP-CLOSED-1");
    });

    test("maps transaction subtype fallback", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
              },
            },
            "responseData": [
              worklistItem(appRef: "APP-LC", subType: "LC"),
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result =
          await repository.getClosedRequestDetailsWorkList("completed");

      expect(result, hasLength(1));
      expect(result?.first.requestSubType?.reference1, "LC");
    });

    test("skips invalid non-map items", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
              },
            },
            "responseData": [
              "invalid",
              123,
              worklistItem(appRef: "APP002"),
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result =
          await repository.getClosedRequestDetailsWorkList("completed");

      expect(result, hasLength(1));
      expect(result?.first.applicationRefNo, "APP002");
    });

    test("returns empty list when responseData is null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
              },
            },
            "responseData": null,
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(
        await repository.getClosedRequestDetailsWorkList("completed"),
        isEmpty,
      );
    });

    test("covers fallback references when no reference matches", () async {
      refs.mockData = {
        ReferenceDataKeys.applicationType: <Reference>[],
        ReferenceDataKeys.requestType: <Reference>[],
        ReferenceDataKeys.transactionType: <Reference>[],
        ReferenceDataKeys.requestStatus: <Reference>[],
      };

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
              },
            },
            "responseData": [
              worklistItem(
                appRef: "APP999",
                subType: "UNKNOWN_SUBTYPE",
                status: "UNKNOWN_STATUS",
              )..addAll({
                  "requestType": "UNKNOWN_TYPE",
                  "requestSubType": "UNKNOWN_SUBTYPE",
                  "businessSegment": "UNKNOWN_SEGMENT",
                }),
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result =
          await repository.getClosedRequestDetailsWorkList("completed");

      expect(result, hasLength(1));
      expect(result?.first.requestStatus?.name, "UNKNOWN_STATUS");
      expect(result?.first.requestType?.name, "UNKNOWN_TYPE");
      expect(result?.first.requestSubType?.name,
          "dashboard.home.historicalApplicationTypes",);
      expect(result?.first.businessSegment?.name, "UNKNOWN_SEGMENT");
    });

    test("throws ApiException when baseResponse statusCode is not zero",
        () async {
      api.setResponse(
        AppResponse(
          message: "Invalid closed request",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "1",
                "statusDescription": "Invalid",
              },
            },
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(
        () => repository.getClosedRequestDetailsWorkList("completed"),
        throwsMessage("Invalid closed request"),
      );
    });

    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Closed request failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getClosedRequestDetailsWorkList("completed"),
        throwsMessage("Closed request failed"),
      );
    });
  });

  group("roles and users", () {
    test("getRolesByUser returns roles list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "roles": ["RM", "CA", "CC"],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getRolesByUser(1, "Test User");

      expect(result, ["RM", "CA", "CC"]);
      expect(api.callLog.last["endpoint"], APIEndpoints.getRolesByUser);
    });

    test("getRolesByUser returns empty when responseData null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getRolesByUser(1, "Test User"), isEmpty);
    });

    test("getRolesByUser returns empty when roles null", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {"roles": null},
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getRolesByUser(1, "Test User"), isEmpty);
    });

    test("getRolesByUser throws on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Roles failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getRolesByUser(1, "Test User"),
        throwsMessage("Roles failed"),
      );
    });

    test("getUsersForAssigne returns users with selected role fields",
        () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "role": "RM",
                "roleId": 12,
                "bpmRoleName": "Relationship Manager-WCAS",
                "userDetails": [
                  {
                    "userId": "U100",
                    "userName": "Test RM",
                    "emailId": "rm@test.com",
                  },
                ],
              },
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getUsersForAssigne(["RM"], "APP001");

      expect(result, hasLength(1));
      expect(result?.first.id, "U100");
      expect(result?.first.selectedRole, "RM");
      expect(result?.first.selectedRoleId, 12);
      expect(result?.first.selectedRoleName, "Relationship Manager-WCAS");
      expect(api.callLog.last["endpoint"], APIEndpoints.getFilteredUsersByrole);
    });

    test("getUsersForAssigne returns empty list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": []},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getUsersForAssigne(["RM"], "APP001"), isEmpty);
    });

    test("getUsersForAssigne returns null for null responseData", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getUsersForAssigne(["RM"], "APP001"), isNull);
    });

    test("getUsersForAssigne returns null for non-list responseData", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {"bad": true},
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      expect(await repository.getUsersForAssigne(["RM"], "APP001"), isNull);
    });

    test("getUsersForAssigne throws on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Users failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getUsersForAssigne(["RM"], "APP001"),
        throwsMessage("Users failed"),
      );
    });
  });

  group("assignUserToApplication", () {
    test("uses assignToUser endpoint for admin", () async {
      Globals.user = User(
        id: "ADMIN_USER",
        currentRole: Role(
          id: 1,
          code: "ADMIN",
          bpmRole: "Admin-WCAS",
          userRole: UserRole.admin,
        ),
      );

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      await repository.assignUserToApplication(
        assignedTo: "TARGET_USER",
        assignedRole: null,
        assignedRoleId: 3203,
        assignedRoleName: "Credit Analysts-WCAS",
        appRefNo: "APP001",
        assignToDetail: AssignToDetail(
          mode: 1,
          userAction: -1,
          returnToUser: false,
        ),
      );

      expect(api.callLog.last["endpoint"], APIEndpoints.assignToUser);
    });

    test("uses assignToUser endpoint for business admin", () async {
      Globals.user = User(
        id: "BUSINESS_ADMIN_USER",
        currentRole: Role(
          id: 1,
          code: "BUSINESS_ADMIN",
          bpmRole: "Business Admin-WCAS",
          userRole: UserRole.businessAdmin,
        ),
      );

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      await repository.assignUserToApplication(
        assignedTo: "TARGET_USER",
        assignedRole: null,
        assignedRoleId: 3203,
        assignedRoleName: "Credit Analysts-WCAS",
        appRefNo: "APP002",
        assignToDetail: AssignToDetail(
          mode: 1,
          userAction: -1,
          returnToUser: false,
        ),
      );

      expect(api.callLog.last["endpoint"], APIEndpoints.assignToUser);
    });

    test("uses submitApplicationApproval endpoint for normal user", () async {
      Globals.user = User(
        id: "NORMAL_USER",
        currentRole: Role(
          id: 1,
          code: "RM",
          bpmRole: "Relationship Manager-WCAS",
        ),
      );

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      await repository.assignUserToApplication(
        assignedTo: "TARGET_USER",
        assignedRole: null,
        assignedRoleId: 3203,
        assignedRoleName: "Credit Analysts-WCAS",
        appRefNo: "APP003",
        assignToDetail: AssignToDetail(
          mode: 1,
          userAction: -1,
          returnToUser: false,
        ),
      );

      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.submitApplicationApproval,
      );
    });

    test("assign to me CA uses current user", () async {
      Globals.user = User(
        id: "CURRENT_CA_USER",
        currentRole: Role(
          id: 1,
          code: "CA",
          bpmRole: "Credit Analysts-WCAS",
        ),
      );

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      await repository.assignUserToApplication(
        assignedTo: "OTHER_USER",
        assignedRole: null,
        assignedRoleId: 3203,
        assignedRoleName: "Credit Analysts-WCAS",
        appRefNo: "APP004",
        assignToDetail: AssignToDetail(
          mode: 1,
          userAction: ServerConstants.assignToMeActionCA,
          returnToUser: false,
        ),
      );

      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.submitApplicationApproval,
      );

      expect(
        jsonEncode(api.callLog.last["body"]).contains("CURRENT_CA_USER"),
        true,
      );
    });

    test("assign to me DM uses submit approval endpoint", () async {
      Globals.user = User(
        id: "CURRENT_DM_USER",
        currentRole: Role(
          id: 1,
          code: "DM",
          bpmRole: "Decision Maker-WCAS",
        ),
      );

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      await repository.assignUserToApplication(
        assignedTo: "OTHER_USER",
        assignedRole: null,
        assignedRoleId: 3203,
        assignedRoleName: "Decision Maker-WCAS",
        appRefNo: "APP005",
        assignToDetail: AssignToDetail(
          mode: 1,
          userAction: ServerConstants.assignToMeActionDM,
          returnToUser: false,
        ),
      );

      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.submitApplicationApproval,
      );
    });

    test("throws ApiException when API returns error", () async {
      Globals.user = User(
        id: "NORMAL_USER",
        currentRole: Role(
          id: 1,
          code: "RM",
          bpmRole: "Relationship Manager-WCAS",
        ),
      );

      api.setResponse(
        AppResponse(
          message: "Assignment failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.assignUserToApplication(
          assignedTo: "TARGET_USER",
          assignedRole: null,
          assignedRoleId: 3203,
          assignedRoleName: "Credit Analysts-WCAS",
          appRefNo: "APP006",
          assignToDetail: AssignToDetail(
            mode: 1,
            userAction: -1,
            returnToUser: false,
          ),
        ),
        throwsMessage("Assignment failed"),
      );
    });

    test("rethrows API exception", () async {
      Globals.user = User(
        id: "NORMAL_USER",
        currentRole: Role(
          id: 1,
          code: "RM",
          bpmRole: "Relationship Manager-WCAS",
        ),
      );

      api.setException(Exception("Assignment API failed"));

      expect(
        () => repository.assignUserToApplication(
          assignedTo: "TARGET_USER",
          assignedRole: null,
          assignedRoleId: 3203,
          assignedRoleName: "Credit Analysts-WCAS",
          appRefNo: "APP007",
          assignToDetail: AssignToDetail(
            mode: 1,
            userAction: -1,
            returnToUser: false,
          ),
        ),
        throwsMessage("Assignment API failed"),
      );
    });
  });

  group("getWorkList", () {
    test("returns empty list for empty responseData", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getWorkList(
        summaryType: SummaryType.me,
        ageingType: DashboardAgeingType.zeroToSevenDays,
        isBarGraph: false,
      );

      expect(result, isEmpty);
      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.getRequestDetailsWorkList,
      );
    });

    test("returns non-empty list", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              worklistItem(),
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getWorkList(
        summaryType: SummaryType.me,
        ageingType: DashboardAgeingType.zeroToSevenDays,
        isBarGraph: false,
      );

      expect(result, hasLength(1));
    });

    test("uses bar graph endpoint and optional fields", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getWorkList(
        summaryType: SummaryType.me,
        ageingType: DashboardAgeingType.zeroToSevenDays,
        isBarGraph: true,
        isCCSYS: true,
        stage: "CREDIT",
        crApprovalType: "APPROVAL",
        isAgeingSelected: true,
      );

      expect(result, isEmpty);
      expect(api.callLog.last["endpoint"], APIEndpoints.getWorklistForBarGraph);
    });

    test("initial load removes ageing filter", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      await repository.getWorkList(
        summaryType: SummaryType.me,
        ageingType: DashboardAgeingType.zeroToSevenDays,
        isBarGraph: false,
        isInitialLoad: true,
      );

      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.getRequestDetailsWorkList,
      );
    });

    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Worklist failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getWorkList(
          summaryType: SummaryType.me,
          ageingType: DashboardAgeingType.zeroToSevenDays,
          isBarGraph: false,
        ),
        throwsMessage("Worklist failed"),
      );
    });

    test("rethrows reference data exception", () async {
      refs.mockException = Exception("Worklist reference failed");

      expect(
        () => repository.getWorkList(
          summaryType: SummaryType.me,
          ageingType: DashboardAgeingType.zeroToSevenDays,
          isBarGraph: false,
        ),
        throwsMessage("Worklist reference failed"),
      );
    });
  });

  group("getWorklistSearchCriteria", () {
    test("returns mapped list with custom application type", () async {
      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "requestSummary": [
                {
                  "customerRim": 1059250,
                  "applicationRefNo": "APP-CUSTOM-001",
                  "customerName": "Custom Customer",
                  "groupId": "123",
                  "groupName": "Custom Group",
                  "requestedBy": "RM User",
                  "purpose": "Coverage Purpose",
                  "terminatedReason": null,
                  "createdDate": "2024-01-01T10:00:00.000Z",
                  "requestType": "APN",
                  "requestSubType": "CUSTOM",
                  "customerType": "Corporate",
                  "requestStatus": "Completed",
                  "region": "Dubai",
                  "pendingWith": "RM",
                },
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getWorklistSearchCriteria(
        key: "completed",
        customerRim: "1059250",
        applicationRefNo: "APP",
        segment: "CORP",
        region: "DXB",
        groupId: "123",
        pendingWith: "RM",
        pendingUser: "U1",
        rmName: "RM User",
      );

      expect(result, hasLength(1));
      expect(result.first.customerRimNo, 1059250);
      expect(result.first.applicationRefNo, "APP-CUSTOM-001");
      expect(result.first.groupId, 123);
      expect(result.first.reqRefType?.reference1, "CUSTOM");
      expect(
        api.callLog.last["endpoint"],
        APIEndpoints.getWorklistForSearchCriteria,
      );
    });

    test("unknown subtype fallback", () async {
      refs.mockData = {
        ReferenceDataKeys.applicationType: <Reference>[],
        ReferenceDataKeys.customApplicationType: <Reference>[],
      };

      api.setResponse(
        AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "requestSummary": [
                {
                  "customerRim": null,
                  "applicationRefNo": null,
                  "customerName": null,
                  "groupId": null,
                  "createdDate": null,
                  "requestType": null,
                  "requestSubType": "UNKNOWN",
                  "pendingWith": null,
                },
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        ),
      );

      final result = await repository.getWorklistSearchCriteria(key: "k");

      expect(result, hasLength(1));
      expect(result.first.reqRefType?.reference1, "UNKNOWN");
      expect(result.first.groupId, isNull);
    });

    test("throws on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Search failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getWorklistSearchCriteria(key: "k"),
        throwsMessage("Search failed"),
      );
    });

    test("rethrows reference data exception", () async {
      refs.mockException = Exception("Search ref failed");

      expect(
        () => repository.getWorklistSearchCriteria(key: "k"),
        throwsMessage("Search ref failed"),
      );
    });
  });

  group("getApplicationDetails", () {
    test("throws ApiException on API error", () async {
      api.setResponse(
        AppResponse(
          message: "Application details failed",
          body: {},
          code: 500,
          status: ResponseStatus.error,
        ),
      );

      expect(
        () => repository.getApplicationDetails(
          appRefNo: "APP001",
          requestStatuses: [],
          bussinessSegments: [],
        ),
        throwsMessage("Application details failed"),
      );
    });
  });

  group("openApplication", () {
    late OpenApplicationTestDashboardRepository openRepository;

    setUp(() {
      refs.mockData = standardReferenceData();
      ReferenceDataService.overrideInstance = refs;

      Globals.user = User(
        id: "U1",
        name: "Test User",
        regions: ["DXB"],
        segments: ["CORP"],
        currentRole: Role(
          id: 1,
          roleId: 1,
          code: "RM",
          name: "Relationship Manager",
          bpmRole: "1",
        ),
      );

      Globals.superBpmRolesId = [
        {"1": 1},
        {"RM": 1},
        {"CA": 2},
      ];

      openRepository = OpenApplicationTestDashboardRepository(
        apiManager: api,
        referenceDataService: refs,
      );
    });

    test("maps normal application type branch and group owner", () async {
      final applicationDetails = Request()
        ..applicationRefNo = "APP-NORMAL"
        ..appBusinessSegment = "Corporate"
        ..businessSegm = "Corporate"
        ..applicationType = Reference(reference1: "NEW")
        ..requestType = Reference(reference1: "CREDIT")
        ..requestSubType = Reference(reference1: "NEW")
        ..customerType = Reference(name: "Corporate")
        ..groupOwner = null
        ..customers = [
          Customer()..groupOwner = 999,
        ];

      final request = Request()
        ..applicationRefNo = "APP-NORMAL"
        ..requestSubType = Reference(reference1: "NEW")
        ..customerType = Reference(name: "Corporate");

      openRepository.nextApplicationDetails = applicationDetails;

      try {
        await openRepository.openApplication(request);
      } on Object {
        // AuthRepository/router hard singletons may throw after mapping.
      }

      expect(openRepository.lastAppRefNo, "APP-NORMAL");
      expect(openRepository.lastIsCcsys, false);
      expect(Utils.request.applicationRefNo, "APP-NORMAL");
      expect(Utils.request.businessSegment?.name, "Corporate");
      expect(Utils.request.applicationType?.reference1, "NEW");
      expect(Utils.request.requestType?.reference1, "CREDIT");
      expect(Utils.request.requestSubType?.reference1, "NEW");
      expect(Utils.request.customerType?.name, "Corporate");
      expect(Utils.request.groupOwner, 999);
    });

    test("maps custom application type branch", () async {
      final applicationDetails = Request()
        ..applicationRefNo = "APP-CUSTOM"
        ..appBusinessSegment = "Corporate"
        ..businessSegm = "Corporate"
        ..appTypeReferenceId = 3
        ..applicationType = Reference(reference1: "CUSTOM")
        ..requestType = Reference(reference1: "CREDIT")
        ..requestSubType = Reference(reference1: "CUSTOM")
        ..customerType = Reference(name: "Corporate")
        ..groupOwner = 123;

      final request = Request()
        ..applicationRefNo = "APP-CUSTOM"
        ..requestSubType = Reference(reference1: "CUSTOM")
        ..customerType = Reference(name: "Corporate");

      openRepository.nextApplicationDetails = applicationDetails;

      try {
        await openRepository.openApplication(request);
      } on Object {
        // AuthRepository/router hard singletons may throw after mapping.
      }

      expect(openRepository.lastAppRefNo, "APP-CUSTOM");
      expect(openRepository.lastIsCcsys, false);
      expect(Utils.request.applicationRefNo, "APP-CUSTOM");
      expect(Utils.request.applicationType?.id, 3);
      expect(Utils.request.requestType?.reference1, "CREDIT");
      expect(Utils.request.requestSubType?.reference1, "CUSTOM");
      expect(Utils.request.customerType?.name, "Corporate");
      expect(Utils.request.groupOwner, 123);
    });

    test("maps fallback application and request type references", () async {
      final applicationDetails = Request()
        ..applicationRefNo = "APP-FALLBACK"
        ..appBusinessSegment = "Unknown Segment"
        ..businessSegm = "Unknown Segment"
        ..applicationType = Reference(reference1: "UNKNOWN_APP")
        ..requestType = Reference(reference1: "UNKNOWN_REQ")
        ..requestSubType = Reference(reference1: "UNKNOWN_SUB")
        ..customerType = Reference(name: "Corporate")
        ..groupOwner = 321;

      final request = Request()
        ..applicationRefNo = "APP-FALLBACK"
        ..requestSubType = Reference(reference1: "UNKNOWN_SUB")
        ..customerType = Reference(name: "Corporate");

      openRepository.nextApplicationDetails = applicationDetails;

      try {
        await openRepository.openApplication(request);
      } on Object {
        // AuthRepository/router hard singletons may throw after mapping.
      }

      expect(openRepository.lastAppRefNo, "APP-FALLBACK");
      expect(openRepository.lastIsCcsys, false);
      expect(Utils.request.applicationType?.reference1, "UNKNOWN_APP");
      expect(Utils.request.requestType?.reference1, "UNKNOWN_REQ");
      expect(Utils.request.requestSubType?.reference1, "UNKNOWN_SUB");
      expect(Utils.request.businessSegment?.name, "Unknown Segment");
    });

    test("maps CCSYS branch and computeCanEdit true path", () async {
      final applicationDetails = Request()
        ..applicationRefNo = "APP-CS"
        ..appBusinessSegment = "Corporate"
        ..businessSegm = "Corporate"
        ..applicationType =
            Reference(reference1: ServerConstants.ccsysAppReference1)
        ..requestType = Reference(reference1: "CREDIT")
        ..requestSubType =
            Reference(reference1: ServerConstants.ccsysAppReference1)
        ..customerType = Reference(name: "Corporate")
        ..status = "1"
        ..enabledForView = false
        ..ccsysLifeCycleStatus = [
          ApplicationLifeCycle(
            assignedToRole: 1,
            assignedTo: "U1",
            status: ServerConstants.lifeCycleStatusWaiting,
          ),
        ];

      final request = Request()
        ..applicationRefNo = "APP-CS"
        ..requestSubType =
            Reference(reference1: ServerConstants.ccsysAppReference1)
        ..customerType = Reference(name: "Corporate");

      openRepository.nextApplicationDetails = applicationDetails;

      try {
        await openRepository.openApplication(request);
      } on Object {
        // AuthRepository/router hard singletons may throw after mapping.
      }

      expect(openRepository.lastAppRefNo, "APP-CS");
      expect(openRepository.lastIsCcsys, true);
      expect(Utils.request.applicationRefNo, "APP-CS");
      expect(Utils.request.ccsysCanEditReadOnly, true);
      expect(
        Utils.request.requestType?.reference1,
        ServerConstants.ccsysAppReference2,
      );
      expect(
        Utils.request.requestSubType?.reference1,
        ServerConstants.ccsysAppReference1,
      );
    });

    test("maps CCSYS branch and computeCanEdit false path", () async {
      final applicationDetails = Request()
        ..applicationRefNo = "APP-CS-RO"
        ..appBusinessSegment = "Corporate"
        ..businessSegm = "Corporate"
        ..applicationType =
            Reference(reference1: ServerConstants.ccsysAppReference1)
        ..requestType = Reference(reference1: "CREDIT")
        ..requestSubType =
            Reference(reference1: ServerConstants.ccsysAppReference1)
        ..customerType = Reference(name: "Corporate")
        ..status = ServerConstants.lifeCycleReadOnlyStatuses.first.toString()
        ..enabledForView = true
        ..ccsysLifeCycleStatus = [
          ApplicationLifeCycle(
            assignedToRole: 99,
            assignedTo: "OTHER",
            status: "completed",
          ),
        ];

      final request = Request()
        ..applicationRefNo = "APP-CS-RO"
        ..requestSubType =
            Reference(reference1: ServerConstants.ccsysAppReference1)
        ..customerType = Reference(name: "Corporate");

      openRepository.nextApplicationDetails = applicationDetails;

      try {
        await openRepository.openApplication(request);
      } on Object {
        // AuthRepository/router hard singletons may throw after mapping.
      }

      expect(openRepository.lastAppRefNo, "APP-CS-RO");
      expect(openRepository.lastIsCcsys, true);
      expect(Utils.request.applicationRefNo, "APP-CS-RO");
      expect(Utils.request.ccsysCanEditReadOnly, false);
      expect(
        Utils.request.requestType?.reference1,
        ServerConstants.ccsysAppReference2,
      );
      expect(
        Utils.request.requestSubType?.reference1,
        ServerConstants.ccsysAppReference1,
      );
    });

    test("does not set Utils.request when details are null", () async {
      Utils.request = Request(applicationRefNo: "OLD");

      final request = Request()
        ..applicationRefNo = "APP-NULL"
        ..requestSubType = Reference(reference1: "NEW")
        ..customerType = Reference(name: "Corporate");

      openRepository.nextApplicationDetails = null;

      try {
        await openRepository.openApplication(request);
      } on Object {
        // AuthRepository/router hard singletons may throw after mapping.
      }

      expect(openRepository.lastAppRefNo, "APP-NULL");
      expect(openRepository.lastIsCcsys, false);
      expect(Utils.request.applicationRefNo, "OLD");
    });

    test("rethrows reference data exception", () async {
      refs.mockException = Exception("open reference failed");

      final request = Request()
        ..applicationRefNo = "APP-REF-ERR"
        ..requestSubType = Reference(reference1: "NEW")
        ..customerType = Reference(name: "Corporate");

      await expectLater(
        openRepository.openApplication(request),
        throwsMessage("open reference failed"),
      );
    });
  });

  group("setBusinessSegment", () {
    test("corporate", () {
      final request = Request();

      final result = repository.setBusinessSegment(
        "Corporate",
        [
          Reference(id: 1, name: "Corporate"),
          Reference(id: 2, name: "Financial Institution"),
        ],
        applicationDetails: request,
      );

      expect(result, BusinessSegment.corporate);
      expect(request.businessSegment?.id, 1);
    });

    test("financial institution", () {
      final request = Request();

      final result = repository.setBusinessSegment(
        "Financial Institution",
        [Reference(id: 2, name: "Financial Institution")],
        applicationDetails: request,
      );

      expect(result, BusinessSegment.financialInstitution);
      expect(request.businessSegment?.id, 2);
    });

    test("unknown defaults corporate", () {
      final request = Request();

      final result = repository.setBusinessSegment(
        "UNKNOWN",
        [Reference(id: 1, name: "Corporate")],
        applicationDetails: request,
      );

      expect(result, BusinessSegment.corporate);
      expect(
        request.businessSegment?.id,
        ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );
      expect(request.businessSegment?.name, "UNKNOWN");
    });

    test("fallback id when matched ref id null", () {
      final request = Request();

      repository.setBusinessSegment(
        "Corporate",
        [Reference(name: "Corporate")],
        applicationDetails: request,
      );

      expect(
        request.businessSegment?.id,
        ServerConstants.businessSegmentId[BusinessSegment.corporate],
      );
    });

    test("applicationDetails null safe", () {
      expect(
        repository.setBusinessSegment(
          "Corporate",
          [Reference(id: 1, name: "Corporate")],
        ),
        BusinessSegment.corporate,
      );
    });
  });

  group("normalizeEnabledForView", () {
    test("all branches", () {
      expect(repository.normalizeEnabledForView(null), isNull);
      expect(repository.normalizeEnabledForView(true), true);
      expect(repository.normalizeEnabledForView(false), false);
      expect(repository.normalizeEnabledForView(0), false);
      expect(repository.normalizeEnabledForView(1), true);
      expect(repository.normalizeEnabledForView(2), true);
      expect(repository.normalizeEnabledForView(-1), true);
      expect(repository.normalizeEnabledForView("0"), false);
      expect(repository.normalizeEnabledForView("1"), true);
      expect(repository.normalizeEnabledForView("true"), true);
      expect(repository.normalizeEnabledForView("false"), false);
      expect(repository.normalizeEnabledForView(" TRUE "), true);
      expect(repository.normalizeEnabledForView(" False "), false);
      expect(repository.normalizeEnabledForView("yes"), isNull);
      expect(repository.normalizeEnabledForView(""), isNull);
      expect(repository.normalizeEnabledForView([]), isNull);
      expect(repository.normalizeEnabledForView({}), isNull);
      expect(repository.normalizeEnabledForView(Object()), isNull);
    });
  });

  group("computeCanEdit", () {
    test("terminal status false", () {
      expect(
        repository.computeCanEdit(
          applicationStatus: ServerConstants.lifeCycleReadOnlyStatuses.first,
          enabledForView: false,
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );
    });

    test("enabledForView false allows edit", () {
      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: false,
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        true,
      );
    });

    test("enabledForView zero allows edit", () {
      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: 0,
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        true,
      );
    });

    test("matching lifecycle allows edit", () {
      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: true,
          lifeCycles: [
            ApplicationLifeCycle(
              assignedToRole: 1,
              assignedTo: "U1",
              status: ServerConstants.lifeCycleStatusWaiting,
            ),
          ],
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        true,
      );
    });

    test("mismatch cases are false", () {
      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: true,
          lifeCycles: [
            ApplicationLifeCycle(
              assignedToRole: 99,
              assignedTo: "U1",
              status: ServerConstants.lifeCycleStatusWaiting,
            ),
          ],
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );

      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: true,
          lifeCycles: [
            ApplicationLifeCycle(
              assignedToRole: 1,
              assignedTo: "OTHER",
              status: ServerConstants.lifeCycleStatusWaiting,
            ),
          ],
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );

      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: true,
          lifeCycles: [
            ApplicationLifeCycle(
              assignedToRole: 1,
              assignedTo: "U1",
              status: "completed",
            ),
          ],
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );

      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: true,
          lifeCycles: const [],
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );

      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: null,
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );

      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: "unknown",
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        false,
      );
    });

    test("string false and zero allow edit", () {
      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: "false",
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        true,
      );

      expect(
        repository.computeCanEdit(
          applicationStatus: null,
          enabledForView: "0",
          lifeCycles: null,
          validateUser: const ValidateUser(bpmRole: "1", userId: "U1"),
        ),
        true,
      );
    });
  });

  group("getAssignedUserIfNotCurrentUser", () {
    test("null guards", () {
      Globals.applicationDetails = null;
      expect(repository.getAssignedUserIfNotCurrentUser(), isNull);

      Globals.applicationDetails = ApplicationDetails()
        ..applicationLifeCycle = null;
      expect(repository.getAssignedUserIfNotCurrentUser(), isNull);
    });

    test("assigned to current user returns null", () {
      Globals.superBpmRolesId = [
        {"RM": 1},
      ];

      Globals.user = User()
        ..id = "123"
        ..currentRole = Role(bpmRole: "RM");

      Globals.applicationDetails = ApplicationDetails()
        ..applicationLifeCycle = ApplicationLifeCycle()
        ..applicationLifeCycle!.assignedTo = "123"
        ..applicationLifeCycle!.assignedToRole = 1;

      expect(repository.getAssignedUserIfNotCurrentUser(), isNull);
    });

    test("assigned to different user returns record", () {
      Globals.superBpmRolesId = [
        {"RM": 1},
        {"CA": 2},
      ];

      Globals.user = User()
        ..id = "123"
        ..currentRole = Role(bpmRole: "RM");

      Globals.applicationDetails = ApplicationDetails()
        ..applicationLifeCycle = ApplicationLifeCycle()
        ..applicationLifeCycle!.assignedTo = "999"
        ..applicationLifeCycle!.assignedToRole = 2;

      final result = repository.getAssignedUserIfNotCurrentUser();

      expect(result, isNotNull);
      expect(result?.userId, "999");
      expect(result?.roleName, "CA");
    });

    test("empty assignedTo returns null", () {
      Globals.superBpmRolesId = [
        {"RM": 1},
      ];

      Globals.user = User()
        ..id = "123"
        ..currentRole = Role(bpmRole: "RM");

      Globals.applicationDetails = ApplicationDetails()
        ..applicationLifeCycle = ApplicationLifeCycle()
        ..applicationLifeCycle!.assignedTo = ""
        ..applicationLifeCycle!.assignedToRole = 1;

      expect(repository.getAssignedUserIfNotCurrentUser(), isNull);
    });

    test("role name empty when assigned role not found", () {
      Globals.superBpmRolesId = [
        {"RM": 1},
      ];

      Globals.user = User()
        ..id = "123"
        ..currentRole = Role(bpmRole: "RM");

      Globals.applicationDetails = ApplicationDetails()
        ..applicationLifeCycle = ApplicationLifeCycle()
        ..applicationLifeCycle!.assignedTo = "999"
        ..applicationLifeCycle!.assignedToRole = 99;

      final result = repository.getAssignedUserIfNotCurrentUser();

      expect(result, isNotNull);
      expect(result?.userId, "999");
      expect(result?.roleName, "");
    });
  });
}
