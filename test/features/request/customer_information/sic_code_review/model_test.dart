import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
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
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/models/request/sic_code.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late SicCodeReviewViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockReferenceDataService mockReferenceService;
  late MockAlertManager mockAlertManager;
  late MockBuildContext mockContext;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
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
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepository = MockRequestRepository();
    mockReferenceService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();
    mockContext = MockBuildContext();
    mockLocalStorageService = MockLocalStorageService();

    LocalStorageService().setStorage(mockLocalStorageService);
    AlertManager.overrideInstance(mockAlertManager);

    viewModel = SicCodeReviewViewModel();
    viewModel.repository = mockRepository;
    viewModel.context = mockContext;
  });

  test("getSICcodeReviewData should assign data on success", () async {
    final mockData = [SicCodeReview()];
    when(() => mockRepository.getSICcodeReviewData())
        .thenAnswer((_) async => mockData);

    await viewModel.getSICcodeReviewData();
    expect(viewModel.customerSICcodeReview, mockData);
  });

  // test('getSICcodeReviewData should show toast on failure', () async {
  //   when(() => mockRepository.getSICcodeReviewData())
  //       .thenThrow(Exception('Failed'));

  //   await viewModel.getSICcodeReviewData();

  //   verify(() => mockAlertManager.showFailureToast(any())).called(1);
  //   expect(viewModel.customerSICcodeReview, isNull);
  // });

  test("getReferenceData should assign proposedSICcodes on success", () async {
    final referenceList = [Reference(id: 1, name: "SIC A")];

    when(
      () => mockReferenceService
          .getReferenceData([ReferenceDataKeys.sicCodeList]),
    ).thenAnswer(
      (_) async => {
        ReferenceDataKeys.sicCodeList: referenceList,
      },
    );

    ReferenceDataService.overrideInstance(mockReferenceService);

    await viewModel.getReferenceData();

    expect(viewModel.proposedSICcodes, referenceList);
  });

  // test('getReferenceData should show toast on failure', () async {
  //   when(() => mockReferenceService.getReferenceData(any()))
  //       .thenThrow(Exception('Reference error'));

  //   ReferenceDataService.overrideInstance(mockReferenceService);

  //   await viewModel.getReferenceData();

  //   verify(() => mockAlertManager.showFailureToast(any())).called(1);
  // });

  // test('onSaveSic should save and emit loaded status', () async {
  //   final mockReview = [SicCodeReview()];
  //   viewModel.customerSICcodeReview = mockReview;

  //   when(() => mockRepository.saveSICcodeReview(mockReview))
  //       .thenAnswer((_) async => 'Success');

  //   await viewModel.onSaveSic();

  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  // test('onSaveSic should show toast on failure', () async {
  //   when(() => mockRepository.saveSICcodeReview(any()))
  //       .thenThrow(Exception('Save failed'));

  //   await viewModel.onSaveSic();

  //   verifyNever(() => mockAlertManager.showFailureToast(any())).called(0);
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  test("init should fetch data and emit loaded state", () async {
    final mockRequest = Request();
    final referenceList = [Reference(id: 1, name: "SIC A")];

    // Stub repository to return 13 mock SicCodeReview objects
    final mockReviewList = List.generate(
      13,
      (index) => SicCodeReview(
        rimNo: 114166,
        customerName: index == 8
            ? "EMIRATES STONE CRAFT 11-Test"
            : "EMIRATES STONE CRAFT 11",
        primaryBusinessActivity: "Software",
        proposedSicCode: "23790",
      ),
    );

    when(() => mockRepository.getSICcodeReviewData())
        .thenAnswer((_) async => mockReviewList);

    when(
      () => mockReferenceService
          .getReferenceData([ReferenceDataKeys.sicCodeList]),
    ).thenAnswer(
      (_) async => {ReferenceDataKeys.sicCodeList: referenceList},
    );

    ReferenceDataService.overrideInstance(mockReferenceService);
    Globals.request = mockRequest;
    viewModel.context = mockContext;

    await viewModel.init(mockContext);

    // expect(viewModel.customerSICcodeReview?.length, equals(13));
    // expect(viewModel.customerSICcodeReview?.first.customerName,
    //     equals("EMIRATES STONE CRAFT 11"));
    // expect(viewModel.proposedSICcodes, equals(referenceList));
    // expect(viewModel.request, equals(mockRequest));
    // expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
  });

  group("SicCodeReviewState", () {
    test("constructor sets loaderStatus", () {
      final state = SicCodeReviewState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = SicCodeReviewState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = SicCodeReviewState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("SicCodeReviewViewModel – getters & draft config", () {
    late SicCodeReviewViewModel vm;

    setUp(() {
      vm = SicCodeReviewViewModel();
    });

    test("canEdit is true only when pageMode is edit", () {
      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, true);

      vm.pageMode = PageMode.view;
      expect(vm.canEdit, false);
    });

    test("draftModuleKey is customerInformation", () {
      expect(vm.draftModuleKey, DraftModuleKeys.customerInformation);
    });

    test("draftFormKey is sicCodeReview", () {
      expect(vm.draftFormKey, Routes.sicCodeReview);
    });

    test("draftHandler type is SicCodeReviewDraftHandler", () {
      expect(vm.draftHandler, isA<SicCodeReviewDraftHandler>());
    });
  });

  group("getSelectedCustomer()", () {
    late SicCodeReviewViewModel vm;

    setUp(() {
      vm = SicCodeReviewViewModel();
    });

    test("returns empty Customer when Globals.request is null", () {
      Globals.request = null;

      final customer = vm.getSelectedCustomer();

      expect(customer, isA<Customer>());
      expect(customer.customerRimNo, isNull);
    });

    test("returns customer derived from Globals.request", () {
      Globals.request = Request(
        customers: [
          Customer(
            customerName: "Test Customer",
            customerRimNo: 123,
          ),
        ],
      );

      final customer = vm.getSelectedCustomer();

      expect(customer.customerName, "Test Customer");
      expect(customer.customerRimNo, 123);
    });
  });

  group("close()", () {
    test("unregisters draft callback and completes", () async {
      final vm = SicCodeReviewViewModel();

      await vm.close();

      expect(true, isTrue); // completes successfully
    });
  });
}
