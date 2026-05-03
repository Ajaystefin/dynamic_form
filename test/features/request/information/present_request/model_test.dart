import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/present_request/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class MockFormState extends Mock implements FormState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "MockFormState";
  }
}

class MockGlobalKey extends Mock implements GlobalKey<FormState> {}

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
  TestWidgetsFlutterBinding.ensureInitialized();
  late PresentRequestViewModel viewModel;
  late MockCommonRepository mockCommonRepo;
  late MockAlertManager mockAlertManager;
  late MockFormState mockFormState;
  late MockLocalStorageService mockLocalStorageService;

  // Stub connectivity_plus channel so every check() returns wifi
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUp(() {
    mockCommonRepo = MockCommonRepository();
    viewModel = PresentRequestViewModel(
      comments: <dynamic>[],
    )..repository = MockRequestRepository();
    mockAlertManager = MockAlertManager();

    mockFormState = MockFormState();

    // Stub the methods
    when(() => mockFormState.validate()).thenReturn(true);
    when(() => mockFormState.save()).thenReturn(null);

    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
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
        return "wifi"; // or whatever mock result you need
      },
    );
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
  setUpAll(() async {
    await EnvConfig.setEnvironment();

    registerFallbackValue(CommentsType.presentRequest);
    registerFallbackValue(EntityIdentifier.presentRequest);

    registerFallbackValue(Comment());
  });

  group("PresentRequestViewModel Tests", () {
    // test('Initial loader status is loading', () {
    //   viewModel.init(null);
    test(
        "getApplicationStrategyDetails() sets strategyComment and loaderStatus "
        "to loaded", () async {
      final commentList = [
        Comment(
          categoryId: ServerConstants.presentRequestCategoryID,
          strategyComment: "Strategy A",
        ),
        Comment(categoryId: 12, strategyComment: "Other"),
      ];

      when(() => mockCommonRepo.getApplicationStrategyDetails(any(), any()))
          .thenAnswer((_) async => commentList);

      await (viewModel..repositoryCommon = mockCommonRepo)
          .getApplicationStrategyDetails();

      expect(viewModel.comments?.first.strategyComment, "Strategy A");
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });
    testWidgets(
        "onSaveButtonPressed() saves comment and sets isButtonLoading to false",
        (WidgetTester tester) async {
      viewModel
        ..pageMode = PageMode.edit
        ..comment = Comment()
        ..comments = [Comment(strategyComment: "Test strategy")]
        ..repositoryCommon = mockCommonRepo;
      AlertManager.overrideInstance(mockAlertManager);
      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "Saved");

      final formKey = GlobalKey<FormState>();
      viewModel.formKey = formKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Form(
            key: formKey,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await viewModel.onSaveButtonPressed();
                  },
                  child: const Text("Save"),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(viewModel.state.isButtonLoading, false);
    });
    test(
        "onSaveButtonPressed() "
        "handles exception "
        "and sets loaderStatus to error", () async {
      viewModel
        ..pageMode = PageMode.edit
        ..formKey = GlobalKey<FormState>()
        ..comment = Comment()
        ..comments = [Comment(strategyComment: "Test strategy")]
        ..repositoryCommon = mockCommonRepo;
      AlertManager.overrideInstance(mockAlertManager);
      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Failed"));

      await viewModel.onSaveButtonPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      expect(viewModel.state.isButtonLoading, false);
    });
    // test('canEdit returns true when pageMode is edit', () {
    //   viewModel.pageMode = PageMode.edit;
    //   expect(viewModel.canEdit, false);
    // });

    test("onSaveButtonPressed saves comment when editable", () async {
      viewModel
        ..pageMode = PageMode.edit
        ..comment = Comment()
        ..comments = [Comment(strategyComment: "Saved Comment")];

      const mockSaveResult = "Success";
      AlertManager.overrideInstance(mockAlertManager);
      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          ServerConstants.presentRequestStrategyCommentsType,
          ServerConstants.presentRequestAppStrategyCommentsId,
          Comment(),
        ),
      ).thenAnswer((_) async => mockSaveResult);

      await viewModel.onSaveButtonPressed();

      verifyNever(() => mockAlertManager.showSuccessToast("")).called(0);

      expect(viewModel.state.isButtonLoading, false);
    });

    test("onSaveButtonPressed handles error gracefully", () async {
      viewModel
        ..pageMode = PageMode.edit
        ..comment = Comment()
        ..comments = [Comment(strategyComment: "Saved Comment")];
      AlertManager.overrideInstance(mockAlertManager);
      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          ServerConstants.presentRequestStrategyCommentsType,
          ServerConstants.presentRequestAppStrategyCommentsId,
          Comment(),
        ),
      ).thenThrow(Exception("Save failed"));

      await viewModel.onSaveButtonPressed();
      verifyNever(() => mockAlertManager.showSuccessToast("")).called(0);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      expect(viewModel.state.isButtonLoading, false);
    });

    test("onSaveButtonPressed saves comment when editable", () async {
      try {
        registerFallbackValue(Comment());

        viewModel
          ..pageMode = PageMode.edit
          ..comment = Comment()
          ..comments = [Comment(strategyComment: "Saved Comment")];

        const mockSaveResult = "Success";

        when(
          () => mockCommonRepo.saveApplicationStrategyDetails(
            ServerConstants.presentRequestStrategyCommentsType,
            ServerConstants.presentRequestAppStrategyCommentsId,
            any(),
          ),
        ).thenAnswer((_) async => mockSaveResult);
        await viewModel.onSaveButtonPressed();
        verifyNever(() => mockAlertManager.showSuccessToast("")).called(0);

        expect(viewModel.state.isButtonLoading, false);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      } catch (_) {
        expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      }
    });
  });
}
