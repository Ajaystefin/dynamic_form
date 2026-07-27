import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";
import "../comments/model_test.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class FakeComment extends Fake implements Comment {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

// Mock LocalStorageService
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

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(FakeComment());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <dynamic>[];
        }
        return null;
      },
    );
  });

  // tearDownAll(() {
  //   connectivityChannel.setMockMethodCallHandler(null);
  // });

  late RequestForFolViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlert;
  late MockController mockController;
  late MockLocalStorageService mockLocalStorageService;
  late MockApprovalRepository mockApprovalRepo;

  setUp(() async {
    Globals.user = User(
      id: "u1",
      name: "Test User",
      currentRole: Role(id: 1, code: "R1", bpmRole: "Role 1"),
    );
    mockAlert = MockAlertManager();
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockController = MockController();
    mockApprovalRepo = MockApprovalRepository();
    AlertManager.overrideInstance = mockAlert;
    CommonRepository.overrideInstance = mockCommonRepository;
    ApprovalRepository.overrideInstance = mockApprovalRepo;
    RequestRepository.overrideInstance = mockRequestRepository;

    viewModel = RequestForFolViewModel()
      ..requestRepository = mockRequestRepository
      ..controller = mockController
      ..commonRepository = mockCommonRepository
      ..repository = mockApprovalRepo;
    await EnvConfig.setEnvironment();

    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().getStorage = mockLocalStorageService;
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

  test("Check roles for initiateFinalFOL", () {
    expect(
      Utils.checkRoles([
        UserRole.relationshipOfficer,
        UserRole.relationshipManagerBussiness,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!(),
    );
  });

  test("Check roles for documentationSubmitted", () {
    expect(
      Utils.checkRoles([
        UserRole.relationshipOfficer,
        UserRole.relationshipManagerBussiness,
      ]),
      viewModel
          .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]!(),
    );
  });

  test("Check roles for sendToDocumentation", () {
    expect(
      Utils.checkRoles([
        UserRole.relationshipOfficer,
        UserRole.relationshipManagerBussiness,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!(),
    );
  });

  test("Check roles for returnToDocumentationMaker", () {
    expect(
      Utils.checkRoles([
        UserRole.relationshipOfficer,
        UserRole.relationshipManagerBussiness,
      ]),
      viewModel
          .buttonVisibilityStatus[ApprovalFields.returnToDocumentationMaker]!(),
    );
  });

  test("Check roles for initiateFitToLend", () {
    expect(
      Utils.checkRoles([
        UserRole.relationshipOfficer,
        UserRole.relationshipManagerBussiness,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!(),
    );
  });

  test("Check roles for stage", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationChecker,
        UserRole.documentationMaker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.stage]!(),
    );
  });

  test("Check roles for returns", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationChecker,
        UserRole.documentationMaker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.returns]!(),
    );
  });

  test("Check roles for sendToCCU", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationChecker,
        UserRole.documentationMaker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!(),
    );
  });

  test("Check roles for sendToDocumentationMaker", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationChecker,
      ]),
      viewModel
          .buttonVisibilityStatus[ApprovalFields.sendToDocumentationMaker]!(),
    );
  });

  test("Check roles for rightFirstTime", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationChecker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.rightFirstTime]!(),
    );
  });

  test("Check roles for sendToRORM", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationMaker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.sendToRORM]!(),
    );
  });

  test("Check roles for draftFolGenerated", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationMaker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!(),
    );
  });

  test("Check roles for finalFOLGenerated", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationMaker,
      ]),
      viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!(),
    );
  });

  test("Check roles for documentationCompleted", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationMaker,
      ]),
      viewModel
          .buttonVisibilityStatus[ApprovalFields.documentationCompleted]!(),
    );
  });

  test("Check roles for sendToDocumentationChecker", () {
    expect(
      Utils.checkRoles([
        UserRole.documentationMaker,
      ]),
      viewModel
          .buttonVisibilityStatus[ApprovalFields.sendToDocumentationChecker]!(),
    );
  });

  test("init loads data and emits state", () async {
    Globals.applicationDetails = ApplicationDetails(
      applicationLifeCycle: ApplicationLifeCycle(
        assignedBy: "999",
        assignedByRole: 99,
        userAction: ServerConstants.sendToDocumentMaker,
      ),
    );

    when(() => mockApprovalRepo.getInitiatedRole())
        .thenAnswer((_) async => "CA");

    when(
      () => mockCommonRepository.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      ),
    ).thenAnswer((_) async => [Comment()]);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());

    when(() => mockApprovalRepo.fetchReference()).thenAnswer((_) async => {});

    Globals.user = User(
      id: "testUser123",
      currentRole: Role(code: "ADMIN"),
      segments: ["RM", "ADM"],
    );

    await viewModel.init(MockBuildContext());

    expect(viewModel.comments, isNotEmpty);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.repository, mockApprovalRepo);
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
    expect(viewModel.yesNo, isNotEmpty);
    expect(viewModel.reviewCommentId, "0");
  });

  group("getComments", () {
    test("should handle exception and leave comments empty", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.requestForFOL,
          EntityIdentifier.requestForFOL,
        ),
      ).thenThrow(Exception("Failed"));
      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );
      expect(viewModel.comments, isEmpty);
    });

    test("getComments should handle exception and show failure toast",
        () async {
      when(() => mockAlert.showFailureToast(any())).thenReturn(null);
      when(
        () => viewModel.getComments(
          CommentsType.requestForFOL,
          EntityIdentifier.requestForFOL,
        ),
      ).thenAnswer((_) async => "");

      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("getComments handles empty list", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.requestForFOL,
          EntityIdentifier.requestForFOL,
        ),
      ).thenAnswer((_) async => []);
      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );
      expect(viewModel.isCommentVisible, false);
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
          CommentsType.requestForFOL,
          EntityIdentifier.requestForFOL,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );

      expect(viewModel.isCommentVisible, true);
      // verifyNever(() => mockController.setText(any()));
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
          CommentsType.requestForFOL,
          EntityIdentifier.requestForFOL,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
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
          CommentsType.requestForFOL,
          EntityIdentifier.requestForFOL,
        ),
      ).thenAnswer((_) async => [comment]);

      await viewModel.getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );

      verify(() => mockController.setText("Test")).called(1);
      expect(viewModel.reviewCommentId, "123");
      expect(viewModel.initialText, "Test");
    });

    // test("sets text with latest comment from multiple", () async {
    //   Globals.user = User(id: "1", currentRole: Role(roleId: 10));

    //   final oldComment = Comment(
    //     userId: "1",
    //     userRole: 10,
    //     reviewCommentId: "123",
    //     comment: "Test",
    //     createdDate: DateTime(2026, 4),
    //   );

    //   final newComment = Comment(
    //     userId: "1",
    //     userRole: 10,
    //     reviewCommentId: "345",
    //     comment: "Sample",
    //     createdDate: DateTime(2026, 4, 10),
    //   );

    //   when(
    //     () => mockCommonRepository.getComments(
    //       CommentsType.requestForFOL,
    //       EntityIdentifier.requestForFOL,
    //     ),
    //   ).thenAnswer((_) async => [oldComment, newComment]);

    //   await viewModel.getComments(
    //     CommentsType.requestForFOL,
    //     EntityIdentifier.requestForFOL,
    //   );

    //   verify(
    //     () => mockCommonRepository.getComments(
    //       CommentsType.requestForFOL,
    //       EntityIdentifier.requestForFOL,
    //     ),
    //   ).called(1);

    //   verify(() => mockController.setText("Sample")).called(1);
    //   expect(viewModel.reviewCommentId, "345");
    //   expect(viewModel.initialText, "Sample");
    // });
  });

  // test("multiple comments picks latest by createdDate", () async {
  //   final oldComment = Comment(
  //     userId: "u2",
  //     userRole: 1,
  //     comment: "Old",
  //     reviewCommentId: "1",
  //     createdDate: DateTime.now().subtract(const Duration(days: 1)),
  //   );

  //   final latestComment = Comment(
  //     userId: "u1",
  //     userRole: 1,
  //     comment: "Latest",
  //     reviewCommentId: "2",
  //     createdDate: DateTime.now(),
  //   );

  //   when(
  //     () => mockCommonRepository.getComments(
  //       CommentsType.requestForFOL,
  //       EntityIdentifier.requestForFOL,
  //     ),
  //   ).thenAnswer((_) async => [oldComment, latestComment]);

  //   await viewModel.getComments(
  //     CommentsType.requestForFOL,
  //     EntityIdentifier.requestForFOL,
  //   );

  //   expect(viewModel.isCommentVisible, true);
  //   expect(viewModel.comment?.comment, isNotNull);
  // });

  test("onSavePress emits loaded when exception occurs", () async {
    when(() => mockController.getText())
        .thenAnswer((_) async => "<p>Crash</p>");

    when(() => mockApprovalRepo.saveReviewComments(any()))
        .thenThrow(Exception("Save failed"));

    await viewModel.onSavePress();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  group("getUserListDropDownItems", () {
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
          userAction: ServerConstants.sendToDocumentMaker,
        ),
      );

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

  group("submitApplication()", () {
    test("returns empty when initialText is empty", () async {
      viewModel.initialText = "";
      when(() => mockController.getText()).thenAnswer((_) async => "");
      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isEmpty);
      verifyNever(
        () => mockApprovalRepo.submitApplication(
          any(),
          any(),
          any(),
        ),
      );
    });

    test("returns empty when stage not selected for doc roles", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");
      final result = await (viewModel..selectedStage = "")
          .submitApplication(FOLTypeAction.sendToDocumentation);

      expect(result, isEmpty);
    });

    test("check validation for RFT option for DC role", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..isOptionsVisible = true
        ..selectedUserId = "user1:DM";
      // ..sendDocumentList = [
      //   User(
      //     id: "user1",
      //     currentRole: Role(roleId: 10, bpmRole: "DM"),
      //   ),
      // ];

      Globals.user?.currentRole?.code = "DC";

      await viewModel.submitApplication(FOLTypeAction.sendToDocumentation);
      verify(() => mockAlert.showFailureToast(any())).called(1);

      await (viewModel..selectedOpt = "No")
          .submitApplication(FOLTypeAction.sendToDocumentation);
      verify(() => mockAlert.showFailureToast(any())).called(1);

      viewModel
        ..additionalComment = "Sample"
        ..selectedOpt = "No";
      when(
        () => mockApprovalRepo.saveReviewComments(any()),
      ).thenAnswer((_) async => "Success");
      when(
        () => mockApprovalRepo.submitApplication(
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
      await viewModel.submitApplication(FOLTypeAction.initiateFinalFOL);
      verifyNever(() => mockAlert.showFailureToast(any()));

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isNotEmpty);
      expect(result.length, 2);
    });

    test("returns empty when userId is empty and action requires user",
        () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      final result = await (viewModel..selectedUserId = "")
          .submitApplication(FOLTypeAction.sendToDocumentation);

      expect(result, isEmpty);
    });

    test("check validation for stage selection documentation role", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      viewModel
        ..selectedStage = ""
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM";

      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
      final result =
          await viewModel.submitApplication(FOLTypeAction.initiateFinalFOL);
      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });

    test("check validation for user selection", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "";

      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
      final result =
          await viewModel.submitApplication(FOLTypeAction.initiateFitToLend);
      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });

    test("returns empty description when submission fails", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      // bypass validations
      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM";
      when(
        () => mockApprovalRepo.submitApplication(
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
            AppResponse(status: ResponseStatus.error, message: "Error"),
      );

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isEmpty);
    });

    test("returns empty list on exception", () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      // bypass validations
      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM";
      when(
        () => mockApprovalRepo.submitApplication(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("API error"));

      final result = await viewModel.submitApplication(
        FOLTypeAction.sendToDocumentation,
      );

      expect(result, isEmpty);
    });

    test("returns confirmation description on documentation completed",
        () async {
      when(() => mockController.getText()).thenAnswer((_) async => "Sample");

      viewModel
        ..selectedStage = "FOL stage"
        ..initialText = "Sample"
        ..selectedUserId = "user1:DM";
      Globals.user?.currentRole?.code = "DC";
      Globals.user?.currentRole?.userRole = UserRole.documentationChecker;
      Globals.request?.applicationRefNo = "App123";
      Globals.folTypeAction = [
        {"Documentation Completed": 10},
      ];
      when(
        () => mockApprovalRepo.submitApplication(
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
          "Your Application App123 has been moved to CCU successfully",
        ),
      );
    });
  });

  group("RequestForFolState", () {
    test("constructor sets loaderStatus", () {
      final state = RequestForFolState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = RequestForFolState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = RequestForFolState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onOptChanged", () {
    test("should set correct values for the field", () async {
      viewModel.onOptChanged("Yes");
      expect(viewModel.showAdditionalComment, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onOptChanged("No");
      expect(viewModel.showAdditionalComment, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("checkCurrentStatus", () {
    test("return correct values for the currect state", () async {
      final status1 = (viewModel..activityName = "Send to CCU Checker")
          .checkCurrentStatus([FOLTypeAction.draftFolGenerated]);
      expect(status1, false);

      final status2 = (viewModel..onOptChanged("No"))
          .checkCurrentStatus([FOLTypeAction.sendToCCUChecker]);
      expect(status2, true);
    });

    test("return correct values from the list of states", () async {
      final status1 =
          (viewModel..activityName = "Send to CCU Checker").checkCurrentStatus([
        FOLTypeAction.draftFolGenerated,
        FOLTypeAction.sendToDocumentationChecker,
        FOLTypeAction.documentationCompleted,
      ]);
      expect(status1, false);

      viewModel.onOptChanged("No");
      final status2 = viewModel.checkCurrentStatus([
        FOLTypeAction.sendToCCUChecker,
        FOLTypeAction.executedDocsUnderReview,
        FOLTypeAction.initiateFinalFOL,
      ]);
      expect(status2, true);
    });

    test("return false for the empty set", () async {
      final status = (viewModel..activityName = "Send to CCU Checker")
          .checkCurrentStatus([]);
      expect(status, false);
    });
  });
}
