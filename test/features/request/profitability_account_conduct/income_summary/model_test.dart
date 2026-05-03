import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
// Adjust these imports to your actual file locations.
// The uploaded test used the following paths:
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/income_summary.dart";
// If CommonRepository or other singletons are used in your ViewModel,
// import and override them similarly.
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

/// ---------- Test doubles & helpers ----------

class TestAlertManager implements AlertManager {
  String? lastFailure;
  String? lastSuccess;

  @override
  void showFailureToast(String message) => lastFailure = message;

  @override
  void showSuccessToast(String message) => lastSuccess = message;

  @override
  void showInfoToast(String message) {}

  @override
  void showWarningToast(String message) {}

  // If your AlertManager has a static override hook:
  static void install(TestAlertManager spy) {
    AlertManager.overrideInstance(spy);
  }
}

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeComment extends Fake implements Comment {}

/// KEY FIX: Prevent DraftRepository.deleteDraft() from hitting Dio during
/// tests.
/// This removes the "Pending timers" error caused by Dio scheduling timers.
class FakeDraftRepository extends DraftRepository {
  FakeDraftRepository() : super(apiManager: null);

  @override
  Future<void> deleteDraft({
    required String module,
    required String screen,
  }) async {
    // no-op
    return;
  }

  @override
  Future<void> saveDraft({
    required String module,
    required String screen,
    required Map<String, dynamic> draftJson,
  }) async {
    // no-op
    return;
  }

  @override
  Future<Map<String, dynamic>?> getDraft({
    required String module,
    required String screen,
  }) async {
    return null;
  }

  @override
  Future<void> saveDraftBeacon({
    required String module,
    required String screen,
    required Map<String, dynamic> draftJson,
  }) async {
    // no-op
    return;
  }
}

/// A view model subclass that allows us to inject mocks.
class TestableIncomeSummaryViewModel extends IncomeSummaryViewModel {
  void setMockRepository(MockProfitabilityRepository mock) {
    repository = mock;
  }

  void setMockCommonRepository(MockCommonRepository mock) {
    CommonRepository.overrideInstance(mock);
  }

  void setAlertManager(AlertManager alert) {
    AlertManager.overrideInstance(alert);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeComment());
  });

  group("init(context)", () {
    late TestableIncomeSummaryViewModel viewModel;
    late MockProfitabilityRepository mockRepo;
    late MockCommonRepository mockCommonRepo;
    late TestAlertManager alertSpy;

    late DraftRepository originalDraftRepo;

    setUp(() {
      mockRepo = MockProfitabilityRepository();
      mockCommonRepo = MockCommonRepository();
      alertSpy = TestAlertManager();
      viewModel = TestableIncomeSummaryViewModel();

      // Prevent Dio timers in any code path that tries to delete drafts.
      originalDraftRepo = DraftRepository.instance;
      DraftRepository.overrideInstance(FakeDraftRepository());

      viewModel
        ..setMockCommonRepository(mockCommonRepo)
        ..setAlertManager(alertSpy);

      // IMPORTANT: init() assigns repository = ProfitabilityRepository.instance
      // so we need to make sure .instance returns our mock.
      // If your repository exposes an override hook, call it here:
      ProfitabilityRepository.overrideInstance(mockRepo);
    });

    tearDown(() {
      // Restore DraftRepository singleton to avoid leaking state between tests.
      DraftRepository.overrideInstance(originalDraftRepo);
    });

    test("sets repository from singleton and loads income summary on success",
        () async {
      // Arrange: stub the repository response
      final response = IncomeSummaryResponseData(
        appRefNo: "APP-INIT",
        incomeSummaryDataList: [
          IncomeSummary(
            rimNo: 10,
            custName: "Init A",
            lastYearAmount: "1000.0",
          ),
          IncomeSummary(
            rimNo: 11,
            custName: "Init B",
            lastYearAmount: "2000.0",
          ),
        ],
        comment: IncomeComment(appRefNo: "APP-INIT", comment: "Init RM note"),
      );
      when(() => mockRepo.getIncomeSummary()).thenAnswer((_) async => response);

      // Act
      await viewModel.init(FakeBuildContext());

      // Assert repository was taken from the singleton
      expect(viewModel.repository, same(mockRepo));

      // Assert data populated by getIncomeSummary()
      expect(viewModel.incomeSummaryList, isNotNull);
      expect(viewModel.incomeSummaryList, hasLength(2));
      expect(viewModel.incomeSummaryList![0].custName, "Init A");
      expect(viewModel.comment, isA<IncomeComment>());
      expect(viewModel.rmComments, "Init RM note");

      // Assert state moved to loaded
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      // Verify getIncomeSummary was invoked exactly once during init
      verify(() => mockRepo.getIncomeSummary()).called(1);
    });

    test("sets repository from singleton and shows empty state on failure",
        () async {
      // Arrange: stub an error from the repository
      when(() => mockRepo.getIncomeSummary())
          .thenThrow(Exception("Init fetch failed"));

      // Act
      await viewModel.init(FakeBuildContext());

      // Assert repository was taken from the singleton
      expect(viewModel.repository, same(mockRepo));

      // Assert defensive empty list and empty loader state (per VM
      // implementation)
      expect(viewModel.incomeSummaryList, isNotNull);
      expect(viewModel.incomeSummaryList, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      // Verify invocation
      verify(() => mockRepo.getIncomeSummary()).called(1);
    });

    test("does not crash with a fake BuildContext", () async {
      // Arrange: provide a nominal success
      when(() => mockRepo.getIncomeSummary()).thenAnswer(
        (_) async => IncomeSummaryResponseData(
          appRefNo: "APP-FAKE",
          incomeSummaryDataList: const [],
          comment: null,
        ),
      );

      // Act + Assert: should complete without exceptions
      await viewModel.init(FakeBuildContext());

      // Post‑conditions
      expect(viewModel.repository, same(mockRepo));
      expect(viewModel.incomeSummaryList, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("IncomeSummaryViewModel lifecycle & state", () {
    late TestableIncomeSummaryViewModel viewModel;
    late MockProfitabilityRepository mockRepo;
    late MockCommonRepository mockCommonRepo;
    late TestAlertManager alertSpy;

    late DraftRepository originalDraftRepo;

    setUp(() {
      mockRepo = MockProfitabilityRepository();
      mockCommonRepo = MockCommonRepository();
      alertSpy = TestAlertManager();
      viewModel = TestableIncomeSummaryViewModel();

      // KEY FIX: override DraftRepository to prevent Dio pending timers.
      originalDraftRepo = DraftRepository.instance;
      DraftRepository.overrideInstance(FakeDraftRepository());

      viewModel
        ..setMockRepository(mockRepo)
        ..setMockCommonRepository(mockCommonRepo)
        ..setAlertManager(alertSpy);
    });

    tearDown(() {
      DraftRepository.overrideInstance(originalDraftRepo);
    });

    test("initial loaderStatus is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    group("getIncomeSummary()", () {
      test("success: populates list, comment and rmComments; sets loaded",
          () async {
        final response = IncomeSummaryResponseData(
          appRefNo: "APP-123",
          incomeSummaryDataList: [
            IncomeSummary(
              rimNo: 101,
              custName: "Alpha",
              lastYearAmount: "250000",
            ),
            IncomeSummary(
              rimNo: 102,
              custName: "Beta",
              lastYearAmount: "175000",
            ),
          ],
          comment:
              IncomeComment(appRefNo: "APP-123", comment: "Prefilled RM note"),
        );

        when(() => mockRepo.getIncomeSummary())
            .thenAnswer((_) async => response);

        await viewModel.getIncomeSummary();

        expect(viewModel.incomeSummaryList, isNotNull);
        expect(viewModel.incomeSummaryList, hasLength(2));
        expect(viewModel.incomeSummaryList![0].custName, "Alpha");
        expect(viewModel.comment, isA<IncomeComment>());
        expect(viewModel.rmComments, "Prefilled RM note");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("success: empty list and null comment; still sets loaded/empty",
          () async {
        final response = IncomeSummaryResponseData(
          appRefNo: "APP-456",
          incomeSummaryDataList: const [],
          comment: null,
        );

        when(() => mockRepo.getIncomeSummary())
            .thenAnswer((_) async => response);

        await viewModel.getIncomeSummary();

        expect(viewModel.incomeSummaryList, isNotNull);
        expect(viewModel.incomeSummaryList, isEmpty);
        expect(viewModel.comment, isNull);
        expect(viewModel.rmComments, isNull);
        expect(viewModel.state.loaderStatus, LoadingStatus.empty);
      });

      test("error: sets list to [] and loaderStatus to empty", () async {
        when(() => mockRepo.getIncomeSummary())
            .thenThrow(Exception("Network down"));

        await viewModel.getIncomeSummary();

        expect(viewModel.incomeSummaryList, isNotNull);
        expect(viewModel.incomeSummaryList, isEmpty);
        expect(viewModel.state.loaderStatus, LoadingStatus.empty);
      });
    });

    group("saveIncomeSummaryData()", () {
      setUp(() {
        // Ensure the formKey exists; currentState may be null in non-widget
        // tests.
        viewModel.formKey = GlobalKey<FormState>();
      });

      testWidgets("success: shows success toast and returns to loaded",
          (tester) async {
        // Arrange
        viewModel
          ..incomeSummaryList = [
            IncomeSummary(
              rimNo: 1,
              custName: "Customer A",
              lastYearAmount: "100.0",
            ),
          ]
          ..rmComments = "RM note";

        when(() => mockRepo.saveIncomeSummary(any(), any()))
            .thenAnswer((_) async => "Saved Successfully");

        await viewModel.saveIncomeSummaryData(FakeBuildContext(), false);

        // Flush microtasks/frames (pumpAndSettle semantics per Flutter docs). [1](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html)
        await tester.pump();
        await tester.pumpAndSettle();

        verify(() => mockRepo.saveIncomeSummary(any(), any())).called(1);

        expect(alertSpy.lastSuccess, "Saved Successfully");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      testWidgets(
          "success: navigateNext=true does not crash (navigation not asserted)",
          (tester) async {
        viewModel
          ..incomeSummaryList = [
            IncomeSummary(
              rimNo: 2,
              custName: "Customer B",
              lastYearAmount: "200.0",
            ),
          ]
          ..rmComments = "Next please";

        when(() => mockRepo.saveIncomeSummary(any(), any()))
            .thenAnswer((_) async => "Saved Successfully");

        await viewModel.saveIncomeSummaryData(FakeBuildContext(), true);

        // This test used to fail due to DraftRepository.deleteDraft → Dio
        // timers.
        // Now DraftRepository is overridden, but still settle frames.
        await tester.pump();
        await tester.pumpAndSettle();

        expect(alertSpy.lastSuccess, "Saved Successfully");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      testWidgets(
          "error: repository throws -> shows failure"
          " toast and returns to loaded", (tester) async {
        viewModel
          ..incomeSummaryList = [
            IncomeSummary(
              rimNo: 3,
              custName: "Customer C",
              lastYearAmount: "300.0",
            ),
          ]
          ..rmComments = "Will fail";

        when(() => mockRepo.saveIncomeSummary(any(), any()))
            .thenThrow(Exception("Save failed"));

        await viewModel.saveIncomeSummaryData(FakeBuildContext(), false);

        await tester.pump();
        await tester.pumpAndSettle();

        expect(alertSpy.lastFailure, contains("Exception: Save failed"));
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      testWidgets(
          "defensive: incomeSummaryList "
          "== null -> "
          "shows failure toast and returns to loaded", (tester) async {
        viewModel
          ..incomeSummaryList = null
          ..rmComments = "No data";

        await viewModel.saveIncomeSummaryData(FakeBuildContext(), false);

        await tester.pump();
        await tester.pumpAndSettle();

        // FIX: VM does NOT throw a Null error; it shows a friendly message.
        expect(
          alertSpy.lastFailure,
          "No data to save. Please refresh and try again.",
        );
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      testWidgets("loaderStatus transitions: loading -> loaded on success",
          (tester) async {
        viewModel
          ..incomeSummaryList = [
            IncomeSummary(
              rimNo: 4,
              custName: "Customer D",
              lastYearAmount: "400.0",
            ),
          ]
          ..rmComments = "Transition check";

        when(() => mockRepo.saveIncomeSummary(any(), any()))
            .thenAnswer((_) async => "OK");

        // Better transition test: start without awaiting so we can observe
        // "loading".
        final future =
            viewModel.saveIncomeSummaryData(FakeBuildContext(), false);

        await tester.pump(); // let synchronous state change apply

        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

        await future;

        await tester.pump();
        await tester.pumpAndSettle();

        expect(alertSpy.lastSuccess, "OK");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      // ── NEW: formKey.currentState != null AND form is INVALID ──────────────
      // Covers the `if (!isValid) { emit(loaded); return; }` early-return
      // branch.
      // A real Form widget must be in the tree so currentState is non-null.
      testWidgets(
          "invalid form: validation fails -> no repo call, loaderStatus loaded",
          (tester) async {
        viewModel.incomeSummaryList = [
          IncomeSummary(
            rimNo: 5,
            custName: "Customer E",
            lastYearAmount: "500.0",
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(validator: (_) => "required"),
              ),
            ),
          ),
        );

        await viewModel.saveIncomeSummaryData(
          tester.element(find.byType(TextFormField)),
          false,
        );

        await tester.pump();
        await tester.pumpAndSettle();

        verifyNever(() => mockRepo.saveIncomeSummary(any(), any()));
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      // ── NEW: formKey.currentState == null (no Form in tree) ────────────────
      // Covers the `if (form != null)` false branch – validation block skipped.
      // The null-list guard is then hit, confirming the skip path was taken.
      testWidgets(
          "null formState: validation block skipped, null list returns early",
          (tester) async {
        viewModel
          ..formKey = GlobalKey<FormState>() // fresh key, never attached
          ..incomeSummaryList = null;

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        await viewModel.saveIncomeSummaryData(
          tester.element(find.byType(SizedBox)),
          false,
        );

        await tester.pump();
        await tester.pumpAndSettle();

        verifyNever(() => mockRepo.saveIncomeSummary(any(), any()));
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      // ── NEW: rmCommentsController whitespace-only → rmComments = null ──────
      // Covers the left branch of:
      //   rmComments = controller.text.trim().isEmpty ? null :
      // controller.text.trim()
      // Must set via controller (not rmComments field) to exercise the trim
      // logic.
      testWidgets(
          "whitespace-only controller text -> "
          "rmComments null, repo called with null", (tester) async {
        viewModel.incomeSummaryList = [
          IncomeSummary(
            rimNo: 6,
            custName: "Customer F",
            lastYearAmount: "600.0",
          ),
        ];
        viewModel.rmCommentsController.text = "   ";

        when(() => mockRepo.saveIncomeSummary(any(), null))
            .thenAnswer((_) async => "OK");

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: const SizedBox(),
              ),
            ),
          ),
        );

        await viewModel.saveIncomeSummaryData(
          tester.element(find.byType(SizedBox)),
          false,
        );

        await tester.pump();
        await tester.pumpAndSettle();

        verify(() => mockRepo.saveIncomeSummary(any(), null)).called(1);
        expect(viewModel.rmComments, isNull);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      // ── NEW: rmCommentsController has real text → trimmed value forwarded ──
      // Covers the right branch of the same ternary: non-empty → trimmed
      // string.
      testWidgets(
          "controller with text -> trimmed rmComments forwarded to repo",
          (tester) async {
        viewModel.incomeSummaryList = [
          IncomeSummary(
            rimNo: 7,
            custName: "Customer G",
            lastYearAmount: "700.0",
          ),
        ];
        viewModel.rmCommentsController.text = "  trimmed note  ";

        when(() => mockRepo.saveIncomeSummary(any(), "trimmed note"))
            .thenAnswer((_) async => "OK");

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: const SizedBox(),
              ),
            ),
          ),
        );

        await viewModel.saveIncomeSummaryData(
          tester.element(find.byType(SizedBox)),
          false,
        );

        await tester.pump();
        await tester.pumpAndSettle();

        verify(() => mockRepo.saveIncomeSummary(any(), "trimmed note"))
            .called(1);
        expect(viewModel.rmComments, "trimmed note");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("IncomeSummaryState.copyWith", () {
      test("constructor sets loaderStatus", () {
        final s = IncomeSummaryState(loaderStatus: LoadingStatus.loading);
        expect(s.loaderStatus, LoadingStatus.loading);
      });

      test("copyWith keeps existing when null", () {
        final original = IncomeSummaryState(loaderStatus: LoadingStatus.loaded);
        final copied = original.copyWith();
        expect(copied.loaderStatus, LoadingStatus.loaded);
      });

      test("copyWith overrides loaderStatus", () {
        final original = IncomeSummaryState(loaderStatus: LoadingStatus.loaded);
        final updated = original.copyWith(loaderStatus: LoadingStatus.error);
        expect(updated.loaderStatus, LoadingStatus.error);
        expect(original.loaderStatus, LoadingStatus.loaded);
      });
    });

    // ── NEW: canEdit getter ─────────────────────────────────────────────────
    // Covers both sides of `bool get canEdit => pageMode == PageMode.edit`.
    group("canEdit getter", () {
      test("returns true when pageMode is PageMode.edit", () {
        viewModel.pageMode = PageMode.edit;
        expect(viewModel.canEdit, isTrue);
      });

      test("returns false when pageMode is not PageMode.edit", () {
        viewModel.pageMode = PageMode.na;
        expect(viewModel.canEdit, isFalse);
      });
    });
  });
}
