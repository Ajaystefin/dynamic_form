import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

/// Test subclass only for observing draft mixin calls.
/// Production code remains unchanged.
class TestBusinessVolumeViewModel extends BusinessVolumeViewModel {
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
  required BusinessVolumeViewModel viewModel,
  void Function(String?)? onSaved,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: viewModel.formKey,
          child: TextFormField(
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestBusinessVolumeViewModel viewModel;
  late MockProfitabilityRepository mockRepository;
  late MockCommonRepository mockCommonRepository;
  late MockAlertManager mockAlertManager;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  setUpAll(() async {
    await EnvConfig.setEnvironment();

    registerFallbackValue(Comment());
    registerFallbackValue(<Customer, List<BusinessVolume>>{});

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

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async => null,
    );
  });

  setUp(() {
    mockRepository = MockProfitabilityRepository();
    mockCommonRepository = MockCommonRepository();
    mockAlertManager = MockAlertManager();

    AlertManager.overrideInstance(mockAlertManager);
    CommonRepository.overrideInstance(mockCommonRepository);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    when(() => mockRepository.getBusinessVolumes())
        .thenAnswer((_) async => <Customer, List<BusinessVolume>>{});
    when(() => mockRepository.saveBusinessVolumes(any(), any()))
        .thenAnswer((_) async => "Saved successfully");
    when(() => mockCommonRepository.saveComment(any()))
        .thenAnswer((_) async => "Comment saved");

    Globals.request = Request(applicationRefNo: "APP123");
    Globals.user = User(
      id: "USER123",
      currentRole: Role(
        roleId: 123,
        rights: <String, AccessType>{},
      ),
    );

    viewModel = TestBusinessVolumeViewModel()..repository = mockRepository;
  });

  group("constructor / initial state / getters", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("draft getters are correct", () {
      expect(
        viewModel.draftModuleKey,
        DraftModuleKeys.profitabilityAndAccountConduct,
      );
      expect(viewModel.draftFormKey, Routes.businessVolume);
      expect(viewModel.draftHandler, isNotNull);
    });

    test("canEdit returns true only when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, isTrue);

      viewModel.pageMode = PageMode.na;
      expect(viewModel.canEdit, isFalse);
    });

    test("default fields are initialized correctly", () {
      expect(viewModel.customerWiseBusinessVolume, isEmpty);
      expect(viewModel.comments, isNull);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    });
  });

  group("init()", () {
    test("init loads data and skips draft callbacks when page mode is non-edit",
        () async {
      Globals.user = User(
        id: "USER123",
        currentRole: Role(
          roleId: 123,
          rights: <String, AccessType>{
            RightConstants.businessVolume: AccessType.view,
          },
        ),
      );

      when(() => mockRepository.getBusinessVolumes()).thenAnswer(
        (_) async => <Customer, List<BusinessVolume>>{
          Customer(id: "C1"): <BusinessVolume>[
            BusinessVolume(natureOfBusiness: "200"),
          ],
        },
      );
      when(() => mockRepository.lastBusinessVolumeComment)
          .thenReturn(Comment(comment: "last comment"));

      await viewModel.init(null);

      verify(() => mockRepository.getBusinessVolumes()).called(1);
      expect(viewModel.comments, "last comment");
      expect(viewModel.pageMode, isA<PageMode>());
      expect(viewModel.registerDraftCallbackCalled, 0);
      expect(viewModel.loadDraftIfAvailableCalled, 0);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init registers and loads draft when page mode is edit", () async {
      Globals.user = User(
        id: "USER123",
        currentRole: Role(
          roleId: 123,
          rights: <String, AccessType>{
            RightConstants.businessVolume: AccessType.edit,
          },
        ),
      );

      when(() => mockRepository.getBusinessVolumes())
          .thenAnswer((_) async => <Customer, List<BusinessVolume>>{});
      when(() => mockRepository.lastBusinessVolumeComment)
          .thenReturn(Comment(comment: "editable comment"));

      await viewModel.init(null);

      expect(viewModel.pageMode, isA<PageMode>());
      expect(viewModel.canEdit, isTrue);
      expect(viewModel.registerDraftCallbackCalled, 1);
      expect(viewModel.loadDraftIfAvailableCalled, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init still emits loaded even if getBusinessVolume emits error",
        () async {
      Globals.user = User(
        id: "USER123",
        currentRole: Role(
          roleId: 123,
          rights: <String, AccessType>{
            RightConstants.businessVolume: AccessType.view,
          },
        ),
      );

      when(() => mockRepository.getBusinessVolumes())
          .thenThrow(Exception("get failed"));

      await viewModel.init(null);

      // getBusinessVolume emits error, but init emits loaded at the end.
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getBusinessVolume()", () {
    test("success populates business volume and comments", () async {
      final Map<Customer, List<BusinessVolume>> mockData =
          <Customer, List<BusinessVolume>>{
        Customer(id: "C1"): <BusinessVolume>[
          BusinessVolume(natureOfBusiness: "200"),
        ],
      };

      when(() => mockRepository.getBusinessVolumes())
          .thenAnswer((_) async => mockData);
      when(() => mockRepository.lastBusinessVolumeComment)
          .thenReturn(Comment(comment: "repo comment"));

      await viewModel.getBusinessVolume();

      expect(viewModel.customerWiseBusinessVolume, mockData);
      expect(viewModel.comments, "repo comment");
      expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
    });

    test("success with null last comment defaults comments to empty string",
        () async {
      when(() => mockRepository.getBusinessVolumes())
          .thenAnswer((_) async => <Customer, List<BusinessVolume>>{});
      when(() => mockRepository.lastBusinessVolumeComment).thenReturn(null);

      await viewModel.getBusinessVolume();

      expect(viewModel.comments, "");
    });

    test("failure emits error", () async {
      when(() => mockRepository.getBusinessVolumes())
          .thenThrow(Exception("Error"));

      await viewModel.getBusinessVolume();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("onSavePress()", () {
    testWidgets("success saves, deletes draft, shows toast, sets loaded",
        (WidgetTester tester) async {
      bool formSaved = false;

      await pumpFormHost(
        tester: tester,
        viewModel: viewModel,
        onSaved: (_) {
          formSaved = true;
        },
      );

      viewModel
        ..customerWiseBusinessVolume = <Customer, List<BusinessVolume>>{
          Customer(id: "C1"): <BusinessVolume>[
            BusinessVolume(natureOfBusiness: "200"),
          ],
        }
        ..comments = "Test comment";

      when(
        () => mockRepository.saveBusinessVolumes(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "Saved successfully");

      await viewModel.onSavePress();

      expect(formSaved, isTrue);
      verify(
        () => mockRepository.saveBusinessVolumes(
          viewModel.customerWiseBusinessVolume,
          "Test comment",
        ),
      ).called(1);
      verify(() => mockAlertManager.showSuccessToast("Saved successfully"))
          .called(1);
      expect(viewModel.deleteDraftCalled, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("success with continue=true executes continue branch",
        (WidgetTester tester) async {
      await pumpFormHost(
        tester: tester,
        viewModel: viewModel,
        onSaved: (_) {},
      );

      viewModel
        ..customerWiseBusinessVolume = <Customer, List<BusinessVolume>>{}
        ..comments = "Continue comment";

      when(() => mockRepository.saveBusinessVolumes(any(), any()))
          .thenAnswer((_) async => "Saved successfully");

      // We only care that the branch is executed.
      // If navigation is safe in test env, state remains loaded.
      await viewModel.onSavePress(isContinue: true);

      verify(() => mockRepository.saveBusinessVolumes(any(), any())).called(1);
    });

    test("failure emits error and shows failure toast", () async {
      viewModel
        ..customerWiseBusinessVolume = <Customer, List<BusinessVolume>>{}
        ..comments = "Test comment";

      when(() => mockRepository.saveBusinessVolumes(any(), any()))
          .thenThrow(Exception("Save failed"));

      await viewModel.onSavePress();

      verify(() => mockAlertManager.showFailureToast("Exception: Save failed"))
          .called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("saveComments()", () {
    test("success builds and saves comment, shows toast, sets loaded",
        () async {
      viewModel.comments = "My comment";

      when(() => mockCommonRepository.saveComment(any()))
          .thenAnswer((_) async => "Comment saved");

      await viewModel.saveComments();

      final VerificationResult result = verify(
        () => mockCommonRepository.saveComment(captureAny()),
      );
      final Comment captured = result.captured.single as Comment;

      expect(captured.comment, "My comment");
      expect(captured.commentId, "2");
      expect(captured.applicationRefNo, "APP123");
      expect(captured.draft, false);
      expect(captured.userId, "USER123");
      expect(captured.userRole, 123);
      expect(captured.reviewCommentId, "345");
      expect(captured.type, CommentsType.accountStats);
      expect(captured.entityType, EntityIdentifier.accountStats);

      verify(() => mockAlertManager.showSuccessToast("Comment saved"))
          .called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("failure shows failure toast", () async {
      viewModel.comments = "Fail comment";

      when(() => mockCommonRepository.saveComment(any()))
          .thenThrow(Exception("Comment failed"));

      await viewModel.saveComments();

      verify(
        () => mockAlertManager.showFailureToast("Exception: Comment failed"),
      ).called(1);
    });

    test("saveComments works even when globals are null", () async {
      Globals.request = null;
      Globals.user = null;
      viewModel.comments = "No globals";

      when(() => mockCommonRepository.saveComment(any()))
          .thenAnswer((_) async => "Comment saved");

      await viewModel.saveComments();

      final VerificationResult result = verify(
        () => mockCommonRepository.saveComment(captureAny()),
      );
      final Comment captured = result.captured.single as Comment;

      expect(captured.applicationRefNo, isNull);
      expect(captured.userId, isNull);
      expect(captured.userRole, isNull);
    });
  });

  group("close()", () {
    test("close unregisters draft callback", () async {
      await viewModel.close();
      expect(viewModel.unregisterDraftCallbackCalled, 1);
    });
  });

  group("BusinessVolumeState", () {
    test("constructor sets loaderStatus", () {
      final BusinessVolumeState state = BusinessVolumeState(
        loaderStatus: LoadingStatus.loading,
      );
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final BusinessVolumeState original = BusinessVolumeState(
        loaderStatus: LoadingStatus.loaded,
      );
      final BusinessVolumeState copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final BusinessVolumeState original = BusinessVolumeState(
        loaderStatus: LoadingStatus.loaded,
      );
      final BusinessVolumeState updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
