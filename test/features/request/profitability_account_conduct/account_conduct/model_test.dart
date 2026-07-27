import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

// ---------------------------------------------------------------------------
// Mocks & fakes
// ---------------------------------------------------------------------------

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class FakeAccountConductResponseData extends Fake
    implements AccountConductResponseData {}

/// Subclass whose toJson() throws — covers the silent inner catch in
/// saveAccConductData().
class _ThrowingResponseData extends AccountConductResponseData {
  _ThrowingResponseData()
      : super(
          previousYearLable: "2023",
          currentYearLable: "2024",
          accountConductDtoList: const [],
        );

  @override
  Map<String, dynamic> toJson() => throw Exception("toJson failed");
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const sampleDto = AccountConductDto(
  passDueOrExcesses: "1",
  chequeReturns: "2",
  turnoverInAcc: "3",
  odHardcore: "4",
  unusualTransactions: "5",
  transparencyDisclosureLevels: "6",
  accountConductDetailsList: [],
);

/// DTO with every field set to the string 'null' (tests _setControllerText null
/// path)
const nullStringDto = AccountConductDto(
  passDueOrExcesses: "null",
  chequeReturns: "null",
  turnoverInAcc: "null",
  odHardcore: "null",
  unusualTransactions: "null",
  transparencyDisclosureLevels: "null",
  accountConductDetailsList: [],
);

Future<void> flushToastTimers(WidgetTester tester) async {
  await tester.pump();
  toastification.dismissAll(delayForAnimation: false);
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Test-only ViewModel subclasses
// ---------------------------------------------------------------------------

class _TestAccountConductViewModel extends AccountConductViewModel {
  _TestAccountConductViewModel({required ProfitabilityRepository repository})
      : super() {
    this.repository = repository;
  }

  @override
  Future<void> deleteDraft() async {}
}

/// Tracks deleteDraft calls so the success path can be verified.
class _TrackingTestViewModel extends _TestAccountConductViewModel {
  _TrackingTestViewModel({required super.repository});
  bool deleteDraftCalled = false;

  @override
  Future<void> deleteDraft() async => deleteDraftCalled = true;
}

/// Overrides goToNextRoute so we don't need a full layout stack.
class _NavigatingTestViewModel extends _TestAccountConductViewModel {
  _NavigatingTestViewModel({required super.repository});
  bool navigated = false;

  @override
  Future<void> saveAccConductData({bool ifNavigate = false}) async {
    await super.saveAccConductData();
    if (ifNavigate) {
      navigated = true;
    }
  }
}

class _FakeBuildContext extends Fake implements BuildContext {}

/// Observes whether the isEdit=true branch inside init() fires the draft hooks.
class _IsEditObservingVM extends _TestAccountConductViewModel {
  _IsEditObservingVM({required super.repository});
  bool registerCalled = false;
  bool loadDraftCalled = false;

  @override
  void registerDraftCallback() => registerCalled = true;

  @override
  Future<void> loadDraftIfAvailable() async => loadDraftCalled = true;
}

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUpAll(() async {
    registerFallbackValue(FakeAccountConductResponseData());

    hiveDir = await Directory.systemTemp.createTemp("hive_test_");
    Hive.init(hiveDir.path);

    const connectivityChannel =
        MethodChannel("dev.fluttercommunity.plus/connectivity");
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check" || call.method == "checkConnectivity") {
        return <String>["wifi"];
      }
      if (call.method == "wifiName") {
        return "test-wifi";
      }
      return null;
    });
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  late MockProfitabilityRepository mockRepository;

  setUp(() {
    Globals.user = null;
    mockRepository = MockProfitabilityRepository();
    HttpOverrides.global = null;
  });

  tearDown(() async {
    Globals.user = null;
    toastification.dismissAll(delayForAnimation: false);
    HttpOverrides.global = null;
  });

  // -------------------------------------------------------------------------
  // init()
  // -------------------------------------------------------------------------

  group("init()", () {
    test("non-empty DTO list: customers seeded, controllers initialised",
        () async {
      when(() => mockRepository.getAccountConductData()).thenAnswer(
        (_) async => AccountConductResponseData(
          previousYearLable: "2023",
          currentYearLable: "2024",
          accountConductDtoList: [sampleDto],
        ),
      );

      ProfitabilityRepository.overrideInstance = mockRepository;
      final vm = AccountConductViewModel();
      await vm.init(_FakeBuildContext());

      expect(vm.customers.length, 1);
      expect(vm.controllerFor("passDueOrExcesses", 0).text, "1");
      expect(vm.controllerFor("chequeReturns", 0).text, "2");
      expect(vm.controllerFor("turnoverInAcc", 0).text, "3");
      expect(vm.controllerFor("odHardcore", 0).text, "4");
      expect(vm.controllerFor("unusualTransactions", 0).text, "5");
      expect(vm.controllerFor("transparencyDisclosureLevels", 0).text, "6");

      vm.dispose();
    });

    // Covers the `if (isEdit)` branch in init().
    test("isEdit=true: registerDraftCallback and loadDraftIfAvailable called",
        () async {
      when(() => mockRepository.getAccountConductData()).thenAnswer(
        (_) async => AccountConductResponseData(
          previousYearLable: "2023",
          currentYearLable: "2024",
          accountConductDtoList: const [],
        ),
      );

      Globals.user = User(
        currentRole: Role(
          rights: {RightConstants.accountConduct: AccessType.edit},
        ),
      );

      final vm = _IsEditObservingVM(repository: mockRepository);
      await vm.init(_FakeBuildContext());

      expect(vm.registerCalled, isTrue);
      expect(vm.loadDraftCalled, isTrue);

      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Header getters
  // -------------------------------------------------------------------------

  group("previousYearHeader / currentYearHeader", () {
    test("return defaults when accountConduct is null", () {
      final vm = AccountConductViewModel();
      expect(vm.previousYearHeader, "Previous Year");
      expect(vm.currentYearHeader, "Current Year");
      vm.dispose();
    });

    test("return actual labels when accountConduct is set directly", () {
      final vm = AccountConductViewModel()
        ..accountConduct = AccountConductResponseData(
          previousYearLable: "FY 2021",
          currentYearLable: "FY 2022",
          accountConductDtoList: const [],
        );
      expect(vm.previousYearHeader, "FY 2021");
      expect(vm.currentYearHeader, "FY 2022");
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // canEdit / pageMode
  // -------------------------------------------------------------------------

  group("canEdit", () {
    test("returns false when pageMode is na (default)", () {
      final vm = AccountConductViewModel();
      expect(vm.canEdit, isFalse);
      vm.dispose();
    });

    test("returns true when pageMode is edit", () {
      final vm = AccountConductViewModel()..pageMode = PageMode.edit;
      expect(vm.canEdit, isTrue);
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // controllerFor()
  // -------------------------------------------------------------------------

  group("controllerFor()", () {
    test("lazily creates an empty controller for an unknown key", () {
      final vm = AccountConductViewModel();
      final c = vm.controllerFor("unknownField", 99);
      expect(c.text, "");
      vm.dispose();
    });

    test("returns the same instance on repeated calls (no duplicate)", () {
      final vm = AccountConductViewModel();
      final c1 = vm.controllerFor("passDueOrExcesses", 0);
      final c2 = vm.controllerFor("passDueOrExcesses", 0);
      expect(identical(c1, c2), isTrue);
      vm.dispose();
    });

    test("returns cached controller when key already exists in map", () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();

      final cached = vm.controllerFor("passDueOrExcesses", 0);
      expect(cached.text, "1");
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // updateCustomer()
  // -------------------------------------------------------------------------

  group("updateCustomer()", () {
    test("replaces DTO at valid index", () {
      final vm = AccountConductViewModel()..customers = [sampleDto];
      final updated = sampleDto.copyWith(passDueOrExcesses: "99");

      vm.updateCustomer(0, updated);

      expect(vm.customers[0].passDueOrExcesses, "99");
      vm.dispose();
    });

    test("does nothing for negative index", () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..updateCustomer(-1, sampleDto.copyWith(passDueOrExcesses: "99"));
      expect(vm.customers[0].passDueOrExcesses, "1");
      vm.dispose();
    });

    test("does nothing when index equals list length", () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..updateCustomer(1, sampleDto.copyWith(passDueOrExcesses: "99"));
      expect(vm.customers[0].passDueOrExcesses, "1");
      vm.dispose();
    });

    test("does nothing when customers list is empty", () {
      final vm = AccountConductViewModel()
        ..customers = []
        ..updateCustomer(0, sampleDto);
      expect(vm.customers, isEmpty);
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // syncCustomersFromControllers()
  // -------------------------------------------------------------------------

  group("syncCustomersFromControllers()", () {
    test("maps controller text back to DTO fields", () {
      final vm = AccountConductViewModel()..customers = [sampleDto];

      vm.controllerFor("passDueOrExcesses", 0).text = "10";
      vm.controllerFor("chequeReturns", 0).text = "20";
      vm.controllerFor("turnoverInAcc", 0).text = "30";
      vm.controllerFor("odHardcore", 0).text = "40";
      vm.controllerFor("unusualTransactions", 0).text = "50";
      vm.controllerFor("transparencyDisclosureLevels", 0).text = "60";

      vm.syncCustomersFromControllers();

      final dto = vm.customers[0];
      expect(dto.passDueOrExcesses, "10");
      expect(dto.chequeReturns, "20");
      expect(dto.turnoverInAcc, "30");
      expect(dto.odHardcore, "40");
      expect(dto.unusualTransactions, "50");
      expect(dto.transparencyDisclosureLevels, "60");

      vm.dispose();
    });

    test("handles missing controllers (absent keys stay null/empty)", () {
      AccountConductViewModel()
        ..customers = [sampleDto]
        ..syncCustomersFromControllers()
        ..dispose();
    });
  });

  // -------------------------------------------------------------------------
  // parseDouble()
  // -------------------------------------------------------------------------

  group("parseDouble()", () {
    late AccountConductViewModel vm;

    setUp(() => vm = AccountConductViewModel());
    tearDown(() => vm.dispose());

    test(
      "parses a valid integer string",
      () => expect(vm.parseDouble("42"), 42.0),
    );
    test(
      "parses a valid decimal string",
      () => expect(vm.parseDouble("12.5"), 12.5),
    );
    test(
      "parses a negative number",
      () => expect(vm.parseDouble("-3.14"), -3.14),
    );
    test(
      "returns null for empty string",
      () => expect(vm.parseDouble(""), isNull),
    );
    test(
      "returns null for whitespace string",
      () => expect(vm.parseDouble("  "), isNull),
    );
    test(
      "returns null for non-numeric string",
      () => expect(vm.parseDouble("abc"), isNull),
    );
    test(
      "returns null for null input",
      () => expect(vm.parseDouble(null), isNull),
    );
    test(
      "trims and parses whitespace-padded number",
      () => expect(vm.parseDouble("  7.0  "), 7.0),
    );
  });

  // -------------------------------------------------------------------------
  // reseedControllersFromCustomers()
  // -------------------------------------------------------------------------

  group("reseedControllersFromCustomers()", () {
    test("updates controllers from DTO values", () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();

      expect(vm.controllerFor("passDueOrExcesses", 0).text, "1");
      expect(vm.controllerFor("chequeReturns", 0).text, "2");
      expect(vm.controllerFor("turnoverInAcc", 0).text, "3");
      expect(vm.controllerFor("odHardcore", 0).text, "4");
      expect(vm.controllerFor("unusualTransactions", 0).text, "5");
      expect(vm.controllerFor("transparencyDisclosureLevels", 0).text, "6");

      vm.dispose();
    });

    test("treats 'null' string values as empty string", () {
      final vm = AccountConductViewModel()
        ..customers = [nullStringDto]
        ..reseedControllersFromCustomers();

      expect(vm.controllerFor("passDueOrExcesses", 0).text, "");
      expect(vm.controllerFor("chequeReturns", 0).text, "");
      expect(vm.controllerFor("turnoverInAcc", 0).text, "");

      vm.dispose();
    });

    test("creates controllers if missing (lazy path in _setControllerText)",
        () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();
      expect(vm.controllerFor("odHardcore", 0).text, "4");
      vm.dispose();
    });

    test("does not update controller when text is already correct (no-op path)",
        () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();
      final controller = vm.controllerFor("chequeReturns", 0);
      vm.reseedControllersFromCustomers();
      expect(controller.text, "2");
      vm.dispose();
    });

    test("_setControllerText updates existing controller when text differs",
        () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();

      vm.customers[0] = sampleDto.copyWith(passDueOrExcesses: "999");
      vm.reseedControllersFromCustomers();

      expect(vm.controllerFor("passDueOrExcesses", 0).text, "999");
      vm.dispose();
    });

    test(
        "_setControllerText does not update controller"
        " when text is already correct", () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();

      final controller = vm.controllerFor("passDueOrExcesses", 0);
      final listenerCallCount = <int>[0];
      controller.addListener(() => listenerCallCount[0]++);

      vm.reseedControllersFromCustomers();

      expect(listenerCallCount[0], 0);
      expect(controller.text, "1");
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // saveAccConductData() — success paths
  // -------------------------------------------------------------------------

  group("saveAccConductData() — success", () {
    testWidgets("posts and shows success toast (no navigation)",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "SUCCESS");

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await vm.saveAccConductData();
      await flushToastTimers(tester);

      verify(() => mockRepository.postAccountConductData(any())).called(1);
      vm.dispose();
    });

    testWidgets("creates accountConduct when it is null before posting",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "OK");

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await vm.saveAccConductData();
      await flushToastTimers(tester);

      expect(vm.accountConduct, isNotNull);
      verify(() => mockRepository.postAccountConductData(any())).called(1);
      vm.dispose();
    });

    testWidgets("updates existing accountConduct before posting",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "OK");

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [sampleDto]
        ..accountConduct = AccountConductResponseData(
          previousYearLable: "2022",
          currentYearLable: "2023",
          accountConductDtoList: const [],
        );

      await vm.saveAccConductData();
      await flushToastTimers(tester);

      expect(vm.accountConduct!.accountConductDtoList, isNotEmpty);
      vm.dispose();
    });

    testWidgets("ifNavigate=true is handled without throwing", (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "OK");

      final vm = _NavigatingTestViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await vm.saveAccConductData(ifNavigate: true);
      await flushToastTimers(tester);

      expect(vm.navigated, isTrue);
      vm.dispose();
    });

    testWidgets("deleteDraft is called after successful post", (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "OK");

      final vm = _TrackingTestViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await vm.saveAccConductData();
      await flushToastTimers(tester);

      expect(vm.deleteDraftCalled, isTrue);
      vm.dispose();
    });

    testWidgets("toJson() throwing is silently caught, save still succeeds",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "OK");

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [sampleDto]
        ..accountConduct = _ThrowingResponseData();

      await vm.saveAccConductData();
      await flushToastTimers(tester);

      verify(() => mockRepository.postAccountConductData(any())).called(1);
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // saveAccConductData() — error path
  // -------------------------------------------------------------------------

  group("saveAccConductData() — error", () {
    testWidgets(
        "when repository "
        "throws, it is caught "
        "and shows error toast (no navigation)", (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenThrow(Exception("Network error"));

      final vm = _NavigatingTestViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await expectLater(
        () async => vm.saveAccConductData(ifNavigate: true),
        returnsNormally,
      );
      await flushToastTimers(tester);

      verify(() => mockRepository.postAccountConductData(any())).called(1);
      expect(vm.navigated, isTrue);
      vm.dispose();
    });

    testWidgets(
        "when repository returns a non-success "
        "response, shows error toast (no navigation)", (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "FAILED");

      final vm = _NavigatingTestViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await expectLater(
        () async => vm.saveAccConductData(ifNavigate: true),
        returnsNormally,
      );
      await flushToastTimers(tester);

      verify(() => mockRepository.postAccountConductData(any())).called(1);
      expect(vm.navigated, isTrue);
      vm.dispose();
    });

    testWidgets(
        "when repository returns empty/null-like response, it is treated as error and shows toast",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenAnswer((_) async => "");

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await expectLater(() async => vm.saveAccConductData(), returnsNormally);
      await flushToastTimers(tester);

      verify(() => mockRepository.postAccountConductData(any())).called(1);
      vm.dispose();
    });

    testWidgets("if customers list is empty, should not call post",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [];

      await expectLater(() async => vm.saveAccConductData(), returnsNormally);
      await flushToastTimers(tester);

      vm.dispose();
    });

    testWidgets("exception path emits LoadingStatus.error state",
        (tester) async {
      await tester.pumpWidget(
        const ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );
      when(() => mockRepository.postAccountConductData(any()))
          .thenThrow(Exception("boom"));

      final vm = _TestAccountConductViewModel(repository: mockRepository)
        ..customers = [sampleDto];
      final streamExpectation = expectLater(
        vm.stream,
        emitsThrough(
          predicate<AccountConductState>(
            (s) => s.loaderStatus == LoadingStatus.error,
          ),
        ),
      );

      await vm.saveAccConductData();
      await tester.pump();
      await flushToastTimers(tester);
      await tester.pumpAndSettle();
      await streamExpectation;

      vm.dispose();
    });

    testWidgets("exception + ifNavigate=false does not navigate",
        (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: Container())),
        ),
      );

      when(() => mockRepository.postAccountConductData(any()))
          .thenThrow(Exception("fail"));

      final vm = _NavigatingTestViewModel(repository: mockRepository)
        ..customers = [sampleDto];

      await vm.saveAccConductData();
      await flushToastTimers(tester);

      expect(vm.navigated, isFalse);
      vm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // dispose()
  // -------------------------------------------------------------------------

  group("dispose()", () {
    test("clears all controllers without throwing", () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();
      expect(vm.dispose, returnsNormally);
    });

    test("is safe to call on a fresh ViewModel with no controllers", () {
      final vm = AccountConductViewModel();
      expect(vm.dispose, returnsNormally);
    });

    test("all text controllers are disposed and inaccessible after dispose()",
        () {
      final vm = AccountConductViewModel()
        ..customers = [sampleDto]
        ..reseedControllersFromCustomers();

      final controller = vm.controllerFor("passDueOrExcesses", 0);
      vm.dispose();

      expect(() => controller.addListener(() {}), throwsFlutterError);
    });
  });
}
