import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/models/request/sic_code.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "MockBuildContext";
  }
}

class FakeSicCodeReviewState extends Fake implements SicCodeReviewState {}

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

class TestableSicCodeReviewViewModel extends SicCodeReviewViewModel {
  bool shouldThrowInInit = false;
  bool testCanEdit = false;

  bool getChildRimsCalled = false;
  bool getSicCalled = false;
  bool getReferenceCalled = false;
  bool getStrategyCommentCalled = false;
  bool registerDraftCalled = false;
  bool loadDraftCalled = false;
  bool deleteDraftCalled = false;
  bool unregisterDraftCalled = false;

  String? lastCustomerRimNo;

  @override
  bool get canEdit => testCanEdit;

  @override
  Future<void> getChildRimsForGroup() async {
    getChildRimsCalled = true;

    if (shouldThrowInInit) {
      throw Exception("init failed");
    }
  }

  @override
  Future<void> getSICcodeReviewData({String? customerRimNo}) async {
    getSicCalled = true;
    lastCustomerRimNo = customerRimNo;

    customerSICcodeReview = <SicCodeReview>[
      SicCodeReview(
        rimNo: 1001,
        customerName: "Customer 1",
        primaryBusinessActivity: "Trading",
        proposedSicCode: "12345",
      ),
    ];

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> getReferenceData() async {
    getReferenceCalled = true;

    proposedSICcodes = <Reference>[
      Reference(id: 1, name: "SIC A"),
    ];
  }

  @override
  Future<void> getStategyComment() async {
    getStrategyCommentCalled = true;

    comment = Comment(strategyComment: "Comment from test");
    controllerAccountLevelSicCode.text = "Comment from test";

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  void registerDraftCallback() {
    registerDraftCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftCalled = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCalled = true;
  }

  @override
  Future<void> delay() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  late SicCodeReviewViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockCommonRepository mockCommonRepository;
  late MockReferenceDataService mockReferenceService;
  late MockAlertManager mockAlertManager;
  late MockBuildContext mockContext;
  late MockLocalStorageService mockLocalStorageService;
  late MockCustomerRepository mockCustomerRepository;

  setUpAll(() async {
    registerFallbackValue(FakeSicCodeReviewState());
    registerFallbackValue(Comment());
    registerFallbackValue(<SicCodeReview>[]);

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check" || call.method == "checkConnectivity") {
          return <String>["wifi"];
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockReferenceService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();
    mockContext = MockBuildContext();
    mockLocalStorageService = MockLocalStorageService();
    mockCustomerRepository = MockCustomerRepository();

    LocalStorageService().getStorage = mockLocalStorageService;
    AlertManager.overrideInstance = mockAlertManager;
    ReferenceDataService.overrideInstance = mockReferenceService;
    CommonRepository.overrideInstance = mockCommonRepository;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    when(
      () => mockCommonRepository.saveStategyComment(
        any(),
        appRefNo: any(named: "appRefNo"),
        rimNo: any(named: "rimNo"),
      ),
    ).thenAnswer((_) async => "success");

    when(
      () => mockCommonRepository.getStategyComment(
        any(),
        any(),
        appRefNo: any(named: "appRefNo"),
      ),
    ).thenAnswer((_) async => <Comment>[]);

    Globals.request = null;
    Globals.applicationDetails = null;

    viewModel = SicCodeReviewViewModel()
      ..repository = mockRepository
      ..repositoryCustomer = mockCustomerRepository
      ..context = mockContext;
  });

  tearDown(() async {
    if (!viewModel.isClosed) {
      await viewModel.close();
    }

    Globals.request = null;
    Globals.applicationDetails = null;
  });

  group("SicCodeReviewState", () {
    test("constructor sets loaderStatus", () {
      const SicCodeReviewState state = SicCodeReviewState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing loaderStatus when null", () {
      const SicCodeReviewState original = SicCodeReviewState(
        loaderStatus: LoadingStatus.loaded,
      );

      final SicCodeReviewState copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides loaderStatus", () {
      const SicCodeReviewState original = SicCodeReviewState(
        loaderStatus: LoadingStatus.loaded,
      );

      final SicCodeReviewState updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("SicCodeReviewViewModel getters and draft config", () {
    test("initial state is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("canEdit is true only when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, true);

      viewModel.pageMode = PageMode.view;
      expect(viewModel.canEdit, false);

      viewModel.pageMode = PageMode.na;
      expect(viewModel.canEdit, false);
    });

    test("draftModuleKey returns customerInformation", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.customerInformation);
    });

    test("draftFormKey returns sicCodeReview route", () {
      expect(viewModel.draftFormKey, Routes.sicCodeReview);
    });

    test("draftHandler returns SicCodeReviewDraftHandler", () {
      expect(viewModel.draftHandler, isA<SicCodeReviewDraftHandler>());
    });
  });

  group("getSelectedCustomer", () {
    test("returns empty Customer when Globals.request is null", () {
      Globals.request = null;

      final Customer customer = viewModel.getSelectedCustomer();

      expect(customer, isA<Customer>());
      expect(customer.customerName, isNull);
      expect(customer.firstName, isNull);
      expect(customer.customerRimNo, isNull);
    });

    test("returns first customer from Globals.request", () {
      Globals.request = Request(
        customers: <Customer>[
          Customer(
            customerName: "Test Customer",
            customerRimNo: 123456,
          ),
        ],
      );

      final Customer customer = viewModel.getSelectedCustomer();

      expect(customer.firstName, "Test Customer");
      expect(customer.customerName, "Test Customer");
      expect(customer.customerRimNo, 123456);
    });
  });

  group("getSICcodeReviewData", () {
    test("assigns returned SIC code review data", () async {
      final List<SicCodeReview> mockData = <SicCodeReview>[
        SicCodeReview(
          rimNo: 1001,
          customerName: "Customer 1",
          primaryBusinessActivity: "Trading",
          proposedSicCode: "12345",
        ),
        SicCodeReview(
          rimNo: 1002,
          customerName: "Customer 2",
          primaryBusinessActivity: "Software",
          proposedSicCode: "54321",
        ),
      ];

      when(
        () => mockRepository.getSICcodeReviewData(
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenAnswer((_) async => mockData);

      await viewModel.getSICcodeReviewData(customerRimNo: "1001");

      expect(viewModel.customerSICcodeReview, mockData);
      expect(viewModel.customerSICcodeReview?.length, 2);
      expect(viewModel.customerSICcodeReview?.first.customerName, "Customer 1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockRepository.getSICcodeReviewData(customerRimNo: "1001"),
      ).called(1);
    });

    test("assigns empty list when repository returns empty list", () async {
      when(
        () => mockRepository.getSICcodeReviewData(
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenAnswer((_) async => <SicCodeReview>[]);

      await viewModel.getSICcodeReviewData(customerRimNo: "2001");

      expect(viewModel.customerSICcodeReview, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockRepository.getSICcodeReviewData(customerRimNo: "2001"),
      ).called(1);
    });

    test("throws when repository throws", () async {
      when(
        () => mockRepository.getSICcodeReviewData(
          customerRimNo: any(named: "customerRimNo"),
        ),
      ).thenThrow(Exception("SIC fetch failed"));

      await expectLater(
        viewModel.getSICcodeReviewData(customerRimNo: "3001"),
        throwsA(isA<Exception>()),
      );
    });
  });

  group("getReferenceData", () {
    test("assigns proposedSICcodes from reference service", () async {
      final List<Reference> referenceList = <Reference>[
        Reference(id: 1, name: "SIC A"),
        Reference(id: 2, name: "SIC B"),
      ];

      when(
        () => mockReferenceService.getReferenceData(
          <String>[ReferenceDataKeys.sicCodeList],
        ),
      ).thenAnswer(
        (_) async => <String, List<Reference>>{
          ReferenceDataKeys.sicCodeList: referenceList,
        },
      );

      await viewModel.getReferenceData();

      expect(viewModel.proposedSICcodes, referenceList);
      expect(viewModel.proposedSICcodes?.length, 2);

      verify(
        () => mockReferenceService.getReferenceData(
          <String>[ReferenceDataKeys.sicCodeList],
        ),
      ).called(1);
    });

    test("assigns null when sic code key is missing", () async {
      when(
        () => mockReferenceService.getReferenceData(
          <String>[ReferenceDataKeys.sicCodeList],
        ),
      ).thenAnswer((_) async => <String, List<Reference>>{});

      await viewModel.getReferenceData();

      expect(viewModel.proposedSICcodes, isNull);
    });

    test("throws when reference service throws", () async {
      when(
        () => mockReferenceService.getReferenceData(
          <String>[ReferenceDataKeys.sicCodeList],
        ),
      ).thenThrow(Exception("Reference failed"));

      await expectLater(
        viewModel.getReferenceData(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group("init", () {
    test("fetches all data, registers draft and emits loaded", () async {
      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..testCanEdit = true
        ..context = mockContext;

      Globals.request = Request(
        customers: <Customer>[
          Customer(
            customerName: "Init Customer",
            customerRimNo: 777,
          ),
        ],
      );

      await vm.init(mockContext);

      expect(vm.request, Globals.request);
      expect(vm.selectedCustomer?.customerName, "Init Customer");
      expect(vm.selectedCustomer?.customerRimNo, 777);
      expect(vm.getChildRimsCalled, true);
      expect(vm.getSicCalled, true);
      expect(vm.getReferenceCalled, true);
      expect(vm.getStrategyCommentCalled, true);
      expect(vm.registerDraftCalled, true);
      expect(vm.loadDraftCalled, true);
      expect(vm.lastCustomerRimNo, "777");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });

    test("does not register draft when not editable", () async {
      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..testCanEdit = false
        ..context = mockContext;

      Globals.request = Request(
        customers: <Customer>[
          Customer(
            customerName: "Readonly Customer",
            customerRimNo: 778,
          ),
        ],
      );

      await vm.init(mockContext);

      expect(vm.getChildRimsCalled, true);
      expect(vm.getSicCalled, true);
      expect(vm.getReferenceCalled, true);
      expect(vm.getStrategyCommentCalled, true);
      expect(vm.registerDraftCalled, false);
      expect(vm.loadDraftCalled, false);
      expect(vm.lastCustomerRimNo, "778");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });

    test("shows failure toast when init dependency throws", () async {
      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..shouldThrowInInit = true
        ..context = mockContext;

      Globals.request = Request(
        customers: <Customer>[
          Customer(
            customerName: "Init Customer",
            customerRimNo: 888,
          ),
        ],
      );

      await vm.init(mockContext);

      expect(vm.getChildRimsCalled, true);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      await vm.close();
    });
  });

  group("onCustomerSeletion", () {
    test("updates selected customer and reloads data", () async {
      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..testCanEdit = false
        ..context = mockContext;

      final Customer selected = Customer(
        customerName: "Selected Customer",
        customerRimNo: 555,
      );

      await vm.onCustomerSeletion(selected);

      expect(vm.selectedCustomer, selected);
      expect(vm.getSicCalled, true);
      expect(vm.getStrategyCommentCalled, true);
      expect(vm.lastCustomerRimNo, "555");
      expect(vm.loadDraftCalled, false);

      await vm.close();
    });

    test("loads draft after customer selection when editable", () async {
      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..testCanEdit = true
        ..context = mockContext;

      final Customer selected = Customer(
        customerName: "Editable Customer",
        customerRimNo: 556,
      );

      await vm.onCustomerSeletion(selected);

      expect(vm.selectedCustomer, selected);
      expect(vm.getSicCalled, true);
      expect(vm.getStrategyCommentCalled, true);
      expect(vm.loadDraftCalled, true);
      expect(vm.lastCustomerRimNo, "556");

      await vm.close();
    });
  });

  group("onSaveSic", () {
    testWidgets("calls form save and saves SIC when proposed SIC exists",
        (WidgetTester tester) async {
      var formSaved = false;

      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..repository = mockRepository
        ..selectedCustomer = Customer(customerRimNo: 999)
        ..comment = Comment(strategyComment: "Save comment")
        ..customerSICcodeReview = <SicCodeReview>[
          SicCodeReview(
            rimNo: 999,
            customerName: "Customer",
            proposedSicCode: "12345",
          ),
        ];

      when(
        () => mockRepository.saveSICcodeReview(any()),
      ).thenAnswer((_) async => "success");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "value",
                onSaved: (_) {
                  formSaved = true;
                },
              ),
            ),
          ),
        ),
      );

      await vm.onSaveSic();

      expect(formSaved, true);
      expect(vm.deleteDraftCalled, true);
      expect(vm.getStrategyCommentCalled, true);

      verify(() => mockRepository.saveSICcodeReview(any())).called(1);

      verify(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: 999,
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));

      await vm.close();
    });

    testWidgets("calls form save and handles repository save failure",
        (WidgetTester tester) async {
      var formSaved = false;

      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..repository = mockRepository
        ..selectedCustomer = Customer(customerRimNo: 998)
        ..comment = Comment(strategyComment: "Save comment")
        ..customerSICcodeReview = <SicCodeReview>[
          SicCodeReview(
            rimNo: 998,
            customerName: "Customer",
            proposedSicCode: "12345",
          ),
        ];

      when(
        () => mockRepository.saveSICcodeReview(any()),
      ).thenThrow(Exception("save failed"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "value",
                onSaved: (_) {
                  formSaved = true;
                },
              ),
            ),
          ),
        ),
      );

      await vm.onSaveSic();

      expect(formSaved, true);
      expect(vm.deleteDraftCalled, false);

      verify(() => mockRepository.saveSICcodeReview(any())).called(1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));

      await vm.close();
    });

    testWidgets("does not call repository save when list is empty",
        (WidgetTester tester) async {
      var formSaved = false;

      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..repository = mockRepository
        ..selectedCustomer = Customer(customerRimNo: 111)
        ..comment = Comment(strategyComment: "No list")
        ..customerSICcodeReview = <SicCodeReview>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "value",
                onSaved: (_) {
                  formSaved = true;
                },
              ),
            ),
          ),
        ),
      );

      await vm.onSaveSic();

      expect(formSaved, true);
      expect(vm.deleteDraftCalled, true);
      expect(vm.getStrategyCommentCalled, true);

      verifyNever(() => mockRepository.saveSICcodeReview(any()));

      verify(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: 111,
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));

      await vm.close();
    });

    testWidgets("does not call repository save when no proposed SIC exists",
        (WidgetTester tester) async {
      var formSaved = false;

      final TestableSicCodeReviewViewModel vm = TestableSicCodeReviewViewModel()
        ..repository = mockRepository
        ..selectedCustomer = Customer(customerRimNo: 222)
        ..comment = Comment(strategyComment: "No SIC")
        ..customerSICcodeReview = <SicCodeReview>[
          SicCodeReview(
            rimNo: 222,
            customerName: "Customer",
          ),
        ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "value",
                onSaved: (_) {
                  formSaved = true;
                },
              ),
            ),
          ),
        ),
      );

      await vm.onSaveSic();

      expect(formSaved, true);
      expect(vm.deleteDraftCalled, true);
      expect(vm.getStrategyCommentCalled, true);

      verifyNever(() => mockRepository.saveSICcodeReview(any()));

      verify(
        () => mockCommonRepository.saveStategyComment(
          any(),
          appRefNo: any(named: "appRefNo"),
          rimNo: 222,
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));

      await vm.close();
    });
  });

  group("getChildRimsForGroup", () {
    test("completes safely for non-group application", () async {
      await viewModel.getChildRimsForGroup();

      expect(viewModel.customerList, isA<List<Customer>?>());
    });
  });

  group("getChildRimsForGroup actual implementation", () {
    test("loads child rims and selects first customer when group application",
        () async {
      Globals.request = Request(groupId: 1);

      final List<Customer> customers = <Customer>[
        Customer(
          customerName: "Child Customer 1",
          customerRimNo: 101,
        ),
        Customer(
          customerName: "Child Customer 2",
          customerRimNo: 102,
        ),
      ];

      when(() => mockCustomerRepository.getChildRimsForGroup())
          .thenAnswer((_) async => customers);

      viewModel.repositoryCustomer = mockCustomerRepository;

      await viewModel.getChildRimsForGroup();

      expect(viewModel.customerList, customers);
      expect(viewModel.selectedCustomer?.customerName, "Child Customer 1");
      expect(viewModel.selectedCustomer?.customerRimNo, 101);

      verify(() => mockCustomerRepository.getChildRimsForGroup()).called(1);
    });

    test("keeps selectedCustomer unchanged when child rim list is empty",
        () async {
      Globals.request = Request(groupId: 1);

      final Customer oldCustomer = Customer(
        customerName: "Old Customer",
        customerRimNo: 999,
      );

      viewModel
        ..selectedCustomer = oldCustomer
        ..repositoryCustomer = mockCustomerRepository;

      when(() => mockCustomerRepository.getChildRimsForGroup())
          .thenAnswer((_) async => <Customer>[]);

      await viewModel.getChildRimsForGroup();

      expect(viewModel.customerList, isEmpty);
      expect(viewModel.selectedCustomer, oldCustomer);

      verify(() => mockCustomerRepository.getChildRimsForGroup()).called(1);
    });

    test("rethrows error when getChildRimsForGroup repository fails", () async {
      Globals.request = Request(groupId: 1);

      viewModel.repositoryCustomer = mockCustomerRepository;

      when(() => mockCustomerRepository.getChildRimsForGroup())
          .thenThrow(Exception("child rim failed"));

      await expectLater(
        viewModel.getChildRimsForGroup(),
        throwsA(isA<Exception>()),
      );

      verify(() => mockCustomerRepository.getChildRimsForGroup()).called(1);
    });
  });

  group("getStategyComment actual implementation", () {
    test("sets empty comment when repository returns null", () async {
      Globals.request = Request(applicationRefNo: "APP-001");

      viewModel.selectedCustomer = Customer(
        customerName: "Customer 1",
        customerRimNo: 1001,
      );

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getStategyComment();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isA<Comment>());
      expect(viewModel.comment.strategyComment, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: "APP-001",
        ),
      ).called(1);
    });

    test("sets empty comment when repository returns empty list", () async {
      Globals.request = Request(applicationRefNo: "APP-002");

      viewModel.selectedCustomer = Customer(
        customerName: "Customer 2",
        customerRimNo: 1002,
      );

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getStategyComment();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isA<Comment>());
      expect(viewModel.comment.strategyComment, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: "APP-002",
        ),
      ).called(1);
    });

    test("sets empty comment when no comment matches selected customer rim",
        () async {
      Globals.request = Request(applicationRefNo: "APP-003");

      viewModel.selectedCustomer = Customer(
        customerName: "Selected Customer",
        customerRimNo: 2001,
      );

      final List<Comment> comments = <Comment>[
        Comment(
          id: 1,
          rimNo: 9999,
          strategyComment: "Other customer comment",
        ),
      ];

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getStategyComment();

      expect(viewModel.comments, comments);
      expect(viewModel.comment.strategyComment, isNull);
      expect(viewModel.controllerAccountLevelSicCode.text, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: "APP-003",
        ),
      ).called(1);
    });

    test("selects latest matching customer comment and updates controller",
        () async {
      Globals.request = Request(applicationRefNo: "APP-004");

      viewModel.selectedCustomer = Customer(
        customerName: "Selected Customer",
        customerRimNo: 3001,
      );

      final List<Comment> comments = <Comment>[
        Comment(
          id: 1,
          rimNo: 3001,
          strategyComment: "Old comment",
        ),
        Comment(
          id: 5,
          rimNo: 3001,
          strategyComment: "Latest comment",
        ),
        Comment(
          id: 3,
          rimNo: 9999,
          strategyComment: "Other customer comment",
        ),
      ];

      when(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: any(named: "appRefNo"),
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getStategyComment();

      expect(viewModel.comments, comments);
      expect(viewModel.comment.id, 5);
      expect(viewModel.comment.rimNo, 3001);
      expect(viewModel.comment.strategyComment, "Latest comment");
      expect(viewModel.controllerAccountLevelSicCode.text, "Latest comment");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockCommonRepository.getStategyComment(
          any(),
          any(),
          appRefNo: "APP-004",
        ),
      ).called(1);
    });
  });

  group("delay", () {
    test("completes successfully", () async {
      await viewModel.delay();

      expect(true, isTrue);
    });
  });

  group("close", () {
    test("unregisters draft callback and completes", () async {
      final TestableSicCodeReviewViewModel vm =
          TestableSicCodeReviewViewModel();

      await vm.close();

      expect(vm.unregisterDraftCalled, true);
      expect(vm.isClosed, true);
    });
  });

  group("otherCACCPBDPRolesCheck", () {
    test("returns false when application details are null", () {
      Globals.applicationDetails = null;

      final bool result = viewModel.otherCACCPBDPRolesCheck();

      expect(result, false);
    });
  });
}
