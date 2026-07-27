import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

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

void main() {
  late RelationshipUtilizationViewModel viewModel;
  late MockProfitabilityRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    registerFallbackValue(<RelationshipUtilization>[]);
    registerFallbackValue(RelationshipUtilization());
    registerFallbackValue("");
    registerFallbackValue(false);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>[ConnectivityResult.wifi.name];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async {
        return "wifi";
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      null,
    );
  });

  setUp(() {
    mockRepository = MockProfitabilityRepository();
    mockAlertManager = MockAlertManager();
    mockLocalStorageService = MockLocalStorageService();

    ProfitabilityRepository.overrideInstance = mockRepository;
    AlertManager.overrideInstance = mockAlertManager;
    AlertManager.instance = mockAlertManager;
    LocalStorageService().getStorage = mockLocalStorageService;

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    Globals.request = Request(applicationRefNo: "APP123");
    Globals.user = User(
      id: "user1",
      currentRole: Role(roleId: 55),
    );

    viewModel = RelationshipUtilizationViewModel()..repository = mockRepository;
  });

  tearDown(() async {
    Globals.request = null;
    Globals.user = null;
    Globals.onAutoSave = null;

    try {
      await viewModel.close();
    } on Object {
      // Safe cleanup for DraftMixin/global dependencies in unit tests.
    }
  });

  group("RelationshipUtilizationViewModel - constructor and getters", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.relationshipUtilizationData, isEmpty);
      expect(viewModel.controllersReady, false);
      expect(viewModel.rowsPerPage, 5);
      expect(viewModel.pageMode, PageMode.na);
      expect(viewModel.canEdit, false);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    });

    test("canEdit should return true only when pageMode is edit", () {
      expect(viewModel.canEdit, false);

      viewModel.pageMode = PageMode.edit;

      expect(viewModel.canEdit, true);

      viewModel.pageMode = PageMode.na;

      expect(viewModel.canEdit, false);
    });

    test("draft getters should return non-empty values and handler", () {
      expect(viewModel.draftModuleKey, isNotEmpty);
      expect(viewModel.draftFormKey, isNotEmpty);
      expect(viewModel.draftHandler, isNotNull);
    });
  });

  group("RelationshipUtilizationState", () {
    test("constructor should set loaderStatus", () {
      final state = RelationshipUtilizationState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith should keep existing values when null", () {
      final state = RelationshipUtilizationState(
        loaderStatus: LoadingStatus.loaded,
        turnOverStatus: LoadingStatus.error,
      );

      final copied = state.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.turnOverStatus, LoadingStatus.error);
    });

    test("copyWith should override loaderStatus and turnOverStatus", () {
      final state = RelationshipUtilizationState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = state.copyWith(
        loaderStatus: LoadingStatus.error,
        turnOverStatus: LoadingStatus.loading,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(updated.turnOverStatus, LoadingStatus.loading);
    });
  });

  group("safe controller accessors", () {
    test("before initialize should return fallback empty controllers", () {
      expect(viewModel.clientCtrlAt(0).text, "");
      expect(viewModel.cbdCtrlAt(0).text, "");
      expect(viewModel.pctCtrlAt(0).text, "");

      expect(viewModel.clientCtrlAt(-1).text, "");
      expect(viewModel.cbdCtrlAt(-1).text, "");
      expect(viewModel.pctCtrlAt(-1).text, "");
    });

    test("after initialize should return actual controllers for valid indexes",
        () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "123",
            turnoverInCbdCua: "12",
            throughputToCbdPercentage: "9.76",
          ),
        ]
        ..initalize();

      expect(viewModel.controllersReady, true);
      expect(viewModel.clientCtrlAt(0).text, "123");
      expect(viewModel.cbdCtrlAt(0).text, "12");
      expect(viewModel.pctCtrlAt(0).text, "9.76");
    });

    test("after initialize should return fallback for invalid indexes", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "123",
            turnoverInCbdCua: "12",
            throughputToCbdPercentage: "9.76",
          ),
        ]
        ..initalize();

      expect(viewModel.clientCtrlAt(-1).text, "");
      expect(viewModel.clientCtrlAt(99).text, "");
      expect(viewModel.cbdCtrlAt(-1).text, "");
      expect(viewModel.cbdCtrlAt(99).text, "");
      expect(viewModel.pctCtrlAt(-1).text, "");
      expect(viewModel.pctCtrlAt(99).text, "");
    });
  });

  group("init", () {
    test("init should load data, initialize controllers, and emit loaded",
        () async {
      final data = <RelationshipUtilization>[
        RelationshipUtilization(
          clientTurnover: "100",
          turnoverInCbdCua: "25",
          throughputToCbdPercentage: "25",
        ),
      ];

      when(() => mockRepository.getRelationshipUtilizationData())
          .thenAnswer((_) async => data);

      await viewModel.init(FakeBuildContext());

      expect(viewModel.relationshipUtilizationData, data);
      expect(viewModel.controllersReady, true);
      expect(viewModel.clientCtrlAt(0).text, "100");
      expect(viewModel.cbdCtrlAt(0).text, "25");
      expect(viewModel.pctCtrlAt(0).text, "25");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(() => mockRepository.getRelationshipUtilizationData()).called(1);
    });

    test("init should use empty list when repository returns empty list",
        () async {
      when(() => mockRepository.getRelationshipUtilizationData())
          .thenAnswer((_) async => <RelationshipUtilization>[]);

      await viewModel.init(FakeBuildContext());

      expect(viewModel.relationshipUtilizationData, isEmpty);
      expect(viewModel.controllersReady, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init should propagate repository error", () async {
      when(() => mockRepository.getRelationshipUtilizationData())
          .thenThrow(Exception("Network error"));

      expect(
        () async => viewModel.init(FakeBuildContext()),
        throwsA(isA<Exception>()),
      );
    });
  });

  group("initialize controllers", () {
    test("initalize should build controllers from clean values", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            turnoverInCbdCua: "null",
            throughputToCbdPercentage: "NuLL",
          ),
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      expect(viewModel.controllersReady, true);
      expect(viewModel.clientCtrlAt(0).text, "");
      expect(viewModel.cbdCtrlAt(0).text, "");
      expect(viewModel.pctCtrlAt(0).text, "");

      expect(viewModel.clientCtrlAt(1).text, "100");
      expect(viewModel.cbdCtrlAt(1).text, "50");
      expect(viewModel.pctCtrlAt(1).text, "50");

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.turnOverStatus, LoadingStatus.loaded);
    });

    test("initalize should dispose old controllers and rebuild new controllers",
        () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "1",
            turnoverInCbdCua: "2",
            throughputToCbdPercentage: "3",
          ),
        ]
        ..initalize();

      expect(viewModel.clientCtrlAt(0).text, "1");

      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "10",
            turnoverInCbdCua: "20",
            throughputToCbdPercentage: "30",
          ),
        ]
        ..initalize();

      expect(viewModel.clientCtrlAt(0).text, "10");
      expect(viewModel.cbdCtrlAt(0).text, "20");
      expect(viewModel.pctCtrlAt(0).text, "30");
    });
  });

  group("percentage recalculation", () {
    test("recalc when controllers are not ready should return safely", () {
      viewModel.recalcPercentage(0);

      expect(viewModel.state.turnOverStatus, LoadingStatus.loaded);
    });

    test("recalc with negative index should return safely", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "25",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      expect(() => viewModel.recalcPercentage(-1), returnsNormally);
    });

    test("recalc with out of range index should return safely", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "25",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      expect(() => viewModel.recalcPercentage(99), returnsNormally);
    });

    test("empty client turnover should set 0 percentage", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "1",
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "0",
      );
      expect(viewModel.state.turnOverStatus, LoadingStatus.loaded);
    });

    test("zero client turnover should set 0 percentage", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "0",
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "0";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "0");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "0",
      );
    });

    test("invalid client turnover should sanitize to empty and set 0", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "abc",
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "abc";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, "");
      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "0",
      );
    });

    test(
        "client turnover less than CBD turnover should show toast once and set 0",
        () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "10",
            turnoverInCbdCua: "20",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "10";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "10");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "0",
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      clearInteractions(mockAlertManager);

      viewModel.recalcPercentage(0);

      verifyNever(() => mockAlertManager.showFailureToast(any()));
    });

    test(
        "valid percentage calculation should update percentage and reset toast guard",
        () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "200",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "200";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "25");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "200");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "25",
      );
    });

    test("decimal percentage should strip trailing zeros", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "8",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "8";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "12.5");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "12.5",
      );
    });

    test("invalid CBD turnover should be treated as zero", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "invalid",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "100";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "0",
      );
    });

    test("null CBD turnover should be treated as zero", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "100";
      viewModel.recalcPercentage(0);

      expect(viewModel.pctCtrlAt(0).text, "0");
    });

    test("listener path should recalculate when controller text changes", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "25",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "200";

      expect(viewModel.pctCtrlAt(0).text, "12.5");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "200");
    });
  });

  group("sanitize and clamp behavior through recalc", () {
    test("should remove commas and spaces", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "1, 000";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, "1000");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "1000");
    });

    test("should keep only first dot and digits", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "12.34.56abc";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, "12.3456");
      expect(
        viewModel.relationshipUtilizationData[0].clientTurnover,
        "12.3456",
      );
    });

    test("should clamp to 15 integer digits and 6 decimals", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "1234567890123456.1234567";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, "123456789012345.123456");
      expect(
        viewModel.relationshipUtilizationData[0].clientTurnover,
        "123456789012345.123456",
      );
    });

    test("should preserve typing state dot and then treat as invalid", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = ".";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, ".");
      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, ".");
    });

    test("should preserve typing state trailing dot and then parse valid part",
        () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "12.";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, "12.");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "12.");
    });

    test("should preserve negative typing states", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "0",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "-";
      viewModel.recalcPercentage(0);
      expect(viewModel.clientCtrlAt(0).text, "-");
      expect(viewModel.pctCtrlAt(0).text, "0");

      viewModel.clientCtrlAt(0).text = "-.";
      viewModel.recalcPercentage(0);
      expect(viewModel.clientCtrlAt(0).text, "-.");
      expect(viewModel.pctCtrlAt(0).text, "0");

      viewModel.clientCtrlAt(0).text = "-0.";
      viewModel.recalcPercentage(0);
      expect(viewModel.clientCtrlAt(0).text, "-0.");
      expect(viewModel.pctCtrlAt(0).text, "0");
    });

    test("negative valid value should remain negative and trigger violation",
        () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "-10.50";
      viewModel.recalcPercentage(0);

      expect(viewModel.clientCtrlAt(0).text, "-10.50");
      expect(viewModel.pctCtrlAt(0).text, "0");
      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "-10.50");
    });
  });

  group("syncControllersToModel", () {
    test("should copy controller values into model", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "1",
            turnoverInCbdCua: "2",
            throughputToCbdPercentage: "3",
          ),
          RelationshipUtilization(
            clientTurnover: "4",
            turnoverInCbdCua: "5",
            throughputToCbdPercentage: "6",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "10";
      viewModel.cbdCtrlAt(0).text = "20";
      viewModel.pctCtrlAt(0).text = "30";

      viewModel.clientCtrlAt(1).text = "40";
      viewModel.cbdCtrlAt(1).text = "50";
      viewModel.pctCtrlAt(1).text = "60";

      viewModel.syncControllersToModel();

      expect(viewModel.relationshipUtilizationData[0].clientTurnover, "10");
      expect(viewModel.relationshipUtilizationData[0].turnoverInCbdCua, "20");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "30",
      );

      expect(viewModel.relationshipUtilizationData[1].clientTurnover, "40");
      expect(viewModel.relationshipUtilizationData[1].turnoverInCbdCua, "50");
      expect(
        viewModel.relationshipUtilizationData[1].throughputToCbdPercentage,
        "60",
      );
    });
  });

  group("saveRelationUtilData", () {
    test("success should post data and show success toast", () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepository.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");

      await viewModel.saveRelationUtilData(isValidate: true);

      verify(() => mockRepository.postRelationshipUtilizationData(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast("OK")).called(1);
      expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
    });

    test("success with ifNavigate false should not throw", () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepository.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");

      await viewModel.saveRelationUtilData(
        isValidate: false,
      );

      verify(() => mockRepository.postRelationshipUtilizationData(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast("OK")).called(1);
    });

    test("turnover violation should block save and show validation toast",
        () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "10",
            turnoverInCbdCua: "20",
            throughputToCbdPercentage: "0",
          ),
        ]
        ..initalize();

      await viewModel.saveRelationUtilData(isValidate: true);

      verifyNever(() => mockRepository.postRelationshipUtilizationData(any()));
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("turnover violation toast should be shown only once", () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "10",
            turnoverInCbdCua: "20",
            throughputToCbdPercentage: "0",
          ),
        ]
        ..initalize();

      await viewModel.saveRelationUtilData(isValidate: true);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      clearInteractions(mockAlertManager);

      await viewModel.saveRelationUtilData(isValidate: true);

      verifyNever(() => mockAlertManager.showFailureToast(any()));
      verifyNever(() => mockRepository.postRelationshipUtilizationData(any()));
    });

    test("repository error should show failure toast and emit error state",
        () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepository.postRelationshipUtilizationData(any()))
          .thenThrow(Exception("boom"));

      await viewModel.saveRelationUtilData(isValidate: true);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test(
        "invalid numeric values in turnover violation check should not block save",
        () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "invalid",
            turnoverInCbdCua: "invalid",
            throughputToCbdPercentage: "0",
          ),
        ]
        ..initalize();

      when(() => mockRepository.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");

      await viewModel.saveRelationUtilData(isValidate: true);

      verify(() => mockRepository.postRelationshipUtilizationData(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast("OK")).called(1);
    });

    test("zero client value should not block save", () async {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "0",
            turnoverInCbdCua: "100",
            throughputToCbdPercentage: "0",
          ),
        ]
        ..initalize();

      when(() => mockRepository.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");

      await viewModel.saveRelationUtilData(isValidate: true);

      verify(() => mockRepository.postRelationshipUtilizationData(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast("OK")).called(1);
    });
  });

  group("dispose and close", () {
    test("disposeControllers should be callable after initialize", () {
      viewModel
        ..relationshipUtilizationData = <RelationshipUtilization>[
          RelationshipUtilization(
            clientTurnover: "1",
            turnoverInCbdCua: "2",
            throughputToCbdPercentage: "3",
          ),
        ]
        ..initalize();

      expect(() => viewModel.disposeControllers(), returnsNormally);
    });

    test("close should be callable", () async {
      await expectLater(viewModel.close(), completes);
    });
  });

  group("clean", () {
    test("clean should convert null and string null to empty string", () {
      expect(viewModel.clean(null), "");
      expect(viewModel.clean("null"), "");
      expect(viewModel.clean("NuLL"), "");
      expect(viewModel.clean("NULL"), "");
    });

    test("clean should return value string for non-null values", () {
      expect(viewModel.clean("123"), "123");
      expect(viewModel.clean(123), "123");
      expect(viewModel.clean(12.5), "12.5");
      expect(viewModel.clean(true), "true");
    });
  });
}
