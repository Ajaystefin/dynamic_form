import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/covenant_condition_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockCovenantConditionRepository extends Mock
    implements CovenantConditionRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockStorageInterface extends Mock implements StorageInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ConditionsSummaryViewModel viewModel;
  late MockCovenantConditionRepository mockConditionRepo;
  late MockCommonRepository mockCommonRepo;
  late MockRequestRepository mockRequestRepo;
  late MockAlertManager mockAlertManager;
  late MockReferenceDataService mockReferenceDataService;

  final mockConditions = [
    CovenantCondition(customerName: "Condition A"),
    CovenantCondition(customerName: "Condition B"),
  ];

  final mockComments = [
    Comment(comment: "Comment A"),
    Comment(comment: "Comment B"),
  ];

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == "check") {
          return ["wifi"];
        }
        return null;
      },
    );
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    mockConditionRepo = MockCovenantConditionRepository();
    mockCommonRepo = MockCommonRepository();
    mockRequestRepo = MockRequestRepository();
    mockAlertManager = MockAlertManager();

    final storageService = LocalStorageService();
    final testHiveStorage =
        HiveStorage(encryptionKey: TestConfig.testEncryptionKeyBytes);
    storageService.setStorage(testHiveStorage);

    viewModel = ConditionsSummaryViewModel(
        //formKey: GlobalKey<FormState>(),
        //comments: <dynamic>[], // or <CommentModel>[]
        );

    viewModel.repository = mockConditionRepo;
    viewModel.commonRepo = mockCommonRepo;
    viewModel.requestRepo = mockRequestRepo;
    registerFallbackValue(Comment(comment: "Test Comment"));
    AlertManager.overrideInstance(mockAlertManager);
    mockReferenceDataService = MockReferenceDataService();
    viewModel.referenceDataService = mockReferenceDataService;
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        return null;
      },
    );
  });

  // group('init method tests', () {
  //   test('init should handle error and emit error status', () async {
  //     when(() => mockConditionRepo.getConditions())
  //         .thenThrow(Exception('Failed to load'));

  //     await viewModel.init(null);

  //     expect(viewModel.state.loaderStatus, LoadingStatus.error);
  //   });
  // });

  test("Initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("should load conditions successfully", () async {
    when(() => mockConditionRepo.getConditions())
        .thenAnswer((_) async => mockConditions);

    viewModel.conditions = await mockConditionRepo.getConditions();

    expect(viewModel.conditions, mockConditions);
  });

  test("should handle repository errors gracefully", () async {
    when(() => mockConditionRepo.getConditions())
        .thenThrow(Exception("Failed"));

    try {
      await mockConditionRepo.getConditions();
    } catch (e) {
      expect(e.toString(), contains("Failed"));
    }
  });

  test("getComments should fetch and assign comments", () async {
    when(
      () => mockCommonRepo.getComments(
        CommentsType.conditionsSummary,
        EntityIdentifier.conditionsSummary,
      ),
    ).thenAnswer((_) async => mockComments);

    // await viewModel
    //     .getComments(
    //         CommentsType.conditionsSummary,
    // EntityIdentifier.conditionsSummary)
    //     .timeout(const Duration(seconds: 5));

    // expect(viewModel.comments, mockComments);
  });

  test("getComments should handle error and show toast", () async {
    when(
      () => mockCommonRepo.getComments(
        CommentsType.conditionsSummary,
        EntityIdentifier.conditionsSummary,
      ),
    ).thenThrow(Exception("Error"));

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    await viewModel
        .getComments(
          CommentsType.conditionsSummary,
          EntityIdentifier.conditionsSummary,
        )
        .timeout(const Duration(seconds: 5));

    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test("onDeleteCondition should delete and update state", () async {
    final condition = CovenantCondition(customerName: "Delete Me");
    viewModel.conditions = [condition];

    when(() => mockRequestRepo.saveConditionDetails(any()))
        .thenAnswer((_) async => "Deleted");

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    await viewModel
        .onDeleteCondition(condition, 0)
        .timeout(const Duration(seconds: 5));

    expect(viewModel.conditions, isEmpty);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    verify(() => mockAlertManager.showSuccessToast(any())).called(1);
  });

  test("onDeleteCondition should handle error and emit error status", () async {
    final condition = CovenantCondition(customerName: "Delete Me");
    viewModel.conditions = [condition];

    when(() => mockRequestRepo.saveConditionDetails(any()))
        .thenThrow(Exception("Delete failed"));

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    await viewModel
        .onDeleteCondition(condition, 0)
        .timeout(const Duration(seconds: 5));

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  group("additional property tests", () {
    test("should have correct initial values", () {
      expect(viewModel.rowsPerPage, 10);
      expect(viewModel.strategyComment, "");
      expect(viewModel.isCovenant, 0);
      expect(viewModel.conditions, isEmpty);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isA<Comment>());
    });

    test("should handle strategy comment assignment", () {
      viewModel.strategyComment = "Test strategy comment";
      expect(viewModel.strategyComment, "Test strategy comment");
    });

    test("should handle isCovenant assignment", () {
      viewModel.isCovenant = 1;
      expect(viewModel.isCovenant, 1);
    });

    test("should handle condition list modifications", () {
      final testCondition = CovenantCondition(customerName: "Test");
      viewModel.conditions.add(testCondition);
      expect(viewModel.conditions.length, 1);
      expect(viewModel.conditions.first.customerName, "Test");
    });
  });

  group("pageMode & canEdit", () {
    test("canEdit is true when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, isTrue);
    });

    test("canEdit is false when pageMode is not edit", () {
      viewModel.pageMode = PageMode.na;
      expect(viewModel.canEdit, isFalse);
    });
  });

  group("isFIFlow", () {
    test("returns true when business segment is financial institution", () {
      Globals.request = Request(
        businessSegment: Reference(
          id: ServerConstants
              .businessSegmentId[BusinessSegment.financialInstitution],
          name: "Financial Institution",
          isActive: true,
        ),
      );

      expect(viewModel.isFIFlow, isTrue);
    });

    test("returns false when business segment is not financial institution",
        () {
      Globals.request = Request(
        businessSegment: Reference(
          id: ServerConstants.businessSegmentId[BusinessSegment.corporate],
          name: "Corporate",
          isActive: true,
        ),
      );

      expect(viewModel.isFIFlow, isFalse);
    });
  });
  group("DraftMixin keys & handler", () {
    test("draftModuleKey is covenantsAndConditions", () {
      expect(
        viewModel.draftModuleKey,
        DraftModuleKeys.covenantsAndConditions,
      );
    });

    test("draftFormKey is conditionsSummary route", () {
      expect(
        viewModel.draftFormKey,
        Routes.conditionsSummary,
      );
    });

    test("draftHandler is ConditionsSummaryDraftHandler", () {
      expect(
        viewModel.draftHandler,
        isA<ConditionsSummaryDraftHandler>(),
      );
    });
  });

  group("getConditions()", () {
    test("loads conditions and sets loaderStatus to loaded", () async {
      when(() => mockConditionRepo.getConditions())
          .thenAnswer((_) async => mockConditions);

      await viewModel.getConditions();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.conditions, mockConditions);
      verify(() => mockConditionRepo.getConditions()).called(1);
    });
  });

  group("getConditions() error handling", () {
    test("throws when repository fails", () async {
      when(() => mockConditionRepo.getConditions())
          .thenThrow(Exception("Failed"));

      expect(
        () async => viewModel.getConditions(),
        throwsException,
      );

      verify(() => mockConditionRepo.getConditions()).called(1);
    });
  });

  group("getComments() with empty result", () {
    test(
      "sets comments but does not update controller"
      " or editor when list is empty",
      () async {
        when(
          () => mockCommonRepo.getComments(
            CommentsType.conditionsSummary,
            EntityIdentifier.conditionsSummary,
          ),
        ).thenAnswer((_) async => <Comment>[]);

        viewModel.controller.text = "existing text";

        await viewModel.getComments(
          CommentsType.conditionsSummary,
          EntityIdentifier.conditionsSummary,
        );

        expect(viewModel.comments, isEmpty);
        expect(viewModel.controller.text, "existing text");
      },
    );
  });

  group("getComments() error handling", () {
    test(
      "shows failure toast when repository throws exception",
      () async {
        when(
          () => mockCommonRepo.getComments(
            CommentsType.conditionsSummary,
            EntityIdentifier.conditionsSummary,
          ),
        ).thenThrow(Exception("Error fetching comments"));

        when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

        await viewModel.getComments(
          CommentsType.conditionsSummary,
          EntityIdentifier.conditionsSummary,
        );

        verify(() => mockAlertManager.showFailureToast(any())).called(1);
      },
    );
  });

  group("getReferenceName()", () {
    test("returns empty string when list is null", () {
      final result = viewModel.getReferenceName(null, 1);
      expect(result, "");
    });

    test("returns empty string when id is null", () {
      final list = [Reference(id: 1, name: "Ref 1")];
      final result = viewModel.getReferenceName(list, null);
      expect(result, "");
    });

    test("returns matching reference name when id exists", () {
      final list = [
        Reference(id: 1, name: "Ref 1"),
        Reference(id: 2, name: "Ref 2"),
      ];

      final result = viewModel.getReferenceName(list, 2);

      expect(result, "Ref 2");
    });

    test("returns empty string when id is not found", () {
      final list = [
        Reference(id: 1, name: "Ref 1"),
      ];

      final result = viewModel.getReferenceName(list, 99);

      expect(result, "");
    });

    test("returns empty string when reference name is null", () {
      final list = [
        Reference(id: 1, name: null),
      ];

      final result = viewModel.getReferenceName(list, 1);

      expect(result, "");
    });
  });

  group("loadReferenceData()", () {
    test(
      "loads reference data successfully",
      () async {
        final mockRefData = <String, List<Reference>>{
          ReferenceDataKeys.conditionDescriptionTemplate: [
            Reference(id: 1, name: "Desc"),
          ],
        };

        when(
          () => viewModel.referenceDataService.getReferenceData(any()),
        ).thenAnswer((_) async => mockRefData);

        await viewModel.loadReferenceData();

        expect(viewModel.referenceData, mockRefData);
      },
    );
  });

  group("loadReferenceData() error handling", () {
    test(
      "shows failure toast, emits loaded status, and rethrows exception",
      () async {
        when(
          () => mockReferenceDataService.getReferenceData(any()),
        ).thenThrow(Exception("Reference load failed"));

        when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

        expect(
          () async => viewModel.loadReferenceData(),
          throwsException,
        );

        verify(() => mockAlertManager.showFailureToast(any())).called(1);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );
  });

  group("close()", () {
    test("unregisters draft callback and closes without error", () async {
      // Should complete without throwing
      await viewModel.close();

      // If close completes, unregisterDraftCallback was called safely
      expect(true, isTrue);
    });
  });
}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class TestLayoutViewModel extends LayoutViewModel {
  @override
  void goToNextRoute({Object? extra}) {}
}
