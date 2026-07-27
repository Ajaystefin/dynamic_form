import "package:connectivity_plus/connectivity_plus.dart";
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
import "package:wcas_frontend/features/request/information/present_request/model.dart";
import "package:wcas_frontend/features/request/information/present_request/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockDraftRepository extends Mock implements DraftRepository {}

class MockBuildContext extends Mock implements BuildContext {}

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
  );

  const MethodChannel oldConnectivityChannel = MethodChannel(
    "plugins.flutter.io/connectivity",
  );

  late PresentRequestViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlertManager;
  late MockDraftRepository mockDraftRepository;
  late MockLocalStorageService mockLocalStorageService;

  PresentRequestViewModel createViewModel({
    bool isEdit = true,
  }) {
    return PresentRequestViewModel()
      ..repository = mockRequestRepository
      ..repositoryCommon = mockCommonRepository
      ..isEdit = isEdit;
  }

  void stubConnectivity() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return [ConnectivityResult.wifi.name];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      oldConnectivityChannel,
      (MethodCall call) async {
        return "wifi";
      },
    );
  }

  void stubDraftRepository() {
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
  }

  setUpAll(() async {
    await EnvConfig.setEnvironment();

    registerFallbackValue(CommentsType.presentRequest);
    registerFallbackValue(EntityIdentifier.presentRequest);
    registerFallbackValue(Comment());
  });

  setUp(() {
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockAlertManager = MockAlertManager();
    mockDraftRepository = MockDraftRepository();
    mockLocalStorageService = MockLocalStorageService();

    CommonRepository.overrideInstance = mockCommonRepository;
    AlertManager.overrideInstance = mockAlertManager;
    DraftRepository.overrideInstance = mockDraftRepository;
    LocalStorageService().getStorage = mockLocalStorageService;

    stubConnectivity();
    stubDraftRepository();

    when(
      () => mockCommonRepository.getApplicationStrategyDetails(
        any(),
        any(),
      ),
    ).thenAnswer((_) async => []);

    when(
      () => mockCommonRepository.saveApplicationStrategyDetails(
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((_) async => "Saved");

    viewModel = createViewModel();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(oldConnectivityChannel, null);

    if (!viewModel.isClosed) {
      await viewModel.close();
    }
  });

  group("PresentRequestState", () {
    test("constructor stores loaderStatus", () {
      final state = PresentRequestState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith preserves existing values when nothing is passed", () {
      final state = PresentRequestState(
        loaderStatus: LoadingStatus.loaded,
        isButtonLoading: true,
      );

      final copied = state.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.isButtonLoading, true);
    });

    test("copyWith overrides loaderStatus only", () {
      final state = PresentRequestState(
        loaderStatus: LoadingStatus.loading,
        isButtonLoading: true,
      );

      final copied = state.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(copied.loaderStatus, LoadingStatus.error);
      expect(copied.isButtonLoading, true);
    });

    test("copyWith overrides isButtonLoading only", () {
      final state = PresentRequestState(
        loaderStatus: LoadingStatus.loading,
        isButtonLoading: true,
      );

      final copied = state.copyWith(
        isButtonLoading: false,
      );

      expect(copied.loaderStatus, LoadingStatus.loading);
      expect(copied.isButtonLoading, false);
    });

    test("copyWith overrides all values", () {
      final state = PresentRequestState(
        loaderStatus: LoadingStatus.loading,
        isButtonLoading: true,
      );

      final copied = state.copyWith(
        loaderStatus: LoadingStatus.error,
        isButtonLoading: false,
      );

      expect(copied.loaderStatus, LoadingStatus.error);
      expect(copied.isButtonLoading, false);
    });
  });

  group("Initial values and draft config", () {
    test("initial loaderStatus is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("initial comments list is empty", () {
      expect(viewModel.comments, isEmpty);
    });

    test("initial comment object exists", () {
      expect(viewModel.comment, isA<Comment>());
    });

    test("canEdit returns true when isEdit is true", () {
      viewModel.isEdit = true;

      expect(viewModel.canEdit, isTrue);
    });

    test("canEdit returns false when isEdit is false", () {
      viewModel.isEdit = false;

      expect(viewModel.canEdit, isFalse);
    });

    test("draftModuleKey returns requestInformation", () {
      expect(
        viewModel.draftModuleKey,
        DraftModuleKeys.requestInformation,
      );
    });

    test("draftFormKey returns presentRequest route", () {
      expect(
        viewModel.draftFormKey,
        Routes.presentRequest,
      );
    });

    test("draftHandler returns handler instance", () {
      expect(viewModel.draftHandler, isNotNull);
    });
  });

  group("init", () {
    test("init loads strategy details, draft and sets loaderStatus loaded",
        () async {
      final comments = [
        Comment(
          categoryId: ServerConstants.presentRequestCategoryID,
          strategyComment: "Initial strategy",
        ),
      ];

      when(
        () => mockCommonRepository.getApplicationStrategyDetails(
          CommentsType.presentRequest,
          EntityIdentifier.presentRequest,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.init(MockBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.comments?.first.strategyComment, "Initial strategy");

      verify(
        () => mockDraftRepository.getDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      ).called(1);
    });
  });

  group("getApplicationStrategyDetails", () {
    test("sets first comment strategyComment from matching category", () async {
      final commentList = [
        Comment(
          categoryId: 12,
          strategyComment: "Other",
        ),
        Comment(
          categoryId: ServerConstants.presentRequestCategoryID,
          strategyComment: "Strategy A",
        ),
      ];

      when(
        () => mockCommonRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => commentList);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments?.first.strategyComment, "Strategy A");
    });

    test("sets first comment strategyComment empty when category does not match",
        () async {
      final commentList = [
        Comment(
          categoryId: 999,
          strategyComment: "Other",
        ),
      ];

      when(
        () => mockCommonRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => commentList);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments?.first.strategyComment, "");
    });

    test("keeps empty comments when repository returns empty list", () async {
      when(
        () => mockCommonRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isEmpty);
    });

    test("handles repository exception gracefully", () async {
      when(
        () => mockCommonRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenThrow(Exception("Fetch failed"));

      await viewModel.getApplicationStrategyDetails();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("syncCommentFromController", () {
    test("updates comment strategyComment", () {
      viewModel..comment = Comment(strategyComment: "Old")
      ..comments = []

      ..syncCommentFromController("New value");

      expect(viewModel.comment.strategyComment, "New value");
    });

    test("updates first comment when comments list is not empty", () {
      viewModel..comment = Comment(strategyComment: "Old")
      ..comments = [
        Comment(strategyComment: "Old list value"),
      ]

      ..syncCommentFromController("Updated list value");

      expect(viewModel.comment.strategyComment, "Updated list value");
      expect(
        viewModel.comments?.first.strategyComment,
        "Updated list value",
      );
    });

    test("does not crash when comments is null", () {
      viewModel..comment = Comment(strategyComment: "Old")
      ..comments = null

      ..syncCommentFromController("Value");

      expect(viewModel.comment.strategyComment, "Value");
      expect(viewModel.comments, isNull);
    });
  });

  group("onSaveButtonPressed", () {
    test("saves comment when not editable because validation is bypassed",
        () async {
      viewModel
        ..isEdit = false
        ..formKey = GlobalKey<FormState>()
        ..comment = Comment(
          id: 101,
          strategyComment: "Saved Comment",
        )
        ..comments = [
          Comment(strategyComment: "Saved Comment"),
        ];

      when(
        () => mockCommonRepository.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "Saved");

      when(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      ).thenAnswer((_) async {});

      await viewModel.onSaveButtonPressed();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isButtonLoading, false);

      verify(
        () => mockCommonRepository.saveApplicationStrategyDetails(
          ServerConstants.presentRequestStrategyCommentsType,
          ServerConstants.presentRequestAppStrategyCommentsId,
          any(),
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);

      verify(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      ).called(1);
    });

    test("does not save when editable and form currentState is null", () async {
      viewModel
        ..isEdit = true
        ..formKey = GlobalKey<FormState>()
        ..comment = Comment(strategyComment: "Invalid")
        ..comments = [
          Comment(strategyComment: "Invalid"),
        ];

      await viewModel.onSaveButtonPressed();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isButtonLoading, false);

      verifyNever(
        () => mockCommonRepository.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      );

      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );

      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("handles save exception and sets loaderStatus error", () async {
      viewModel
        ..isEdit = false
        ..formKey = GlobalKey<FormState>()
        ..comment = Comment(strategyComment: "Error Comment")
        ..comments = [
          Comment(strategyComment: "Error Comment"),
        ];

      when(
        () => mockCommonRepository.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Save failed"));

      await viewModel.onSaveButtonPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      expect(viewModel.state.isButtonLoading, false);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );
    });
  });

  group("close", () {
    test("close completes without error", () async {
      final vm = createViewModel();

      await vm.close();

      expect(vm.isClosed, isTrue);
    });
  });
}
