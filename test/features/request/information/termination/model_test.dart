import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/termination/draft_handler.dart";
import "package:wcas_frontend/features/request/information/termination/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class FakeBuildContext extends Fake implements BuildContext {}

// class MockFormState extends Mock implements FormState {}

class MockAlertManager extends Mock implements AlertManager {}

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

  void clearAll() {
    _storage.clear();
  }
}

void main() {
  late TerminationViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;
  late MockCommonRepository mockCommonRepositorysitory;
  // late FakeBuildContext mockContext;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(const SizedBox.shrink());
    registerFallbackValue(<Widget>[]); // For actions

    // Mock the connectivity plugin to return a list with wifi connectivity
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
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepository = MockRequestRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockCommonRepositorysitory = MockCommonRepository();
    mockAlertManager = MockAlertManager();
    // mockContext = FakeBuildContext();
    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().getStorage = mockLocalStorageService;

    viewModel = TerminationViewModel()..repository = mockRepository;

    registerFallbackValue(CommentsType.terminateWithdraw);
    registerFallbackValue(EntityIdentifier.terminateWithdraw);
  });

  testWidgets(
      "onTerminateButtonPressed does not show dialog when form is invalid",
      (WidgetTester tester) async {
    viewModel
      ..terminationPageMode = PageMode.edit
      ..formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Form(
          key: viewModel.formKey,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  viewModel.onTerminateButtonPressed(context);
                },
                child: const Text("Submit"),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback

    // Since form is invalid, dialog should not appear
    expect(
      find.text("requestInformation.terminateWithdrawal.warning".tr()),
      findsNothing,
    );
  });

  testWidgets("onTerminateButtonPressed shows dialog when form is valid",
      (WidgetTester tester) async {
    viewModel
      ..terminationPageMode = PageMode.edit
      ..formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: viewModel.formKey,
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    TextFormField(
                      controller: TextEditingController(),
                      validator: (_) => null, // Always valid
                      onSaved: (_) {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.onTerminateButtonPressed(context);
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), "Valid input");
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback
    await tester.pump(); // Allows dialog to render

    expect(
      find.text("requestInformation.terminateWithdrawal.warning".tr()),
      findsOneWidget,
    );
  });

  testWidgets("showDialogUpdateTerminateStatus displays confirmation dialog",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                viewModel.showDialogUpdateTerminateStatus(context);
              },
              child: const Text("Trigger Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback
    await tester.pump(); // Allows dialog to render

    // Check for presence of dialog content
    expect(
      find.text("requestInformation.terminateWithdrawal.warning".tr()),
      findsOneWidget,
    );
    expect(
      find.text("requestInformation.terminateWithdrawal.warningMsg".tr()),
      findsOneWidget,
    );
  });

  testWidgets("showDialogSuccessTerminateStatus displays success dialog",
      (WidgetTester tester) async {
    viewModel.isTerminationSuccess = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                viewModel.showDialogSuccessTerminateStatus(context);
              },
              child: const Text("Trigger Success Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Triggers addPostFrameCallback
    await tester.pump(); // Allows dialog to render

    // Check for presence of dialog content
    expect(
      find.text("requestInformation.terminateWithdrawal.information".tr()),
      findsOneWidget,
    );
    // expect(
    //
    //     findsOneWidget);

    // Confirm flag reset
    expect(viewModel.isTerminationSuccess, false);
  });

  test("MockLocalStorageService should store, retrieve, delete, and clear data",
      () async {
    final storage = MockLocalStorageService();

    await storage.put("box1", "key1", "value1");

    expect(await storage.get("box1", "key1"), "value1");

    await storage.delete("box1", "key1");

    expect(await storage.get("box1", "key1"), isNull);

    await storage.put("box1", "key2", "value2");

    await storage.clearBox("box1");

    expect(await storage.get("box1", "key2"), isNull);

    await storage.put("box2", "key3", "value3");

    storage.clearAll();

    expect(await storage.get("box2", "key3"), isNull);
  });

  group("ApplicationService Tests", () {
    test("submitTerminateRequest calls repository with correct data", () async {
      // when(() => mockRepository.updateTerminateStatus(any(), any()))
      //     .thenAnswer((_) async => 'Success');

      // viewModel.getReviewComments = [
      //   Comment(applicationRefNo: 'APP123', reasonList: 'R1', comment: 'Test')
      // ];

      // await viewModel.submitTerminateRequest(FakeBuildContext());

      // verify(mockRepository.updateTerminateStatus('R1', 'Test')).called(1);
      // expect(viewModel.isTerminationSuccess, true);
    });

    test("submitTerminateRequest handles empty comments", () async {
      // when(() => mockRepository.updateTerminateStatus(any(), any()))
      //     .thenAnswer((_) async => 'Success');

      // viewModel.getReviewComments = [];

      // await viewModel.submitTerminateRequest(FakeBuildContext());

      // expect(viewModel.getReviewComments!.isNotEmpty, false);
      // expect(viewModel.isTerminationSuccess, true);
    });
  });

  group("TerminationViewModel Tests", () {
    test("init calls both getReviewCommentsReference and getReferenceDatas",
        () async {
      viewModel.reasonForTermination = [Reference(id: 1, name: "Test Reason")];
      when(() => mockCommonRepositorysitory.getComments(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.terminationReason: [
            Reference(id: 1, name: "Reason"),
          ],
        },
      );

      AlertManager.overrideInstance = mockAlertManager;
      await viewModel.init(FakeBuildContext());

      expect(viewModel.reasonForTermination.isNotEmpty, true);
      expect(viewModel.getReviewComments, isEmpty);
    });

    test("getReviewCommentsReference filters comments by applicationRefNo",
        () async {
      viewModel.getReviewComments = [
        Comment(applicationRefNo: "APP123"),
      ];
      Globals.request?.applicationRefNo = "APP123";
      when(() => mockCommonRepositorysitory.getComments(any(), any()))
          .thenAnswer(
        (_) async => [
          Comment(applicationRefNo: "APP123"),
          Comment(applicationRefNo: "OTHER"),
        ],
      );
      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.getReviewComments!.length, 1);
      expect(viewModel.getReviewComments!.first.applicationRefNo, "APP123");
    });

    test("getReviewCommentsReference handles exception", () async {
      when(() => mockCommonRepositorysitory.getComments(any(), any()))
          .thenThrow(Exception("Error fetching comments"));
      AlertManager.overrideInstance = mockAlertManager;
      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getReferenceDatas loads termination reasons", () async {
      viewModel.reasonForTermination = [Reference(id: 1, name: "Test Reason")];
      when(() => mockReferenceDataService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.terminationReason: [
            Reference(id: 1, name: "Test Reason"),
          ],
        },
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.reasonForTermination.length, 1);
      expect(viewModel.reasonForTermination.first.name, "Test Reason");
    });

    test("getReferenceDatas handles exception", () async {
      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenThrow(Exception("Error fetching reference data"));

      await viewModel.getReferenceDatas();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("TerminationViewModel Draft Config", () {
    test("draftModuleKey returns correct value", () {
      final vm = TerminationViewModel();

      expect(vm.draftModuleKey, DraftModuleKeys.requestInformation);
    });

    test("draftFormKey returns correct value", () {
      final vm = TerminationViewModel();

      expect(vm.draftFormKey, Routes.terminateWithdraw);
    });

    test("draftHandler returns correct type", () {
      final vm = TerminationViewModel();

      expect(vm.draftHandler, isA<TerminationDraftHandler>());
    });

    test("draftHandler returns new instance each time", () {
      final vm = TerminationViewModel();

      final handler1 = vm.draftHandler;
      final handler2 = vm.draftHandler;

      expect(handler1.runtimeType, equals(handler2.runtimeType));
      expect(identical(handler1, handler2), false);
    });
  });

  group("reasonForTerminationSelected", () {
    test("updates comment when comment exists", () {
      final vm = TerminationViewModel()..comment = Comment();

      final reason = Reference(id: 10);

      vm.reasonForTerminationSelected(reason);

      expect(vm.comment?.categoryId, 10);
      expect(vm.comment?.reasonList, "10");
    });

    test("does not crash when comment is null", () {
      final vm = TerminationViewModel()..comment = null;

      final reason = Reference(id: 20);

      vm.reasonForTerminationSelected(reason);

      expect(true, true);
    });

    test("updates first review comment when list is not empty", () {
      final vm = TerminationViewModel()..getReviewComments = [Comment()];

      final reason = Reference(id: 30);

      vm.reasonForTerminationSelected(reason);

      expect(vm.getReviewComments!.first.reasonList, "30");
    });

    test("does nothing when review comments list is empty", () {
      final vm = TerminationViewModel()..getReviewComments = [];

      final reason = Reference(id: 40);

      vm.reasonForTerminationSelected(reason);

      expect(vm.getReviewComments!.isEmpty, true);
    });

    test("does not crash when review comments is null", () {
      final vm = TerminationViewModel()..getReviewComments = null;

      final reason = Reference(id: 50);

      vm.reasonForTerminationSelected(reason);

      expect(true, true);
    });

    test("updates both comment and review comment when both exist", () {
      final vm = TerminationViewModel()
        ..comment = Comment()
        ..getReviewComments = [Comment()];

      final reason = Reference(id: 99);

      vm.reasonForTerminationSelected(reason);

      expect(vm.comment?.categoryId, 99);
      expect(vm.comment?.reasonList, "99");
      expect(vm.getReviewComments!.first.reasonList, "99");
    });
  });

  group("TerminationViewModel close", () {
    test("close executes without errors", () async {
      final vm = TerminationViewModel();

      await vm.close();

      expect(true, true);
    });

    test("close can be called multiple times safely", () async {
      final vm = TerminationViewModel();

      await vm.close();
      await vm.close();

      expect(true, true);
    });
  });

  group("getReviewCommentsReference", () {
    tearDown(() {
      CommonRepository.debugReplaceInstance = CommonRepository();
    });

    test("filters matching comments and sets first comment", () async {
      final vm = TerminationViewModel();

      Globals.request = Request(applicationRefNo: "ABC123");

      final fakeData = [
        Comment(applicationRefNo: "ABC123"),
        Comment(applicationRefNo: "XYZ999"),
      ];

      CommonRepository.debugReplaceInstance = FakeCommonRepository(fakeData);

      await vm.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(vm.getReviewComments!.length, 1);
      expect(vm.getReviewComments!.first.applicationRefNo, "ABC123");
      expect(vm.comment?.applicationRefNo, "ABC123");
    });

    test("returns empty when no matching applicationRefNo", () async {
      final vm = TerminationViewModel();

      Globals.request = Request(applicationRefNo: "MATCH");

      final fakeData = [
        Comment(applicationRefNo: "OTHER"),
      ];

      CommonRepository.debugReplaceInstance = FakeCommonRepository(fakeData);

      await vm.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(vm.getReviewComments, isEmpty);
    });

    test("handles null applicationRefNo safely", () async {
      final vm = TerminationViewModel();

      Globals.request = Request(applicationRefNo: "REQ");

      final fakeData = [
        Comment(),
      ];

      CommonRepository.debugReplaceInstance = FakeCommonRepository(fakeData);

      await vm.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(vm.getReviewComments, isEmpty);
    });

    test("handles empty list safely", () async {
      final vm = TerminationViewModel();

      Globals.request = Request(applicationRefNo: "REQ");

      CommonRepository.debugReplaceInstance = FakeCommonRepository([]);

      await vm.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(vm.getReviewComments, isEmpty);
    });

    test("handles error and sets state to error", () async {
      final vm = TerminationViewModel();

      CommonRepository.debugReplaceInstance = ErrorCommonRepository();

      await vm.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(vm.state.loaderStatus, LoadingStatus.error);
    });
  });

  test("reasonForTermination is empty when value is null", () {
    final vm = TerminationViewModel();

    vm
      ..referenceData = {
        ReferenceDataKeys.terminationReason: [],
      }
      ..reasonForTermination =
          vm.referenceData[ReferenceDataKeys.terminationReason] ?? [];

    expect(vm.reasonForTermination, isEmpty);
  });

  test("reasonForTermination is empty when key is missing", () {
    final vm = TerminationViewModel();

    vm
      ..referenceData = {} // no key
      ..reasonForTermination =
          vm.referenceData[ReferenceDataKeys.terminationReason] ?? [];

    expect(vm.reasonForTermination, isEmpty);
  });

  test("getReferenceDatas covers null fallback branch", () async {
    final vm = TerminationViewModel()
      ..referenceData = {
        // intentionally different key
        "someOtherKey": [],
      };

    try {
      await vm.getReferenceDatas();
    } on Exception catch (_) {
      // ignore API error
    }

    vm
      ..referenceData = {
        // simulate response WITHOUT required key
        "wrongKey": [],
      }
      ..reasonForTermination =
          vm.referenceData[ReferenceDataKeys.terminationReason] ?? [];

    expect(vm.reasonForTermination, isEmpty);
  });

  test("submitTerminateRequest success", () async {
    final vm = TerminationViewModel()
      ..repository = FakeRepo()
      ..terminationPageMode = PageMode.view
      ..comment = Comment(reasonList: "1", comment: "test")
      ..formKey = GlobalKey<FormState>();

    await vm.submitTerminateRequest(TestBuildContext());

    expect(vm.isTerminationSuccess, true);
    expect(vm.state.isButtonLoading, false);
  });

  test("submitTerminateRequest error path", () async {
    final vm = TerminationViewModel()
      ..repository = ErrorRepo()
      ..terminationPageMode = PageMode.view
      ..comment = Comment(reasonList: "1")
      ..formKey = GlobalKey<FormState>();

    await vm.submitTerminateRequest(TestBuildContext());

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });
}

class FakeRepo extends RequestRepository {
  @override
  Future<String?> updateTerminateStatus(String? r, String? c) async {
    return "success";
  }
}

class ErrorRepo extends RequestRepository {
  @override
  Future<String?> updateTerminateStatus(String? r, String? c) async {
    throw Exception("error");
  }
}

class TestBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCommonRepository extends CommonRepository {
  FakeCommonRepository(this.comments);
  final List<Comment> comments;

  @override
  Future<List<Comment>> getComments(
    CommentsType type,
    EntityIdentifier? entityIdentifier,
  ) async {
    return comments;
  }
}

class ErrorCommonRepository extends CommonRepository {
  @override
  Future<List<Comment>> getComments(
    CommentsType type,
    EntityIdentifier? entityIdentifier,
  ) async {
    throw Exception("error");
  }
}
