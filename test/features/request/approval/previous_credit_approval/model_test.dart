import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/model.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

class TestablePreviousCreditApprovalViewModel
    extends PreviousCreditApprovalViewModel {
  TestablePreviousCreditApprovalViewModel({
    required ApprovalRepository mockApprovalRepository,
    required RequestRepository mockRequestRepository,
    required AdminRepository mockAdminRepository,
  })  : _mockApprovalRepository = mockApprovalRepository,
        _mockRequestRepository = mockRequestRepository,
        _mockAdminRepository = mockAdminRepository,
        super();

  final ApprovalRepository _mockApprovalRepository;
  final RequestRepository _mockRequestRepository;
  final AdminRepository _mockAdminRepository;

  @override
  ApprovalRepository get repository => _mockApprovalRepository;

  @override
  set repository(ApprovalRepository value) {}

  @override
  RequestRepository get requestRepository => _mockRequestRepository;

  @override
  set requestRepository(RequestRepository value) {}

  @override
  AdminRepository get adminRepository => _mockAdminRepository;

  @override
  set adminRepository(AdminRepository value) {}
}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage =
      <String, Map<String, dynamic>>{};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    _storage[box] ??= <String, dynamic>{};
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

  const MethodChannel connectivityPlusChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  const MethodChannel oldConnectivityChannel = MethodChannel(
    "plugins.flutter.io/connectivity",
  );

  late PreviousCreditApprovalViewModel viewModel;
  late MockApprovalRepository mockApprovalRepository;
  late MockRequestRepository mockRequestRepository;
  late MockAdminRepository mockAdminRepository;
  late MockAlertManager mockAlertManager;
  late BuildContext fakeContext;
  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(<Comment>[]);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityPlusChannel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == "check" ||
          methodCall.method == "checkConnectivity") {
        return <String>["wifi"];
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(oldConnectivityChannel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == "check" ||
          methodCall.method == "checkConnectivity") {
        return "wifi";
      }
      return null;
    });
  });

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockApprovalRepository = MockApprovalRepository();
    mockRequestRepository = MockRequestRepository();
    mockAdminRepository = MockAdminRepository();
    mockAlertManager = MockAlertManager();
    fakeContext = FakeBuildContext();
    mockLocalStorageService = MockLocalStorageService();

    AlertManager.instance = mockAlertManager;
    LocalStorageService().getStorage = mockLocalStorageService;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    when(
      () => mockApprovalRepository.getApplicationStrategyDetails(
        CommentsType.previousCreditApproval,
        EntityIdentifier.previousCreditApproval,
      ),
    ).thenAnswer((_) async => <Comment>[]);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => null);

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async => <dynamic>[]);

    when(
      () => mockApprovalRepository.saveApplicationStrategyDetails(
        any(),
        any<List<Comment>>(),
      ),
    ).thenAnswer((_) async => null);

    viewModel = TestablePreviousCreditApprovalViewModel(
      mockApprovalRepository: mockApprovalRepository,
      mockRequestRepository: mockRequestRepository,
      mockAdminRepository: mockAdminRepository,
    );
  });

  tearDown(() async {
    Globals.user = null;

    if (!viewModel.isClosed) {
      await viewModel.close();
    }
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityPlusChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(oldConnectivityChannel, null);
  });

  group("PreviousCreditApprovalViewModel defaults", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("properties are initialized properly", () {
      expect(viewModel.repository, mockApprovalRepository);
      expect(viewModel.requestRepository, mockRequestRepository);
      expect(viewModel.adminRepository, mockAdminRepository);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isNull);
      expect(viewModel.initialText, "");
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.isReadOnly, true);
      expect(viewModel.userRoleList, isNotEmpty);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.scrollController, isA<ScrollController>());
      expect(viewModel.commentController.text, "");
    });

    test("userRoleList contains expected roles", () {
      expect(
        viewModel.userRoleList,
        containsAll(<UserRole>[
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.businessUnitHead,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
          UserRole.commercialAreaManager,
          UserRole.relationshipManagerBussiness,
        ]),
      );
    });
  });

  group("init", () {
    test("init covers full flow for view role", () async {
      Globals.user = User(
        currentRole: Role(
          rights: <String, AccessType>{
            RightConstants.previousCreditApproval: AccessType.view,
          },
        ),
      );

      await viewModel.init(fakeContext);

      verify(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).called(1);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepository.fetchReference()).called(1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.commentController.text, viewModel.initialText);
    });

    test("init covers full flow for edit role and draft branch", () async {
      Globals.user = User(
        currentRole: Role(
          rights: <String, AccessType>{
            RightConstants.previousCreditApproval: AccessType.edit,
          },
        ),
      );

      await viewModel.init(fakeContext);

      verify(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).called(1);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepository.fetchReference()).called(1);

      expect(viewModel.isEdit, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init loads server comment and syncs controller", () async {
      final int? categoryId = ServerConstants
          .approvalCategoryId[ApprovalCategory.previousCreditApproval];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(
            categoryId: categoryId,
            strategyComment: "Loaded from init",
          ),
        ],
      );

      Globals.user = User(
        currentRole: Role(
          rights: <String, AccessType>{
            RightConstants.previousCreditApproval: AccessType.view,
          },
        ),
      );

      await viewModel.init(fakeContext);

      expect(viewModel.initialText, "Loaded from init");
      expect(viewModel.commentController.text, "Loaded from init");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getters and draft config", () {
    test("isEdit returns true when user has edit right", () {
      Globals.user = User(
        currentRole: Role(
          rights: <String, AccessType>{
            RightConstants.previousCreditApproval: AccessType.edit,
          },
        ),
      );

      expect(viewModel.isEdit, true);
    });

    test("isEdit returns false when user has view right", () {
      Globals.user = User(
        currentRole: Role(
          rights: <String, AccessType>{
            RightConstants.previousCreditApproval: AccessType.view,
          },
        ),
      );

      expect(viewModel.isEdit, false);
    });

    test("isEdit returns false when user is null", () {
      Globals.user = null;

      expect(viewModel.isEdit, false);
    });

    test("isEdit returns false when currentRole is null", () {
      Globals.user = User();

      expect(viewModel.isEdit, false);
    });

    test("isEdit returns false when rights are null", () {
      Globals.user = User(
        currentRole: Role(),
      );

      expect(viewModel.isEdit, false);
    });

    test("draftModuleKey returns approval", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
    });

    test("draftFormKey returns previousCreditApproval route", () {
      expect(viewModel.draftFormKey, Routes.previousCreditApproval);
    });

    test("draftHandler returns PreviousCreditApprovalDraftHandler", () {
      expect(
        viewModel.draftHandler,
        isA<PreviousCreditApprovalDraftHandler>(),
      );
    });
  });

  group("onSavePress", () {
    test("shows failure toast and returns when initialText is empty", () async {
      viewModel.initialText = "";

      await viewModel.onSavePress(context: fakeContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any<List<Comment>>(),
        ),
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("saves successfully and shows success toast", () async {
      viewModel.initialText = "Approved remarks";

      await viewModel.onSavePress(context: fakeContext);

      verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.previousCreditApproval],
          any<List<Comment>>(),
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
    });

    test("save sends correct previous credit approval payload", () async {
      viewModel.initialText = "Payload remarks";

      await viewModel.onSavePress(context: fakeContext);

      final List<dynamic> captured = verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          captureAny(),
          captureAny<List<Comment>>(),
        ),
      ).captured;

      final int? commentTypeId = captured[0] as int?;
      final List<Comment> comments = captured[1] as List<Comment>;
      final Comment comment = comments.first;

      expect(
        commentTypeId,
        ServerConstants.commentTypeId[CommentsType.previousCreditApproval],
      );
      expect(comments.length, 1);
      expect(comment.strategyComment, "Payload remarks");
      expect(
        comment.categoryId,
        ServerConstants
            .approvalCategoryId[ApprovalCategory.previousCreditApproval],
      );
      expect(
        comment.categoryType,
        ServerConstants
            .approvalCategoryType[ApprovalCategory.previousCreditApproval],
      );
    });

    test("shows error toast and emits error when save throws synchronously",
        () async {
      viewModel.initialText = "Approved remarks";

      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any<List<Comment>>(),
        ),
      ).thenThrow(Exception("Save failed"));

      await viewModel.onSavePress(context: fakeContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("getApplicationStrategyDetails", () {
    test("handles empty comments and emits loaded", () async {
      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialText, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets initialText from matched comment", () async {
      final int? categoryId = ServerConstants
          .approvalCategoryId[ApprovalCategory.previousCreditApproval];

      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: categoryId,
          strategyComment: "Matched strategy comment",
        ),
        Comment(
          categoryId: 999999,
          strategyComment: "Other comment",
        ),
      ];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, comments);
      expect(
        viewModel.comments.first.strategyComment,
        "Matched strategy comment",
      );
      expect(viewModel.initialText, "Matched strategy comment");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("uses first matched comment when multiple matched comments exist",
        () async {
      final int? categoryId = ServerConstants
          .approvalCategoryId[ApprovalCategory.previousCreditApproval];

      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: categoryId,
          strategyComment: "First matched",
        ),
        Comment(
          categoryId: categoryId,
          strategyComment: "Second matched",
        ),
      ];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments.first.strategyComment, "First matched");
      expect(viewModel.initialText, "First matched");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets first strategyComment empty when matched comment not found",
        () async {
      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: 999999,
          strategyComment: "Unmatched comment",
        ),
      ];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments.first.strategyComment, "");
      expect(viewModel.initialText, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles null strategyComment from matched comment", () async {
      final int? categoryId = ServerConstants
          .approvalCategoryId[ApprovalCategory.previousCreditApproval];

      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: categoryId,
        ),
      ];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments.first.strategyComment, null);
      expect(viewModel.initialText, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles exception and shows failure toast", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.previousCreditApproval,
          EntityIdentifier.previousCreditApproval,
        ),
      ).thenThrow(Exception("Fetch failed"));

      await viewModel.getApplicationStrategyDetails();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("syncControllerFromModel", () {
    test("updates controller text when different from initialText", () {
      viewModel.initialText = "New value";
      viewModel.commentController.text = "Old value";

      viewModel.syncControllerFromModel();

      expect(viewModel.commentController.text, "New value");
    });

    test("does nothing when controller text matches initialText", () {
      viewModel.initialText = "Same value";
      viewModel.commentController.text = "Same value";

      viewModel.syncControllerFromModel();

      expect(viewModel.commentController.text, "Same value");
    });

    test("clears controller when initialText is empty", () {
      viewModel.initialText = "";
      viewModel.commentController.text = "Existing text";

      viewModel.syncControllerFromModel();

      expect(viewModel.commentController.text, "");
    });
  });

  group("PreviousCreditApprovalDraftHandler", () {
    test("buildDraftData includes current initialText", () {
      final PreviousCreditApprovalDraftHandler handler =
          PreviousCreditApprovalDraftHandler();

      viewModel.initialText = "Draft text value";

      final Map<String, dynamic> draftData = handler.buildDraftData(viewModel);

      expect(draftData.toString(), contains("Draft text value"));
    });

    test("applyDraft restores data produced by buildDraftData", () async {
      final PreviousCreditApprovalDraftHandler handler =
          PreviousCreditApprovalDraftHandler();

      final PreviousCreditApprovalViewModel sourceVm =
          TestablePreviousCreditApprovalViewModel(
        mockApprovalRepository: mockApprovalRepository,
        mockRequestRepository: mockRequestRepository,
        mockAdminRepository: mockAdminRepository,
      );

      final PreviousCreditApprovalViewModel targetVm =
          TestablePreviousCreditApprovalViewModel(
        mockApprovalRepository: mockApprovalRepository,
        mockRequestRepository: mockRequestRepository,
        mockAdminRepository: mockAdminRepository,
      );

      sourceVm.initialText = "Restored draft text";

      final Map<String, dynamic> draftData = handler.buildDraftData(sourceVm);

      handler.applyDraft(targetVm, draftData);

      expect(targetVm.initialText, "Restored draft text");
      expect(targetVm.commentController.text, "");

      await sourceVm.close();
      await targetVm.close();
    });

    test("draftHandler getter build and apply round trip", () async {
      final PreviousCreditApprovalViewModel sourceVm =
          TestablePreviousCreditApprovalViewModel(
        mockApprovalRepository: mockApprovalRepository,
        mockRequestRepository: mockRequestRepository,
        mockAdminRepository: mockAdminRepository,
      );

      final PreviousCreditApprovalViewModel targetVm =
          TestablePreviousCreditApprovalViewModel(
        mockApprovalRepository: mockApprovalRepository,
        mockRequestRepository: mockRequestRepository,
        mockAdminRepository: mockAdminRepository,
      );

      sourceVm.initialText = "Round trip draft";

      final Map<String, dynamic> draftData =
          sourceVm.draftHandler.buildDraftData(sourceVm);

      targetVm.draftHandler.applyDraft(targetVm, draftData);

      expect(targetVm.initialText, "Round trip draft");
      expect(targetVm.commentController.text, "");

      await sourceVm.close();
      await targetVm.close();
    });
  });

  group("PreviousCreditApprovalState", () {
    test("constructor sets loaderStatus", () {
      final PreviousCreditApprovalState state =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.loading);

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing value when null", () {
      final PreviousCreditApprovalState original =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.loaded);

      final PreviousCreditApprovalState copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides loaderStatus", () {
      final PreviousCreditApprovalState original =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.loaded);

      final PreviousCreditApprovalState updated =
          original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith can set loading", () {
      final PreviousCreditApprovalState original =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.error);

      final PreviousCreditApprovalState updated =
          original.copyWith(loaderStatus: LoadingStatus.loading);

      expect(updated.loaderStatus, LoadingStatus.loading);
    });
  });

  group("MockLocalStorageService", () {
    test("put get delete and clearBox work", () async {
      await mockLocalStorageService.put(
        "draftBox",
        "previousCreditApproval",
        <String, dynamic>{"remarks": "abc"},
      );

      expect(
        await mockLocalStorageService.get(
          "draftBox",
          "previousCreditApproval",
        ),
        <String, dynamic>{"remarks": "abc"},
      );

      await mockLocalStorageService.delete(
        "draftBox",
        "previousCreditApproval",
      );

      expect(
        await mockLocalStorageService.get(
          "draftBox",
          "previousCreditApproval",
        ),
        isNull,
      );

      await mockLocalStorageService.put(
        "draftBox",
        "previousCreditApproval",
        <String, dynamic>{"remarks": "xyz"},
      );

      await mockLocalStorageService.clearBox("draftBox");

      expect(
        await mockLocalStorageService.get(
          "draftBox",
          "previousCreditApproval",
        ),
        isNull,
      );
    });

    test("init completes safely", () async {
      await mockLocalStorageService.init(path: "test-path");

      expect(true, isTrue);
    });
  });

  group("close", () {
    test("disposes controller and completes safely", () async {
      final PreviousCreditApprovalViewModel vm =
          TestablePreviousCreditApprovalViewModel(
        mockApprovalRepository: mockApprovalRepository,
        mockRequestRepository: mockRequestRepository,
        mockAdminRepository: mockAdminRepository,
      );

      await vm.close();

      expect(vm.isClosed, true);
    });

    test("close can be called after controller text update", () async {
      final PreviousCreditApprovalViewModel vm =
          TestablePreviousCreditApprovalViewModel(
        mockApprovalRepository: mockApprovalRepository,
        mockRequestRepository: mockRequestRepository,
        mockAdminRepository: mockAdminRepository,
      )
            ..initialText = "Before close"
            ..syncControllerFromModel();

      expect(vm.commentController.text, "Before close");

      await vm.close();

      expect(vm.isClosed, true);
    });
  });
}
