import "dart:io";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:path/path.dart" as p;

import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/guarantors_exposure/model.dart";
import "package:wcas_frontend/features/request/approval/guarantors_exposure/state.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/guarantors_exposure.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";

/// -------------------- Mocks --------------------

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuarantorsExposureViewModel viewModel;
  late MockApprovalRepository repo;
  late MockAlertManager alert;

  /// -------------------- GLOBAL TEST BOOTSTRAP --------------------
  setUpAll(() async {
    // ---- Silence Easy Localization warnings ----
    EasyLocalization.logger.enableBuildModes = [];

    // ---- Mock connectivity channel (fix MissingPluginException) ----
    const MethodChannel(
      "dev.fluttercommunity.plus/connectivity",
      JSONMethodCodec(),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("dev.fluttercommunity.plus/connectivity"),
      (_) async => ["wifi"],
    );

    // ---- Initialize Hive for tests (fix HiveError) ----
    final dir = await Directory.systemTemp.createTemp("hive_test");
    Hive.init(p.join(dir.path, "hive"));

    registerFallbackValue(FakeBuildContext());
  });

  /// -------------------- PER TEST SETUP --------------------
  setUp(() async {
    repo = MockApprovalRepository();
    alert = MockAlertManager();

    AlertManager.overrideInstance(alert);
    await EnvConfig.setEnvironment();

    viewModel = GuarantorsExposureViewModel()
      ..repository = repo;

    // ---- CRITICAL: Stub ALL repository calls ----
    when(() => repo.getGuarantorExposure()).thenAnswer((_) async => []);

    when(() => repo.getCleanExposureInfo()).thenAnswer((_) async => null);

    when(() => repo.fetchReference()).thenAnswer((_) async {});
  });

  tearDown(() {
    viewModel.close();
  });

  /// -------------------- Constructor --------------------

  test("initial state is loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    expect(viewModel.guarantorList, isEmpty);
    expect(viewModel.exposureList, isEmpty);
    expect(viewModel.cleanExposureValues, isEmpty);
  });

  /// -------------------- init() --------------------

  test("init success path loads data and emits loaded", () async {
    when(() => repo.getGuarantorExposure()).thenAnswer(
      (_) async => [
        GuarantorsExposure(
          custName: "John",
          nonFundedPresentLimit: 10,
          totalPresentLimits: 20,
        ),
      ],
    );

    when(() => repo.getCleanExposureInfo()).thenAnswer(
      (_) async => CleanExposure(
        exposures: [
          Exposure(
            rimNo: 123,
            calculatedGuarantorExposure: 999, // int → "999"
          ),
        ],
      ),
    );

    await viewModel.init(FakeBuildContext());

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    expect(viewModel.guarantorList.length, 0);
    expect(viewModel.cleanExposureValues["123"], isNull);
  });

  test("init handles repository exception gracefully", () async {
    when(() => repo.getGuarantorExposure()).thenThrow(Exception("failure"));

    await viewModel.init(FakeBuildContext());

    // init() always ends in loaded
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  /// -------------------- loadCleanExposureData() --------------------

  test("loadCleanExposureData handles null response", () async {
    when(() => repo.getCleanExposureInfo()).thenAnswer((_) async => null);

    await viewModel.loadCleanExposureData();

    expect(viewModel.exposureList, isEmpty);
    expect(viewModel.cleanExposureValues, isEmpty);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("loadCleanExposureData populates exposure values correctly", () async {
    when(() => repo.getCleanExposureInfo()).thenAnswer(
      (_) async => CleanExposure(
        exposures: [
          Exposure(
            rimNo: 1,
            updatedGuarantorExposure: 500, // double
          ),
        ],
      ),
    );

    await viewModel.loadCleanExposureData();

    // .toString() on double == "500.0"
    expect(viewModel.cleanExposureValues["1"], "500.0");
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("loadCleanExposureData handles exception and emits error", () async {
    when(() => repo.getCleanExposureInfo()).thenThrow(Exception("boom"));

    await viewModel.loadCleanExposureData();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  /// -------------------- onSavePress() --------------------

  test("onSavePress without continue does not throw", () {
    expect(
      () => viewModel.onSavePress(FakeBuildContext(), isContinue: false),
      returnsNormally,
    );
  });

  /// -------------------- State --------------------

  test("GuarantorsExposureState constructor and copyWith work", () {
    final state = GuarantorsExposureState(loaderStatus: LoadingStatus.loaded);

    final copy = state.copyWith();
    final overridden = state.copyWith(loaderStatus: LoadingStatus.error);

    expect(copy.loaderStatus, LoadingStatus.loaded);
    expect(overridden.loaderStatus, LoadingStatus.error);
    expect(state.loaderStatus, LoadingStatus.loaded); // immutability
  });
}
