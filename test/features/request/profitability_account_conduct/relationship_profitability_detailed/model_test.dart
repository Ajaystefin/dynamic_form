// relationship_profitability_detailed_test.dart
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

import "../../approval/group_position/model_test.dart";

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

// Mock LocalStorageService
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
  late RelationshipProfitabilityDetailedViewModel viewModel;
  late MockProfitabilityRepository mockRepo;
  late MockCommonRepository mockCommonRepo;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;

  // Stub connectivity_plus channel so every check() returns wifi
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Fallbacks for mocktail when matching complex args
    registerFallbackValue(
      CommentsType.relationshipProfitabilityDetailed,
    ); // - updated
    registerFallbackValue(
      EntityIdentifier.relationshipProfitabilityDetailed,
    ); // - updated
    registerFallbackValue(Comment());
    registerFallbackValue(RelationshipProfitabilityDetailed());

    await EnvConfig.setEnvironment();
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

  setUp(() {
    mockRepo = MockProfitabilityRepository();
    mockCommonRepo = MockCommonRepository();
    mockAlertManager = MockAlertManager();

    // Create VM
    viewModel = RelationshipProfitabilityDetailedViewModel();

    // Override singletons/instances
    ProfitabilityRepository.overrideInstance(mockRepo);
    CommonRepository.overrideInstance(mockCommonRepo);
    AlertManager.overrideInstance(mockAlertManager);

    // Local storage mock
    mockLocalStorageService = MockLocalStorageService();
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
        return "wifi";
      },
    );
  });

  test("Initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  // -----------------------------
  // saveComments()
  // -----------------------------
  group("saveComments()", () {
    test("success path shows success toast (stay on page)", () async {
      // simulate user input bound to strategyComment
      CommonRepository.overrideInstance(mockCommonRepo);

      viewModel.strategyComment = "My strategy";

      // - uses relationshipProfitabilityDetailed type ids
      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          ServerConstants
              .commentTypeId[CommentsType.relationshipProfitabilityDetailed]!,
          ServerConstants.commentTypeId[CommentsType
              .relationshipProfitabilityDetailed]!, // API requires same twice
          any(that: isA<Comment>()),
        ),
      ).thenAnswer((_) async => "Saved");
      await viewModel.saveComments();

      verify(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          ServerConstants
              .commentTypeId[CommentsType.relationshipProfitabilityDetailed]!,
          ServerConstants
              .commentTypeId[CommentsType.relationshipProfitabilityDetailed]!,
          any(that: isA<Comment>()),
        ),
      ).called(
        1,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)

      verify(() => mockAlertManager.showSuccessToast("Saved")).called(
        1,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)
    });

    test("error path shows failure toast", () async {
      // Arrange
      AlertManager.overrideInstance(mockAlertManager);
      CommonRepository.overrideInstance(mockCommonRepo);

      // Sanity: singleton points to the mock
      expect(CommonRepository.instance, equals(mockCommonRepo));

      viewModel.strategyComment = "Bad strategy";

      // Stub via the singleton that VM calls
      when(
        () => CommonRepository.instance.saveApplicationStrategyDetails(
          any<int>(), // first type id
          any<int>(), // second type id
          any<Comment>(), // comment payload
        ),
      ).thenThrow(Exception("Boom"));

      // Act
      await viewModel.saveComments();

      // Assert
      verify(() => mockAlertManager.showFailureToast("Exception: Boom"))
          .called(1);
    });

    test("isContinue triggers navigation to next route", () async {
      // Arrange
      AlertManager.overrideInstance(mockAlertManager);
      CommonRepository.overrideInstance(mockCommonRepo);

      expect(CommonRepository.instance, equals(mockCommonRepo)); // sanity check

      viewModel.strategyComment = "Proceed";

      // Stub via the singleton to avoid instance mismatches
      when(
        () => CommonRepository.instance.saveApplicationStrategyDetails(
          any<int>(), // first type id
          any<int>(), // second type id (same id per VM)
          any<Comment>(), // comment payload
        ),
      ).thenAnswer((_) async => "Saved");

      // Act
      await viewModel.saveComments(isContinue: true);

      // Assert
      verify(() => mockAlertManager.showSuccessToast("Saved")).called(1);

      // Note: LayoutViewModel().goToNextRoute() creates a new instance inline,
      // so it’s not trivially mockable unless you add an override/injection.
      // If you introduce LayoutViewModel.overrideInstance(mockLayout), verify
      // it here.
    });
  });

  // -----------------------------
  // init()
  // -----------------------------
  group("init()", () {
    test("loads data and emits loaded state", () async {
      final mockData = <RelationshipProfitabilityDetailed>[];
      final mockComments = <Comment>[
        Comment(
          categoryId: ServerConstants
              .relationshipProfitabilityDetailedCommentCategoryId, // - updated
          strategyComment: "Existing strategy",
        ),
      ];

      when(() => mockRepo.getRelationProfitDetData()).thenAnswer(
        (_) async => mockData,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.relationshipProfitabilityDetailed, // - updated
          EntityIdentifier.relationshipProfitabilityDetailed, // - updated
        ),
      ).thenAnswer(
        (_) async => mockComments,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)

      await viewModel.init(TestBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.relProfitDet, isEmpty);
      expect(
        viewModel.strategyComment,
        "Existing strategy",
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)
    });

    test("init() handles error", () async {
      // Arrange: make sure singletons point to your mocks
      AlertManager.overrideInstance(mockAlertManager);
      ProfitabilityRepository.overrideInstance(mockRepo);
      CommonRepository.overrideInstance(mockCommonRepo);

      // Sanity checks
      expect(CommonRepository.instance, equals(mockCommonRepo));
      expect(ProfitabilityRepository.instance, equals(mockRepo));

      // First call (profitability data) throws → VM should go to error path
      when(() => mockRepo.getRelationProfitDetData())
          .thenThrow(Exception("Load failed"));

      // The comments call won’t be reached, but it’s fine to keep a safe stub.
      // IMPORTANT: stub via the singleton AND use the same enums the VM uses.
      when(
        () => CommonRepository.instance.getApplicationStrategyDetails(
          CommentsType.relationshipProfitabilityDetailed,
          EntityIdentifier.relationshipProfitabilityDetailed,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      // Act
      await viewModel.init(TestBuildContext());

      // Assert
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      verify(() => mockAlertManager.showFailureToast("Exception: Load failed"))
          .called(1);
    });
  });

  // -----------------------------
  // getComments()
  // -----------------------------
  group("getComments()", () {
    test("fetches comments successfully and updates strategyComment", () async {
      final mockComments = <Comment>[
        Comment(
          categoryId: ServerConstants
              .relationshipProfitabilityDetailedCommentCategoryId, // - updated
          strategyComment: "Strategy A",
        ),
        Comment(
          categoryId: 999, // ignored
          strategyComment: "Other",
        ),
      ];

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.relationshipProfitabilityDetailed, // - updated
          EntityIdentifier.relationshipProfitabilityDetailed, // - updated
        ),
      ).thenAnswer(
        (_) async => mockComments,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)

      await viewModel.getComments();

      expect(
        viewModel.strategyComment,
        "Strategy A",
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("fetches comments returns empty; strategyComment becomes empty string",
        () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.relationshipProfitabilityDetailed, // - updated
          EntityIdentifier.relationshipProfitabilityDetailed, // - updated
        ),
      ).thenAnswer(
        (_) async => <Comment>[],
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)

      await viewModel.getComments();

      // - ViewModel sets '' (empty string), not null
      expect(
        viewModel.strategyComment,
        "",
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("fetches comments error case sets error state", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.relationshipProfitabilityDetailed, // - updated
          EntityIdentifier.relationshipProfitabilityDetailed, // - updated
        ),
      ).thenThrow(
        Exception(
          "Fetch failed",
        ),
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)

      await viewModel.getComments();

      expect(
        viewModel.state.loaderStatus,
        LoadingStatus.error,
      ); // [1](https://cbddxb-my.sharepoint.com/personal/chr15616_cbd_ae/Documents/Microsoft%20Copilot%20Chat%20Files/model_test.dart)
    });
  });

  // -----------------------------
  // RelationshipProfitabilityDetailedState
  // -----------------------------
  group("RelationshipProfitabilityDetailedState", () {
    test("constructor sets loaderStatus", () {
      final state = RelationshipProfitabilityDetailedState(
        loaderStatus: LoadingStatus.loading,
      );
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = RelationshipProfitabilityDetailedState(
        loaderStatus: LoadingStatus.loaded,
      );
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = RelationshipProfitabilityDetailedState(
        loaderStatus: LoadingStatus.loaded,
      );
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  // -----------------------------
  // Additional validation (optional)
  // ----------------------------
}
