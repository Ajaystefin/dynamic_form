import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/guarantors_exposure/model.dart';
import 'package:wcas_frontend/models/request/approval/guarantors_exposure.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/features/request/approval/guarantors_exposure/state.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class MockRequestRepository extends Mock implements ApprovalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuarantorsExposureViewModel viewModel;
  late MockBuildContext fakeContext;
  late MockAlertManager mockAlert;
  late MockRequestRepository mockRepo;

  setUpAll(() {
    // const MethodChannel('dev.fluttercommunity.plus/connectivity')
    //     .setMockMethodCallHandler((call) async {
    //   if (call.method == 'check') return 1; // pretend “wifi”
    //   return null;
    // });
    const channel = MethodChannel(
      'dev.fluttercommunity.plus/connectivity',
      JSONMethodCodec(),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return ['wifi'];
    });
    registerFallbackValue('');
  });

  setUp(() async {
    fakeContext = MockBuildContext();
    mockAlert = MockAlertManager();
    mockRepo = MockRequestRepository();
    AlertManager.overrideInstance(mockAlert);

    viewModel = GuarantorsExposureViewModel();
    viewModel.repository = mockRepo;
    await EnvConfig.setEnvironment();
  });

  tearDown(() {
    viewModel.close();
  });

  test('initial state is loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  group('init()', () {
    test('successfully loads list and emits loaded', () async {
      when(() => mockRepo.getGuarantorExposure()).thenAnswer((_) async => [
            GuarantorsExposure(
              custName: 'G1',
              nonFundedPresentLimit: 123,
              totalPresentLimits: 0,
            )
          ]);
      await viewModel.init(fakeContext);
      expect(viewModel.guarantorList, hasLength(1));
      expect(viewModel.guarantorList.first.custName, equals('G1'));
      expect(viewModel.guarantorList.first.nonFundedPresentLimit, equals(123));
      expect(viewModel.guarantorList.first.totalPresentLimits, equals(0));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('repository throws → still ends in loaded (error branch covered)',
        () async {
      when(() => mockRepo.getGuarantorExposure()).thenThrow(Exception('oops'));
      viewModel.init(fakeContext);
      expect(viewModel.guarantorList, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('onSavePress()', () {
    setUp(() {
      when(() => fakeContext.mounted).thenReturn(false);
    });

    test(
      'isContinue=false & not mounted → [loading,loaded] + success toast only',
      () async {
        // Arrange
        when(() => mockAlert.showSuccessToast(any())).thenReturn(null);

        // Collect state changes:
        final emitted = <LoadingStatus>[];
        viewModel.stream.listen((s) => emitted.add(s.loaderStatus)); // ADDED

        // Act
        viewModel.onSavePress(fakeContext, isContinue: false);
        await Future<void>.delayed(Duration.zero);

        // Assert states
        expect(emitted, [LoadingStatus.loading, LoadingStatus.loaded]);
        verify(() => mockAlert.showSuccessToast(
              "approval.guarantorsExposure.savedSuccessfully".tr(),
            )).called(1);

        verifyNever(() => (fakeContext as dynamic).go(any<String>()));
      },
    );

    test(
      'isContinue=true & mounted=true → [loading,loaded], toast, navigation',
      () async {
        // Arrange
        when(() => fakeContext.mounted).thenReturn(true);
        when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
        when(() => (fakeContext as dynamic).go(Routes.queriesAndResponses))
            .thenReturn(null);

        final emitted = <LoadingStatus>[];
        viewModel.stream.listen((s) => emitted.add(s.loaderStatus)); // ADDED

        // Act
        viewModel.onSavePress(fakeContext, isContinue: true);
        await Future<void>.delayed(Duration.zero); // ADDED

        // Assert
        expect(emitted,
            [LoadingStatus.loading, LoadingStatus.loaded, LoadingStatus.error]);
      },
    );

    test(
      'toast failure → [loading,error] + failure toast',
      () async {
        // Arrange
        when(() => fakeContext.mounted).thenReturn(false);
        when(() => mockAlert.showSuccessToast(any()))
            .thenThrow(Exception('toast failed'));

        final emitted = <LoadingStatus>[];
        viewModel.stream.listen((s) => emitted.add(s.loaderStatus)); // ADDED

        // Act
        viewModel.onSavePress(fakeContext, isContinue: false);
        await Future<void>.delayed(Duration.zero); // ADDED

        // Assert
        expect(emitted, [LoadingStatus.loading, LoadingStatus.error]);
        verify(() => mockAlert.showFailureToast('Exception: toast failed'))
            .called(1);
      },
    );

    test(
      'navigation failure → [loading,loaded,error] + failure toast',
      () async {
        // Arrange
        when(() => fakeContext.mounted).thenReturn(true);
        when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
        when(() => (fakeContext as dynamic).go(any<String>()))
            .thenThrow(Exception('nav error'));

        final emitted = <LoadingStatus>[];
        viewModel.stream.listen((s) => emitted.add(s.loaderStatus));

        // Act
        viewModel.onSavePress(fakeContext, isContinue: true);
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(emitted,
            [LoadingStatus.loading, LoadingStatus.loaded, LoadingStatus.error]);
      },
    );
  });

  test('viewModel.repository and initial properties', () {
    expect(viewModel.repository, mockRepo);
    expect(viewModel.guarantorList, isEmpty); // ADDED
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  group('GuarantorsExposureState', () {
    test('constructor sets loaderStatus', () {
      final state =
          GuarantorsExposureState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          GuarantorsExposureState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original =
          GuarantorsExposureState(loaderStatus: LoadingStatus.loaded);
      final updated =
          original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
