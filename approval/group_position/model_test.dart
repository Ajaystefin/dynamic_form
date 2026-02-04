import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/group_position/model.dart';
//import 'package:wcas_frontend/models/request/approval/group_position.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/features/request/approval/group_position/state.dart';

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
    throw Exception('navErr');
  }
}

class TestAlertManager implements AlertManager {
  String? lastFailure, lastSuccess;

  @override
  void showFailureToast(String message) => lastFailure = message;

  @override
  void showSuccessToast(String message) => lastSuccess = message;

  @override
  void showInfoToast(String message) {}

  @override
  void showWarningToast(String message) {}
}

class MockAlertManager extends Mock implements AlertManager {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

    

void main() {
  const channel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
    JSONMethodCodec(),
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => ['wifi']);

  late GroupPositionViewModel viewModel;
  late MockRequestRepository mockRepo;
  late TestAlertManager alertSpy;
  late TestBuildContext context;
  late MockAlertManager mockAlert;
  // late MockApprovalRepository mockApprovalRepository;

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockRepo = MockRequestRepository();
    // mockApprovalRepository = MockApprovalRepository();
    alertSpy = TestAlertManager();
    context = TestBuildContext();
    mockAlert = MockAlertManager();
    AlertManager.overrideInstance(mockAlert);

    viewModel = GroupPositionViewModel()..repository = mockRepo;
  });

  test('initial state & defaults', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    expect(viewModel.groups, isEmpty);
    expect(viewModel.rowsPerPage, 12);
    expect(viewModel.repository, mockRepo);
  });

  // testWidgets('init() generates 0 dummy groups & emits loaded', (tester) async {
  //   await tester.pumpWidget(const SizedBox());

  //   mockApprovalRepository.groupPositionData =  GroupPosition(presentPosition: <Position>[], proposedPosition: <Position>[]);
  //   final future = viewModel.init(context);
  //   await tester.pump(const Duration(seconds: 2));
  //   await future;

  //   expect(viewModel.groups, hasLength(0));
  //   //expect(viewModel.groups!.first, isA<CustomerPosition>());
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  group('onSavePress()', () {
    testWidgets(
      'isContinue=false & mounted=false → success toast no nav loaded',
      (tester) async {
        context.mounted = false;

        viewModel.onSavePress(context, isContinue: false);
        await tester.pumpAndSettle();

        expect(alertSpy.lastSuccess, null);
        expect(context.goCount, 0);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    testWidgets(
      'isContinue=false & mounted=true → success toast no nav loaded',
      (tester) async {
        context.mounted = true;

        viewModel.onSavePress(context, isContinue: false);
        await tester.pumpAndSettle();

        expect(alertSpy.lastSuccess, null);
        expect(context.goCount, 0);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    testWidgets(
      'isContinue=true & mounted=true → success toast nav loaded',
      (tester) async {
        context.mounted = true;

        viewModel.onSavePress(context, isContinue: true);
        await tester.pumpAndSettle();

        expect(alertSpy.lastSuccess, null);
        expect(context.goCount, 0);
        expect(context.lastRoute, null);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      },
    );

    testWidgets(
      'navigation throws → failure toast error status',
      (tester) async {
        context.mounted = true;

        viewModel.onSavePress(context, isContinue: true);
        await tester.pumpAndSettle();
        expect(alertSpy.lastFailure, null);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      },
    );
  });

  group('GroupPositionState', () {
    test('constructor sets loaderStatus', () {
      final state = GroupPositionState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original = GroupPositionState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original = GroupPositionState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
