import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockBuildContext extends Mock implements BuildContext {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockGoRouter extends Mock implements GoRouter {}

class FakeFeeStructure extends Fake implements FeeStructure {}

class FakeCustomer extends Fake implements Customer {}

class FakeRequest extends Fake implements Request {}

class FakeReference extends Fake implements Reference {}

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
}

class TestFeeStructureViewModel extends FeeStructureViewModel {
  bool deleteDraftCalled = false;
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool unregisterDraftCallbackCalled = false;

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }
}

class AlwaysEditFeeStructureViewModel extends TestFeeStructureViewModel {
  @override
  bool get isEdit => true;
}

class AlwaysViewFeeStructureViewModel extends TestFeeStructureViewModel {
  @override
  bool get isEdit => false;

  @override
  bool get isReadOnlyMode => true;
}

const MethodChannel connectivityChannel = MethodChannel(
  "dev.fluttercommunity.plus/connectivity",
);

Future<void> stubConnectivity() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    connectivityChannel,
    (MethodCall call) async {
      if (call.method == "check") {
        return <String>[ConnectivityResult.wifi.name];
      }
      return <String>[ConnectivityResult.wifi.name];
    },
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel("plugins.flutter.io/connectivity"),
    (MethodCall call) async {
      if (call.method == "check") {
        return "wifi";
      }
      return "wifi";
    },
  );
}

void stubAlerts(MockAlertManager alert) {
  when(() => alert.showFailureToast(any())).thenReturn(null);
  when(() => alert.showSuccessToast(any())).thenReturn(null);
  when(() => alert.showWarningToast(any())).thenReturn(null);
  when(() => alert.showInfoToast(any())).thenReturn(null);
}

void stubRepository(MockRequestRepository repository) {
  when(() => repository.getFeeStructureData(any())).thenAnswer(
    (_) async => <FeeStructure>[],
  );

  when(() => repository.saveFeeStructure(any())).thenAnswer(
    (_) async => "saved",
  );

  when(() => repository.deleteFeeStructureData(any())).thenAnswer(
    (_) async => "deleted",
  );
}

Request testRequest({
  int? rim = 999,
  Reference? businessSegment,
  List<Customer>? borrowers,
  List<Customer>? customers,
}) {
  return Request(
    applicationRefNo: "APP123",
    groupId: 0,
    businessSegment: businessSegment,
    borrowers: borrowers ??
        <Customer>[
          Customer(
            customerRimNo: rim,
            preferredName: "Borrower One",
            customerName: "Borrower One",
            type: CustomerType.corporate,
          ),
        ],
    customers: customers ??
        <Customer>[
          Customer(
            customerRimNo: 123,
            preferredName: "John Doe",
            customerName: "John Doe",
          ),
        ],
  );
}

GoRouter createRouter(Widget child) {
  return GoRouter(
    initialLocation: "/",
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        builder: (_, __) => child,
      ),
      GoRoute(
        path: Routes.rmCertification,
        builder: (_, __) => const Scaffold(
          body: Text("Certification"),
        ),
      ),
      for (final String path in TabConstants.remarksRoutes.values)
        GoRoute(
          path: path,
          builder: (_, __) => Scaffold(
            body: Text(path),
          ),
        ),
    ],
  );
}

Future<BuildContext> pumpContext(
  WidgetTester tester, {
  required Widget child,
}) async {
  late BuildContext context;

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: createRouter(
        Builder(
          builder: (BuildContext ctx) {
            context = ctx;
            return child;
          },
        ),
      ),
    ),
  );

  await tester.pump();
  return context;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestFeeStructureViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockBuildContext mockContext;
  late MockGoRouter mockRouter;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();
    await stubConnectivity();

    registerFallbackValue(FakeFeeStructure());
    registerFallbackValue(FakeCustomer());
    registerFallbackValue(FakeRequest());
    registerFallbackValue(FakeReference());
    registerFallbackValue(<FeeStructure>[]);
    registerFallbackValue(RemarksTabs.feeStructure);
    registerFallbackValue(0);
    registerFallbackValue("");
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      null,
    );

    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepository = MockRequestRepository();
    mockAlertManager = MockAlertManager();
    mockContext = MockBuildContext();
    mockRouter = MockGoRouter();

    RequestRepository.overrideInstance = mockRepository;
    AlertManager.overrideInstance = mockAlertManager;
    LocalStorageService().getStorage = MockLocalStorageService();

    stubAlerts(mockAlertManager);
    stubRepository(mockRepository);

    when(() => mockContext.mounted).thenReturn(false);
    when(() => mockRouter.go(any(), extra: any(named: "extra")))
        .thenReturn(null);
    when(() => mockRouter.go(any())).thenReturn(null);

    router = mockRouter;

    Globals.selectedCustomer = null;
    Globals.onAutoSave = null;
    Globals.request = testRequest();

    viewModel = TestFeeStructureViewModel()
      ..repository = mockRepository
      ..defaultFeeTypes = <String>[
        "Arrangement Fee",
        "Processing Fee",
        "Commitment Fee",
        "Pre Payment Fee",
        "Breach Of Covenant",
      ];
  });

  tearDown(() async {
    Globals.selectedCustomer = null;
    Globals.onAutoSave = null;
    Globals.request = null;

    for (final TextEditingController controller
        in viewModel.amountControllers) {
      try {
        controller.dispose();
      } on Object {
        // ignore
      }
    }

    for (final TextEditingController controller
        in viewModel.commentsControllers) {
      try {
        controller.dispose();
      } on Object {
        // ignore
      }
    }

    try {
      await viewModel.close();
    } on Object {
      // ignore
    }

    reset(mockRepository);
    reset(mockAlertManager);
    reset(mockRouter);
  });

  group("FeeStructureState", () {
    test("constructor sets loader status", () {
      final FeeStructureState state = FeeStructureState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loaded);
      expect(state.tableLoader, isA<LoadingStatus>());
    });

    test("copyWith keeps existing values", () {
      final FeeStructureState state = FeeStructureState(
        loaderStatus: LoadingStatus.loaded,
      );

      final FeeStructureState copy = state.copyWith();

      expect(copy.loaderStatus, LoadingStatus.loaded);
      expect(copy.tableLoader, LoadingStatus.loading);
    });

    test("copyWith overrides values", () {
      final FeeStructureState state = FeeStructureState(
        loaderStatus: LoadingStatus.loaded,
      );

      final FeeStructureState copy = state.copyWith(
        loaderStatus: LoadingStatus.error,
        tableLoader: LoadingStatus.loaded,
      );

      expect(copy.loaderStatus, LoadingStatus.error);
      expect(copy.tableLoader, LoadingStatus.loaded);
    });
  });

  group("constructor and simple getters", () {
    test("starts with loaded state and returns request", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.request.applicationRefNo, "APP123");
      expect(viewModel.repository, mockRepository);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.selectedCustomer, isNull);
      expect(viewModel.feeRows, isEmpty);
      expect(viewModel.amountControllers, isEmpty);
      expect(viewModel.commentsControllers, isEmpty);
      expect(viewModel.showAsteriskTabs, isEmpty);
      expect(viewModel.customerList, isEmpty);
      expect(viewModel.isFI, isFalse);
      expect(viewModel.pageMode, PageMode.na);
    });

    test("draft getters are correct", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.remarks);
      expect(viewModel.draftFormKey, Routes.feeStructure);
      expect(viewModel.draftHandler, isA<FeeStructureDraftHandler>());
    });

    test("isReadOnlyMode and isEdit reflect pageMode", () {
      viewModel.pageMode = PageMode.view;
      expect(viewModel.isReadOnlyMode, isTrue);
      expect(viewModel.isEdit, isFalse);

      viewModel.pageMode = PageMode.edit;
      expect(viewModel.isReadOnlyMode, isFalse);
      expect(viewModel.isEdit, isTrue);

      viewModel.pageMode = PageMode.na;
      expect(viewModel.isReadOnlyMode, isFalse);
      expect(viewModel.isEdit, isFalse);
    });

    test("showViewMore is true only for FI customer types", () {
      viewModel.selectedCustomer =
          Customer(type: CustomerType.investmentGradeBanks);
      expect(viewModel.showViewMore, isTrue);

      viewModel.selectedCustomer =
          Customer(type: CustomerType.belowInvestmentGradeBanks);
      expect(viewModel.showViewMore, isTrue);

      viewModel.selectedCustomer = Customer(type: CustomerType.country);
      expect(viewModel.showViewMore, isFalse);

      viewModel.selectedCustomer = Customer(type: CustomerType.corporate);
      expect(viewModel.showViewMore, isFalse);

      viewModel.selectedCustomer = null;
      expect(viewModel.showViewMore, isFalse);
    });
  });

  group("customer selection helpers", () {
    test("defaultSelectedCustomer prefers borrower when available", () {
      viewModel.defaultSelectedCustomer();

      expect(viewModel.selectedCustomer?.customerRimNo, 999);
    });

    test("defaultSelectedCustomer falls back to first customer", () {
      Globals.request = Request(
        applicationRefNo: "APP999",
        borrowers: <Customer>[],
        customers: <Customer>[
          Customer(customerRimNo: 456, preferredName: "Fallback Customer"),
        ],
      );

      viewModel.defaultSelectedCustomer();

      expect(viewModel.selectedCustomer?.customerRimNo, 456);
    });

    test("setAsterisks completes and assigns list", () async {
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      await viewModel.setAsterisks();

      expect(viewModel.showAsteriskTabs, isA<List<RemarksTabs>>());
    });

    test("getChildRimsForGroup non-group uses default customer", () async {
      Globals.request = testRequest();

      await viewModel.getChildRimsForGroup();

      expect(viewModel.selectedCustomer?.customerRimNo, 999);
    });
  });

  group("row getters", () {
    test("defaultRows inject all missing default rows and marks them not new",
        () {
      viewModel.feeRows = <FeeStructure>[];

      final List<FeeStructure> defaults = viewModel.defaultRows;

      expect(defaults.length, viewModel.defaultFeeTypes.length);
      expect(defaults.every((FeeStructure row) => !row.isNew), isTrue);
      expect(
        defaults.map((FeeStructure row) => row.feeType).toSet(),
        viewModel.defaultFeeTypes.toSet(),
      );
    });

    test("defaultRows reuses existing rows by fee type", () {
      final FeeStructure existing = FeeStructure(
        id: "existing",
        feeType: viewModel.defaultFeeTypes.first,
        isNew: true,
      );

      viewModel.feeRows = <FeeStructure>[existing];

      final List<FeeStructure> defaults = viewModel.defaultRows;

      expect(defaults.first.id, "existing");
      expect(defaults.first.isNew, isFalse);
    });

    test("extraRows returns only non-default fee rows", () {
      viewModel.feeRows = <FeeStructure>[
        FeeStructure(id: "d1", feeType: viewModel.defaultFeeTypes.first),
        FeeStructure(id: "x1", feeType: "Custom A"),
        FeeStructure(id: "x2", feeType: "Custom B"),
      ];

      final List<FeeStructure> extras = viewModel.extraRows;

      expect(extras.length, 2);
      expect(
        extras.map((FeeStructure e) => e.feeType),
        containsAll(<String>["Custom A", "Custom B"]),
      );
    });

    test("combinedRows returns defaults followed by extra rows", () {
      viewModel.feeRows = <FeeStructure>[
        FeeStructure(id: "x1", feeType: "Custom A"),
      ];

      final List<FeeStructure> combined = viewModel.combinedRows;

      expect(combined.length, viewModel.defaultFeeTypes.length + 1);
      expect(combined.last.feeType, "Custom A");
    });

    test("combinedRows returns only defaults when feeRows is empty", () {
      viewModel.feeRows = <FeeStructure>[];

      final List<FeeStructure> combined = viewModel.combinedRows;

      expect(combined.length, viewModel.defaultFeeTypes.length);
    });
  });

  group("getFeeStructureData", () {
    test(
        "populates controllers correctly for N/A, empty, integer, decimal and amount only",
        () async {
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      final FeeStructure naRow = FeeStructure(
        id: "1",
        feeType: "Custom 1",
        comments: "NA comment",
      )..amountRaw = "N/A";

      final FeeStructure emptyRow = FeeStructure(
        id: "2",
        feeType: "Custom 2",
        comments: "Empty comment",
      )..amountRaw = "";

      final FeeStructure integerRow = FeeStructure(
        id: "3",
        feeType: "Custom 3",
        amount: 12,
        comments: "Int comment",
      )..amountRaw = "12";

      final FeeStructure decimalRow = FeeStructure(
        id: "4",
        feeType: "Custom 4",
        amount: 12.5,
        comments: "Decimal comment",
      )..amountRaw = "12.5";

      final FeeStructure amountOnlyRow = FeeStructure(
        id: "5",
        feeType: "Custom 5",
        amount: 7.2,
        comments: "Amount comment",
      );

      when(() => mockRepository.getFeeStructureData(123)).thenAnswer(
        (_) async => <FeeStructure>[
          naRow,
          emptyRow,
          integerRow,
          decimalRow,
          amountOnlyRow,
        ],
      );

      await viewModel.getFeeStructureData();

      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
      expect(
        viewModel.amountControllers.length,
        viewModel.defaultFeeTypes.length + 5,
      );
      expect(
        viewModel.commentsControllers.length,
        viewModel.defaultFeeTypes.length + 5,
      );

      final int offset = viewModel.defaultFeeTypes.length;
      expect(viewModel.amountControllers[offset].text, "");
      expect(viewModel.amountControllers[offset + 1].text, "");
      expect(viewModel.amountControllers[offset + 2].text, "12");
      expect(viewModel.amountControllers[offset + 3].text, "12.5");
      expect(viewModel.amountControllers[offset + 4].text, "");
      expect(viewModel.commentsControllers[offset].text, "NA comment");
      expect(viewModel.commentsControllers[offset + 4].text, "Amount comment");
    });

    test("sets error state when repository throws", () async {
      viewModel.selectedCustomer = Customer(customerRimNo: 123);

      when(() => mockRepository.getFeeStructureData(123))
          .thenThrow(Exception("fetch failed"));

      await viewModel.getFeeStructureData();

      expect(viewModel.feeRows, isEmpty);
      expect(viewModel.state.tableLoader, LoadingStatus.error);
    });
  });

  group("onAmountFieldChanged", () {
    test("empty input clears amount/raw", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X", amount: 5);
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "");

      expect(row.amount, isNull);
      expect(row.amountRaw, isNull);
    });

    test("N/A input stores textual N/A and amount zero", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X");
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "N/A");

      expect(row.amountRaw, "N/A");
      expect(row.amount, 0);
    });

    test("lowercase n/a input stores textual N/A", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X");
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "n/a");

      expect(row.amountRaw, "N/A");
      expect(row.amount, 0);
    });

    test("valid numeric input preserves raw and parses", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X");
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "12.5");

      expect(row.amountRaw, "12.5");
      expect(row.amount, 12.5);
    });

    test("invalid numeric input keeps raw and parsed amount null", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X");
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "invalid");

      expect(row.amountRaw, "invalid");
      expect(row.amount, isNull);
    });

    test("oversized numeric input keeps raw and amount null", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X");
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "12345678901234567");

      expect(row.amountRaw, "12345678901234567");
      expect(row.amount, isNull);
    });

    test("zero input stores raw and parses zero", () {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(id: "1", feeType: "X");
      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[TextEditingController()]
        ..onAmountFieldChanged(0, "0");

      expect(row.amountRaw, "0");
      expect(row.amount, 0);
    });
  });

  group("mutations", () {
    test("addRow appends row and both controllers", () {
      viewModel
        ..defaultFeeTypes = <String>[]
        ..addRow();

      expect(viewModel.feeRows.length, 1);
      expect(viewModel.amountControllers.length, 1);
      expect(viewModel.commentsControllers.length, 1);
      expect(viewModel.feeRows.first.isNew, isTrue);
      expect(viewModel.feeRows.first.feeType, "");
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("deleteRow removes local new row and controllers only", () async {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(
        id: "1",
        feeType: "CustomType",
        isNew: true,
      );

      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(),
        ];

      await viewModel.deleteRow(row);

      expect(viewModel.feeRows, isEmpty);
      expect(viewModel.amountControllers, isEmpty);
      expect(viewModel.commentsControllers, isEmpty);
      verifyNever(() => mockRepository.deleteFeeStructureData(any()));
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("deleteRow persisted row calls repository and reloads data", () async {
      viewModel
        ..defaultFeeTypes = <String>[]
        ..selectedCustomer = Customer(customerRimNo: 123);

      final FeeStructure row = FeeStructure(
        id: "1",
        feeType: "X",
      );

      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(),
        ];

      when(() => mockRepository.deleteFeeStructureData(row))
          .thenAnswer((_) async => "deleted");
      when(() => mockRepository.getFeeStructureData(123))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.deleteRow(row);

      verify(() => mockRepository.deleteFeeStructureData(row)).called(1);
      verify(() => mockRepository.getFeeStructureData(123)).called(1);
      verify(() => mockAlertManager.showSuccessToast("deleted")).called(1);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("deleteRow failure shows error toast and error state", () async {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(
        id: "1",
        feeType: "X",
      );

      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[TextEditingController()]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(),
        ];

      when(() => mockRepository.deleteFeeStructureData(row))
          .thenThrow(Exception("fail"));

      await viewModel.deleteRow(row);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.tableLoader, LoadingStatus.error);
    });

    test("deleteRow missing row still calls delete when persisted", () async {
      viewModel.defaultFeeTypes = <String>[];
      final FeeStructure row = FeeStructure(
        id: "missing",
        feeType: "X",
      );

      when(() => mockRepository.deleteFeeStructureData(row))
          .thenAnswer((_) async => "deleted");
      when(() => mockRepository.getFeeStructureData(any()))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.deleteRow(row);

      verify(() => mockRepository.deleteFeeStructureData(row)).called(1);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });
  });

  group("save flow", () {
    test("onSavePress syncs values, defaults rows, saves and shows success",
        () async {
      viewModel
        ..defaultFeeTypes = <String>[]
        ..selectedCustomer = Customer(customerRimNo: 123);

      final FeeStructure emptyRow = FeeStructure(
        id: "1",
        feeType: "Empty",
        isNew: true,
      );
      final FeeStructure naRow = FeeStructure(
        id: "2",
        feeType: "NA",
        isNew: true,
      );
      final FeeStructure numericRow = FeeStructure(
        id: "3",
        feeType: "Numeric",
        isNew: true,
      );
      final FeeStructure hugeRow = FeeStructure(
        id: "4",
        feeType: "Huge",
        isNew: true,
      );

      viewModel
        ..feeRows = <FeeStructure>[emptyRow, naRow, numericRow, hugeRow]
        ..amountControllers = <TextEditingController>[
          TextEditingController(text: ""),
          TextEditingController(text: "N/A"),
          TextEditingController(text: "123.45"),
          TextEditingController(text: "12345678901234567"),
        ]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(text: "Comment 1"),
          TextEditingController(text: "Comment 2"),
          TextEditingController(text: "Comment 3"),
          TextEditingController(text: "Comment 4"),
        ];

      when(() => mockRepository.saveFeeStructure(any()))
          .thenAnswer((_) async => "ok");
      when(() => mockRepository.getFeeStructureData(123))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.onSavePress(mockContext, isContinue: false);

      verify(() => mockRepository.saveFeeStructure(any())).called(1);
      verify(() => mockRepository.getFeeStructureData(123)).called(1);
      verify(() => mockAlertManager.showSuccessToast("ok")).called(1);

      expect(viewModel.deleteDraftCalled, true);

      expect(emptyRow.amountRaw, isNull);
      expect(emptyRow.amount, isNull);
      expect(emptyRow.comments, "Comment 1");

      expect(naRow.amountRaw, "N/A");
      expect(naRow.amount, 0);
      expect(naRow.comments, "Comment 2");

      expect(numericRow.amountRaw, "123.45");
      expect(numericRow.amount, 123.45);
      expect(numericRow.comments, "Comment 3");

      expect(hugeRow.amountRaw, "12345678901234567");
      expect(hugeRow.amount, isNull);
      expect(hugeRow.comments, "Comment 4");

      for (final FeeStructure row in <FeeStructure>[
        emptyRow,
        naRow,
        numericRow,
        hugeRow,
      ]) {
        expect(row.appRefNo, "APP123");
        expect(row.rimNo, 123);
      }

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSavePress restores cached controllers after reload", () async {
      viewModel
        ..defaultFeeTypes = <String>[]
        ..selectedCustomer = Customer(customerRimNo: 123);

      final FeeStructure row = FeeStructure(
        id: "1",
        feeType: "X",
        isNew: true,
      );

      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[
          TextEditingController(text: "10"),
        ]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(text: "Cached"),
        ];

      when(() => mockRepository.saveFeeStructure(any()))
          .thenAnswer((_) async => "ok");

      // Important: return one row after reload, otherwise controllers become empty.
      when(() => mockRepository.getFeeStructureData(123)).thenAnswer(
        (_) async => <FeeStructure>[
          FeeStructure(
            id: "1",
            feeType: "X",
          ),
        ],
      );

      await viewModel.onSavePress(mockContext, isContinue: false);

      expect(viewModel.amountControllers, isNotEmpty);
      expect(viewModel.commentsControllers, isNotEmpty);
      expect(viewModel.amountControllers.first.text, "10");
      expect(viewModel.commentsControllers.first.text, "Cached");
    });

    test("onSavePress handles save error gracefully", () async {
      viewModel
        ..defaultFeeTypes = <String>[]
        ..selectedCustomer = Customer(customerRimNo: 123);

      final FeeStructure row = FeeStructure(
        id: "1",
        feeType: "X",
        isNew: true,
      );

      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[
          TextEditingController(text: "N/A"),
        ]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(text: "Comment"),
        ];

      when(() => mockRepository.saveFeeStructure(any()))
          .thenThrow(Exception("Save failed"));

      await viewModel.onSavePress(mockContext, isContinue: false);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.deleteDraftCalled, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSavePress continue does not navigate when context unmounted",
        () async {
      viewModel
        ..defaultFeeTypes = <String>[]
        ..selectedCustomer = Customer(customerRimNo: 123);

      final FeeStructure row = FeeStructure(
        id: "1",
        feeType: "X",
        isNew: true,
      );

      viewModel
        ..feeRows = <FeeStructure>[row]
        ..amountControllers = <TextEditingController>[
          TextEditingController(text: "1"),
        ]
        ..commentsControllers = <TextEditingController>[
          TextEditingController(text: ""),
        ];

      when(() => mockContext.mounted).thenReturn(false);
      when(() => mockRepository.saveFeeStructure(any()))
          .thenAnswer((_) async => "ok");
      when(() => mockRepository.getFeeStructureData(123))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.onSavePress(mockContext, isContinue: true);

      verifyNever(
        () => mockRouter.go(
          any(),
          extra: any(named: "extra"),
        ),
      );
    });
  });

  group("navigation", () {
    test("changeTab navigates using global router", () async {
      const RemarksTabs tab = RemarksTabs.feeStructure;

      await viewModel.changeTab(tab);

      verify(
        () => mockRouter.go(
          TabConstants.remarksRoutes[tab]!,
          extra: tab,
        ),
      ).called(1);
    });

    testWidgets(
        "navigateAfterFeeStructure with null customer goes certification",
        (WidgetTester tester) async {
      final BuildContext context = await pumpContext(
        tester,
        child: const Scaffold(body: Text("Start")),
      );

      viewModel.selectedCustomer = null;

      await viewModel.navigateAfterFeeStructure(context);
      await tester.pumpAndSettle();

      expect(find.text("Certification"), findsOneWidget);
    });

    testWidgets("navigateAfterFeeStructure corporate follows visible tab rules",
        (WidgetTester tester) async {
      final BuildContext context = await pumpContext(
        tester,
        child: const Scaffold(body: Text("Start")),
      );

      viewModel.selectedCustomer = Customer(type: CustomerType.corporate);

      final Map<RemarksTabs, bool Function()> visibilityRules =
          TabConstants.getRemarksRoutes(viewModel.selectedCustomer!);

      final List<RemarksTabs> orderedVisibleTabs =
          TabConstants.remarksRoutes.entries
              .where((MapEntry<RemarksTabs, String> routeEntry) {
                final bool Function()? isTabVisible =
                    visibilityRules[routeEntry.key];
                return isTabVisible == null || isTabVisible();
              })
              .map((MapEntry<RemarksTabs, String> routeEntry) => routeEntry.key)
              .toList();

      final int feeIndex = orderedVisibleTabs.indexOf(RemarksTabs.feeStructure);

      await viewModel.navigateAfterFeeStructure(context);
      await tester.pumpAndSettle();

      if (feeIndex == -1 || feeIndex == orderedVisibleTabs.length - 1) {
        expect(find.text("Certification"), findsOneWidget);
      } else {
        final RemarksTabs nextTab = orderedVisibleTabs[feeIndex + 1];

        verify(
          () => mockRouter.go(
            TabConstants.remarksRoutes[nextTab]!,
            extra: nextTab,
          ),
        ).called(1);
      }
    });
  });

  group("other flows", () {
    test("init fetches fee data and ends in loaded state", () async {
      when(() => mockRepository.getFeeStructureData(any()))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.init(mockContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
      expect(viewModel.selectedCustomer, isNotNull);
    });

    test("init calls draft methods when edit mode", () async {
      final AlwaysEditFeeStructureViewModel local =
          AlwaysEditFeeStructureViewModel()
            ..repository = mockRepository
            ..defaultFeeTypes = <String>[
              "Arrangement Fee",
            ];

      when(() => mockRepository.getFeeStructureData(any()))
          .thenAnswer((_) async => <FeeStructure>[]);

      await local.init(mockContext);

      expect(local.registerDraftCallbackCalled, isTrue);
      expect(local.loadDraftIfAvailableCalled, isTrue);
    });

    test("onCustomerChanged updates selected customer and reloads data",
        () async {
      final Customer customer = Customer(
        customerRimNo: 456,
        preferredName: "Jane",
      );

      when(() => mockRepository.getFeeStructureData(456))
          .thenAnswer((_) async => <FeeStructure>[]);

      await viewModel.onCustomerChanged(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(Globals.selectedCustomer, customer);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("onCustomerChanged loads draft when edit mode", () async {
      final AlwaysEditFeeStructureViewModel local =
          AlwaysEditFeeStructureViewModel()
            ..repository = mockRepository
            ..defaultFeeTypes = <String>[
              "Arrangement Fee",
            ];

      final Customer customer = Customer(customerRimNo: 456);

      when(() => mockRepository.getFeeStructureData(456))
          .thenAnswer((_) async => <FeeStructure>[]);

      await local.onCustomerChanged(customer);

      expect(local.loadDraftIfAvailableCalled, isTrue);
    });

    test("onCustomerChanged does not load draft when not edit mode", () async {
      final AlwaysViewFeeStructureViewModel local =
          AlwaysViewFeeStructureViewModel()
            ..repository = mockRepository
            ..defaultFeeTypes = <String>[
              "Arrangement Fee",
            ];

      final Customer customer = Customer(customerRimNo: 456);

      when(() => mockRepository.getFeeStructureData(456))
          .thenAnswer((_) async => <FeeStructure>[]);

      await local.onCustomerChanged(customer);

      expect(local.loadDraftIfAvailableCalled, isFalse);
    });

    test("setAsterisks produces list", () async {
      viewModel.selectedCustomer = Customer(
        type: CustomerType.investmentGradeBanks,
      );

      await viewModel.setAsterisks();

      expect(viewModel.showAsteriskTabs, isA<List<RemarksTabs>>());
    });

    test("close unregisters draft callback", () async {
      await viewModel.close();

      expect(viewModel.unregisterDraftCallbackCalled, isTrue);
    });
  });
}
