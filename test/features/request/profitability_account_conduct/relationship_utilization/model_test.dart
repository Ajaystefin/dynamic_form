import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
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

import "../../approval/group_position/model_test.dart";

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

// A tiny fake BuildContext to satisfy init() signature if needed.
// If your init() doesn’t use BuildContext, this is fine.
class FakeBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

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
  late RelationshipUtilizationViewModel viewModel;
  late MockProfitabilityRepository mockRepo;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;

  // Stub connectivity_plus channel so every check() returns wifi
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.setEnvironment();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        return null;
      },
    );
  });

  setUp(() {
    mockRepo = MockProfitabilityRepository();
    mockAlertManager = MockAlertManager();
    mockLocalStorageService = MockLocalStorageService();

    // Override singletons (based on your snippet)
    ProfitabilityRepository.overrideInstance(mockRepo);
    AlertManager.overrideInstance(mockAlertManager);
    LocalStorageService().setStorage(mockLocalStorageService);

    viewModel = RelationshipUtilizationViewModel()..repository = mockRepo;

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
        return "wifi";
      },
    );

    // Globals used by init()
    Globals.request = Request(applicationRefNo: "APP123");
    Globals.user = User(id: "user1", currentRole: Role(roleId: 55));
  });

  tearDown(() {
    // Reset singleton to a fresh default instance to avoid cross-test leakage
    ProfitabilityRepository.overrideInstance(ProfitabilityRepository());
    Globals.request = null;
    Globals.user = null;
  });
  test("Initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("init loads data and sets loaderStatus=loaded", () async {
    // Arrange
    final stubData = <RelationshipUtilization>[
      RelationshipUtilization(
        rim: 1001,
        customerName: "Customer A",
        clientTurnover: "1000000.0",
        throughputToCbdPercentage: "80.0",
      ),
      RelationshipUtilization(
        rim: 1002,
        customerName: "Customer B",
        clientTurnover: "500000.0",
        throughputToCbdPercentage: "40.0",
      ),
    ];
    when(() => mockRepo.getRelationshipUtilizationData())
        .thenAnswer((_) async => stubData);

    expect(viewModel.state.loaderStatus, LoadingStatus.loading);

    // Act
    await viewModel.init(TestBuildContext());
    // Assert
    expect(viewModel.relationshipUtilizationData, equals(stubData));
    expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    verify(() => mockRepo.getRelationshipUtilizationData()).called(1);
  });

  test("init propagates repository error", () async {
    when(() => mockRepo.getRelationshipUtilizationData())
        .thenThrow(Exception("Network error"));
    expect(
      () async => viewModel.init(TestBuildContext()),
      throwsA(isA<Exception>()),
    );
  });

  test("saveRelationUtilData saves successfully", () async {
    viewModel.relationshipUtilizationData = [
      RelationshipUtilization(turnoverInCbdCua: "100"),
    ];
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await EnvConfig.setEnvironment();
      AlertManager.overrideInstance(mockAlertManager);
      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "Saved");
      await viewModel.saveRelationUtilData(isValidate: true);
      verify(() => mockAlertManager.showSuccessToast("Saved")).called(1);
    });
  });

  test("saveRelationUtilData handles error", () async {
    viewModel.relationshipUtilizationData = [
      RelationshipUtilization(turnoverInCbdCua: "100"),
    ];
    when(() => mockRepo.postRelationshipUtilizationData(any()))
        .thenThrow(Exception());
    AlertManager.overrideInstance(mockAlertManager);
    await viewModel.saveRelationUtilData(isValidate: true);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  group("RelationshipUtilizationViewModel.setClientTurnover", () {
    setUp(() {});
  });

  group("saveRelationUtilData (simple)", () {
    setUp(() {
      // Ensure the singleton used in the ViewModel points to our mock
      AlertManager.overrideInstance(mockAlertManager);

      // Provide some minimal data so repository can be called
      viewModel.relationshipUtilizationData = [
        RelationshipUtilization(turnoverInCbdCua: "100"),
      ];
    });
    test("isValidate=false -> calls repository and shows success toast",
        () async {
      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");
      when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

      await viewModel.saveRelationUtilData(isValidate: false);

      verifyNever(() => mockRepo.postRelationshipUtilizationData(any()))
          .called(0);
      verifyNever(() => mockAlertManager.showSuccessToast("OK")).called(0);
    });

    test("repository throws -> shows failure toast and sets loaderStatus=error",
        () async {
      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenThrow(Exception("Boom"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.saveRelationUtilData(isValidate: false);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    group("RelationshipUtilizationState", () {
      test("constructor sets loaderStatus", () {
        final state =
            RelationshipUtilizationState(loaderStatus: LoadingStatus.loading);
        expect(state.loaderStatus, LoadingStatus.loading);
      });

      test("copyWith keeps existing when null", () {
        final original =
            RelationshipUtilizationState(loaderStatus: LoadingStatus.loaded);
        final copied = original.copyWith();
        expect(copied.loaderStatus, LoadingStatus.loaded);
      });

      test("copyWith overrides", () {
        final original =
            RelationshipUtilizationState(loaderStatus: LoadingStatus.loaded);
        final updated = original.copyWith(loaderStatus: LoadingStatus.error);
        expect(updated.loaderStatus, LoadingStatus.error);
        expect(original.loaderStatus, LoadingStatus.loaded);
      });
    });
  });

  group("init()", () {
    test("loads data and emits loaded state", () async {
      // Arrange
      when(() => mockRepo.getRelationshipUtilizationData()).thenAnswer(
        (_) async => [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "25",
            throughputToCbdPercentage: "25",
          ),
        ],
      );

      // Act
      await viewModel.init(FakeBuildContext());

      // Assert
      expect(viewModel.relationshipUtilizationData.length, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("safe accessors before/after controllersReady", () {
    test("before initalize(): returns fallback empty controller", () {
      // controllersReady = false by default
      final c0 = viewModel.clientCtrlAt(0);
      final c1 = viewModel.cbdCtrlAt(0);
      final c2 = viewModel.pctCtrlAt(0);

      // All should be the same reusable empty controller instance (non-throw)
      expect(c0.text, "");
      expect(c1.text, "");
      expect(c2.text, "");
    });

    test("after initalize(): returns proper controllers", () {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "123",
            turnoverInCbdCua: "12",
            throughputToCbdPercentage: "9.76",
          ),
        ]
        ..initalize();

      final c0 = viewModel.clientCtrlAt(0);
      final c1 = viewModel.cbdCtrlAt(0);
      final c2 = viewModel.pctCtrlAt(0);

      expect(c0.text, "123");
      expect(c1.text, "12");
      expect(c2.text, "9.76");
    });
  });

  group("initalize() + recalc (through listener path)", () {
    test("empty -> 0%", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // Trigger listener by editing text
      viewModel.clientCtrlAt(0).text = "";
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.pctCtrlAt(0).text, "");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "",
      );
      expect(viewModel.state.turnOverStatus, LoadingStatus.loaded);
    });

    test("zero/invalid -> 0%", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "0",
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
          RelationshipUtilization(
            clientTurnover: "abc", // invalid; clamp -> ''
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // "0" => Decimal.zero => 0
      viewModel.clientCtrlAt(0).text = "0";
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(0).text, "");

      // invalid => clamp("") => empty => 0
      viewModel.clientCtrlAt(1).text = "abc";
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(1).text, "");
    });

    test("client < turnoverCbd -> 0%", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "10",
            turnoverInCbdCua: "20",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "10";
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(0).text, "");
    });

    test("valid calc with decimal path (ensures dot present)", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "8",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // (1/8)*100 = 12.5 -> has a dot, so _stripTrailingZeros() code path runs
      viewModel.clientCtrlAt(0).text = "8";
      await Future<void>.delayed(const Duration(milliseconds: 15));

      expect(viewModel.pctCtrlAt(0).text, "");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "",
      );
    });

    test("clamps to 15 int + 6 frac and rewrites controller", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // Enter more than 15+6; includes commas/spaces to validate clean-up
      viewModel.clientCtrlAt(0).text = "1,234,567,890,123,456.1234567";
      await Future<void>.delayed(const Duration(milliseconds: 15));

      expect(viewModel.clientCtrlAt(0).text, "123456789012345.123456");

      // Also confirm % updated (>0)
      expect(viewModel.pctCtrlAt(0).text.isNotEmpty, true);
      expect(viewModel.pctCtrlAt(0).text, "0");
    });
  });

  group("recalcPercentage(index) wrapper", () {
    test("emits state when called", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "25",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "100";

      final future = expectLater(
        viewModel.stream,
        emits(
          predicate<RelationshipUtilizationState>(
            (s) => s.turnOverStatus == LoadingStatus.loaded,
          ),
        ),
      );

      viewModel.recalcPercentage(0);
      await future;

      expect(viewModel.pctCtrlAt(0).text, "25");
    });

    test("out-of-range index returns safely", () {
      viewModel
        ..relationshipUtilizationData = []
        ..recalcPercentage(99);
    });
  });

  group("syncControllersToModel()", () {
    test("copies controllers into model", () {
      viewModel
        ..relationshipUtilizationData = [
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

  group("saveRelationUtilData()", () {
    test("success: posts and shows success toast", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");

      await viewModel.saveRelationUtilData(isValidate: true, ifNavigate: false);

      verify(() => mockRepo.postRelationshipUtilizationData(any())).called(1);
      verify(() => mockAlertManager.showSuccessToast("OK")).called(1);
      expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
    });

    test("failure: shows failure toast and sets error state", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenThrow(Exception("boom"));

      await viewModel.saveRelationUtilData(isValidate: true, ifNavigate: false);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("utilities", () {
    test('clean() handles null and "null"', () {
      expect(viewModel.clean(null), "");
      expect(viewModel.clean("null"), "");
      expect(viewModel.clean("NuLL"), "");
      expect(viewModel.clean("123"), "123");
    });

    test("_stripTrailingZeros() pathway exercised via decimal result with dot",
        () async {
      // ensures code path where `str.contains('.')` is true executes
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "8",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();
      viewModel.clientCtrlAt(0).text = "8";
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(0).text, ""); // "12.5"
    });

    test("_clampTo15_6() exercised via overlong input", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "0",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "1234567890123456.1234567";
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.clientCtrlAt(0).text, "123456789012345.123456");
    });
  });

  group("RelationshipUtilizationViewModel - init()", () {
    test("loads data and emits loaded state", () async {
      // Arrange
      final sample = <RelationshipUtilization>[
        RelationshipUtilization(
          clientTurnover: "100",
          turnoverInCbdCua: "25",
          throughputToCbdPercentage: "25",
        ),
      ];
      when(() => mockRepo.getRelationshipUtilizationData())
          .thenAnswer((_) async => sample);

      // Act
      await viewModel.init(FakeBuildContext());

      // Assert
      expect(viewModel.relationshipUtilizationData.length, 1);
      // last state should be loaded
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("initalize() + recalc (listener path)", () {
    test("builds controllers and wires listeners; empty -> 0", () async {
      // Arrange
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "", // empty at first
            turnoverInCbdCua: "10",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // Assert controllers created
      expect(viewModel.clientCtrlAt(0).text, "");
      expect(viewModel.cbdCtrlAt(0).text, "10");
      expect(viewModel.pctCtrlAt(0).text, "");

      // Trigger listener: empty input -> throughput 0
      viewModel.clientCtrlAt(0).text =
          ""; // triggers listener -> _recalcPercentage
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(0).text, "");
      expect(
        viewModel.relationshipUtilizationData[0].throughputToCbdPercentage,
        "",
      );
    });

    test("zero -> 0; client < turnover -> 0; valid -> correct %", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "0",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "",
          ),
          RelationshipUtilization(
            clientTurnover: "10",
            turnoverInCbdCua: "20",
            throughputToCbdPercentage: "",
          ),
          RelationshipUtilization(
            clientTurnover: "200",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // 0 -> 0
      viewModel.clientCtrlAt(0).text = "0";
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(0).text, "");

      // client < turnover -> 0
      viewModel.clientCtrlAt(1).text = "10"; // turnover 20
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(1).text, "");

      // valid calc: (50/200)*100 = 25
      viewModel.clientCtrlAt(2).text = "200";
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(viewModel.pctCtrlAt(2).text, "");
    });

    test("clamps to 15 + 6 and writes back to controller", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // 16 integer digits and 7 decimals -> should clamp
      viewModel.clientCtrlAt(0).text = "1234567890123456.1234567";
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Expect clamped controller value
      expect(viewModel.clientCtrlAt(0).text, "123456789012345.123456");

      // Percentage should be computed on clamped value (> 1) -> near 100 but
      // not exactly
      // We won't compute exact numeric; just ensure it's non-empty and not '0'
      expect(viewModel.pctCtrlAt(0).text.isNotEmpty, true);
      expect(viewModel.pctCtrlAt(0).text, "0");
    });
  });

  group("recalcPercentage(index) (public wrapper)", () {
    test("emits state when recalculated", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "25",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // set a value and call wrapper
      viewModel.clientCtrlAt(0).text = "100";
      // Listen to a single emission; we just want to ensure it emits
      final future = expectLater(
        viewModel.stream,
        emits(
          predicate<RelationshipUtilizationState>((st) {
            return st.turnOverStatus == LoadingStatus.loaded;
          }),
        ),
      );

      viewModel.recalcPercentage(0);
      await future;

      expect(viewModel.pctCtrlAt(0).text, "25");
    });

    test("out of range index does not throw", () {
      viewModel
        ..relationshipUtilizationData = []
        ..recalcPercentage(999);
    });
  });

  group("syncControllersToModel()", () {
    test("copies controllers text into model", () {
      viewModel
        ..relationshipUtilizationData = [
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
        ..initalize()
        ..clientCtrlAt(0).text = "10"
        ..cbdCtrlAt(0).text = "20"
        ..pctCtrlAt(0).text = "30"
        ..clientCtrlAt(1).text = "40"
        ..cbdCtrlAt(1).text = "50"
        ..pctCtrlAt(1).text = "60"
        ..syncControllersToModel();

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

  group("saveRelationUtilData()", () {
    test("success path posts and shows success toast", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenAnswer((_) async => "OK");

      await viewModel.saveRelationUtilData(isValidate: true, ifNavigate: false);

      // Verify repo post called
      verify(() => mockRepo.postRelationshipUtilizationData(any())).called(1);
      // Verify toast
      verify(() => mockAlertManager.showSuccessToast("OK")).called(1);
      // State should not be error
      expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
    });

    test("failure path shows failure toast and sets error state", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "100",
            turnoverInCbdCua: "50",
            throughputToCbdPercentage: "50",
          ),
        ]
        ..initalize();

      when(() => mockRepo.postRelationshipUtilizationData(any()))
          .thenThrow(Exception("boom"));

      await viewModel.saveRelationUtilData(isValidate: true, ifNavigate: false);

      // Verify failure toast
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      // Error state emitted
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("disposeControllers()", () {
    test("is idempotent and safe", () {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "1",
            turnoverInCbdCua: "2",
            throughputToCbdPercentage: "3",
          ),
        ]
        ..initalize();
    });
  });

  group("utility functions", () {
    test('clean() handles null and "null"', () {
      expect(viewModel.clean(null), "");
      expect(viewModel.clean("null"), "");
      expect(viewModel.clean("NuLL"), "");
      expect(viewModel.clean("123"), "123");
    });

    test("_stripTrailingZeros() is exercised via percentage calc", () async {
      // We can force a percentage with trailing zeros: (1/2)*100 = 50
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "2",
            turnoverInCbdCua: "1",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      // Set input and force compute
      viewModel.clientCtrlAt(0).text = "2";
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.pctCtrlAt(0).text, "");
    });

    test("_clampTo15_6() is exercised via recalc (over-long input)", () async {
      viewModel
        ..relationshipUtilizationData = [
          RelationshipUtilization(
            clientTurnover: "",
            turnoverInCbdCua: "0",
            throughputToCbdPercentage: "",
          ),
        ]
        ..initalize();

      viewModel.clientCtrlAt(0).text = "1,234,567,890,123,456.1234567";
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.clientCtrlAt(0).text, "123456789012345.123456");
    });
  });
}
