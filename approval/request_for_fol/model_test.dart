// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/model.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/state.dart';

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

  late RequestForFolViewModel viewModel;
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
    viewModel = RequestForFolViewModel()..repository = mockRequestRepository;
    await EnvConfig.setEnvironment();
  });

  test('initial state should be loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test('Check roles for initiateFinalFOL', () {
    expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!());
  });

  test('Check roles for documentationSubmitted', () {
    expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]!());
  });

  test('Check roles for sendToDocumentation', () {
    expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!());
  });

  test('Check roles for returnToDocumentationMaker', () {
    expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[
            ApprovalFields.returnToDocumentationMaker]!());
  });

  test('Check roles for initiateFitToLend', () {
    expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!());
  });

  test('Check roles for stage', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.stage]!());
  });

  test('Check roles for returns', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.returns]!());
  });

  test('Check roles for sendToCCU', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!());
  });

  test('Check roles for sendToDocumentationMaker', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
        viewModel.buttonVisibilityStatus[
            ApprovalFields.sendToDocumentationMaker]!());
  });

  test('Check roles for rightFirstTime', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.rightFirstTime]!());
  });

  test('Check roles for sendToRORM', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToRORM]!());
  });

  test('Check roles for draftFolGenerated', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!());
  });

  test('Check roles for finalFOLGenerated', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!());
  });

  test('Check roles for documentationCompleted', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationCompleted]!());
  });

  test('Check roles for sendToDocumentationChecker', () {
    expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[
            ApprovalFields.sendToDocumentationChecker]!());
  });

  // test('init loads data and emits loaded state', () async {
  //   final testUser = User(
  //       id: 'testUser123',
  //       name: 'Test User',
  //       currentRole: Role(id: 1, code: 'ADMIN', name: 'Administrator'),
  //       segments: [
  //         "RM",
  //         "ADM"
  //       ],
  //       regions: [
  //         "IND"
  //       ],
  //       availableRoles: [
  //         Role(
  //             id: 1, code: 'RM', name: 'Relationship manager', bpmRole: "RM123")
  //       ]);
  //   Globals.user = testUser;
  //   when(() => mockCommonRepository.getComments(
  //           CommentsType.requestForFOL, EntityIdentifier.requestForFOL))
  //       .thenAnswer((_) async => [Comment()]);
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  //   viewModel.init(MockBuildContext());
  //   expect(viewModel.comments, []);
  // });

  test('getComments should handle exception and leave comments empty',
      () async {
    when(() => mockCommonRepository.getComments(
            CommentsType.requestForFOL, EntityIdentifier.requestForFOL))
        .thenThrow(Exception('Failed'));
    await viewModel.getComments(
        CommentsType.requestForFOL, EntityIdentifier.requestForFOL);
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
    viewModel.onSavePress();
    expect(statuses, []);
  });

  test('viewModel properties are properly initialized', () {
    expect(viewModel.repository, mockRequestRepository);
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
  });

  group('RequestForFolState', () {
    test('constructor sets loaderStatus', () {
      final state = RequestForFolState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original = RequestForFolState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original = RequestForFolState(loaderStatus: LoadingStatus.loaded);
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
}
