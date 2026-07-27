import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/termination/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/features/request/ccsys/termination/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class TestableCcsysTerminationViewModel extends CcsysTerminationViewModel {
  bool warningDialogShown = false;
  bool successDialogShown = false;
  bool registerDraftCalled = false;
  bool unregisterDraftCalled = false;
  bool loadDraftCalled = false;
  bool deleteDraftCalled = false;

  final List<TerminationState> emittedStates = [];

  @override
  void emit(TerminationState state) {
    super.emit(state);
    emittedStates.add(state);
  }

  @override
  void showDialogUpdateTerminateStatus(BuildContext context) {
    warningDialogShown = true;
  }

  @override
  void showDialogSuccessTerminateStatus(BuildContext context) {
    successDialogShown = true;
  }

  @override
  void registerDraftCallback() {
    registerDraftCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftCalled = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }
}

class MockAlertManager extends Mock implements AlertManager {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockContext extends Mock implements BuildContext {}

class MockDraftRepository extends Mock implements DraftRepository {}

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

  late TestableCcsysTerminationViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockContext mockContext;
  late MockAlertManager mockAlertManager;
  late MockDraftRepository mockDraftRepository;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

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

    registerFallbackValue(Request());
    registerFallbackValue(Customer());
    registerFallbackValue(Comment());
  });

  setUp(() {
    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance = mockAlertManager;

    mockLocalStorageService = MockLocalStorageService();
    LocalStorageService().getStorage = mockLocalStorageService;

    mockDraftRepository = MockDraftRepository();
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockContext = MockContext();

    RequestRepository.overrideInstance = mockRequestRepository;
    CommonRepository.overrideInstance = mockCommonRepository;

    viewModel = TestableCcsysTerminationViewModel()
      ..repository = mockRequestRepository
      ..commonRepository = mockCommonRepository;

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

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockContext.mounted).thenReturn(false);

    Globals.request = Request();
  });

  tearDown(() async {
    if (!viewModel.isClosed) {
      await viewModel.close();
    }
  });

  group("CcsysTerminationViewModel initial state and getters", () {
    test("constructor sets initial values", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.isTerminationSuccess, false);
      expect(viewModel.reasonForTermination, isEmpty);
      expect(viewModel.customerInfo, isEmpty);
      expect(viewModel.getReviewComments, isEmpty);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isNotNull);
      expect(viewModel.referenceData, isEmpty);
      expect(viewModel.canEdit, false);
      expect(viewModel.pageMode, PageMode.na);
      expect(viewModel.formFocusNode, isA<FocusNode>());
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.remarksController, isA<TextEditingController>());
    });

    test("draft getters return correct values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.ccsys);
      expect(viewModel.draftFormKey, Routes.ccsysTerminateWithdraw);
      expect(
        viewModel.draftHandler,
        isA<DraftHandler<CcsysTerminationViewModel>>(),
      );
      expect(viewModel.draftHandler, isA<CcsysTerminationDraftHandler>());
    });
  });

  group("init", () {
    test("init sets repositories, comments and loaded state", () async {
      Globals.request = Request()..applicationRefNo = "APP-INIT";

      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.init(mockContext);

      expect(viewModel.repository, RequestRepository.instance);
      expect(viewModel.commonRepository, CommonRepository.instance);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init handles matching comments", () async {
      Globals.request = Request()..applicationRefNo = "APP-INIT-2";

      final comment = Comment(
        userId: "u1",
        userRole: 1,
        comment: "Init comment",
        reviewCommentId: "1",
        applicationRefNo: "APP-INIT-2",
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => [comment]);

      await viewModel.init(mockContext);

      expect(viewModel.comments.length, 1);
      expect(viewModel.getReviewComments?.length, 1);
      expect(viewModel.comment?.comment, "Init comment");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init attempts draft only when canEdit is true", () async {
      Globals.request = Request()..ccsysCanEditReadOnly = true;

      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.init(mockContext);

      if (viewModel.canEdit) {
        expect(viewModel.registerDraftCalled, true);
        expect(viewModel.loadDraftCalled, true);
      } else {
        expect(viewModel.registerDraftCalled, false);
        expect(viewModel.loadDraftCalled, false);
      }

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("initRightsAndMode", () {
    test("sets canEdit false when request rights is false", () {
      final request = Request()..ccsysCanEditReadOnly = false;

      viewModel.initRightsAndMode(request);

      expect(viewModel.canEdit, false);
    });
  });

  group("reasonForTerminationSelected", () {
    test("updates comment categoryId and reasonList", () {
      viewModel.reasonForTerminationSelected(Reference(id: 10));

      expect(viewModel.comment?.categoryId, 10);
      expect(viewModel.comment?.reasonList, "10");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updates first review comment reasonList when review comments exist",
        () {
      final existingComment = Comment()..reasonList = "1";
      viewModel
        ..getReviewComments = [existingComment]
        ..reasonForTerminationSelected(Reference(id: 99));

      expect(viewModel.comment?.categoryId, 99);
      expect(viewModel.comment?.reasonList, "99");
      expect(viewModel.getReviewComments?.first.reasonList, "99");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getReviewCommentsReference", () {
    test("sets comments and selected comment when applicationRefNo matches",
        () async {
      Globals.request = Request()..applicationRefNo = "APP-123";

      final matchedComment = Comment(
        userId: "u1",
        userRole: 1,
        comment: "Matched",
        reviewCommentId: "1",
        applicationRefNo: "APP-123",
      );

      final unmatchedComment = Comment(
        userId: "u2",
        userRole: 2,
        comment: "Unmatched",
        reviewCommentId: "2",
        applicationRefNo: "APP-999",
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => [matchedComment, unmatchedComment]);

      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.comments.length, 2);
      expect(viewModel.getReviewComments?.length, 1);
      expect(viewModel.getReviewComments?.first.comment, "Matched");
      expect(viewModel.comment?.comment, "Matched");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("keeps review comments empty when applicationRefNo does not match",
        () async {
      Globals.request = Request()..applicationRefNo = "APP-123";

      final unmatchedComment = Comment(
        userId: "u2",
        userRole: 2,
        comment: "Unmatched",
        reviewCommentId: "2",
        applicationRefNo: "APP-999",
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => [unmatchedComment]);

      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.comments.length, 1);
      expect(viewModel.getReviewComments, isEmpty);
      expect(viewModel.comment, isNotNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles empty comments response", () async {
      Globals.request = Request()..applicationRefNo = "APP-EMPTY";

      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.comments, isEmpty);
      expect(viewModel.getReviewComments, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles exception and shows failure toast", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenThrow(Exception("Error"));

      await viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.error);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("getReferenceDatas", () {
    test("method completes without throwing", () async {
      await viewModel.getReferenceDatas();

      expect(viewModel.reasonForTermination, isA<List<Reference>>());
    });
  });

  group("onTerminateButtonPressed", () {
    test("shows warning dialog when canEdit is false", () async {
      viewModel.canEdit = false;

      await viewModel.onTerminateButtonPressed(mockContext);

      expect(viewModel.warningDialogShown, true);

      verifyNever(
        () => mockAlertManager.showFailureToast(
          "requestInformation.terminateWithdrawal.requiredFeild".tr(),
        ),
      );
    });

    test("shows validation toast when canEdit is true and form is invalid",
        () async {
      viewModel.canEdit = true;

      await viewModel.onTerminateButtonPressed(mockContext);

      expect(viewModel.warningDialogShown, false);

      verify(
        () => mockAlertManager.showFailureToast(
          "requestInformation.terminateWithdrawal.requiredFeild".tr(),
        ),
      ).called(1);
    });
  });

  group("submitTerminateRequest", () {
    test("success calls repository with selected reason and comment", () async {
      viewModel
        ..canEdit = false
        ..comment = Comment(
          reasonList: "10",
          comment: "Terminate reason",
        );

      when(
        () => mockRequestRepository.updateTerminateStatus(
          "10",
          "Terminate reason",
        ),
      ).thenAnswer((_) async => "Success");

      await viewModel.submitTerminateRequest(mockContext);

      expect(viewModel.isTerminationSuccess, true);
      expect(viewModel.deleteDraftCalled, true);
      expect(viewModel.state.isButtonLoading, false);

      verify(
        () => mockRequestRepository.updateTerminateStatus(
          "10",
          "Terminate reason",
        ),
      ).called(1);
    });

    test("success sends empty strings when comment fields are null", () async {
      viewModel
        ..canEdit = false
        ..comment = Comment();

      when(
        () => mockRequestRepository.updateTerminateStatus("", ""),
      ).thenAnswer((_) async => "Success");

      await viewModel.submitTerminateRequest(mockContext);

      expect(viewModel.isTerminationSuccess, true);
      expect(viewModel.deleteDraftCalled, true);
      expect(viewModel.state.isButtonLoading, false);

      verify(
        () => mockRequestRepository.updateTerminateStatus("", ""),
      ).called(1);
    });

    test("does not call repository when canEdit true and form is invalid",
        () async {
      viewModel.canEdit = true;

      await viewModel.submitTerminateRequest(mockContext);

      expect(viewModel.state.isButtonLoading, false);

      verifyNever(
        () => mockRequestRepository.updateTerminateStatus(any(), any()),
      );
    });

    test("handles repository exception", () async {
      viewModel.canEdit = false;

      when(
        () => mockRequestRepository.updateTerminateStatus(any(), any()),
      ).thenThrow(Exception("Error"));

      await viewModel.submitTerminateRequest(mockContext);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      expect(viewModel.state.isButtonLoading, false);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("dialog methods", () {
    testWidgets("showDialogUpdateTerminateStatus does not throw",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (dialogContext) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    CcsysTerminationViewModel()
                      ..repository = mockRequestRepository
                      ..commonRepository = mockCommonRepository
                      ..showDialogUpdateTerminateStatus(dialogContext);
                  },
                  child: const Text("Open"),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text("Open"));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets("showDialogSuccessTerminateStatus does not throw",
        (tester) async {
      Globals.request = Request()..applicationRefNo = "APP-SUCCESS";

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (dialogContext) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    CcsysTerminationViewModel()
                      ..repository = mockRequestRepository
                      ..commonRepository = mockCommonRepository
                      ..showDialogSuccessTerminateStatus(dialogContext);
                  },
                  child: const Text("Open"),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text("Open"));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group("TerminationState", () {
    test("constructor sets loaderStatus", () {
      const state = TerminationState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing values when null", () {
      const original = TerminationState(
        loaderStatus: LoadingStatus.loaded,
        isButtonLoading: true,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.isButtonLoading, true);
    });

    test("copyWith overrides loaderStatus", () {
      const original = TerminationState(loaderStatus: LoadingStatus.loaded);

      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides isButtonLoading", () {
      const original = TerminationState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(isButtonLoading: true);

      expect(updated.isButtonLoading, true);
      expect(original.isButtonLoading, false);
    });
  });

  group("close", () {
    test("unregisters draft callback and closes cubit", () async {
      await viewModel.close();

      expect(viewModel.unregisterDraftCalled, true);
      expect(viewModel.isClosed, true);
    });
  });
}
