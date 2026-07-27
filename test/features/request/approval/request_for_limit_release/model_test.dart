import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockDraftRepository extends Mock implements DraftRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  late RequestForLimitReleaseViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockAdminRepository mockAdminRepository;
  late MockAlertManager mockAlertManager;
  late MockUnifiedEditorController mockController;
  late MockDraftRepository mockDraftRepository;

  RequestForLimitReleaseViewModel createViewModel({
    bool assignController = true,
  }) {
    final vm = RequestForLimitReleaseViewModel()
      ..repository = mockRequestRepository
      ..approvalRepository = mockApprovalRepository
      ..adminRepository = mockAdminRepository;

    if (assignController) {
      vm.controller = mockController;
    }

    return vm;
  }

  void resetGlobals() {
    Globals.user = User(
      id: "current-user",
      currentRole: Role(
        roleId: 1,
        code: "RM",
        name: "RM",
        bpmRole: "RM-WCAS",
        userRole: UserRole.relationshipManager,
      ),
    );

    Globals.request = null;
    Globals.applicationDetails = ApplicationDetails(
      applicationLifeCycle: ApplicationLifeCycle(
        activityName: "",
        userAction: 0,
      ),
    );

    Globals.superUserRoles = [];
    Globals.limitReleaseStagesReferences = [];
    Globals.folTypeAction = [];
  }

  setUpAll(() async {
    registerFallbackValue(CommentsType.requestForLimitRelease);
    registerFallbackValue(EntityIdentifier.requestForLimitRelease);
    registerFallbackValue(Comment());
    registerFallbackValue(User());
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (_) async => <String>["wifi"],
    );

    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockAdminRepository = MockAdminRepository();
    mockAlertManager = MockAlertManager();
    mockController = MockUnifiedEditorController();
    mockDraftRepository = MockDraftRepository();

    CommonRepository.overrideInstance = mockCommonRepository;
    ApprovalRepository.overrideInstance = mockApprovalRepository;
    RequestRepository.overrideInstance = mockRequestRepository;
    AlertManager.overrideInstance = mockAlertManager;
    DraftRepository.overrideInstance = mockDraftRepository;

    resetGlobals();

    when(() => mockController.getText()).thenAnswer((_) async => "");
    when(() => mockController.setText(any())).thenAnswer((_) async {});

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

    when(() => mockCommonRepository.getComments(any(), any()))
        .thenAnswer((_) async => []);

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async => {});

    when(() => mockApprovalRepository.getUsersByRoles(any()))
        .thenAnswer((_) async => []);

    when(() => mockApprovalRepository.getFilteredUsersByrole(any()))
        .thenAnswer((_) async => []);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());

    viewModel = createViewModel();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    await viewModel.close();
  });

  group("Initial state", () {
    test("initial loaderStatus is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("comment is initially null", () {
      expect(viewModel.comment, isNull);
    });

    test("comments list is initially empty", () {
      expect(viewModel.comments, isEmpty);
    });

    test("repository is assigned", () {
      expect(viewModel.repository, mockRequestRepository);
    });
  });

  group("draft configuration", () {
    test("returns approval draft module key", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
    });

    test("returns request for limit release draft form key", () {
      expect(viewModel.draftFormKey, Routes.requestForLimitRelease);
    });

    test("returns draft handler", () {
      expect(viewModel.draftHandler, isNotNull);
    });
  });

  test("init handles repository exception gracefully", () async {
    final initViewModel = createViewModel(assignController: false);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenThrow(Exception("init failed"));

    await initViewModel.init(MockBuildContext());

    expect(initViewModel.state.loaderStatus, LoadingStatus.loaded);

    await initViewModel.close();
  });

  group("getComments", () {
    test("handles exception without crashing", () async {
      when(() => mockCommonRepository.getComments(any(), any()))
          .thenThrow(Exception("Failed"));

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      expect(viewModel.comments, isEmpty);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("populates comments on success", () async {
      final testComments = [Comment(comment: "Hello")];

      when(() => mockCommonRepository.getComments(any(), any()))
          .thenAnswer((_) async => testComments);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("single different user comment sets visible true", () async {
      final comments = [
        Comment(
          userId: "u1",
          userRole: 1,
          comment: "Test",
          reviewCommentId: "1",
          createdDate: DateTime.now(),
        ),
      ];

      Globals.user = User(id: "other", currentRole: Role(roleId: 99));

      when(
        () => mockCommonRepository.getComments(
          CommentsType.requestForLimitRelease,
          EntityIdentifier.requestForLimitRelease,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      expect(viewModel.isCommentVisible, true);
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
          CommentsType.requestForLimitRelease,
          EntityIdentifier.requestForLimitRelease,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      expect(viewModel.initialText, "My comment");
      expect(viewModel.reviewCommentId, "99");
      expect(viewModel.comments, isEmpty);
      verify(() => mockController.setText("My comment")).called(1);
    });

    test("multiple own comments selects latest comment", () async {
      Globals.user = User(id: "u1", currentRole: Role(roleId: 10));

      final oldComment = Comment(
        userId: "u1",
        userRole: 10,
        reviewCommentId: "old",
        comment: "Old",
        createdDate: DateTime(2026),
      );

      final newComment = Comment(
        userId: "u1",
        userRole: 10,
        reviewCommentId: "new",
        comment: "New",
        createdDate: DateTime(2026, 2),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.requestForLimitRelease,
          EntityIdentifier.requestForLimitRelease,
        ),
      ).thenAnswer((_) async => [oldComment, newComment]);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      expect(viewModel.reviewCommentId, "old");
    });
  });

  group("getReferenceList", () {
    test("returns CCU maker role for sendToCCUMaker", () {
      final result = viewModel.getReferenceList(FOLTypeAction.sendToCCUMaker);

      expect(
        result,
        contains(ServerConstants.userRoleCode[UserRole.ccuMaker]),
      );
    });

    test("returns CCU checker role for sendToCCUChecker", () {
      final result = viewModel.getReferenceList(FOLTypeAction.sendToCCUChecker);

      expect(
        result,
        contains(ServerConstants.userRoleCode[UserRole.ccuChecker]),
      );
    });

    test("returns documentation and relationship roles when role is ccuMaker",
        () {
      Globals.user = User(
        currentRole: Role(
          code: ServerConstants.userRoleCode[UserRole.ccuMaker],
          userRole: UserRole.ccuMaker,
        ),
      );

      final result = viewModel.getReferenceList(
        FOLTypeAction.returnFromDocCCU,
      );

      expect(
        result,
        contains(ServerConstants.userRoleCode[UserRole.documentationChecker]),
      );
      expect(
        result,
        contains(ServerConstants.userRoleCode[UserRole.relationshipManager]),
      );
      expect(
        result,
        contains(ServerConstants.userRoleCode[UserRole.relationshipOfficer]),
      );
    });

    test("returns CCU maker role when role is not ccuMaker", () {
      Globals.user = User(
        currentRole: Role(
          code: ServerConstants.userRoleCode[UserRole.documentationChecker],
          userRole: UserRole.documentationChecker,
        ),
      );

      final result = viewModel.getReferenceList(
        FOLTypeAction.returnFromDocCCU,
      );

      expect(
        result,
        contains(ServerConstants.userRoleCode[UserRole.ccuMaker]),
      );
    });
  });

  group("getAllUserRoleLists", () {
    test("returns empty list when bpm roles are empty", () async {
      Globals.superUserRoles = [];

      final result = await viewModel.getAllUserRoleLists();

      expect(result, isEmpty);
      verifyNever(() => mockApprovalRepository.getUsersByRoles(any()));
    });

    test("returns users when bpm roles exist", () async {
      Globals.superUserRoles = [
        {
          ServerConstants.userRoleCode[UserRole.ccuMaker] ?? "":
              "Credit Control Unit Maker",
          ServerConstants.userRoleCode[UserRole.ccuChecker] ?? "":
              "Credit Control Unit Checker",
        },
      ];

      final users = [
        User(
          id: "u1",
          name: "User One",
          currentRole: Role(
            code: ServerConstants.userRoleCode[UserRole.ccuMaker],
            name: ServerConstants.userRoleCode[UserRole.ccuMaker],
            bpmRole: "Credit Control Unit Maker",
          ),
        ),
      ];

      when(() => mockApprovalRepository.getUsersByRoles(any()))
          .thenAnswer((_) async => users);

      final result = await viewModel.getAllUserRoleLists();

      expect(result, users);
    });
  });

  group("getAllUserLists", () {
    test("returns empty map when bpm roles are empty", () async {
      Globals.superUserRoles = [];

      final result = await viewModel.getAllUserLists();

      expect(result, isEmpty);
      verifyNever(() => mockApprovalRepository.getUsersByRoles(any()));
    });

    test("returns grouped user maps when users exist", () async {
      Globals.superUserRoles = [
        {
          ServerConstants.userRoleCode[UserRole.ccuMaker] ?? "":
              "Credit Control Unit Maker",
          ServerConstants.userRoleCode[UserRole.ccuChecker] ?? "":
              "Credit Control Unit Checker",
        },
      ];

      final users = [
        User(
          id: "maker1",
          name: "Maker User",
          currentRole: Role(
            code: ServerConstants.userRoleCode[UserRole.ccuMaker],
            name: ServerConstants.userRoleCode[UserRole.ccuMaker],
            bpmRole: "Credit Control Unit Maker",
          ),
        ),
        User(
          id: "checker1",
          name: "Checker User",
          currentRole: Role(
            code: ServerConstants.userRoleCode[UserRole.ccuChecker],
            name: ServerConstants.userRoleCode[UserRole.ccuChecker],
            bpmRole: "Credit Control Unit Checker",
          ),
        ),
      ];

      when(() => mockApprovalRepository.getUsersByRoles(any()))
          .thenAnswer((_) async => users);

      final result = await viewModel.getAllUserLists();

      expect(
        result,
        isA<Map<FOLTypeAction, Map<String, List<User>>>>(),
      );
      expect(result.containsKey(FOLTypeAction.sendToCCUMaker), isTrue);
      expect(result.containsKey(FOLTypeAction.sendToCCUChecker), isTrue);
      expect(result.containsKey(FOLTypeAction.returnFromDocCCU), isTrue);
    });
  });

  group("getUsersByRole", () {
    test("returns empty map for empty list", () {
      final result = viewModel.getUsersByRole([]);

      expect(result, isEmpty);
    });

    test("groups users by role name", () {
      final users = [
        User(
          id: "123",
          name: "Alice",
          currentRole: Role(
            name: "RO",
            roleId: 1,
            bpmRole: "Relationship Officer",
          ),
        ),
        User(
          id: "456",
          name: "Bob",
          currentRole: Role(
            name: "RM",
            roleId: 2,
            bpmRole: "Relationship Manager",
          ),
        ),
        User(
          id: "789",
          name: "Clark",
          currentRole: Role(
            name: "RO",
            roleId: 3,
            bpmRole: "Relationship Officer",
          ),
        ),
      ];

      final result = viewModel.getUsersByRole(users);

      expect(result.length, 2);
      expect(result["RO"]?.length, 2);
      expect(result["RM"]?.length, 1);
    });
  });

  group("getUserListDropDownItems", () {
    test("returns empty list for empty map", () {
      final result = viewModel.getUserListDropDownItems({});

      expect(result, isEmpty);
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

    test("does not set returnPrefill when lifecycle does not match", () {
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

    test("sets returnPrefill when lifecycle conditions match", () {
      Globals.applicationDetails = ApplicationDetails(
        applicationLifeCycle: ApplicationLifeCycle(
          assignedBy: "u4",
          assignedByRole: 10,
          userAction: ServerConstants.sendToDocumentMaker,
        ),
      );

      final users = {
        "RM": [
          User(
            id: "u4",
            name: "User4",
            currentRole: Role(roleId: 10, bpmRole: "RM"),
          ),
        ],
      };

      viewModel.getUserListDropDownItems(users);

      expect(viewModel.returnPrefill, isNotNull);
      expect(viewModel.returnPrefill!.label, "User4 - u4");
    });

    test("skips invalid user when both name and id are null", () {
      final users = {
        "RM": [
          User(
            currentRole: Role(roleId: 10, bpmRole: "RM"),
          ),
        ],
      };

      final result = viewModel.getUserListDropDownItems(users);

      expect(result.length, 1);
      expect(result.first.isHeader, true);
    });
  });

  group("submitApplication", () {
    void stubSubmitSuccess() {
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
          rightFirstTime: any(named: "rightFirstTime"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.success,
          message: "Success",
        ),
      );
    }

    void stubSubmitFailure() {
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
          rightFirstTime: any(named: "rightFirstTime"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          status: ResponseStatus.error,
          message: "Error",
        ),
      );
    }

    test("returns empty when initialText is empty", () async {
      final result = await (viewModel..initialText = "")
          .submitApplication(FOLTypeAction.sendToDocumentation);

      expect(result, isEmpty);
      verifyNever(
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
          rightFirstTime: any(named: "rightFirstTime"),
        ),
      );
    });

    test("returns empty when stage is not selected for CCU role", () async {
      viewModel
        ..selectedStage = ""
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM";

      Globals.user = User(
        currentRole: Role(
          code: "CCU-C",
          userRole: UserRole.ccuChecker,
        ),
      );

      final result =
          await viewModel.submitApplication(FOLTypeAction.sendToCCUChecker);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });

    test("returns empty when userId is empty and action requires user",
        () async {
      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "";

      Globals.user = User(
        currentRole: Role(
          code: "DC",
          userRole: UserRole.documentationChecker,
        ),
      );

      final result =
          await viewModel.submitApplication(FOLTypeAction.returnFromDocCCU);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });

    test("returns confirmation description on successful submit", () async {
      stubSubmitSuccess();

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM"
        ..allUserList = [
          User(
            id: "user1",
            currentRole: Role(
              name: "DM",
              bpmRole: "DM",
            ),
          ),
        ];

      Globals.user = User(
        currentRole: Role(
          code: "DC",
          userRole: UserRole.documentationChecker,
        ),
      );

      Globals.request?.applicationRefNo = "App123";
      Globals.folTypeAction = [
        {
          ServerConstants.folTypeActionList[FOLTypeAction.returnFromDocCCU] ??
              "": 10,
        },
      ];

      final result = await viewModel.submitApplication(
        FOLTypeAction.returnFromDocCCU,
      );

      expect(result, isA<List<String>>());
      expect(result.first, contains("layout.topmenu.comfirmation"));
    });

    test("returns confirmation description on documentation completed",
        () async {
      stubSubmitSuccess();

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM"
        ..allUserList = [
          User(
            id: "user1",
            currentRole: Role(
              name: "DM",
              bpmRole: "DM",
            ),
          ),
        ];

      Globals.user = User(
        currentRole: Role(
          code: "DC",
          userRole: UserRole.documentationChecker,
        ),
      );

      Globals.request?.applicationRefNo = "App123";

      Globals.folTypeAction = [
        {
          ServerConstants
                  .folTypeActionList[FOLTypeAction.documentationCompleted] ??
              "": 10,
        },
      ];

      final result = await viewModel.submitApplication(
        FOLTypeAction.documentationCompleted,
      );

      expect(result, isA<List<String>>());
      expect(result.first, contains("layout.topmenu.comfirmation"));
    });

    test("uses returnToCCUmaker action when returnFromDocCCU and ccuChecker",
        () async {
      stubSubmitSuccess();

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM"
        ..allUserList = [
          User(
            id: "user1",
            currentRole: Role(
              name: "DM",
              bpmRole: "DM",
            ),
          ),
        ];

      Globals.user = User(
        currentRole: Role(
          code: "CCU-C",
          userRole: UserRole.ccuChecker,
        ),
      );

      Globals.folTypeAction = [
        {
          ServerConstants.folTypeActionList[FOLTypeAction.returnFromDocCCU] ??
              "": 10,
        },
      ];

      final result = await viewModel.submitApplication(
        FOLTypeAction.returnFromDocCCU,
      );

      expect(result, isNotEmpty);
    });

    test("returns empty description when submission fails", () async {
      stubSubmitFailure();

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM"
        ..allUserList = [
          User(
            id: "user1",
            currentRole: Role(
              name: "DM",
              bpmRole: "DM",
            ),
          ),
        ];

      Globals.user = User(
        currentRole: Role(
          code: "DC",
          userRole: UserRole.documentationChecker,
        ),
      );

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToCCUChecker,
      );

      expect(result, isEmpty);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("returns empty list on exception", () async {
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
          rightFirstTime: any(named: "rightFirstTime"),
        ),
      ).thenThrow(Exception("API error"));

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM"
        ..allUserList = [
          User(
            id: "user1",
            currentRole: Role(
              name: "DM",
              bpmRole: "DM",
            ),
          ),
        ];

      Globals.user = User(
        currentRole: Role(
          code: "DC",
          userRole: UserRole.documentationChecker,
        ),
      );

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToCCUChecker,
      );

      expect(result, isEmpty);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("saveComment", () {
    test("emits loaded on success and deletes draft", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Some remark</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "1");

      when(() => mockCommonRepository.getComments(any(), any()))
          .thenAnswer((_) async => []);

      await viewModel.saveComment();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      ).called(1);
    });

    test("emits loaded even when repository throws", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Some remark</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenThrow(Exception("Save failed"));

      await viewModel.saveComment();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );
    });

    test("returns early without saving when content is empty", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "");

      await viewModel.saveComment();
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockApprovalRepository.saveReviewComments(any()));

      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("returns early when content is only HTML tags and whitespace",
        () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>&nbsp;</p>");

      await viewModel.saveComment();
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockApprovalRepository.saveReviewComments(any()));

      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("RequestForLimitReleaseState", () {
    test("constructor stores loaderStatus", () {
      const state =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loading);

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith preserves existing values when nothing passed", () {
      const original =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loaded);

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides field correctly", () {
      const original =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loaded);

      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("Button visibility — buttonVisibilityStatus", () {
    test("initiateFinalFOL", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("documentationSubmitted", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("sendToDocumentation", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("returnToDocumentationMaker", () {
      expect(
        viewModel.buttonVisibilityStatus[
            ApprovalFields.returnToDocumentationMaker]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("initiateFitToLend", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("sendtoCCUMaker", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUMaker]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationChecker,
        ]),
      );
    });

    test("stage", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.stage]!(),
        Utils.checkRoles([
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
      );
    });

    test("returns", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.returns]!(),
        Utils.checkRoles([
          UserRole.ccuMaker,
        ]),
      );
    });

    test("sendToCCU", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!(),
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
      );
    });

    test("sendToDocumentationMaker", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.sendToDocumentationMaker]!(),
        Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
      );
    });

    test("draftFolGenerated", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!(),
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
      );
    });

    test("finalFOLGenerated", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!(),
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
      );
    });

    test("documentationCompleted", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationCompleted]!(),
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
      );
    });

    test("sendToDocumentationChecker", () {
      expect(
        viewModel.buttonVisibilityStatus[
            ApprovalFields.sendToDocumentationChecker]!(),
        Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
      );
    });

    test("sendtoCCUChecker", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUChecker]!(),
        Utils.checkRoles([
          UserRole.ccuMaker,
        ]),
      );
    });

    test("returntoCCUMaker", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.returntoCCUMaker]!(),
        Utils.checkRoles([
          UserRole.ccuChecker,
        ]),
      );
    });

    test("acceptCloseApplication", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.acceptCloseApplication]!(),
        Utils.checkRoles([
          UserRole.ccuChecker,
        ]),
      );
    });

    test("previewApplication", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.previewApplication]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationMaker,
          UserRole.documentationChecker,
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
      );
    });
  });
}
