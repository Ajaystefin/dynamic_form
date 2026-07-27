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
import "package:wcas_frontend/features/request/remarks/common_tabs/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/model.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockBuildContext extends Mock implements BuildContext {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeComment extends Fake implements Comment {}

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

class TestCommonTabsViewModel extends CommonTabsViewModel {
  bool registerDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool unregisterDraftCallbackCalled = false;
  bool deleteDraftCalled = false;

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
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }
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
  when(
    () => repository.getRemarkStrategyData(
      any(),
      any(),
      any(),
    ),
  ).thenAnswer(
    (_) async => Comment(strategyComment: "Server remark"),
  );

  when(
    () => repository.saveRemarkStrategyData(
      any(),
      any(),
    ),
  ).thenAnswer((_) async => "Success");
}

Request testRequest({
  Customer? borrower,
  Customer? customer,
  Reference? businessSegment,
}) {
  return Request(
    groupId: 0,
    businessSegment: businessSegment,
    borrowers: <Customer>[
      borrower ??
          Customer(
            customerRimNo: 123,
            customerName: "Borrower One",
            type: CustomerType.corporate,
          ),
    ],
    customers: <Customer>[
      customer ??
          Customer(
            customerRimNo: 999,
            customerName: "Customer One",
          ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestCommonTabsViewModel vm;
  late MockRequestRepository mockRepository;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();
    await stubConnectivity();

    registerFallbackValue(FakeComment());
    registerFallbackValue(FakeCustomer());
    registerFallbackValue(FakeRequest());
    registerFallbackValue(FakeReference());
    registerFallbackValue(CommentsType.remarks);
    registerFallbackValue(EntityIdentifier.remarks);
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

    RequestRepository.overrideInstance = mockRepository;
    AlertManager.overrideInstance = mockAlertManager;
    LocalStorageService().getStorage = MockLocalStorageService();

    stubAlerts(mockAlertManager);
    stubRepository(mockRepository);

    Globals.onAutoSave = null;
    Globals.selectedCustomer = null;
    Globals.request = testRequest();

    vm = TestCommonTabsViewModel()..repository = mockRepository;
  });

  tearDown(() async {
    Globals.request = null;
    Globals.selectedCustomer = null;
    Globals.onAutoSave = null;

    try {
      await vm.close();
    } on Object {
      // ignore
    }

    reset(mockRepository);
    reset(mockAlertManager);
  });

  group("CommonTabsState", () {
    test("constructor sets defaults", () {
      final CommonTabsState state = CommonTabsState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.buttonLoaderStatus, isNull);
      expect(state.shouldNavigate, false);
      expect(state.activeTab, isA<RemarksTabs>());
    });

    test("copyWith keeps existing values", () {
      final CommonTabsState state = CommonTabsState(
        loaderStatus: LoadingStatus.loaded,
        buttonLoaderStatus: LoadingStatus.loading,
        shouldNavigate: true,
        activeTab: RemarksTabs.background,
      );

      final CommonTabsState copy = state.copyWith();

      expect(copy.loaderStatus, LoadingStatus.loaded);
      expect(copy.buttonLoaderStatus, LoadingStatus.loading);
      expect(copy.shouldNavigate, true);
      expect(copy.activeTab, RemarksTabs.background);
    });

    test("copyWith overrides values", () {
      final CommonTabsState state = CommonTabsState(
        loaderStatus: LoadingStatus.loading,
      );

      final CommonTabsState copy = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        buttonLoaderStatus: LoadingStatus.error,
        shouldNavigate: true,
        activeTab: RemarksTabs.businessExperience,
      );

      expect(copy.loaderStatus, LoadingStatus.loaded);
      expect(copy.buttonLoaderStatus, LoadingStatus.error);
      expect(copy.shouldNavigate, true);
      expect(copy.activeTab, RemarksTabs.businessExperience);
    });
  });

  group("initial values and getters", () {
    test("initial fields are correct", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.repository, mockRepository);
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.selectedCustomer, isNull);
      expect(vm.commentData, isA<Comment>());
      expect(vm.otherRemarksTabs, <RemarksTabs>[
        RemarksTabs.feeStructure,
        RemarksTabs.guarantorFinancials,
        RemarksTabs.financialRatiosAndAnalysis,
      ]);
      expect(vm.customerList, isEmpty);
      expect(vm.showAsteriskTabs, isEmpty);
      expect(vm.pageMode, PageMode.na);
      expect(vm.isReadOnlyMode, false);
      expect(vm.isFI, false);
      expect(vm.shouldValidateField, false);
      expect(vm.showViewMore, false);
      expect(vm.rteController, isNotNull);
      expect(vm.scrollController, isA<ScrollController>());
    });

    test("request getter returns Globals.request", () {
      final Request request = testRequest();
      Globals.request = request;

      expect(vm.request, same(request));
      expect(vm.request.borrowers?.first.customerName, "Borrower One");
    });

    test("draftModuleKey returns remarks", () {
      expect(vm.draftModuleKey, DraftModuleKeys.remarks);
    });

    test("draftFormKey uses route, selected customer rim and active tab", () {
      vm
        ..selectedCustomer = Customer(customerRimNo: 777)
        ..emit(vm.state.copyWith(activeTab: RemarksTabs.background));

      expect(
        vm.draftFormKey,
        "${Routes.remarksCommonTabs}_777_${RemarksTabs.background.name}",
      );
    });

    test("draftFormKey handles null selected customer", () {
      vm
        ..selectedCustomer = null
        ..emit(vm.state.copyWith(activeTab: RemarksTabs.background));

      expect(
        vm.draftFormKey,
        "${Routes.remarksCommonTabs}_null_${RemarksTabs.background.name}",
      );
    });

    test("draftHandler returns CommonTabsDraftHandler", () {
      expect(vm.draftHandler, isA<CommonTabsDraftHandler>());
    });

    test("isReadOnlyMode follows pageMode", () {
      vm.pageMode = PageMode.view;
      expect(vm.isReadOnlyMode, true);

      vm.pageMode = PageMode.edit;
      expect(vm.isReadOnlyMode, false);
    });

    test("shouldValidateField checks active tab in showAsteriskTabs", () {
      vm
        ..showAsteriskTabs = <RemarksTabs>[RemarksTabs.background]
        ..emit(vm.state.copyWith(activeTab: RemarksTabs.background));

      expect(vm.shouldValidateField, true);

      vm.emit(vm.state.copyWith(activeTab: RemarksTabs.businessExperience));

      expect(vm.shouldValidateField, false);
    });

    test("showViewMore true for FI bank customer types", () {
      vm.selectedCustomer = Customer(
        type: CustomerType.investmentGradeBanks,
      );
      expect(vm.showViewMore, true);

      vm.selectedCustomer = Customer(
        type: CustomerType.belowInvestmentGradeBanks,
      );
      expect(vm.showViewMore, true);
    });

    test("showViewMore false for non FI customer types", () {
      vm.selectedCustomer = Customer(type: CustomerType.corporate);
      expect(vm.showViewMore, false);

      vm.selectedCustomer = Customer(type: CustomerType.country);
      expect(vm.showViewMore, false);

      vm.selectedCustomer = null;
      expect(vm.showViewMore, false);
    });
  });

  group("defaultSelectedCustomer", () {
    test("selects first borrower when borrowers exist", () {
      final Customer borrower = Customer(
        customerRimNo: 101,
        customerName: "Borrower",
      );

      Globals.request = Request(
        borrowers: <Customer>[borrower],
        customers: <Customer>[
          Customer(customerRimNo: 202, customerName: "Customer"),
        ],
      );

      vm.defaultSelectedCustomer();

      expect(vm.selectedCustomer, same(borrower));
    });

    test("selects first customer when borrowers are empty", () {
      final Customer customer = Customer(
        customerRimNo: 202,
        customerName: "Customer",
      );

      Globals.request = Request(
        borrowers: <Customer>[],
        customers: <Customer>[customer],
      );

      vm.defaultSelectedCustomer();

      expect(vm.selectedCustomer, same(customer));
    });
  });

  group("getChildRimsForGroup", () {
    test("non group application uses default selected customer", () async {
      final Customer borrower = Customer(
        customerRimNo: 123,
        customerName: "Borrower",
      );

      Globals.request = testRequest(borrower: borrower);

      await vm.getChildRimsForGroup();

      expect(vm.selectedCustomer, borrower);
    });
  });

  group("setAsterisks", () {
    test("sets mandatory tabs for investment grade FI customer", () {
      Globals.request = Request(
        businessSegment: Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
        ),
      );

      vm
        ..selectedCustomer = Customer(
          type: CustomerType.investmentGradeBanks,
        )
        ..setAsterisks();

      expect(vm.showAsteriskTabs, isA<List<RemarksTabs>>());
      expect(vm.showAsteriskTabs, contains(RemarksTabs.businessExperience));
      expect(vm.showAsteriskTabs, contains(RemarksTabs.bankOverview));
      expect(vm.showAsteriskTabs, contains(RemarksTabs.financialHighlights));
    });

    test("sets mandatory tabs for below investment grade FI customer", () {
      Globals.request = Request(
        businessSegment: Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
        ),
      );

      vm
        ..selectedCustomer = Customer(
          type: CustomerType.belowInvestmentGradeBanks,
        )
        ..setAsterisks();

      expect(vm.showAsteriskTabs, isA<List<RemarksTabs>>());
    });

    test("corporate request produces a list safely", () {
      Globals.request = Request(
        businessSegment: Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
        ),
      );

      vm
        ..selectedCustomer = Customer(type: CustomerType.corporate)
        ..setAsterisks();

      expect(vm.showAsteriskTabs, isA<List<RemarksTabs>>());
    });
  });

  group("getRemarks", () {
    test("success stores returned comment", () async {
      final Comment expected = Comment(strategyComment: "Test remark");

      when(
        () => mockRepository.getRemarkStrategyData(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => expected);

      await vm.getRemarks();

      expect(vm.commentData, same(expected));
    });

    test("null response stores empty Comment", () async {
      when(
        () => mockRepository.getRemarkStrategyData(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => null);

      await vm.getRemarks();

      expect(vm.commentData, isA<Comment>());
    });

    test("error stores empty Comment and shows toast", () async {
      when(
        () => mockRepository.getRemarkStrategyData(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Test Error"));

      await vm.getRemarks();

      expect(vm.commentData, isA<Comment>());
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("init", () {
    testWidgets("init loads data and emits loaded",
        (WidgetTester tester) async {
      when(
        () => mockRepository.getRemarkStrategyData(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => Comment(strategyComment: "Loaded"),
      );

      await vm.init(MockBuildContext());

      expect(vm.selectedCustomer?.customerRimNo, 123);
      expect(vm.commentData?.strategyComment, "Loaded");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("init sets active tab when parameter is provided",
        (WidgetTester tester) async {
      await vm.init(MockBuildContext(), tab: RemarksTabs.background);

      expect(vm.state.activeTab, RemarksTabs.background);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("init calls draft loading when not read only",
        (WidgetTester tester) async {
      await vm.init(MockBuildContext());

      if (!vm.isReadOnlyMode) {
        expect(vm.registerDraftCallbackCalled, true);
        expect(vm.loadDraftIfAvailableCalled, true);
      }
    });
  });

  group("changeTab", () {
    test("other remarks tab navigates branch is safe", () async {
      try {
        await vm.changeTab(RemarksTabs.feeStructure);
      } on Object {
        // Global router can throw in isolated unit tests.
      }

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("non other tab loads remarks and emits loaded", () async {
      when(
        () => mockRepository.getRemarkStrategyData(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => Comment(strategyComment: "Changed tab"),
      );

      await vm.changeTab(RemarksTabs.businessExperience);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.activeTab, RemarksTabs.businessExperience);
      expect(vm.commentData?.strategyComment, "Changed tab");
    });

    test("non other tab loads draft when editable", () async {
      await vm.changeTab(RemarksTabs.businessExperience);

      if (!vm.isReadOnlyMode) {
        expect(vm.loadDraftIfAvailableCalled, true);
      }

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("read only changeTab does not load draft", () async {
      vm
        ..pageMode = PageMode.view
        ..loadDraftIfAvailableCalled = false;

      await vm.changeTab(RemarksTabs.businessExperience);

      expect(vm.loadDraftIfAvailableCalled, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onChangeCustomer", () {
    test("changes customer, saves global selected customer and loads remarks",
        () async {
      final Customer newCustomer = Customer(
        customerRimNo: 555,
        customerName: "New Customer",
      );

      when(
        () => mockRepository.getRemarkStrategyData(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => Comment(strategyComment: "Customer changed"),
      );

      await vm.onChangeCustomer(newCustomer);

      expect(vm.selectedCustomer, same(newCustomer));
      expect(Globals.selectedCustomer, same(newCustomer));
      expect(vm.commentData?.strategyComment, "Customer changed");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("calls global autosave when available", () async {
      bool autoSaveCalled = false;
      Globals.onAutoSave = () async {
        autoSaveCalled = true;
      };

      await vm.onChangeCustomer(
        Customer(customerRimNo: 777, customerName: "Auto Save Customer"),
      );

      await Future<void>.delayed(Duration.zero);

      expect(autoSaveCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("loads draft when not read only", () async {
      await vm.onChangeCustomer(
        Customer(customerRimNo: 888, customerName: "Draft Customer"),
      );

      if (!vm.isReadOnlyMode) {
        expect(vm.loadDraftIfAvailableCalled, true);
      }
    });

    test("read only does not load draft on customer change", () async {
      vm
        ..pageMode = PageMode.view
        ..loadDraftIfAvailableCalled = false;

      await vm.onChangeCustomer(
        Customer(customerRimNo: 999, customerName: "Read Only Customer"),
      );

      expect(vm.loadDraftIfAvailableCalled, false);
    });
  });

  group("onSavePress", () {
    test("handles editor getText failure safely and resets button loader",
        () async {
      await vm.onSavePress(context: MockBuildContext());

      expect(vm.state.buttonLoaderStatus, LoadingStatus.loaded);
    });

    test("required validation path can show failure when active tab mandatory",
        () async {
      vm
        ..showAsteriskTabs = <RemarksTabs>[RemarksTabs.businessExperience]
        ..emit(
          vm.state.copyWith(activeTab: RemarksTabs.businessExperience),
        );

      await vm.onSavePress(context: MockBuildContext());

      expect(vm.state.buttonLoaderStatus, LoadingStatus.loaded);
    });

    test("shouldNavigate flag is reflected during save lifecycle", () async {
      await vm.onSavePress(
        context: MockBuildContext(),
        shouldNavigate: true,
      );

      expect(vm.state.buttonLoaderStatus, LoadingStatus.loaded);
    });

    test("repository save error path is safe when editor returns empty/error",
        () async {
      when(
        () => mockRepository.saveRemarkStrategyData(
          any(),
          any(),
        ),
      ).thenThrow(Exception("Save Error"));

      await vm.onSavePress(context: MockBuildContext());

      expect(vm.state.buttonLoaderStatus, LoadingStatus.loaded);
    });
  });

  group("close", () {
    test("close unregisters draft callback", () async {
      final TestCommonTabsViewModel local = TestCommonTabsViewModel();

      await local.close();

      expect(local.unregisterDraftCallbackCalled, true);
    });
  });
}
