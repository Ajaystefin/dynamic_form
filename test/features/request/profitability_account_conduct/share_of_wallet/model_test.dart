// model_test.dart
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/share_of_wallet.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

// ---------------- Mocks ----------------

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

// ---------------- Testable VM ----------------

class TestShareOfWalletViewModel extends ShareOfWalletViewModel {
  TestShareOfWalletViewModel({
    this.editable = false,
    this.throwInGetShare = false,
    this.throwInGetStrategy = false,
  });

  final bool editable;
  final bool throwInGetShare;
  final bool throwInGetStrategy;

  bool registerDraftCalled = false;
  bool loadDraftCalled = false;
  bool deleteDraftCalled = false;
  bool unregisterDraftCalled = false;

  bool getShareCalled = false;
  bool strategyCalled = false;

  @override
  bool get canEdit => editable;

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

  @override
  Future<void> getShareOfWallet() async {
    getShareCalled = true;
    if (throwInGetShare) {
      throw Exception("getShare failed");
    }
  }

  @override
  Future<void> getApplicationStrategyDetails() async {
    strategyCalled = true;
    if (throwInGetStrategy) {
      throw Exception("strategy failed");
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Comment());
  });

  late MockProfitabilityRepository mockProfitRepo;
  late MockCommonRepository mockCommonRepo;
  late MockAlertManager mockAlert;
  late ShareOfWalletViewModel viewModel;

  setUp(() {
    mockProfitRepo = MockProfitabilityRepository();
    mockCommonRepo = MockCommonRepository();
    mockAlert = MockAlertManager();

    CommonRepository.overrideInstance(mockCommonRepo);
    AlertManager.overrideInstance(mockAlert);

    viewModel = ShareOfWalletViewModel();
    viewModel.repository = mockProfitRepo;
    viewModel.comment = Comment();
  });

  test("initial loaderStatus is loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  // ---------------------------------------------------------------------------
  // getShareOfWallet()
  // ---------------------------------------------------------------------------
  group("getShareOfWallet()", () {
    final dummyData = <ShareOfWallet>[
      ShareOfWallet(
        customerRimNo: 2,
        customerName: "Y",
        facilitiesWithAllBanksLimitsA: 100,
        facilitiesWithAllBanksOutstandingC: 50,
        facilitiesWithCbdLimitsB: 200,
        facilitiesWithCbdOutstandingD: 75,
        shareOfWalletLimits: 300,
        shareOfWalletOutstanding: 150,
      ),
    ];

    test("success -> list updated", () async {
      when(() => mockProfitRepo.getShareOfWallet())
          .thenAnswer((_) async => dummyData);

      await viewModel.getShareOfWallet();

      expect(viewModel.shareOfWalletList, dummyData);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      verify(() => mockProfitRepo.getShareOfWallet()).called(1);
    });

    test("failure -> rethrows and list stays empty", () async {
      when(() => mockProfitRepo.getShareOfWallet())
          .thenThrow(Exception("fetch failed"));

      await expectLater(viewModel.getShareOfWallet(), throwsException);

      expect(viewModel.shareOfWalletList, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      verify(() => mockProfitRepo.getShareOfWallet()).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // saveComment()
  // ---------------------------------------------------------------------------
  group("saveComment()", () {
    test("failure -> repository throws and shows failure toast", () async {
      final vm = TestShareOfWalletViewModel();
      vm.comment = Comment();

      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("Save failed"));

      await vm.saveComment("Test wallet comment");

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlert.showFailureToast(any(that: isA<String>())))
          .called(1);
    });

    test("null comment input still executes method path", () async {
      final vm = TestShareOfWalletViewModel();
      vm.comment = Comment();

      when(
        () => mockCommonRepo.saveApplicationStrategyDetails(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "Saved");

      await vm.saveComment(null);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlert.showSuccessToast("Saved")).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // getApplicationStrategyDetails()
  // ---------------------------------------------------------------------------
  group("getApplicationStrategyDetails()", () {
    test("non-empty list with relevant comment -> sets rmComments", () async {
      final relevant = Comment()
        ..categoryId = ServerConstants.shareWalletCommentCategoryId
        ..strategyComment = "Existing comment";

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.shareWallet,
          EntityIdentifier.shareWallet,
        ),
      ).thenAnswer((_) async => [Comment(), relevant]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.rmComments, "Existing comment");
      verify(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.shareWallet,
          EntityIdentifier.shareWallet,
        ),
      ).called(1);
    });

    test("non-empty list without relevant comment -> sets empty string",
        () async {
      final notRelevant = Comment()
        ..categoryId = 999
        ..strategyComment = "Should not be used";

      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.shareWallet,
          EntityIdentifier.shareWallet,
        ),
      ).thenAnswer((_) async => [Comment(), notRelevant]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.rmComments, "");
    });

    test("empty list -> sets rmComments empty string", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.shareWallet,
          EntityIdentifier.shareWallet,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.rmComments, "");
    });

    test("failure -> catches exception and keeps loading state", () async {
      when(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.shareWallet,
          EntityIdentifier.shareWallet,
        ),
      ).thenThrow(Exception("fetch failed"));

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      verify(
        () => mockCommonRepo.getApplicationStrategyDetails(
          CommentsType.shareWallet,
          EntityIdentifier.shareWallet,
        ),
      ).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // onSaveAndContinue()
  // ---------------------------------------------------------------------------
  group("onSaveAndContinue()", () {
    testWidgets("valid form -> saves comment and ends in loaded state",
        (tester) async {
      final vm = TestShareOfWalletViewModel();
      vm.comment = Comment();

      when(
        () =>
            mockCommonRepo.saveApplicationStrategyDetails(any(), any(), any()),
      ).thenAnswer((_) async => "Saved");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                validator: (_) => null,
                onSaved: (_) => vm.rmComments = "  hello world  ",
              ),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(Form));

      await vm.onSaveAndContinue(context);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      verify(
        () =>
            mockCommonRepo.saveApplicationStrategyDetails(any(), any(), any()),
      ).called(1);
    });

    testWidgets("invalid form -> saveComment is not called", (tester) async {
      final vm = TestShareOfWalletViewModel();
      vm.comment = Comment();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                validator: (_) => "validation failed",
                onSaved: (_) => vm.rmComments = "will not save",
              ),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(Form));

      await vm.onSaveAndContinue(context);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(
        () =>
            mockCommonRepo.saveApplicationStrategyDetails(any(), any(), any()),
      );
    });

    testWidgets("form save throws -> emits error state", (tester) async {
      final vm = TestShareOfWalletViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                validator: (_) => null,
                onSaved: (_) {
                  throw Exception("save failed");
                },
              ),
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(Form));

      await vm.onSaveAndContinue(context);

      expect(vm.state.loaderStatus, LoadingStatus.error);
    });
  });

  // ---------------------------------------------------------------------------
  // init()
  // ---------------------------------------------------------------------------
  group("init()", () {
    test("success, canEdit=false -> calls load methods and sets loaded",
        () async {
      final vm = TestShareOfWalletViewModel(editable: false);

      await vm.init(MockBuildContext());

      expect(vm.getShareCalled, isTrue);
      expect(vm.strategyCalled, isTrue);
      expect(vm.registerDraftCalled, isFalse);
      expect(vm.loadDraftCalled, isFalse);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("success, canEdit=true -> registers and loads draft", () async {
      final vm = TestShareOfWalletViewModel(editable: true);

      await vm.init(MockBuildContext());

      expect(vm.getShareCalled, isTrue);
      expect(vm.strategyCalled, isTrue);
      expect(vm.registerDraftCalled, isTrue);
      expect(vm.loadDraftCalled, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("failure in Future.wait -> shows failure toast and still loads",
        () async {
      final vm = TestShareOfWalletViewModel(
        editable: false,
        throwInGetShare: true,
      );

      await vm.init(MockBuildContext());

      expect(vm.getShareCalled, isTrue);
      verify(() => mockAlert.showFailureToast(any(that: isA<String>())))
          .called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ---------------------------------------------------------------------------
  // close()
  // ---------------------------------------------------------------------------
  group("close()", () {
    test("unregisters draft callback", () async {
      final vm = TestShareOfWalletViewModel();

      await vm.close();

      expect(vm.unregisterDraftCalled, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // State tests
  // ---------------------------------------------------------------------------
  group("ShareOfWalletState", () {
    test("constructor sets loaderStatus", () {
      final state = ShareOfWalletState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = ShareOfWalletState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = ShareOfWalletState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
