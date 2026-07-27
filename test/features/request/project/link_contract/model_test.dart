import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class TestLinkContractViewModel extends LinkContractViewModel {
  @override
  Future<void> deleteDraft() async {
    // Prevent DraftRepository.deleteDraft real API call and pending timers.
  }

  @override
  void onDiscard(BuildContext context) {
    // Prevent real router navigation in tests.
  }
}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late TestLinkContractViewModel vm;
  late MockProjectRepository mockProjectRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    registerFallbackValue(<String>[]);
    registerFallbackValue(Reference());
    registerFallbackValue(Project());
    registerFallbackValue(Customer());
    registerFallbackValue(Contract());
    registerFallbackValue(Role());
    registerFallbackValue(Request());
    registerFallbackValue(MockBuildContext());

    EasyLocalization.logger.enableBuildModes = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <dynamic>["wifi"];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async => "wifi",
    );
  });

  setUp(() {
    mockProjectRepository = MockProjectRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    ReferenceDataService.overrideInstance = mockReferenceDataService;
    AlertManager.overrideInstance = mockAlertManager;
    LocalStorageService().getStorage = MockLocalStorageService();

    Globals.request = Request(applicationRefNo: "APP-001");
    Globals.user = User(
      id: "USER-1",
      currentRole: Role(roleId: 1),
    );

    when(() => mockAlertManager.showFailureToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showWarningToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showSuccessToast(any())).thenAnswer((_) {});

    vm = TestLinkContractViewModel()
      ..repository = mockProjectRepository
      ..project = (Project()
        ..projectId = 100
        ..projectCode = "PRJ-001"
        ..projectName = "Alpha Project"
        ..projectUltimateOwnerName = "Ultimate Owner");
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      null,
    );
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    required GlobalKey<FormState> formKey,
    bool valid = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormField(
              validator: (_) => valid ? null : "error",
            ),
          ),
        ),
      ),
    );
  }

  Future<BuildContext> pumpContextWithForm(
    WidgetTester tester, {
    required GlobalKey<FormState> formKey,
    bool valid = true,
  }) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              capturedContext = context;
              return Form(
                key: formKey,
                child: TextFormField(
                  validator: (_) => valid ? null : "error",
                ),
              );
            },
          ),
        ),
      ),
    );

    return capturedContext;
  }

  group("initial, draft and close", () {
    test("initial state is loading", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("draft getters are covered", () {
      expect(vm.draftModuleKey, isNotEmpty);
      expect(vm.draftFormKey, contains("/link-contract_PRJ-001"));
      expect(vm.draftHandler, isNotNull);
    });

    test("draftFormKey uses projectName fallback when projectCode is null", () {
      vm.project = Project()..projectName = "Only Name";

      expect(vm.draftFormKey, contains("Only Name"));
    });

    test("canEdit returns false when pageMode is not edit", () {
      vm.pageMode = PageMode.view;

      expect(vm.canEdit, false);
    });

    test("close is safe", () async {
      await vm.close();
    });
  });

  group("init", () {
    test("init catch path covers AuthRepository/updateRole lines safely",
        () async {
      await vm.init(
        MockBuildContext(),
        projectItemView: Project()
          ..projectId = 1
          ..projectCode = "PRJ"
          ..projectName = "Project",
      );

      expect(vm.project?.projectCode, "PRJ");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getcountryCode", () {
    test("success loads and sorts AED first", () async {
      when(() => mockProjectRepository.getcountryCode()).thenAnswer(
        (_) async => [
          Reference(name: "USD"),
          Reference(name: ReferenceDataKeys.currencyAED),
          Reference(name: "EUR"),
        ],
      );

      await vm.getcountryCode();

      expect(vm.countryCodes.first.name, ReferenceDataKeys.currencyAED);
      expect(vm.countryCodes.length, 3);
    });

    test("success handles empty list", () async {
      when(() => mockProjectRepository.getcountryCode())
          .thenAnswer((_) async => []);

      await vm.getcountryCode();

      expect(vm.countryCodes, isEmpty);
    });

    test("failure shows toast", () async {
      when(() => mockProjectRepository.getcountryCode())
          .thenThrow(Exception("oops"));

      await vm.getcountryCode();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("loadReferenceData", () {
    test("success loads borrower roles", () async {
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.borrowerRole: [
            Reference(id: 1, name: "Borrower"),
          ],
        },
      );

      await vm.loadReferenceData();

      expect(vm.borrowerRole?.length, 1);
      expect(vm.borrowerRole?.first.name, "Borrower");
    });

    test("success handles missing borrower role key", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => <String, List<Reference>>{});

      await vm.loadReferenceData();

      expect(vm.borrowerRole, isEmpty);
    });

    test("failure rethrows", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenThrow(Exception("bad"));

      expect(() => vm.loadReferenceData(), throwsException);
    });
  });

  group("currency", () {
    test("onCurrencyChanged AED keeps FX enabled", () {
      vm.onCurrencyChanged(Reference(name: ServerConstants.aedCurrency));

      expect(vm.selectedCurrencyLabel, ServerConstants.aedCurrency);
      expect(vm.contract.contractCurrency, ServerConstants.aedCurrency);
      expect(vm.disableFxRates, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onCurrencyChanged non-AED disables FX", () {
      vm.onCurrencyChanged(Reference(name: "USD"));

      expect(vm.selectedCurrencyLabel, "USD");
      expect(vm.contract.contractCurrency, "USD");
      expect(vm.disableFxRates, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onCurrencyChanged null name defaults label", () {
      vm.onCurrencyChanged(Reference());

      expect(vm.selectedCurrencyLabel, ServerConstants.aedCurrency);
      expect(vm.contract.contractCurrency, isNull);
      expect(vm.disableFxRates, true);
    });

    test("getCurrencyRates failure path is safe and emits loaded", () async {
      await vm.getCurrencyRates(Reference(name: "USD"));

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onContractValueChanged is safe no-op", () {
      vm.onContractValueChanged("123");

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("onProceed and clearAll", () {
    test("onProceed empty inputs shows toast", () async {
      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "";

      await vm.onProceed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onProceed rim and name populate contract and controllers", () async {
      vm
        ..searchRimController.text = "123"
        ..searchNameController.text = "Customer"
        ..borrowerCustomer = [
          Customer()..applicationRefNo = "APP-777",
        ];

      await vm.onProceed();

      expect(vm.contract.appReffNo, "APP-777");
      expect(vm.contract.customerRimNo, 123);
      expect(vm.contract.customerName, "Customer");
      expect(vm.customerRimController.text, "123");
      expect(vm.customerNameController.text, "Customer");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onProceed name only works", () async {
      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "Alice";

      await vm.onProceed();

      expect(vm.contract.customerRimNo, isNull);
      expect(vm.contract.customerName, "Alice");
      expect(vm.customerRimController.text, "");
      expect(vm.customerNameController.text, "Alice");
    });

    test("onProceed invalid rim keeps rim null", () async {
      vm
        ..searchRimController.text = "ABC"
        ..searchNameController.text = "Alice";

      await vm.onProceed();

      expect(vm.contract.customerRimNo, isNull);
      expect(vm.customerRimController.text, "");
      expect(vm.customerNameController.text, "Alice");
    });

    test("clearAll clears controllers and contract", () {
      vm
        ..searchRimController.text = "7"
        ..searchNameController.text = "Name"
        ..customerRimController.text = "7"
        ..customerNameController.text = "Name"
        ..projectTenorController.text = "2 Months"
        ..paymasterNameController.text = "Boss"
        ..contractorScopeController.text = "Scope"
        ..startDateController.text = "01/01/2025"
        ..completionDateController.text = "01/02/2025";

      vm.contract
        ..borrowerRole = "Role"
        ..contractValue = "100"
        ..paymasterName = "Boss"
        ..contractorScope = "Scope"
        ..expectedStartDate = DateTime(2025)
        ..expectedCompletionDate = DateTime(2025, 2)
        ..projectTenor = 1;

      vm.clearAll();

      expect(vm.searchRimController.text, "");
      expect(vm.searchNameController.text, "");
      expect(vm.customerRimController.text, "");
      expect(vm.customerNameController.text, "");
      expect(vm.projectTenorController.text, "");
      expect(vm.paymasterNameController.text, "");
      expect(vm.contractorScopeController.text, "");
      expect(vm.startDateController.text, "");
      expect(vm.completionDateController.text, "");
      expect(vm.contract.borrowerRole, isNull);
      expect(vm.contract.contractValue, isNull);
      expect(vm.contract.paymasterName, isNull);
      expect(vm.contract.contractorScope, isNull);
      expect(vm.contract.expectedStartDate, isNull);
      expect(vm.contract.expectedCompletionDate, isNull);
      expect(vm.contract.projectTenor, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("date logic and tenor", () {
    test("onStartDateSubmitted2 null clears controller", () {
      vm.onStartDateSubmitted2(null);

      expect(vm.contract.expectedStartDate, isNull);
      expect(vm.startDateController.text, "");
    });

    test("onStartDateSubmitted2 valid start date sets controller", () {
      vm.onStartDateSubmitted2(DateTime(2025, 1, 10));

      expect(vm.contract.expectedStartDate, DateTime(2025, 1, 10));
      expect(vm.startDateController.text, "10/01/2025");
      expect(vm.completionDateValidate, false);
    });

    test("onStartDateSubmitted2 invalid with end before start clears start",
        () {
      vm
        ..onCompletionDateSubmitted2(DateTime(2025, 1, 5))
        ..onStartDateSubmitted2(DateTime(2025, 1, 10));

      expect(vm.contract.expectedStartDate, isNull);
      expect(vm.startDateController.text, "");
    });

    test("onCompletionDateSubmitted2 null clears completion date", () {
      vm.onCompletionDateSubmitted2(null);

      expect(vm.contract.expectedCompletionDate, isNull);
      expect(vm.completionDateController.text, "");
      expect(vm.completionDateValidate, false);
    });

    test("onCompletionDateSubmitted2 valid end date updates tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 3, 15));

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 3, 15));
      expect(vm.completionDateController.text, "15/03/2025");
      expect(vm.contract.projectTenor, 2);
      expect(vm.projectTenorController.text, "2 Months");
      expect(vm.state.tenor, "2 Months");
      expect(vm.completionDateValidate, false);
    });

    test("onCompletionDateSubmitted2 invalid end clears fields", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 3, 10))
        ..onCompletionDateSubmitted2(DateTime(2025, 3));

      expect(vm.contract.expectedEndDate, isNull);
      expect(vm.contract.expectedCompletionDate, isNull);
      expect(vm.completionDateController.text, "");
      expect(vm.contract.projectTenor, isNull);
      expect(vm.projectTenorController.text, "");
      expect(vm.completionDateValidate, true);
    });

    test("callEndDateTenor null clears completion controller", () {
      vm.callEndDateTenor(null, const YearRules());

      expect(vm.contract.expectedCompletionDate, isNull);
      expect(vm.completionDateController.text, "");
    });

    test("callEndDateTenor valid updates controller but not tenor if false",
        () {
      vm
        ..onStartDateSubmitted2(DateTime(2025))
        ..callEndDateTenor(DateTime(2025, 2), const YearRules());

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 2));
      expect(vm.completionDateController.text, "01/02/2025");
      expect(vm.projectTenorController.text, "");
    });

    test("callEndDateTenor valid updates controller and tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025))
        ..callEndDateTenor(
          DateTime(2025, 2),
          const YearRules(),
          isFirst: true,
        );

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 2));
      expect(vm.completionDateController.text, "01/02/2025");
      expect(vm.projectTenorController.text, "1 Month");
    });

    test("end before start branch shows warning and clears tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 5, 10))
        ..callEndDateTenor(
          DateTime(2025, 5),
          const YearRules(),
          isFirst: true,
        );

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
      expect(vm.contract.projectTenor, isNull);
      expect(vm.projectTenorController.text, "");
    });

    test("onSavedTenor parses number", () {
      vm.onSavedTenor("5 months");

      expect(vm.contract.projectTenor, 5);
    });
  });

  group("simple setters and comments", () {
    test("onPaymasterNameChanged updates model and controller", () {
      vm.onPaymasterNameChanged("Boss");

      expect(vm.contract.paymasterName, "Boss");
      expect(vm.paymasterNameController.text, "Boss");
    });

    test("onContractorScopeChanged updates model and controller", () {
      vm.onContractorScopeChanged("Scope");

      expect(vm.contract.contractorScope, "Scope");
      expect(vm.contractorScopeController.text, "Scope");
    });

    test("addComment ignores empty", () {
      vm.addComment("   ");

      expect(vm.comments, isEmpty);
    });

    test("addComment adds trimmed comment and getComments returns list", () {
      vm
        ..addComment("  First  ")
        ..addComment("Second");

      expect(vm.getComments().length, 2);
      expect(vm.getComments().first.text, "First");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("borrower search", () {
    test("success preferredName branch", () async {
      vm
        ..searchNameController.text = "Acme"
        ..searchRimController.text = "123";

      when(
        () => mockProjectRepository.getProjectBorrowerSearch(
          customerName: any(named: "customerName"),
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenAnswer(
        (_) async => [
          Customer()
            ..preferredName = "Preferred"
            ..firstName = "Display"
            ..customerRimNo = 999
            ..applicationRefNo = "APP-999",
        ],
      );

      await vm.onBorrowerOnPressed();

      expect(vm.borrowerCustomer.length, 1);
      expect(vm.customerNameController.text, "Preferred");
      expect(vm.customerRimController.text, "999");
      expect(vm.custName, "Preferred");
      expect(vm.custRimNo, "999");
      expect(vm.borrowerAppRefNo, "APP-999");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success fallback branch when preferredName is null", () async {
      vm
        ..searchNameController.text = "Beta"
        ..searchRimController.text = "777";

      when(
        () => mockProjectRepository.getProjectBorrowerSearch(
          customerName: any(named: "customerName"),
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenAnswer(
        (_) async => [
          Customer()
            ..preferredName = null
            ..firstName = "Display Only"
            ..customerRimNo = 777,
        ],
      );

      await vm.onBorrowerOnPressed();

      expect(vm.customerRimController.text, "777");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty borrower search result clears fields", () async {
      vm
        ..customerNameController.text = "Old"
        ..customerRimController.text = "Old";

      when(
        () => mockProjectRepository.getProjectBorrowerSearch(
          customerName: any(named: "customerName"),
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenAnswer((_) async => <Customer>[]);

      await vm.onBorrowerOnPressed();

      expect(vm.customerNameController.text, "");
      expect(vm.customerRimController.text, "");
      expect(vm.custName, "");
      expect(vm.custRimNo, "");
      expect(vm.borrowerAppRefNo, "");
    });

    test("failure shows toast and emits loaded", () async {
      when(
        () => mockProjectRepository.getProjectBorrowerSearch(
          customerName: any(named: "customerName"),
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenThrow(Exception("search failed"));

      await vm.onBorrowerOnPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("borrower role", () {
    test("main contractor sets paymaster", () {
      vm.project = Project()..projectUltimateOwnerName = "BIG BOSS";

      //
      // ignore: cascade_invocations
      vm.onBorrowerRoleSelected(
        Reference(id: ServerConstants.mainContractorId, name: "Main"),
      );

      expect(vm.selectedBorrowerRole?.name, "Main");
      expect(vm.contract.borrowerRole, "Main");
      expect(vm.contract.isMainContractor, true);
      expect(vm.contract.paymasterName, "BIG BOSS");
      expect(vm.paymasterNameController.text, "BIG BOSS");
    });

    test("sub contractor clears paymaster", () {
      vm
        ..paymasterNameController.text = "Old"
        ..contract.paymasterName = "Old"
        ..onBorrowerRoleSelected(Reference(id: 999, name: "Sub"));

      expect(vm.contract.borrowerRole, "Sub");
      expect(vm.contract.isMainContractor, false);
      expect(vm.contract.paymasterName, "");
      expect(vm.paymasterNameController.text, "");
    });
  });

  group("onSave", () {
    testWidgets("empty rim and name shows toast and returns", (tester) async {
      await pumpForm(tester, formKey: vm.formKey);

      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "";

      await vm.onSave(MockBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(() => mockProjectRepository.saveLinkContractDetails(any()));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("invalid form returns loaded", (tester) async {
      await pumpForm(tester, formKey: vm.formKey, valid: false);

      vm
        ..searchRimController.text = "100"
        ..searchNameController.text = "Name";

      await vm.onSave(MockBuildContext());

      verifyNever(() => mockProjectRepository.saveLinkContractDetails(any()));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("invalid dates set completionDateValidate true", (
      tester,
    ) async {
      await pumpForm(tester, formKey: vm.formKey);

      vm
        ..searchRimController.text = "100"
        ..searchNameController.text = "Name"
        ..onStartDateSubmitted2(DateTime(2025, 6, 10))
        ..callEndDateTenor(DateTime(2025, 6), const YearRules());

      await vm.onSave(MockBuildContext());

      expect(vm.completionDateValidate, true);
      verifyNever(() => mockProjectRepository.saveLinkContractDetails(any()));
    });

    testWidgets("legacy completionDateValidate true shows warning", (
      tester,
    ) async {
      await pumpForm(tester, formKey: vm.formKey);

      vm
        ..searchRimController.text = "101"
        ..searchNameController.text = "Name"
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2))
        ..completionDateValidate = true;

      await vm.onSave(MockBuildContext());

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
      verifyNever(() => mockProjectRepository.saveLinkContractDetails(any()));
    });

    testWidgets("success isCreate false saves and shows success toast", (
      tester,
    ) async {
      await pumpForm(tester, formKey: vm.formKey);

      vm
        ..searchRimController.text = "555"
        ..searchNameController.text = "Gamma Ltd"
        ..borrowerAppRefNo = "APP-BORROWER"
        ..project = (Project()
          ..projectId = 10
          ..projectCode = "P-10"
          ..projectName = "Project 10")
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2));

      when(() => mockProjectRepository.saveLinkContractDetails(any()))
          .thenAnswer((_) async => "CON-777");

      await vm.onSave(MockBuildContext());

      verify(() => mockProjectRepository.saveLinkContractDetails(any()))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);

      expect(vm.contract.contractCode, "CON-777");
      expect(vm.contract.rimNo, "555");
      expect(vm.contract.customerRimNo, 555);
      expect(vm.contract.customerName, "Gamma Ltd");
      expect(vm.contract.projectId, "10");
      expect(vm.contract.projectCode, "P-10");
      expect(vm.contract.projectName, "Project 10");
      expect(vm.contract.appReffNo, "APP-BORROWER");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("success isCreate true schedules dialog branch", (
      tester,
    ) async {
      final BuildContext context = await pumpContextWithForm(
        tester,
        formKey: vm.formKey,
      );

      vm
        ..searchRimController.text = "777"
        ..searchNameController.text = "Create Ltd"
        ..project = (Project()
          ..projectId = 20
          ..projectCode = "P-20"
          ..projectName = "Project 20")
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2));

      when(() => mockProjectRepository.saveLinkContractDetails(any()))
          .thenAnswer((_) async => "CON-CREATE");

      await vm.onSave(context, isCreate: true);
      await tester.pump();

      expect(vm.contract.contractCode, "CON-CREATE");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("success uses fallback customer details", (tester) async {
      await pumpForm(tester, formKey: vm.formKey);

      vm
        ..searchRimController.text = ""
        ..searchNameController.text = "Fallback Name"
        ..custRimNo = "222"
        ..custName = "Fallback Name"
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2));

      when(() => mockProjectRepository.saveLinkContractDetails(any()))
          .thenAnswer((_) async => "CON-888");

      await vm.onSave(MockBuildContext());

      expect(vm.contract.customerRimNo, 222);
      expect(vm.contract.customerName, "Fallback Name");
    });

    testWidgets("repository throws shows failure toast", (tester) async {
      await pumpForm(tester, formKey: vm.formKey);

      vm
        ..searchRimController.text = "9"
        ..searchNameController.text = "Zeta"
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2));

      when(() => mockProjectRepository.saveLinkContractDetails(any()))
          .thenThrow(Exception("save failed"));

      await vm.onSave(MockBuildContext() as BuildContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("back and access checks", () {
    test("onBacktoRequestStatusPressed calls discard safely", () async {
      await vm.onBacktoRequestStatusPressed(MockBuildContext());

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("editAccessRolesCheck and viewAccessRolesCheck return bool", () {
      expect(vm.editAccessRolesCheck(), isA<bool>());
      expect(vm.viewAccessRolesCheck(), isA<bool>());
    });
  });
}
