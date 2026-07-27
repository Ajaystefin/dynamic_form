import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/model.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockBuildContext extends Mock implements BuildContext {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class FakeRequest extends Fake implements Request {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAlertManager mockAlertManager;

  late InPipelineDialogViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockReferenceDataService mockReferenceService;
  late MockDashboardRepository mockDashboardRepository;
  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    registerFallbackValue(FakeRequest());

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async => ["wifi"],
    );
  });

  setUp(() {
    mockRepository = MockRequestRepository();
    mockReferenceService = MockReferenceDataService();
    mockDashboardRepository = MockDashboardRepository();
    mockAlertManager = MockAlertManager();
    ReferenceDataService.overrideInstance = mockReferenceService;
    AlertManager.overrideInstance = mockAlertManager;
    viewModel = InPipelineDialogViewModel()
      ..repository = mockRepository
      ..repositoryDashboard = mockDashboardRepository;

    Globals.request = Request();
  });

  tearDown(() {
    Globals.request = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      null,
    );
  });

  // ================= INIT =================

  test("init executes full flow", () async {
    when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
      (_) async => {
        ReferenceDataKeys.applicationType: [Reference(name: "A")],
        ReferenceDataKeys.customApplicationType: [Reference(name: "B")],
      },
    );

    when(() => mockRepository.getPipelineRequestDetails())
        .thenAnswer((_) async => [Response()]);

    await viewModel.init(MockBuildContext());

    expect(viewModel.applicationType.length, 1);
    expect(viewModel.customApplicationType.length, 1);
    expect(viewModel.pipelineRequestDetails.length, 0);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= REFERENCE =================

  test("getReferenceDatas success", () async {
    when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
      (_) async => {
        ReferenceDataKeys.applicationType: [Reference(name: "A")],
        ReferenceDataKeys.customApplicationType: [Reference(name: "B")],
      },
    );

    await viewModel.getReferenceDatas();

    expect(viewModel.applicationType.length, 1);
    expect(viewModel.customApplicationType.length, 1);
  });

  test("getReferenceDatas failure", () async {
    when(() => mockReferenceService.getReferenceData(any()))
        .thenThrow(Exception());

    await viewModel.getReferenceDatas();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= CUSTOMER =================

  test("getCustomerRequestInfo success", () async {
    when(() => mockRepository.getCustomerRequestInfo())
        .thenAnswer((_) async => [Response()]);

    await viewModel.getCustomerRequestInfo();

    expect(viewModel.customerRequestInfo.length, 1);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getCustomerRequestInfo empty", () async {
    when(() => mockRepository.getCustomerRequestInfo())
        .thenAnswer((_) async => []);

    await viewModel.getCustomerRequestInfo();

    expect(viewModel.customerRequestInfo.isEmpty, true);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("getCustomerRequestInfo exception", () async {
    when(() => mockRepository.getCustomerRequestInfo()).thenThrow(Exception());

    await viewModel.getCustomerRequestInfo();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= PIPELINE =================

  test("getPipelineRequestDetails success", () async {
    when(() => mockRepository.getPipelineRequestDetails())
        .thenAnswer((_) async => [Response()]);

    await viewModel.getPipelineRequestDetails();

    expect(viewModel.pipelineRequestDetails.length, 1);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getPipelineRequestDetails empty", () async {
    when(() => mockRepository.getPipelineRequestDetails())
        .thenAnswer((_) async => []);

    await viewModel.getPipelineRequestDetails();

    expect(viewModel.pipelineRequestDetails.isEmpty, true);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("getPipelineRequestDetails exception", () async {
    when(() => mockRepository.getPipelineRequestDetails())
        .thenThrow(Exception());

    await viewModel.getPipelineRequestDetails();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= STATE =================

  test("state constructor", () {
    const state = InPipelineDialogState(loaderStatus: LoadingStatus.loading);
    expect(state.loaderStatus, LoadingStatus.loading);
  });

  test("state copyWith retains", () {
    const s = InPipelineDialogState(loaderStatus: LoadingStatus.loaded);
    final n = s.copyWith();
    expect(n.loaderStatus, LoadingStatus.loaded);
  });

  test("state copyWith override", () {
    const s = InPipelineDialogState(loaderStatus: LoadingStatus.loaded);
    final n = s.copyWith(loaderStatus: LoadingStatus.error);
    expect(n.loaderStatus, LoadingStatus.error);
  });

  // ================= APPLICATION TYPE =================

  test(
    "getApplicationRequestType returns customApplicationType",
    () {
      viewModel.customApplicationType = [
        Reference(
          name: "Custom",
          reference1: "SUB",
          reference3: "REQ",
        ),
      ];

      final result = viewModel.getApplicationRequestType(
        "REQ",
        "SUB",
      );

      expect(result.name, "Custom");
    },
  );

  test(
    "getApplicationRequestType returns applicationType",
    () {
      viewModel.applicationType = [
        Reference(
          name: "Application",
          reference1: "SUB",
          reference4: "REQ",
        ),
      ];

      final result = viewModel.getApplicationRequestType(
        "REQ",
        "SUB",
      );

      expect(result.name, "Application");
    },
  );

  test(
    "getApplicationRequestType returns fallback reference",
    () {
      final result = viewModel.getApplicationRequestType(
        "REQ",
        "SUB",
      );

      expect(result.reference1, "SUB");
      expect(result.reference3, "REQ");
      expect(result.reference4, "REQ");
    },
  );

// ================= OPEN APPLICATION =================

  test(
    "openApplication success using customApplicationType",
    () async {
      when(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      ).thenAnswer((_) async {});

      viewModel
        ..requestTypeItems = [
          Reference(
            name: "Request",
            reference1: "REQ",
          ),
        ]
        ..customApplicationType = [
          Reference(
            name: "Custom",
            reference1: "SUB",
            reference3: "REQ",
          ),
        ];

      final response = Response(
        applicationRefNo: "APP001",
        requestType: "REQ",
        subType: "SUB",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      verify(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: true,
        ),
      ).called(1);

      expect(
        Globals.request?.applicationRefNo,
        "APP001",
      );

      expect(
        Globals.request?.isCreateRequest,
        false,
      );

      expect(
        Globals.request?.applicationType?.name,
        "Custom",
      );

      expect(
        viewModel.state.loaderStatus,
        LoadingStatus.loaded,
      );
    },
  );
  test(
    "openApplication returns when requestType is null",
    () async {
      final response = Response(
        subType: "SUB",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      verifyNever(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      );

      expect(
        Globals.request?.applicationType,
        isNull,
      );
    },
  );

  test(
    "openApplication returns when subType is null",
    () async {
      final response = Response(
        requestType: "REQ",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      verifyNever(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      );

      expect(
        Globals.request?.applicationType,
        isNull,
      );
    },
  );

  test(
    "openApplication uses requestType fallback",
    () async {
      when(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      ).thenAnswer((_) async {});

      final response = Response(
        requestType: "UNKNOWN",
        subType: "SUB",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      expect(
        Globals.request?.requestType?.reference1,
        "UNKNOWN",
      );
    },
  );

  test(
    "openApplication uses applicationType mapping",
    () async {
      when(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      ).thenAnswer((_) async {});

      viewModel.applicationType = [
        Reference(
          name: "Application",
          reference1: "SUB",
          reference4: "REQ",
        ),
      ];

      final response = Response(
        requestType: "REQ",
        subType: "SUB",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      expect(
        Globals.request?.applicationType?.name,
        "Application",
      );
    },
  );

  test(
    "openApplication uses fallback applicationType",
    () async {
      when(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      ).thenAnswer((_) async {});

      final response = Response(
        requestType: "REQ",
        subType: "SUB",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      expect(
        Globals.request?.applicationType?.reference1,
        "SUB",
      );

      expect(
        Globals.request?.applicationType?.reference3,
        "REQ",
      );

      expect(
        Globals.request?.applicationType?.reference4,
        "REQ",
      );
    },
  );

  test(
    "openApplication handles dashboard repository exception",
    () async {
      when(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: any(named: "isPipeline"),
          context: any(named: "context"),
        ),
      ).thenThrow(Exception("Failed"));
      when(() => mockAlertManager.showFailureToast(any()))
          .thenAnswer((_) async {});
      final response = Response(
        requestType: "REQ",
        subType: "SUB",
      );

      await viewModel.openApplication(
        null,
        response,
        Request(),
      );

      verify(
        () => mockDashboardRepository.openApplication(
          any(),
          isPipeline: true,
        ),
      ).called(1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    },
  );
}
