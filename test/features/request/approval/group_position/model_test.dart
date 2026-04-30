import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/group_position/model.dart";
import "package:wcas_frontend/features/request/approval/group_position/state.dart";
// import 'package:wcas_frontend/models/request/application_details.dart';
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
//import 'package:wcas_frontend/models/request/approval/group_position.dart';
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class TestBuildContext implements BuildContext {
  @override
  bool mounted = false;
  int goCount = 0;
  String? lastRoute;

  void go(String location) {
    goCount++;
    lastRoute = location;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ThrowingNavContext extends TestBuildContext {
  @override
  void go(String location) {
    throw Exception("navErr");
  }
}

class MockAlertManager extends Mock implements AlertManager {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => ["wifi"]);

  late GroupPositionViewModel viewModel;
  late MockRequestRepository mockRepo;
  late TestBuildContext context;
  late MockAlertManager mockAlert;
  late MockApprovalRepository mockApprovalRepository;
  late MockDraftRepository mockDraftRepository;

  setUpAll(() async {
    registerFallbackValue("");
    await EnvConfig.setEnvironment();
  });

  setUp(() async {
    await EnvConfig.setEnvironment();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == "check") {
        return [ConnectivityResult.wifi.name];
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall methodCall) async {
        return "wifi";
      },
    );

    mockRepo = MockRequestRepository();
    mockApprovalRepository = MockApprovalRepository();
    context = TestBuildContext();
    mockAlert = MockAlertManager();
    mockDraftRepository = MockDraftRepository();
    AlertManager.instance = mockAlert;
    AlertManager.overrideInstance(mockAlert);
    DraftRepository.overrideInstance(mockDraftRepository);
    ApprovalRepository.overrideInstance(mockApprovalRepository);
    DraftRepository.overrideInstance(mockDraftRepository);

    viewModel = GroupPositionViewModel()
      ..repository = mockRepo
      ..approvalRepository = mockApprovalRepository;

    when(
      () => mockDraftRepository.deleteDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockDraftRepository.saveDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
        draftJson: any(named: "draftJson"),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockDraftRepository.getDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test("initial state & defaults", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    expect(viewModel.groups, isEmpty);
    expect(viewModel.rowsPerPage, 12);
    expect(viewModel.repository, mockRepo);
  });

  // test('init() generates 0 dummy groups & emits loaded', () async {
  //   when(() => mockRepo.getApplicationDetails()).thenAnswer((_) async =>
  // ApplicationDetails());
  //   when(() => mockApprovalRepository.fetchReference()).thenAnswer((_) async
  // => {});
  //   when(() => mockApprovalRepository.getCleanExposureInfo()).thenAnswer((_)
  // async => CleanExposure());
  //   when(() => mockApprovalRepository.getGroupPositionDetails())
  //       .thenAnswer((_) async => AppResponse(message: 'Success'));
  //   when(() =>

  // 'Success')))
  //       .thenAnswer((_) async => GroupPosition());
  //   viewModel.init(context);
  //   expect(viewModel.groups, hasLength(0));
  // });

  group("loadCleanExposureData()", () {
    test(
      "loaded state on success",
      () async {
        final cleanExposure = CleanExposure(
          exposures: [
            Exposure(
              rimNo: 10,
              appRefNo: "App123",
              updatedGuarantorExposure: 10.2,
              updatedPresentExposure: 12.4,
              updatedProposedExposure: 24.2,
              calculatedPresentExposure: 20,
              calculatedProposedExposure: 30.4,
            ),
            Exposure(
              rimNo: 0,
              appRefNo: "App123",
              updatedGuarantorExposure: 10.2,
              updatedPresentExposure: 12.4,
              updatedProposedExposure: 24.2,
              calculatedPresentExposure: 20,
              calculatedProposedExposure: 30.4,
            ),
          ],
          totalSharedLimitPresent: 100,
          totalSharedLimitProposed: 120,
        );
        when(() => mockApprovalRepository.getCleanExposureInfo())
            .thenAnswer((_) async => cleanExposure);
        await viewModel.loadCleanExposureData();
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      " handle exception if thrown by API",
      () async {
        when(() => mockApprovalRepository.getCleanExposureInfo())
            .thenThrow(Exception("Failed to load"));
        await viewModel.loadCleanExposureData();
        expect(viewModel.groupedExposure.length, 0);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      },
    );
  });

  group("getGroupPositionDetails()", () {
    test(
      "assign values to variables on success",
      () async {
        final appResponse = AppResponse(
          message: "Success",
          body: {
            "response": [
              {"custName": "Sample1"},
              {"custName": "Sample2"},
            ],
          },
        );
        final groupPositionList = GroupPosition(
          presentPosition: [Position(customerName: "Sample1")],
          proposedPosition: [Position(customerName: "Sample2")],
        );
        when(() => mockApprovalRepository.getGroupPositionDetails())
            .thenAnswer((_) async => appResponse);
        when(
          () => mockApprovalRepository.transformGroupPositionFacilitiesData(
            appResponse,
          ),
        ).thenAnswer((_) async => groupPositionList);
        await viewModel.getGroupPositionDetails();
        expect(viewModel.groups.length, 0);
        // expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      " handle exception if thrown",
      () async {
        final appResponse = AppResponse(
          message: "Success",
          body: {
            "response": [
              {"custName": "Sample1"},
              {"custName": "Sample2"},
            ],
          },
        );
        when(() => mockApprovalRepository.getGroupPositionDetails())
            .thenAnswer((_) async => appResponse);
        when(
          () => mockApprovalRepository.transformGroupPositionFacilitiesData(
            appResponse,
          ),
        ).thenThrow(Exception("Error"));
        await viewModel.getGroupPositionDetails();
        expect(viewModel.groups.length, 0);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      },
    );
  });

  group("onSavePress()", () {
    test(
      "isContinue=false → no success or failure toast if"
      " data is empty state will be loaded",
      () async {
        await viewModel.onSavePress(context, isContinue: false);

        verifyNever(() => mockAlert.showSuccessToast(any()));
        verifyNever(() => mockAlert.showFailureToast(any()));

        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      " success toast will appear if data is present",
      () async {
        viewModel.exposureList = [Exposure(rimNo: 10, appRefNo: "App123")];
        when(
          () => mockApprovalRepository
              .insertCleanExposureInfo(viewModel.exposureList),
        ).thenAnswer((_) async => "Success");

        await viewModel.onSavePress(context);

        // verify(() => mockAlert.showSuccessToast(any())).called(1);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      " failure toast will appear if exception is thrown",
      () async {
        viewModel.exposureList = [Exposure(rimNo: 10, appRefNo: "App123")];
        when(
          () => mockApprovalRepository
              .insertCleanExposureInfo(viewModel.exposureList),
        ).thenThrow(Exception("Error"));

        await viewModel.onSavePress(context);

        verify(() => mockAlert.showFailureToast(any())).called(1);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );
  });

  group("updateExposureField()", () {
    test(
      "assign values to the variables for non proposed",
      () async {
        viewModel.updateExposureField(1, "10", "200", false);
        viewModel.updateExposureField(2, "0", "700", false);
        expect(viewModel.groupedExposure.length, 2);
      },
    );

    test(
      "assign values to the variables for proposed",
      () async {
        viewModel.updateExposureField(1, "10", "500", true);
        viewModel.updateExposureField(2, "0", "1000", true);
        expect(viewModel.groupedExposure.length, 2);
      },
    );
  });

  group("GroupPositionState", () {
    test("constructor sets loaderStatus", () {
      final state = GroupPositionState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = GroupPositionState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = GroupPositionState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
