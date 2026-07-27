import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/state.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
import "package:wcas_frontend/models/request/approval/proposed_facilities.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS / FAKES ================= */

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockDraftRepository extends Mock implements DraftRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeExposure extends Fake implements Exposure {}

class FakeAppResponse extends Fake implements AppResponse {}

class FakeGroupPosition extends Fake implements GroupPosition {}

class FakeApplicationDetails extends Fake implements ApplicationDetails {}

class FakeProposedFacilities extends Fake implements ProposedFacilities {}

CleanExposure buildFullCleanExposure() {
  return CleanExposure(
    totalSharedLimitPresent: 100,
    totalSharedLimitProposed: 200,
    totalProposedExposure: 300,
    exposures: <Exposure>[
      Exposure(
        rimNo: 1,
        updatedPresentExposure: 10,
        updatedProposedExposure: 20,
        calculatedPresentExposure: 15,
        calculatedProposedExposure: 25,
      ),
      Exposure(
        rimNo: 2,
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  late ProposedFacilitiesViewModel vm;
  late MockApprovalRepository approvalRepo;
  late MockRequestRepository requestRepo;
  late MockCommonRepository commonRepo;
  late MockDraftRepository draftRepo;
  late MockAlertManager alerts;

  Future<void> pumpVm(
    WidgetTester tester, {
    Widget? child,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: child ?? const SizedBox(key: Key("root")),
        ),
      ),
    );
  }

  void stubDraftRepository() {
    when(
      () => draftRepo.deleteDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async {});
  }

  void stubSuccessRepositories({
    CleanExposure? cleanExposure,
    List<ProposedFacilities>? pipelineRequests,
    GroupPosition? groupPosition,
  }) {
    when(
      () => requestRepo.getApplicationDetails(
        appRefNo: any(named: "appRefNo"),
      ),
    ).thenAnswer((_) async => null);

    when(() => approvalRepo.getGroupPositionDetails()).thenAnswer(
      (_) async => AppResponse(message: "ok"),
    );

    when(
      () => approvalRepo.transformGroupPositionFacilitiesData(any()),
    ).thenAnswer((_) async => groupPosition ?? GroupPosition());

    when(() => approvalRepo.getCleanExposureInfo()).thenAnswer(
      (_) async => cleanExposure,
    );

    when(
      () => approvalRepo.getPipelineRequestDetails(any()),
    ).thenAnswer((_) async => pipelineRequests ?? <ProposedFacilities>[]);

    when(() => approvalRepo.fetchReference()).thenAnswer((_) async {});

    when(
      () => approvalRepo.insertCleanExposureInfo(any()),
    ).thenAnswer((_) async => null);
  }

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (_) async => <String>["wifi"],
    );

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(FakeExposure());
    registerFallbackValue(<Exposure>[]);
    registerFallbackValue(FakeAppResponse());
    registerFallbackValue(FakeGroupPosition());
    registerFallbackValue(FakeApplicationDetails());
    registerFallbackValue(FakeProposedFacilities());
    registerFallbackValue(<ProposedFacilities>[]);
  });

  setUp(() {
    approvalRepo = MockApprovalRepository();
    requestRepo = MockRequestRepository();
    commonRepo = MockCommonRepository();
    draftRepo = MockDraftRepository();
    alerts = MockAlertManager();

    ApprovalRepository.overrideInstance = approvalRepo;
    RequestRepository.overrideInstance = requestRepo;
    CommonRepository.overrideInstance = commonRepo;
    DraftRepository.overrideInstance = draftRepo;
    AlertManager.overrideInstance = alerts;

    Globals.request = null;

    stubDraftRepository();
    stubSuccessRepositories();

    vm = ProposedFacilitiesViewModel()
      ..approvalRepository = approvalRepo
      ..repository = requestRepo
      ..cleanExposureControllers = <String, TextEditingController>{}
      ..cleanExposureValues = <String, String>{}
      ..groupedExposure = <int, Exposure>{}
      ..exposureList = <Exposure>[];
  });

  tearDown(() async {
    await vm.close();
  });

  /* ================= BASIC ================= */

  test("initial state and default values are correct", () {
    expect(vm.state.loaderStatus, LoadingStatus.loading);
    expect(vm.rowsPerPage, 5);
    expect(vm.groupPositionList, isA<GroupPosition>());
    expect(vm.pipelineRequests, isEmpty);
    expect(vm.appResponse, isNull);
    expect(vm.cleanExposureControllers, isNotNull);
    expect(vm.cleanExposureValues, isEmpty);
    expect(vm.groupedExposure, isEmpty);
    expect(vm.exposureList, isEmpty);
    expect(vm.cleanExposure, isNull);
    expect(vm.totalProposedExposure, 0);
    expect(vm.draftModuleKey, DraftModuleKeys.approval);
    expect(vm.draftFormKey, Routes.proposedFacilities);
    expect(vm.draftHandler, isA<ProposedFacilitiesDraftHandler>());
    expect(vm.draftHandler, isNot(same(vm.draftHandler)));
  });

  /* ================= STATE ================= */

  group("ProposedFacilitiesState", () {
    test("copyWith keeps existing loader status when no value is provided", () {
      final ProposedFacilitiesState state = ProposedFacilitiesState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.copyWith().loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides loader status", () {
      final ProposedFacilitiesState state = ProposedFacilitiesState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(
        state.copyWith(loaderStatus: LoadingStatus.error).loaderStatus,
        LoadingStatus.error,
      );
    });
  });

  /* ================= INIT ================= */

  testWidgets("init success loads all required data", (tester) async {
    stubSuccessRepositories(cleanExposure: buildFullCleanExposure());

    await pumpVm(tester);

    await tester.runAsync(() async {
      await vm.init(tester.element(find.byKey(const Key("root"))));
    });

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    expect(vm.cleanExposure, isNotNull);
    expect(vm.groupPositionList, isA<GroupPosition>());
    expect(vm.pipelineRequests, isNotNull);

    verify(
      () => requestRepo.getApplicationDetails(
        appRefNo: any(named: "appRefNo"),
      ),
    ).called(1);
    verify(() => approvalRepo.getGroupPositionDetails()).called(1);
    verify(() => approvalRepo.getCleanExposureInfo()).called(1);
    verify(() => approvalRepo.getPipelineRequestDetails(any())).called(1);
    verify(() => approvalRepo.fetchReference()).called(1);
  });

  testWidgets("init emits error when request repository throws",
      (tester) async {
    when(
      () => requestRepo.getApplicationDetails(
        appRefNo: any(named: "appRefNo"),
      ),
    ).thenThrow(Exception("application details failed"));

    await pumpVm(tester);

    await tester.runAsync(() async {
      await vm.init(tester.element(find.byKey(const Key("root"))));
    });

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  testWidgets("init emits error when fetchReference throws", (tester) async {
    when(() => approvalRepo.fetchReference()).thenThrow(
      Exception("reference failed"),
    );

    await pumpVm(tester);

    await tester.runAsync(() async {
      await vm.init(tester.element(find.byKey(const Key("root"))));
    });

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  /* ================= GROUP POSITION ================= */

  test("getGroupPositionDetails success updates app response and state",
      () async {
    await vm.getGroupPositionDetails();

    expect(vm.appResponse, isA<AppResponse>());
    expect(vm.groupPositionList, isA<GroupPosition>());
    expect(vm.state.loaderStatus, LoadingStatus.loaded);

    verify(() => approvalRepo.getGroupPositionDetails()).called(1);
    verify(
      () => approvalRepo.transformGroupPositionFacilitiesData(any()),
    ).called(1);
  });

  test(
      "getGroupPositionDetails emits error when getGroupPositionDetails throws",
      () async {
    when(() => approvalRepo.getGroupPositionDetails()).thenThrow(
      Exception("group position failed"),
    );

    await vm.getGroupPositionDetails();

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  test(
      "getGroupPositionDetails emits error when transformGroupPositionFacilitiesData throws",
      () async {
    when(
      () => approvalRepo.transformGroupPositionFacilitiesData(any()),
    ).thenThrow(Exception("transform failed"));

    await vm.getGroupPositionDetails();

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  /* ================= PIPELINE REQUESTS ================= */

  test("getPipelineRequestDetails success updates pipeline requests", () async {
    final List<ProposedFacilities> expected = <ProposedFacilities>[];

    when(
      () => approvalRepo.getPipelineRequestDetails(any()),
    ).thenAnswer((_) async => expected);

    await vm.getPipelineRequestDetails();

    expect(vm.pipelineRequests, expected);
    expect(vm.pipelineRequests, hasLength(0));
    expect(vm.state.loaderStatus, LoadingStatus.loaded);

    verify(() => approvalRepo.getPipelineRequestDetails(any())).called(1);
  });

  test("getPipelineRequestDetails emits error when repository throws",
      () async {
    when(
      () => approvalRepo.getPipelineRequestDetails(any()),
    ).thenThrow(Exception("pipeline failed"));

    await vm.getPipelineRequestDetails();

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  /* ================= CLEAN EXPOSURE ================= */

  test("loadCleanExposureData populates shared and customer exposure data",
      () async {
    when(() => approvalRepo.getCleanExposureInfo()).thenAnswer(
      (_) async => buildFullCleanExposure(),
    );

    await vm.loadCleanExposureData();

    expect(vm.cleanExposure, isNotNull);
    expect(vm.totalProposedExposure, 300);

    // Original two exposures + shared rim exposure.
    expect(vm.exposureList.length, 3);

    expect(vm.groupedExposure.containsKey(0), true);
    expect(vm.groupedExposure.containsKey(1), true);
    expect(vm.groupedExposure.containsKey(2), true);

    expect(vm.cleanExposureControllers!.containsKey("0_present"), true);
    expect(vm.cleanExposureControllers!.containsKey("0_proposed"), true);
    expect(vm.cleanExposureControllers!.containsKey("1_present"), true);
    expect(vm.cleanExposureControllers!.containsKey("1_proposed"), true);
    expect(vm.cleanExposureControllers!.containsKey("2_present"), true);
    expect(vm.cleanExposureControllers!.containsKey("2_proposed"), true);

    expect(vm.cleanExposureControllers!["0_present"]!.text, "100.0");
    expect(vm.cleanExposureControllers!["0_proposed"]!.text, "200.0");
    expect(vm.cleanExposureControllers!["1_present"]!.text, "10.0");
    expect(vm.cleanExposureControllers!["1_proposed"]!.text, "20.0");

    expect(vm.cleanExposureValues["0_present"], "100.0");
    expect(vm.cleanExposureValues["0_proposed"], "200.0");
    expect(vm.cleanExposureValues["1_present"], "15.0");
    expect(vm.cleanExposureValues["1_proposed"], "25.0");

    expect(vm.groupedExposure[0]?.updatedSharedLimitPresent, 100);
    expect(vm.groupedExposure[0]?.updatedSharedLimitProposed, 200);
    expect(vm.groupedExposure[1]?.updatedPresentExposure, 10);
    expect(vm.groupedExposure[1]?.updatedProposedExposure, 20);
  });

  test("loadCleanExposureData handles null clean exposure without throwing",
      () async {
    when(() => approvalRepo.getCleanExposureInfo()).thenAnswer(
      (_) async => null,
    );

    await vm.loadCleanExposureData();

    expect(vm.cleanExposure, isNull);
    expect(vm.exposureList, isEmpty);
    expect(vm.groupedExposure, isEmpty);
    expect(vm.cleanExposureValues, isEmpty);
  });

  test("loadCleanExposureData catches repository exception", () async {
    when(() => approvalRepo.getCleanExposureInfo()).thenThrow(
      Exception("clean exposure failed"),
    );

    await vm.loadCleanExposureData();

    expect(vm.state.loaderStatus, LoadingStatus.loading);
    expect(vm.exposureList, isEmpty);
  });

  test("loadCleanExposureData handles shared rim with null shared totals",
      () async {
    when(() => approvalRepo.getCleanExposureInfo()).thenAnswer(
      (_) async => CleanExposure(
        exposures: <Exposure>[],
      ),
    );

    await vm.loadCleanExposureData();

    expect(vm.cleanExposure, isNotNull);
    expect(vm.exposureList.length, 1);
    expect(vm.groupedExposure.containsKey(0), true);
    expect(vm.cleanExposureValues.containsKey("0_present"), false);
    expect(vm.cleanExposureValues.containsKey("0_proposed"), false);
  });

  /* ================= UPDATE EXPOSURE FIELD ================= */

  test("updateExposureField updates shared present exposure", () {
    vm.updateExposureField(
      1,
      0,
      "123.45",
      isProposed: false,
    );

    expect(vm.groupedExposure[0], isNotNull);
    expect(vm.groupedExposure[0]?.updatedSharedLimitPresent, 123.45);
  });

  test("updateExposureField updates shared proposed exposure", () {
    vm.updateExposureField(
      2,
      0,
      "234.56",
      isProposed: true,
    );

    expect(vm.groupedExposure[0], isNotNull);
    expect(vm.groupedExposure[0]?.updatedSharedLimitProposed, 234.56);
  });

  test("updateExposureField updates customer present exposure", () {
    vm.updateExposureField(
      3,
      99,
      "345.67",
      isProposed: false,
    );

    expect(vm.groupedExposure[99], isNotNull);
    expect(vm.groupedExposure[99]?.updatedPresentExposure, 345.67);
  });

  test("updateExposureField updates customer proposed exposure", () {
    vm.updateExposureField(
      4,
      99,
      "456.78",
      isProposed: true,
    );

    expect(vm.groupedExposure[99], isNotNull);
    expect(vm.groupedExposure[99]?.updatedProposedExposure, 456.78);
  });

  test("updateExposureField uses zero rim when rimNo is null", () {
    vm.updateExposureField(
      5,
      null,
      "11",
      isProposed: false,
    );

    expect(vm.groupedExposure.containsKey(0), true);
    expect(vm.groupedExposure[0]?.rimNo, 0);
    expect(vm.groupedExposure[0]?.updatedSharedLimitPresent, isNull);
  });

  test("updateExposureField stores null for invalid number", () {
    vm.updateExposureField(
      6,
      10,
      "not-a-number",
      isProposed: true,
    );

    expect(vm.groupedExposure[10], isNotNull);
    expect(vm.groupedExposure[10]?.updatedProposedExposure, isNull);
  });

  /* ================= SAVE ================= */

  test("onSavePress with no exposure data emits loaded and does not insert",
      () async {
    await vm.onSavePress();

    await Future<void>.delayed(Duration.zero);

    expect(vm.state.loaderStatus, LoadingStatus.loaded);

    verifyNever(
      () => approvalRepo.insertCleanExposureInfo(any()),
    );
  });

  test("onSavePress saves non-zero rim exposure and emits loaded", () async {
    vm.groupedExposure = <int, Exposure>{
      1: Exposure(
        rimNo: 1,
        updatedPresentExposure: 10,
        updatedProposedExposure: 20,
      ),
    };

    await vm.onSavePress();

    await Future<void>.delayed(Duration.zero);

    expect(vm.exposureList, isNotEmpty);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);

    verify(
      () => approvalRepo.insertCleanExposureInfo(any()),
    ).called(1);
    verify(() => alerts.showSuccessToast(any())).called(1);
  });

  test("onSavePress filters out shared rim zero before insert", () async {
    vm.groupedExposure = <int, Exposure>{
      0: Exposure(
        rimNo: 0,
        updatedSharedLimitPresent: 100,
      ),
      7: Exposure(
        rimNo: 7,
        updatedPresentExposure: 700,
      ),
    };

    await vm.onSavePress();

    await Future<void>.delayed(Duration.zero);

    final VerificationResult result = verify(
      () => approvalRepo.insertCleanExposureInfo(captureAny()),
    )..called(1);

    final List<Exposure> captured = result.captured.single as List<Exposure>;

    expect(captured.any((Exposure exposure) => exposure.rimNo == 0), false);
    expect(captured.any((Exposure exposure) => exposure.rimNo == 7), true);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onSavePress catches insert exception and finally emits loaded",
      () async {
    when(
      () => approvalRepo.insertCleanExposureInfo(any()),
    ).thenThrow(Exception("insert failed"));

    vm.groupedExposure = <int, Exposure>{
      1: Exposure(rimNo: 1),
    };

    await vm.onSavePress();

    await Future<void>.delayed(Duration.zero);

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onSavePress reloads clean exposure data after save", () async {
    when(() => approvalRepo.getCleanExposureInfo()).thenAnswer(
      (_) async => buildFullCleanExposure(),
    );

    vm.groupedExposure = <int, Exposure>{
      1: Exposure(rimNo: 1),
    };

    await vm.onSavePress();

    await Future<void>.delayed(Duration.zero);

    verify(() => approvalRepo.getCleanExposureInfo()).called(greaterThan(0));
    expect(vm.cleanExposure, isNotNull);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onSavePress with isContinue false completes safely", () async {
    await vm.onSavePress();

    await Future<void>.delayed(Duration.zero);

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  /* ================= CLOSE ================= */

  test("close returns Future<void> and completes", () async {
    final ProposedFacilitiesViewModel localVm = ProposedFacilitiesViewModel();

    final Future<void> result = localVm.close();

    expect(result, isA<Future<void>>());

    await result;
  });
}
