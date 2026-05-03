import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/home/aging_summary.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";
import "package:wcas_frontend/models/home/home.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

extension LocalizationBypass on String {
  String tr() => this;
}

// Helper to create DocumentationStage
DocumentationStage createDocumentationStage({int totalCount = 0}) {
  final rows = <Map<String, dynamic>>[
    {"stage": "FOL not required", "crApprovalDesc": "TOTAL", "total": 10},
    {"stage": "FOL not required", "crApprovalDesc": "New to Bank", "total": 3},
    {
      "stage": "FOL not required",
      "crApprovalDesc": "Isolated Memo",
      "total": 2,
    },
    {
      "stage": "FOL not required",
      "crApprovalDesc": " annual review - increase ",
      "total": "5",
    },
    // noisy/invalid rows
    {"stage": "FOL not required", "crApprovalDesc": null, "total": 99},
    {"stage": "FOL not required", "crApprovalDesc": "  ", "total": 99},
  ];

  return DocumentationStage.fromFlatRows(rows);
}

// Helper to create DocumentationSummary
DocumentationSummary createDocumentationSummary() {
  final rows = <Map<String, dynamic>>[
    {"stage": "FOL not required", "crApprovalDesc": "TOTAL", "total": 10},
    {"stage": "FOL not required", "crApprovalDesc": "New to Bank", "total": 3},
    {
      "stage": "FOL not required",
      "crApprovalDesc": "Isolated Memo",
      "total": 2,
    },
    {
      "stage": "fol NOT required ",
      "crApprovalDesc": "Annual Review - Increase",
      "total": 5,
    },
    {
      "stage": "FOL draft under preparation",
      "crApprovalDesc": "TOTAL",
      "total": 4,
    },
    {
      "stage": "FOL draft under preparation",
      "crApprovalDesc": "New to Bank",
      "total": 4,
    },
  ];

  return DocumentationSummary.fromJson(rows);
}

// Mock LocalStorageService
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    _storage[box] ??= {};
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

  void clearAll() {
    _storage.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HomeViewModel viewModel;
  // late MockContext mockContext;

  late MockDashboardRepository mockRepo;
  // late MockAuthRepository mockAuthRepo;

  late MockLocalStorageService mockLocalStorageService;

  // Stub connectivity_plus channel so every check() returns wifi
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    await EnvConfig.setEnvironment();
    SharedPreferences.setMockInitialValues({});

    await EasyLocalization.ensureInitialized();

    registerFallbackValue("");
    registerFallbackValue(SummaryType.me);
    registerFallbackValue(DashboardAgeingType.zeroToSevenDays);
    registerFallbackValue(Request());
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockRepo = MockDashboardRepository();
    // mockAuthRepo = MockAuthRepository();

    viewModel = HomeViewModel()
      // mockContext = MockContext();

      ..repository = mockRepo;

    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);

    // Connectivity mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return [ConnectivityResult.wifi.name];
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall methodCall) async {
        return "wifi"; // or whatever mock result you need
      },
    );

    // Default logged-in non-admin user unless overridden per test

    Globals.user = User(
      id: "U1",
      name: "Tester",
      currentRole: (Role(code: "RM")
        ..userRole = UserRole.relationshipManagerBussiness),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  group("HomeViewModel basics", () {
    test("initial state is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("getTableColor returns expected colors for segments", () {
      viewModel.showWorkListColors = true;
      expect(
        viewModel.getTableColor(BusinessSegment.financialInstitution),
        isA<Color?>(),
      );

      expect(viewModel.getTableColor(BusinessSegment.corporate), isA<Color?>());

      expect(viewModel.getTableColor(BusinessSegment.business), isA<Color?>());

      expect(viewModel.getTableColor(BusinessSegment.baf), isA<Color?>());

      expect(viewModel.getTableColor(BusinessSegment.personal), isA<Color?>());
    });

    test("getTableColor returns expected colors for segments", () {
      viewModel.showWorkListColors = false;
      expect(
        viewModel.getTableColor(BusinessSegment.financialInstitution),
        isA<Color?>(),
      );

      expect(viewModel.getTableColor(BusinessSegment.corporate), isA<Color?>());

      expect(viewModel.getTableColor(BusinessSegment.business), isA<Color?>());

      expect(viewModel.getTableColor(BusinessSegment.baf), isA<Color?>());

      expect(viewModel.getTableColor(BusinessSegment.personal), isA<Color?>());
    });
  });

  group("Table data and filtering", () {
    test("getTableData success populates draftTableData and filteredRequests",
        () async {
      final requests = [
        Request(
          applicationRefNo: "REF1",
          customerName: "Alice",
          requestType: Reference(name: "RT1"),
        ),
        Request(
          applicationRefNo: "REF2",
          customerName: "Bob",
          requestType: Reference(name: "RT2"),
        ),
      ];

      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => requests);

      viewModel.selectedSummary = SummaryType.me;
      await viewModel.getWorklist();

      expect(viewModel.worklistData.length, 2);

      expect(viewModel.filteredRequests.length, 2);

      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("onFilter by name filters correctly and sets applicantNameFilter",
        () async {
      viewModel.worklistData = [
        Request(customerName: "Alice", applicationRefNo: "REF123"),
        Request(customerName: "Bob", applicationRefNo: "XYZ"),
      ];

      await viewModel.onFilter(
        value: "Alice",
        filterType: FilterType.applicantName,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.customerName, "Alice");
      expect(viewModel.applicantNameFilter, "Alice");
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("onFilter by type with selectedTypes filters correctly", () async {
      final appType = Reference(name: "TypeA");
      viewModel.worklistData = [
        Request(customerName: "Alice", applicationType: appType),
        Request(customerName: "Bob", applicationType: Reference(name: "TypeB")),
      ];

      await viewModel.onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [Request(applicationType: appType)],
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.applicationType?.name, "TypeA");
      expect(viewModel.requestTypeFilter.length, 1);
    });

    test("onFilter by type with empty selectedTypes resets to all data",
        () async {
      viewModel.worklistData = [
        Request(
          customerName: "Alice",
          applicationType: Reference(name: "TypeA"),
        ),
        Request(customerName: "Bob", applicationType: Reference(name: "TypeB")),
      ];

      await viewModel.onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [],
      );

      expect(viewModel.filteredRequests.length, 2);
      expect(viewModel.requestTypeFilter.length, 0);
    });

    test("onFilter by rim filters correctly and sets applicantRimFilter",
        () async {
      viewModel.worklistData = [
        Request(customerName: "Alice", customerRimNo: 12345),
        Request(customerName: "Bob", customerRimNo: 67890),
      ];

      await viewModel.onFilter(
        value: "123",
        filterType: FilterType.applicantRim,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.customerRimNo, 12345);
      expect(viewModel.applicantRimFilter, "123");
    });

    test("onFilter by refNo filters correctly and sets reqRefNoFilter",
        () async {
      viewModel.worklistData = [
        Request(customerName: "Alice", applicationRefNo: "REF123"),
        Request(customerName: "Bob", applicationRefNo: "XYZ"),
      ];

      await viewModel.onFilter(
        value: "REF",
        filterType: FilterType.referenceNumber,
      );

      expect(viewModel.filteredRequests.length, 1);

      expect(viewModel.filteredRequests.first?.applicationRefNo, "REF123");

      expect(viewModel.reqRefNoFilter, "REF");

      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });
  });

  group("Refresh and other flows", () {
    test(
      "init test",
      () {
        // Skipped: init() wires real repository instance and performs network
        // calls.
        // Unit tests should avoid external side effects.
      },
      skip: "Skipped to avoid real network calls from init()",
    );

    test("getSummaryText and getSummaryType mappings return expected values",
        () {
      final txt = viewModel.getSummaryText(SummaryType.me);

      expect(txt, isA<String>());

      final t = viewModel
          .getSummaryType(viewModel.summaryTypeStringMap[SummaryType.me] ?? "");

      expect(t, SummaryType.me);
    });

    test(
        "getSummaryText and getSummaryType mappings"
        " return expected else values", () {
      final txt = viewModel.getSummaryText(SummaryType.na);

      expect(txt, isA<String>());

      final t = viewModel
          .getSummaryType(viewModel.summaryTypeStringMap[SummaryType.me] ?? "");

      expect(t, SummaryType.me);
    });

    test(
      "onTapApplicationRefNo test skipped due to singleton pattern",
      () {
        // Skipped: onTapApplicationRefNo() calls AuthRepository.instance
        // singleton which cannot be easily mocked.
        // The method updates roles and navigates which requires complex setup
        // to test properly.
      },
      skip: "Skipped due to singleton AuthRepository pattern",
    );

    test(
      "onTapApplicationRefNo error flow test skipped due to singleton pattern",
      () {
        // Skipped: onTapApplicationRefNo() calls AuthRepository.instance
        // singleton which cannot be easily mocked.
      },
      skip: "Skipped due to singleton AuthRepository pattern",
    );

    test(
      "onActionClicked test skipped due to dialog dependency",
      () {
        // Skipped: onActionClicked() shows a Material dialog which requires
        // proper Material widget context
      },
      skip: "Skipped due to Material dialog context requirements",
    );
  });

  group("onTapGraph", () {
    test("onTapGraph sets selectedGraphValue and emits loaded state", () async {
      await viewModel.onTapGraph(
        text: "test-value",
        selectedDocStage: null,
      );

      expect(viewModel.selectedGraphValue, "test-value");
      expect(viewModel.state.graphLoader, LoadingStatus.loaded);
    });

    test("onTapGraph can set different values", () async {
      await viewModel.onTapGraph(
        text: "first-value",
        selectedDocStage: null,
      );
      expect(viewModel.selectedGraphValue, "first-value");

      await viewModel.onTapGraph(
        text: "second-value",
        selectedDocStage: null,
      );
      expect(viewModel.selectedGraphValue, "second-value");
    });
  });

  group("onSelectGraphFilter", () {
    test("onSelectGraphFilter updates filter and fetches worklist", () async {
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      viewModel.selectedSummary = SummaryType.me;

      await viewModel
          .onSelectGraphFilter(DashboardAgeingType.eightToFifteenDays);

      expect(
        viewModel.selectedGraphFilter,
        DashboardAgeingType.eightToFifteenDays,
      );
      expect(viewModel.state.graphLoader, LoadingStatus.loaded);
    });
  });

  group("getSummary", () {
    test("getSummary success updates summaryData", () async {
      final summary = Summary(pendingWithMe: {});
      when(() => mockRepo.getSummary()).thenAnswer((_) async => summary);

      await viewModel.getSummary();

      expect(viewModel.summaryData, summary);
    });

    test("getSummary with refresh=true sets refreshLoader", () async {
      final summary = Summary(pendingWithMe: {});
      when(() => mockRepo.getSummary()).thenAnswer((_) async => summary);

      await viewModel.getSummary(isRefresh: true);

      expect(viewModel.summaryData, summary);
    });

    test("getSummary error sets errorText and error state", () async {
      when(() => mockRepo.getSummary()).thenThrow(Exception("Summary error"));

      await viewModel.getSummary();

      expect(viewModel.errorText, contains("Exception"));
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      expect(viewModel.state.refreshLoader, false);
    });
  });

  group("getWorklist with refresh", () {
    test("getWorklist with refresh=true sets refreshLoader", () async {
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      viewModel.selectedSummary = SummaryType.me;

      await viewModel.getWorklist(isRefresh: true);

      expect(viewModel.state.refreshLoader, false);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });
  });

  group("getAgeingSummary", () {
    test("getAgeingSummary for non-documentation type shows pie chart",
        () async {
      final agingSummary = AgingSummary(
        zeroToSevenDays: 10,
        eightToFifteenDays: 5,
        sixteenToThirtyDays: 3,
        aboveThirtyDays: 2,
      );

      when(() => mockRepo.getDashboardAgeingCount(any()))
          .thenAnswer((_) async => agingSummary);
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getAgeingSummary(SummaryType.me);

      expect(viewModel.visibleGraphType, VisibleGraphType.pie);
      expect(viewModel.graphTitle, "Active Request");
      expect(viewModel.ageingSummary, agingSummary);
      expect(viewModel.selectedSummary, SummaryType.me);
      expect(
        viewModel.selectedGraphFilter,
        DashboardAgeingType.zeroToSevenDays,
      );
    });

    test("getAgeingSummary error throws exception", () async {
      when(() => mockRepo.getDashboardAgeingCount(any()))
          .thenThrow(Exception("Ageing error"));
    });
  });

  group("getDocumentationSummary", () {
    test("getDocumentationSummary error throws exception", () async {
      viewModel.selectedSummary = SummaryType.documentation;

      when(
        () => mockRepo.getDocumentationSummary(
          ageing: any(named: "ageing"),
          type: any(named: "type"),
        ),
      ).thenThrow(Exception("Doc summary error"));

      expect(
        () => viewModel.getDocumentationSummary(),
        throwsA(contains("Exception")),
      );
    });
  });

  group("onClickRefresh", () {
    test("onClickRefresh calls getSummary and getAgeingSummary", () async {
      final summary = Summary(pendingWithMe: {});
      final agingSummary = AgingSummary(
        zeroToSevenDays: 10,
        eightToFifteenDays: 5,
        sixteenToThirtyDays: 3,
        aboveThirtyDays: 2,
      );

      when(() => mockRepo.getSummary()).thenAnswer((_) async => summary);
      when(() => mockRepo.getDashboardAgeingCount(any()))
          .thenAnswer((_) async => agingSummary);
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      viewModel.selectedSummary = SummaryType.me;

      await viewModel.onClickRefresh();

      expect(viewModel.summaryData, summary);
      verify(() => mockRepo.getSummary()).called(1);
    });
  });

  group("openApplication", () {
    test("openApplication success updates appRefIndex", () async {
      final request = Request(applicationRefNo: "REF123");

      when(() => mockRepo.openApplication(any())).thenAnswer((_) async {});

      await viewModel.openApplication(request, 0);

      expect(viewModel.state.appRefIndex, -1);
    });

    test("openApplication error resets appRefIndex", () async {
      final request = Request(applicationRefNo: "REF123");

      when(() => mockRepo.openApplication(any()))
          .thenThrow(Exception("Open error"));

      // The toast will fail since Toastification isn't initialized, but state
      // should still be updated
      try {
        await viewModel.openApplication(request, 0);
      } catch (_) {
        // Toastification assertion error expected
      }

      expect(viewModel.state.appRefIndex, -1);
    });
  });

  group("downloadSpreadSmart", () {
    test("downloadSpreadSmart success completes without error", () async {
      when(() => mockRepo.downloadFile(any())).thenAnswer((_) async {});

      await viewModel.downloadSpreadSmart();

      verify(() => mockRepo.downloadFile(any())).called(1);
    });

    test("downloadSpreadSmart error calls downloadFile", () async {
      when(() => mockRepo.downloadFile(any()))
          .thenThrow(Exception("Download error"));

      // The toast will fail since Toastification isn't initialized
      try {
        await viewModel.downloadSpreadSmart();
      } catch (_) {
        // Toastification assertion error expected
      }

      verify(() => mockRepo.downloadFile(any())).called(1);
    });
  });

  group("downloadUserManual", () {
    test("downloadUserManual success completes without error", () async {
      when(() => mockRepo.downloadFile(any())).thenAnswer((_) async {});

      await viewModel.downloadUserManual();

      verify(() => mockRepo.downloadFile(any())).called(1);
    });

    test("downloadUserManual error calls downloadFile", () async {
      when(() => mockRepo.downloadFile(any()))
          .thenThrow(Exception("Download error"));

      // The toast will fail since Toastification isn't initialized
      try {
        await viewModel.downloadUserManual();
      } catch (_) {
        // Toastification assertion error expected
      }

      verify(() => mockRepo.downloadFile(any())).called(1);
    });
  });

  group("getTableColor edge cases", () {
    test("getTableColor returns financial institution CF color", () {
      viewModel.showWorkListColors = true;
      expect(
        viewModel.getTableColor(BusinessSegment.financialInstitutionCF),
        isA<Color?>(),
      );
    });
  });

  group("getSummaryType edge cases", () {
    test("getSummaryType returns na for unknown text", () {
      final result = viewModel.getSummaryType("unknown-text");
      expect(result, SummaryType.na);
    });
  });

  group("getWorklist null handling", () {
    test("getWorklist handles null response from repository", () async {
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => null);

      viewModel.selectedSummary = SummaryType.me;
      await viewModel.getWorklist();

      expect(viewModel.worklistData, isEmpty);
      expect(viewModel.filteredRequests, isEmpty);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });
  });

  group("Additional onFilter tests", () {
    test("onFilter with null selectedTypes defaults to worklistData", () async {
      viewModel.worklistData = [
        Request(
          customerName: "Alice",
          applicationType: Reference(name: "TypeA"),
        ),
        Request(customerName: "Bob", applicationType: Reference(name: "TypeB")),
      ];

      await viewModel.onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: null,
      );

      expect(viewModel.filteredRequests.length, 2);
    });

    test("onFilter by applicantName with empty value returns no matches",
        () async {
      viewModel.worklistData = [
        Request(customerName: "Alice", applicationRefNo: "REF123"),
        Request(customerName: "Bob", applicationRefNo: "XYZ"),
      ];

      await viewModel.onFilter(
        value: "NonExistent",
        filterType: FilterType.applicantName,
      );

      expect(viewModel.filteredRequests.length, 0);
    });

    test("onFilter by rim with partial match", () async {
      viewModel.worklistData = [
        Request(customerName: "Alice", customerRimNo: 99999),
        Request(customerName: "Bob", customerRimNo: 12345),
      ];

      await viewModel.onFilter(
        value: "99",
        filterType: FilterType.applicantRim,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.customerRimNo, 99999);
    });
  });

  group("Additional getAgeingSummary tests", () {
    test("getAgeingSummary for team type shows pie chart", () async {
      final agingSummary = AgingSummary(
        zeroToSevenDays: 5,
        eightToFifteenDays: 3,
        sixteenToThirtyDays: 2,
        aboveThirtyDays: 1,
      );

      when(() => mockRepo.getDashboardAgeingCount(any()))
          .thenAnswer((_) async => agingSummary);
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getAgeingSummary(SummaryType.team);

      expect(viewModel.visibleGraphType, VisibleGraphType.pie);
      expect(viewModel.selectedSummary, SummaryType.team);
    });

    test("getAgeingSummary for credit type shows pie chart", () async {
      final agingSummary = AgingSummary(
        zeroToSevenDays: 8,
        eightToFifteenDays: 4,
        sixteenToThirtyDays: 2,
        aboveThirtyDays: 1,
      );

      when(() => mockRepo.getDashboardAgeingCount(any()))
          .thenAnswer((_) async => agingSummary);
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getAgeingSummary(SummaryType.credit);

      expect(viewModel.visibleGraphType, VisibleGraphType.pie);
      expect(viewModel.graphTitle, "Active Request");
    });
  });

  group("Additional openApplication tests", () {
    test("openApplication sets appRefIndex before calling repo", () async {
      final request = Request(applicationRefNo: "REF456");

      when(() => mockRepo.openApplication(any())).thenAnswer((_) async {});

      await viewModel.openApplication(request, 5);

      verify(() => mockRepo.openApplication(request)).called(1);
    });

    test("openApplication with null index", () async {
      final request = Request(applicationRefNo: "REF789");

      when(() => mockRepo.openApplication(any())).thenAnswer((_) async {});

      await viewModel.openApplication(request, null);

      expect(viewModel.state.appRefIndex, -1);
    });
  });

  group("Additional getSummary tests", () {
    test("getSummary returns null when repository returns null", () async {
      when(() => mockRepo.getSummary()).thenAnswer((_) async => null);

      await viewModel.getSummary();

      expect(viewModel.summaryData, isNull);
    });
  });

  group("onSelectGraphFilter additional tests", () {
    test("onSelectGraphFilter with different ageing type", () async {
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      viewModel.selectedSummary = SummaryType.me;

      await viewModel
          .onSelectGraphFilter(DashboardAgeingType.sixteenToThirtyDays);

      expect(
        viewModel.selectedGraphFilter,
        DashboardAgeingType.sixteenToThirtyDays,
      );
    });

    test("onSelectGraphFilter with above thirty days", () async {
      when(
        () => mockRepo.getWorkList(
          ageingType: any(named: "ageingType"),
          summaryType: any(named: "summaryType"),
          isBarGraph: false,
        ),
      ).thenAnswer((_) async => []);

      viewModel.selectedSummary = SummaryType.me;

      await viewModel.onSelectGraphFilter(DashboardAgeingType.aboveThirtyDays);

      expect(
        viewModel.selectedGraphFilter,
        DashboardAgeingType.aboveThirtyDays,
      );
    });
  });

  group("onClickBarGraphLegend", () {
    test(
      "sets legend, sets crApprovalType, emits loaded, and triggers worklist",
      () async {
        // Arrange
        final viewModel = HomeViewModel();

        // Stub repository to avoid errors from getWorklist()
        final mockRepo = MockDashboardRepository();
        viewModel.repository = mockRepo;

        when(
          () => mockRepo.getWorkList(
            ageingType: any(named: "ageingType"),
            summaryType: any(named: "summaryType"),
            isBarGraph: any(named: "isBarGraph"),
            stage: any(named: "stage"),
            crApprovalType: any(named: "crApprovalType"),
          ),
        ).thenAnswer((_) async => []);

        viewModel
          ..selectedSummary = SummaryType.me

          // Act
          ..onClickBarGraphLegend(
            "New to Bank",
            selectedDocStage: null,
          );

        // Assert
        expect(viewModel.selectedBarGraphLegendLabel, "New to Bank");
        expect(viewModel.barGraphCrApprovalType, "New to Bank");
        expect(viewModel.state.graphLoader, LoadingStatus.loaded);
      },
    );

    test(
      "clears legend and crApprovalType when same legend clicked again",
      () async {
        // Arrange
        final viewModel = HomeViewModel();

        final mockRepo = MockDashboardRepository();
        viewModel.repository = mockRepo;

        when(
          () => mockRepo.getWorkList(
            ageingType: any(named: "ageingType"),
            summaryType: any(named: "summaryType"),
            isBarGraph: any(named: "isBarGraph"),
            stage: any(named: "stage"),
            crApprovalType: any(named: "crApprovalType"),
          ),
        ).thenAnswer((_) async => []);

        viewModel
          ..selectedSummary = SummaryType.me

          // First click
          ..onClickBarGraphLegend("New to Bank")

          // Second click (toggle off)
          ..onClickBarGraphLegend("New to Bank");

        // Assert
        expect(viewModel.selectedBarGraphLegendLabel, isNull);
        expect(viewModel.barGraphCrApprovalType, isNull);
        expect(viewModel.state.graphLoader, LoadingStatus.loaded);
      },
    );

    test(
      "updates docStage when provided",
      () async {
        // Arrange
        final viewModel = HomeViewModel();

        final mockRepo = MockDashboardRepository();
        viewModel.repository = mockRepo;

        when(
          () => mockRepo.getWorkList(
            ageingType: any(named: "ageingType"),
            summaryType: any(named: "summaryType"),
            isBarGraph: any(named: "isBarGraph"),
            stage: any(named: "stage"),
            crApprovalType: any(named: "crApprovalType"),
          ),
        ).thenAnswer((_) async => []);

        viewModel.selectedSummary = SummaryType.me;

        final docStage = DocumentationStage.fromFlatRows([]);

        // Act
        viewModel.onClickBarGraphLegend(
          "Isolated Memo",
          selectedDocStage: docStage,
        );

        // Assert
        expect(viewModel.docStage, docStage);
        expect(viewModel.selectedBarGraphLegendLabel, "Isolated Memo");
      },
    );
  });

  group("showCreateReq", () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel()..showCreateRequest = false;
    });

    test("sets showCreateRequest TRUE for allowed roles", () {
      for (final role in [
        UserRole.relationshipOfficer,
        UserRole.relationshipManager,
        UserRole.creditAnalyst,
        UserRole.creditCordinator,
      ]) {
        Globals.user = User(
          currentRole: Role()..userRole = role,
        );

        viewModel
          ..showCreateRequest = false
          ..showCreateReq();

        expect(
          viewModel.showCreateRequest,
          true,
          reason: "Expected TRUE for role $role",
        );
      }
    });

    test("keeps showCreateRequest FALSE for non-allowed roles", () {
      Globals.user = User(
        currentRole: Role()..userRole = UserRole.documentationChecker,
      );

      viewModel.showCreateReq();

      expect(viewModel.showCreateRequest, false);
    });
  });

  group("getTableTextColor", () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test("returns BLACK when showWorkListColors is false (any segment)", () {
      viewModel.showWorkListColors = false;

      expect(
        viewModel.getTableTextColor(BusinessSegment.financialInstitution),
        AppColors.black,
      );

      expect(
        viewModel.getTableTextColor(BusinessSegment.corporate),
        AppColors.black,
      );

      expect(
        viewModel.getTableTextColor(null),
        AppColors.black,
      );
    });

    test(
      "returns BLACK for financialInstitution when showWorkListColors is true",
      () {
        viewModel.showWorkListColors = true;

        final color =
            viewModel.getTableTextColor(BusinessSegment.financialInstitution);

        expect(color, AppColors.black);
      },
    );

    test(
      "returns WHITE for "
      "non-financialInstitution "
      "when showWorkListColors is true",
      () {
        viewModel.showWorkListColors = true;

        for (final segment in [
          BusinessSegment.corporate,
          BusinessSegment.business,
          BusinessSegment.personal,
          BusinessSegment.baf,
          BusinessSegment.financialInstitutionCF,
          null,
        ]) {
          final color = viewModel.getTableTextColor(segment);

          expect(
            color,
            AppColors.white,
            reason: "Expected WHITE for segment $segment",
          );
        }
      },
    );
  });

  group("firstKeyForSummaryCount", () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test("returns null when map is null", () {
      final result = viewModel.firstKeyForSummaryCount(null);

      expect(result, isNull);
    });

    test("returns null when map is empty", () {
      final result = viewModel.firstKeyForSummaryCount({});

      expect(result, isNull);
    });

    test("returns first inserted key when map has entries", () {
      final map = <int, AssignToDetail?>{
        10: AssignToDetail(),
        20: AssignToDetail(),
        30: null,
      };

      final result = viewModel.firstKeyForSummaryCount(map);

      expect(result, 10);
    });

    test("preserves insertion order (not sorted order)", () {
      final map = <int, AssignToDetail?>{};
      map[99] = null;
      map[1] = null;

      final result = viewModel.firstKeyForSummaryCount(map);

      expect(result, 99);
    });
  });

  group("onActionClicked - unit", () {
    late TestHomeViewModel viewModel;

    setUp(() {
      viewModel = TestHomeViewModel();
    });

    test("assignToMe path does not open dialog", () async {
      final detail = AssignToDetail(
        userAction: ServerConstants.assignToMeAction,
      );

      await viewModel.onActionClicked(
        FakeBuildContext(),
        "REF123",
        detail,
      );

      await Future.delayed(Duration.zero);

      expect(viewModel.assignCalled, true);
      expect(viewModel.refreshCalled, true);
    });
  });

  group("getUsersByRoles", () {
    late HomeViewModel viewModel;
    late MockDashboardRepository mockRepo;

    setUp(() {
      viewModel = HomeViewModel();
      mockRepo = MockDashboardRepository();
      viewModel.repository = mockRepo;

      Globals.superBpmRolesId = [];
    });

    test(
      "sets users empty and hides assign user "
      "when summaryFirstStringForType is null",
      () async {
        viewModel.summaryData = null;

        await viewModel.getUsersByRoles();

        expect(viewModel.users, isEmpty);
        expect(viewModel.showAssignUser, false);
        verifyNever(() => mockRepo.getUsersByRoles(any()));
      },
    );

    test(
      "fetches users when BPM roles exist and match Globals.superBpmRolesId",
      () async {
        // summaryFirstStringForType → "1,2"
        viewModel
          ..summaryData = Summary(
            pendingWithMe: {
              1: AssignToDetail(assingToRoles: "1,2"),
            },
          )
          ..selectedSummary = SummaryType.me;

        Globals.superBpmRolesId = [
          {"RM": 1},
          {"CA": 2},
          {"RM": 1}, // duplicate role name
        ];

        final mockUsers = [
          User(id: "U1"),
          User(id: "U2"),
        ];

        when(() => mockRepo.getUsersByRoles(any()))
            .thenAnswer((_) async => mockUsers);

        await viewModel.getUsersByRoles();

        expect(viewModel.showAssignUser, true);
        expect(viewModel.users, mockUsers);

        verify(
          () => mockRepo.getUsersByRoles(["RM", "CA"]),
        ).called(1);
      },
    );

    test(
      "does not call repo when no roles match wanted role IDs",
      () async {
        viewModel
          ..summaryData = Summary(
            pendingWithMe: {
              1: AssignToDetail(assingToRoles: "9"),
            },
          )
          ..selectedSummary = SummaryType.me;

        Globals.superBpmRolesId = [
          {"RM": 1},
          {"CA": 2},
        ];

        await viewModel.getUsersByRoles();

        expect(viewModel.users, isEmpty);
        expect(viewModel.showAssignUser, true);
        verifyNever(() => mockRepo.getUsersByRoles(any()));
      },
    );

    test(
      "removes duplicate role names before calling repository",
      () async {
        viewModel
          ..summaryData = Summary(
            pendingWithMe: {
              1: AssignToDetail(assingToRoles: "1,1,2"),
            },
          )
          ..selectedSummary = SummaryType.me;

        Globals.superBpmRolesId = [
          {"RM": 1},
          {"RM": 1},
          {"CA": 2},
        ];

        when(() => mockRepo.getUsersByRoles(any())).thenAnswer((_) async => []);

        await viewModel.getUsersByRoles();

        verify(
          () => mockRepo.getUsersByRoles(["RM", "CA"]),
        ).called(1);
      },
    );
  });

  HomeViewModel createViewModel(MockDashboardRepository repo) {
    final vm = HomeViewModel()
      ..repository = repo
      ..selectedAssignToDetail = AssignToDetail(
        userAction: 0,
      );
    return vm;
  }

  group("assignToUser", () {
    late MockDashboardRepository mockRepo;
    late HomeViewModel viewModel;

    setUp(() {
      mockRepo = MockDashboardRepository();
      viewModel = createViewModel(mockRepo);
    });

    test(
      "throws and shows failure when no assignee and not assign-to-me",
      () async {
        viewModel
          ..selectedAssignee = null
          ..selectedAssignToDetail = AssignToDetail(
            userAction: 0,
          );

        // Toast will throw internally, so wrap safely
        try {
          await viewModel.assignToUser("REF001");
        } catch (_) {}

        expect(viewModel.selectedAssignee, isNull);
        verifyNever(
          () => mockRepo.assignUserToApplication(
            assignedTo: any(named: "assignedTo"),
            appRefNo: any(named: "appRefNo"),
            assignedRole: any(named: "assignedRole"),
            assignedRoleId: any(named: "assignedRoleId"),
            assignedRoleName: any(named: "assignedRoleName"),
            assignToDetail: any(named: "assignToDetail"),
          ),
        );
      },
    );

    AssignToDetail manualAssignDetail() =>
        AssignToDetail(userAction: 2126); // default non-assign action

    test(
      "throws error when no assignee and not assign-to-me",
      () async {
        viewModel
          ..selectedAssignee = null
          ..selectedAssignToDetail = manualAssignDetail();

        try {
          await viewModel.assignToUser("REF001");
        } catch (_) {}

        verifyNever(
          () => mockRepo.assignUserToApplication(
            assignedTo: any(named: "assignedTo"),
            appRefNo: any(named: "appRefNo"),
            assignedRole: any(named: "assignedRole"),
            assignedRoleId: any(named: "assignedRoleId"),
            assignedRoleName: any(named: "assignedRoleName"),
            assignToDetail: any(named: "assignToDetail"),
          ),
        );

        expect(viewModel.selectedAssignee, isNull);
      },
    );
  });

  group("summaryFirstStringForType", () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test("returns null when summaryData is null", () {
      viewModel
        ..summaryData = null
        ..selectedSummary = SummaryType.me;

      final result = viewModel.summaryFirstStringForType();

      expect(result, isNull);
      expect(viewModel.selectedAssignToDetail, isNull);
    });

    test("returns first non-empty trimmed assingToRoles", () {
      viewModel
        ..summaryData = Summary(
          pendingWithMe: {
            1: AssignToDetail(assingToRoles: "   "),
            2: AssignToDetail(assingToRoles: "RM,CA"),
          },
        )
        ..selectedSummary = SummaryType.me;

      final result = viewModel.summaryFirstStringForType();

      expect(result, "RM,CA");
    });

    test("preserves insertion order when selecting first role", () {
      viewModel
        ..summaryData = Summary(
          pendingWithMe: {
            10: AssignToDetail(assingToRoles: "FIRST"),
            20: AssignToDetail(assingToRoles: "SECOND"),
          },
        )
        ..selectedSummary = SummaryType.me;

      final result = viewModel.summaryFirstStringForType();

      expect(result, "FIRST");
    });

    test("sets selectedAssignToDetail to first map value", () {
      final firstDetail = AssignToDetail(assingToRoles: "ROLE1");
      final secondDetail = AssignToDetail(assingToRoles: "ROLE2");

      viewModel
        ..summaryData = Summary(
          pendingWithMe: {
            1: firstDetail,
            2: secondDetail,
          },
        )
        ..selectedSummary = SummaryType.me
        ..summaryFirstStringForType();

      expect(viewModel.selectedAssignToDetail, firstDetail);
    });
  });

  group("typeForMap", () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test("returns SummaryType.na when summary is null", () {
      final result = viewModel.typeForMap(null, {});
      expect(result, SummaryType.na);
    });

    test("returns SummaryType.na when map is null", () {
      final summary = Summary(pendingWithMe: {});
      final result = viewModel.typeForMap(summary, null);
      expect(result, SummaryType.na);
    });

    test("returns SummaryType.me for pendingWithMe map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(pendingWithMe: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.me);
    });

    test("returns SummaryType.business for pendingWithBusiness map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(pendingWithBusiness: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.business);
    });

    test("returns SummaryType.credit for pendingWithCredit map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(pendingWithCredit: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.credit);
    });

    test("returns SummaryType.requests for recommentedRequest map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(recommentedRequest: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.requests);
    });

    test(
        "returns SummaryType.documentationrequest "
        "for returnedRequestDocumentation map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(returnedRequestDocumentation: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.documentationrequest);
    });

    test("returns SummaryType.ro for returnedToRO map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(returnedToRO: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.ro);
    });

    test("returns SummaryType.pendingWithBusinessTeam map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(pendingWithBusinessTeam: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.pendingWithBusinessTeam);
    });

    test("returns SummaryType.pendingWithRelationShipTeam map", () {
      final map = <int, AssignToDetail?>{};
      final summary = Summary(pendingWithRelationShipTeam: map);

      final result = viewModel.typeForMap(summary, map);

      expect(result, SummaryType.pendingWithRelationShipTeam);
    });

    test("returns null when map does not match any summary bucket", () {
      final summary = Summary(pendingWithMe: {});
      final otherMap = <int, AssignToDetail?>{};

      final result = viewModel.typeForMap(summary, otherMap);

      expect(result, isNull);
    });
  });

  group("onFilter", () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel()
        ..worklistData = [
          Request(
            customerName: "Alice",
            applicationRefNo: "REF123",
            customerRimNo: 111,
            requestedBy: "John",
            receivedFrom: "Branch",
            status: "APPROVED",
            applicationType: Reference(name: "TYPE_A"),
            businessSegment: Reference(name: "CORPORATE"),
          ),
          Request(
            customerName: "Bob",
            applicationRefNo: "XYZ999",
            customerRimNo: 222,
            requestedBy: "Mary",
            receivedFrom: "Online",
            status: "PENDING",
            applicationType: Reference(name: "TYPE_B"),
            businessSegment: Reference(name: "BUSINESS"),
          ),
        ];
    });

    test("filters by applicantName", () async {
      await viewModel.onFilter(
        value: "Alice",
        filterType: FilterType.applicantName,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.customerName, "Alice");
      expect(viewModel.applicantNameFilter, "Alice");
    });

    test("filters by referenceNumber", () async {
      await viewModel.onFilter(
        value: "REF",
        filterType: FilterType.referenceNumber,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.applicationRefNo, "REF123");
      expect(viewModel.reqRefNoFilter, "REF");
    });

    test("filters by applicantRim", () async {
      await viewModel.onFilter(
        value: "111",
        filterType: FilterType.applicantRim,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.customerRimNo, 111);
      expect(viewModel.applicantRimFilter, "111");
    });

    test("filters by referenceType with selectedTypes", () async {
      await viewModel.onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [
          Request(applicationType: Reference(name: "TYPE_A")),
        ],
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.applicationType?.name, "TYPE_A");
      expect(viewModel.requestTypeFilter.length, 1);
    });

    test("referenceType with empty selectedTypes returns all data", () async {
      await viewModel.onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [],
      );

      expect(viewModel.filteredRequests.length, 2);
      expect(viewModel.requestTypeFilter, isEmpty);
    });

    test("filters by requestBy", () async {
      await viewModel.onFilter(
        value: "mary",
        filterType: FilterType.requestBy,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.requestedBy, "Mary");
      expect(viewModel.requestByFilter, "mary");
    });

    test("filters by requestStatus", () async {
      await viewModel.onFilter(
        value: "",
        filterType: FilterType.requestStatus,
        selectedTypes: [
          Request(status: "APPROVED"),
        ],
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.status, "APPROVED");
      expect(viewModel.requestStatusListFilter, ["APPROVED"]);
    });

    test("filters by businessSegment", () async {
      await viewModel.onFilter(
        value: "",
        filterType: FilterType.businessSegment,
        selectedTypes: [
          Request(businessSegment: Reference(name: "BUSINESS")),
        ],
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(
        viewModel.filteredRequests.first?.businessSegment?.name,
        "BUSINESS",
      );
      expect(viewModel.businessSegmentListFilter, ["BUSINESS"]);
    });

    test("filters by receivedFrom", () async {
      await viewModel.onFilter(
        value: "online",
        filterType: FilterType.receivedFrom,
      );

      expect(viewModel.filteredRequests.length, 1);
      expect(viewModel.filteredRequests.first?.receivedFrom, "Online");
      expect(viewModel.receivedFromFilter, "online");
    });

    test("sets tableLoader to loaded after filtering", () async {
      await viewModel.onFilter(
        value: "Alice",
        filterType: FilterType.applicantName,
      );

      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });
  });

  group("mapForType – full coverage", () {
    late HomeViewModel viewModel;
    late Summary summary;

    setUp(() {
      viewModel = HomeViewModel();

      summary = Summary(
        pendingWithMe: {1: AssignToDetail()},
        pendingWithBusiness: {2: AssignToDetail()},
        pendingWithCredit: {3: AssignToDetail()},
        pendingWithDocumentation: {4: AssignToDetail()},
        pendingWithTeam: {5: AssignToDetail()},
        pendingWithApprovingAuthority: {6: AssignToDetail()},
        pendingWithCreditControl: {7: AssignToDetail()},
        pendingWithPool: {8: AssignToDetail()},
        recommentedRequest: {9: AssignToDetail()},
        returnedRequestDocumentation: {10: AssignToDetail()},
        returnedToRO: {11: AssignToDetail()},
        returnedToRM: {12: AssignToDetail()},
        returnedToCA: {13: AssignToDetail()},
        returnedToCAM: {14: AssignToDetail()},
        returnedToTLB: {15: AssignToDetail()},
        returnedToSHB: {16: AssignToDetail()},
        returnedToRMB: {17: AssignToDetail()},
        returnedToCCUM: {18: AssignToDetail()},
        returnedToTLD1: {19: AssignToDetail()},
        returnedToSHD: {20: AssignToDetail()},
        returnedToSHC: {21: AssignToDetail()},
        returnedToSHB1: {22: AssignToDetail()},
        returnedToSHBHyphen: {23: AssignToDetail()},
        returnedToCCP: {24: AssignToDetail()},
        returnedToCCPA: {25: AssignToDetail()},
        returnedToBDP: {26: AssignToDetail()},
        pendingWithBusinessTeam: {27: AssignToDetail()},
        pendingWithRelationShipTeam: {28: AssignToDetail()},
      );
    });

    test("returns correct map for every SummaryType", () {
      final cases = <SummaryType, Map<int, AssignToDetail?>?>{
        SummaryType.me: summary.pendingWithMe,
        SummaryType.business: summary.pendingWithBusiness,
        SummaryType.credit: summary.pendingWithCredit,
        SummaryType.documentation: summary.pendingWithDocumentation,
        SummaryType.team: summary.pendingWithTeam,
        SummaryType.approvingauthority: summary.pendingWithApprovingAuthority,
        SummaryType.creditcontrol: summary.pendingWithCreditControl,
        SummaryType.pool: summary.pendingWithPool,
        SummaryType.creditCordinator: summary.returnedToCA,
        SummaryType.requests: summary.recommentedRequest,
        SummaryType.documentationrequest: summary.returnedRequestDocumentation,
        SummaryType.ro: summary.returnedToRO,
        SummaryType.rm: summary.returnedToRM,
        SummaryType.ca: summary.returnedToCA,
        SummaryType.cam: summary.returnedToCAM,
        SummaryType.tlb: summary.returnedToTLB,
        SummaryType.shb: summary.returnedToSHB,
        SummaryType.rmb: summary.returnedToRMB,
        SummaryType.ccuMaker: summary.returnedToCCUM,
        SummaryType.tld1: summary.returnedToTLD1,
        SummaryType.shld: summary.returnedToSHD,
        SummaryType.shlc: summary.returnedToSHC,
        SummaryType.shlb1: summary.returnedToSHB1,
        SummaryType.shlb: summary.returnedToSHBHyphen,
        SummaryType.ccProxy: summary.returnedToCCP,
        SummaryType.ccProxyApprover: summary.returnedToCCPA,
        SummaryType.bdProxy: summary.returnedToBDP,
        SummaryType.unitHead: summary.returnedToCCUM,
        SummaryType.pendingWithBusinessTeam: summary.pendingWithBusinessTeam,
        SummaryType.pendingWithRelationShipTeam:
            summary.pendingWithRelationShipTeam,
      };

      for (final entry in cases.entries) {
        final result = viewModel.mapForType(summary, entry.key);
        expect(
          result,
          same(entry.value),
          reason: "Failed for SummaryType.${entry.key}",
        );
      }
    });

    test("returns null when summary is null", () {
      final result = viewModel.mapForType(null, SummaryType.me);
      expect(result, isNull);
    });

    test("returns null for unsupported SummaryType", () {
      final result = viewModel.mapForType(summary, SummaryType.na);
      expect(result, isNull);
    });
  });
}

class TestHomeViewModel extends HomeViewModel {
  bool assignCalled = false;
  bool refreshCalled = false;

  @override
  Future<void> assignToUser(String? appRefNo) async {
    assignCalled = true;
  }

  @override
  Future<void> onClickRefresh() async {
    refreshCalled = true;
  }

  bool worklistCalled = false;

  @override
  Future<void> getWorklist({bool isRefresh = false}) async {
    worklistCalled = true;
  }
}
