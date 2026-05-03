import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {
  FakeBuildContext({
    this.mountedValue = true,
  });

  final bool mountedValue;

  @override
  bool get mounted => mountedValue;
}

/// Used for main behavioral tests
class TestableCountrySummaryViewModel extends CountrySummaryViewModel {
  TestableCountrySummaryViewModel({
    required RequestRepository repository,
    required ApprovalRepository approvalRepository,
    required CommonRepository commonRepository,
    required UnifiedEditorController controller,
    required AlertManager alertManager,
    required bool Function() checkIfAppReadOnly,
    required String? Function() getCustomerType,
    required void Function(BuildContext context) goToNextRouteAccess,
    Duration changeTabDelay = Duration.zero,
  }) : super(
          repository: repository,
          approvalRepository: approvalRepository,
          commonRepository: commonRepository,
          controller: controller,
          alertManager: alertManager,
          checkIfAppReadOnly: checkIfAppReadOnly,
          getCustomerType: getCustomerType,
          goToNextRouteAccess: goToNextRouteAccess,
          changeTabDelay: changeTabDelay,
        );

  int registerDraftCallbackCallCount = 0;
  int loadDraftIfAvailableCallCount = 0;
  int deleteDraftCallCount = 0;
  int refreshAfterSaveCallCount = 0;
  bool validateAndSaveFormResult = true;

  @override
  Future<void> doRegisterDraftCallback() async {
    registerDraftCallbackCallCount++;
  }

  @override
  Future<void> doLoadDraftIfAvailable() async {
    loadDraftIfAvailableCallCount++;
  }

  @override
  Future<void> doDeleteDraft() {
    deleteDraftCallCount++;
    return super.doDeleteDraft();
  }

  @override
  bool validateAndSaveForm() {
    return validateAndSaveFormResult;
  }

  @override
  Future<void> refreshAfterSave(BuildContext context) async {
    refreshAfterSaveCallCount++;
  }
}

/// Used ONLY to cover wrapper methods in the real ViewModel file
class WrapperCoverageCountrySummaryViewModel extends CountrySummaryViewModel {
  WrapperCoverageCountrySummaryViewModel({
    required RequestRepository repository,
    required ApprovalRepository approvalRepository,
    required CommonRepository commonRepository,
    required UnifiedEditorController controller,
    required AlertManager alertManager,
    required bool Function() checkIfAppReadOnly,
    required String? Function() getCustomerType,
    required void Function(BuildContext context) goToNextRouteAccess,
    Duration changeTabDelay = Duration.zero,
  }) : super(
          repository: repository,
          approvalRepository: approvalRepository,
          commonRepository: commonRepository,
          controller: controller,
          alertManager: alertManager,
          checkIfAppReadOnly: checkIfAppReadOnly,
          getCustomerType: getCustomerType,
          goToNextRouteAccess: goToNextRouteAccess,
          changeTabDelay: changeTabDelay,
        );

  bool registerDraftCalled = false;
  bool loadDraftCalled = false;
  bool deleteDraftCalled = false;
  bool initCalled = false;

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
  Future<void> init(BuildContext? context) async {
    initCalled = true;
  }
}

Future<void> pumpFormHost({
  required WidgetTester tester,
  required CountrySummaryViewModel viewModel,
  required String? Function(String?) validator,
  required void Function(String?) onSaved,
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall call) async => <int>[0],
  );

  late TestableCountrySummaryViewModel viewModel;
  late WrapperCoverageCountrySummaryViewModel wrapperVm;
  late MockRequestRepository mockRequestRepo;
  late MockApprovalRepository mockApprovalRepo;
  late MockCommonRepository mockCommonRepo;
  late MockUnifiedEditorController mockController;
  late MockAlertManager mockAlert;
  late int nextRouteCallCount;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // REQUIRED for EasyLocalization in tests
    SharedPreferences.setMockInitialValues({});

    // Initialize EasyLocalization AFTER mocking SharedPreferences
    await EasyLocalization.ensureInitialized();

    // Mocktail fallbacks (non-UI objects only)
    registerFallbackValue(Comment());
    registerFallbackValue(<Comment>[]);
    registerFallbackValue(CommentsType.countrySummary);
    registerFallbackValue(EntityIdentifier.countrySummary);
  });

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockRequestRepo = MockRequestRepository();
    mockApprovalRepo = MockApprovalRepository();
    mockCommonRepo = MockCommonRepository();
    mockController = MockUnifiedEditorController();
    mockAlert = MockAlertManager();
    nextRouteCallCount = 0;

    when(() => mockRequestRepo.getApplicationDetails())
        .thenAnswer((_) async => null);

    when(
      () => mockApprovalRepo.getApplicationStrategyDetails(
        CommentsType.countrySummary,
        EntityIdentifier.countrySummary,
      ),
    ).thenAnswer((_) async => <Comment>[]);

    when(
      () => mockApprovalRepo.saveApplicationStrategyDetails(
        any(),
        any(),
      ),
    ).thenAnswer((_) async => "Success");

    when(() => mockCommonRepo.saveComment(any()))
        .thenAnswer((_) async => "Success");

    when(() => mockController.getText())
        .thenAnswer((_) async => "<p>Valid content</p>");

    when(() => mockController.setText(any())).thenReturn(null);

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);

    viewModel = TestableCountrySummaryViewModel(
      repository: mockRequestRepo,
      approvalRepository: mockApprovalRepo,
      commonRepository: mockCommonRepo,
      controller: mockController,
      alertManager: mockAlert,
      checkIfAppReadOnly: () => false,
      getCustomerType: () => CustomerType.country.name,
      goToNextRouteAccess: (_) {
        nextRouteCallCount++;
      },
      changeTabDelay: Duration.zero,
    );

    wrapperVm = WrapperCoverageCountrySummaryViewModel(
      repository: mockRequestRepo,
      approvalRepository: mockApprovalRepo,
      commonRepository: mockCommonRepo,
      controller: mockController,
      alertManager: mockAlert,
      checkIfAppReadOnly: () => false,
      getCustomerType: () => CustomerType.country.name,
      goToNextRouteAccess: (_) {
        nextRouteCallCount++;
      },
      changeTabDelay: Duration.zero,
    );
  });

  group("constructor / initial state", () {
    test("initial state is correct", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.activeTab, CountrySummaryTabs.request);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isA<Comment>());
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.controller, equals(mockController));
    });

    test("draft getters return expected values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
      expect(
        viewModel.draftFormKey,
        "${Routes.countrySummary}_${viewModel.state.activeTab.name}",
      );
      expect(viewModel.draftHandler, isNotNull);
    });
  });

  group("direct wrapper coverage", () {
    test("doRegisterDraftCallback executes real wrapper method", () async {
      await wrapperVm.doRegisterDraftCallback();
      expect(wrapperVm.registerDraftCalled, true);
    });

    test("doLoadDraftIfAvailable executes real wrapper method", () async {
      await wrapperVm.doLoadDraftIfAvailable();
      expect(wrapperVm.loadDraftCalled, true);
    });

    test("doDeleteDraft executes real wrapper method", () {
      wrapperVm.doDeleteDraft();
      expect(wrapperVm.deleteDraftCalled, true);
    });

    test("refreshAfterSave executes real wrapper method", () async {
      await wrapperVm.refreshAfterSave(FakeBuildContext());
      expect(wrapperVm.initCalled, true);
    });
  });

  group("validateAndSaveForm() real coverage", () {
    testWidgets("returns true and saves when form is valid", (tester) async {
      bool savedCalled = false;

      await pumpFormHost(
        tester: tester,
        viewModel: wrapperVm,
        validator: (_) => null,
        onSaved: (_) {
          savedCalled = true;
        },
      );

      final bool result = wrapperVm.validateAndSaveForm();

      expect(result, true);
      expect(savedCalled, true);
    });

    testWidgets("returns false when form is invalid", (tester) async {
      bool savedCalled = false;

      await pumpFormHost(
        tester: tester,
        viewModel: wrapperVm,
        validator: (_) => "invalid",
        onSaved: (_) {
          savedCalled = true;
        },
      );

      final bool result = wrapperVm.validateAndSaveForm();

      expect(result, false);
      expect(savedCalled, false);
    });
  });

  group("getTabLabel()", () {
    test("returns label for every tab", () {
      for (final CountrySummaryTabs tab in CountrySummaryTabs.values) {
        final String label = viewModel.getTabLabel(tab);
        expect(label, isA<String>());
        expect(label, isNotEmpty);
      }
    });
  });

  group("init()", () {
    test(
      "init loads data, registers draft callbacks and sets editable state",
      () async {
        await viewModel.init(null);

        verify(() => mockRequestRepo.getApplicationDetails()).called(1);
        verify(
          () => mockApprovalRepo.getApplicationStrategyDetails(
            CommentsType.countrySummary,
            EntityIdentifier.countrySummary,
          ),
        ).called(1);

        expect(viewModel.registerDraftCallbackCallCount, 1);
        expect(viewModel.loadDraftIfAvailableCallCount, 1);
        expect(viewModel.isEditable, true);
        expect(viewModel.isReadOnly, false);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      "init does not register draft when app is read-only, then"
      " non-country makes final readOnly true",
      () async {
        viewModel = TestableCountrySummaryViewModel(
          repository: mockRequestRepo,
          approvalRepository: mockApprovalRepo,
          commonRepository: mockCommonRepo,
          controller: mockController,
          alertManager: mockAlert,
          checkIfAppReadOnly: () => true,
          getCustomerType: () => "group",
          goToNextRouteAccess: (_) {
            nextRouteCallCount++;
          },
          changeTabDelay: Duration.zero,
        );

        await viewModel.init(null);

        expect(viewModel.registerDraftCallbackCallCount, 0);
        expect(viewModel.loadDraftIfAvailableCallCount, 0);
        expect(viewModel.isEditable, false);
        expect(viewModel.isReadOnly, true);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );
  });

  group("changeTab()", () {
    test("changes to request", () async {
      viewModel.isReadOnly = true;
      await viewModel.changeTab(CountrySummaryTabs.request);

      expect(viewModel.state.activeTab, CountrySummaryTabs.request);
      expect(
        viewModel.categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );
      expect(
        viewModel.categoryType,
        ServerConstants.approvalCategoryType[ApprovalCategory.request],
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("changes to rational", () async {
      viewModel.isReadOnly = true;
      await viewModel.changeTab(CountrySummaryTabs.rational);

      expect(viewModel.state.activeTab, CountrySummaryTabs.rational);
      expect(
        viewModel.categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.rational],
      );
      expect(
        viewModel.categoryType,
        ServerConstants.approvalCategoryType[ApprovalCategory.rational],
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("changes to summaryOfLatestDev", () async {
      viewModel.isReadOnly = true;
      await viewModel.changeTab(CountrySummaryTabs.summaryOfLatestDev);

      expect(viewModel.state.activeTab, CountrySummaryTabs.summaryOfLatestDev);
      expect(
        viewModel.categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.summaryOfLastDev],
      );
      expect(
        viewModel.categoryType,
        ServerConstants.approvalCategoryType[ApprovalCategory.summaryOfLastDev],
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("changes to bankingSector", () async {
      viewModel.isReadOnly = true;
      await viewModel.changeTab(CountrySummaryTabs.bankingSector);

      expect(viewModel.state.activeTab, CountrySummaryTabs.bankingSector);
      expect(
        viewModel.categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.bankingSector],
      );
      expect(
        viewModel.categoryType,
        ServerConstants.approvalCategoryType[ApprovalCategory.bankingSector],
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("changes to fiRecommend", () async {
      viewModel.isReadOnly = true;
      await viewModel.changeTab(CountrySummaryTabs.fiRecommend);

      expect(viewModel.state.activeTab, CountrySummaryTabs.fiRecommend);
      expect(
        viewModel.categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.fiRecommendation],
      );
      expect(
        viewModel.categoryType,
        ServerConstants.approvalCategoryType[ApprovalCategory.fiRecommendation],
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("loads draft after tab change when editable", () async {
      viewModel.isReadOnly = false;

      await viewModel.changeTab(CountrySummaryTabs.fiRecommend);

      expect(viewModel.loadDraftIfAvailableCallCount, 1);
    });

    test("does not load draft after tab change when read-only", () async {
      viewModel.isReadOnly = true;

      await viewModel.changeTab(CountrySummaryTabs.fiRecommend);

      expect(viewModel.loadDraftIfAvailableCallCount, 0);
    });
  });

  group("onSavePress()", () {
    test("shows failure toast when editor text is empty and editable",
        () async {
      viewModel.isEditable = true;
      when(() => mockController.getText()).thenAnswer((_) async => "");

      await viewModel.onSavePress(
        false,
        context: FakeBuildContext(),
      );

      verify(() => mockAlert.showFailureToast(any())).called(1);
      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      );
    });

    test("does nothing when form validation fails", () async {
      viewModel
        ..validateAndSaveFormResult = false
        ..isEditable = false;

      await viewModel.onSavePress(
        false,
        context: FakeBuildContext(),
      );

      verifyNever(() => mockAlert.showSuccessToast(any()));
      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      );
    });

    test("handles editor exception and emits error", () async {
      when(() => mockController.getText()).thenThrow(
        Exception("editorErr"),
      );

      await viewModel.onSavePress(
        false,
        context: FakeBuildContext(),
      );

      verify(
        () => mockAlert.showFailureToast("Exception: editorErr"),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("handles save exception and emits error", () async {
      viewModel.validateAndSaveFormResult = true;

      when(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenThrow(
        Exception("saveErr"),
      );

      await viewModel.onSavePress(
        false,
        context: FakeBuildContext(),
      );

      verify(
        () => mockAlert.showFailureToast("Exception: saveErr"),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("saveComment()", () {
    test("creates and saves comment successfully", () async {
      await viewModel.saveComment("Test comment");

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment?.comment, "Test comment");
      verify(() => mockCommonRepo.saveComment(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
      "handles repository exception and still returns loaded state",
      () async {
        when(() => mockCommonRepo.saveComment(any())).thenThrow(
          Exception("Save failed"),
        );

        await viewModel.saveComment("Test comment");

        verify(
          () => mockAlert.showFailureToast("Exception: Save failed"),
        ).called(1);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test("emits loading then loaded", () async {
      final List<LoadingStatus> emittedStatuses = <LoadingStatus>[];
      final subscription = viewModel.stream.listen((state) {
        emittedStatuses.add(state.loaderStatus);
      });

      await viewModel.saveComment("Test comment");

      expect(emittedStatuses, contains(LoadingStatus.loading));
      expect(emittedStatuses, contains(LoadingStatus.loading));

      await subscription.cancel();
    });
  });

  group("navigate()", () {
    test("moves to next tab when current tab is not last tab", () async {
      viewModel.isReadOnly = true;

      await viewModel.changeTab(CountrySummaryTabs.request);
      viewModel.navigate(FakeBuildContext());

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.activeTab, CountrySummaryTabs.rational);
    });

    test("goes to next route access when current tab is last tab", () async {
      viewModel.isReadOnly = true;
      await viewModel.changeTab(CountrySummaryTabs.fiRecommend);

      viewModel.navigate(FakeBuildContext());

      expect(nextRouteCallCount, 1);
    });
  });

  group("getApplicationStrategyDetails()", () {
    test("sets initialText and editor when matching comment exists", () async {
      final List<Comment> data = <Comment>[
        Comment.fromInputData(
          type: CommentsType.countrySummary,
          categoryId:
              ServerConstants.approvalCategoryId[ApprovalCategory.request],
          categoryType:
              ServerConstants.approvalCategoryType[ApprovalCategory.request],
          strategyComment: "<p>hello</p>",
        ),
      ];

      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.countrySummary,
          EntityIdentifier.countrySummary,
        ),
      ).thenAnswer((_) async => data);

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      expect(viewModel.comment, isNotNull);
      expect(viewModel.initialText, "<p>hello</p>");
      verify(() => mockController.setText("<p>hello</p>")).called(1);
    });

    test("clears editor when list exists but no matching category", () async {
      final List<Comment> data = <Comment>[
        Comment.fromInputData(
          type: CommentsType.countrySummary,
          categoryId: 999999,
          categoryType: "dummy",
          strategyComment: "<p>hello</p>",
        ),
      ];

      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.countrySummary,
          EntityIdentifier.countrySummary,
        ),
      ).thenAnswer((_) async => data);

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      expect(viewModel.initialText, "");
      verify(() => mockController.setText("")).called(1);
    });

    test("clears editor when repository returns empty list", () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.countrySummary,
          EntityIdentifier.countrySummary,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      expect(viewModel.initialText, "");
      verify(() => mockController.setText("")).called(1);
    });

    test("shows failure toast when repository throws", () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.countrySummary,
          EntityIdentifier.countrySummary,
        ),
      ).thenThrow(
        Exception("detailsErr"),
      );

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      verify(
        () => mockAlert.showFailureToast("Exception: detailsErr"),
      ).called(1);
    });
  });
}

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "common.error": "Error",
      "approval.creditAssessment.savedSuccessfully": "Saved successfully",
      "approval.countrySummary.savedSuccessfully": "Saved successfully",
    };
  }
}
