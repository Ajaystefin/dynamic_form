import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

import "../../../../test_config.dart";

class MockGroupInformationRepository extends Mock
    implements GroupInformationRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage =
      <String, Map<String, dynamic>>{};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
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

  void clearAll() {
    _storage.clear();
  }
}

class TestBuildContext extends Fake implements BuildContext {
  @override
  bool mounted = true;
}

/// Subclass used to cover draft-mixin interactions safely
class TestFacilitiesWithCbdViewModel extends FacilitiesWithCbdViewModel {
  int registerDraftCallbackCalled = 0;
  int loadDraftIfAvailableCalled = 0;
  int deleteDraftCalled = 0;
  int unregisterDraftCallbackCalled = 0;

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled++;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled++;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled++;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled++;
  }
}

Future<void> pumpFormHost({
  required WidgetTester tester,
  required FacilitiesWithCbdViewModel viewModel,
  required String? Function(String?) validator,
  void Function(String?)? onSaved,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: viewModel.formKey,
          child: TextFormField(
            validator: validator,
            onSaved: onSaved,
          ),
        ),
      ),
    ),
  );

  await tester.pump();
}

Future<void> flushAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  late TestFacilitiesWithCbdViewModel viewModel;
  late MockGroupInformationRepository mockGroupRepo;
  late MockCommonRepository mockCommonRepo;
  late MockLocalStorageService mockLocalStorageService;
  late MockAlertManager mockAlertManager;

  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(Comment());
    registerFallbackValue(FacilitiesWithCbd());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>["wifi"];
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    mockGroupRepo = MockGroupInformationRepository();
    mockCommonRepo = MockCommonRepository();
    mockLocalStorageService = MockLocalStorageService();
    mockAlertManager = MockAlertManager();

    AlertManager.overrideInstance(mockAlertManager);
    LocalStorageService().setStorage(mockLocalStorageService);
    CommonRepository.overrideInstance(mockCommonRepo);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    viewModel = TestFacilitiesWithCbdViewModel()..repository = mockGroupRepo;

    when(() => mockGroupRepo.getGroupInformation())
        .thenAnswer((_) async => <FacilitiesWithCbd>[]);
    when(
      () => mockCommonRepo.getApplicationStrategyDetails(
        CommentsType.facilitiesWithCbd,
        EntityIdentifier.facilitiesWithCbd,
      ),
    ).thenAnswer((_) async => <Comment>[]);
    when(
      () => mockCommonRepo.saveApplicationStrategyDetails(
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((_) async => "Saved");
  });

  group("constructor / fields / getters", () {
    test("constructor initializes default values correctly", () {
      final FacilitiesWithCbdViewModel newViewModel =
          FacilitiesWithCbdViewModel();

      expect(newViewModel.state.loaderStatus, LoadingStatus.loading);
      expect(newViewModel.repository, isNull);
      expect(newViewModel.formKey, isA<GlobalKey<FormState>>());
      expect(newViewModel.groupFacilitiesWithCDB, isEmpty);
      expect(
        newViewModel.groupFacilitiesWithCDB,
        isA<List<FacilitiesWithCbd>>(),
      );
      expect(newViewModel.comments, isNull);
      expect(newViewModel.comment, isNull);
      expect(newViewModel.commentController.text, "");
    });

    test("draft getters return expected values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.groupInformation);
      expect(viewModel.draftFormKey, Routes.facilitiesWithCbd);
      expect(viewModel.draftHandler, isNotNull);
    });

    test("canEdit returns true only when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, isTrue);

      viewModel.pageMode = PageMode.na;
      expect(viewModel.canEdit, isFalse);
    });

    test("field assignment tests", () {
      expect(viewModel.comment, isNull);
      final Comment comment = Comment();
      viewModel.comment = comment;
      expect(viewModel.comment, same(comment));

      expect(viewModel.comments, isNull);
      final List<Comment> comments = <Comment>[Comment(), Comment()];
      viewModel.comments = comments;
      expect(viewModel.comments, same(comments));
      expect(viewModel.comments!.length, 2);

      expect(viewModel.groupFacilitiesWithCDB, isEmpty);
      final List<FacilitiesWithCbd> facilities = <FacilitiesWithCbd>[
        FacilitiesWithCbd(),
        FacilitiesWithCbd(),
      ];
      viewModel.groupFacilitiesWithCDB = facilities;
      expect(viewModel.groupFacilitiesWithCDB, same(facilities));
      expect(viewModel.groupFacilitiesWithCDB.length, 2);
    });
  });

  group("init()", () {
    test("init sets repository when null", () async {
      final TestFacilitiesWithCbdViewModel newViewModel =
          TestFacilitiesWithCbdViewModel();

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[Comment()]);

      // Only verifies the null-aware assignment line runs
      await newViewModel.init(TestBuildContext());
      await flushAsync();

      expect(newViewModel.repository, isA<GroupInformationRepository>());
    });

    test("init does not override existing repository", () async {
      final GroupInformationRepository? originalRepo = viewModel.repository;

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[Comment()]);

      await viewModel.init(TestBuildContext());
      await flushAsync();

      expect(viewModel.repository, same(originalRepo));
    });

    test("init waits for getApplicationStrategyDetails and getGroupInformation",
        () async {
      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[Comment()]);

      await viewModel.init(TestBuildContext());
      await flushAsync();

      verify(() => mockGroupRepo.getGroupInformation()).called(1);
      verify(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).called(1);
    });

    test("init registers draft and loads draft when isEdit is true", () async {
      viewModel.isEdit = true;

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.init(TestBuildContext());
      await flushAsync();

      expect(viewModel.registerDraftCallbackCalled, 1);
      expect(viewModel.loadDraftIfAvailableCalled, 1);
    });

    test("init does not register or load draft when isEdit is false", () async {
      viewModel.isEdit = false;

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.init(TestBuildContext());
      await flushAsync();

      expect(viewModel.registerDraftCallbackCalled, 0);
      expect(viewModel.loadDraftIfAvailableCalled, 0);
    });

    test(
        "init adds listener and updates comment when commentController changes",
        () async {
      viewModel.isEdit = false;

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.init(TestBuildContext());
      await flushAsync();

      viewModel.commentController.text = "typed comment";
      await flushAsync();

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment!.comment, "typed comment");
    });

    test("init sets pageMode from AuthRepository path", () async {
      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.init(TestBuildContext());
      await flushAsync();

      expect(viewModel.pageMode, isA<PageMode>());
    });
  });

  group("getApplicationStrategyDetails()", () {
    test("sets comment correctly with matching categoryId", () async {
      final Comment matchingComment = Comment(
        categoryId: ServerConstants.groupCategoryID,
        strategyComment: "Strategy Comment",
      );

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[matchingComment]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment?.comment, "Strategy Comment");
      expect(viewModel.comments, <Comment>[matchingComment]);
      expect(viewModel.commentController.text, "Strategy Comment");
    });

    test("sets comment to empty when no matching categoryId", () async {
      final Comment comment =
          Comment(categoryId: 999, strategyComment: "Other Strategy");

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[comment]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment?.comment, "");
      expect(viewModel.commentController.text, "");
    });

    test("handles empty comment list", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment?.comment, "");
      expect(viewModel.commentController.text, "");
    });

    test("handles null strategyComment", () async {
      final List<Comment> mockComments = <Comment>[
        Comment(
          categoryId: ServerConstants.groupCategoryID,
          strategyComment: null,
        ),
      ];

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => mockComments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment?.comment, null);
      expect(viewModel.commentController.text, "");
    });

    test("handles multiple comments with matching category", () async {
      final List<Comment> mockComments = <Comment>[
        Comment(categoryId: 1, strategyComment: "Comment 1"),
        Comment(
          categoryId: ServerConstants.groupCategoryID,
          strategyComment: "Expected Comment",
        ),
        Comment(categoryId: 3, strategyComment: "Comment 3"),
      ];

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => mockComments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment?.comment, "Expected Comment");
      expect(viewModel.comments, mockComments);
    });

    test("initializes comment when null", () async {
      expect(viewModel.comment, isNull);

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment, isA<Comment>());
    });

    test("handles exception and emits error", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenThrow(Exception("API Error"));

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("filters comments by categoryId correctly", () async {
      final List<Comment> mockComments = <Comment>[
        Comment(categoryId: 1, strategyComment: "Comment 1"),
        Comment(
          categoryId: ServerConstants.groupCategoryID,
          strategyComment: "Group Comment 1",
        ),
        Comment(categoryId: 3, strategyComment: "Comment 3"),
        Comment(
          categoryId: ServerConstants.groupCategoryID,
          strategyComment: "Group Comment 2",
        ),
      ];

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenAnswer((_) async => mockComments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comment?.comment, "Group Comment 1");
    });
  });

  group("getGroupInformation()", () {
    test("sets loaderStatus to loaded on success", () async {
      final List<FacilitiesWithCbd> facilities = <FacilitiesWithCbd>[
        FacilitiesWithCbd(),
        FacilitiesWithCbd(),
      ];

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => facilities);

      await viewModel.getGroupInformation();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.groupFacilitiesWithCDB, facilities);
      expect(viewModel.groupFacilitiesWithCDB.length, 2);
    });

    test("sets loaderStatus to error on failure", () async {
      when(() => mockGroupRepo.getGroupInformation())
          .thenThrow(Exception("Failed"));

      await viewModel.getGroupInformation();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("handles empty list", () async {
      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[]);

      await viewModel.getGroupInformation();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.groupFacilitiesWithCDB, isEmpty);
    });

    test("populates groupFacilitiesWithCDB correctly", () async {
      final FacilitiesWithCbd facility1 = FacilitiesWithCbd();
      final FacilitiesWithCbd facility2 = FacilitiesWithCbd();
      final List<FacilitiesWithCbd> facilities = <FacilitiesWithCbd>[
        facility1,
        facility2,
      ];

      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => facilities);

      await viewModel.getGroupInformation();

      expect(viewModel.groupFacilitiesWithCDB, facilities);
      expect(viewModel.groupFacilitiesWithCDB[0], same(facility1));
      expect(viewModel.groupFacilitiesWithCDB[1], same(facility2));
    });
  });

  group("onSaveComment()", () {
    // testWidgets('successful save path saves comment, deletes draft and
    // loads', (WidgetTester tester) async {
    //   await pumpFormHost(
    //     tester: tester,
    //     viewModel: viewModel,
    //     validator: (_) => null,
    //     onSaved: (_) {},
    //   );

    //   viewModel.commentController.text = 'Saved comment';

    //   when(
    //     () => mockCommonRepo.saveApplicationStrategyDetails(
    //       ServerConstants.groupStrategyCommentsType,
    //       ServerConstants.groupAppStrategyCommentsId,
    //       any(),
    //     ),
    //   ).thenAnswer((_) async => 'Success');

    //   await viewModel.onSaveComment();

    //   verify(
    //     () => mockCommonRepo.saveApplicationStrategyDetails(
    //       ServerConstants.groupStrategyCommentsType,
    //       ServerConstants.groupAppStrategyCommentsId,
    //       any(),
    //     ),
    //   ).called(1);

    //   expect(viewModel.deleteDraftCalled, 1);
    //   verify(() => mockAlertManager.showSuccessToast('Success')).called(1);
    //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    // });

    testWidgets("invalid form does not save and ends loaded",
        (WidgetTester tester) async {
      await pumpFormHost(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => "Validation error",
        onSaved: (_) {},
      );

      viewModel.comment = Comment();

      await viewModel.onSaveComment();

      verifyNever(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("null currentState throws and emits error", () async {
      viewModel.comment = Comment();

      await viewModel.onSaveComment();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    // test('null comment is created during successful save', () async {
    //   final GlobalKey<FormState> key = GlobalKey<FormState>();
    //   viewModel.formKey = key;

    //   final Widget app = MaterialApp(
    //     home: Scaffold(
    //       body: Form(
    //         key: key,
    //         child: TextFormField(
    //           validator: (_) => null,
    //           onSaved: (_) {},
    //         ),
    //       ),
    //     ),
    //   );

    //   final TestWidgetsFlutterBinding binding =
    //       TestWidgetsFlutterBinding.ensureInitialized();
    //   binding.renderView.configuration = TestViewConfiguration.fromView(
    //     binding.platformDispatcher.views.first,
    //   );

    //   // This test doesn't need tester because we are only ensuring no crash path.
    //   expect(viewModel.comment, isNull);
    // });

    testWidgets("saveApplicationStrategyDetails exception emits error",
        (WidgetTester tester) async {
      await pumpFormHost(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => null,
        onSaved: (_) {},
      );

      viewModel.commentController.text = "Saved comment";

      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Strategy save failed"));

      await viewModel.onSaveComment();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      verify(
        () => mockAlertManager.showFailureToast(
          "Exception: Strategy save failed",
        ),
      ).called(1);
    });

    test("without form ends in error state", () async {
      viewModel.comment = Comment();

      await viewModel.onSaveComment();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("state and repository interaction", () {
    test("state changes from loading to loaded during getGroupInformation",
        () async {
      when(() => mockGroupRepo.getGroupInformation())
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);

      await viewModel.getGroupInformation();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "state changes from loading to error during"
        " getApplicationStrategyDetails error", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd,
          EntityIdentifier.facilitiesWithCbd,
        ),
      ).thenThrow(Exception("API Error"));

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("repository field can be set and retrieved", () {
      expect(viewModel.repository, isA<GroupInformationRepository>());

      final MockGroupInformationRepository newRepo =
          MockGroupInformationRepository();
      viewModel.repository = newRepo;

      expect(viewModel.repository, same(newRepo));
    });

    test("getGroupInformation uses correct repository instance", () async {
      final MockGroupInformationRepository specificRepo =
          MockGroupInformationRepository();
      viewModel.repository = specificRepo;

      when(specificRepo.getGroupInformation)
          .thenAnswer((_) async => <FacilitiesWithCbd>[FacilitiesWithCbd()]);

      await viewModel.getGroupInformation();

      verify(specificRepo.getGroupInformation).called(1);
    });
  });

  group("close()", () {
    test("close unregisters draft callback", () async {
      await viewModel.close();
      expect(viewModel.unregisterDraftCallbackCalled, 1);
    });
  });

  group("FacilitiesWithCbdState", () {
    test("constructor sets loaderStatus loading", () {
      final FacilitiesWithCbdState state = FacilitiesWithCbdState(
        loaderStatus: LoadingStatus.loading,
      );
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final FacilitiesWithCbdState original = FacilitiesWithCbdState(
        loaderStatus: LoadingStatus.loaded,
      );
      final FacilitiesWithCbdState copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides value", () {
      final FacilitiesWithCbdState original = FacilitiesWithCbdState(
        loaderStatus: LoadingStatus.loaded,
      );
      final FacilitiesWithCbdState updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
