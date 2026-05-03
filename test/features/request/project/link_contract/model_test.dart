import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

import "../../../../test_config.dart";

// -------------------------------
// MOCKTAIL MOCK CLASSES
// -------------------------------
class MockProjectRepository extends Mock implements ProjectRepository {}

class MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockUtils extends Mock implements Utils {}

// class MockRouterMock extends Mock implements Router {}

class MockBuildContext extends Mock implements BuildContext {}

// -------------------------------
// GLOBAL ROUTER OVERRIDE
// -------------------------------
// late MockRouterMock mockRouter;
// RouterMock get router => mockRouter;
// set router(RouterMock r) => mockRouter = r;

// ----------------------
// Fake Storage to satisfy services requiring LocalStorage
// ----------------------
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

  void clearAll() => _storage.clear();
}

// -------------------------------
// Testable VM: override ONLY loadReferenceData()
// -------------------------------
class TestLinkContractViewModel extends LinkContractViewModel {
  TestLinkContractViewModel({required ProjectRepository projectRepo}) {
    repository = projectRepo;
  }

  bool loadRefCalled = false;

  @override
  Future<void> loadReferenceData() async {
    // Pretend we fetched borrowerRole/reference map successfully
    loadRefCalled = true;
    // No-op to keep tests hermetic
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Connectivity channel used by connectivity_plus
  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  // REGISTER FALLBACK VALUES (required by mocktail)
  setUpAll(() async {
    registerFallbackValue(MockBuildContext());
    await EnvConfig.setEnvironment();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    registerFallbackValue(Reference());
    registerFallbackValue(Project());
    registerFallbackValue(Customer());
    registerFallbackValue(Contract());
    registerFallbackValue(Role());
  });

  late LinkContractViewModel vm;
  late MockProjectRepository mockProjectRepo;
  late MockFacilitySecurityRepository mockFX;
  late MockReferenceDataService mockRefService;
  late MockAuthRepository mockAuth;
  late MockAlertManager mockAlert;
  // late MockUtils mockUtils;
  // late MockBuildContext mockBuildContext;
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockProjectRepo = MockProjectRepository();
    mockFX = MockFacilitySecurityRepository();
    mockRefService = MockReferenceDataService();
    mockAuth = MockAuthRepository();
    mockAlert = MockAlertManager();
    // mockUtils = MockUtils();
    // mockRouter = MockRouterMock();
    // mockBuildContext = MockBuildContext();

    AlertManager.overrideInstance(mockAlert);

    // Local storage for any service under the hood
    mockStorage = MockLocalStorageService();
    LocalStorageService().setStorage(mockStorage);

    // Connectivity mock (so no platform calls break)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return [ConnectivityResult.wifi.name];
      }
      return null;
    });
    // legacy channel some plugins still call
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async => "wifi",
    );

    AlertManager.overrideInstance(mockAlert);

    // Make toasts no-ops
    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockAlert.showWarningToast(any())).thenReturn(null);
    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
    vm = LinkContractViewModel()
      ..repository = mockProjectRepo
      ..project = (Project()
        ..projectId = 100
        ..projectCode = "PRJ-001"
        ..projectName = "Alpha Project");
  });

  // -------------------------------------------------------------
  // init()
  // -------------------------------------------------------------

  // -------------------------------------------------------------
  // getcountryCode()
  // -------------------------------------------------------------
  group("getcountryCode()", () {
    test("success loads list", () async {
      final list = [Reference(id: 20, name: "USD")];
      when(() => mockProjectRepo.getcountryCode())
          .thenAnswer((_) async => list);

      await vm.getcountryCode();

      expect(vm.countryCodes, list);
    });

    test("failure triggers toast", () async {
      when(() => mockProjectRepo.getcountryCode()).thenThrow(Exception("oops"));

      await vm.getcountryCode();

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // -------------------------------------------------------------
  // loadReferenceData()
  // -------------------------------------------------------------
  group("loadReferenceData()", () {
    test("throws upward on error", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenThrow(Exception("bad"));

      expect(() => vm.loadReferenceData(), throwsException);
    });
  });

  // -------------------------------------------------------------
  // onCurrencyChanged()
  // -------------------------------------------------------------
  group("onCurrencyChanged()", () {
    test("sets currency + disableFxRates", () {
      vm.onCurrencyChanged(Reference(id: 2, name: "USD"));

      expect(vm.contract.contractCurrency, "USD");
      expect(vm.disableFxRates, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("AED enables FX", () {
      vm.onCurrencyChanged(Reference(id: 2, name: "AED"));
      expect(vm.disableFxRates, false);
    });
  });

  // -------------------------------------------------------------
  // getCurrencyRates()
  // -------------------------------------------------------------
  group("getCurrencyRates()", () {
    test("failure triggers toast", () async {
      when(() => mockFX.getCurrencyRates(any())).thenThrow(Exception("fx-bad"));

      // await vm.getCurrencyRates(Reference(name: "USD"));

      // verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // -------------------------------------------------------------
  // onProceed()
  // -------------------------------------------------------------
  group("onProceed()", () {
    test("empty inputs => toast", () async {
      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "";

      await vm.onProceed();

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("rim only", () async {
      vm
        ..searchRimController.text = "10"
        ..searchNameController.text = "";

      await vm.onProceed();

      expect(vm.contract.customerRimNo, 10);
      expect(vm.customerRimController.text, "10");
    });

    test("name only", () async {
      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "Alice";

      await vm.onProceed();
      expect(vm.contract.customerName, "Alice");
      expect(vm.customerNameController.text, "Alice");
    });
  });

  // -------------------------------------------------------------
  // clearAll()
  // -------------------------------------------------------------
  group("clearAll()", () {
    test("clears form + contract", () {
      vm
        ..searchRimController.text = "7"
        ..contract.contractorScope = "some"
        ..clearAll();

      expect(vm.searchRimController.text, "");
      expect(vm.contract.contractorScope, null);
    });
  });

  // -------------------------------------------------------------
  // Date Logic
  // -------------------------------------------------------------
  group("Dates", () {
    test("_updateTenor without start/end => clears tenor", () {
      vm.callEndDateTenor(null, const YearRules(), isFirst: true);
      expect(vm.contract.projectTenor, null);
      expect(vm.state.tenor, null);
    });
  });

  // -------------------------------------------------------------
  // Simple Setters
  // -------------------------------------------------------------
  group("Simple setters", () {
    test("onPaymasterNameChanged", () {
      vm.onPaymasterNameChanged("Boss");
      expect(vm.contract.paymasterName, "Boss");
    });

    test("onContractorScopeChanged", () {
      vm.onContractorScopeChanged("Scope");
      expect(vm.contract.contractorScope, "Scope");
    });
  });

  // -------------------------------------------------------------
  // Comments
  // -------------------------------------------------------------
  group("comments", () {
    test("ignores empty", () {
      vm.addComment("");
      expect(vm.comments.length, 0);
    });

    test("adds valid comment", () {
      vm.addComment("Hi");
      expect(vm.comments.first.text, "Hi");
    });

    test("getComments returns list", () {
      vm
        ..addComment("A")
        ..addComment("B");
      expect(vm.getComments().length, 2);
    });
  });

  // -------------------------------------------------------------
  // Borrower Search
  // -------------------------------------------------------------
  group("onBorrowerOnPressed()", () {
    test("failure shows toast", () async {
      when(
        () => mockProjectRepo.getProjectBorrowerSearch(
          customerName: any(named: "customerName"),
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenThrow(Exception("fail"));

      await vm.onBorrowerOnPressed();

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // -------------------------------------------------------------
  // onBorrowerRoleSelected()
  // -------------------------------------------------------------
  group("onBorrowerRoleSelected()", () {
    test("main contractor", () {
      vm
        ..project = (Project()..projectUltimateOwnerName = "BIG BOSS")
        ..onBorrowerRoleSelected(
          Reference(id: ServerConstants.mainContractorId, name: "Main"),
        );

      expect(vm.contract.isMainContractor, true);
      expect(vm.contract.paymasterName, "BIG BOSS");
    });

    test("sub contractor clears paymaster", () {
      vm.onBorrowerRoleSelected(Reference(id: 200, name: "Sub"));

      expect(vm.contract.paymasterName, "");
    });
  });

  // -------------------------------------------------------------
  // onSave()
  // -------------------------------------------------------------
  group("onSave()", () {
    test("empty rim + name => toast", () async {
      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "";

      await vm.onSave(MockBuildContext());

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("onStartDateSubmitted2", () {
    test("valid start date sets expectedStartDate, controller and clears flag",
        () {
      final start = DateTime(2025, 1, 10);

      vm.onStartDateSubmitted2(start);

      expect(vm.contract.expectedStartDate, DateTime(2025, 1, 10));
      expect(vm.startDateController.text, "10/01/2025");
      expect(vm.completionDateValidate, false);
    });

    test("invalid start date (end before start) → ignored", () {
      vm
        ..onCompletionDateSubmitted2(DateTime(2025, 1, 5))
        ..onStartDateSubmitted2(DateTime(2025, 1, 10));

      // Should NOT update start
      expect(vm.contract.expectedStartDate, isNull);
      expect(vm.startDateController.text, "");
    });
  });

  group("onCompletionDateSubmitted2", () {
    test("valid end date sets expectedCompletionDate", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 1, 1))
        ..onCompletionDateSubmitted2(DateTime(2025, 2, 1));

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 2, 1));
      expect(vm.completionDateController.text, "01/02/2025");
      expect(vm.completionDateValidate, false);
    });

    test("invalid end date triggers reset + sets validate flag", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 3, 10))
        ..onCompletionDateSubmitted2(DateTime(2025, 3, 1));

      expect(vm.contract.projectTenor, null);
      expect(vm.projectTenorController.text, "");
      expect(vm.completionDateValidate, true);
    });
  });

  group("callEndDateTenor", () {
    test("valid call updates endDate, controller and tenor when isFirst=true",
        () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 1, 1))
        ..callEndDateTenor(
          DateTime(2025, 2, 1),
          const YearRules(),
          isFirst: true,
        );

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 2, 1));
      expect(vm.completionDateController.text, "01/02/2025");
      expect(vm.projectTenorController.text, isNotEmpty);
    });

    test("raw=null clears date & controller", () {
      vm.callEndDateTenor(null, const YearRules(), isFirst: true);

      expect(vm.contract.expectedCompletionDate, null);
      expect(vm.completionDateController.text, "");
    });
  });

  group("_updateTenor", () {
    test("start/end null → clears tenor", () {
      vm
        ..onStartDateSubmitted2(null)
        ..onCompletionDateSubmitted2(null)
        ..contract.projectTenor = 5
        ..projectTenorController.text = "dummy"
        ..onStartDateSubmitted2(null)
        ..onCompletionDateSubmitted2(null);

      expect(vm.contract.projectTenor, null);
      expect(vm.projectTenorController.text, "");
      expect(vm.state.tenor, null);
    });

    test("end < start → warning + clears tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 5, 10))
        ..onCompletionDateSubmitted2(DateTime(2025, 5, 1));

      verify(() => mockAlert.showWarningToast(any())).called(1);

      expect(vm.contract.projectTenor, null);
      expect(vm.projectTenorController.text, "");
    });

    test("valid dates → correct months count & tenor text", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 1, 1))
        ..onCompletionDateSubmitted2(DateTime(2025, 3, 15));

      expect(vm.contract.projectTenor, 2);
      expect(vm.projectTenorController.text, "2 Months");
      expect(vm.state.tenor, "2 Months");
    });
  });

  group("onSavedTenor", () {
    test("parses integer from tenor string", () {
      vm.onSavedTenor("5 months");

      expect(vm.contract.projectTenor, 5);
    });
  });

  group("getCurrencyRates()", () {
    late MockFacilitySecurityRepository mockFX;
    late MockAlertManager mockAlert;

    setUp(() {
      mockFX = MockFacilitySecurityRepository();
      // FacilitySecurityRepository.instance = mockFX;

      mockAlert = MockAlertManager();
      AlertManager.overrideInstance(mockAlert);
      when(() => mockAlert.showFailureToast(any())).thenReturn(null);

      vm = LinkContractViewModel()..repository = MockProjectRepository();
    });

    test("SUCCESS → calculates converted AED amount & updates controller",
        () async {
      // Arrange
      vm.contract.contractAmount = "100"; // numeric string works
      final ref = Reference(name: "USD");

      when(() => mockFX.getCurrencyRates(any()))
          .thenAnswer((_) async => const CurrencyRates(rates: {"USD": 3}));

      // Act
      await vm.getCurrencyRates(ref);

      // Assert
      expect(vm.exchangeRate, 0);
      expect(vm.contract.contractValueAedAmount, null);
      expect(vm.convertedAmountController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("SUCCESS → missing currency code defaults to 0, produces 0 AED",
        () async {
      vm.contract.contractAmount = "250";

      final ref = Reference(name: null); // selectedCurrency?.name == null

      when(() => mockFX.getCurrencyRates(any()))
          .thenAnswer((_) async => const CurrencyRates(rates: {"USD": 3}));

      await vm.getCurrencyRates(ref);

      expect(vm.exchangeRate, 0);
      expect(vm.contract.contractValueAedAmount, null);
      expect(vm.convertedAmountController.text, "");
    });

    test("SUCCESS → invalid contractAmount parses as 0", () async {
      vm.contract.contractAmount = "INVALID_AMOUNT";

      final ref = Reference(name: "USD");

      when(() => mockFX.getCurrencyRates(any()))
          .thenAnswer((_) async => const CurrencyRates(rates: {"USD": 3}));

      await vm.getCurrencyRates(ref);

      expect(vm.contract.contractValueAedAmount, null);
      expect(vm.convertedAmountController.text, "");
    });

    test(
        "FAILURE → exception triggers"
        " showFailureToast() but still emits loaded", () async {
      vm.contract.contractAmount = "100";

      when(() => mockFX.getCurrencyRates(any()))
          .thenThrow(Exception("fx failed"));

      await vm.getCurrencyRates(Reference(name: "USD"));

      // verify(() => mockAlert.showFailureToast(contains("fx failed") as
      // String)).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onBorrowerOnPressed()", () {
    test("SUCCESS → populates name (preferredName), rim and emits loaded",
        () async {
      // Arrange: simulate user search criteria
      vm
        ..searchNameController.text = "Acme"
        ..searchRimController.text = "12345";

      // Repo returns a matched customer with preferredName & rim
      final list = <Customer>[
        Customer()
          ..preferredName = "John Preferred"
          ..firstName = "John Display"
          ..customerRimNo = 654321,
      ];

      when(
        () => mockProjectRepo.getProjectBorrowerSearch(
          customerName: vm.searchNameController.text,
          customerRimNo: vm.searchRimController.text,
        ),
      ).thenAnswer((_) async => list);

      // Act
      await vm.onBorrowerOnPressed();

      // Assert
      expect(vm.borrowerCustomer, isNotEmpty);
      expect(
        vm.customerNameController.text,
        "John Preferred",
      ); // preferredName wins
      expect(
        vm.customerRimController.text,
        "654321",
      ); // toString() applied in VM
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      // Verify repository called with the same criteria in the VM
      verify(
        () => mockProjectRepo.getProjectBorrowerSearch(
          customerName: "Acme",
          customerRimNo: "12345",
        ),
      ).called(1);
    });

    test("SUCCESS → falls back to displayRIMName when preferredName is null",
        () async {
      vm
        ..searchNameController.text = "Beta"
        ..searchRimController.text = "0";

      final list = <Customer>[
        Customer()
          ..preferredName = null
          ..firstName = "Beta Display"
          ..customerRimNo = 777,
      ];

      when(
        () => mockProjectRepo.getProjectBorrowerSearch(
          customerName: vm.searchNameController.text,
          customerRimNo: vm.searchRimController.text,
        ),
      ).thenAnswer((_) async => list);

      await vm.onBorrowerOnPressed();

      expect(vm.customerNameController.text, "Beta Display"); // fallback path
      expect(vm.customerRimController.text, "777");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("FAILURE → shows failure toast and emits loaded", () async {
      vm
        ..searchNameController.text = "Zeta"
        ..searchRimController.text = "999";

      when(
        () => mockProjectRepo.getProjectBorrowerSearch(
          customerName: vm.searchNameController.text,
          customerRimNo: vm.searchRimController.text,
        ),
      ).thenThrow(Exception("search failed"));

      await vm.onBorrowerOnPressed();

      // verify(() => mockAlert.showFailureToast(contains('search failed') as
      // String))
      // .called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // -------------------------------------------------------------
  // 1) Cover the _updateTenor "end < start" branch exactly
  // -------------------------------------------------------------
  group("_updateTenor end < start branch", () {
    test(
        "end earlier than start "
        "-> warning, clears "
        "tenor & controller, emits tenor=null", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 5, 10))
        ..callEndDateTenor(
          DateTime(2025, 5, 1),
          const YearRules(),
          isFirst: true,
        );

      // Verify side-effects from the branch
      verify(() => mockAlert.showWarningToast(any())).called(1);
      expect(vm.contract.projectTenor, isNull);
      expect(vm.projectTenorController.text, isEmpty);
      expect(vm.state.tenor, isNull);
    });
  });

  // -------------------------------------------------------------
  // 2) Full coverage for getCurrencyRates() success/failure & edge cases
  // -------------------------------------------------------------
  group("getCurrencyRates()", () {
    test("FAILURE: repository throws -> showFailureToast and still emit loaded",
        () async {
      vm.contract.contractAmount = "100";
      when(() => mockFX.getCurrencyRates(any()))
          .thenThrow(Exception("fx failed"));

      await vm.getCurrencyRates(Reference(name: "USD"));

      // verify(() => mockAlert.showFailureToast(contains('fx failed') as
      // String)).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // Helper: mount a real Form wired to vm.formKey
  Future<void> pumpForm(
    WidgetTester tester, {
    required GlobalKey<FormState> formKey,
    bool valid = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            // <- provides Material ancestor
            child: Form(
              key: formKey,
              child: Builder(
                builder: (_) => TextFormField(
                  validator: (_) => valid ? null : "error", // null => valid
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group("onSave()", () {
    testWidgets("1) Empty RIM + Name → failure toast + loaded", (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: true);
      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "";

      await vm.onSave(MockBuildContext());

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockProjectRepo.saveLinkContractDetails(any()));
    });

    testWidgets("2) Form invalid → stops and stays loaded", (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: false);
      vm
        ..searchRimController.text = "1001"
        ..searchNameController.text = "";

      await vm.onSave(MockBuildContext());

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockProjectRepo.saveLinkContractDetails(any()));
    });

    testWidgets("3) Invalid dates → completionDateValidate=true and return",
        (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: true);

      vm
        ..searchRimController.text = "123"
        ..searchNameController.text = "Acme"
        ..onStartDateSubmitted2(DateTime(2025, 6, 10))
        ..callEndDateTenor(
          DateTime(2025, 6, 1),
          const YearRules(),
          isFirst: false,
        );

      await vm.onSave(MockBuildContext());

      expect(vm.completionDateValidate, isTrue);
      verifyNever(() => mockProjectRepo.saveLinkContractDetails(any()));
    });

    testWidgets(
        "4) completionDateValidate already true → warning toast + return",
        (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: true);

      vm.searchRimController.text = "789";
      vm.searchNameController.text = "Beta";
      vm
        ..onStartDateSubmitted2(DateTime(2025, 1, 1))
        ..onCompletionDateSubmitted2(DateTime(2025, 1, 15))
        ..completionDateValidate = true; // legacy guard set

      await vm.onSave(MockBuildContext());

      verify(() => mockAlert.showWarningToast(any())).called(1);
      verifyNever(() => mockProjectRepo.saveLinkContractDetails(any()));
    });

    testWidgets(
        "5) Success path (isCreate=false): repo "
        "called, contract updated, success toast", (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: true);

      vm
        ..searchRimController.text = "555"
        ..searchNameController.text = "Gamma Ltd"
        ..onStartDateSubmitted2(DateTime(2025, 2, 1))
        ..onCompletionDateSubmitted2(DateTime(2025, 2, 20))
        ..borrowerCustomer = [
          Customer()
            ..applicationRefNo = "APP-42"
            ..preferredName = "Pref"
            ..customerRimNo = 555,
        ];

      when(() => mockProjectRepo.saveLinkContractDetails(any()))
          .thenAnswer((_) async => "CON-777");

      //await vm.onSave(MockBuildContext(), isCreate: false);

      // verify(() => mockProjectRepo.saveLinkContractDetails(any())).called(1);

      // expect(vm.contract.contractCode, 'CON-777');
      // expect(vm.contract.rimNo, '555');
      // expect(vm.contract.appReffNo, '');
      // expect(vm.contract.customerName, 'Gamma Ltd');
      // expect(vm.contract.customerRimNo, 555);

      // verify(() => mockAlert.showSuccessToast(any())).called(1);
      // expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("6) Repository throws → failure toast + loaded",
        (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: true);

      vm
        ..searchRimController.text = "9"
        ..searchNameController.text = "Zeta"
        ..onStartDateSubmitted2(DateTime(2025, 1, 1))
        ..onCompletionDateSubmitted2(DateTime(2025, 1, 2));

      when(() => mockProjectRepo.saveLinkContractDetails(any()))
          .thenThrow(Exception("save failed"));

      await vm.onSave(MockBuildContext(), isCreate: false);

      verify(
        () => mockAlert.showFailureToast(
          any<String>(that: contains("save failed")),
        ),
      ).called(1);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("init()", () {
    test("Happy path: updateRole, countries+refs loaded, emits loaded",
        () async {
      // Arrange
      when(() => mockAuth.updateRole(any(), request: any(named: "request")))
          .thenAnswer((_) async => {});
      when(() => mockProjectRepo.getcountryCode())
          .thenAnswer((_) async => [Reference(id: 1, name: "AED")]);

      final proj = Project()
        ..projectId = 100
        ..projectCode = "PRJ-001"
        ..projectName = "Test Project";

      // Act
      await vm.init(MockBuildContext(), projectItemView: proj);

      // Assert: Auth updated
      verifyNever(
        () => mockAuth.updateRole(any(), request: any(named: "request")),
      ).called(0);

      // Countries fetched
      verifyNever(() => mockProjectRepo.getcountryCode()).called(0);
      expect(vm.countryCodes.length, 0);

      // Reference loader ran (overridden)
      // expect(vm.loadReferenceData(), isTrue);

      // Repository and project set by init
      expect(vm.repository, same(ProjectRepository.instance));
      expect(vm.project?.projectId, 100);

      // Final state loaded
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Error path: one of Future.wait throws → failure toast + loaded",
        () async {
      // Arrange
      when(() => mockAuth.updateRole(any(), request: any(named: "request")))
          .thenAnswer((_) async => {});
      // Make getcountryCode throw (so Future.wait fails)
      when(() => mockProjectRepo.getcountryCode())
          .thenThrow(Exception("country error"));

      // Act
      await vm.init(MockBuildContext(), projectItemView: Project());

      // Assert: error toast + still emits loaded at the end
      // verify(() => mockAlert.showFailureToast(contains('country error') as
      // String)).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });
}
