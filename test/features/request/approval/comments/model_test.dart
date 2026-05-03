import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/comments/model.dart";
import "package:wcas_frontend/features/request/approval/comments/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockCommonRepository extends Mock implements CommonRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockController extends Mock implements UnifiedEditorController {}

class FakeComment extends Fake implements Comment {}

class MockDraftRepository extends Mock implements DraftRepository {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    _storage[box] ??= {};
    _storage[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _storage[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _storage[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _storage[box]?.clear();
  }

  void clearAll() {
    _storage.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  late MockLocalStorageService mockLocalStorageService;
  late CommentsViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlert;
  late MockApprovalRepository mockApprovalRepository;
  // late MockAdminRepository mockAdminRepository;
  late MockController mockController;
  late BuildContext fakeContext;
  late MockDraftRepository mockDraftRepository;

  setUpAll(() async {
    // await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    // SharedPreferences.setMockInitialValues({});
    // await EasyLocalization.ensureInitialized();
    registerFallbackValue(CommentsType.approval);
    registerFallbackValue(EntityIdentifier.approval);
    registerFallbackValue(FakeComment());
    // ignore: deprecated_member_use
    connectivityChannel.setMockMethodCallHandler((call) async {
      if (call.method == "check") {
        return <dynamic>[];
      }
      return null;
    });
  });

  tearDownAll(() {
    // ignore: deprecated_member_use
    connectivityChannel.setMockMethodCallHandler(null);
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (_) async => <String>["wifi"],
    );

    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockController = MockController();
    mockApprovalRepository = MockApprovalRepository();
    mockDraftRepository = MockDraftRepository();
    fakeContext = MockBuildContext();
    // mockAdminRepository = MockAdminRepository();
    mockAlert = MockAlertManager();
    CommonRepository.overrideInstance(mockCommonRepository);
    AlertManager.overrideInstance(mockAlert);
    RequestRepository.overrideInstance(mockRequestRepository);
    DraftRepository.overrideInstance(mockDraftRepository);
    viewModel = CommentsViewModel()
      ..repository = mockRequestRepository
      ..controller = mockController
      ..approvalRepository = mockApprovalRepository;
    // ..adminRepository = mockAdminRepository;

    mockLocalStorageService = MockLocalStorageService();

    DraftRepository.overrideInstance(mockDraftRepository);

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async {});

    // FIX: stub all DraftRepository methods that the mixin calls
    // fire-and-forget — return normally so no exception escapes
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

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async {});

    when(() => mockApprovalRepository.getLastAssignedRole())
        .thenAnswer((_) async => null);

    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "");

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);
    // Connectivity mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return [ConnectivityResult.wifi.name];
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall methodCall) async {
        return "wifi"; // or whatever mock result you need
      },
    );
  });

  test("initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("init loads data and emits loaded state", () async {
    final mockData = <Comment>[];
    viewModel.userRole = UserRole.admin;
    when(
      () => mockCommonRepository.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      ),
    ).thenAnswer((_) async => mockData);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());
    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async {});
    when(() => mockApprovalRepository.getLastAssignedRole())
        .thenAnswer((_) async => Role(roleRM: "CA-WCAS"));
    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "CA");

    // await viewModel.init(fakeContext);
    expect(viewModel.comments, mockData);
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  group("getComments", () {
    test("should handle exception and leave comments empty", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenThrow(Exception("Failed"));
      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );
      expect(viewModel.comments, isEmpty);
    });

    test(" should handle exception and show failure toast", () async {
      when(() => mockAlert.showFailureToast(any())).thenReturn(null);
      when(
        () => viewModel.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => "");

      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test(" handles empty list", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => []);
      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );
      verifyNever(() => mockController.setText(""));
    });

    test("single comment from different user sets isCommentVisible false",
        () async {
      final comments = [
        Comment(
          userId: "u1",
          userRole: 1,
          comment: "Test",
          reviewCommentId: "1",
          createdDate: DateTime.now(),
        ),
      ];

      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );

      expect(viewModel.isCommentVisible, true);
      verifyNever(() => mockController.setText(any()));
    });

    test("single own comment sets text and removes it from list", () async {
      Globals.user = User(id: "u1", currentRole: Role(roleId: 10));
      final comments = [
        Comment(
          userId: "u1",
          userRole: 10,
          comment: "My comment",
          reviewCommentId: "99",
          createdDate: DateTime.now(),
        ),
      ];
      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );

      expect(viewModel.initialText, "My comment");
      expect(viewModel.reviewCommentId, "99");
      expect(viewModel.comments.isEmpty, true);

      verify(() => mockController.setText("My comment")).called(1);
    });

    test("sets text when single comment matches", () async {
      Globals.user = User(id: "1", currentRole: Role(roleId: 10));
      final comment = Comment(
        userId: "1",
        userRole: 10,
        reviewCommentId: "123",
        comment: "Test",
        createdDate: DateTime.now(),
      );
      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => [comment]);

      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );

      verify(() => mockController.setText("Test")).called(1);
      expect(viewModel.reviewCommentId, "123");
      expect(viewModel.initialText, "Test");
    });

    test("sets text with latest comment from multiple", () async {
      Globals.user = User(id: "1", currentRole: Role(roleId: 10));

      final oldComment = Comment(
        userId: "1",
        userRole: 10,
        reviewCommentId: "123",
        comment: "Test",
        createdDate: DateTime(2026, 4, 1),
      );

      final newComment = Comment(
        userId: "1",
        userRole: 10,
        reviewCommentId: "345",
        comment: "Sample",
        createdDate: DateTime(2026, 4, 10),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => [oldComment, newComment]);

      await viewModel.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      );

      verify(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).called(1);

      verify(() => mockController.setText("Sample")).called(1);
      expect(viewModel.reviewCommentId, "345");
      expect(viewModel.initialText, "Sample");
    });
  });

  test("onReturnOptChanged should update selected option and emit state", () {
    viewModel.onReturnOptChanged("Rework for Query");

    expect(viewModel.returnOptSelected, "Rework for Query");
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  group("Button Visibility Role Checks", () {
    test("amendRAROC", () {
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

    test("amendFacilities", () {
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

    test("amendSecurities", () {
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

    test("amendConditions", () {
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

    test("amendRiskRating", () {
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

    test("approve", () {
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

    test("approvalDelegation", () {
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

    test("decline", () {
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

    test("reasonForDecline", () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.reasonForDecline]!(),
      );
    });

    test("generatePack", () {
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

    test("closeApplication", () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.closeApplication]!(),
      );
    });

    test("noReturn", () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.noReturn]!(),
      );
    });

    test("recommend", () {
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

    test("returns", () {
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

    test("previewApplication", () {
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

    test("save", () {
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

    test("saveAndContinue", () {
      expect(
        Utils.checkRoles([
          UserRole.admin,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.saveAndContinue]!(),
      );
    });

    test("amendCovenants", () {
      expect(
        Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
        viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]!(),
      );
    });

    test("amendFacilitySecurityLinkage", () {
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

    test("approveonbehalf", () {
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

  test("viewModel properties are properly initialized", () {
    expect(viewModel.comments, isEmpty);
    expect(viewModel.returnOptSelected, "");
    expect(viewModel.userRole, isNull);
  });

  group("CommentsState", () {
    test("constructor sets provided fields", () {
      final state =
          CommentsState(loaderStatus: LoadingStatus.loading, getRole: "RM");
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.getRole, "RM");
    });

    test("copyWith keeps existing values when null", () {
      final original =
          CommentsState(loaderStatus: LoadingStatus.loaded, getRole: "ADMIN");
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.getRole, "ADMIN");
    });

    test("copyWith overrides provided fields", () {
      final original =
          CommentsState(loaderStatus: LoadingStatus.loaded, getRole: "ADMIN");
      final updated =
          original.copyWith(loaderStatus: LoadingStatus.error, getRole: "RM");
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(updated.getRole, "RM");
      expect(original.getRole, "ADMIN");
    });

    test("getUsersByRoles get data correctly", () async {
      // Arrage
      final List<User> user = <User>[];
      // List<String> usersList = ["RO-WCAS"];
      // Act
      when(() => mockRequestRepository.getUsersByRoles([]))
          .thenAnswer((_) async => user);

      // Assert
      verifyNever(() => mockRequestRepository.getUsersByRoles(any()));
    });

    test("getUsersByRoles handles repository exception", () async {
      // Act
      when(() => mockRequestRepository.getUsersByRoles([]))
          .thenThrow(Exception("Save failed"));
      // Assert
      verifyNever(() => mockAlert.showFailureToast("Exception: Save failed"));
    });
  });

  group("Approval", () {
    test("transformGroupPositionFacilitiesData creates and saves correctly",
        () async {
      // Arrange
      final AppResponse response = AppResponse(
        message: "",
        body: {"responseData": []},
        code: 0,
        status: ResponseStatus.success,
      );

      // Act
      when(
        () => mockApprovalRepository.transformGroupPositionFacilitiesData(
          response,
        ),
      ).thenAnswer((_) async => GroupPosition());

      // Assert
      verifyNever(
        () => mockApprovalRepository
            .transformGroupPositionFacilitiesData(response),
      );
    });
  });

  group("getUsersByRole view model function", () {
    test("getUsersByRole for empty list", () async {
      // Arrage
      final List<User> userList = [];
      Map<String, List<User>> user = {};

      // Act
      user = viewModel.getUsersByRole(userList);

      // Assert
      expect(user, isEmpty);
    });

    test("should match with the type", () async {
      // Arrange
      final List<User> users = [
        User(
          id: "123",
          name: "Alice",
          currentRole:
              Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer"),
        ),
      ];

      final result = viewModel.getUsersByRole(users);

      expect(result, isA<Map<String, List<User>>>());
    });

    test("should get exact count", () async {
      // Arrange
      final List<User> users = [
        User(
          id: "123",
          name: "Alice",
          currentRole:
              Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer"),
        ),
        User(
          id: "456",
          name: "Bob",
          currentRole:
              Role(name: "RM", roleId: 1, bpmRole: "Relationship Manager"),
        ),
        User(
          id: "789",
          name: "Clark",
          currentRole:
              Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer"),
        ),
      ];

      final result = viewModel.getUsersByRole(users);
      expect(result.length, equals(2));
    });
  });

  // test('checkIsInitiated return type string', () async {
  //   final role = await mockApprovalRepository.getInitiatedRole();
  //   expect(role, isA<String>());
  // });

  group("getUserListByGroup", () {
    test("should return data if data is present", () async {
      Globals.superUserRoles = [
        {
          "RM": "RM-WCAS",
          "RO": "RO-WCAS",
          "CCU-M": "Credit Control Unit Maker",
        },
      ];
      Globals.user =
          User(currentRole: Role(userRole: UserRole.relationshipOfficer));
      Globals.recommendReferences = [
        Reference(name: "RO", reference1: "RO,RM,CCU-M"),
      ];
      final mockResponse = [
        User(
          id: "123",
          name: "User1",
          currentRole:
              Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer"),
        ),
        User(
          id: "456",
          name: "User2",
          currentRole:
              Role(name: "RM", roleId: 4, bpmRole: "Relationship Manager"),
        ),
        User(
          id: "789",
          name: "User3",
          currentRole: Role(
            name: "CCU-M",
            roleId: 2,
            bpmRole: "Credit Control Unit Maker",
          ),
        ),
      ];
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenAnswer((_) async => mockResponse);
      final groupList = await viewModel
          .getUserListByGroup(ReferenceDataKeys.recommendationList);
      expect(groupList, isA<Map<String, List<User>>>());
      expect(groupList.length, 3);
    });

    test("should match with the type", () async {
      Globals.user = User(
        id: "u1",
        currentRole: Role(
          roleId: 10,
          code: "CCU-M",
          userRole: UserRole.relationshipOfficer,
        ),
      );
      Globals.returnReferences = [
        Reference(name: "RO", reference1: "RO,RM,CCU-M"),
      ];
      Globals.superUserRoles = [
        {
          "RM": "RM-WCAS",
          "RO": "RO-WCAS",
        },
      ];
      final mockResponse = User(
        id: "789",
        name: "User3",
        currentRole:
            Role(name: "RO", roleId: 2, bpmRole: "Credit Control Unit Maker"),
      );
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenAnswer((_) async => [mockResponse]);
      final groupList = await viewModel
          .getUserListByGroup(ReferenceDataKeys.returnedRolesList);
      expect(groupList, isA<Map<String, List<User>>>());
    });

    test("should return empty data if reference data is empty", () async {
      Globals.user =
          User(id: "u1", currentRole: Role(roleId: 10, code: "CCU-M"));
      Globals.superUserRoles = [
        {
          "RM": "RM-WCAS",
          "RO": "RO-WCAS",
        },
      ];
      final mockResponse = User(
        id: "789",
        name: "User3",
        currentRole:
            Role(name: "RO", roleId: 2, bpmRole: "Credit Control Unit Maker"),
      );
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenAnswer((_) async => [mockResponse]);
      final groupList = await viewModel
          .getUserListByGroup(ReferenceDataKeys.recommendationList);
      expect(groupList, isEmpty);
    });
  });

  group("getApprovalDelegationList", () {
    test("should return empty list if type is not provided", () async {
      final delegationList = await viewModel.getApprovalDelegationList("");
      expect(delegationList.isEmpty, true);
    });

    test("should return delegations of List<String> type", () async {
      Globals.user = User(id: "u1", currentRole: Role(roleId: 126));
      Globals.delegationReferences = [
        Reference(reference1: "125,126", name: "delegation1"),
        Reference(reference1: "125,135", name: "delegation2"),
      ];
      final delegationList = await viewModel
          .getApprovalDelegationList(ReferenceDataKeys.approvalDelegationList);
      expect(delegationList, isA<List<String>>());
      expect(delegationList.length, 1);
    });
  });

  group("getApprovalUserListByGroup()", () {
    test("should handle exception", () async {
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenThrow(Exception("Error"));
      final approvalList = await viewModel.getApprovalUserListByGroup();
      expect(approvalList, isEmpty);
    });

    test("should return data of Map<String,List<User>> type", () async {
      Globals.user = User(
        id: "u1",
        currentRole: Role(roleId: 126, userRole: UserRole.segmentHeadLevelB1),
      );
      Globals.superUserRoles = [
        {
          "RM": "RM-WCAS",
          "RO": "RO-WCAS",
          "CCU-M": "Credit Control Unit Maker",
        },
      ];
      final mockResponse = [
        User(
          id: "123",
          name: "User1",
          currentRole:
              Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer"),
        ),
        User(
          id: "456",
          name: "User2",
          currentRole:
              Role(name: "RM", roleId: 4, bpmRole: "Relationship Manager"),
        ),
        User(
          id: "789",
          name: "User3",
          currentRole: Role(
            name: "CCU-M",
            roleId: 2,
            bpmRole: "Credit Control Unit Maker",
          ),
        ),
      ];
      Globals.approvalReferences = [
        Reference(
          id: 1,
          reference2: "RO,RM",
          reference3: "CA,CCOOD",
          name: "SH-B1",
        ),
        Reference(
          id: 2,
          reference2: "CFO,SHB",
          reference3: "SH-B1,SH-B",
          name: "CA",
        ),
      ];
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenAnswer((_) async => mockResponse);
      final approvalList = await viewModel.getApprovalUserListByGroup();
      expect(approvalList, isA<Map<String, List<User>>>());
      expect(approvalList.length, 3);
    });

    test("should show only cfo heading for risk rating", () async {
      viewModel.isRiskRatingInit = true;
      Globals.user = User(
        id: "u1",
        currentRole: Role(roleId: 126, userRole: UserRole.segmentHeadLevelB1),
      );
      Globals.superUserRoles = [
        {
          "RM": "RM-WCAS",
          "RO": "RO-WCAS",
          "CCU-M": "Credit Control Unit Maker",
          "CFO": "CFO",
        },
      ];
      final mockResponse = [
        User(
          id: "123",
          name: "User1",
          currentRole:
              Role(name: "RO", roleId: 1, bpmRole: "Relationship Officer"),
        ),
        User(
          id: "456",
          name: "User2",
          currentRole:
              Role(name: "RM", roleId: 4, bpmRole: "Relationship Manager"),
        ),
        User(
          id: "789",
          name: "User3",
          currentRole: Role(
            name: "CCU-M",
            roleId: 2,
            bpmRole: "Credit Control Unit Maker",
          ),
        ),
      ];
      Globals.approvalReferences = [
        Reference(
          id: 1,
          reference2: "RO,RM",
          reference3: "CA,CCOOD",
          name: "SH-B1",
        ),
        Reference(
          id: 2,
          reference2: "CFO,SHB",
          reference3: "SH-B1,SH-B",
          name: "CA",
        ),
      ];
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenAnswer((_) async => mockResponse);
      final approvalList = await viewModel.getApprovalUserListByGroup();
      expect(approvalList, isA<Map<String, List<User>>>());
      expect(approvalList.length, 4);
    });
  });

  group("onSavePress()", () {
    test("onSavePress shows error when comment is empty", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>&nbsp;</p>");

      await viewModel.onSavePress(context: fakeContext);

      verify(() => mockController.getText()).called(1);
      verifyNever(() => mockApprovalRepository.saveReviewComments(any()));
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    // test('onSavePress show validation message for empty', () async {
    //   when(() => mockController.getText()).thenAnswer((_) async => '<br>');

    //   // when(() => mockApprovalRepository.saveReviewComments(any())).thenAnswer((_) async => '123');

    //   viewModel.onSavePress(context: fakeContext);
    //   when(() => mockController.getText()).thenAnswer((_) async => '<br>');

    //   verifyNever(() => mockApprovalRepository.saveReviewComments(any()));
    //   verify(() => mockAlert.showFailureToast(any())).called(1);
    //   expect(viewModel.reviewCommentId, '0');
    //   expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    // });

    test("onSavePress emits loading when exception occurs", () async {
      viewModel.optsActionId = 10;
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Crash</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenThrow(Exception("Save failed"));

      await viewModel.onSavePress(context: fakeContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("getUserListDropDownItems", () {
    test("should get exact count", () async {
      // Arrange
      final Map<String, List<User>> users = {
        "RO": [
          User(
            id: "123",
            name: "Alice",
            availableRoles: [Role(name: "RMB", roleId: 1)],
          ),
          User(
            id: "456",
            name: "Bob",
            availableRoles: [Role(name: "RMB", roleId: 2)],
          ),
          User(
            id: "789",
            name: "Clark",
            availableRoles: [Role(name: "RMB", roleId: 3)],
          ),
        ],
      };

      final result = viewModel.getUserListDropDownItems(users);
      // one for title and rest users list
      expect(result.length, equals(4));
    });

    test("getUserListDropDownItems for empty list", () async {
      // Arrage
      List<CustomDropdownItem> userList = [];
      final Map<String, List<User>> user = {};

      // Act
      userList = viewModel.getUserListDropDownItems(user);

      // Assert
      expect(userList, isEmpty);
    });

    test("should match with the type", () async {
      // Arrange
      final Map<String, List<User>> users = {
        "RO": [
          User(
            id: "123",
            name: "Alice",
            availableRoles: [Role(name: "RMB", roleId: 1)],
          ),
        ],
      };

      final result = viewModel.getUserListDropDownItems(users);

      expect(result, isA<List<CustomDropdownItem>>());
    });

    test("creates header and user dropdown items", () {
      final users = {
        "RM": [
          User(
            id: "11",
            name: "User123",
            currentRole: Role(roleId: 10, bpmRole: "RM"),
          ),
        ],
        "RO": [
          User(
            id: "32",
            name: "User456",
            currentRole: Role(roleId: 20, bpmRole: "RO"),
          ),
        ],
      };

      final result = viewModel.getUserListDropDownItems(users);

      expect(result.length, 4);

      // For role it will show as header
      expect(result[0].isHeader, true);
      expect(result[0].label, "RM");

      // For user it will show as element
      expect(result[1].isHeader, false);
      expect(result[1].label, "User123 - 11");

      expect(result[2].isHeader, true);
      expect(result[2].label, "RO");

      expect(result[3].label, "User456 - 32");
    });

    test("onPressed assigns selectedUser", () {
      final user = User(
        id: "10",
        name: "RO123",
        currentRole: Role(roleId: 10, bpmRole: "RM"),
      );

      final users = {
        "RM": [user],
      };

      final items = viewModel.getUserListDropDownItems(users);

      items[1].onPressed!();

      expect(viewModel.selectedUser, same(user));
    });

    test("sets returnPrefill when lifecycle conditions match", () {
      Globals.applicationDetails = ApplicationDetails(
        applicationLifeCycle: ApplicationLifeCycle(
          assignedBy: "1",
          assignedByRole: 10,
          userAction: ServerConstants.userActionRecommend,
        ),
      );
      viewModel
        ..userAction = ServerConstants.userActionRecommend
        ..assignedBy = "1"
        ..assignedByRole = 10;
      final user = User(
        id: "1",
        name: "User4",
        currentRole: Role(roleId: 10, bpmRole: "RM"),
      );

      final users = {
        "RM": [user],
      };

      viewModel.getUserListDropDownItems(users);

      final prefill = viewModel.returnPrefill;
      expect(prefill, isNotNull);
      expect(prefill!.label, "User4 - 1");
    });

    test("sets recommendPrefill when lifecycle conditions match", () {
      Globals.applicationDetails = ApplicationDetails(
        applicationLifeCycle: ApplicationLifeCycle(
          assignedBy: "1",
          assignedByRole: 10,
          userAction: ServerConstants.userActionReturn,
        ),
      );
      viewModel
        ..userAction = ServerConstants.userActionReturn
        ..assignedBy = "1"
        ..assignedByRole = 10;
      final user = User(
        id: "1",
        name: "User4",
        currentRole: Role(roleId: 10, bpmRole: "RM"),
      );

      final users = {
        "RM": [user],
      };

      viewModel.getUserListDropDownItems(users);

      final prefill = viewModel.recommendPrefill;
      expect(prefill, isNotNull);
      expect(prefill!.label, "User4 - 1");
    });

    group("validateApproval", () {
      test("should return empty data if success is return", () async {
        Globals.userAction = [
          {"Recommended": 10},
        ];
        final AppResponse response = AppResponse(
          message: "",
          body: {"responseData": []},
          code: 0,
          status: ResponseStatus.success,
        );
        // when(() => mockApprovalRepository.validateApproval(any()))
        // .thenThrow(Exception('Failed'));
        when(() => mockApprovalRepository.validateApproval(any()))
            .thenAnswer((_) async => response);
        final description =
            await viewModel.validateApproval(UserAction.recommended);
        expect(description, isNull);
      });

      test("should return description if error is return with 422 status code",
          () async {
        Globals.userAction = [
          {"Recommended": 10},
        ];
        final AppResponse response = AppResponse(
          message: "",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "1",
                "statusDescription": "Validation",
                "errorCode": "422",
                "errorDescription": "Warning: One Validation check remaining",
              },
            },
          },
          code: 0,
          status: ResponseStatus.error,
        );
        when(() => mockApprovalRepository.validateApproval(any()))
            .thenAnswer((_) async => response);
        final description =
            await viewModel.validateApproval(UserAction.recommended);
        expect(description, "Warning: One Validation check remaining");
      });
    });

    group("submitApplication()", () {
      test("returns empty when initialText is empty", () async {
        when(() => mockController.getText()).thenAnswer((_) async => "");
        final result = await viewModel.submitApplication(
          UserAction.recommended,
        );

        expect(result, isEmpty);
        verifyNever(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
          ),
        );
        verify(() => mockAlert.showFailureToast(any())).called(1);
      });

      test("show failure toast if the user is not selected", () async {
        viewModel.initialText = "Comment";
        when(() => mockController.getText()).thenAnswer((_) async => "Comment");
        final result = await viewModel.submitApplication(
          UserAction.returned,
        );
        expect(result, isEmpty);
        verifyNever(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
          ),
        );
        verify(() => mockAlert.showFailureToast(any())).called(1);
      });

      test("show failure toast if the CA user does not select option",
          () async {
        viewModel
          ..selectedUserId = "user1:DM"
          ..isRMselected = true;
        Globals.user?.currentRole?.code = "CA";
        when(() => mockController.getText()).thenAnswer((_) async => "Comment");
        final result = await viewModel.submitApplication(
          UserAction.returned,
        );
        verify(() => mockAlert.showFailureToast(any())).called(1);
        expect(result, isEmpty);
      });

      test("check validation for user selection", () async {
        viewModel.initialText = "Sample";
        when(() => mockController.getText()).thenAnswer((_) async => "Sample");
        viewModel.selectedUserId = "";
        Globals.user?.currentRole?.code = "DC";
        Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
        final result = await viewModel.submitApplication(
          UserAction.returned,
        );
        verify(() => mockAlert.showFailureToast(any())).called(1);
        expect(result, isEmpty);
      });

      test("returns confirmation description on successful submit", () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "user1:RO"
          ..returnUserList = [
            User(id: "user1", currentRole: Role(bpmRole: "RO")),
          ];
        when(() => mockController.getText()).thenAnswer((_) async => "Sample");
        Globals.user?.currentRole?.code = "RM";
        Globals.user?.currentRole?.userRole = UserRole.relationshipManager;
        Globals.request?.applicationRefNo = "App123";
        when(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
            returnToUser: any(named: "returnToUser"),
            avoidWarning: any(named: "avoidWarning"),
            mode: any(named: "mode"),
            userAction: any(named: "userAction"),
            stage: any(named: "stage"),
            assignedRole: any(named: "assignedRole"),
          ),
        ).thenAnswer(
          (_) async =>
              AppResponse(status: ResponseStatus.success, message: "Success"),
        );

        final result = await viewModel.submitApplication(
          UserAction.returned,
        );

        expect(result, isA<List<String>>());
        expect(result.first, contains("layout.topmenu.comfirmation"));
        expect(
          result.last,
          contains(
            "approval.comments.applicationMoved",
          ),
        );
      });

      test("returns confirmation description on approval", () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "user1:DM"
          ..selectedDelegation = "delegation1"
          ..approveUserList = [
            User(id: "user1", currentRole: Role(bpmRole: "RO")),
          ];
        when(() => mockController.getText()).thenAnswer((_) async => "Comment");
        Globals.user?.currentRole?.code = "RO";
        Globals.user?.currentRole?.userRole = UserRole.relationshipOfficer;
        Globals.request?.applicationRefNo = "App123";
        when(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
            returnToUser: any(named: "returnToUser"),
            avoidWarning: any(named: "avoidWarning"),
            mode: any(named: "mode"),
            userAction: any(named: "userAction"),
            approvalDelegation: any(named: "approvalDelegation"),
            assignedRole: any(named: "assignedRole"),
            reasonForDecline: any(named: "reasonForDecline"),
          ),
        ).thenAnswer(
          (_) async =>
              AppResponse(status: ResponseStatus.success, message: "Success"),
        );

        final result = await viewModel.submitApplication(
          UserAction.approveOnBehalfOf,
        );

        expect(result, isA<List<String>>());
        debugPrint(" $result");
        expect(result.first, contains("layout.topmenu.comfirmation"));
        expect(
          result.last,
          contains(
            "approval.comments.applicationStatus",
          ),
        );
      });

      test("returns empty description when submission fails", () async {
        // bypass validations
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "user1:DM";
        when(() => mockController.getText()).thenAnswer((_) async => "");
        when(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async =>
              AppResponse(status: ResponseStatus.error, message: "Error"),
        );

        final result = await viewModel.submitApplication(
          UserAction.returned,
        );

        expect(result, isEmpty);
      });

      test("returns empty list on exception", () async {
        // bypass validations
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "user1:DM";
        when(() => mockController.getText()).thenAnswer((_) async => "");
        when(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(Exception("API error"));

        final result = await viewModel.submitApplication(
          UserAction.returned,
        );

        expect(result, isEmpty);
      });

      test("check validation on approve and decline", () async {
        viewModel.initialText = "Sample";
        when(() => mockController.getText()).thenAnswer((_) async => "Comment");
        viewModel
          ..selectedUserId = "user1:DM"
          ..approveUserList = [
            User(id: "user1", currentRole: Role(bpmRole: "RO")),
          ];
        Globals.user?.currentRole?.code = "CA";
        Globals.user?.currentRole?.userRole = UserRole.creditAnalyst;

        final result1 = await viewModel.submitApplication(
          UserAction.declined,
        );

        expect(result1, isEmpty);
        verify(
          () => mockAlert.showFailureToast(
            "approval.comments.selectReasonbeforeSubmit",
          ),
        ).called(1);

        final result2 = await viewModel.submitApplication(
          UserAction.approved,
        );

        expect(result2, isEmpty);
        verify(
          () => mockAlert.showFailureToast(
            "approval.comments.selectDelegationbeforeSubmit",
          ),
        ).called(1);
      });
    });

    test("does not set returnPrefill when lifecycle does not match", () {
      // Arrange
      Globals.applicationDetails = ApplicationDetails(
        applicationLifeCycle: ApplicationLifeCycle(
          assignedBy: "999",
          assignedByRole: 99,
          userAction: ServerConstants.sendToDocumentMaker,
        ),
      );

      final user = User(
        id: "2",
        name: "User",
        currentRole: Role(roleId: 10, bpmRole: "RM"),
      );

      final users = {
        "RM": [user],
      };

      viewModel.getUserListDropDownItems(users);

      expect(viewModel.returnPrefill, isNull);
    });
  });

  group("getUsersByRole", () {
    test("get emtpy map if the user list is empty", () {
      final userMap = viewModel.getUsersByRole([]);
      expect(userMap, isEmpty);
    });

    test("get user map if the user list present", () {
      final users = [
        User(
          id: "11",
          name: "User123",
          currentRole: Role(roleId: 10, bpmRole: "RM", name: "RM"),
        ),
        User(
          id: "32",
          name: "User456",
          currentRole: Role(roleId: 20, bpmRole: "RO", name: "RO"),
        ),
        User(
          id: "45",
          name: "User789",
          currentRole: Role(roleId: 20, bpmRole: "RO", name: "RO"),
        ),
      ];
      final userMap = viewModel.getUsersByRole(users);
      expect(userMap, isNotEmpty);
      expect(userMap, isA<Map<String, List<User>>>());
      expect(userMap.length, 2);
    });
  });

  group("setSelectedUser()", () {
    test("get false if the role is not RM", () {
      viewModel.setSelectedUser("CA");
      expect(viewModel.isRMselected, false);
    });

    test("get true if the role is RM", () {
      viewModel
        ..roleMap = {"RM": "RM-WCAS"}
        ..setSelectedUser("RM-WCAS");
      expect(viewModel.isRMselected, true);
    });
  });

  group("validateRsaToken()", () {
    test("get false rsaDigit digit is less than or greater 10 digit", () async {
      viewModel.rsaDigit = "123456";
      final value1 = await viewModel.validateRsaToken();
      expect(value1, false);

      viewModel.rsaDigit = "12345678901";
      final value2 = await viewModel.validateRsaToken();
      expect(value2, false);
    });

    test("get false if rsa is invalid or throws exception", () async {
      const digits = "1234567890";
      when(() => mockApprovalRepository.validateRSAToken(digits))
          .thenAnswer((_) async => false);
      final value1 = await viewModel.validateRsaToken();
      expect(value1, false);

      when(() => mockApprovalRepository.validateRSAToken(digits))
          .thenThrow(Exception("Failed"));
      final value2 = await viewModel.validateRsaToken();
      expect(value2, false);
    });

    test("get true if rsa is valid", () async {
      viewModel.rsaDigit = "1234567890";
      when(() => mockApprovalRepository.validateRSAToken(viewModel.rsaDigit))
          .thenAnswer((_) async => true);
      final value = await viewModel.validateRsaToken();
      expect(value, true);
    });
  });
}
