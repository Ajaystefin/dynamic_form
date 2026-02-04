import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/state.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
    JSONMethodCodec(),
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
    return <String>['wifi']; // must return List<String>, not raw JSON
  });

  late RequestForLimitReleaseViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockApprovalRepository mockApprovalRepository;

  setUpAll(() async {
    registerFallbackValue(CommentsType.requestForFOL);
    registerFallbackValue(EntityIdentifier.requestForFOL);
    registerFallbackValue(Comment());
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();

    // 2) Override the singleton instance in your tests
    CommonRepository.overrideInstance(mockCommonRepository);
    ApprovalRepository.overrideInstance(mockApprovalRepository);

    viewModel = RequestForLimitReleaseViewModel();
    viewModel.repository = mockRequestRepository;
  });

  group("init state", () {
    test('initial state should be loading', () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    // test('init loads data and emits loaded state', () async {
    //   // Arrange
    //   final testUser = User(
    //       id: 'testUser123',
    //       name: 'Test User',
    //       currentRole: Role(id: 1, code: 'ADMIN', name: 'Administrator'),
    //       availableRoles: [
    //         Role(
    //             id: 1,
    //             code: 'RM',
    //             name: 'Relationship manager',
    //             bpmRole: "RM123")
    //       ]);
    //   Globals.user = testUser;
    //   final mockComments = <Comment>[Comment()];
    //   when(() => mockCommonRepository.getComments(
    //         CommentsType.requestForLimitRelease,
    //         EntityIdentifier.requestForLimitRelease,
    //       )).thenAnswer((_) async => mockComments);

    //   final mockAlertManager = MockAlertManager();
    //   AlertManager.overrideInstance(mockAlertManager);

    //   // Act
    //   await viewModel.init(MockBuildContext());

    //   // Assert
    //   expect(viewModel.comments, mockComments);
    //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    // });

    test('getComments should handle exception and not crash', () async {
      // Arrange
      when(() => mockCommonRepository.getComments(any(), any()))
          .thenThrow(Exception('Failed'));

      AlertManager.overrideInstance(MockAlertManager());

      // Act
      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );

      // Assert
      expect(viewModel.comments, isEmpty);
    });
  });

  group('Documentation & CCU Button Visibility Role Checks', () {
    test('initiateFinalFOL', () {
      expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!(),
      );
    });

    test('documentationSubmitted', () {
      expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]!(),
      );
    });

    test('sendToDocumentation', () {
      expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!(),
      );
    });

    test('returnToDocumentationMaker', () {
      expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[
            ApprovalFields.returnToDocumentationMaker]!(),
      );
    });

    test('initiateFitToLend', () {
      expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!(),
      );
    });

    test('sendtoCCUMaker', () {
      expect(
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.documentationChecker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUMaker]!(),
      );
    });

    test('stage', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.stage]!(),
      );
    });

    test('returns', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
          UserRole.ccuMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.returns]!(),
      );
    });

    test('sendToCCU', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!(),
      );
    });

    test('sendToDocumentationMaker', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.sendToDocumentationMaker]!(),
      );
    });

    test('rightFirstTime', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.rightFirstTime]!(),
      );
    });

    test('sendToRORM', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToRORM]!(),
      );
    });

    test('draftFolGenerated', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!(),
      );
    });

    test('finalFOLGenerated', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!(),
      );
    });

    test('documentationCompleted', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationCompleted]!(),
      );
    });

    test('sendToDocumentationChecker', () {
      expect(
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
        viewModel.buttonVisibilityStatus[
            ApprovalFields.sendToDocumentationChecker]!(),
      );
    });

    test('sendtoCCUChecker', () {
      expect(
        Utils.checkRoles([
          UserRole.ccuMaker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUChecker]!(),
      );
    });

    test('returntoCCUMaker', () {
      expect(
        Utils.checkRoles([
          UserRole.ccuChecker,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.returntoCCUMaker]!(),
      );
    });

    test('acceptCloseApplication', () {
      expect(
        Utils.checkRoles([
          UserRole.ccuChecker,
        ]),
        viewModel
            .buttonVisibilityStatus[ApprovalFields.acceptCloseApplication]!(),
      );
    });
  });

  test('saveComment should emit loading and then loaded', () async {
    // Arrange
    when(() => mockCommonRepository.saveComment(any()))
        .thenAnswer((_) async => 'Saved');

    AlertManager.overrideInstance(MockAlertManager());

    // Act
    await viewModel.saveComment();

    // Assert
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('saveComment should handle exception and still emit loaded', () async {
    // Arrange
    when(() => mockCommonRepository.saveComment(any()))
        .thenThrow(Exception('Save failed'));

    AlertManager.overrideInstance(MockAlertManager());

    // Act
    await viewModel.saveComment();

    // Assert
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  // test('onSavePress should emit loading and then loaded', () async {
  //   // Act
  //   await viewModel.onSavePress();

  //   // Assert
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  test('viewModel properties are properly initialized', () {
    expect(viewModel.repository, mockRequestRepository);
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
  });

  group('RequestForLimitReleaseState', () {
    test('constructor stores loaderStatus', () {
      final state =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides field', () {
      final original =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loaded);
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
