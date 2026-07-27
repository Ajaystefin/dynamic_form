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
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/state.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

import "../../../../test_config.dart";

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class FakeProject extends Fake implements Project {}

class FakeContract extends Fake implements Contract {}

class FakeComment extends Fake implements Comment {}

class FakeReference extends Fake implements Reference {}

class FakeMap extends Fake implements Map<String, dynamic> {}

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

class TestEditContractViewModel extends EditContractViewModel {
  bool enrichCalled = false;
  bool deleteDraftCalled = false;
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool unregisterDraftCallbackCalled = false;
  bool fetchCalled = false;
  String? fetchedRefNo;

  set repo(ProjectRepository r) => repository = r;

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

  @override
  void enrichLinkCommitmentNumberWith() {
    enrichCalled = true;
    super.enrichLinkCommitmentNumberWith();
  }

  @override
  Future<void> fetchAndSetStrategyComments({String? appRefNo}) async {
    fetchCalled = true;
    fetchedRefNo = appRefNo;
    await super.fetchAndSetStrategyComments(appRefNo: appRefNo);
  }

  Future<void> loadReferenceDataWith(ReferenceDataService service) async {
    referenceData = await service.getReferenceData(
      <String>[
        ReferenceDataKeys.borrowerRole,
        ReferenceDataKeys.facilityTypes,
      ],
    );
    borrowerRole =
        referenceData[ReferenceDataKeys.borrowerRole] ?? <Reference>[];
    facilityType =
        referenceData[ReferenceDataKeys.facilityTypes] ?? <Reference>[];
  }
}

const MethodChannel connectivityChannel =
    MethodChannel("dev.fluttercommunity.plus/connectivity");

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

Future<GoRouter> pumpRouterShell(
  WidgetTester tester, {
  required Widget child,
  String initialLocation = "/",
}) async {
  final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        builder: (_, __) => child,
      ),
      GoRoute(
        path: Routes.editViewProject,
        builder: (_, __) => const Scaffold(
          body: Center(child: Text("EditViewProject")),
        ),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, __) => const Scaffold(
          body: Center(child: Text("Home")),
        ),
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

Future<void> pumpFormShell(
  WidgetTester tester, {
  required GlobalKey<FormState> formKey,
  String? Function(String?)? validator,
  void Function(String?)? onSaved,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: TextFormField(
            validator: validator,
            onSaved: onSaved,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void stubAlerts(MockAlertManager alert) {
  when(() => alert.showFailureToast(any())).thenReturn(null);
  when(() => alert.showWarningToast(any())).thenReturn(null);
  when(() => alert.showSuccessToast(any())).thenReturn(null);
  when(() => alert.showInfoToast(any())).thenReturn(null);
}

void stubRepoDefaults(MockProjectRepository repo) {
  when(() => repo.getcountryCode()).thenAnswer(
    (_) async => <Reference>[
      Reference(id: 1, name: "AED"),
      Reference(id: 2, name: "USD"),
    ],
  );

  when(
    () => repo.getContractByContractCodeDetails(
      contractCode: any(named: "contractCode"),
    ),
  ).thenAnswer(
    (_) async => Contract()
      ..contractCode = "C-001"
      ..contractCurrency = "AED"
      ..contractValue = "1000"
      ..contractValueAedAmount = "1000"
      ..contractName = "Contract Name"
      ..projectTenor = 1
      ..ppcList = <PPC>[],
  );

  when(() => repo.getProjectContractDetails(any())).thenAnswer(
    (_) async => <Contract>[],
  );

  when(
    () => repo.getLinkedCMNForRimDetails(
      contractRimNo: any(named: "contractRimNo"),
    ),
  ).thenAnswer(
    (_) async => <LinkCommitmentNumber>[],
  );

  when(
    () => repo.getComments(
      CommentsType.contract,
      EntityIdentifier.contract,
      any(),
    ),
  ).thenAnswer(
    (_) async => <Comment>[],
  );

  when(() => repo.saveComment(any())).thenAnswer((_) async => "OK");

  when(() => repo.saveContractDetail(any())).thenAnswer((_) async => "OK");
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestEditContractViewModel vm;
  late EditContractViewModel viewModel;
  late MockProjectRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockReferenceDataService mockRefSvc;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();
    await stubConnectivity();

    registerFallbackValue(FakeProject());
    registerFallbackValue(FakeContract());
    registerFallbackValue(FakeComment());
    registerFallbackValue(FakeReference());
    registerFallbackValue(FakeMap());
    registerFallbackValue(const YearRules());
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String>[]);
    registerFallbackValue(<Reference>[]);
    registerFallbackValue(<Comment>[]);
    registerFallbackValue(<PPC>[]);
    registerFallbackValue(<LinkCommitmentNumber>[]);
    registerFallbackValue("");
    registerFallbackValue(CommentsType.contract);
    registerFallbackValue(EntityIdentifier.contract);
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
    mockRepository = MockProjectRepository();
    mockAlertManager = MockAlertManager();
    mockRefSvc = MockReferenceDataService();

    AlertManager.overrideInstance = mockAlertManager;
    LocalStorageService().getStorage = MockLocalStorageService();

    stubAlerts(mockAlertManager);
    stubRepoDefaults(mockRepository);

    Globals.request = Request(applicationRefNo: "APP-001");
    Globals.onAutoSave = null;

    viewModel = EditContractViewModel()
      ..repository = mockRepository
      ..ppc = <PPC>[]
      ..ppcList = <PPC>[]
      ..ppcControllerss = <PpcRowControllers>[]
      ..isNewRow = <bool>[]
      ..contractValue = 1000
      ..contractorValueController.text = "1000"
      ..contract = (Contract()
        ..contractCode = "C-001"
        ..appRefNo = "APP-001"
        ..rimNo = "123")
      ..project = (Project()
        ..projectId = 1
        ..projectCode = "PRJ-001"
        ..projectName = "Test Project");

    vm = TestEditContractViewModel()
      ..repo = mockRepository
      ..contractValue = 1000
      ..contractorValueController.text = "1000"
      ..contract = (Contract()
        ..contractCode = "C-001"
        ..appRefNo = "APP-001"
        ..rimNo = "123")
      ..project = (Project()
        ..projectId = 1
        ..projectCode = "PRJ-001"
        ..projectName = "Test Project");
  });

  tearDown(() {
    Globals.onAutoSave = null;
    Globals.request = null;
    try {
      viewModel.disposeControllers();
    } on Object {
      return;
    }
    try {
      vm.disposeControllers();
    } on Object {
      return;
    }
  });

  group("state / config", () {
    test("constructor starts with loading statuses", () {
      final EditContractViewModel local = EditContractViewModel();

      expect(local.state.loaderStatus, LoadingStatus.loading);
      expect(local.state.linkCommitmentStatus, LoadingStatus.loading);
      expect(local.state.ppcStatus, LoadingStatus.loading);
    });

    test("state copyWith works", () {
      final EditContractState state = EditContractState(
        loaderStatus: LoadingStatus.loading,
        linkCommitmentStatus: LoadingStatus.loading,
        ppcStatus: LoadingStatus.loading,
      );

      final EditContractState next = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        linkCommitmentStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.error,
        refreshKey: 123,
      );

      expect(next.loaderStatus, LoadingStatus.loaded);
      expect(next.linkCommitmentStatus, LoadingStatus.loaded);
      expect(next.ppcStatus, LoadingStatus.error);
      expect(next.refreshKey, 123);
    });

    test("draft getters are correct", () {
      vm.contract.contractCode = "CON-001";

      expect(vm.draftModuleKey, DraftModuleKeys.projects);
      expect(vm.draftFormKey, "${Routes.editContract}_CON-001");
      expect(vm.draftHandler, isA<EditContractDraftHandler>());
    });

    test("canEdit follows pageMode", () {
      vm.pageMode = PageMode.na;
      expect(vm.canEdit, false);

      vm.pageMode = PageMode.view;
      expect(vm.canEdit, false);

      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, true);
    });

    test("default fields are initialized", () {
      expect(vm.dropdownItems, <String>["Main Contractor", "Sub-Contractor"]);
      expect(vm.referenceData, isEmpty);
      expect(vm.countryCodes, isEmpty);
      expect(vm.borrowerRole, isEmpty);
      expect(vm.facilityType, isEmpty);
      expect(vm.selectedCurrencyLabel, ServerConstants.aedCurrency);
      expect(vm.isAedRates, false);
      expect(vm.isAddPPC, true);
      expect(vm.commentInputs, <String>[""]);
      expect(vm.completionDateValidate, false);
      expect(vm.isPpcEditable, false);
      expect(vm.isRestoringDraft, false);
    });
  });

  group("sync helpers", () {
    test("syncModelFromControllers copies static controllers into model", () {
      vm
        ..customerNameController.text = "Contract A"
        ..contractorValueController.text = "5000"
        ..contractorScopeController.text = "Scope A"
        ..completionPercentageController.text = "45.5"
        ..selectedCurrencyLabel = "USD"
        ..syncModelFromControllers();

      expect(vm.contract.contractName, "Contract A");
      expect(vm.contract.contractValue, "5000");
      expect(vm.contract.contractScope, "Scope A");
      expect(vm.contract.completionPercentage, 45.5);
      expect(vm.contract.contractCurrency, "USD");
    });

    test("syncModelFromControllers handles invalid completion", () {
      vm
        ..completionPercentageController.text = "bad"
        ..syncModelFromControllers();

      expect(vm.contract.completionPercentage, isNull);
    });

    test("syncControllersFromModel copies model into controllers", () {
      vm
        ..contract = (Contract()
          ..completionPercentage = 88.8
          ..contractName = "Loaded Contract"
          ..contractValue = "7500"
          ..contractScope = "Loaded Scope"
          ..projectTenor = 4
          ..contractCurrency = "AED")
        ..syncControllersFromModel();

      expect(vm.completionPercentageController.text, "88.8");
      expect(vm.customerNameController.text, "Loaded Contract");
      expect(vm.contractorValueController.text, "7500");
      expect(vm.contractorScopeController.text, "Loaded Scope");
      expect(vm.projectTenorController.text, "4 Months");
      expect(vm.selectedCurrencyLabel, "AED");
    });

    test("syncControllersFromModel handles nulls", () {
      vm
        ..contract = Contract()
        ..syncControllersFromModel();

      expect(vm.completionPercentageController.text, "null");
      expect(vm.customerNameController.text, "");
      expect(vm.contractorValueController.text, "");
      expect(vm.contractorScopeController.text, "");
      expect(vm.projectTenorController.text, "");
      expect(vm.selectedCurrencyLabel, isNull);
    });
  });

  group("comment input helpers", () {
    test("addCommentInput appends empty string and clears draft controller",
        () {
      vm.contractorCommentsController.text = "abc";
      final int initialLength = vm.commentInputs.length;

      vm.addCommentInput();

      expect(vm.commentInputs.length, initialLength + 1);
      expect(vm.commentInputs.last, "");
      expect(vm.contractorCommentsController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateCommentInput updates valid index", () {
      vm
        ..commentInputs = <String>["initial"]
        ..updateCommentInput(0, "updated");

      expect(vm.commentInputs[0], "updated");
      expect(vm.contractorCommentsController.text, "updated");
    });

    test("updateCommentInput ignores invalid index", () {
      vm
        ..commentInputs = <String>["only"]
        ..updateCommentInput(5, "ignored")
        ..updateCommentInput(-1, "ignored");

      expect(vm.commentInputs, <String>["only"]);
    });

    test("getCommentInputs returns current list", () {
      vm.commentInputs = <String>["a", "b"];

      expect(vm.getCommentInputs(), <String>["a", "b"]);
    });

    test("clearCommentInputs leaveOneBlank true", () {
      vm
        ..commentInputs = <String>["x", "y"]
        ..contractorCommentsController.text = "hello"
        ..clearCommentInputs();

      expect(vm.commentInputs, <String>[""]);
      expect(vm.contractorCommentsController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("clearCommentInputs leaveOneBlank false", () {
      vm
        ..commentInputs = <String>["x", "y"]
        ..contractorCommentsController.text = "hello"
        ..clearCommentInputs(leaveOneBlank: false);

      expect(vm.commentInputs, isEmpty);
      expect(vm.contractorCommentsController.text, "hello");
    });

    test("setDraftComment sets controller", () {
      vm.setDraftComment("draft text");
      expect(vm.contractorCommentsController.text, "draft text");

      vm.setDraftComment(null);
      expect(vm.contractorCommentsController.text, "");
    });

    test("clearDraftComment clears controller", () {
      vm.contractorCommentsController.text = "abc";

      vm.clearDraftComment();

      expect(vm.contractorCommentsController.text, "");
    });
  });

  group("currency conversion", () {
    test("onCurrencyChanged updates selected label and AED flag", () {
      vm.onCurrencyChanged(Reference(name: "USD"));

      expect(vm.selectedCurrencyLabel, "USD");
      expect(vm.contract.contractCurrency, "USD");
      expect(vm.isAedRates, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      vm.onCurrencyChanged(Reference(name: "AED"));

      expect(vm.selectedCurrencyLabel, "AED");
      expect(vm.contract.contractCurrency, "AED");
      expect(vm.isAedRates, true);
    });

    test("isAEDCurrencyRate uses ref, contract, selected label", () {
      vm.selectedCurrencyLabel = "USD";

      expect(vm.isAEDCurrencyRate(ref: Reference(name: "aed")), true);
      expect(vm.isAedRates, true);

      vm.selectedCurrencyLabel = null;
      vm.contract.contractCurrency = "AED";
      expect(vm.isAEDCurrencyRate(contract: vm.contract), true);

      vm.contract.contractCurrency = null;
      vm.selectedCurrencyLabel = "USD";
      expect(vm.isAEDCurrencyRate(), false);
    });

    test("onContractValueChanged triggers conversion", () {
      vm
        ..selectedCurrencyLabel = "AED"
        ..contractorValueController.text = "200"
        ..onContractValueChanged("200");

      expect(vm.convertedAmountController.text, "200.00");
    });

    test("updateConvertedAmount clears on empty input", () {
      vm
        ..selectedCurrencyLabel = "AED"
        ..contractorValueController.text = ""
        ..updateConvertedAmount();

      expect(vm.convertedAmountController.text, "");
    });

    test("updateConvertedAmount clears on zero conversion", () {
      vm
        ..selectedCurrencyLabel = "AED"
        ..contractorValueController.text = "0"
        ..updateConvertedAmount();

      expect(vm.convertedAmountController.text, "");
    });

    test("updateConvertedAmount sets converted value for USD", () {
      vm
        ..selectedCurrencyLabel = "USD"
        ..contractorValueController.text = "100"
        ..updateConvertedAmount();

      expect(vm.convertedAmountController.text, "367.00");
    });

    test("updateConvertedAmount defaults unknown currency rate to 1", () {
      vm
        ..selectedCurrencyLabel = "XYZ"
        ..contractorValueController.text = "123"
        ..updateConvertedAmount();

      expect(vm.convertedAmountController.text, "123.00");
    });
  });

  group("date / tenor helpers", () {
    test("isCompletionBeforeStart compares date-only values", () {
      final DateTime start = DateTime(2025, 1, 10, 23, 59);
      final DateTime earlierEnd = DateTime(2025, 1, 9);
      final DateTime sameDayEnd = DateTime(2025, 1, 10);
      final DateTime laterEnd = DateTime(2025, 1, 11, 12, 30);

      expect(vm.isCompletionBeforeStart(start, earlierEnd), true);
      expect(vm.isCompletionBeforeStart(start, sameDayEnd), false);
      expect(vm.isCompletionBeforeStart(start, laterEnd), false);
    });

    test("onStartDateSubmitted2 valid start updates model/controller", () {
      vm.onStartDateSubmitted2(DateTime(2025, 1, 4));

      expect(vm.contract.expectedStartDate, DateTime(2025, 1, 4));
      expect(vm.startDateController.text, "04/01/2025");
      expect(vm.completionDateValidate, false);
    });

    test("onStartDateSubmitted2 null clears date and tenor", () {
      vm.onStartDateSubmitted2(null);

      expect(vm.contract.expectedStartDate, isNull);
      expect(vm.startDateController.text, "");
      expect(vm.contract.projectTenor, isNull);
    });

    test("onCompletionDateSubmitted2 valid end updates model/controller", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 1, 4))
        ..onCompletionDateSubmitted2(DateTime(2025, 2, 10));

      expect(vm.contract.expectedEndDate, DateTime(2025, 2, 10));
      expect(vm.contract.expectedCompletionDate, DateTime(2025, 2, 10));
      expect(vm.completionDateController.text, "10/02/2025");
      expect(vm.completionDateValidate, false);
    });

    test("onCompletionDateSubmitted2 invalid clears completion/tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 5, 10))
        ..onCompletionDateSubmitted2(DateTime(2025, 5));

      expect(vm.contract.expectedEndDate, isNull);
      expect(vm.contract.expectedCompletionDate, isNull);
      expect(vm.completionDateController.text, "");
      expect(vm.contract.projectTenor, isNull);
      expect(vm.projectTenorController.text, "");
      expect(vm.completionDateValidate, true);
    });

    test("onCompletionDateSubmitted2 null writes NA variation", () {
      vm.contract.variationCompletionDate = null;

      vm.onCompletionDateSubmitted2(null);

      expect(vm.variationCompletionDateController.text, "NA");
      expect(vm.contract.variationCompletionDate, 0);
    });

    test("callEndDateTenor null clears UI", () {
      vm.callEndDateTenor(null, const YearRules(), isFirst: true);

      expect(vm.contract.expectedCompletionDate, isNull);
      expect(vm.completionDateController.text, "");
      expect(vm.projectTenorController.text, "");
    });

    test("callEndDateTenor valid updates and calculates tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025))
        ..callEndDateTenor(
          DateTime(2025, 3, 15),
          const YearRules(),
          isFirst: true,
        );

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 3, 15));
      expect(vm.completionDateController.text, "15/03/2025");
      expect(vm.contract.projectTenor, 2);
      expect(vm.projectTenorController.text, "2 Months");
    });

    test("callEndDateTenor valid isFirst false only updates end", () {
      vm.callEndDateTenor(
        DateTime(2025, 3, 15),
        const YearRules(),
      );

      expect(vm.contract.expectedCompletionDate, DateTime(2025, 3, 15));
      expect(vm.completionDateController.text, "15/03/2025");
    });

    test("callEndDateTenor end before start warns and clears tenor", () {
      vm
        ..onStartDateSubmitted2(DateTime(2025, 5, 10))
        ..callEndDateTenor(
          DateTime(2025, 5),
          const YearRules(),
          isFirst: true,
        );

      expect(vm.contract.projectTenor, isNull);
      expect(vm.projectTenorController.text, "");
      expect(vm.completionDateValidate, true);
      verify(() => mockAlertManager.showWarningToast(any())).called(1);
    });

    test("onSavedTenor parses integer", () {
      vm.onSavedTenor("7 months");

      expect(vm.contract.projectTenor, 7);
    });

    test("onOriginalCompletionDateSubmitted2 non-null updates original date",
        () {
      vm.onOriginalCompletionDateSubmitted2(DateTime(2025));

      expect(vm.contract.originalCompletionDate, DateTime(2025));
    });

    test("onOriginalCompletionDateSubmitted2 null writes NA and zero", () {
      vm.contract.variationCompletionDate = null;

      vm.onOriginalCompletionDateSubmitted2(null);

      expect(vm.variationCompletionDateController.text, "NA");
      expect(vm.contract.variationCompletionDate, 0);
    });
  });

  group("country code", () {
    test("sorts AED first and selects current currency", () async {
      vm.contract.contractCurrency = "USD";

      when(() => mockRepository.getcountryCode()).thenAnswer(
        (_) async => <Reference>[
          Reference(id: 1, name: "INR"),
          Reference(id: 2, name: "AED"),
          Reference(id: 3, name: "USD"),
        ],
      );

      await vm.getcountryCode();

      expect(vm.countryCodes.first.name?.toUpperCase(), "AED");
      expect(vm.selectedContractValueCurrency?.name, "USD");
      expect(vm.isAedRates, false);
    });

    test("contract currency unknown creates fallback reference", () async {
      vm.contract.contractCurrency = "ZZZ";

      when(() => mockRepository.getcountryCode()).thenAnswer(
        (_) async => <Reference>[
          Reference(id: 1, name: "AED"),
        ],
      );

      await vm.getcountryCode();

      expect(vm.selectedContractValueCurrency?.name, "ZZZ");
    });

    test("contract currency null keeps selectedContractValueCurrency null",
        () async {
      vm.contract.contractCurrency = null;

      when(() => mockRepository.getcountryCode()).thenAnswer(
        (_) async => <Reference>[
          Reference(id: 1, name: "AED"),
          Reference(id: 2, name: "USD"),
        ],
      );

      await vm.getcountryCode();

      expect(vm.selectedContractValueCurrency, isNull);
    });

    test("rethrows repository errors", () async {
      when(() => mockRepository.getcountryCode()).thenThrow(Exception("fail"));

      expect(vm.getcountryCode, throwsA(isA<Exception>()));
    });
  });

  group("contract loading", () {
    test("getContract happy path with name and PPC", () async {
      vm.contract.contractCode = "C-001";
      vm.referenceData = <String, List<Reference>>{
        ReferenceDataKeys.borrowerRole: <Reference>[
          Reference(id: 10, name: "Main"),
        ],
      };

      final Contract returned = Contract()
        ..contractCode = "C-001"
        ..contractCurrency = "USD"
        ..contractValueAedAmount = "1,000"
        ..borrowerRole = "Main"
        ..expectedStartDate = DateTime(2025)
        ..expectedEndDate = DateTime(2025, 3)
        ..projectTenor = 2
        ..contractValue = "200"
        ..contractName = "Already Present"
        ..variationContractValue = 12
        ..variationCompletionDate = 5
        ..ppcList = <PPC>[
          PPC(
            ppcNo: "90",
            ppcDate: "01/01/2025",
            grossValue: 50,
          ),
        ];

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenAnswer((_) async => returned);

      when(
        () => mockRepository.getComments(
          CommentsType.contract,
          EntityIdentifier.contract,
          any(),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(
            strategyComment: "ok",
            categoryId: ServerConstants.contractCategoryID,
          ),
        ],
      );

      await vm.getContract();

      expect(vm.contract.contractCode, "C-001");
      expect(vm.selectedCurrencyLabel, "USD");
      expect(vm.isAedRates, false);
      expect(vm.convertedAmountController.text, isNotEmpty);
      expect(vm.customerNameController.text, "Already Present");
      expect(vm.selectedBorrowerRole?.name, "Main");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.ppcStatus, LoadingStatus.loaded);
      expect(vm.ppc.length, 1);
      expect(vm.ppcList.length, 1);
      expect(vm.isNewRow.length, 1);
      expect(vm.fetchCalled, true);
      expect(vm.fetchedRefNo, "C-001");
    });

    test("getContract fetches contract name when missing", () async {
      vm.contract.contractCode = "C-002";

      final Contract returned = Contract()
        ..contractCode = "C-002"
        ..contractCurrency = "AED"
        ..contractValueAedAmount = "100"
        ..projectTenor = 1
        ..contractValue = "100"
        ..contractName = null
        ..projectId = "7"
        ..ppcList = <PPC>[];

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenAnswer((_) async => returned);

      when(() => mockRepository.getProjectContractDetails(any())).thenAnswer(
        (_) async => <Contract>[
          Contract()
            ..contractCode = "C-002"
            ..contractName = "Fetched Name",
        ],
      );

      await vm.getContract();

      expect(vm.customerNameController.text, "Fetched Name");
      expect(vm.isAedRates, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getContract borrower role fallback when not in referenceData",
        () async {
      vm.contract.contractCode = "C-003";
      vm.referenceData = <String, List<Reference>>{
        ReferenceDataKeys.borrowerRole: <Reference>[
          Reference(id: 1, name: "Other"),
        ],
      };

      final Contract returned = Contract()
        ..contractCode = "C-003"
        ..borrowerRole = "Fallback"
        ..contractCurrency = "AED"
        ..contractValue = "100"
        ..contractValueAedAmount = "100"
        ..contractName = "Name"
        ..projectTenor = 1
        ..ppcList = <PPC>[];

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenAnswer((_) async => returned);

      await vm.getContract();

      expect(vm.selectedBorrowerRole?.name, "Fallback");
    });

    test("getContract rethrows repository errors", () async {
      vm.contract.contractCode = "ERR";

      when(
        () => mockRepository.getContractByContractCodeDetails(
          contractCode: any(named: "contractCode"),
        ),
      ).thenThrow(Exception("boom"));

      expect(vm.getContract, throwsA(isA<Exception>()));
    });
  });

  group("contract details", () {
    test("fills customerNameContract and controller from matched item",
        () async {
      final Project project = Project()..projectId = 9;
      final Contract contract = Contract()..contractCode = "Z-9";

      when(() => mockRepository.getProjectContractDetails(any())).thenAnswer(
        (_) async => <Contract>[
          Contract()
            ..contractCode = "Z-8"
            ..contractName = "Nope",
          Contract()
            ..contractCode = "Z-9"
            ..contractName = "Winner",
        ],
      );

      await vm.getContractDetailsData(project, contract);

      expect(vm.customerNameContract, "Winner");
      expect(vm.customerNameController.text, "Winner");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("when not matched writes empty string", () async {
      when(() => mockRepository.getProjectContractDetails(any())).thenAnswer(
        (_) async => <Contract>[
          Contract()
            ..contractCode = "Z-8"
            ..contractName = "Nope",
        ],
      );

      await vm.getContractDetailsData(
        Project(),
        Contract()..contractCode = "Z-9",
      );

      expect(vm.customerNameContract, "");
      expect(vm.customerNameController.text, "");
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

  group("link commitment", () {
    test("getLinkCommitment sets list and calls enrich", () async {
      vm.contract.rimNo = "123";

      when(
        () => mockRepository.getLinkedCMNForRimDetails(
          contractRimNo: any(named: "contractRimNo"),
        ),
      ).thenAnswer(
        (_) async => <LinkCommitmentNumber>[
          LinkCommitmentNumber(projectAllocationAccount: "A"),
          LinkCommitmentNumber(projectAllocationAccount: "B"),
        ],
      );

      await vm.getLinkCommitment();

      expect(vm.linkContract?.length, 2);
      expect(vm.enrichCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
    });

    test("getLinkCommitment rethrows errors", () async {
      when(
        () => mockRepository.getLinkedCMNForRimDetails(
          contractRimNo: any(named: "contractRimNo"),
        ),
      ).thenThrow(Exception("link fail"));

      expect(vm.getLinkCommitment, throwsA(isA<Exception>()));
    });

    test("enrichLinkCommitmentNumberWith merges API data", () {
      vm
        ..contract.linkCommitmentNumberWith = <LinkCommitmentNumber>[
          LinkCommitmentNumber(projectAllocationAccount: "100001"),
          LinkCommitmentNumber(projectAllocationAccount: "200002"),
        ]
        ..linkContract = <LinkCommitmentNumber>[
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
        ]
        ..enrichLinkCommitmentNumberWith();

      final List<LinkCommitmentNumber> merged =
          vm.contract.linkCommitmentNumberWith!;

      expect(merged.length, 2);
      expect(merged[0].facilityType, 100);
      expect(merged[0].limitAmountInAED, 500000);
      expect(merged[1].facilityType, 101);
    });

    test("enrichLinkCommitmentNumberWith keeps getData when no API match", () {
      vm
        ..contract.linkCommitmentNumberWith = <LinkCommitmentNumber>[
          LinkCommitmentNumber(projectAllocationAccount: "999"),
        ]
        ..linkContract = <LinkCommitmentNumber>[
          LinkCommitmentNumber(projectAllocationAccount: "111"),
        ]
        ..enrichLinkCommitmentNumberWith();

      expect(
        vm.contract.linkCommitmentNumberWith?.first.projectAllocationAccount,
        "999",
      );
    });

    test("enrich no-ops when lists are null or empty", () {
      vm
        ..contract.linkCommitmentNumberWith = null
        ..linkContract = null
        ..enrichLinkCommitmentNumberWith();

      expect(vm.contract.linkCommitmentNumberWith, isNull);

      vm
        ..contract.linkCommitmentNumberWith = <LinkCommitmentNumber>[]
        ..linkContract = <LinkCommitmentNumber>[]
        ..enrichLinkCommitmentNumberWith();

      expect(vm.contract.linkCommitmentNumberWith, isEmpty);
    });

    test("linkCommitmentNumberDeleted removes valid index", () {
      vm.contract.linkCommitmentNumberWith = <LinkCommitmentNumber>[
        LinkCommitmentNumber(projectAllocationAccount: "A"),
        LinkCommitmentNumber(projectAllocationAccount: "B"),
        LinkCommitmentNumber(projectAllocationAccount: "C"),
      ];

      vm.linkCommitmentNumberDeleted(1);

      expect(
        vm.contract.linkCommitmentNumberWith!
            .map((LinkCommitmentNumber e) => e.projectAllocationAccount),
        <String?>["A", "C"],
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
    });

    test("linkCommitmentNumberDeleted ignores invalid index", () {
      vm.contract.linkCommitmentNumberWith = <LinkCommitmentNumber>[
        LinkCommitmentNumber(projectAllocationAccount: "X"),
      ];

      vm
        ..linkCommitmentNumberDeleted(-1)
        ..linkCommitmentNumberDeleted(99);

      expect(vm.contract.linkCommitmentNumberWith, hasLength(1));
    });

    test("updateLinkCommitmentNumberWith updates list", () {
      final List<LinkCommitmentNumber> selected = <LinkCommitmentNumber>[
        LinkCommitmentNumber(projectAllocationAccount: "111"),
        LinkCommitmentNumber(projectAllocationAccount: "222"),
      ];

      vm.updateLinkCommitmentNumberWith(selected);

      expect(vm.contract.linkCommitmentNumberWith, selected);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
    });
  });

  group("reference data seam", () {
    test("loads borrowerRole and facilityTypes into fields", () async {
      when(() => mockRefSvc.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.borrowerRole: <Reference>[
            Reference(id: 1, name: "Main"),
          ],
          ReferenceDataKeys.facilityTypes: <Reference>[
            Reference(id: 2, name: "TL"),
          ],
        },
      );

      await vm.loadReferenceDataWith(mockRefSvc);

      expect(vm.borrowerRole?.first.name, "Main");
      expect(vm.facilityType?.first.name, "TL");
    });
  });

  group("strategy comments", () {
    test("fetchAndSetStrategyComments filters comments", () async {
      when(
        () => mockRepository.getComments(
          CommentsType.contract,
          EntityIdentifier.contract,
          any(),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(
            strategyComment: "keep-category",
            categoryId: ServerConstants.contractCategoryID,
          ),
          Comment(
            strategyComment: "keep-code",
            categoryId: 99999,
          ),
          Comment(
            strategyComment: "drop",
            categoryId: 99999,
          ),
        ],
      );

      await vm.fetchAndSetStrategyComments(appRefNo: "APP-001");

      expect(vm.commentItem.length, 1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("fetchAndSetStrategyComments handles errors with default comment",
        () async {
      when(
        () => mockRepository.getComments(
          CommentsType.contract,
          EntityIdentifier.contract,
          any(),
        ),
      ).thenThrow(Exception("failed"));

      await vm.fetchAndSetStrategyComments(appRefNo: "APP-001");

      expect(vm.commentItem.length, 1);
      expect(vm.commentItem.first.strategyComment, "");
    });
  });

  group("submitComments", () {
    test("empty text early returns, no repo call", () async {
      vm.contractorCommentsController.text = "   ";

      await vm.submitComments();

      verifyNever(() => mockRepository.saveComment(any()));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success saves comment, clears draft, refreshes", () async {
      vm
        ..contract.contractCode = "C-001"
        ..contractorCommentsController.text = "hello";

      when(() => mockRepository.saveComment(any()))
          .thenAnswer((_) async => "OK");

      when(
        () => mockRepository.getComments(
          CommentsType.contract,
          EntityIdentifier.contract,
          any(),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(
            strategyComment: "hello",
            categoryId: ServerConstants.contractCategoryID,
          ),
        ],
      );

      await vm.submitComments();

      verify(() => mockRepository.saveComment(any())).called(1);
      expect(vm.contractorCommentsController.text, "");
      expect(vm.commentItem, isNotEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success with empty contract code skips refresh", () async {
      vm
        ..contract.contractCode = ""
        ..contractorCommentsController.text = "hello";

      when(() => mockRepository.saveComment(any()))
          .thenAnswer((_) async => "OK");

      await vm.submitComments();

      verify(() => mockRepository.saveComment(any())).called(1);
      verifyNever(
        () => mockRepository.getComments(
          CommentsType.contract,
          EntityIdentifier.contract,
          any(),
        ),
      );
    });

    test("repository error shows failure toast", () async {
      vm.contractorCommentsController.text = "hello";

      when(() => mockRepository.saveComment(any()))
          .thenThrow(Exception("save failed"));

      await vm.submitComments();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("borrower role", () {
    test("main contractor sets isMainContractor true", () {
      final Reference selected = Reference(
        id: ServerConstants.mainContractorId,
        name: "Main Contractor",
      );

      vm.onBorrowerRoleSelected(selected);

      expect(vm.selectedBorrowerRole, selected);
      expect(vm.contract.borrowerRole, "Main Contractor");
      expect(vm.contract.isMainContractor, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non-main contractor sets false", () {
      final Reference selected = Reference(id: 999, name: "Sub-Contractor");

      vm.onBorrowerRoleSelected(selected);

      expect(vm.selectedBorrowerRole, selected);
      expect(vm.contract.borrowerRole, "Sub-Contractor");
      expect(vm.contract.isMainContractor, false);
    });

    test("null name handled", () {
      final Reference selected =
          Reference(id: ServerConstants.mainContractorId);

      vm.onBorrowerRoleSelected(selected);

      expect(vm.contract.borrowerRole, isNull);
      expect(vm.contract.isMainContractor, true);
    });
  });

  group("PPC edit mode and debounce", () {
    test("enable/disable edit mode", () {
      vm.enablePpcEditMode();
      expect(vm.isPpcEditable, true);

      vm.disablePpcEditMode();
      expect(vm.isPpcEditable, false);
    });

    test("emitPpcSoft debounces", () async {
      vm.emitPpcSoft();
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("emitPpcSoft returns when restoring draft", () async {
      vm
        ..isRestoringDraft = true
        ..emitPpcSoft();

      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("buildNames", () {
    final List<Reference> options = <Reference>[
      Reference(id: 1, name: "One"),
      Reference(id: 2, name: "Two"),
      Reference(id: 3, name: "Three"),
    ];

    test("refs maps to comma names", () {
      final String s = vm.buildNames(
        refs: <Reference>[Reference(id: 1), Reference(id: 3)],
        options: options,
      );

      expect(s, "One, Three");
    });

    test("refs with unknown id uses --", () {
      final String s = vm.buildNames(
        refs: <Reference>[Reference(id: 999)],
        options: options,
      );

      expect(s, "--");
    });

    test("single id maps name", () {
      expect(vm.buildNames(options: options, id: 2), "Two");
    });

    test("fallbacks return --", () {
      expect(vm.buildNames(refs: <Reference>[], options: options), "--");
      expect(vm.buildNames(options: options, id: 999), "--");
      expect(vm.buildNames(options: options), "--");
    });
  });

  group("variation helpers", () {
    test("updateVariationField AED mode", () {
      vm
        ..contract.initialContractValue = "100.0"
        ..isAedRates = true
        ..contract.contractValue = "130.0"
        ..updateVariationField();

      expect(vm.variationController.text, isNotEmpty);
      expect(vm.contract.variationAmount, closeTo(30.0, 1e-6));
      expect(vm.contract.variationContractValue, isNotNull);
    });

    test("updateVariationField uses contractValueAedAmount when not AED", () {
      vm
        ..contract.initialContractValue = "100.0"
        ..isAedRates = false
        ..contract.contractValueAedAmount = "150.0"
        ..updateVariationField();

      expect(vm.variationController.text, isNotEmpty);
      expect(vm.contract.variationAmount, closeTo(50.0, 1e-6));
    });

    test("updateVariationField treats tiny diff as zero", () {
      vm
        ..contract.initialContractValue = "100.0000001"
        ..isAedRates = true
        ..contract.contractValue = "100.0000002"
        ..updateVariationField(epsilon: 1);

      expect(vm.contract.variationAmount, 0.0);
    });

    test("updateCompletionVariation writes diff", () {
      vm
        ..contract.originalCompletionDate = DateTime(2025)
        ..contract.expectedEndDate = DateTime(2025, 1, 15)
        ..updateCompletionVariation();

      expect(vm.variationCompletionDateController.text, "14");
      expect(vm.contract.variationCompletionDate, 14);
    });
  });

  group("PPC rows", () {
    test("rowHasAnyInput returns true when any field has value", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      expect(vm.rowHasAnyInput(c), true);

      c.dispose();
    });

    test("rowHasAnyInput returns false when all fields empty", () {
      final PpcRowControllers c = PpcRowControllers();

      expect(vm.rowHasAnyInput(c), false);

      c.dispose();
    });

    test("isRowBlank works", () {
      final PpcRowControllers c = PpcRowControllers();

      expect(vm.isRowBlank(c), true);

      c.ppcCtrl.text = "1";
      expect(vm.isRowBlank(c), false);

      c.dispose();
    });

    test("addPPCRow adds first row", () {
      vm.addPPCRow();

      expect(vm.ppcList.length, 1);
      expect(vm.ppcControllerss.length, 1);
      expect(vm.isNewRow, <bool>[true]);
    });

    test("addPPCRow prevents adding empty previous row", () {
      vm
        ..addPPCRow()
        ..addPPCRow();

      expect(vm.ppcList.length, 1);
    });

    test("addPPCRow allows when last gross value exists", () {
      vm.addPPCRow();
      vm.ppcControllerss.last.grossPPCValueCtrl.text = "100";

      vm.addPPCRow();

      expect(vm.ppcList.length, 2);
    });

    test("removePPCRow ignores invalid index", () {
      vm
        ..addPPCRow()
        ..removePPCRow(5)
        ..removePPCRow(-1);

      expect(vm.ppcList.length, 1);
    });

    test("removePPCRow removes row", () async {
      vm
        ..addPPCRow()
        ..removePPCRow(0);
      await Future<void>.delayed(Duration.zero);

      expect(vm.ppcList.length, 0);
      expect(vm.ppcControllerss.length, 0);
      expect(vm.isNewRow.length, 0);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("calculatePPCRowAtIndex computes values correctly", () {
      vm.addPPCRow();

      final PpcRowControllers c = vm.ppcControllerss[0];

      c.ppcCtrl.text = "1";
      c.grossPPCValueCtrl.text = "100";
      c.advancePaymentDeductionCtrl.text = "10";
      c.retentionDeductionCtrl.text = "5";
      c.vatAmountCtrl.text = "2";
      c.otherPaymentCtrl.text = "3";
      c.actualPaymentReceivedCtrl.text = "50";
      vm.contractorValueController.text = "200";

      vm.calculatePPCRowAtIndex(0);

      final PPC row = vm.ppcList[0];

      expect(row.ppcNo, "1.0");
      expect(row.grossValue, 100);
      expect(row.cumulativeValue, 100);
      expect(row.netValue, 85);
      expect(row.totalWithVat, 90);
      expect(row.workDone, 50);
      expect(row.cumulativeWorkDone, 50);
      expect(row.actualPaymentReceived, 50);
    });

    test("calculatePPCRowAtIndex clamps work done to 100", () {
      vm.addPPCRow();

      final PpcRowControllers c = vm.ppcControllerss[0];
      c.grossPPCValueCtrl.text = "500";
      vm.contractorValueController.text = "100";

      vm.calculatePPCRowAtIndex(0);

      expect(vm.ppcList[0].workDone, 100);
      expect(vm.ppcList[0].cumulativeWorkDone, 100);
    });

    test("calculatePPCRowAtIndex handles empty gross", () {
      vm
        ..addPPCRow()
        ..calculatePPCRowAtIndex(0);

      final PPC row = vm.ppcList[0];

      expect(row.cumulativeValue, 0);
      expect(row.netValue, 0);
      expect(row.totalWithVat, 0);
    });

    test("loadPpcFromApi binds data", () {
      final List<PPC> apiList = <PPC>[
        PPC(
          ppcNo: "1",
          ppcDate: "2025-01-01",
          grossValue: 100,
          advancePaymentDeduction: 10,
          retentionDeduction: 5,
          vatAmount: 2,
          otherPayment: 3,
          actualPaymentReceived: 50,
          datePaymentReceived: "2025-01-05",
        ),
      ];

      vm.loadPpcFromApi(apiList);

      expect(vm.ppcList.length, 1);
      expect(vm.ppcControllerss[0].ppcCtrl.text, "1");
      expect(vm.ppcControllerss[0].ppcDateCtrl.text, "2025-01-01");
      expect(vm.ppcControllerss[0].grossPPCValueCtrl.text, "100.0");
      expect(vm.ppcControllerss[0].advancePaymentDeductionCtrl.text, "10.0");
      expect(vm.ppcControllerss[0].retentionDeductionCtrl.text, "5.0");
      expect(vm.ppcControllerss[0].vatAmountCtrl.text, "2.0");
      expect(vm.ppcControllerss[0].otherPaymentCtrl.text, "3.0");
      expect(vm.ppcControllerss[0].actualPaymentReceivedCtrl.text, "50.0");
      expect(vm.ppcControllerss[0].datePaymentReceivedCtrl.text, "2025-01-05");
      expect(vm.isNewRow, <bool>[false]);
    });

    test("onSubmitted triggers calculation and emits", () {
      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "100";

      vm.onSubmitted(0);

      expect(vm.ppcList[0].grossValue, 100);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onChanged triggers calculation and debounce", () async {
      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "100";

      vm.onChanged(0);
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(vm.ppcList[0].grossValue, 100);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getTotalGrossPPC sums rows and supports ignoreIndex", () {
      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "100";

      expect(vm.getTotalGrossPPC(), 100);
      expect(vm.getTotalGrossPPC(ignoreIndex: 0), 0);
    });

    test("recalculateAllPPC handles valid totals", () {
      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "100";
      vm.contractorValueController.text = "1000";

      vm.recalculateAllPPC();

      expect(vm.ppcList[0].grossValue, 100);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("recalculateAllPPC shows error when total exceeds contract", () {
      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "2000";
      vm.contractorValueController.text = "1000";

      vm.recalculateAllPPC();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("PPC validators", () {
    test("numeric blank row empty value returns null", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "",
        fieldLabel: "Gross",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("numeric blank row valid value returns null", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "12345.123456",
        fieldLabel: "Gross",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("numeric blank row invalid value returns error", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "abc",
        fieldLabel: "Gross",
      );

      expect(result, contains("must be numeric"));
      c.dispose();
    });

    test("numeric row has input empty value returns required error", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "",
        fieldLabel: "Gross",
      );

      expect(result, contains("is required"));
      c.dispose();
    });

    test("numeric row has input valid value returns null", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "100",
        fieldLabel: "Gross",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("numeric row has input invalid value returns error", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "12345678901234567890",
        fieldLabel: "Gross",
      );

      expect(result, contains("must be numeric"));
      c.dispose();
    });

    test("numeric commas are ignored", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryNumericIfOther(
        c: c,
        value: "10,000.50",
        fieldLabel: "Gross",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("date blank row empty value returns null", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryDateIfOther(
        c: c,
        value: "",
        fieldLabel: "Date",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("date blank row valid returns null", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryDateIfOther(
        c: c,
        value: "12/12/2025",
        fieldLabel: "Date",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("date blank row invalid returns error", () {
      final PpcRowControllers c = PpcRowControllers();

      final String? result = vm.mandatoryDateIfOther(
        c: c,
        value: "2025-12-12",
        fieldLabel: "Date",
      );

      expect(result, contains("DD/MM/YYYY"));
      c.dispose();
    });

    test("date row has input empty returns required error", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      final String? result = vm.mandatoryDateIfOther(
        c: c,
        value: "",
        fieldLabel: "Date",
      );

      expect(result, contains("is required"));
      c.dispose();
    });

    test("date row has input valid returns null", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      final String? result = vm.mandatoryDateIfOther(
        c: c,
        value: "12/12/2025",
        fieldLabel: "Date",
      );

      expect(result, isNull);
      c.dispose();
    });

    test("date row has input invalid returns error", () {
      final PpcRowControllers c = PpcRowControllers();
      c.ppcCtrl.text = "1";

      final String? result = vm.mandatoryDateIfOther(
        c: c,
        value: "invalid",
        fieldLabel: "Date",
      );

      expect(result, contains("DD/MM/YYYY"));
      c.dispose();
    });
  });

  group("validateAllPPCRows", () {
    test("blank rows are skipped", () {
      vm.addPPCRow();

      expect(vm.validateAllPPCRows(), true);
    });

    test("missing PPC number returns false", () {
      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "100";

      expect(vm.validateAllPPCRows(), false);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("missing PPC date returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..grossPPCValueCtrl.text = "100";

      expect(vm.validateAllPPCRows(), false);
    });

    test("missing gross returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..advancePaymentDeductionCtrl.text = "0";

      expect(vm.validateAllPPCRows(), false);
    });

    test("missing advance returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..grossPPCValueCtrl.text = "100";

      expect(vm.validateAllPPCRows(), false);
    });

    test("missing retention returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..grossPPCValueCtrl.text = "100"
        ..advancePaymentDeductionCtrl.text = "0";

      expect(vm.validateAllPPCRows(), false);
    });

    test("missing vat returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..grossPPCValueCtrl.text = "100"
        ..advancePaymentDeductionCtrl.text = "0"
        ..retentionDeductionCtrl.text = "0";

      expect(vm.validateAllPPCRows(), false);
    });

    test("missing other payment returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..grossPPCValueCtrl.text = "100"
        ..advancePaymentDeductionCtrl.text = "0"
        ..retentionDeductionCtrl.text = "0"
        ..vatAmountCtrl.text = "0";

      expect(vm.validateAllPPCRows(), false);
    });

    test("total greater than cap returns false", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..grossPPCValueCtrl.text = "2000"
        ..advancePaymentDeductionCtrl.text = "0"
        ..retentionDeductionCtrl.text = "0"
        ..vatAmountCtrl.text = "0"
        ..otherPaymentCtrl.text = "0";

      vm.contractorValueController.text = "1000";

      expect(vm.validateAllPPCRows(), false);
    });

    test("valid PPC row returns true", () {
      vm.addPPCRow();
      final PpcRowControllers c = vm.ppcControllerss[0];
      //
      // ignore: cascade_invocations
      c
        ..ppcCtrl.text = "1"
        ..ppcDateCtrl.text = "01/01/2025"
        ..grossPPCValueCtrl.text = "100"
        ..advancePaymentDeductionCtrl.text = "0"
        ..retentionDeductionCtrl.text = "0"
        ..vatAmountCtrl.text = "0"
        ..otherPaymentCtrl.text = "0";

      vm.contractorValueController.text = "1000";

      expect(vm.validateAllPPCRows(), true);
    });
  });

  group("onSubmit", () {
    testWidgets("invalid form shows failure toast",
        (WidgetTester tester) async {
      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => "required",
      );

      await vm.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("invalid PPC blocks submit", (WidgetTester tester) async {
      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      vm.addPPCRow();
      vm.ppcControllerss[0].grossPPCValueCtrl.text = "100";

      await vm.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    testWidgets("invalid dates block submit", (WidgetTester tester) async {
      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      vm
        ..onStartDateSubmitted2(DateTime(2025, 5, 10))
        ..onCompletionDateSubmitted2(DateTime(2025, 5));

      await vm.onSubmit(tester.element(find.byType(Form)));

      expect(vm.completionDateValidate, true);
    });

    testWidgets("legacy completionDateValidate flag blocks submit",
        (WidgetTester tester) async {
      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      vm
        ..completionDateValidate = true
        ..contract.expectedStartDate = DateTime(2025)
        ..contract.expectedEndDate = DateTime(2025, 2)
        ..contract.projectTenor = 1
        ..selectedCurrencyLabel = "AED"
        ..contractorValueController.text = "100";

      await vm.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showWarningToast(any())).called(1);
    });

    testWidgets("missing required fields block submit",
        (WidgetTester tester) async {
      await pumpFormShell(
        tester,
        formKey: vm.formKey,
        validator: (_) => null,
      );

      vm
        ..contract.expectedStartDate = null
        ..contract.expectedEndDate = null
        ..contract.projectTenor = null
        ..selectedCurrencyLabel = null
        ..contractorValueController.text = "";

      await vm.onSubmit(tester.element(find.byType(Form)));

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    testWidgets("success path saves contract and navigates", (tester) async {
      final GoRouter router = await pumpRouterShell(
        tester,
        child: Builder(
          builder: (BuildContext context) {
            return Form(
              key: vm.formKey,
              child: ElevatedButton(
                onPressed: () async => vm.onSubmit(context),
                child: const Text("save"),
              ),
            );
          },
        ),
      );

      vm
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2))
        ..selectedCurrencyLabel = "AED"
        ..contractorValueController.text = "100"
        ..contractorCommentsController.text = "hello"
        ..ppcList = <PPC>[]
        ..ppcControllerss = <PpcRowControllers>[]
        ..completionDateValidate = false;

      when(() => mockRepository.saveComment(any()))
          .thenAnswer((_) async => "OK");
      when(() => mockRepository.saveContractDetail(any()))
          .thenAnswer((_) async => "OK");

      await tester.tap(find.text("save"));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveContractDetail(any())).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(vm.deleteDraftCalled, true);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        Routes.editViewProject,
      );
    });

    testWidgets("repository error shows failure toast", (tester) async {
      await pumpRouterShell(
        tester,
        child: Builder(
          builder: (BuildContext context) {
            return Form(
              key: vm.formKey,
              child: ElevatedButton(
                onPressed: () async => vm.onSubmit(context),
                child: const Text("save"),
              ),
            );
          },
        ),
      );

      vm
        ..onStartDateSubmitted2(DateTime(2025))
        ..onCompletionDateSubmitted2(DateTime(2025, 2))
        ..selectedCurrencyLabel = "AED"
        ..contractorValueController.text = "100"
        ..ppcList = <PPC>[]
        ..ppcControllerss = <PpcRowControllers>[]
        ..completionDateValidate = false;

      when(() => mockRepository.saveContractDetail(any()))
          .thenThrow(Exception("save failed"));

      await tester.tap(find.text("save"));
      await tester.pumpAndSettle();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  testWidgets("onReset navigates to editViewProject", (tester) async {
    final GoRouter router = await pumpRouterShell(
      tester,
      child: Builder(
        builder: (BuildContext context) {
          return ElevatedButton(
            onPressed: () async => vm.onReset(context),
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

  group("clean / role helpers / close", () {
    test("clean handles null and string null", () {
      expect(vm.clean(null), "");
      expect(vm.clean("null"), "");
      expect(vm.clean("Null"), "");
      expect(vm.clean("NULL"), "");
      expect(vm.clean("Hello"), "Hello");
      expect(vm.clean(123), "123");
      expect(vm.clean(false), "false");
    });

    test("editAccessRolesCheck returns bool", () {
      expect(vm.editAccessRolesCheck(), isA<bool>());
    });

    test("viewAccessRolesCheck returns bool", () {
      expect(vm.viewAccessRolesCheck(), isA<bool>());
    });

    test("disposeControllers clears PPC controllers", () {
      vm
        ..addPPCRow()
        ..disposeControllers();

      expect(vm.ppcControllerss, isEmpty);
    });

    test("close clears PPC controllers and unregisters draft", () async {
      final TestEditContractViewModel local = TestEditContractViewModel()
        ..addPPCRow();

      await local.close();

      expect(local.ppcControllerss, isEmpty);
      expect(local.unregisterDraftCallbackCalled, true);
    });

    test("PpcRowControllers dispose does not throw", () {
      final PpcRowControllers c = PpcRowControllers();

      expect(c.dispose, returnsNormally);
    });
  });
}
