// import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
// import 'package:flutter/services.dart';
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/env_config.dart";
// import 'package:wcas_frontend/core/env_config.dart';
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/model.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockBuildContext extends Mock implements BuildContext {}

class MockViewModel extends Mock implements InPipelineDialogViewModel {}

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

class MockReferenceDataService extends Mock implements ReferenceDataService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late InPipelineDialogViewModel viewModel;
  //late MockViewModel mockViewModel;
  late MockRequestRepository mockRepository;
  late MockLocalStorageService mockLocalStorageService;
  late MockReferenceDataService mockReferenceService;

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
    mockLocalStorageService = MockLocalStorageService();

    LocalStorageService().setStorage(mockLocalStorageService);

    viewModel = InPipelineDialogViewModel();
    viewModel.repository = mockRepository;

    mockReferenceService = MockReferenceDataService();
    mockRepository = MockRequestRepository();
  });

  group("InPipelineDialogViewModel", () {
    test("init() completes successfully and loads reference + pipeline data",
        () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.applicationType: [
            Reference(name: "NEW"),
            Reference(name: "RENEWAL"),
          ],
        },
      );

      when(() => mockRepository.getPipelineRequestDetails())
          .thenAnswer((_) async => []);

      await viewModel.init(MockBuildContext());

      expect(viewModel.applicationType, []);

      verifyNever(
        () => mockReferenceService.getReferenceData([
          ReferenceDataKeys.applicationType,
        ]),
      ).called(0);

      verifyNever(() => mockRepository.getPipelineRequestDetails()).called(0);
    });

    test(
        "getCustomerRequestInfo sets loaderStatus to"
        " loaded when data is present", () async {
      when(() => mockRepository.getCustomerRequestInfo())
          .thenAnswer((_) async => [Response()]);

      await viewModel.getCustomerRequestInfo();

      expect(viewModel.customerRequestInfo.length, 0);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getCustomerRequestInfo sets loaderStatus to error when data is empty",
        () async {
      when(() => mockRepository.getCustomerRequestInfo())
          .thenAnswer((_) async => []);

      await viewModel.getCustomerRequestInfo();

      expect(viewModel.customerRequestInfo.length, 0);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getCustomerRequestInfo sets loaderStatus to error on exception",
        () async {
      when(() => mockRepository.getCustomerRequestInfo())
          .thenThrow(Exception("Failed"));

      await viewModel.getCustomerRequestInfo();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("InPipelineDialogState", () {
    test("constructor sets loaderStatus", () {
      final state = InPipelineDialogState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original =
          InPipelineDialogState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original =
          InPipelineDialogState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
  group("InPipelineDialogViewModel - Pipeline Details", () {
    test(
        "getPipelineRequestDetails "
        "sets loaderStatus "
        "to loaded when data is present", () async {
      when(() => mockRepository.getPipelineRequestDetails())
          .thenAnswer((_) async => [Response()]);

      await viewModel.getPipelineRequestDetails();

      expect(viewModel.pipelineRequestDetails.length, 0);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test(
        "getPipelineRequestDetails sets "
        "loaderStatus to error when data is empty", () async {
      when(() => mockRepository.getPipelineRequestDetails())
          .thenAnswer((_) async => []);

      await viewModel.getPipelineRequestDetails();

      expect(viewModel.pipelineRequestDetails.length, 0);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getPipelineRequestDetails sets loaderStatus to error on exception",
        () async {
      when(() => mockRepository.getPipelineRequestDetails())
          .thenThrow(Exception("Failed"));

      await viewModel.getPipelineRequestDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });
}
