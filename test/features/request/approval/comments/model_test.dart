import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
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
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockCommonRepository extends Mock implements CommonRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockController extends Mock implements UnifiedEditorController {}

class MockDraftRepository extends Mock implements DraftRepository {}

class FakeComment extends Fake implements Comment {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  late CommentsViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlert;
  late MockApprovalRepository mockApprovalRepository;
  late MockController mockController;
  late MockDraftRepository mockDraftRepository;
  late BuildContext fakeContext;
  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() async {
    await EnvConfig.setEnvironment();

    registerFallbackValue(CommentsType.approval);
    registerFallbackValue(EntityIdentifier.approval);
    registerFallbackValue(FakeComment());
    registerFallbackValue(User());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <dynamic>["wifi"];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async => "wifi",
    );
  });

  setUp(() async {
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockController = MockController();
    mockDraftRepository = MockDraftRepository();
    mockAlert = MockAlertManager();
    fakeContext = MockBuildContext();

    CommonRepository.overrideInstance = mockCommonRepository;
    RequestRepository.overrideInstance = mockRequestRepository;
    ApprovalRepository.overrideInstance = mockApprovalRepository;
    DraftRepository.overrideInstance = mockDraftRepository;
    AlertManager.overrideInstance = mockAlert;

    mockLocalStorageService = MockLocalStorageService();
    LocalStorageService().getStorage = mockLocalStorageService;

    Globals.user = User(
      id: "u1",
      approvalAccess: true,
      approveOnBehalfOf: true,
      currentRole: Role(
        roleId: 1,
        code: "ADMIN",
        name: "Admin",
        bpmRole: "ADMIN-WCAS",
        userRole: UserRole.admin,
      ),
    );

    // IMPORTANT:
    // Globals.request type is Request?, not ApplicationDetails?.
    // Keep it null to avoid ApplicationDetails -> Request cast error.
    Globals.request = null;

    Globals.applicationDetails = ApplicationDetails(
      requestType: "MEMO",
      applicationLifeCycle: ApplicationLifeCycle(
        assignedBy: "u1",
        assignedByRole: 1,
        userAction: 0,
      ),
    );

    Globals.superRolesId = [
      {"CA": 1},
      {"ADMIN": 1},
      {"RM": 2},
    ];

    Globals.superUserRoles = [
      {
        "ADMIN": "ADMIN-WCAS",
        "RO": "RO-WCAS",
        "RM": "RM-WCAS",
        "CA": "CA-WCAS",
        "CFO": "Chief Financial Officer-WCAS",
      },
    ];

    Globals.recommendReferences = [];
    Globals.returnReferences = [];
    Globals.approvalReferences = [];
    Globals.delegationReferences = [];

    Globals.userAction = [
      {"Recommended": 10},
      {"Returned": 11},
      {"Approved": 12},
      {"Declined": 13},
      {"Approve on behalf of": 14},
      {"Accept Close Application": 15},
    ];

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async {});

    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "");

    when(() => mockApprovalRepository.getLastAssignedRole())
        .thenAnswer((_) async => null);

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

    viewModel = CommentsViewModel()
      ..repository = mockRequestRepository
      ..approvalRepository = mockApprovalRepository
      ..controller = mockController;
  });

  group("initial state", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.returnOptSelected, "");
    });

    test("CommentsState constructor and copyWith", () {
      final state =
          CommentsState(loaderStatus: LoadingStatus.loading, getRole: "RM");

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.getRole, "RM");

      final copied = state.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loading);
      expect(copied.getRole, "RM");

      final updated =
          state.copyWith(loaderStatus: LoadingStatus.loaded, getRole: "ADMIN");

      expect(updated.loaderStatus, LoadingStatus.loaded);
      expect(updated.getRole, "ADMIN");
    });
  });

  group("init()", () {
    test("init completes happy path", () async {
      Globals.user = User(
        id: "admin1",
        approvalAccess: true,
        approveOnBehalfOf: false,
        currentRole: Role(
          roleId: ServerConstants.userRoleId[UserRole.admin] ?? 1,
          code: "ADMIN",
          userRole: UserRole.admin,
          name: "Admin",
        ),
      );

      Globals.request = null;

      Globals.applicationDetails = ApplicationDetails(
        requestType: "MEMO",
        applicationLifeCycle: ApplicationLifeCycle(
          assignedBy: "admin1",
          assignedByRole: 1,
          userAction: ServerConstants.userActionRecommend,
        ),
      );

      Globals.recommendReferences = [];
      Globals.returnReferences = [];
      Globals.approvalReferences = [];
      Globals.delegationReferences = [];

      Globals.superRolesId = [
        {"CA": 1},
      ];

      when(() => mockRequestRepository.getApplicationDetails())
          .thenAnswer((_) async => ApplicationDetails());

      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => []);

      when(() => mockApprovalRepository.getInitiatedRole())
          .thenAnswer((_) async => "CA");

      await viewModel.init(fakeContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.initiatedRole, "CA");
      expect(viewModel.initRoleId, 1);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepository.fetchReference()).called(1);
      verify(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).called(1);
    });

    test("init catches exception", () async {
      when(() => mockRequestRepository.getApplicationDetails())
          .thenThrow(Exception("Init failed"));

      await viewModel.init(fakeContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("assignValues()", () {
    test("assignValues maps lifecycle and flags", () {
      Globals.user = User(
        id: "u100",
        approvalAccess: true,
        approveOnBehalfOf: false,
        currentRole: Role(
          code: "CA",
          roleId: ServerConstants.userRoleId[UserRole.creditAnalyst],
          userRole: UserRole.creditAnalyst,
        ),
      );

      Globals.applicationDetails = ApplicationDetails(
        requestType: "MEMO",
        applicationLifeCycle: ApplicationLifeCycle(
          assignedBy: "maker1",
          assignedByRole: 9,
          userAction: ServerConstants.userActionReturn,
        ),
      );

      viewModel
        ..initiatedRole =
            ServerConstants.userRoleCode[UserRole.creditAnalyst] ?? "CA"
        ..assignValues();

      expect(viewModel.assignedBy, "maker1");
      expect(viewModel.assignedByRole, 9);
      expect(viewModel.userAction, ServerConstants.userActionReturn);
      expect(viewModel.isInitByCA, true);
      expect(viewModel.isApproveButtonVisible, true);
      expect(viewModel.isApproveDelegationButtonVisible, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("assignValues handles null lifecycle", () {
      Globals.applicationDetails = ApplicationDetails();

      Globals.user = User(
        approvalAccess: false,
        approveOnBehalfOf: true,
        currentRole: Role(
          code: "RM",
          userRole: UserRole.relationshipManager,
        ),
      );

      viewModel.assignValues();

      expect(viewModel.assignedBy, "");
      expect(viewModel.assignedByRole, 0);
      expect(viewModel.userAction, 0);
      expect(viewModel.isApproveOnBehalfButtonVisible, true);
      expect(viewModel.isApproveDelegationButtonVisible, true);
    });
  });

  group("getComments()", () {
    test("handles exception and shows failure toast", () async {
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
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("handles empty list", () async {
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

      expect(viewModel.initialText, isEmpty);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("single different user comment is visible", () async {
      final comments = [
        Comment(
          userId: "u3",
          userRole: 1,
          comment: "Other user comment",
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
    });

    test("own comment sets editor text and removes own comment", () async {
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
      expect(viewModel.comments, isEmpty);

      verify(() => mockController.setText("My comment")).called(1);
    });
  });

  group("onReturnOptChanged()", () {
    test("updates selected option and action id", () {
      viewModel.onReturnOptChanged("Rework");

      expect(viewModel.returnOptSelected, "Rework");
      expect(viewModel.optsActionId, ServerConstants.returnForQuery);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("unknown option sets action id zero", () {
      viewModel.onReturnOptChanged("Unknown");

      expect(viewModel.returnOptSelected, "Unknown");
      expect(viewModel.optsActionId, 0);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("saveReviewComments()", () {
    test("saves comment and returns id", () async {
      viewModel
        ..reviewCommentId = "0"
        ..optsActionId = 99;

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Hello approval</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "555");

      final id = await viewModel.saveReviewComments();

      expect(id, "555");
      expect(viewModel.reviewCommentId, "555");

      final captured = verify(
        () => mockApprovalRepository.saveReviewComments(captureAny()),
      ).captured.single as Comment;

      expect(captured.comment, "<p>Hello approval</p>");
      expect(captured.reasonList, "99");
    });

    test("returns existing id on exception", () async {
      viewModel.reviewCommentId = "123";

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Failure</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenThrow(Exception("Save failed"));

      final id = await viewModel.saveReviewComments();

      expect(id, "123");
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("onSavePress()", () {
    test("shows error when comment is empty", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>&nbsp;</p>");

      await viewModel.onSavePress(context: fakeContext);

      verify(() => mockController.getText()).called(1);
      verifyNever(() => mockApprovalRepository.saveReviewComments(any()));
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("saves valid comment, deletes draft, reloads comments", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Valid remarks</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "777");

      when(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.onSavePress(context: fakeContext);

      expect(viewModel.reviewCommentId, "0");

      verify(() => mockApprovalRepository.saveReviewComments(any())).called(1);

      verify(
        () => mockCommonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        ),
      ).called(1);
    });

    test("handles exception while saving", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Crash</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenThrow(Exception("Save failed"));

      await viewModel.onSavePress(context: fakeContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("getUsersByRole()", () {
    test("empty list returns empty map", () {
      final result = viewModel.getUsersByRole([]);

      expect(result, isEmpty);
    });

    test("groups users by current role name", () {
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

      final result = viewModel.getUsersByRole(users);

      expect(result, isA<Map<String, List<User>>>());
      expect(result.length, 2);
      expect(result["RO"]!.length, 2);
      expect(result["RM"]!.length, 1);
    });

    test("null role name groups under empty string", () {
      final users = [
        User(
          id: "1",
          name: "No Role",
          currentRole: Role(roleId: 1),
        ),
      ];

      final result = viewModel.getUsersByRole(users);

      expect(result.containsKey(""), true);
      expect(result[""]!.length, 0);
    });
  });

  group("getUserListDropDownItems()", () {
    test("empty map returns empty list", () {
      final result = viewModel.getUserListDropDownItems({});

      expect(result, isEmpty);
    });

    test("creates header and user items", () {
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
      expect(result[0].isHeader, true);
      expect(result[0].label, "RM");
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

      expect(viewModel.returnPrefill, isNotNull);
      expect(viewModel.returnPrefill!.label, "User4 - 1");
    });

    test("sets recommendPrefill when lifecycle conditions match", () {
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

      expect(viewModel.recommendPrefill, isNotNull);
      expect(viewModel.recommendPrefill!.label, "User4 - 1");
    });

    test("does not set prefill when lifecycle does not match", () {
      viewModel
        ..userAction = ServerConstants.sendToDocumentMaker
        ..assignedBy = "999"
        ..assignedByRole = 99;

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
      expect(viewModel.recommendPrefill, isNull);
    });
  });

  // group("getUserListByGroup()", () {
  //   test("recommendation list returns grouped users", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.relationshipOfficer),
  //     );

  //     Globals.recommendReferences = [
  //       Reference(name: "RO", reference1: "RO,RM,CA"),
  //     ];

  //     Globals.superUserRoles = [
  //       {
  //         "RO": "RO-WCAS",
  //         "RM": "RM-WCAS",
  //         "CA": "CA-WCAS",
  //       },
  //     ];

  //     final mockUsers = [
  //       User(
  //         id: "123",
  //         name: "User1",
  //         currentRole: Role(name: "RO", roleId: 1, bpmRole: "RO-WCAS"),
  //       ),
  //       User(
  //         id: "456",
  //         name: "User2",
  //         currentRole: Role(name: "RM", roleId: 4, bpmRole: "RM-WCAS"),
  //       ),
  //       User(
  //         id: "789",
  //         name: "User3",
  //         currentRole: Role(name: "CA", roleId: 2, bpmRole: "CA-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => mockUsers);

  //     final result = await viewModel.getUserListByGroup(
  //       ReferenceDataKeys.recommendationList,
  //     );

  //     expect(result, isA<Map<String, List<User>>>());
  //     expect(result.length, 3);
  //   });

  //   test("returned list filters users below initiated role id", () async {
  //     viewModel.initRoleId = 5;

  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.relationshipManager),
  //     );

  //     Globals.returnReferences = [
  //       Reference(name: "RM", reference1: "RO,CA"),
  //     ];

  //     Globals.superUserRoles = [
  //       {
  //         "RO": "RO-WCAS",
  //         "CA": "CA-WCAS",
  //       },
  //     ];

  //     final apiUsers = [
  //       User(
  //         id: "low",
  //         name: "Low User",
  //         currentRole: Role(name: "RO", roleId: 3, bpmRole: "RO-WCAS"),
  //       ),
  //       User(
  //         id: "high",
  //         name: "High User",
  //         currentRole: Role(name: "CA", roleId: 6, bpmRole: "CA-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => apiUsers);

  //     final result = await viewModel.getUserListByGroup(
  //       ReferenceDataKeys.returnedRolesList,
  //     );

  //     expect(result.length, 1);
  //     expect(result.containsKey("CA"), true);
  //     expect(result["CA"]!.single.id, "high");
  //   });

  //   test("returns empty when references are empty", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.relationshipOfficer),
  //     );

  //     Globals.recommendReferences = [];
  //     Globals.superUserRoles = [
  //       {"RM": "RM-WCAS"},
  //     ];

  //     final result = await viewModel.getUserListByGroup(
  //       ReferenceDataKeys.recommendationList,
  //     );

  //     expect(result, isEmpty);
  //   });

  //   test("returns empty when mapped bpm roles are empty", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.relationshipOfficer),
  //     );

  //     Globals.recommendReferences = [
  //       Reference(name: "RO", reference1: "UNKNOWN"),
  //     ];

  //     Globals.superUserRoles = [
  //       {"RM": "RM-WCAS"},
  //     ];

  //     final result = await viewModel.getUserListByGroup(
  //       ReferenceDataKeys.recommendationList,
  //     );

  //     expect(result, isEmpty);
  //     verifyNever(() => mockApprovalRepository.getFilteredUsersByrole(any()));
  //   });
  // });

  group("getApprovalDelegationList()", () {
    test("returns empty list when no delegation matches", () async {
      Globals.user = User(currentRole: Role(roleId: 126));
      Globals.delegationReferences = [
        Reference(reference1: "125", name: "delegation1"),
      ];

      final result = await viewModel.getApprovalDelegationList(
        ReferenceDataKeys.approvalDelegationList,
      );

      expect(result, isEmpty);
    });

    test("returns matching delegation names", () async {
      Globals.user = User(currentRole: Role(roleId: 126));

      Globals.delegationReferences = [
        Reference(reference1: "125,126", name: "delegation1"),
        Reference(reference1: "125,135", name: "delegation2"),
      ];

      final result = await viewModel.getApprovalDelegationList(
        ReferenceDataKeys.approvalDelegationList,
      );

      expect(result, isA<List<String>>());
      expect(result.length, 1);
      expect(result.first, "delegation1");
    });

    test("removes CFO when not risk rating", () async {
      viewModel.isRiskRatingInit = false;

      Globals.user = User(currentRole: Role(roleId: 101));

      Globals.delegationReferences = [
        Reference(reference1: "101", name: "CFO"),
        Reference(reference1: "101", name: "Unit Head"),
      ];

      final result = await viewModel.getApprovalDelegationList(
        ReferenceDataKeys.approvalDelegationList,
      );

      expect(result.contains("CFO"), false);
      expect(result.contains("Unit Head"), true);
    });

    test("keeps CFO when risk rating", () async {
      viewModel.isRiskRatingInit = true;

      Globals.user = User(currentRole: Role(roleId: 101));

      Globals.delegationReferences = [
        Reference(reference1: "101", name: "CFO"),
      ];

      final result = await viewModel.getApprovalDelegationList(
        ReferenceDataKeys.approvalDelegationList,
      );

      expect(result.contains("CFO"), true);
    });
  });

  // group("getApprovalUserListByGroup()", () {
  //   test("returns empty map when roles list is empty", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [];
  //     Globals.superUserRoles = [
  //       {"RM": "RM-WCAS"},
  //     ];

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result, isEmpty);
  //   });

  //   test("returns grouped users when reference2 has valid roles", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(
  //         name: "SH-B1",
  //         reference2: "RO,RM",
  //       ),
  //     ];

  //     Globals.superUserRoles = [
  //       {
  //         "RO": "RO-WCAS",
  //         "RM": "RM-WCAS",
  //       },
  //     ];

  //     final mockUsers = [
  //       User(
  //         id: "1",
  //         name: "User1",
  //         currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
  //       ),
  //       User(
  //         id: "2",
  //         name: "User2",
  //         currentRole: Role(name: "RM", bpmRole: "RM-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => mockUsers);

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result, isNotEmpty);
  //     expect(result.length, 2);
  //   });

  //   test("uses reference3 roles also", () async {
  //     viewModel.isRiskRatingInit = false;

  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(name: "SH-B1", reference3: "RM"),
  //     ];

  //     Globals.superUserRoles = [
  //       {"RM": "RM-WCAS"},
  //     ];

  //     final users = [
  //       User(
  //         id: "rm1",
  //         name: "RM User",
  //         currentRole: Role(name: "RM", bpmRole: "RM-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => users);

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result.containsKey("RM"), true);
  //   });

  //   test("removes CFO when not risk rating", () async {
  //     viewModel.isRiskRatingInit = false;

  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(name: "SH-B1", reference2: "CFO,RO"),
  //     ];

  //     Globals.superUserRoles = [
  //       {
  //         "CFO": "Chief Financial Officer-WCAS",
  //         "RO": "RO-WCAS",
  //       },
  //     ];

  //     final mockUsers = [
  //       User(
  //         id: "1",
  //         name: "User1",
  //         currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => mockUsers);

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result.containsKey("CFO"), false);
  //     expect(result, isNotEmpty);
  //   });

  //   test("adds CFO heading user when risk rating", () async {
  //     viewModel.isRiskRatingInit = true;

  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(name: "SH-B1", reference2: "RO"),
  //     ];

  //     Globals.superUserRoles = [
  //       {
  //         "RO": "RO-WCAS",
  //         "CFO": "Chief Financial Officer-WCAS",
  //       },
  //     ];

  //     final mockUsers = [
  //       User(
  //         id: "1",
  //         name: "User1",
  //         currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => mockUsers);

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result.containsKey("CFO"), true);
  //     expect(result, isNotEmpty);
  //   });

  //   test("risk rating removes existing CFO user and adds CFO header", () async {
  //     viewModel.isRiskRatingInit = true;

  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(name: "SH-B1", reference2: "CFO"),
  //     ];

  //     Globals.superUserRoles = [
  //       {"CFO": "Chief Financial Officer-WCAS"},
  //     ];

  //     final users = [
  //       User(
  //         id: "actual-cfo",
  //         name: "Actual CFO",
  //         currentRole: Role(
  //           name: "Old CFO",
  //           bpmRole: "Chief Financial Officer-WCAS",
  //         ),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => users);

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result.containsKey("CFO"), true);
  //     expect(result["CFO"]!.single.id, isNull);
  //     expect(
  //       result["CFO"]!.single.currentRole?.bpmRole,
  //       "Chief Financial Officer-WCAS",
  //     );
  //   });

  //   test("returns empty map on exception", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(name: "SH-B1", reference2: "RO"),
  //     ];

  //     Globals.superUserRoles = [
  //       {"RO": "RO-WCAS"},
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenThrow(Exception("API error"));

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result, isEmpty);
  //     expect(viewModel.state.loaderStatus, LoadingStatus.error);
  //   });

  //   test("deduplicates roles", () async {
  //     Globals.user = User(
  //       currentRole: Role(userRole: UserRole.segmentHeadLevelB1),
  //     );

  //     Globals.approvalReferences = [
  //       Reference(
  //         name: "SH-B1",
  //         reference2: "RO,RO,RM",
  //         reference3: "RM",
  //       ),
  //     ];

  //     Globals.superUserRoles = [
  //       {
  //         "RO": "RO-WCAS",
  //         "RM": "RM-WCAS",
  //       },
  //     ];

  //     final mockUsers = [
  //       User(
  //         id: "1",
  //         name: "User1",
  //         currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
  //       ),
  //     ];

  //     when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
  //         .thenAnswer((_) async => mockUsers);

  //     final result = await viewModel.getApprovalUserListByGroup();

  //     expect(result, isNotEmpty);
  //   });
  // });

  group("setSelectedUser()", () {
    test("sets false when selected role is not RM bpm role", () {
      viewModel
        ..roleMap = {"RM": "RM-WCAS"}
        ..setSelectedUser("CA-WCAS");

      expect(viewModel.isRMselected, false);
      expect(viewModel.state.isRMselected, false);
    });

    test("sets true when selected role is RM bpm role", () {
      viewModel
        ..roleMap = {"RM": "RM-WCAS"}
        ..setSelectedUser("RM-WCAS");

      expect(viewModel.isRMselected, true);
      expect(viewModel.state.isRMselected, true);
    });
  });

  group("validateRsaToken()", () {
    test("returns false when digit length is not 10", () async {
      viewModel.rsaDigit = "123456";
      expect(await viewModel.validateRsaToken(), false);

      viewModel.rsaDigit = "12345678901";
      expect(await viewModel.validateRsaToken(), false);
    });

    test("returns false when token invalid", () async {
      viewModel.rsaDigit = "1234567890";

      when(() => mockApprovalRepository.validateRSAToken("1234567890"))
          .thenAnswer((_) async => false);

      final result = await viewModel.validateRsaToken();

      expect(result, false);
    });

    test("returns true when token valid", () async {
      viewModel.rsaDigit = "1234567890";

      when(() => mockApprovalRepository.validateRSAToken("1234567890"))
          .thenAnswer((_) async => true);

      final result = await viewModel.validateRsaToken();

      expect(result, true);
    });
  });

  group("validateApproval()", () {
    test("returns null on success", () async {
      Globals.userAction = [
        {"Recommended": 10},
      ];

      final response = AppResponse(
        message: "",
        body: {"responseData": []},
        code: 0,
        status: ResponseStatus.success,
      );

      when(() => mockApprovalRepository.validateApproval(any()))
          .thenAnswer((_) async => response);

      final result = await viewModel.validateApproval(UserAction.recommended);

      expect(result, isNull);
    });

    test("returns error description on 422", () async {
      Globals.userAction = [
        {"Recommended": 10},
      ];

      final response = AppResponse(
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

      final result = await viewModel.validateApproval(UserAction.recommended);

      expect(result, "Warning: One Validation check remaining");
    });

    test("returns null on non 422 error", () async {
      Globals.userAction = [
        {"Recommended": 10},
      ];

      final response = AppResponse(
        message: "",
        body: {
          "baseResponse": {
            "status": {
              "errorCode": "500",
              "errorDescription": "Server error",
            },
          },
        },
        code: 0,
        status: ResponseStatus.error,
      );

      when(() => mockApprovalRepository.validateApproval(any()))
          .thenAnswer((_) async => response);

      final result = await viewModel.validateApproval(UserAction.recommended);

      expect(result, isNull);
    });
  });

  group("submitApplication()", () {
    test("returns empty when comment text is empty", () async {
      viewModel.initialText = "";

      when(() => mockController.getText()).thenAnswer((_) async => "");

      final result = await viewModel.submitApplication(UserAction.recommended);

      expect(result, isEmpty);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("returns empty when initialText is empty even if editor has text",
        () async {
      viewModel.initialText = "";

      when(() => mockController.getText()).thenAnswer((_) async => "Text");

      final result = await viewModel.submitApplication(UserAction.recommended);

      expect(result, isEmpty);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("shows failure when user is not selected for returned action",
        () async {
      viewModel.initialText = "Comment";

      when(() => mockController.getText()).thenAnswer((_) async => "Comment");

      final result = await viewModel.submitApplication(UserAction.returned);

      expect(result, isEmpty);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("CA returning to RM requires option", () async {
      Globals.user = User(
        id: "ca1",
        currentRole: Role(
          code: ServerConstants.userRoleCode[UserRole.creditAnalyst],
          userRole: UserRole.creditAnalyst,
        ),
      );

      viewModel
        ..initialText = "Comment"
        ..selectedUserId = "user1:RM-WCAS"
        ..isRMselected = true
        ..optsActionId = 0;

      when(() => mockController.getText()).thenAnswer((_) async => "Comment");

      final result = await viewModel.submitApplication(UserAction.returned);

      expect(result, isEmpty);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("returned action success returns moved confirmation", () async {
      viewModel
        ..initialText = "Sample"
        ..selectedUserId = "user1:RO"
        ..reviewCommentId = "100"
        ..returnUserMap = {
          "RO": [
            User(
              id: "user1",
              name: "User 1",
              currentRole: Role(name: "RO", bpmRole: "RO"),
            ),
          ],
        };

      Globals.request = null;

      Globals.userAction = [
        {"Returned": 11},
      ];

      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        ),
      );

      final result = await viewModel.submitApplication(UserAction.returned);

      expect(result, isNotEmpty);
      expect(result.first, contains("layout.topmenu.comfirmation"));
      expect(result.last, contains("approval.comments.applicationMoved"));
    });

    test("recommended action success returns moved confirmation", () async {
      viewModel
        ..initialText = "Sample"
        ..selectedUserId = "user1:RO"
        ..reviewCommentId = "101"
        ..recommendUserMap = {
          "RO": [
            User(
              id: "user1",
              name: "User 1",
              currentRole: Role(name: "RO", bpmRole: "RO"),
            ),
          ],
        };

      Globals.request = null;

      Globals.userAction = [
        {"Recommended": 10},
      ];

      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        ),
      );

      final result = await viewModel.submitApplication(UserAction.recommended);

      expect(result, isNotEmpty);
      expect(result.last, contains("approval.comments.applicationMoved"));
    });

    test("approved requires delegation", () async {
      viewModel.initialText = "Sample";

      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      final result = await viewModel.submitApplication(UserAction.approved);

      expect(result, isEmpty);
      verify(
        () => mockAlert.showFailureToast(
          "approval.comments.selectDelegationbeforeSubmit",
        ),
      ).called(1);
    });

    test("approved submits successfully with delegation", () async {
      viewModel
        ..initialText = "Approval comment"
        ..selectedDelegation = "Unit Head"
        ..reviewCommentId = "900";

      Globals.request = null;

      Globals.userAction = [
        {"Approved": 12},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Approval comment");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        ),
      );

      final result = await viewModel.submitApplication(UserAction.approved);

      expect(result, isNotEmpty);
      expect(result.first, contains("layout.topmenu.comfirmation"));
      expect(result.last, contains("approval.comments.applicationStatus"));
    });

    test("declined requires reason", () async {
      viewModel.initialText = "Sample";

      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      final result = await viewModel.submitApplication(UserAction.declined);

      expect(result, isEmpty);
      verify(
        () => mockAlert.showFailureToast(
          "approval.comments.selectReasonbeforeSubmit",
        ),
      ).called(1);
    });

    test("declined submits successfully with reason", () async {
      viewModel
        ..initialText = "Decline comment"
        ..selectedReason = "Invalid request"
        ..reviewCommentId = "901";

      Globals.request = null;

      Globals.userAction = [
        {"Declined": 13},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Decline comment");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        ),
      );

      final result = await viewModel.submitApplication(UserAction.declined);

      expect(result, isNotEmpty);
      expect(result.last, contains("approval.comments.applicationStatus"));
    });

    test("approveOnBehalf submits successfully", () async {
      viewModel
        ..initialText = "Approve behalf comment"
        ..selectedUserId = "ap1:DM"
        ..selectedDelegation = "Delegation"
        ..approveUserMap = {
          "Approver": [
            User(
              id: "ap1",
              name: "Approver",
              currentRole: Role(name: "Approver", bpmRole: "DM"),
            ),
          ],
        };

      Globals.userAction = [
        {"Approve on behalf of": 14},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Approve behalf comment");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        ),
      );

      final result =
          await viewModel.submitApplication(UserAction.approveOnBehalfOf);

      expect(result, isNotEmpty);
    });

    test("returns 422 validation descriptions", () async {
      viewModel
        ..initialText = "Return comment"
        ..selectedUserId = "u2:RO-WCAS"
        ..reviewCommentId = "902"
        ..returnUserMap = {
          "RO": [
            User(
              id: "u2",
              name: "Return User",
              currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
            ),
          ],
        };

      Globals.userAction = [
        {"Returned": 11},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Return comment");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.error,
          message: "Validation",
          body: {
            "baseResponse": {
              "status": {
                "errorCode": "422",
                "errorDescription": "Warning one; Warning two",
              },
            },
          },
        ),
      );

      final result = await viewModel.submitApplication(UserAction.returned);

      expect(result.length, 2);
      expect(result.first, "Warning one");
      expect(result.last, "Warning two");
    });

    test("generic failure shows toast and returns empty", () async {
      viewModel
        ..initialText = "Return comment"
        ..selectedUserId = "u2:RO-WCAS"
        ..returnUserMap = {
          "RO-WCAS": [
            User(
              id: "u2",
              name: "Return User",
              currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
            ),
          ],
        };

      Globals.userAction = [
        {"Returned": 11},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Return comment");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.error,
          message: "Error",
          body: {},
        ),
      );

      final result = await viewModel.submitApplication(UserAction.returned);

      expect(result, isEmpty);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("exception returns empty list and shows toast", () async {
      viewModel
        ..initialText = "Return comment"
        ..selectedUserId = "u2:RO-WCAS"
        ..returnUserMap = {
          "RO-WCAS": [
            User(
              id: "u2",
              name: "Return User",
              currentRole: Role(name: "RO", bpmRole: "RO-WCAS"),
            ),
          ],
        };

      Globals.userAction = [
        {"Returned": 11},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Return comment");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenThrow(Exception("API error"));

      final result = await viewModel.submitApplication(UserAction.returned);

      expect(result, isEmpty);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("risk rating accept close application saves comment before submit",
        () async {
      viewModel
        ..initialText = "Close comment"
        ..isRiskRatingInit = true
        ..reviewCommentId = "0";

      Globals.request = null;

      Globals.userAction = [
        {"Accept Close Application": 15},
      ];

      when(() => mockController.getText())
          .thenAnswer((_) async => "Close comment");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "333");

      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
          returnToUser: any(named: "returnToUser"),
          avoidWarning: any(named: "avoidWarning"),
          approvalDelegation: any(named: "approvalDelegation"),
          reasonForDecline: any(named: "reasonForDecline"),
          userAction: any(named: "userAction"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        ),
      );

      final result = await viewModel.submitApplication(
        UserAction.acceptCloseApplication,
      );

      expect(viewModel.reviewCommentId, "333");
      expect(result, isNotEmpty);
    });

    group("user resolution across role groups", () {
      /// Multi-group map: the selected user exists in one group only.
      Map<String, List<User>> multiGroupMap() => {
            "CA": [
              User(
                id: "ca1",
                name: "Credit Analyst",
                currentRole: Role(name: "CA", bpmRole: "CA-WCAS", roleId: 12),
              ),
            ],
            "TL-D1": [
              User(
                id: "tl1",
                name: "Team Leader",
                currentRole:
                    Role(name: "TL-D1", bpmRole: "TL-WCAS", roleId: 18),
              ),
            ],
          };

      void stubSubmitSuccess() {
        when(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
            returnToUser: any(named: "returnToUser"),
            avoidWarning: any(named: "avoidWarning"),
            approvalDelegation: any(named: "approvalDelegation"),
            reasonForDecline: any(named: "reasonForDecline"),
            userAction: any(named: "userAction"),
          ),
        ).thenAnswer(
          (_) async => AppResponse(
            status: ResponseStatus.success,
            message: "Success",
            body: {},
          ),
        );
      }

      setUp(() {
        Globals.request = null;
        Globals.userAction = [
          {"Recommended": 10},
          {"Returned": 11},
        ];
      });

      test(
          "resolves user from a non-last role group instead of overwriting "
          "with an empty user", () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "ca1:CA-WCAS"
          ..recommendUserMap = multiGroupMap();

        when(() => mockController.getText()).thenAnswer((_) async => "Sample");
        stubSubmitSuccess();

        final result =
            await viewModel.submitApplication(UserAction.recommended);

        expect(result, isNotEmpty);
        expect(viewModel.selectedUser.id, "ca1");
        expect(viewModel.selectedUser.currentRole?.bpmRole, "CA-WCAS");
      });

      test("resolves user from the last role group", () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "tl1:TL-WCAS"
          ..recommendUserMap = multiGroupMap();

        when(() => mockController.getText()).thenAnswer((_) async => "Sample");
        stubSubmitSuccess();

        final result =
            await viewModel.submitApplication(UserAction.recommended);

        expect(result, isNotEmpty);
        expect(viewModel.selectedUser.id, "tl1");
        expect(viewModel.selectedUser.currentRole?.bpmRole, "TL-WCAS");
      });

      // test("applies the selected role to the resolved user", () async {
      //   viewModel
      //     ..initialText = "Sample"
      //     ..selectedUserId = "ca1:CA-OVERRIDE"
      //     ..returnUserMap = multiGroupMap();

      //   when(() => mockController.getText()).thenAnswer((_) async => "Sample");
      //   stubSubmitSuccess();

      //   await viewModel.submitApplication(UserAction.returned);

      //   expect(viewModel.selectedUser.currentRole?.bpmRole, "CA-OVERRIDE");
      // });

      test("blocks submit when the selected id matches no user in any group",
          () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "ghost:CA-WCAS"
          ..recommendUserMap = multiGroupMap();

        when(() => mockController.getText()).thenAnswer((_) async => "Sample");

        final result =
            await viewModel.submitApplication(UserAction.recommended);

        expect(result, isEmpty);
        verify(() => mockAlert.showFailureToast(any())).called(1);
        verifyNever(
          () => mockApprovalRepository.submitApplication(
            any(),
            any(),
            any(),
            returnToUser: any(named: "returnToUser"),
            avoidWarning: any(named: "avoidWarning"),
            approvalDelegation: any(named: "approvalDelegation"),
            reasonForDecline: any(named: "reasonForDecline"),
            userAction: any(named: "userAction"),
          ),
        );
      });

      test("blocks submit when the action's user map is empty", () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = "ca1:CA-WCAS"
          ..recommendUserMap = {};

        when(() => mockController.getText()).thenAnswer((_) async => "Sample");

        final result =
            await viewModel.submitApplication(UserAction.recommended);

        expect(result, isEmpty);
        verify(() => mockAlert.showFailureToast(any())).called(1);
      });

      test("leaves user resolution untouched for actions without a user map",
          () async {
        viewModel
          ..initialText = "Sample"
          ..selectedUserId = ""
          ..selectedDelegation = "Delegation"
          ..recommendUserMap = multiGroupMap();

        Globals.userAction = [
          {"Approved": 12},
        ];

        when(() => mockController.getText()).thenAnswer((_) async => "Sample");
        stubSubmitSuccess();

        final result = await viewModel.submitApplication(UserAction.approved);

        expect(result, isNotEmpty);
      });
    });
  });

  group("buttonVisibilityStatus", () {
    test("all configured button visibility callbacks return bool", () {
      for (final entry in viewModel.buttonVisibilityStatus.entries) {
        expect(entry.value(), isA<bool>());
      }
    });

    test("map contains key approval fields", () {
      expect(
        viewModel.buttonVisibilityStatus.containsKey(ApprovalFields.amendRAROC),
        true,
      );
      expect(
        viewModel.buttonVisibilityStatus.containsKey(ApprovalFields.approve),
        true,
      );
      expect(
        viewModel.buttonVisibilityStatus.containsKey(ApprovalFields.returns),
        true,
      );
      expect(
        viewModel.buttonVisibilityStatus.containsKey(ApprovalFields.save),
        true,
      );
      expect(
        viewModel.buttonVisibilityStatus
            .containsKey(ApprovalFields.approveonbehalf),
        true,
      );
    });
  });

  group("close()", () {
    test("close completes", () async {
      await viewModel.close();

      expect(true, true);
    });
  });
}
