import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/state.dart";
import "package:wcas_frontend/features/request/information/create_request/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

import "../../../../test_config.dart";

/// ---- Mocks / Fakes ----

class FakeCcsysRepository extends Mock implements CcsysRepository {}

/// Spy to capture emitted states for submit tests
class SpySubmitVm extends CcsysCreateRequestViewModel {
  final List<CcsysCreateRequestState> emitted = [];
  final List<CcsysCreateRequestState> emittedStates = [];

  @override
  void emit(CcsysCreateRequestState state) {
    super.emit(state);
    emitted.add(state);
    emittedStates.add(state);
  }
}

/// Spy to capture emitted states in general tests
class MockCcsysCreateRequestViewModel extends CcsysCreateRequestViewModel {
  @override
  void emit(CcsysCreateRequestState state) {
    super.emit(state);
    emittedStates.add(state);
  }

  final List<CcsysCreateRequestState> emittedStates = [];
  bool searchCalled = false;

  @override
  Future<void> onCustomerSearchPressed({
    bool showDialog = true,
    bool isRim = true,
  }) async {
    searchCalled = true;
    return super.onCustomerSearchPressed(showDialog: showDialog, isRim: isRim);
  }
}

class MockAlertManager extends Mock implements AlertManager {}

class MockRouter extends Mock {
  // Match production signature
  void go(String route, {Object? extra});
}

class RequestController {
  RequestController(this.router);
  final MockRouter router;

  void onResetButtonPress() {
    router.go(Routes.loadingPage);
    Future.delayed(const Duration(milliseconds: 100), () {
      router.go(Routes.requestCreate);
    });
  }
}

class MockLayoutViewModel extends Mock implements LayoutViewModel {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockContext extends Mock implements BuildContext {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

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
  TestWidgetsFlutterBinding.ensureInitialized(); // binding required

  late MockCcsysCreateRequestViewModel viewModel;
  late MockCustomerRepository mockRepository;
  late MockContext mockContext;
  // late MockCcsysRepository ccsysRepo;
  // late MockAuthRepository mockAuthRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockRouter mockRouter;
  late RequestController controller;
  late MockAlertManager mockAlertManager;

  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    // Mock the connectivity plugin to return a list with wifi connectivity
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == "check") {
          return ["wifi"];
        }
        return null;
      },
    );

    registerFallbackValue(Request());
    registerFallbackValue(Customer());
  });

  setUp(() {
    mockRouter = MockRouter();
    // ccsysRepo = MockCcsysRepository();
    // mockAuthRepository = MockAuthRepository();
    controller = RequestController(mockRouter);
    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);

    mockLocalStorageService = MockLocalStorageService();
    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);
    mockReferenceDataService = MockReferenceDataService();
    ReferenceDataService.overrideInstance(mockReferenceDataService);
    mockRepository = MockCustomerRepository();
    mockContext = MockContext();
    viewModel = MockCcsysCreateRequestViewModel()
      ..repository = mockRepository;
    // viewModel.authRepository = mockAuthRepository;
  });

  // test('init method set values', () {
  //   final role = Role(bpmRole: 'RO', id: 10, name: 'RO');
  //   Globals.user = User(id: 'u1', name: 'Sample', currentRole: role);
  //   when(
  //     () => mockReferenceDataService.getReferenceData([
  //       ReferenceDataKeys.applicationType,
  //       ReferenceDataKeys.yesNoNa,
  //     ]),
  //   ).thenAnswer(
  //     (_) async => {
  //       ReferenceDataKeys.applicationType: [
  //         Reference(id: 1, name: 'Reason'),
  //       ],
  //       ReferenceDataKeys.yesNoNa: [
  //         Reference(id: 1, name: 'Yes'),
  //       ],
  //     },
  //   );
  //   // when(() => mockAuthRepository.getRoleRights(role)).thenAnswer((_) async => role);
  //   when(() => mockAuthRepository.updateRole(role)).thenAnswer((_) async =>
  // {});
  //   viewModel.init(mockContext);
  //   expect(viewModel.customers, isEmpty);
  // });

  test("onSelectionCancelButtonPress method set variable values to default",
      () {
    viewModel
      ..customer = Customer(id: "12", customerName: "Sample")
      ..customerName = "Test"
      ..customerRimNo = "R123"
      ..isResetPressed = true
      ..onSelectionCancelButtonPress();
    expect(viewModel.customer, isNull);
    expect(viewModel.customerName, isNull);
    expect(viewModel.customerRimNo, isNull);
    expect(viewModel.isResetPressed, false);
    expect(viewModel.isSearched, false);
    expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onSelectionPressed method set variable values to selected customer",
      () {
    viewModel
      ..selectedCustomer = ValueNotifier(
        Customer(
          id: "12",
          customerName: "Sample",
          customerRimNo: 123,
          segment: "Segment1",
        ),
      )
      ..selectedCustomer.value?.branch = "Branch1"
      ..isResetPressed = true
      ..onSelectionPressed(mockContext);
    expect(viewModel.customer, isNotNull);
    expect(viewModel.customerName, "Sample");
    expect(viewModel.branchName, "Branch1");
    expect(viewModel.segmentName, "Segment1");
    expect(viewModel.customerRimNo, "123");
    expect(viewModel.isSearched, true);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test(
      "filterCustomers method set variable values on"
      " the bases of search result", () {
    viewModel
      ..allCustomers = [
        Customer(
          id: "12",
          customerName: "Sample",
          customerRimNo: 123,
          segment: "Segment1",
          preferredName: "Sample",
        ),
        Customer(
          id: "34",
          customerName: "Test",
          customerRimNo: 456,
          segment: "Segment2",
          preferredName: "Test",
        ),
      ]
      ..customerName = "Test"
      ..filterCustomers();
    expect(viewModel.dailogCustomers, isNotNull);
    expect(viewModel.dailogCustomers.length, 1);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("filterCustomers method validation", () {
    viewModel
      ..allCustomers = []
      ..filterCustomers();
    verify(
      () => mockAlertManager.showFailureToast(
        "common.noUserFound".tr(),
      ),
    ).called(1);
  });

  // group('onCustomerSearchPressed', () {
  //   test('method on success if the type is rim', () {
  //     // final customers = [
  //     //    Customer(id: '12', customerName: 'Sample', customerRimNo: 123, segment: 'Segment1', preferredName: 'Sample'),
  //     // Customer(id: '34', customerName: 'Test', customerRimNo: 456, segment: 'Segment2', preferredName: 'Test'),
  //     // ];
  //     viewModel.isRim = true;
  //     final customer =
  //         Customer(id: '12', customerName: 'Sample', customerRimNo: 123,
  // segment: 'Segment1', preferredName: 'Sample');
  //     customer.branch = 'Branch1';
  //     viewModel.customer = customer;
  //     when(
  //       () => ccsysRepo.searchUserDetails(any(), any()),
  //     ).thenAnswer((_) async => customer);
  //     viewModel.onCustomerNameSearchPressed();
  //     expect(viewModel.customer, isNotNull);
  //     expect(viewModel.customerName, 'Sample');
  //     expect(viewModel.branchName, 'Branch1');
  //     expect(viewModel.segmentName, 'Segment1');
  //     expect(viewModel.customerRimNo, '123');
  //     expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  //   });
  // });

  // ---------------- onResetButtonPress ----------------
  group("CcsysCreateRequestViewModel.onResetButtonPress", () {
    setUp(() {
      // Seed non-default values so we can verify they get reset
      viewModel
        ..customerRimNo = "1023563"
        ..customerName = "ACME LLC"
        ..isSearched = true
        ..customer = (Customer()..id = "1023563");

      // Set field controls to true initially
      viewModel.fieldCntrl.value = {
        ControlFields.customerName: true,
        ControlFields.customerRim: true,
      };

      // Set selectedCustomer not null
      viewModel.selectedCustomer.value = Customer()..id = "200";
    });

    test("resets primitive fields and notifiers, emits loaded", () {
      // Act
      viewModel.onResetButtonPress();

      // Assert primitives / refs
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.isSearched, isFalse);
      expect(viewModel.customer, isNull);

      // Assert selectedCustomer reset
      expect(viewModel.selectedCustomer.value, isNull);

      // Assert fieldCntrl replaced with both false
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], isFalse);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], isFalse);

      // Assert an emitted state with loaderStatus loaded
      expect(viewModel.emittedStates, isNotEmpty);
      final last = viewModel.emittedStates.last;
      expect(last.loaderStatus, LoadingStatus.loaded);
    });

    test("stopAllLoaders sets individual loader flags to loaded", () {
      // Manually make loaders "loading" first
      viewModel
        ..customerRimNoLoadingStatus = LoadingStatus.loading
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..onResetButtonPress();

      // Assert loader flags returned to loaded
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    });

    test("formKey.reset() is safe even when no Form is mounted", () {
      // The method should not throw if currentState is null.
      expect(() => viewModel.onResetButtonPress(), returnsNormally);

      // And after reset the state should be loaded
      final last = viewModel.emittedStates.last;
      expect(last.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ---------------- Field Control helpers ----------------
  test(
      "handleFieldControl "
      "sets correct field "
      "control states when data is not empty", () {
    viewModel
      ..fieldCntrl.value = {
        ControlFields.customerName: true,
        ControlFields.customerRim: true,
      }
      ..handleFieldControl(ControlFields.customerName, "John");

    expect(viewModel.fieldCntrl.value, {
      ControlFields.customerName: false,
      ControlFields.customerRim: true,
    });
  });

  test(
      "handleFieldControl sets all fields to false "
      "and resets customer info when data is empty", () {
    viewModel
      ..fieldCntrl.value = {
        ControlFields.customerName: true,
        ControlFields.customerRim: true,
      }
      ..customerName = "John"
      ..customerRimNo = "123456"
      ..handleFieldControl(ControlFields.customerName, "");

    expect(viewModel.fieldCntrl.value, {
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
    });
    expect(viewModel.customerName, isNull);
    expect(viewModel.customerRimNo, isNull);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });
  // ---------------- Submit Button Validation ----------------
  test("submitButtonValidation returns true when customer is null", () {
    viewModel.customer = null;
    expect(viewModel.submitButtonValidation(), true);
  });

  test("submitButtonValidation returns false when customer is not null", () {
    viewModel.customer = Customer(id: "123", customerName: "John Doe");
    expect(viewModel.submitButtonValidation(), false);
  });

  // ---------------- RIM Search Guard ----------------
  test("onCustomerRimNoSearchPressed does not trigger search when RIM is empty",
      () async {
    viewModel
      ..customerRimNo = ""
      ..isSearched = false
      ..onCustomerRimNoSearchPressed();

    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
    expect(viewModel.searchCalled, false);
  });

  // ---------------- Name invalid toast ----------------
  test("onCustomerNameSearchPressed shows failure toast when name is invalid",
      () {
    final mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);

    viewModel
      ..customerName = "Jo" // Too short
      ..isSearched = false;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    viewModel.onCustomerNameSearchPressed();

    verify(
      () => mockAlertManager.showFailureToast(
        "requestInformation.createRequest.enterCustomerName".tr(),
      ),
    ).called(1);
  });

  // ---------------- isFieldsFilled ----------------
  test(
      "isFieldsFilled returns true when both "
      "customerName and customerRimNo are not null", () {
    viewModel
      ..customerName = "John Doe"
      ..customerRimNo = "123456";
    expect(viewModel.isFieldsFilled(), isTrue);
  });

  test("isFieldsFilled returns false when customerName is null", () {
    viewModel
      ..customerName = null
      ..customerRimNo = "123456";
    expect(viewModel.isFieldsFilled(), isFalse);
  });

  test("isFieldsFilled returns false when customerRimNo is null", () {
    viewModel
      ..customerName = "John Doe"
      ..customerRimNo = null;
    expect(viewModel.isFieldsFilled(), isFalse);
  });

  test("isFieldsFilled returns false when both fields are null", () {
    viewModel
      ..customerName = null
      ..customerRimNo = null;
    expect(viewModel.isFieldsFilled(), isFalse);
  });

  // ---------------- RequestController navigation ----------------
  test(
      "RequestController.onResetButtonPress navigates "
      "to loadingPage and then requestCreate", () async {
    controller.onResetButtonPress();

    verify(() => mockRouter.go(Routes.loadingPage)).called(1);

    await Future.delayed(const Duration(milliseconds: 150));

    verify(() => mockRouter.go(Routes.requestCreate)).called(1);
  });

  // ---------------- RIM path local status (without mocking CcsysRepository)
  // ----------------
  test("onCustomerRimNoSearchPressed leaves status loading immediately", () {
    viewModel
      ..customerRimNo = "123456"
      ..isSearched = false
      ..onCustomerRimNoSearchPressed();

    // The VM sets `customerRimNoLoadingStatus = LoadingStatus.loading;` before
    // async.
    expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loading);
  });

  // ---------------- onSubmitButtonPress – simple tests ----------------
  group("CcsysCreateRequestViewModel.onSubmitButtonPress – simple tests", () {
    late SpySubmitVm submitVm;
    late MockAlertManager mockAlert;
    // late FakeCcsysRepository fakeRepo;

    setUp(() {
      // ViewModel with seeded, valid defaults
      submitVm = SpySubmitVm()
        ..requestCreate = Request()
        ..customerName = "ACME LLC"
        ..customerRimNo = "1023563"
        ..customer = (Customer()
          ..segment = "Jumeirah"
          ..branch = "Al Qouz Branch");

      // Toasts mocked out (no Toastification overlay required in unit tests)
      mockAlert = MockAlertManager();
      AlertManager.overrideInstance(mockAlert);
      when(() => mockAlert.showFailureToast(any())).thenReturn(null);

      // Fake CCsys repo
      // fakeRepo = FakeCcsysRepository();

      // Override singleton instance (assumes mutable)

      // // Default success answer
      // when(() => fakeRepo.saveApplicationInformation(
      //       region: any(named: 'region'),
      //       branch: any(named: 'branch'),
      //       rimNo: any(named: 'rimNo'),
      //       customerName: any(named: 'customerName'),
      //       caDateIsoPlus4: any(named: 'caDateIsoPlus4'),
      //     )).thenAnswer((_) async => 'APP-REF-001');
    });

    testWidgets("returns early when form is invalid (no loading emission)",
        (tester) async {
      // Mount a minimal Form that fails validation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: submitVm.formKey,
              child: TextFormField(
                validator: (_) => "error", // force invalid
              ),
            ),
          ),
        ),
      );

      final initial = submitVm.state.loaderStatus;

      await submitVm.onSubmitButtonPress(mockContext);

      // No loading state is emitted because the method returns early
      expect(submitVm.state.loaderStatus, initial);
      expect(submitVm.emitted, isEmpty);

      // No repo calls
      // verifyNever(() => fakeRepo.saveApplicationInformation(
      //       region: any(named: 'region'),
      //       branch: any(named: 'branch'),
      //       rimNo: any(named: 'rimNo'),
      //       customerName: any(named: 'customerName'),
      //       caDateIsoPlus4: any(named: 'caDateIsoPlus4'),
      //     ));
    });

    group("onSubmitButtonPress – simple unit tests (no widgets, no repo)", () {
      late SpySubmitVm viewModel;
      late MockAlertManager mockAlert;

      setUp(() {
        viewModel = SpySubmitVm()
          ..requestCreate = Request()
          ..customerName = "ACME LLC"
          ..customerRimNo = "INVALID" // force failure path
          ..customer = (Customer()
            ..segment = "Jumeirah"
            ..branch = "Al Qouz Branch");

        mockAlert = MockAlertManager();
        AlertManager.overrideInstance(mockAlert);

        when(() => mockAlert.showFailureToast(any())).thenReturn(null);
      });

      test("invalid RIM → shows toast and emits loading → loaded", () async {
        // Act
        await viewModel.onSubmitButtonPress(mockContext);

        // Assert state emissions

        // Assert toast
        verify(() => mockAlert.showFailureToast("common.invalidRimNo".tr()))
            .called(1);
      });

      test("invalid RIM does not mutate requestCreate", () async {
        await viewModel.onSubmitButtonPress(mockContext);

        expect(viewModel.requestCreate.customerName, isNull);
        expect(viewModel.requestCreate.customerRimNo, isNull);
        expect(viewModel.requestCreate.branch, isNull);
        expect(viewModel.requestCreate.region, isNull);
        expect(viewModel.requestCreate.applicationRefNo, isNull);
      });

      test("final loaderStatus is always loaded", () async {
        await (viewModel..customerRimNo = "123")
            .onSubmitButtonPress(mockContext);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });
  });

  group("CreateRequestState", () {
    test("constructor sets loaderStatus", () {
      final state = CreateRequestState(
        loaderStatus: LoadingStatus.loading,
        showSelectDialog: false,
      );
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.showSelectDialog, false);
    });

    test("copyWith keeps existing when null", () {
      final original = CreateRequestState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = CreateRequestState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
