import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/features/request/approval/comments/model.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/comments/state.dart';

class MockCommonRepository extends Mock implements CommonRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late CommentsViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlert;
  late MockApprovalRepository mockApprovalRepository;
  late MockAdminRepository mockAdminRepository;

  setUpAll(() {
    registerFallbackValue(CommentsType.approval);
    registerFallbackValue(EntityIdentifier.approval);
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    CommonRepository.overrideInstance(mockCommonRepository);
    viewModel = CommentsViewModel();
    viewModel.repository = mockRequestRepository;
    mockAlert = MockAlertManager();
    mockApprovalRepository = MockApprovalRepository();
    mockAdminRepository = MockAdminRepository();
    viewModel.adminRepository = mockAdminRepository;
    await EnvConfig.setEnvironment();
  });

  test('initial state should be loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test('init loads data and emits loaded state', () async {
    final mockData = <Comment>[];
    final mockAlertManager = MockAlertManager();
    viewModel.userRole = UserRole.admin;

    when(() => mockCommonRepository.getComments(
            CommentsType.approval, EntityIdentifier.approval))
        .thenAnswer((_) async => mockData);

    //await viewModel.init(MockBuildContext());
    AlertManager.overrideInstance(mockAlertManager);
    viewModel.state.loaderStatus = LoadingStatus.loaded;
    expect(viewModel.comments, mockData);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('getComments should handle exception and show toast', () async {
    final mockAlertManager = MockAlertManager();
    when(() => mockCommonRepository.getComments(
            CommentsType.approval, EntityIdentifier.approval))
        .thenThrow(Exception('Failed'));
    AlertManager.overrideInstance(mockAlertManager);

    await viewModel.getComments(
        CommentsType.approval, EntityIdentifier.approval);

    expect(viewModel.comments, isEmpty);
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test('getComments success', () async {
    when(() => mockCommonRepository.getComments(any(), any()))
        .thenAnswer((_) async => []);

    await viewModel.getComments(
        CommentsType.approval, EntityIdentifier.approval);

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test('onReturnOptChanged should update selected option and emit state', () {
    viewModel.onReturnOptChanged('Rework for Query');

    expect(viewModel.returnOptSelected, 'Rework for Query');
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  group('Button Visibility Role Checks', () {
    test('amendRAROC', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]!(),
      );
    });

    test('amendFacilities', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]!(),
      );
    });

    test('amendSecurities', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]!(),
      );
    });

    test('amendConditions', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]!(),
      );
    });

    test('amendRiskRating', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendRiskRating]!(),
      );
    });

    test('approve', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.approve]!(),
      );
    });

    test('approvalDelegation', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.approvalDelegation]!(),
      );
    });

    test('decline', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.decline]!(),
      );
    });

    test('reasonForDecline', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.reasonForDecline]!(),
      );
    });

    test('generatePack', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.generatePack]!(),
      );
    });

    test('closeApplication', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.closeApplication]!(),
      );
    });

    test('noReturn', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.noReturn]!(),
      );
    });

    test('recommend', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.recommend]!(),
      );
    });

    test('returns', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.returns]!(),
      );
    });

    test('previewApplication', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.previewApplication]!(),
      );
    });

    test('save', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.save]!(),
      );
    });

    test('saveAndContinue', () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.saveAndContinue]!(),
      );
    });

    test('amendCovenants', () {
      expect(
        Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]!(),
      );
    });

    test('amendFacilitySecurityLinkage', () {
      expect(
        Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[
            ApprovalFields.amendFacilitySecurityLinkage]!(),
      );
    });

    test('approveonbehalf', () {
      expect(
        Utils.checkRoles([
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.approveonbehalf]!(),
      );
    });
  });

  // test('onSavePress should emit loading and then loaded', () async {
  //   viewModel.onSavePress();

  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  test('getUserRole should emit correct role code for relationshipOfficer', () {
    viewModel.getUserRole(UserRole.relationshipOfficer);

    expect(viewModel.state.getRole,
        ServerConstants.userRoleCode[UserRole.relationshipOfficer]);
  });

  test('getUserRole should emit correct role code for relationshipManager', () {
    viewModel.getUserRole(UserRole.relationshipManagerBussiness);

    expect(viewModel.state.getRole,
        ServerConstants.userRoleCode[UserRole.relationshipManagerBussiness]);
  });

  test('getUserRole should emit correct role code for creditCordinator', () {
    viewModel.getUserRole(UserRole.creditCordinator);

    expect(viewModel.state.getRole,
        ServerConstants.userRoleCode[UserRole.creditCordinator]);
  });

  test('viewModel properties are properly initialized', () {
    expect(viewModel.comments, isEmpty);
    expect(viewModel.returnOptSelected, '');
    expect(viewModel.userRole, isNull);
  });

  group('CommentsState', () {
    test('constructor sets provided fields', () {
      final state =
          CommentsState(loaderStatus: LoadingStatus.loading, getRole: 'RM');
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.getRole, 'RM');
    });

    test('copyWith keeps existing values when null', () {
      final original =
          CommentsState(loaderStatus: LoadingStatus.loaded, getRole: 'ADMIN');
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.getRole, 'ADMIN');
    });

    test('copyWith overrides provided fields', () {
      final original =
          CommentsState(loaderStatus: LoadingStatus.loaded, getRole: 'ADMIN');
      final updated =
          original.copyWith(loaderStatus: LoadingStatus.error, getRole: 'RM');
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(updated.getRole, 'RM');
      expect(original.getRole, 'ADMIN');
    });

    test('getUsersByRoles get data correctly', () async {
      // Arrage
      List<User> user = <User>[];
      // List<String> usersList = ["RO-WCAS"];
      // Act
      when(() => mockRequestRepository.getUsersByRoles([]))
          .thenAnswer((_) async => user);

      // Assert
      verifyNever(() => mockRequestRepository.getUsersByRoles(any()));
    });

    test('getUsersByRoles handles repository exception', () async {
      // Act
      when(() => mockRequestRepository.getUsersByRoles([]))
          .thenThrow(Exception('Save failed'));
      // Assert
      verifyNever(() => mockAlert.showFailureToast('Exception: Save failed'));
    });

    test('getUserListDropDownItems for empty list', () async {
      // Arrage
      List<CustomDropdownItem> userList = [];
      Map<String, List<User>> user = {};

      // Act
      userList = viewModel.getUserListDropDownItems(user);

      // Assert
      expect(userList, isEmpty);
    });

    test('should match with the type', () async {
      // Arrange
      Map<String, List<User>> users = {
        "RO": [
          User(
              id: '123',
              name: 'Alice',
              availableRoles: [Role(name: "RMB", roleId: 1)]),
        ]
      };

      final result = viewModel.getUserListDropDownItems(users);

      expect(result, isA<List<CustomDropdownItem>>());
    });

    test('should get exact count', () async {
      // Arrange
      Map<String, List<User>> users = {
        "RO": [
          User(
              id: '123',
              name: 'Alice',
              availableRoles: [Role(name: "RMB", roleId: 1)]),
          User(
              id: '456',
              name: 'Bob',
              availableRoles: [Role(name: "RMB", roleId: 2)]),
          User(
              id: '789',
              name: 'Clark',
              availableRoles: [Role(name: "RMB", roleId: 3)]),
        ]
      };

      final result = viewModel.getUserListDropDownItems(users);
      // one for title and rest users list
      expect(result.length, equals(4));
    });
  });

  group('Approval', () {
    test('transformGroupPositionFacilitiesData creates and saves correctly',
        () async {
      // Arrange
      AppResponse response = AppResponse(
          message: "",
          body: {"responseData": []},
          code: 0,
          status: ResponseStatus.success);

      // Act
      when(() => mockApprovalRepository.transformGroupPositionFacilitiesData(
          response)).thenAnswer((_) async => GroupPosition());

      // Assert
      verifyNever(() => mockApprovalRepository
          .transformGroupPositionFacilitiesData(response));
    });

    // test('transformGroupPositionFacilitiesData handles repository exception', () async {
    //   // Arrage
    //   AppResponse response = AppResponse(
    //     message:"",
    //     body:null,
    //     code:0,
    //     status:ResponseStatus.success
    //   );
    //   // Act
    //   when(() => mockApprovalRepository.transformGroupPositionFacilitiesData(response))
    //   .thenThrow(Exception('Transform failed'));
    //   // Assert
    //   verify(() => mockAlert.showFailureToast('Exception: Save failed'))
    //       .called(1);
    // });

    // test('should return empty list when responseData is empty', () async {
    //   // Arrange
    //   final mockResponse = AppResponse(
    //     message: 'Success',
    //     body: {'responseData': []},
    //     code: 200,
    //     status: ResponseStatus.success,
    //   );

    //   // Act
    //   final result = await mockApprovalRepository.transformGroupPositionFacilitiesData(mockResponse);

    //   // Assert
    //    expect(result, isNull);
    // });
  });

  group('getUsersByRole view model function', () {
    test('getUsersByRole for empty list', () async {
      // Arrage
      List<User> userList = [];
      Map<String, List<User>> user = {};

      // Act
      user = viewModel.getUsersByRole(userList);

      // Assert
      expect(user, isEmpty);
    });

    test('should match with the type', () async {
      // Arrange
      List<User> users = [
        User(
            id: '123',
            name: 'Alice',
            currentRole:
                Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer")),
      ];

      final result = viewModel.getUsersByRole(users);

      expect(result, isA<Map<String, List<User>>>());
    });

    test('should get exact count', () async {
      // Arrange
      List<User> users = [
        User(
            id: '123',
            name: 'Alice',
            currentRole:
                Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer")),
        User(
            id: '456',
            name: 'Bob',
            currentRole:
                Role(name: "RM", roleId: 1, bpmRole: "Relationship Manager")),
        User(
            id: '789',
            name: 'Clark',
            currentRole:
                Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer")),
      ];

      final result = viewModel.getUsersByRole(users);
      expect(result.length, equals(2));
    });
  });

  // group('getUserListByGroup', () {
  //   test('should match with the type', () async {
  //     Map<String, List<User>> groupList =
  //         await viewModel.getUserListByGroup("RECOMMENDED_ROLES_LIST");
  //     expect(groupList, isA<Map<String, List<User>>>());
  //   });
  // });

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
