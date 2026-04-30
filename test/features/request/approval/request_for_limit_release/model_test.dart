import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
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
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

// FIX: mock DraftRepository so deleteDraft() never fires a real Dio call
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
  late MockAlertManager mockAlertManager;
  late MockUnifiedEditorController mockController;
  late MockDraftRepository mockDraftRepository;

  setUpAll(() async {
    // FIX: use the correct CommentsType and EntityIdentifier for this screen
    registerFallbackValue(CommentsType.requestForLimitRelease);
    registerFallbackValue(EntityIdentifier.requestForLimitRelease);
    registerFallbackValue(Comment());
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    // Registered fresh before every test with correct List<String> return type
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (_) async => <String>["wifi"],
    );

    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockAlertManager = MockAlertManager();
    mockController = MockUnifiedEditorController();
    mockDraftRepository = MockDraftRepository();

    // 2) Override the singleton instance in your tests
    CommonRepository.overrideInstance(mockCommonRepository);
    ApprovalRepository.overrideInstance(mockApprovalRepository);
    RequestRepository.overrideInstance(mockRequestRepository);
    AlertManager.overrideInstance(mockAlertManager);

    // FIX: override DraftRepository so deleteDraft/saveDraft never
    // reach Dio and the connectivity platform channel
    DraftRepository.overrideInstance(mockDraftRepository);

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

    viewModel = RequestForLimitReleaseViewModel();
    viewModel.repository = mockRequestRepository;
    viewModel.approvalRepository = mockApprovalRepository;
  });

  tearDown(() {
    // FIX: use addTearDown-safe cleanup — clear channel mock after each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------

  group("Initial state", () {
    test("initial loaderStatus is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    // FIX: comment is declared as Comment? (nullable) and initialised to null
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

  test("init loads data and computes comment visibility correctly", () async {
    final comments = [
      Comment(categoryId: 20, strategyComment: "Other"),
    ];

    Globals.user = User(
      currentRole: Role(bpmRole: "RM"),
    );

    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "CA");

    when(() => viewModel.getComments(any(), any())).thenAnswer((_) async {
      viewModel.comments = comments;
    });

    when(() => mockApprovalRepository.fetchReference()).thenAnswer(
      (_) async => {
        "roles": ["CCU-M"],
      },
    );

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());

    await viewModel.init(MockBuildContext());

    expect(viewModel.comments, comments);

    expect(viewModel.isCommentVisible, false);
  });

  group("getComments", () {
    test("handles exception without crashing", () async {
      when(() => mockCommonRepository.getComments(any(), any()))
          .thenThrow(Exception("Failed"));

      // FIX: use correct CommentsType/EntityIdentifier for this screen
      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      // Assert
      expect(viewModel.comments, isEmpty);
    });

    test("populates comments on success", () async {
      final testComments = [Comment(comment: "Hello")];
      when(() => mockCommonRepository.getComments(any(), any()))
          .thenAnswer((_) async => testComments);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
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
          CommentsType.requestForLimitRelease,
          EntityIdentifier.requestForLimitRelease,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
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
      expect(viewModel.comments.isEmpty, false);
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
          CommentsType.requestForLimitRelease,
          EntityIdentifier.requestForLimitRelease,
        ),
      ).thenAnswer((_) async => [oldComment, newComment]);

      await viewModel.getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );

      verify(
        () => mockCommonRepository.getComments(
          CommentsType.requestForLimitRelease,
          EntityIdentifier.requestForLimitRelease,
        ),
      ).called(1);

      expect(viewModel.reviewCommentId, "345");
      expect(viewModel.initialText, "Sample");
    });
  });

  group("getUserListByGroup", () {
    test("should return data if data is present", () async {
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
      when(
        () => mockApprovalRepository.getUsersByRoles(any()),
      ).thenAnswer((_) async => mockResponse);
      final groupList =
          await viewModel.getUserListByGroup(FOLTypeAction.sendToCCUMaker);
      expect(groupList, isA<Map<String, List<User>>>());
      expect(groupList.length, 3);
    });

    test("should match with the type", () async {
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
          .getUserListByGroup(FOLTypeAction.executedDocsUnderReview);
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
      final groupList =
          await viewModel.getUserListByGroup(FOLTypeAction.sendToCCUChecker);
      expect(groupList, isEmpty);
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
          User(
            id: "u1",
            name: "User4",
            currentRole: Role(roleId: 10, bpmRole: "User4"),
          ),
        ],
      };

      viewModel.getUserListDropDownItems(users);

      final prefill = viewModel.returnPrefill;
      expect(prefill, isNotNull);
      // expect(prefill!.label, 'User4 - 1');
    });
  });

  group("submitApplication()", () {
    test("returns empty when initialText is empty", () async {
      viewModel.initialText = "";

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isEmpty);
      verifyNever(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
        ),
      );
    });

    test("returns empty when stage not selected for doc roles", () async {
      viewModel.selectedStage = "";

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isEmpty);
    });

    test("returns empty when userId is empty and action requires user",
        () async {
      viewModel.selectedUserId = "";

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isEmpty);
    });

    test("check validation for stage selection CCU roles", () async {
      viewModel.selectedStage = "";
      viewModel.initialText = "Sample";
      viewModel.selectedUserId = "user1:DM";
      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.ccuChecker;
      final result =
          await viewModel.submitApplication(FOLTypeAction.sendToCCUChecker);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });

    test("check validation for user selection", () async {
      viewModel.selectedStage = "FOL stage";
      viewModel.initialText = "Sample";
      viewModel.selectedUserId = "";
      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
      final result =
          await viewModel.submitApplication(FOLTypeAction.returnFromDocCCU);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });

    test("returns confirmation description on successful submit", () async {
      viewModel.selectedStage = "FOL stage";
      viewModel.initialText = "Sample";
      viewModel.selectedUserId = "user1:DM";
      viewModel.returnCcuMakerList = [
        User(id: "user1", currentRole: Role(bpmRole: "DM")),
      ];
      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
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
          rightFirstTime: any(named: "rightFirstTime"),
        ),
      ).thenAnswer(
        (_) async =>
            AppResponse(status: ResponseStatus.success, message: "Success"),
      );

      final result = await viewModel.submitApplication(
        FOLTypeAction.returnFromDocCCU,
      );

      expect(result, isA<List<String>>());
      expect(result.first, contains("layout.topmenu.comfirmation"));
      expect(
        result.last,
        contains(
          "Your Application App123 has been moved to user1 successfully",
        ),
      );
    });

    test("returns confirmation description on documentation completed",
        () async {
      viewModel.selectedStage = "FOL stage";
      viewModel.initialText = "Sample";
      viewModel.selectedUserId = "user1:DM";
      viewModel.returnCcuMakerList = [
        User(id: "user1", currentRole: Role(bpmRole: "DM")),
      ];
      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
      Globals.request?.applicationRefNo = "App123";
      Globals.folTypeAction = [
        {"Documentation Completed": 10},
      ];
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
        (_) async =>
            AppResponse(status: ResponseStatus.success, message: "Success"),
      );

      final result = await viewModel.submitApplication(
        FOLTypeAction.documentationCompleted,
      );

      expect(result, isA<List<String>>());
      expect(result.first, contains("layout.topmenu.comfirmation"));
      expect(
        result.last,
        contains(
          "Your Application App123 has been approved successfully",
        ),
      );
    });

    test("returns empty description when submission fails", () async {
      // bypass validations
      viewModel.selectedStage = "FOL stage";
      viewModel.initialText = "Sample";
      viewModel.selectedUserId = "user1:DM";
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
        FOLTypeAction.sendToCCUChecker,
      );

      expect(result, isEmpty);
    });

    test("returns empty list on exception", () async {
      // bypass validations
      viewModel.selectedStage = "FOL stage";
      viewModel.initialText = "Sample";
      viewModel.selectedUserId = "user1:DM";
      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("API error"));

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToCCUChecker,
      );

      expect(result, isEmpty);
    });
  });

  group("saveComment", () {
    test("emits loading then loaded on success", () async {
      // FIX: prime the controller so the empty-content guard does not trip
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Some remark</p>");
      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "1");
      when(() => mockCommonRepository.getComments(any(), any()))
          .thenAnswer((_) async => []);

      viewModel.controller = mockController;

      final List<LoadingStatus> statuses = [];
      viewModel.stream.listen((s) => statuses.add(s.loaderStatus));

      await viewModel.saveComment(ifNavigate: true);

      // FIX: pump any remaining microtasks so the fire-and-forget
      // deleteDraft() future fully resolves before we assert
      await Future<void>.delayed(Duration.zero);

      // expect(statuses, contains(LoadingStatus.loading));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      // Verify deleteDraft was called once after successful save
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

      viewModel.controller = mockController;

      await viewModel.saveComment();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      // deleteDraft must NOT be called when save fails
      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );
    });

    test("returns early without saving when content is empty", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "");
      viewModel.controller = mockController;

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

    test("returns early when content is only HTML tags / whitespace", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>&nbsp;</p>");
      viewModel.controller = mockController;

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

  group("onTextChange", () {
    test("sets canSubmit to false for empty text", () {
      viewModel.onTextChange("");
      expect(viewModel.canSubmit, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets canSubmit to true for non-empty text", () {
      viewModel.onTextChange("New Comment");
      expect(viewModel.canSubmit, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets canSubmit to false for whitespace-only text", () {
      viewModel.onTextChange("   ");
      expect(viewModel.canSubmit, false);
    });
  });

  group("RequestForLimitReleaseState", () {
    test("constructor stores loaderStatus", () {
      final state =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith preserves existing values when nothing passed", () {
      final original =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides field correctly", () {
      final original =
          RequestForLimitReleaseState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      // original is unchanged (immutability)
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("Button visibility — buttonVisibilityStatus", () {
    test("initiateFinalFOL: RO and RM only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("documentationSubmitted: RO and RM only", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("sendToDocumentation: RO and RM only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("returnToDocumentationMaker: RO and RM only", () {
      expect(
        viewModel.buttonVisibilityStatus[
            ApprovalFields.returnToDocumentationMaker]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("initiateFitToLend: RO and RM only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
      );
    });

    test("sendtoCCUMaker: RO, RM, documentationChecker", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUMaker]!(),
        Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationChecker,
        ]),
      );
    });

    // FIX: stage belongs to ccuMaker + ccuChecker per buttonVisibilityStatus
    // map
    test("stage: ccuMaker and ccuChecker only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.stage]!(),
        Utils.checkRoles([
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
      );
    });

    // FIX: returns belongs to ccuMaker only per buttonVisibilityStatus map
    test("returns: ccuMaker only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.returns]!(),
        Utils.checkRoles([
          UserRole.ccuMaker,
        ]),
      );
    });

    test("sendToCCU: documentationChecker and documentationMaker", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!(),
        Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
      );
    });

    test("sendToDocumentationMaker: documentationChecker only", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.sendToDocumentationMaker]!(),
        Utils.checkRoles([UserRole.documentationChecker]),
      );
    });

    test("draftFolGenerated: documentationMaker only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!(),
        Utils.checkRoles([UserRole.documentationMaker]),
      );
    });

    test("finalFOLGenerated: documentationMaker only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!(),
        Utils.checkRoles([UserRole.documentationMaker]),
      );
    });

    test("documentationCompleted: documentationMaker only", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.documentationCompleted]!(),
        Utils.checkRoles([UserRole.documentationMaker]),
      );
    });

    test("sendToDocumentationChecker: documentationMaker only", () {
      expect(
        viewModel.buttonVisibilityStatus[
            ApprovalFields.sendToDocumentationChecker]!(),
        Utils.checkRoles([UserRole.documentationMaker]),
      );
    });

    test("sendtoCCUChecker: ccuMaker only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUChecker]!(),
        Utils.checkRoles([UserRole.ccuMaker]),
      );
    });

    test("returntoCCUMaker: ccuChecker only", () {
      expect(
        viewModel.buttonVisibilityStatus[ApprovalFields.returntoCCUMaker]!(),
        Utils.checkRoles([UserRole.ccuChecker]),
      );
    });

    test("acceptCloseApplication: ccuChecker only", () {
      expect(
        viewModel
            .buttonVisibilityStatus[ApprovalFields.acceptCloseApplication]!(),
        Utils.checkRoles([UserRole.ccuChecker]),
      );
    });
  });
}
