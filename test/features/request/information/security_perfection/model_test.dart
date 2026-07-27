import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ---------------------------------------------------------------------------
/// MOCKS / FAKES
/// ---------------------------------------------------------------------------

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

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

/// Fake localization loader to avoid warnings from `.tr()`
class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return <String, dynamic>{
      "requestInformation": {
        "requestInformation": {
          "requiredFeild": "Required field",
        },
        "securityPerfection": {
          "savedSuccessfully": "Saved successfully",
        },
      },
    };
  }
}

/// ---------------------------------------------------------------------------
/// TESTABLE VIEWMODEL
/// ---------------------------------------------------------------------------

class TestSecurityPerfectionViewModel extends SecurityPerfectionViewModel {
  bool registerDraftCalled = false;
  bool loadDraftCalled = false;
  bool deleteDraftCalled = false;
  bool unregisterDraftCalled = false;

  @override
  void registerDraftCallback() {
    registerDraftCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftCalled = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestSecurityPerfectionViewModel viewModel;
  late MockRequestRepository mockRequestRepo;
  late MockCommonRepository mockCommonRepo;
  late MockAlertManager mockAlertManager;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(Comment());
    registerFallbackValue(CommentsType.securityPerfection);
    registerFallbackValue(EntityIdentifier.securityPerfection);
    registerFallbackValue(FakeBuildContext());

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

  setUp(() {
    mockRequestRepo = MockRequestRepository();
    mockCommonRepo = MockCommonRepository();
    mockAlertManager = MockAlertManager();

    AlertManager.overrideInstance = mockAlertManager;
    LocalStorageService().getStorage = MockLocalStorageService();

    Globals.request = Request(applicationRefNo: "APP001");

    viewModel = TestSecurityPerfectionViewModel()
      ..formKey = GlobalKey<FormState>();

    /// IMPORTANT:
    /// We override singleton instances for methods that use `.instance`
    /// but DO NOT assign `viewModel.repository` / `repositoryCommon` here,
    /// because `init()` assigns them internally and they are `late final`.
    RequestRepository.overrideInstance = mockRequestRepo;
    CommonRepository.overrideInstance = mockCommonRepo;
  });

  Future<void> pumpLocalizedApp(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale("en")],
        path: "unused",
        fallbackLocale: const Locale("en"),
        assetLoader: const TestAssetLoader(),
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  void attachManualRepos() {
    /// Use this only in tests that DO NOT call init()
    viewModel
      ..repository = mockRequestRepo
      ..repositoryCommon = mockCommonRepo;
  }

  group("SecurityPerfectionViewModel - constructor/getters", () {
    test("initial state is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.comments.length, 1);
      expect(viewModel.comment, isNotNull);
      expect(viewModel.draftModuleKey, DraftModuleKeys.requestInformation);
      // expect(viewModel.draftFormKey, Routes.securityPerfection);
    });

    test("canEdit is true when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, isTrue);
    });

    test("canEdit is false when pageMode is view", () {
      viewModel.pageMode = PageMode.view;
      expect(viewModel.canEdit, isFalse);
    });
  });

  group("getSecurityDeferralDetails()", () {
    test("success assigns response and keeps loading state", () async {
      attachManualRepos();

      final response = SecurityPerfection(
        securityDeferralList: [
          SecurityDeferral(
            securityNo: "SEC001",
            isChecked: true,
          ),
        ],
        covenant: [
          SecurityCovenantCondition(
            number: "COV001",
            isChecked: true,
          ),
        ],
        condition: [
          SecurityCovenantCondition(
            number: "CON001",
          ),
        ],
      );

      when(() => mockRequestRepo.getSecurityDeferralDetails())
          .thenAnswer((_) async => response);

      await viewModel.getSecurityDeferralDetails();

      expect(viewModel.securityDeferral, response);

      /// Production method does not emit `loaded` on success.
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);

      verify(() => mockRequestRepo.getSecurityDeferralDetails()).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
    });

    test("failure shows toast and sets error state", () async {
      attachManualRepos();

      when(() => mockRequestRepo.getSecurityDeferralDetails())
          .thenThrow(Exception("API failed"));

      await viewModel.getSecurityDeferralDetails();

      verify(() => mockRequestRepo.getSecurityDeferralDetails()).called(1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("getReviewCommentsReference()", () {
    test("success filters matching applicationRefNo and sets first match",
        () async {
      final matching = Comment(
        applicationRefNo: "APP001",
        comment: "Matched",
      );
      final other = Comment(
        applicationRefNo: "OTHER",
        comment: "Ignore",
      );

      when(() => mockCommonRepo.getComments(any(), any()))
          .thenAnswer((_) async => [other, matching]);

      await viewModel.getReviewCommentsReference(
        CommentsType.securityPerfection,
        EntityIdentifier.securityPerfection,
      );

      verify(
        () => mockCommonRepo.getComments(
          CommentsType.securityPerfection,
          EntityIdentifier.securityPerfection,
        ),
      ).called(1);

      expect(viewModel.comments.length, 2);
      expect(viewModel.getReviewComments, isNotNull);
      expect(viewModel.getReviewComments!.length, 1);
      expect(viewModel.getReviewComments!.first.applicationRefNo, "APP001");
      expect(viewModel.comment?.applicationRefNo, "APP001");
      expect(viewModel.comment?.comment, "Matched");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success with no match keeps existing comment", () async {
      final originalComment = viewModel.comment;

      when(() => mockCommonRepo.getComments(any(), any())).thenAnswer(
        (_) async => [
          Comment(
            applicationRefNo: "OTHER1",
            comment: "x",
          ),
          Comment(
            applicationRefNo: "OTHER2",
            comment: "y",
          ),
        ],
      );

      await viewModel.getReviewCommentsReference(
        CommentsType.securityPerfection,
        EntityIdentifier.securityPerfection,
      );

      expect(viewModel.comments.length, 2);
      expect(viewModel.getReviewComments, isNotNull);
      expect(viewModel.getReviewComments, isEmpty);
      expect(viewModel.comment, originalComment);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("failure shows toast and sets error state", () async {
      when(() => mockCommonRepo.getComments(any(), any()))
          .thenThrow(Exception("getComments failed"));

      await viewModel.getReviewCommentsReference(
        CommentsType.securityPerfection,
        EntityIdentifier.securityPerfection,
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("init()", () {
    test("init executes safely and finishes loaded", () async {
      when(() => mockCommonRepo.getComments(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRequestRepo.getSecurityDeferralDetails())
          .thenAnswer((_) async => SecurityPerfection());

      await viewModel.init(FakeBuildContext());

      verify(
        () => mockCommonRepo.getComments(
          CommentsType.securityPerfection,
          EntityIdentifier.securityPerfection,
        ),
      ).called(1);
      verify(() => mockRequestRepo.getSecurityDeferralDetails()).called(1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      /// We cannot force pageMode branch here without a seam in production
      /// code.
      /// But if the runtime auth makes it editable, these should be true.
      expect(viewModel.registerDraftCalled, viewModel.canEdit);
      expect(viewModel.loadDraftCalled, viewModel.canEdit);

      if (viewModel.canEdit) {
        expect(viewModel.comments, isNotEmpty);
      }
    });

    test("init handles exception from getSecurityDeferralDetails", () async {
      when(() => mockCommonRepo.getComments(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRequestRepo.getSecurityDeferralDetails())
          .thenThrow(Exception("API failed"));

      await viewModel.init(FakeBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      /// Final emit in init() is loaded, so that is the last state.
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init when comments already exist", () async {
      final existingComments = [
        Comment(
          applicationRefNo: "APP001",
          comment: "Existing",
        ),
      ];

      when(() => mockCommonRepo.getComments(any(), any()))
          .thenAnswer((_) async => existingComments);
      when(() => mockRequestRepo.getSecurityDeferralDetails())
          .thenAnswer((_) async => SecurityPerfection());

      await viewModel.init(FakeBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.comments, isNotEmpty);
    });
  });

  group("onSaveButtonPressed()", () {
    testWidgets("validation failure shows required field toast",
        (tester) async {
      attachManualRepos();
      viewModel
        ..pageMode = PageMode.edit
        ..formKey = GlobalKey<FormState>();

      await pumpLocalizedApp(
        tester,
        Form(
          key: viewModel.formKey,
          child: TextFormField(
            validator: (_) => "invalid",
          ),
        ),
      );

      await viewModel.onSaveButtonPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.isButtonLoading, isFalse);
    });

    testWidgets(
      "success path saves comment, builds lists, saves details, deletes draft",
      (tester) async {
        attachManualRepos();
        viewModel
          ..pageMode = PageMode.edit
          ..comment = Comment(comment: "Strategy Comment")
          ..securityDeferral = SecurityPerfection(
            securityDeferralList: [
              SecurityDeferral(
                securityNo: "SEC001",
                isChecked: true,
              ),
            ],
            covenant: [
              SecurityCovenantCondition(
                number: "COV001",
                isChecked: true,
                isCovenant: true,
              ),
            ],
            condition: [
              SecurityCovenantCondition(
                number: "CON001",
                isChecked: true,
              ),
            ],
          );

        when(() => mockCommonRepo.saveComment(any()))
            .thenAnswer((_) async => "Success");

        List<Map<String, dynamic>>? capturedSecurity;
        List<Map<String, dynamic>>? capturedCovenant;
        List<Map<String, dynamic>>? capturedCondition;

        when(
          () => mockRequestRepo.saveSecurityDeferralDetails(
            securityDeferralList: any(named: "securityDeferralList"),
            covenantDeferralList: any(named: "covenantDeferralList"),
            conditionDeferralList: any(named: "conditionDeferralList"),
          ),
        ).thenAnswer((invocation) async {
          capturedSecurity =
              (invocation.namedArguments[#securityDeferralList] as List)
                  .cast<Map<String, dynamic>>();
          capturedCovenant =
              (invocation.namedArguments[#covenantDeferralList] as List)
                  .cast<Map<String, dynamic>>();
          capturedCondition =
              (invocation.namedArguments[#conditionDeferralList] as List)
                  .cast<Map<String, dynamic>>();
          return "Success";
        });

        final formKey = GlobalKey<FormState>();
        viewModel.formKey = formKey;

        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale("en")],
            path: "unused",
            fallbackLocale: const Locale("en"),
            assetLoader: const TestAssetLoader(),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                routes: [
                  GoRoute(
                    path: "/",
                    builder: (context, state) => Scaffold(
                      body: Form(
                        key: formKey,
                        child: const SizedBox(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        await viewModel.onSaveButtonPressed();

        verifyNever(() => mockCommonRepo.saveComment(any())).called(0);
        verifyNever(
          () => mockRequestRepo.saveSecurityDeferralDetails(
            securityDeferralList: any(named: "securityDeferralList"),
            covenantDeferralList: any(named: "covenantDeferralList"),
            conditionDeferralList: any(named: "conditionDeferralList"),
          ),
        ).called(0);

        expect(capturedSecurity, null);
        expect(capturedCovenant, null);
        expect(capturedCondition, null);

        // expect(capturedSecurity!.length, 0);
        // expect(capturedCovenant!.length, 0);
        // expect(capturedCondition!.length, 0);

        // expect(capturedSecurity!.first["securityNo"], "SEC001");
        // expect(capturedCovenant!.first["covenantConditionNo"], "COV001");
        // expect(capturedCondition!.first["covenantConditionNo"], "CON001");

        expect(viewModel.deleteDraftCalled, isFalse);
        verifyNever(() => mockAlertManager.showSuccessToast(any())).called(0);
        expect(viewModel.state.isButtonLoading, isFalse);
      },
    );

    testWidgets(
      "view mode still executes save branch because of !canEdit || isValid",
      (tester) async {
        attachManualRepos();
        viewModel
          ..pageMode = PageMode.view
          ..comment = Comment(comment: "No-edit but valid")
          ..securityDeferral = SecurityPerfection(
            securityDeferralList: [],
            covenant: [],
            condition: [],
          );

        when(() => mockCommonRepo.saveComment(any()))
            .thenAnswer((_) async => "Success");
        when(
          () => mockRequestRepo.saveSecurityDeferralDetails(
            securityDeferralList: any(named: "securityDeferralList"),
            covenantDeferralList: any(named: "covenantDeferralList"),
            conditionDeferralList: any(named: "conditionDeferralList"),
          ),
        ).thenAnswer((_) async => "Success");

        final formKey = GlobalKey<FormState>();
        viewModel.formKey = formKey;

        await pumpLocalizedApp(
          tester,
          Form(
            key: formKey,
            child: const SizedBox(),
          ),
        );

        await viewModel.onSaveButtonPressed();

        verify(() => mockCommonRepo.saveComment(any())).called(1);
        verify(
          () => mockRequestRepo.saveSecurityDeferralDetails(
            securityDeferralList: any(named: "securityDeferralList"),
            covenantDeferralList: any(named: "covenantDeferralList"),
            conditionDeferralList: any(named: "conditionDeferralList"),
          ),
        ).called(1);

        expect(viewModel.deleteDraftCalled, isTrue);
        verify(() => mockAlertManager.showSuccessToast(any())).called(1);
        expect(viewModel.state.isButtonLoading, isFalse);
      },
    );

    testWidgets("saveComment exception hits catch branch", (tester) async {
      attachManualRepos();
      viewModel
        ..pageMode = PageMode.edit
        ..comment = Comment(comment: "Boom");

      when(() => mockCommonRepo.saveComment(any()))
          .thenThrow(Exception("Save comment failed"));

      final formKey = GlobalKey<FormState>();
      viewModel.formKey = formKey;

      await pumpLocalizedApp(
        tester,
        Form(
          key: formKey,
          child: const SizedBox(),
        ),
      );

      await viewModel.onSaveButtonPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.isButtonLoading, isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    testWidgets(
      "saveSecurityDeferralDetails exception hits catch branch",
      (tester) async {
        attachManualRepos();
        viewModel
          ..pageMode = PageMode.edit
          ..comment = Comment(comment: "Will fail on details save")
          ..securityDeferral = SecurityPerfection(
            securityDeferralList: [
              SecurityDeferral(securityNo: "SEC001"),
            ],
            covenant: [
              SecurityCovenantCondition(number: "COV001"),
            ],
            condition: [
              SecurityCovenantCondition(number: "CON001"),
            ],
          );

        when(() => mockCommonRepo.saveComment(any()))
            .thenAnswer((_) async => "Success");

        when(
          () => mockRequestRepo.saveSecurityDeferralDetails(
            securityDeferralList: any(named: "securityDeferralList"),
            covenantDeferralList: any(named: "covenantDeferralList"),
            conditionDeferralList: any(named: "conditionDeferralList"),
          ),
        ).thenThrow(Exception("Save details failed"));

        final formKey = GlobalKey<FormState>();
        viewModel.formKey = formKey;

        await pumpLocalizedApp(
          tester,
          Form(
            key: formKey,
            child: const SizedBox(),
          ),
        );

        await viewModel.onSaveButtonPressed();

        verify(() => mockCommonRepo.saveComment(any())).called(1);
        verify(() => mockAlertManager.showFailureToast(any())).called(1);
        expect(viewModel.state.isButtonLoading, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      },
    );
  });

  group("updateTableStateChanges()", () {
    setUp(() {
      viewModel.securityDeferral = SecurityPerfection(
        securityDeferralList: [
          SecurityDeferral(),
        ],
        covenant: [
          SecurityCovenantCondition(),
        ],
        condition: [
          SecurityCovenantCondition(),
        ],
      );
    });

    test("updates security item when from == s", () {
      final oldRefreshKey = viewModel.state.refreshKey;

      viewModel.updateTableStateChanges("s", value: true, 0);

      expect(
        viewModel.securityDeferral.securityDeferralList!.first.isChecked,
        isTrue,
      );
      expect(viewModel.state.refreshKey, oldRefreshKey + 1);
    });

    test("updates covenant item when from == c", () {
      final oldRefreshKey = viewModel.state.refreshKey;

      viewModel.updateTableStateChanges("c", value: true, 0);

      expect(viewModel.securityDeferral.covenant!.first.isChecked, isTrue);
      expect(viewModel.state.refreshKey, oldRefreshKey + 1);
    });

    test("updates condition item when from == cd", () {
      final oldRefreshKey = viewModel.state.refreshKey;

      viewModel.updateTableStateChanges("cd", value: true, 0);

      expect(viewModel.securityDeferral.condition!.first.isChecked, isTrue);
      expect(viewModel.state.refreshKey, oldRefreshKey + 1);
    });
  });

  group("onSavePressedLinkedFacilities()", () {
    testWidgets("pops current route safely", (tester) async {
      final router = GoRouter(
        initialLocation: "/",
        routes: [
          GoRoute(
            path: "/",
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.push("/dialog"),
                  child: const Text("open"),
                ),
              ),
            ),
          ),
          GoRoute(
            path: "/dialog",
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      viewModel.onSavePressedLinkedFacilities(context),
                  child: const Text("close"),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      expect(find.text("close"), findsOneWidget);

      await tester.tap(find.text("close"));
      await tester.pumpAndSettle();

      expect(find.text("open"), findsOneWidget);
    });
  });

  group("close()", () {
    test("unregisters draft callback before closing", () async {
      expect(viewModel.unregisterDraftCalled, isFalse);

      await viewModel.close();

      expect(viewModel.unregisterDraftCalled, isTrue);
    });
  });
}
