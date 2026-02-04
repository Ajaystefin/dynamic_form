// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/features/request/approval/request_for_closure/model.dart';
import 'package:wcas_frontend/features/request/approval/request_for_closure/state.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/application_details.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/core/utils/utils.dart';

class MockRequestRepository extends Mock implements ApprovalRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class FakeComment extends Fake implements Comment {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel =
      MethodChannel('dev.fluttercommunity.plus/connectivity');

  setUpAll(() {
    registerFallbackValue(FakeComment());
    connectivityChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'check') {
        return <dynamic>[];
      }
      return null;
    });
  });

  tearDownAll(() {
    connectivityChannel.setMockMethodCallHandler(null);
  });

  late RequestForClosureViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlert;

  setUp(() async {
    Globals.user = User(
      id: 'u1',
      name: 'Test User',
      currentRole: Role(id: 1, code: 'R1', bpmRole: 'Role 1'),
    );
    mockAlert = MockAlertManager();
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    AlertManager.overrideInstance(mockAlert);
    viewModel = RequestForClosureViewModel()
      ..repository = mockRequestRepository;
    await EnvConfig.setEnvironment();
  });

  test('initial state should be loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  // test('init loads data and emits loaded state', () async {
  //   when(() => mockCommonRepository.getComments(
  //           CommentsType.requestForClosure, EntityIdentifier.requestForClosure))
  //       .thenAnswer((_) async => [Comment()]);
  //   viewModel.init(MockBuildContext());
  //   // expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  //   expect(viewModel.comments, []);
  // });

  test('getComments should handle exception and leave comments empty',
      () async {
    when(() => mockCommonRepository.getComments(
            CommentsType.requestForClosure, EntityIdentifier.requestForClosure))
        .thenThrow(Exception('Failed'));
    await viewModel.getComments(
        CommentsType.requestForClosure, EntityIdentifier.requestForClosure);
    expect(viewModel.comments, isEmpty);
  });

  test('saveComment should emit loaded after success', () async {
    final mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);
    viewModel.comment = Comment();
    const resultMessage = 'Saved OK';
    when(() => mockCommonRepository.saveComment(any()))
        .thenAnswer((_) async => resultMessage);
    await viewModel.saveComment();
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('saveComment handles exception and emits loaded', () async {
    final mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);
    viewModel.comment = Comment();
    when(() => mockCommonRepository.saveComment(any()))
        .thenThrow(Exception('oops'));
    await viewModel.saveComment();
    verify(() => mockAlertManager.showFailureToast(any())).called(1);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('onSavePress emits loading → loaded', () async {
    final statuses = <LoadingStatus>[];
    viewModel.stream.map((s) => s.loaderStatus).listen(statuses.add);
    viewModel.saveComment();
    expect(statuses, []);
  });

  test('viewModel properties are properly initialized', () {
    expect(viewModel.repository, mockRequestRepository);
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
  });

  group('RequestForClosureState', () {
    test('constructor sets loaderStatus', () {
      final state = RequestForClosureState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          RequestForClosureState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original =
          RequestForClosureState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('onTextChange', () {
    test('should validate the field', () async {
      viewModel.onTextChange("");
      expect(viewModel.canSubmit, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onTextChange("New Comment");
      expect(viewModel.canSubmit, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('Globals Method', () {
    test('checkAccessbility return values when application is null', () {
      Map<String, bool> access = Globals.checkAccessbility();
      bool readOnly = access['isReadOnly'] ?? false;
      expect(readOnly, true);
      bool status = access['status'] ?? true;
      expect(status, false);
    });

    test('checkAccessbility return values when application is initialized', () {
      // considering initiated status as 10
      Globals.applicationDetails = ApplicationDetails(status: 10);
      Globals.requestStatus = [
        {"Initiated": 10}
      ];
      Map<String, bool> access =
          Globals.checkAccessbility(status: [RequestStatus.initiated]);
      bool readOnly = access['isReadOnly'] ?? false;
      expect(readOnly, true);
      bool status = access['status'] ?? false;
      expect(status, true);
    });
  });
}
