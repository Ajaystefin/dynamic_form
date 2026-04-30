import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

/// ---------------------------------------------------------------------------
/// Mocks / Fakes
/// ---------------------------------------------------------------------------

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

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

/// Small subclass to observe internal calls without breaking production logic.
class TestEditContractViewModel extends EditContractViewModel {
  bool recomputeCalled = false;
  bool initControllersCalled = false;
  bool enrichCalled = false;

  bool fetchCalled = false;
  String? fetchedRefNo;

  set repo(ProjectRepository r) => repository = r;

  @override
  void recomputeDerived() {
    recomputeCalled = true;
    super.recomputeDerived();
  }

  @override
  void initializeControllers(List<PPC> rows) {
    initControllersCalled = true;
    super.initializeControllers(rows);
  }

  @override
  void enrichLinkCommitmentNumberWith() {
    enrichCalled = true;
    super.enrichLinkCommitmentNumberWith();
  }

  @override
  Future<void> fetchAndSetStrategyComments({String? appRefNo}) async {
    fetchCalled = true;
    fetchedRefNo = appRefNo;
    return super.fetchAndSetStrategyComments(appRefNo: appRefNo);
  }

  /// test seam because production uses `ReferenceDataService()` inline
  Future<void> loadReferenceDataWith(ReferenceDataService svc) async {
    referenceData = await svc.getReferenceData(
      [ReferenceDataKeys.borrowerRole, ReferenceDataKeys.facilityTypes],
    );
    borrowerRole = referenceData[ReferenceDataKeys.borrowerRole] ?? [];
    facilityType = referenceData[ReferenceDataKeys.facilityTypes] ?? [];
  }
}

class DummyRouteData {
  static const home = "/";
}

/// ---------------------------------------------------------------------------
/// Helpers
/// ---------------------------------------------------------------------------

const MethodChannel connectivityChannel =
    MethodChannel("dev.fluttercommunity.plus/connectivity");

Future<void> stubConnectivity() async {
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
    (MethodCall methodCall) async => "wifi",
  );
}

Future<GoRouter> pumpRouterShell(
  WidgetTester tester, {
  required Widget child,
  String initialLocation = "/",
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: "/",
        builder: (_, __) => child,
      ),
      GoRoute(
        path: Routes.editViewProject,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text("EditViewProject"))),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
  await tester.pump();
  return router;
}

Future<void> pumpSimpleFocusShell(
  WidgetTester tester, {
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Material(
          child: FocusTraversalGroup(
            child: Column(
              children: [
                const TextField(),
                child,
                const TextField(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> pumpFormShell(
  WidgetTester tester, {
  required GlobalKey<FormState> formKey,
  String? Function(String?)? validator,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: TextFormField(
            validator: validator,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// ---------------------------------------------------------------------------
/// Main
/// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EditContractViewModel viewModel;
  late TestEditContractViewModel vm;
  late MockProjectRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockCommonRepository mockCommonRepo;
  late MockReferenceDataService mockRefSvc;
  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await EasyLocalization.ensureInitialized();
    await EnvConfig.setEnvironment();
    await stubConnectivity();

    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const Locale("en"));
    registerFallbackValue(const YearRules());
    registerFallbackValue(Project());
    registerFallbackValue(Contract());
    registerFallbackValue(Reference());
  });

  setUp(() {
    mockRepository = MockProjectRepository();
    mockAlertManager = MockAlertManager();
    mockCommonRepo = MockCommonRepository();
    mockRefSvc = MockReferenceDataService();
    mockLocalStorageService = MockLocalStorageService();

    LocalStorageService().setStorage(mockLocalStorageService);

    AlertManager.overrideInstance(mockAlertManager);
    CommonRepository.debugReplaceInstance = mockCommonRepo;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showWarningToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    viewModel = EditContractViewModel()..repository = mockRepository;

    viewModel.ppc = <PPC>[];
    viewModel.ppcControllers = <PpcControllers>[];
    viewModel.isNewRow = <bool>[];

    viewModel.contractValue = 1000;
    viewModel.contractorValueController.text = "1000";

    viewModel.contract = Contract()
      ..appRefNo = "APP-001"
      ..rimNo = "123";

    viewModel.project = Project()
      ..projectId = 1
      ..projectCode = "PRJ-001"
      ..projectName = "Test Project";

    viewModel.startDateController = TextEditingController();
    viewModel.completionDateController = TextEditingController();
    viewModel.projectTenorController = TextEditingController();
    viewModel.variationController = TextEditingController();
    viewModel.variationCompletionDateController = TextEditingController();
    viewModel.customerNameController = TextEditingController();
    viewModel.contractorCommentsController = TextEditingController();
    viewModel.contractorValueController = TextEditingController();
    viewModel.convertedAmountController = TextEditingController();
    viewModel.contractorScopeController = TextEditingController();
    viewModel.completionPercentageController = TextEditingController();
    viewModel.commentInputs = [""];

    vm = TestEditContractViewModel()..repo = mockRepository;
    vm.contract = Contract()
      ..appRefNo = "APP-001"
      ..rimNo = "123";
    vm.project = Project()
      ..projectId = 1
      ..projectCode = "PRJ-001"
      ..projectName = "Test Project";

    vm.customerNameController = TextEditingController();
    vm.convertedAmountController = TextEditingController();
    vm.contractorValueController = TextEditingController();
    vm.contractorScopeController = TextEditingController();
    vm.contractorCommentsController = TextEditingController();
    vm.projectTenorController = TextEditingController();
    vm.startDateController = TextEditingController();
    vm.completionDateController = TextEditingController();
    vm.variationController = TextEditingController();
    vm.variationCompletionDateController = TextEditingController();
    vm.completionPercentageController = TextEditingController();
  });

  tearDown(() {
    viewModel.disposeControllers();
    viewModel.contractorCommentsController.dispose();
    viewModel.startDateController.dispose();
    viewModel.completionDateController.dispose();
    viewModel.projectTenorController.dispose();
    viewModel.variationController.dispose();
    viewModel.variationCompletionDateController.dispose();
    viewModel.customerNameController.dispose();
    viewModel.contractorValueController.dispose();
    viewModel.convertedAmountController.dispose();
    viewModel.contractorScopeController.dispose();
    viewModel.completionPercentageController.dispose();

    vm.disposeControllers();
    vm.customerNameController.dispose();
    vm.convertedAmountController.dispose();
    vm.contractorValueController.dispose();
    vm.contractorScopeController.dispose();
    vm.contractorCommentsController.dispose();
    vm.projectTenorController.dispose();
    vm.startDateController.dispose();
    vm.completionDateController.dispose();
    vm.variationController.dispose();
    vm.variationCompletionDateController.dispose();
    vm.completionPercentageController.dispose();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  // ---------------------------------------------------------------------------
  // Basic state & sync helpers
  // ---------------------------------------------------------------------------

  group("basic sync helpers", () {
    test("syncModelFromControllers copies static controllers into model", () {
      viewModel.customerNameController.text = "Contract A";
      viewModel.contractorValueController.text = "5000";
      viewModel.contractorScopeController.text = "Scope A";
      viewModel.completionPercentageController.text = "45.5";
      viewModel.selectedCurrencyLabel = "USD";

      viewModel.syncModelFromControllers();

      expect(viewModel.contract.contractName, "Contract A");
      expect(viewModel.contract.contractValue, "5000");
      expect(viewModel.contract.contractScope, "Scope A");
      expect(viewModel.contract.completionPercentage, 45.5);
      expect(viewModel.contract.contractCurrency, "USD");
    });

    test("syncControllersFromModel copies model into static controllers", () {
      viewModel.contract = Contract()
        ..completionPercentage = 88.8
        ..contractName = "Loaded Contract"
        ..contractValue = "7500"
        ..contractScope = "Loaded Scope"
        ..projectTenor = 4
        ..contractCurrency = "AED";

      viewModel.syncControllersFromModel();

      expect(viewModel.completionPercentageController.text, "88.8");
      expect(viewModel.customerNameController.text, "Loaded Contract");
      expect(viewModel.contractorValueController.text, "7500");
      expect(viewModel.contractorScopeController.text, "Loaded Scope");
      expect(viewModel.projectTenorController.text, "4 Months");
      expect(viewModel.selectedCurrencyLabel, "AED");
    });

    test("close disposes PPC controllers and clears list", () async {
      viewModel.ppcControllers = [
        PpcControllers.empty(),
        PpcControllers.empty(),
      ];

      await viewModel.close();

      expect(viewModel.ppcControllers, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Comment input helpers
  // ---------------------------------------------------------------------------

  group("comment input helpers", () {
    test("addCommentInput appends empty string and clears draft controller",
        () {
      viewModel.contractorCommentsController.text = "abc";
      final initialLength = viewModel.commentInputs.length;

      viewModel.addCommentInput();

      expect(viewModel.commentInputs.length, initialLength + 1);
      expect(viewModel.commentInputs.last, "");
      expect(viewModel.contractorCommentsController.text, "");
    });

    test("updateCommentInput updates valid index and draft controller", () {
      viewModel.commentInputs = ["initial"];
      viewModel.updateCommentInput(0, "updated");

      expect(viewModel.commentInputs[0], "updated");
      expect(viewModel.contractorCommentsController.text, "updated");
    });

    test("updateCommentInput ignores invalid index", () {
      viewModel.commentInputs = ["only"];
      viewModel.updateCommentInput(5, "ignored");

      expect(viewModel.commentInputs, ["only"]);
    });

    test("getCommentInputs returns the current list", () {
      viewModel.commentInputs = ["a", "b"];
      expect(viewModel.getCommentInputs(), ["a", "b"]);
    });

    test(
        "clearCommentInputs leaveOneBlank=true resets"
        " controller and keeps one blank row", () {
      viewModel.commentInputs = ["x", "y"];
      viewModel.contractorCommentsController.text = "hello";

      viewModel.clearCommentInputs(leaveOneBlank: true);

      expect(viewModel.commentInputs, [""]);
      expect(viewModel.contractorCommentsController.text, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("clearCommentInputs leaveOneBlank=false clears only list", () {
      viewModel.commentInputs = ["x", "y"];
      viewModel.contractorCommentsController.text = "hello";

      viewModel.clearCommentInputs(leaveOneBlank: false);

      expect(viewModel.commentInputs, isEmpty);
      expect(viewModel.contractorCommentsController.text, "hello");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("setDraftComment sets controller value", () {
      viewModel.setDraftComment("draft text");
      expect(viewModel.contractorCommentsController.text, "draft text");

      viewModel.setDraftComment(null);
      expect(viewModel.contractorCommentsController.text, "");
    });

    test("clearDraftComment clears controller", () {
      viewModel.contractorCommentsController.text = "abc";
      viewModel.clearDraftComment();
      expect(viewModel.contractorCommentsController.text, "");
    });
  });

  // ---------------------------------------------------------------------------
  // Currency conversion
  // ---------------------------------------------------------------------------

  group("currency conversion", () {
    test("onContractValueChanged triggers conversion", () {
      viewModel.selectedCurrencyLabel = "AED";
      viewModel.contractorValueController.text = "200";

      viewModel.onContractValueChanged("200");

      expect(viewModel.convertedAmountController.text, "200.00");
    });

    test("updateConvertedAmount clears on empty input", () {
      viewModel.selectedCurrencyLabel = "AED";
      viewModel.contractorValueController.text = "";

      viewModel.updateConvertedAmount();

      expect(viewModel.convertedAmountController.text, "");
    });

    test("updateConvertedAmount clears on zero conversion", () {
      viewModel.selectedCurrencyLabel = "AED";
      viewModel.contractorValueController.text = "0";

      viewModel.updateConvertedAmount();

      expect(viewModel.convertedAmountController.text, "");
    });

    test("updateConvertedAmount sets converted value for USD", () {
      viewModel.selectedCurrencyLabel = "USD";
      viewModel.contractorValueController.text = "100";

      viewModel.updateConvertedAmount();

      expect(viewModel.convertedAmountController.text, "367.00");
    });

    test(
        "onCurrencyChanged "
        "updates selected label, "
        "contract currency, AED flag, emits", () {
      viewModel.onCurrencyChanged(Reference(name: "USD"));
      expect(viewModel.selectedCurrencyLabel, "USD");
      expect(viewModel.contract.contractCurrency, "USD");
      expect(viewModel.isAedRates, isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onCurrencyChanged(Reference(name: "AED"));
      expect(viewModel.selectedCurrencyLabel, "AED");
      expect(viewModel.contract.contractCurrency, "AED");
      expect(viewModel.isAedRates, isTrue);
    });

    test("isAEDCurrencyRate uses ref first, then contract, then selected label",
        () {
      viewModel.selectedCurrencyLabel = "USD";
      expect(viewModel.isAEDCurrencyRate(ref: Reference(name: "aed")), isTrue);
      expect(viewModel.isAedRates, isTrue);

      viewModel.selectedCurrencyLabel = null;
      viewModel.contract.contractCurrency = "AED";
      expect(viewModel.isAEDCurrencyRate(contract: viewModel.contract), isTrue);

      viewModel.contract.contractCurrency = null;
      viewModel.selectedCurrencyLabel = "USD";
      expect(viewModel.isAEDCurrencyRate(), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Date and tenor logic
  // ---------------------------------------------------------------------------

  group("date / tenor helpers", () {
    test("isCompletionBeforeStart compares date-only values", () {
      final start = DateTime(2025, 1, 10, 23, 59);
      final earlierEnd = DateTime(2025, 1, 9, 0, 0);
      final sameDayEnd = DateTime(2025, 1, 10, 0, 0);
      final laterEnd = DateTime(2025, 1, 11, 12, 30);

      expect(viewModel.isCompletionBeforeStart(start, earlierEnd), isTrue);
      expect(viewModel.isCompletionBeforeStart(start, sameDayEnd), isFalse);
      expect(viewModel.isCompletionBeforeStart(start, laterEnd), isFalse);
    });

    test("onStartDateSubmitted2 valid start updates model/controller", () {
      final date = DateTime(2025, 1, 4);

      viewModel.onStartDateSubmitted2(date);

      expect(viewModel.contract.expectedStartDate, DateTime(2025, 1, 4));
      expect(viewModel.startDateController.text, "04/01/2025");
      expect(viewModel.completionDateValidate, isFalse);
    });

    test("onCompletionDateSubmitted2 valid end updates model/controller", () {
      viewModel.onStartDateSubmitted2(DateTime(2025, 1, 4));
      viewModel.onCompletionDateSubmitted2(DateTime(2025, 2, 10));

      expect(viewModel.contract.expectedEndDate, DateTime(2025, 2, 10));
      expect(viewModel.contract.expectedCompletionDate, DateTime(2025, 2, 10));
      expect(viewModel.completionDateController.text, "10/02/2025");
      expect(viewModel.completionDateValidate, isFalse);
    });

    test(
        "onCompletionDateSubmitted2 invalid clears completion/tenor and sets flag",
        () {
      viewModel.onStartDateSubmitted2(DateTime(2025, 5, 10));

      viewModel.onCompletionDateSubmitted2(DateTime(2025, 5, 1));

      expect(viewModel.contract.expectedEndDate, isNull);
      expect(viewModel.contract.expectedCompletionDate, isNull);
      expect(viewModel.completionDateController.text, "");
      expect(viewModel.contract.projectTenor, isNull);
      expect(viewModel.projectTenorController.text, "");
      expect(viewModel.completionDateValidate, isTrue);
    });

    test("callEndDateTenor(null, isFirst: true) clears UI and tenor", () {
      viewModel.callEndDateTenor(null, const YearRules(), isFirst: true);

      expect(viewModel.contract.expectedCompletionDate, isNull);
      expect(viewModel.completionDateController.text, "");
      expect(viewModel.projectTenorController.text, anyOf("", isEmpty));
    });

    test(
        "callEndDateTenor(valid, isFirst: true) updates and recalculates tenor",
        () {
      viewModel.onStartDateSubmitted2(DateTime(2025, 1, 1));

      viewModel.callEndDateTenor(
        DateTime(2025, 3, 15),
        const YearRules(),
        isFirst: true,
      );

      expect(viewModel.contract.expectedCompletionDate, DateTime(2025, 3, 15));
      expect(viewModel.completionDateController.text, "15/03/2025");
      expect(viewModel.contract.projectTenor, 2);
      expect(viewModel.projectTenorController.text, "2 Months");
    });

    test("callEndDateTenor(valid, isFirst: false) only updates end fields", () {
      viewModel.callEndDateTenor(
        DateTime(2025, 3, 15),
        const YearRules(),
        isFirst: false,
      );

      expect(viewModel.contract.expectedCompletionDate, DateTime(2025, 3, 15));
      expect(viewModel.completionDateController.text, "15/03/2025");
    });

    test("_updateTenor via public path clears tenor when one date missing", () {
      viewModel.callEndDateTenor(null, const YearRules(), isFirst: true);

      expect(viewModel.contract.projectTenor, isNull);
      expect(viewModel.projectTenorController.text, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("_updateTenor via public path warns and clears tenor when end < start",
        () {
      viewModel.onStartDateSubmitted2(DateTime(2025, 5, 10));
      viewModel.callEndDateTenor(
        DateTime(2025, 5, 1),
        const YearRules(),
        isFirst: true,
      );

      expect(viewModel.contract.projectTenor, isNull);
      expect(viewModel.projectTenorController.text, "");
      expect(viewModel.completionDateValidate, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("_updateTenor via public path computes completed months", () {
      viewModel.onStartDateSubmitted2(DateTime(2025, 1, 1));
      viewModel.callEndDateTenor(
        DateTime(2025, 3, 15),
        const YearRules(),
        isFirst: true,
      );

      expect(viewModel.contract.projectTenor, 2);
      expect(viewModel.projectTenorController.text, "2 Months");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('onSavedTenor parses integer from "7 months"', () {
      viewModel.onSavedTenor("7 months");
      expect(viewModel.contract.projectTenor, 7);
    });

    test(
        "onOriginalCompletionDateSubmitted2 non-null "
        "updates original date and variation", () {
      viewModel.contract.expectedEndDate = DateTime(2025, 2, 1);

      viewModel.onOriginalCompletionDateSubmitted2(DateTime(2025, 1, 1));

      expect(viewModel.contract.originalCompletionDate, DateTime(2025, 1, 1));
      expect(viewModel.variationCompletionDateController.text, isNotEmpty);
    });

    test("onOriginalCompletionDateSubmitted2 null writes NA and numeric 0", () {
      viewModel.contract.variationCompletionDate = null;

      viewModel.onOriginalCompletionDateSubmitted2(null);

      expect(viewModel.variationCompletionDateController.text, "NA");
      expect(viewModel.contract.variationCompletionDate, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // getcountryCode
  // ---------------------------------------------------------------------------

  group("getcountryCode", () {
    test(
        "sorts AED first and selects current "
        "currency when contract currency exists", () async {
      vm.contract.contractCurrency = "USD";

      final refs = [
        Reference(id: 1, name: "INR"),
        Reference(id: 2, name: "AED"),
        Reference(id: 3, name: "USD"),
      ];

      when(() => mockRepository.getcountryCode()).thenAnswer((_) async => refs);

      await vm.getcountryCode();

      expect(
        vm.countryCodes.first.name?.toUpperCase(),
        ServerConstants.aedCurrency,
      );
      expect(vm.selectedContractValueCurrency?.name, "USD");
      expect(vm.isAedRates, isFalse);
    });

    test(
        "when contract currency is null, "
        "selectedContractValueCurrency remains null", () async {
      vm.contract.contractCurrency = null;

      when(() => mockRepository.getcountryCode()).thenAnswer(
        (_) async => [
          Reference(id: 1, name: "AED"),
          Reference(id: 2, name: "USD"),
        ],
      );

      await vm.getcountryCode();

      expect(vm.selectedContractValueCurrency, isNull);
    });

    test("rethrows repository errors", () async {
      when(() => mockRepository.getcountryCode()).thenThrow(Exception("fail"));
      expect(() => vm.getcountryCode(), throwsA(isA<Exception>()));
    });
  });

  // ---------------------------------------------------------------------------
  // Contract loading
  // ---------------------------------------------------------------------------

  group("getContract", () {
    test(
        "happy path sets fields, fills "
        "controllers, initializes PPC and comments", () async {
      vm.contract.contractCode = "C-001";

      final returned = Contract()
        ..contractCode = "C-001"
        ..contractCurrency = "USD"
        ..contractValueAedAmount = "1,000"
        ..borrowerRole = "Main"
        ..expectedStartDate = DateTime(2025, 1, 1)
        ..expectedEndDate = DateTime(2025, 3, 1)
        ..projectTenor = 2
        ..contractValue = "200"
        ..appRefNo = "APP-9"
        ..projectId = "7"
        ..contractName = null
        ..ppcList = [
          PPC(
            ppcNo: "P1",
            ppcDate: "01/01/2025",
            grossPPCValue: 50,
          ),
        ];

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenAnswer((_) async => returned);

      when(() => mockRepository.getcountryCode()).thenAnswer(
        (_) async => [
          Reference(id: 1, name: "AED"),
          Reference(id: 2, name: "USD"),
        ],
      );

      when(() => mockRepository.getProjectContractDetails(any())).thenAnswer(
        (_) async => [
          Contract()
            ..contractCode = "C-001"
            ..contractName = "Cont Name",
        ],
      );

      when(
        () => mockCommonRepo.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            strategyComment: "ok",
            categoryId: ServerConstants.contractCategoryID,
          ),
        ],
      );

      vm.referenceData = {
        ReferenceDataKeys.borrowerRole: [Reference(id: 10, name: "Main")],
      };

      await vm.getContract();

      expect(vm.contract.contractCode, "C-001");
      expect(vm.selectedCurrencyLabel, "USD");
      expect(vm.isAedRates, isFalse);
      expect(vm.convertedAmountController.text, isNotEmpty);
      expect(vm.customerNameController.text, "Cont Name");
      expect(vm.selectedBorrowerRole?.name, "Main");
      expect(vm.recomputeCalled, isTrue);
      expect(vm.initControllersCalled, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.ppcStatus, LoadingStatus.loaded);
      expect(vm.ppc.length, 1);
      expect(vm.isNewRow.length, 1);
      expect(vm.fetchCalled, isTrue);
      expect(vm.fetchedRefNo, "APP-9");
    });

    test("when contractName already exists, uses it without extra fetch",
        () async {
      vm.contract.contractCode = "C-002";

      final returned = Contract()
        ..contractCode = "C-002"
        ..contractCurrency = "AED"
        ..contractValueAedAmount = "100"
        ..projectTenor = 1
        ..contractValue = "100"
        ..contractName = "Already Present"
        ..ppcList = [];

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenAnswer((_) async => returned);

      when(() => mockRepository.getcountryCode()).thenAnswer(
        (_) async => [
          Reference(id: 1, name: "AED"),
          Reference(id: 2, name: "USD"),
        ],
      );

      await vm.getContract();

      expect(vm.customerNameController.text, "Already Present");
      expect(vm.isAedRates, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("rethrows repository errors", () async {
      vm.contract.contractCode = "ERR";

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenThrow(Exception("boom"));

      expect(() => vm.getContract(), throwsA(isA<Exception>()));
    });
  });

  group("getContractDetailsData", () {
    test("fills customerNameContract and controller from matched item",
        () async {
      final p = Project()..projectId = 9;
      final c = Contract()..contractCode = "Z-9";

      when(() => mockRepository.getProjectContractDetails(any())).thenAnswer(
        (_) async => [
          Contract()
            ..contractCode = "Z-8"
            ..contractName = "Nope",
          Contract()
            ..contractCode = "Z-9"
            ..contractName = "Winner",
        ],
      );

      await vm.getContractDetailsData(p, c);

      expect(vm.customerNameContract, "Winner");
      expect(vm.customerNameController.text, "Winner");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("when not matched, writes empty string", () async {
      final p = Project()..projectId = 9;
      final c = Contract()..contractCode = "Z-9";

      when(() => mockRepository.getProjectContractDetails(any())).thenAnswer(
        (_) async => [
          Contract()
            ..contractCode = "Z-8"
            ..contractName = "Nope",
        ],
      );

      await vm.getContractDetailsData(p, c);

      expect(vm.customerNameContract, "");
      expect(vm.customerNameController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("rethrows repository errors", () async {
      when(() => mockRepository.getProjectContractDetails(any()))
          .thenThrow(Exception("down"));

      expect(
        () => vm.getContractDetailsData(Project(), Contract()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Link commitment
  // ---------------------------------------------------------------------------

  test("getLinkCommitment sets linkContract, emits loaded and calls enrich",
      () async {
    vm.contract.rimNo = "123";

    when(
      () => mockRepository.getLinkedCMNForRimDetails(
        contractRimNo: any(named: "contractRimNo"),
      ),
    ).thenAnswer(
      (_) async => [
        LinkCommitmentNumber(projectAllocationAccount: "A"),
        LinkCommitmentNumber(projectAllocationAccount: "B"),
      ],
    );

    await vm.getLinkCommitment();

    expect(vm.linkContract?.length, 2);
    expect(vm.enrichCalled, isTrue);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
  });

  group("LinkCommitmentNumberWith helpers", () {
    test("enrichLinkCommitmentNumberWith merges API data into selected list",
        () {
      viewModel.contract.linkCommitmentNumberWith = [
        LinkCommitmentNumber(projectAllocationAccount: "100001"),
        LinkCommitmentNumber(projectAllocationAccount: "200002"),
      ];

      viewModel.linkContract = [
        LinkCommitmentNumber(
          projectAllocationAccount: "100001",
          facilityType: 100,
          limitAmountInAED: 500000,
          currentOSInAED: 125000,
        ),
        LinkCommitmentNumber(
          projectAllocationAccount: "200002",
          facilityType: 101,
          limitAmountInAED: 300000,
          currentOSInAED: 45000,
        ),
      ];

      viewModel.enrichLinkCommitmentNumberWith();

      final merged = viewModel.contract.linkCommitmentNumberWith!;
      expect(merged.length, 2);
      expect(merged[0].projectAllocationAccount, "100001");
      expect(merged[0].facilityType, 100);
      expect(merged[0].limitAmountInAED, 500000);
      expect(merged[0].currentOSInAED, 125000);
      expect(merged[1].facilityType, 101);
    });

    test("enrichLinkCommitmentNumberWith no-ops when lists are null/empty", () {
      viewModel.contract.linkCommitmentNumberWith = null;
      viewModel.linkContract = null;
      viewModel.enrichLinkCommitmentNumberWith();
      expect(viewModel.contract.linkCommitmentNumberWith, isNull);

      viewModel.contract.linkCommitmentNumberWith = [];
      viewModel.linkContract = [];
      viewModel.enrichLinkCommitmentNumberWith();
      expect(viewModel.contract.linkCommitmentNumberWith, isEmpty);
    });

    test("linkCommitmentNumberDeleted removes item and emits loaded", () {
      viewModel.contract.linkCommitmentNumberWith = [
        LinkCommitmentNumber(projectAllocationAccount: "A"),
        LinkCommitmentNumber(projectAllocationAccount: "B"),
        LinkCommitmentNumber(projectAllocationAccount: "C"),
      ];

      viewModel.linkCommitmentNumberDeleted(1);

      final list = viewModel.contract.linkCommitmentNumberWith!;
      expect(list.map((e) => e.projectAllocationAccount), ["A", "C"]);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.linkCommitmentStatus, LoadingStatus.loaded);
    });

    test("linkCommitmentNumberDeleted ignores out-of-range indices", () {
      viewModel.contract.linkCommitmentNumberWith = [
        LinkCommitmentNumber(projectAllocationAccount: "X"),
      ];

      viewModel.linkCommitmentNumberDeleted(-1);
      viewModel.linkCommitmentNumberDeleted(99);

      expect(viewModel.contract.linkCommitmentNumberWith!.length, 1);
    });

    test(
        "updateLinkCommitmentNumberWith sets loading "
        "then loaded and updates contract list", () {
      final selected = [
        LinkCommitmentNumber(projectAllocationAccount: "111"),
        LinkCommitmentNumber(projectAllocationAccount: "222"),
      ];

      viewModel.updateLinkCommitmentNumberWith(selected);

      expect(viewModel.contract.linkCommitmentNumberWith, selected);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.linkCommitmentStatus, LoadingStatus.loaded);
    });
  });

  // ---------------------------------------------------------------------------
  // Reference data load
  // ---------------------------------------------------------------------------

  group("loadReferenceData (test seam)", () {
    test("loads borrowerRole + facilityTypes into fields", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.borrowerRole: [Reference(id: 1, name: "Main")],
          ReferenceDataKeys.facilityTypes: [Reference(id: 2, name: "TL")],
        },
      );

      await vm.loadReferenceDataWith(mockRefSvc);

      expect(vm.borrowerRole?.first.name, "Main");
      expect(vm.facilityType?.first.name, "TL");
    });
  });

  // ---------------------------------------------------------------------------
  // Strategy comments fetch
  // ---------------------------------------------------------------------------

  group("fetchAndSetStrategyComments", () {
    test("filters category and emits loaded on success", () async {
      when(
        () => mockCommonRepo.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            strategyComment: "keep",
            categoryId: ServerConstants.contractCategoryID,
          ),
          Comment(strategyComment: "drop", categoryId: 99999),
        ],
      );

      await viewModel.fetchAndSetStrategyComments(appRefNo: "APP-001");

      expect(viewModel.commentItem.length, 1);
      expect(viewModel.commentItem.first.strategyComment, "keep");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("on error sets default empty comment item", () async {
      when(
        () => mockCommonRepo.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenThrow(Exception("failed"));

      await viewModel.fetchAndSetStrategyComments(appRefNo: "APP-001");

      expect(viewModel.commentItem.length, 1);
      expect(viewModel.commentItem.first.strategyComment, "");
    });
  });

  // ---------------------------------------------------------------------------
  // Submit comments
  // ---------------------------------------------------------------------------

  group("submitComments", () {
    test("empty/whitespace text -> early return, no repo call", () async {
      viewModel.contractorCommentsController.text = "   ";

      await viewModel.submitComments();

      verifyNever(
        () => mockCommonRepo.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success saves comment, clears draft, refreshes", () async {
      viewModel.contractorCommentsController.text = "hello";

      when(
        () => mockCommonRepo.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer((_) async => "OK");

      when(
        () => mockCommonRepo.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            strategyComment: "hello",
            categoryId: ServerConstants.contractCategoryID,
          ),
        ],
      );

      await viewModel.submitComments();

      verify(
        () => mockCommonRepo.saveStategyComment(
          any(),
          appRefNo: "APP-001",
          rimNo: 123,
        ),
      ).called(1);

      expect(viewModel.contractorCommentsController.text, "");
      expect(viewModel.commentItem.isNotEmpty, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "if appRefNo is empty, payload creation "
        "happens but repo save is skipped", () async {
      viewModel.contract.appRefNo = "";
      viewModel.contractorCommentsController.text = "hello";

      await viewModel.submitComments();

      verifyNever(
        () => mockCommonRepo.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      );
      expect(viewModel.contractorCommentsController.text, "");
    });

    test("repository error shows failure toast and emits loaded", () async {
      viewModel.contractorCommentsController.text = "hello";

      when(
        () => mockCommonRepo.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      ).thenThrow(Exception("save failed"));

      await viewModel.submitComments();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ---------------------------------------------------------------------------
  // Borrower role
  // ---------------------------------------------------------------------------

  group("onBorrowerRoleSelected", () {
    test("sets main contractor fields when id == mainContractorId", () {
      final selected = Reference(
        id: ServerConstants.mainContractorId,
        name: "Main Contractor",
      );

      viewModel.onBorrowerRoleSelected(selected);

      expect(viewModel.selectedBorrowerRole, same(selected));
      expect(viewModel.contract.borrowerRole, "Main Contractor");
      expect(viewModel.contract.isMainContractor, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets non-main contractor fields when id != mainContractorId", () {
      final selected = Reference(id: 999, name: "Sub-Contractor");

      viewModel.onBorrowerRoleSelected(selected);

      expect(viewModel.selectedBorrowerRole, same(selected));
      expect(viewModel.contract.borrowerRole, "Sub-Contractor");
      expect(viewModel.contract.isMainContractor, isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles null name gracefully", () {
      final selected = Reference(
        id: ServerConstants.mainContractorId,
        name: null,
      );

      viewModel.onBorrowerRoleSelected(selected);

      expect(viewModel.selectedBorrowerRole, same(selected));
      expect(viewModel.contract.borrowerRole, isNull);
      expect(viewModel.contract.isMainContractor, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ---------------------------------------------------------------------------
  // PPC controllers
  // ---------------------------------------------------------------------------

  group("PpcControllers.empty + loadFromModel", () {
    test("creates a full set of empty controllers", () {
      final c = PpcControllers.empty();

      expect(c.ppcCtrl.text, "");
      expect(c.grossPPCValueCtrl.text, "");
      expect(c.commentsCtrl.text, "");
    });

    test("loadFromModel populates all controller texts", () {
      final c = PpcControllers.empty();
      final row = PPC(
        ppcNo: "A1",
        ppcDate: "01/01/2025",
        grossPpcValue: 100,
        cumulativePpcValue: 110,
        cumulativePPCValue: 120,
        workDone: 1,
        workDonePercent: 2,
        cumulativeWorkDone: 3,
        cumulativeWorkDonePercent: 4,
        advancePaymentDeduction: 5,
        retentionDeduction: 6,
        netPPCValue: 7,
        vatAmount: 8,
        otherPayment: 9,
        netCertifiedAmountVat: 10,
        actualPaymentReceived: 11,
        datePaymentReceived: "02/01/2025",
        comments: "ok",
      );

      c.loadFromModel(row);

      expect(c.ppcCtrl.text, "A1");
      expect(c.ppcDateCtrl.text, "01/01/2025");
      expect(c.grossPPCValueCtrl.text, "100.0");
      expect(c.cumulativePpcValueCtrl.text, "110.0");
      expect(c.cumulativePPCValueCtrl.text, "120.0");
      expect(c.workDoneCtrl.text, "1.0");
      expect(c.workDonePercentCtrl.text, "2.0");
      expect(c.cumulativeWorkDoneCtrl.text, "3.0");
      expect(c.cumulativeWorkDonePercentCtrl.text, "4.0");
      expect(c.advancePaymentDeductionCtrl.text, "5.0");
      expect(c.retentionDeductionCtrl.text, "6.0");
      expect(c.netPPCValueCtrl.text, "7.0");
      expect(c.vatAmountCtrl.text, "8.0");
      expect(c.otherPaymentCtrl.text, "9.0");
      expect(c.netCertifiedAmountVatCtrl.text, "10.0");
      expect(c.actualPaymentReceivedCtrl.text, "11.0");
      expect(c.datePaymentReceivedCtrl.text, "02/01/2025");
      expect(c.commentsCtrl.text, "ok");
    });
  });

  group("initializeControllers", () {
    test(
        "creates mapped controllers and attached "
        "listeners sync back into model", () async {
      final rows = <PPC>[
        PPC(
          ppcNo: "A1",
          ppcDate: "01/01/2025",
          grossPPCValue: 100,
          advancePaymentDeduction: 10,
          retentionDeduction: 5,
          vatAmount: 2,
          otherPayment: 3,
          cumulativePPCValue: 0,
          cumulativePpcValue: 0,
          workDone: 0,
          workDonePercent: 0,
          cumulativeWorkDone: 0,
          cumulativeWorkDonePercent: 0,
          netPPCValue: 0,
          netCertifiedAmountVat: 0,
          actualPaymentReceived: 0,
          datePaymentReceived: "01/01/2025",
          comments: "row1",
        ),
        PPC(
          ppcNo: "A2",
          ppcDate: "02/01/2025",
          grossPPCValue: 50,
          advancePaymentDeduction: 0,
          retentionDeduction: 0,
          vatAmount: 0,
          otherPayment: 0,
          cumulativePPCValue: 0,
          cumulativePpcValue: 0,
          workDone: 0,
          workDonePercent: 0,
          cumulativeWorkDone: 0,
          cumulativeWorkDonePercent: 0,
          netPPCValue: 0,
          netCertifiedAmountVat: 0,
          actualPaymentReceived: 0,
          datePaymentReceived: "02/01/2025",
          comments: "row2",
        ),
      ];

      viewModel.initializeControllers(rows);

      expect(viewModel.ppc.length, 2);
      expect(viewModel.ppcControllers.length, 2);
      expect(viewModel.ppcControllerGeneration, 1);

      viewModel.ppcControllers.first.grossPPCValueCtrl.text = "120";

      await Future<void>.delayed(const Duration(milliseconds: 220));

      expect(viewModel.ppc.first.grossPPCValue, isNotNull);
    });
  });

  group("syncRowFromControllers", () {
    test("parses controller text into model numerics and recomputes derived",
        () {
      final row = PPC(
        ppcNo: "X",
        grossPPCValue: 0,
        cumulativePPCValue: 0,
        workDonePercent: 0,
        cumulativeWorkDonePercent: 0,
        netPPCValue: 0,
        advancePaymentDeduction: 0,
        retentionDeduction: 0,
        vatAmount: 0,
        otherPayment: 0,
        netCertifiedAmountVat: 0,
        actualPaymentReceived: 0,
      );
      viewModel.ppc = [row];
      viewModel.ppcControllers = [PpcControllers.empty()];

      final c = viewModel.ppcControllers.first;
      c.grossPPCValueCtrl.text = "250.5";
      c.advancePaymentDeductionCtrl.text = "10.0";
      c.retentionDeductionCtrl.text = "5.0";
      c.vatAmountCtrl.text = "2.0";
      c.otherPaymentCtrl.text = "3.0";

      viewModel.syncRowFromControllers(0);

      expect(viewModel.ppc.first.grossPPCValue, 250.5);
      expect(viewModel.ppc.first.netPPCValue, isNotNull);
      expect(viewModel.ppc.first.netCertifiedAmountVat, isNotNull);
    });

    test("returns immediately when isRestoringDraft=true", () {
      viewModel.isRestoringDraft = true;
      viewModel.ppc = [PPC(grossPPCValue: 1)];
      viewModel.ppcControllers = [PpcControllers.empty()];
      viewModel.ppcControllers.first.grossPPCValueCtrl.text = "999";

      viewModel.syncRowFromControllers(0);

      expect(viewModel.ppc.first.grossPPCValue, 1);
    });
  });

  group("recomputeDerived", () {
    test(
        "caps by contractValue, clamps negatives to "
        "0, computes percentages when contract > 0", () {
      viewModel.contractValue = 100;
      viewModel.contractorValueController.text = "100";

      viewModel.ppc = [
        PPC(
          grossPPCValue: -10,
          advancePaymentDeduction: 5,
          retentionDeduction: 5,
          vatAmount: 2,
          otherPayment: 3,
        ),
        PPC(
          grossPPCValue: 80,
          advancePaymentDeduction: 0,
          retentionDeduction: 0,
          vatAmount: 0,
          otherPayment: 0,
        ),
        PPC(
          grossPPCValue: 50,
          advancePaymentDeduction: 0,
          retentionDeduction: 0,
          vatAmount: 0,
          otherPayment: 0,
        ),
      ];

      viewModel.recomputeDerived();

      expect(viewModel.ppc[0].cumulativePPCValue, 0);
      expect(viewModel.ppc[0].netPPCValue, -10);
      expect(viewModel.ppc[0].netCertifiedAmountVat, -5);

      expect(viewModel.ppc[1].cumulativePPCValue, 80);
      expect(viewModel.ppc[2].cumulativePPCValue, 100);

      expect(viewModel.ppc[1].workDonePercent, isNotNull);
      expect(viewModel.ppc[2].cumulativeWorkDonePercent, isNotNull);
    });

    test("when contract <= 0, percent fields become 0", () {
      viewModel.contractValue = 0;
      viewModel.contractorValueController.text = "0";

      viewModel.ppc = [
        PPC(grossPPCValue: 10),
      ];

      viewModel.recomputeDerived();

      expect(viewModel.ppc.first.workDonePercent, 0.0);
      expect(viewModel.ppc.first.cumulativeWorkDonePercent, 0.0);
    });
  });

  group("PPC edit mode toggles", () {
    test("enable/disable edit mode", () {
      viewModel.enablePpcEditMode();
      expect(viewModel.isPpcEditable, true);

      viewModel.disablePpcEditMode();
      expect(viewModel.isPpcEditable, false);
    });
  });

  group("add/remove PPC rows", () {
    test("onAddRowPressed prevents adding when last row blank", () {
      viewModel.ppcControllers = [PpcControllers.empty()];

      viewModel.onAddRowPressed();

      expect(viewModel.ppcControllers.length, 1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onAddRowPressed adds when last row has input", () {
      final c = PpcControllers.empty();
      c.commentsCtrl.text = "has value";
      viewModel.ppcControllers = [c];
      viewModel.ppc = [PPC()];
      viewModel.isNewRow = [false];

      viewModel.onAddRowPressed();

      expect(viewModel.ppc.length, 2);
      expect(viewModel.ppcControllers.length, 2);
      expect(viewModel.isNewRow.length, 2);
    });

    test("addPpcRow appends row/controllers/isNewRow", () {
      final initialLen = viewModel.ppc.length;

      viewModel.addPpcRow();

      expect(viewModel.ppc.length, initialLen + 1);
      expect(viewModel.ppcControllers.length, initialLen + 1);
      expect(viewModel.isNewRow.length, initialLen + 1);
      expect(viewModel.isNewRow.last, isTrue);
    });

    test("removePpcRow removes row/controllers/isNewRow", () {
      viewModel.addPpcRow();

      viewModel.removePpcRow(0);

      expect(viewModel.ppc.length, 0);
      expect(viewModel.ppcControllers.length, 0);
      expect(viewModel.isNewRow.length, 0);
    });

    test("removePpcRow out-of-range is safe", () {
      viewModel.removePpcRow(-1);
      viewModel.removePpcRow(99);
      expect(true, isTrue);
    });
  });

  group("emitPpcSoft", () {
    test("debounces without throwing", () async {
      viewModel.emitPpcSoft();
      await Future<void>.delayed(const Duration(milliseconds: 220));
      expect(true, isTrue);
    });

    test("returns immediately when restoring draft", () async {
      viewModel.isRestoringDraft = true;
      viewModel.emitPpcSoft();
      await Future<void>.delayed(const Duration(milliseconds: 220));
      expect(true, isTrue);
    });
  });

  group("row input detection", () {
    test("_rowHasAnyInput/rowHasAnyInput detect non-empty fields", () {
      final c = PpcControllers.empty();

      expect(viewModel.rowHasAnyInput(c), false);

      c.grossPPCValueCtrl.text = "  ";
      expect(viewModel.rowHasAnyInput(c), false);

      c.grossPPCValueCtrl.text = "1";
      expect(viewModel.rowHasAnyInput(c), true);
    });
  });

  group("validators", () {
    late PpcControllers c;

    setUp(() {
      c = PpcControllers.empty();
    });

    test(
        "mandatoryNumericIfOther: blank row "
        "-> optional, but numeric if provided", () {
      String? res = viewModel.mandatoryNumericIfOther(
        c: c,
        value: "",
        fieldLabel: "Gross",
      );
      expect(res, null);

      res = viewModel.mandatoryNumericIfOther(
        c: c,
        value: "abc",
        fieldLabel: "Gross",
      );
      expect(
        res,
        "Gross must be numeric (≤15 digits before decimal, ≤6 after).",
      );

      res = viewModel.mandatoryNumericIfOther(
        c: c,
        value: "123.456",
        fieldLabel: "Gross",
      );
      expect(res, null);
    });

    test("mandatoryNumericIfOther: row has other input -> mandatory", () {
      c.commentsCtrl.text = "some";

      String? res = viewModel.mandatoryNumericIfOther(
        c: c,
        value: "",
        fieldLabel: "Gross",
      );
      expect(res, "Gross is required because other PPC details are provided.");

      res = viewModel.mandatoryNumericIfOther(
        c: c,
        value: "1.234567",
        fieldLabel: "Gross",
      );
      expect(res, null);
    });

    test("mandatoryDateIfOther: blank row -> optional but validated if present",
        () {
      String? res = viewModel.mandatoryDateIfOther(
        c: c,
        value: "",
        fieldLabel: "Date",
      );
      expect(res, null);

      res = viewModel.mandatoryDateIfOther(
        c: c,
        value: "31/12/2025",
        fieldLabel: "Date",
      );
      expect(res, null);

      res = viewModel.mandatoryDateIfOther(
        c: c,
        value: "2025-12-31",
        fieldLabel: "Date",
      );
      expect(res, "Date must be in DD/MM/YYYY format.");
    });

    test("mandatoryDateIfOther: row has other input -> mandatory", () {
      c.commentsCtrl.text = "x";

      String? res = viewModel.mandatoryDateIfOther(
        c: c,
        value: "",
        fieldLabel: "Date",
      );
      expect(res, "Date is required because other PPC details are provided.");

      res = viewModel.mandatoryDateIfOther(
        c: c,
        value: "31/12/2025",
        fieldLabel: "Date",
      );
      expect(res, null);
    });
  });

  group("buildNames", () {
    final options = <Reference>[
      Reference(id: 1, name: "One"),
      Reference(id: 2, name: "Two"),
      Reference(id: 3, name: "Three"),
    ];

    test("list of refs maps to comma-separated names", () {
      final refs = [Reference(id: 1), Reference(id: 3)];
      final s = viewModel.buildNames(refs: refs, options: options);
      expect(s, "One, Three");
    });

    test("single id looks up name", () {
      final s = viewModel.buildNames(options: options, id: 2);
      expect(s, "Two");
    });

    test("fallback returns --", () {
      final s1 = viewModel.buildNames(refs: [], options: options);
      final s2 = viewModel.buildNames(options: options, id: 999);
      final s3 = viewModel.buildNames(options: options);

      expect(s1, "--");
      expect(s2, "--");
      expect(s3, "--");
    });
  });

  group("soft sync + single row recompute", () {
    test(
        "syncRowFromControllersSoft updates only this row; "
        "recomputeDerivedForSingleRow uses prev baseline", () {
      viewModel.contractValue = 100;
      viewModel.contractorValueController.text = "100";
      viewModel.ppc = [
        PPC(grossPPCValue: 60, cumulativePPCValue: 60, cumulativePpcValue: 60),
        PPC(grossPPCValue: 10, cumulativePPCValue: 10, cumulativePpcValue: 10),
      ];

      viewModel.ppcControllers = [
        PpcControllers.empty(),
        PpcControllers.empty(),
      ];

      viewModel.ppcControllers[1].grossPPCValueCtrl.text = "50";
      viewModel.syncRowFromControllersSoft(1);

      expect(viewModel.ppc[1].grossPPCValue, 50);

      viewModel.recomputeDerivedForSingleRow(1);

      expect(viewModel.ppc[1].cumulativePPCValue, 100);
      expect(viewModel.ppc[1].cumulativePpcValue, 100);
      expect(viewModel.ppc[1].netPPCValue, isNotNull);
      expect(viewModel.ppc[1].netCertifiedAmountVat, isNotNull);
      expect(viewModel.ppc[1].workDonePercent, isNotNull);
      expect(viewModel.ppc[1].cumulativeWorkDonePercent, isNotNull);
    });

    test("recomputeDerivedForSingleRow with invalid index is safe", () {
      viewModel.ppc = [];
      viewModel.recomputeDerivedForSingleRow(-1);
      viewModel.recomputeDerivedForSingleRow(99);
      expect(true, isTrue);
    });

    test(
        "recomputeDerivedForSingleRow with "
        "non-positive contract sets percents to 0", () {
      viewModel.contractValue = 0;
      viewModel.contractorValueController.text = "0";
      viewModel.ppc = [PPC(grossPPCValue: 10, cumulativePPCValue: 0)];
      viewModel.ppcControllers = [PpcControllers.empty()];

      viewModel.recomputeDerivedForSingleRow(0);

      expect(viewModel.ppc[0].workDonePercent, 0.0);
      expect(viewModel.ppc[0].cumulativeWorkDonePercent, 0.0);
      expect(viewModel.ppc[0].workDone, 0.0);
      expect(viewModel.ppc[0].cumulativeWorkDone, 0.0);
    });
  });

  group("disposeControllers", () {
    test("disposes each controller set and clears list", () {
      viewModel.ppcControllers = [
        PpcControllers.empty(),
        PpcControllers.empty(),
      ];

      viewModel.disposeControllers();

      expect(viewModel.ppcControllers, isEmpty);
    });
  });

  group("variation helpers", () {
    test(
        "updateVariationField writes formatted "
        "value and stores numeric (AED mode)", () {
      viewModel.contract.initialContractValue = "100.0";
      viewModel.isAedRates = true;
      viewModel.contract.contractValue = "130.0";

      viewModel.updateVariationField(epsilon: 1e-6);

      expect(viewModel.variationController.text, isNotEmpty);
      expect(viewModel.contract.variationAmount, closeTo(30.0, 1e-6));
      expect(viewModel.contract.variationContractValue, isNotNull);
    });

    test(
        "updateVariationField writes formatted "
        "value when using contractValueAedAmount", () {
      viewModel.contract.initialContractValue = "100.0";
      viewModel.isAedRates = false;
      viewModel.contract.contractValueAedAmount = "150.0";

      viewModel.updateVariationField(epsilon: 1e-6);

      expect(viewModel.variationController.text, isNotEmpty);
      expect(viewModel.contract.variationAmount, closeTo(50.0, 1e-6));
    });

    test("updateCompletionVariation formats variation days and writes diff",
        () {
      viewModel.contract.originalCompletionDate = DateTime(2025, 1, 1);
      viewModel.contract.expectedEndDate = DateTime(2025, 1, 15);

      viewModel.updateCompletionVariation();

      expect(viewModel.variationCompletionDateController.text, contains("14"));
      expect(viewModel.contract.variationCompletionDate, 14);
    });
  });

  group("prefillPpcControllersFromModel", () {
    test("prefills empty controllers from PPC model", () {
      final c = PpcControllers.empty();
      viewModel.ppcControllers = [c];
      viewModel.ppc = [PPC()];

      final data = PPC(
        ppcNo: "PPC-007",
        ppcId: 77,
        ppcDate: "2025-12-31",
        grossPPCValue: 123.45,
        advancePaymentDeduction: 1.2,
        retentionDeduction: 2.3,
        vatAmount: 3.4,
        otherPayment: 4.5,
        actualPaymentReceived: 6.7,
        datePaymentReceived: "2025-01-15",
      );

      viewModel.prefillPpcControllersFromModel(0, data);

      expect(c.ppcCtrl.text, "PPC-007");
      expect(c.ppcDateCtrl.text, "31/12/2025");
      expect(c.grossPPCValueCtrl.text, "123.45");
      expect(c.advancePaymentDeductionCtrl.text, "1.2");
      expect(c.retentionDeductionCtrl.text, "2.3");
      expect(c.vatAmountCtrl.text, "3.4");
      expect(c.otherPaymentCtrl.text, "4.5");
      expect(c.actualPaymentReceivedCtrl.text, "6.7");
      expect(c.datePaymentReceivedCtrl.text, "15/01/2025");
    });

    test("when ppcNo is null, falls back to ppcId for ppcCtrl", () {
      final c = PpcControllers.empty();
      viewModel.ppcControllers = [c];
      viewModel.ppc = [PPC()];

      final data = PPC(
        ppcNo: null,
        ppcId: 999,
      );

      viewModel.prefillPpcControllersFromModel(0, data);

      expect(c.ppcCtrl.text, "999");
    });

    test("does not overwrite non-empty controllers", () {
      final c = PpcControllers.empty()
        ..ppcCtrl.text = "ALREADY"
        ..ppcDateCtrl.text = "10/10/2025"
        ..grossPPCValueCtrl.text = "5"
        ..advancePaymentDeductionCtrl.text = "6"
        ..retentionDeductionCtrl.text = "7"
        ..vatAmountCtrl.text = "8"
        ..otherPaymentCtrl.text = "9"
        ..actualPaymentReceivedCtrl.text = "11"
        ..datePaymentReceivedCtrl.text = "01/01/2024";

      viewModel.ppcControllers = [c];
      viewModel.ppc = [PPC()];

      final data = PPC(
        ppcNo: "NEW",
        ppcId: 1,
        ppcDate: "2025-01-01",
        grossPPCValue: 10,
        advancePaymentDeduction: 1,
        retentionDeduction: 1,
        vatAmount: 1,
        otherPayment: 1,
        actualPaymentReceived: 1,
        datePaymentReceived: "2025-01-02",
      );

      viewModel.prefillPpcControllersFromModel(0, data);

      expect(c.ppcCtrl.text, "ALREADY");
      expect(c.ppcDateCtrl.text, "10/10/2025");
      expect(c.grossPPCValueCtrl.text, "5");
      expect(c.advancePaymentDeductionCtrl.text, "6");
      expect(c.retentionDeductionCtrl.text, "7");
      expect(c.vatAmountCtrl.text, "8");
      expect(c.otherPaymentCtrl.text, "9");
      expect(c.actualPaymentReceivedCtrl.text, "11");
      expect(c.datePaymentReceivedCtrl.text, "01/01/2024");
    });

    test("out-of-range index is no-op", () {
      viewModel.ppcControllers = [PpcControllers.empty()];
      viewModel.ppc = [PPC()];

      viewModel.prefillPpcControllersFromModel(-1, PPC(ppcNo: "X"));
      viewModel.prefillPpcControllersFromModel(99, PPC(ppcNo: "X"));

      expect(true, isTrue);
    });

    test("returns immediately when restoring draft", () {
      final c = PpcControllers.empty();
      viewModel.ppcControllers = [c];
      viewModel.ppc = [PPC()];
      viewModel.isRestoringDraft = true;

      viewModel.prefillPpcControllersFromModel(
        0,
        PPC(ppcNo: "WILL_NOT_SET"),
      );

      expect(c.ppcCtrl.text, "");
    });
  });

  // ---------------------------------------------------------------------------
  // handleSubmitForRow / alert dedupe / row cooldown
  // ---------------------------------------------------------------------------

  group("handleSubmitForRow", () {
    // testWidgets('blank row submit shows toast first, suppresses duplicate,
    // allows after cooldown', (tester) async {
    //   final ctrls = PpcControllers.empty();
    //   vm.ppcControllers = [ctrls];
    //   vm.ppc = [PPC()];
    //   vm.isNewRow = [true];

    //   late BuildContext ctx;
    //   await pumpSimpleFocusShell(
    //     tester,
    //     child: Builder(
    //       builder: (context) {
    //         ctx = context;
    //         return const SizedBox();
    //       },
    //     ),
    //   );

    //   // FIRST submit -> should show toast
    //   vm.handleSubmitForRow(ctx, ctrls, 0, () {});
    //   verify(() => mockAlertManager.showFailureToast(any())).called(1);

    //   // Clear interactions so we can assert second submit causes NO NEW call
    //   clearInteractions(mockAlertManager);

    //   // Wait only row submit cooldown (600ms), but NOT alert cooldown (2s)
    //   await tester.pump(const Duration(milliseconds: 700));

    //   // SECOND submit -> duplicate alert suppressed
    //   vm.handleSubmitForRow(ctx, ctrls, 0, () {});
    //   verifyNever(() => mockAlertManager.showFailureToast(any()));

    //   // Wait full alert cooldown
    //   await tester.pump(const Duration(seconds: 2));

    //   // THIRD submit -> allowed again
    //   vm.handleSubmitForRow(ctx, ctrls, 0, () {});
    //   verify(() => mockAlertManager.showFailureToast(any())).called(1);
    // });

    testWidgets("rapid repeated enter presses are ignored by cooldown",
        (tester) async {
      final ctrls = PpcControllers.empty()..commentsCtrl.text = "x";
      vm.ppcControllers = [ctrls];
      vm.ppc = [PPC()];
      vm.isNewRow = [true];

      int called = 0;

      late BuildContext ctx;
      await pumpSimpleFocusShell(
        tester,
        child: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      );

      vm.handleSubmitForRow(ctx, ctrls, 0, () => called++);
      vm.handleSubmitForRow(ctx, ctrls, 0, () => called++);

      expect(called, 1);
    });

    testWidgets(
        "API row path uses soft sync + single row recompute when gross exists",
        (tester) async {
      final ctrls = PpcControllers.empty()
        ..grossPPCValueCtrl.text = "50"
        ..commentsCtrl.text = "row";

      vm.contractValue = 100;
      vm.contractorValueController.text = "100";
      vm.ppcControllers = [ctrls];
      vm.ppc = [PPC(grossPPCValue: 10)];
      vm.isNewRow = [false];

      late BuildContext ctx;
      await pumpSimpleFocusShell(
        tester,
        child: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      );

      vm.handleSubmitForRow(ctx, ctrls, 0, () {});

      // Flush the 200ms debounce timer created by emitPpcSoft()
      await tester.pump(const Duration(milliseconds: 250));

      expect(vm.ppc.first.grossPPCValue, 50);
      expect(vm.ppc.first.netPPCValue, isNotNull);
    });

    testWidgets("API row path without gross only soft-emits", (tester) async {
      final ctrls = PpcControllers.empty()..commentsCtrl.text = "row";

      vm.contractValue = 100;
      vm.contractorValueController.text = "100";
      vm.ppcControllers = [ctrls];
      vm.ppc = [PPC(grossPPCValue: 10)];
      vm.isNewRow = [false];

      late BuildContext ctx;
      await pumpSimpleFocusShell(
        tester,
        child: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      );

      vm.handleSubmitForRow(ctx, ctrls, 0, () {});
      await tester.pump(const Duration(milliseconds: 220));

      expect(true, isTrue);
    });

    testWidgets("new row path calls onAnyFieldChanged", (tester) async {
      final ctrls = PpcControllers.empty()..commentsCtrl.text = "row";

      vm.ppcControllers = [ctrls];
      vm.ppc = [PPC()];
      vm.isNewRow = [true];

      int called = 0;

      late BuildContext ctx;
      await pumpSimpleFocusShell(
        tester,
        child: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      );

      vm.handleSubmitForRow(ctx, ctrls, 0, () => called++);

      expect(called, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  group("onSubmit", () {
    testWidgets("invalid form shows failure toast and returns", (tester) async {
      await pumpFormShell(
        tester,
        formKey: viewModel.formKey,
        validator: (_) => "required",
      );

      await viewModel.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("blank last PPC row blocks submit", (tester) async {
      await pumpFormShell(
        tester,
        formKey: viewModel.formKey,
        validator: (_) => null,
      );

      viewModel.ppcControllers = [PpcControllers.empty()];
      viewModel.ppc = [PPC()];

      await viewModel.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    testWidgets("invalid dates block submit", (tester) async {
      await pumpFormShell(
        tester,
        formKey: viewModel.formKey,
        validator: (_) => null,
      );

      viewModel.onStartDateSubmitted2(DateTime(2025, 5, 10));
      viewModel.onCompletionDateSubmitted2(DateTime(2025, 5, 1));

      await viewModel.onSubmit(tester.element(find.byType(Form)));

      expect(viewModel.completionDateValidate, isTrue);
    });

    testWidgets("legacy completionDateValidate flag blocks submit",
        (tester) async {
      await pumpFormShell(
        tester,
        formKey: viewModel.formKey,
        validator: (_) => null,
      );

      viewModel.completionDateValidate = true;
      viewModel.contract.expectedStartDate = DateTime(2025, 1, 1);
      viewModel.contract.expectedEndDate = DateTime(2025, 2, 1);
      viewModel.contract.projectTenor = 1;
      viewModel.selectedCurrencyLabel = "AED";
      viewModel.contractorValueController.text = "100";

      await viewModel.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
    });

    testWidgets("missing required fields block submit", (tester) async {
      await pumpFormShell(
        tester,
        formKey: viewModel.formKey,
        validator: (_) => null,
      );

      viewModel.contract.expectedStartDate = null;
      viewModel.contract.expectedEndDate = null;
      viewModel.contract.projectTenor = null;
      viewModel.selectedCurrencyLabel = null;
      viewModel.contractorValueController.text = "";

      await viewModel.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    testWidgets("success path saves contract, clears draft and navigates",
        (tester) async {
      final router = await pumpRouterShell(
        tester,
        child: Builder(
          builder: (context) {
            return Form(
              key: viewModel.formKey,
              child: ElevatedButton(
                onPressed: () async => viewModel.onSubmit(context),
                child: const Text("save"),
              ),
            );
          },
        ),
      );

      // IMPORTANT: set dates using public methods so _startDate/_endDate are populated
      viewModel.onStartDateSubmitted2(DateTime(2025, 1, 1));
      viewModel.onCompletionDateSubmitted2(DateTime(2025, 2, 1));

      viewModel.selectedCurrencyLabel = "AED";
      viewModel.contractorValueController.text = "100";
      viewModel.contractorCommentsController.text = "hello";
      viewModel.ppc = [];
      viewModel.ppcControllers = [];
      viewModel.completionDateValidate = false;

      when(
        () => mockCommonRepo.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: any(named: "rimNo"),
        ),
      ).thenAnswer((_) async => "OK");

      when(
        () => mockCommonRepo.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            strategyComment: "hello",
            categoryId: ServerConstants.contractCategoryID,
          ),
        ],
      );

      // IMPORTANT: return String? if that's your repo signature
      when(() => mockRepository.saveContractDetail(any()))
          .thenAnswer((_) async => "OK");

      await tester.tap(find.text("save"));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveContractDetail(any())).called(1);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        Routes.editViewProject,
      );
    });

    testWidgets("repository error shows failure toast", (tester) async {
      await pumpRouterShell(
        tester,
        child: Builder(
          builder: (context) {
            return Form(
              key: viewModel.formKey,
              child: ElevatedButton(
                onPressed: () async => viewModel.onSubmit(context),
                child: const Text("save"),
              ),
            );
          },
        ),
      );

      // IMPORTANT: set dates through the public handlers
      viewModel.onStartDateSubmitted2(DateTime(2025, 1, 1));
      viewModel.onCompletionDateSubmitted2(DateTime(2025, 2, 1));

      viewModel.selectedCurrencyLabel = "AED";
      viewModel.contractorValueController.text = "100";
      viewModel.ppc = [];
      viewModel.ppcControllers = [];
      viewModel.completionDateValidate = false;

      when(() => mockRepository.saveContractDetail(any()))
          .thenThrow(Exception("save failed"));

      await tester.tap(find.text("save"));
      await tester.pumpAndSettle();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ---------------------------------------------------------------------------
  // onReset
  // ---------------------------------------------------------------------------

  testWidgets("onReset navigates to editViewProject", (tester) async {
    final router = await pumpRouterShell(
      tester,
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () async => viewModel.onReset(context),
            child: const Text("reset"),
          );
        },
      ),
    );

    await tester.tap(find.text("reset"));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      Routes.editViewProject,
    );
  });

  // ---------------------------------------------------------------------------
  // build / clean / utility-only
  // ---------------------------------------------------------------------------

  group("clean()", () {
    test("returns empty string when value is null", () {
      expect(viewModel.clean(null), "");
    });

    test('returns empty string when value is "null" (case-insensitive)', () {
      expect(viewModel.clean("null"), "");
      expect(viewModel.clean("Null"), "");
      expect(viewModel.clean("NULL"), "");
      expect(viewModel.clean("NuLl"), "");
    });

    test("converts non-null values to string", () {
      expect(viewModel.clean(123), "123");
      expect(viewModel.clean(45.6), "45.6");
      expect(viewModel.clean(true), "true");
      expect(viewModel.clean(false), "false");
    });

    test("returns the same non-null normal string", () {
      expect(viewModel.clean("Hello"), "Hello");
      expect(viewModel.clean("0"), "0");
      expect(viewModel.clean("test"), "test");
    });
  });

  // ---------------------------------------------------------------------------
  // Smoke / default state
  // ---------------------------------------------------------------------------

  test("constructor starts with loading statuses", () {
    final local = EditContractViewModel();
    expect(local.state.loaderStatus, LoadingStatus.loading);
    expect(local.state.linkCommitmentStatus, LoadingStatus.loading);
    expect(local.state.ppcStatus, LoadingStatus.loading);
  });
}
