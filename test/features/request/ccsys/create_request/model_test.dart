import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

import "../../../../test_config.dart";

class MockAlertManager extends Mock implements AlertManager {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockContext extends Mock implements BuildContext {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockRouter extends Mock {
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

class TestableCcsysCreateRequestViewModel extends CcsysCreateRequestViewModel {
  TestableCcsysCreateRequestViewModel({
    this.stubGetReferenceDatas,
    this.stubOnCustomerSearchPressed,
  });

  final Future<void> Function()? stubGetReferenceDatas;
  final Future<void> Function({
    bool showDialog,
    bool isRim,
  })? stubOnCustomerSearchPressed;

  final List<CcsysCreateRequestState> emittedStates = [];

  bool getReferenceDatasCalled = false;
  bool searchCalled = false;
  bool lastSearchShowDialog = true;
  bool lastSearchIsRim = true;

  @override
  void emit(CcsysCreateRequestState state) {
    super.emit(state);
    emittedStates.add(state);
  }

  @override
  Future<void> getReferenceDatas() async {
    getReferenceDatasCalled = true;
    if (stubGetReferenceDatas != null) {
      await stubGetReferenceDatas!.call();
      return;
    }
    return super.getReferenceDatas();
  }

  @override
  Future<void> onCustomerSearchPressed({
    bool showDialog = true,
    bool isRim = true,
  }) async {
    searchCalled = true;
    lastSearchShowDialog = showDialog;
    lastSearchIsRim = isRim;

    if (stubOnCustomerSearchPressed != null) {
      await stubOnCustomerSearchPressed!(
        showDialog: showDialog,
        isRim: isRim,
      );
      return;
    }

    return super.onCustomerSearchPressed(
      showDialog: showDialog,
      isRim: isRim,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestableCcsysCreateRequestViewModel viewModel;
  late MockCustomerRepository mockCustomerRepository;
  late MockCcsysRepository mockCcsysRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockContext mockContext;
  late MockAlertManager mockAlertManager;
  late MockRouter mockRouter;
  late RequestController controller;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

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
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String>[]);
    registerFallbackValue(<Reference>[]);
  });

  setUp(() {
    mockRouter = MockRouter();
    controller = RequestController(mockRouter);

    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance = mockAlertManager;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showWarningToast(any())).thenReturn(null);
    when(() => mockAlertManager.showInfoToast(any())).thenReturn(null);

    mockLocalStorageService = MockLocalStorageService();
    LocalStorageService().getStorage = mockLocalStorageService;

    mockCustomerRepository = MockCustomerRepository();
    mockCcsysRepository = MockCcsysRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockContext = MockContext();

    ReferenceDataService.overrideInstance = mockReferenceDataService;

    Globals.request = Request();

    viewModel = TestableCcsysCreateRequestViewModel()
      ..repository = mockCustomerRepository
      ..repositoryCCSYS = mockCcsysRepository
      ..requestCreate = Request();
  });

  tearDown(() async {
    if (!viewModel.isClosed) {
      await viewModel.close();
    }
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async => null,
    );
  });

  group("constructor and initial state", () {
    test("sets default values", () {
      final vm = CcsysCreateRequestViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.formFocusNode, isA<FocusNode>());
      expect(vm.applicationDetails, isA<ApplicationDetails>());
      expect(vm.fieldCntrl.value[ControlFields.customerName], false);
      expect(vm.fieldCntrl.value[ControlFields.customerRim], false);
      expect(vm.showError, true);
      expect(vm.customerRimNo, isNull);
      expect(vm.customerName, isNull);
      expect(vm.branchName, isNull);
      expect(vm.branchNo, isNull);
      expect(vm.segmentName, isNull);
      expect(vm.isRim, true);
      expect(vm.isSearched, false);
      expect(vm.dailogCustomers, isEmpty);
      expect(vm.allCustomers, isEmpty);
      expect(vm.selectedButtonModelVN.value, isNull);
      expect(vm.selectedCustomer.value, isNull);
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(vm.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(vm.isResetPressed, false);
      expect(vm.customers, isEmpty);
      expect(vm.customer, isNull);
      expect(vm.referenceData, isEmpty);
      expect(vm.applicationType, isEmpty);
      expect(vm.branchType, isEmpty);
      expect(vm.pageMode, PageMode.na);
      expect(vm.canEdit, false);
    });
  });

  group("getReferenceDatas", () {
    test("success sets applicationType and branchType", () async {
      final application = Reference(
        id: ServerConstants.ccsysAppReferenceId,
        name: "CCSYS",
      );
      final branch = Reference(
        id: 1,
        name: "Branch",
        reference1: "10",
        reference2: "Region",
      );

      when(
        () => mockReferenceDataService.getReferenceData([
          ReferenceDataKeys.applicationType,
          ReferenceDataKeys.branchList,
          ReferenceDataKeys.yesNoNa,
        ]),
      ).thenAnswer(
        (_) async => {
          ReferenceDataKeys.applicationType: [application],
          ReferenceDataKeys.branchList: [branch],
          ReferenceDataKeys.yesNoNa: [Reference(id: 1, name: "Yes")],
        },
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.referenceData, isNotEmpty);
      expect(viewModel.applicationType.length, 1);
      expect(viewModel.applicationType.first.id, application.id);
      expect(viewModel.branchType.length, 1);
      expect(viewModel.branchType.first.reference2, "Region");
    });

    test("failure rethrows", () async {
      when(
        () => mockReferenceDataService.getReferenceData(any()),
      ).thenThrow(Exception("reference error"));

      expect(
        () async => viewModel.getReferenceDatas(),
        throwsA(anything),
      );
    });
  });

  group("field helpers", () {
    test("isFieldsFilled returns true when both fields are not null", () {
      viewModel
        ..customerName = "John Doe"
        ..customerRimNo = "123456";

      expect(viewModel.isFieldsFilled(), true);
    });

    test("isFieldsFilled returns false when customerName is null", () {
      viewModel
        ..customerName = null
        ..customerRimNo = "123456";

      expect(viewModel.isFieldsFilled(), false);
    });

    test("isFieldsFilled returns false when customerRimNo is null", () {
      viewModel
        ..customerName = "John Doe"
        ..customerRimNo = null;

      expect(viewModel.isFieldsFilled(), false);
    });

    test("isFieldsFilled returns false when both fields are null", () {
      viewModel
        ..customerName = null
        ..customerRimNo = null;

      expect(viewModel.isFieldsFilled(), false);
    });

    test("submitButtonValidation returns true when customer is null", () {
      viewModel.customer = null;

      expect(viewModel.submitButtonValidation(), true);
    });

    test("submitButtonValidation returns false when customer is not null", () {
      viewModel.customer = Customer(id: "123", customerName: "John Doe");

      expect(viewModel.submitButtonValidation(), false);
    });

    test("handleFieldControl sets correct states when data is not empty", () {
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

    test("handleFieldControl resets customer info when data is empty", () {
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
  });

  group("selection", () {
    test("onSelectionCancelButtonPress resets values", () {
      viewModel
        ..customer = Customer(id: "12", customerName: "Sample")
        ..customerName = "Test"
        ..customerRimNo = "R123"
        ..isResetPressed = true
        ..isSearched = true
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..customerRimNoLoadingStatus = LoadingStatus.loading
        ..fieldCntrl.value = {
          ControlFields.customerName: true,
          ControlFields.customerRim: true,
        }
        ..onSelectionCancelButtonPress();

      expect(viewModel.customer, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.isResetPressed, false);
      expect(viewModel.isSearched, false);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSelectionPressed shows toast when no customer selected", () {
      viewModel.selectedCustomer.value = null;

      viewModel.onSelectionPressed(mockContext);

      verify(
        () => mockAlertManager.showFailureToast("common.selectValue".tr()),
      ).called(1);
      expect(viewModel.customer, isNull);
    });

    test("onSelectionPressed sets values from selected customer", () {
      final customer = Customer(
        id: "12",
        customerName: "Sample",
        customerRimNo: 123,
        segment: "Segment1",
      )
        ..branch = "Branch1"
        ..branchNo = 11;

      viewModel
        ..selectedCustomer = ValueNotifier(customer)
        ..onSelectionPressed(mockContext);

      expect(viewModel.customer, isNotNull);
      expect(viewModel.customerName, "Sample");
      expect(viewModel.branchName, "Branch1");
      expect(viewModel.branchNo, 11);
      expect(viewModel.segmentName, "Segment1");
      expect(viewModel.customerRimNo, "123");
      expect(viewModel.isSearched, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSelectionPressed uses default branch and segment values", () {
      viewModel
        ..selectedCustomer = ValueNotifier(
          Customer(
            id: "12",
            customerName: "Sample",
            customerRimNo: 123,
          ),
        )
        ..onSelectionPressed(mockContext);

      expect(viewModel.branchName, ServerConstants.defaultBranch);
      expect(viewModel.branchNo, ServerConstants.defaultBranchNo);
      expect(viewModel.segmentName, ServerConstants.defaultSegment);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("filterCustomers", () {
    test("shows toast when allCustomers is empty", () {
      viewModel
        ..allCustomers = []
        ..filterCustomers();

      verify(
        () => mockAlertManager.showFailureToast("common.noUserFound".tr()),
      ).called(1);
    });

    test("copies all customers when search term is empty", () {
      final first = Customer(
        id: "12",
        customerName: "Sample",
        preferredName: "Sample",
      );
      final second = Customer(
        id: "34",
        customerName: "Test",
        preferredName: "Test",
      );

      viewModel
        ..allCustomers = [first, second]
        ..customerName = ""
        ..filterCustomers();

      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.dailogCustomers.first, first);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("filters customers by preferredName", () {
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

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first?.preferredName, "Test");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("ignores null customers while filtering", () {
      viewModel
        ..allCustomers = [
          null,
          Customer(
            id: "34",
            customerName: "Test",
            preferredName: "Test",
          ),
        ]
        ..customerName = "Test"
        ..filterCustomers();

      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.dailogCustomers.first?.customerName, "Test");
    });

    test("returns empty dialog customers when no match", () {
      viewModel
        ..allCustomers = [
          Customer(
            id: "34",
            customerName: "Test",
            preferredName: "Test",
          ),
        ]
        ..customerName = "Missing"
        ..filterCustomers();

      expect(viewModel.dailogCustomers, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("customer search buttons", () {
    test("onCustomerNameSearchPressed shows failure toast for invalid name",
        () {
      viewModel
        ..customerName = "Jo"
        ..isSearched = false
        ..onCustomerNameSearchPressed();

      verify(
        () => mockAlertManager.showFailureToast(
          "requestInformation.createRequest.enterCustomerName".tr(),
        ),
      ).called(1);
    });

    test("onCustomerNameSearchPressed triggers search for valid name",
        () async {
      final vm = TestableCcsysCreateRequestViewModel(
        stubOnCustomerSearchPressed: ({
          bool showDialog = true,
          bool isRim = true,
        }) async {},
      )
        ..repository = mockCustomerRepository
        ..repositoryCCSYS = mockCcsysRepository
        ..requestCreate = Request()
        ..customerName = "Valid Name"
        ..isSearched = false
        ..onCustomerNameSearchPressed(showDialog: false);

      expect(vm.customerNameLoadingStatus, LoadingStatus.loading);
      expect(vm.searchCalled, true);
      expect(vm.lastSearchShowDialog, false);
      expect(vm.lastSearchIsRim, false);

      await vm.close();
    });

    test("onCustomerRimNoSearchPressed does not search when RIM is empty", () {
      viewModel
        ..customerRimNo = ""
        ..isSearched = false
        ..onCustomerRimNoSearchPressed();

      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.searchCalled, false);
    });

    test("onCustomerRimNoSearchPressed searches when RIM exists", () async {
      final vm = TestableCcsysCreateRequestViewModel(
        stubOnCustomerSearchPressed: ({
          bool showDialog = true,
          bool isRim = true,
        }) async {},
      )
        ..repository = mockCustomerRepository
        ..repositoryCCSYS = mockCcsysRepository
        ..requestCreate = Request()
        ..customerRimNo = "123456"
        ..isSearched = false
        ..onCustomerRimNoSearchPressed();

      expect(vm.customerRimNoLoadingStatus, LoadingStatus.loading);
      expect(vm.searchCalled, true);
      expect(vm.lastSearchIsRim, true);

      await vm.close();
    });

    test("onCustomerRimNoSearchPressed skips when already searched", () {
      viewModel
        ..customerRimNo = "123456"
        ..isSearched = true
        ..onCustomerRimNoSearchPressed();

      expect(viewModel.searchCalled, false);
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
    });
  });

  group("onCustomerSearchPressed rim path", () {
    test("rim search success sets customer fields", () async {
      final customer = Customer(
        id: "9001",
        customerName: "Rim Customer",
        customerRimNo: 9001,
        segment: "Segment",
      )
        ..branch = "Branch"
        ..branchNo = 44;

      when(
        () => mockCcsysRepository.searchUserDetails(any(), any()),
      ).thenAnswer((_) async => customer);

      viewModel
        ..customerRimNo = "9001"
        ..customerName = "";

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "9001");
      expect(viewModel.customerName, "Rim Customer");
      expect(viewModel.branchName, "Branch");
      expect(viewModel.branchNo, 44);
      expect(viewModel.segmentName, "Segment");
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("rim search success uses default branch values", () async {
      final customer = Customer(
        id: "9002",
        customerName: "Rim Customer",
      );

      when(
        () => mockCcsysRepository.searchUserDetails(any(), any()),
      ).thenAnswer((_) async => customer);

      viewModel.customerRimNo = "9002";

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.branchName, ServerConstants.defaultBranch);
      expect(viewModel.branchNo, ServerConstants.defaultBranchNo);
      expect(viewModel.segmentName, ServerConstants.defaultSegment);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("rim search null result exits loaded", () async {
      when(
        () => mockCcsysRepository.searchUserDetails(any(), any()),
      ).thenAnswer((_) async => null);

      viewModel.customerRimNo = "9003";

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.customer, isNull);
      expect(viewModel.isSearched, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("rim search exception shows toast and emits loaded", () async {
      when(
        () => mockCcsysRepository.searchUserDetails(any(), any()),
      ).thenThrow(Exception("search failed"));

      viewModel.customerRimNo = "9004";

      await viewModel.onCustomerSearchPressed();

      expect(viewModel.isSearched, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("onCustomerSearchPressed name path", () {
    test("single result sets customer and dialog state", () async {
      final customer = Customer(
        id: "100",
        customerName: "Single Customer",
        segment: "Segment",
      )
        ..branch = "Branch"
        ..branchNo = 5;

      when(
        () => mockCcsysRepository.searchCustomerProfile(any(), any(), any()),
      ).thenAnswer((_) async => [customer]);

      viewModel.customerName = "Single Customer";

      await viewModel.onCustomerSearchPressed(
        isRim: false,
      );

      expect(viewModel.customer, customer);
      expect(viewModel.customerRimNo, "100");
      expect(viewModel.customerName, "Single Customer");
      expect(viewModel.branchName, "Branch");
      expect(viewModel.branchNo, 5);
      expect(viewModel.segmentName, "Segment");
      expect(viewModel.dailogCustomers.length, 1);
      expect(viewModel.allCustomers.length, 1);
      expect(viewModel.state.showSelectDialog, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("multiple results sets dialog list", () async {
      final first = Customer(id: "1", customerName: "One");
      final second = Customer(id: "2", customerName: "Two");

      when(
        () => mockCcsysRepository.searchCustomerProfile(any(), any(), any()),
      ).thenAnswer((_) async => [first, second]);

      viewModel.customerName = "Customer";

      await viewModel.onCustomerSearchPressed(
        showDialog: false,
        isRim: false,
      );

      expect(viewModel.customer, isNull);
      expect(viewModel.dailogCustomers.length, 2);
      expect(viewModel.allCustomers.length, 2);
      expect(viewModel.state.showSelectDialog, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("empty name search result exits loaded", () async {
      when(
        () => mockCcsysRepository.searchCustomerProfile(any(), any(), any()),
      ).thenAnswer((_) async => []);

      viewModel.customerName = "Missing";

      await viewModel.onCustomerSearchPressed(isRim: false);

      expect(viewModel.customer, isNull);
      expect(viewModel.dailogCustomers, isEmpty);
      expect(viewModel.isSearched, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("name search exception shows toast and emits loaded", () async {
      when(
        () => mockCcsysRepository.searchCustomerProfile(any(), any(), any()),
      ).thenThrow(Exception("name search failed"));

      viewModel.customerName = "Failure";

      await viewModel.onCustomerSearchPressed(isRim: false);

      expect(viewModel.isSearched, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("stop and reset", () {
    test("stopAllLoaders resets statuses and toggles reset flag", () {
      viewModel
        ..isSearched = true
        ..isResetPressed = false
        ..customerRimNoLoadingStatus = LoadingStatus.loading
        ..customerNameLoadingStatus = LoadingStatus.loading
        ..stopAllLoaders();

      expect(viewModel.isSearched, false);
      expect(viewModel.isResetPressed, true);
      expect(viewModel.customerRimNoLoadingStatus, LoadingStatus.loaded);
      expect(viewModel.customerNameLoadingStatus, LoadingStatus.loaded);
    });

    test("onResetButtonPress resets fields and emits loaded", () {
      viewModel
        ..customerRimNo = "1023563"
        ..customerName = "ACME LLC"
        ..isSearched = true
        ..customer = (Customer()..id = "1023563")
        ..fieldCntrl.value = {
          ControlFields.customerName: true,
          ControlFields.customerRim: true,
        }
        ..selectedCustomer.value = (Customer()..id = "200")
        ..onResetButtonPress();

      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.customerName, isNull);
      expect(viewModel.isSearched, false);
      expect(viewModel.customer, isNull);
      expect(viewModel.selectedCustomer.value, isNull);
      expect(viewModel.fieldCntrl.value[ControlFields.customerName], false);
      expect(viewModel.fieldCntrl.value[ControlFields.customerRim], false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onResetButtonPress is safe when no Form is mounted", () {
      expect(() => viewModel.onResetButtonPress(), returnsNormally);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onSubmitButtonPress", () {
    testWidgets("returns early when form is invalid", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => "error",
              ),
            ),
          ),
        ),
      );

      await viewModel.onSubmitButtonPress(mockContext);

      expect(viewModel.emittedStates, isEmpty);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
    });

    test("invalid RIM shows toast and emits loaded", () async {
      viewModel
        ..requestCreate = Request()
        ..customerName = "ACME LLC"
        ..customerRimNo = "INVALID"
        ..customer = Customer();

      await viewModel.onSubmitButtonPress(mockContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.requestCreate.customerName, isNull);
      expect(viewModel.requestCreate.customerRimNo, isNull);
    });

    test("valid RIM populates request before router failure is caught",
        () async {
      final previousRegions = Globals.user?.regions;
      Globals.user?.regions = ["Default Region"];

      viewModel
        ..requestCreate = Request()
        ..customerName = "ACME LLC"
        ..customerRimNo = "1023563"
        ..branchName = "Branch"
        ..branchNo = 10
        ..segmentName = "Segment"
        ..applicationType = [
          Reference(
            id: ServerConstants.ccsysAppReferenceId,
            name: "CCSYS",
          ),
        ]
        ..branchType = [
          Reference(
            reference1: "10",
            reference2: "Region 10",
          ),
        ];

      await viewModel.onSubmitButtonPress(mockContext);

      expect(Globals.request?.customerName, "ACME LLC");
      expect(Globals.request?.customerRimNo, 1023563);
      expect(Globals.request?.branch, "Branch");
      expect(Globals.request?.region, "Region 10");
      expect(Globals.request?.isCreateRequest, true);
      expect(Globals.request?.enabledForView, false);
      expect(Globals.request?.ccsysCanEditReadOnly, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      Globals.user?.regions = previousRegions;
    });

    test("valid RIM uses fallback app type and fallback region", () async {
      final previousRegions = Globals.user?.regions;
      Globals.user?.regions = ["Fallback Region"];

      viewModel
        ..requestCreate = Request()
        ..customerName = "Fallback Customer"
        ..customerRimNo = "123"
        ..branchName = "Fallback Branch"
        ..branchNo = 99
        ..segmentName = "Fallback Segment"
        ..applicationType = []
        ..branchType = [];

      await viewModel.onSubmitButtonPress(mockContext);

      expect(Globals.request?.customerName, "Fallback Customer");
      expect(Globals.request?.customerRimNo, 123);
      expect(Globals.request?.branch, "Fallback Branch");
      expect(Globals.request?.region, isNull);
      expect(
        Globals.request?.applicationType?.id,
        ServerConstants.ccsysAppReferenceId,
      );
      expect(Globals.request?.businessSegment?.name, "Fallback Segment");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      Globals.user?.regions = previousRegions;
    });

    test("final loaderStatus is loaded after submit", () async {
      viewModel
        ..requestCreate = Request()
        ..customerName = "ACME LLC"
        ..customerRimNo = "123";

      await viewModel.onSubmitButtonPress(mockContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("role checks", () {
    test("otherRolesCheck returns bool", () {
      expect(viewModel.otherRolesCheck(), isA<bool>());
    });

    test("otherRolesCheckCC returns bool", () {
      expect(viewModel.otherRolesCheckCC(), isA<bool>());
    });
  });

  group("RequestController navigation", () {
    test("onResetButtonPress navigates to loadingPage and requestCreate",
        () async {
      controller.onResetButtonPress();

      verify(() => mockRouter.go(Routes.loadingPage)).called(1);

      await Future.delayed(const Duration(milliseconds: 150));

      verify(() => mockRouter.go(Routes.requestCreate)).called(1);
    });
  });

  group("CcsysCreateRequestState", () {
    test("constructor sets loaderStatus and default showSelectDialog", () {
      final state = CcsysCreateRequestState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.showSelectDialog, false);
    });

    test("copyWith keeps existing values when null", () {
      final original = CcsysCreateRequestState(
        loaderStatus: LoadingStatus.loaded,
        showSelectDialog: true,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.showSelectDialog, isFalse);
    });

    test("copyWith overrides loaderStatus", () {
      final original = CcsysCreateRequestState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides showSelectDialog", () {
      final original = CcsysCreateRequestState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(showSelectDialog: true);

      expect(updated.showSelectDialog, true);
      expect(original.showSelectDialog, false);
    });
  });
}
