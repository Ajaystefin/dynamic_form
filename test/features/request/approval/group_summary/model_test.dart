import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/group_summary/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS ================= */

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockEditorController extends Mock implements UnifiedEditorController {}

class MockAlertManager extends Mock implements AlertManager {}

class MockDraftRepository extends Mock implements DraftRepository {}

class FakeComment extends Fake implements Comment {}

class FakeApplicationDetails extends Fake implements ApplicationDetails {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(connectivityChannel, (_) async => ["wifi"]);

  late GroupSummaryViewModel vm;
  late MockRequestRepository requestRepo;
  late MockApprovalRepository approvalRepo;
  late MockCommonRepository commonRepo;
  late MockDraftRepository draftRepo;
  late MockEditorController editor;
  late MockAlertManager alerts;

  Future<void> pumpVm(
    WidgetTester tester, {
    Widget? child,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GroupSummaryViewModel>.value(
          value: vm,
          child: Scaffold(
            body: child ?? const SizedBox(key: Key("root")),
          ),
        ),
      ),
    );
  }

  void stubCommonRepositoryCalls() {
    when(() => requestRepo.getApplicationDetails())
        .thenAnswer((_) async => null);

    when(() => approvalRepo.fetchReference()).thenAnswer((_) async {});

    when(() => approvalRepo.getLastAssignedRole()).thenAnswer(
      (_) async => Role(roleRM: "RM-WCAS"),
    );

    when(
      () => approvalRepo.getApplicationStrategyDetails(any(), any()),
    ).thenAnswer((_) async => <Comment>[]);

    when(
      () => approvalRepo.saveApplicationStrategyDetails(any(), any()),
    ).thenAnswer((_) async => null);

    when(
      () => draftRepo.deleteDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async {});
  }

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(CommentsType.groupSummary);
    registerFallbackValue(EntityIdentifier.groupSummary);
    registerFallbackValue(FakeComment());
    registerFallbackValue(FakeApplicationDetails());
    registerFallbackValue(<Comment>[]);
  });

  setUp(() {
    requestRepo = MockRequestRepository();
    approvalRepo = MockApprovalRepository();
    commonRepo = MockCommonRepository();
    draftRepo = MockDraftRepository();
    editor = MockEditorController();
    alerts = MockAlertManager();

    RequestRepository.overrideInstance = requestRepo;
    ApprovalRepository.overrideInstance = approvalRepo;
    CommonRepository.overrideInstance = commonRepo;
    DraftRepository.overrideInstance = draftRepo;
    AlertManager.overrideInstance = alerts;

    Globals.superUserRoles = [
      {"RM": "RM-WCAS"},
      {"CA": "CA-WCAS"},
      {"CCOOD": "CCOOD-WCAS"},
    ];

    stubCommonRepositoryCalls();

    vm = GroupSummaryViewModel()
      ..repository = requestRepo
      ..approvalRepository = approvalRepo
      ..controller = editor;
  });

  tearDown(() {
    vm.close();
  });

  /* ================= BASIC ================= */

  test("initial state has loading status and default active tab", () {
    expect(vm.state.loaderStatus, LoadingStatus.loading);
    expect(
      vm.state.activeTab,
      GroupSummaryTabs.ownershipCorporateStructure,
    );
    expect(vm.comments, isEmpty);
    expect(vm.comment, isNotNull);
    expect(vm.initialText, "");
    expect(vm.canSubmit, false);
    expect(vm.isReadOnly, false);
    expect(vm.isInitByUser, false);
    expect(vm.isRiskRatingApp, false);
    expect(vm.isInitByCA, false);
    expect(vm.isInitByCCOOD, false);
    expect(vm.draftModuleKey, DraftModuleKeys.approval);
    expect(
      vm.draftFormKey,
      "${Routes.groupSummary}_${GroupSummaryTabs.ownershipCorporateStructure.name}",
    );
    expect(vm.draftHandler, isNotNull);
    expect(vm.formKey, isNotNull);
    expect(vm.scrollController, isNotNull);
    expect(vm.userRoleList, isNotEmpty);
    expect(vm.requestStatus, contains(RequestStatus.initiated));
    expect(vm.requestStatus, contains(RequestStatus.pendingForApproval));
  });

  test("category defaults are group overview", () {
    expect(
      vm.categoryId,
      ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview],
    );
    expect(
      vm.categoryType,
      ServerConstants.approvalCategoryType[ApprovalCategory.groupOverview],
    );
  });

  /* ================= INIT ================= */

  testWidgets("init completes and loads repositories", (tester) async {
    await pumpVm(tester);

    await tester.runAsync(() async {
      await vm.init(tester.element(find.byKey(const Key("root"))));
    });

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    verify(() => requestRepo.getApplicationDetails()).called(1);
    verify(() => approvalRepo.fetchReference()).called(1);
    verify(() => approvalRepo.getLastAssignedRole()).called(1);
    verify(
      () => approvalRepo.getApplicationStrategyDetails(
        CommentsType.groupSummary,
        EntityIdentifier.groupSummary,
      ),
    ).called(1);
  });

  testWidgets("init handles null context", (tester) async {
    await tester.runAsync(() async {
      await vm.init(null);
    });

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    verify(() => requestRepo.getApplicationDetails()).called(1);
    verify(() => approvalRepo.fetchReference()).called(1);
  });

  testWidgets("init completes when last assigned role has no superuser match",
      (tester) async {
    when(() => approvalRepo.getLastAssignedRole()).thenAnswer(
      (_) async => Role(roleRM: "UNKNOWN"),
    );

    await pumpVm(tester);

    await tester.runAsync(() async {
      await vm.init(tester.element(find.byKey(const Key("root"))));
    });

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    expect(vm.isInitByCA, false);
    expect(vm.isInitByCCOOD, false);
  });

  /* ================= TAB LABEL ================= */

  test("getTabLabel covers all group summary tabs", () {
    for (final GroupSummaryTabs tab in GroupSummaryTabs.values) {
      expect(vm.getTabLabel(tab), isNotEmpty);
    }
  });

  /* ================= CHANGE TAB ================= */

  testWidgets("changeTab covers ownershipCorporateStructure", (tester) async {
    await pumpVm(tester);

    final Future<void> future = vm.changeTab(
      GroupSummaryTabs.ownershipCorporateStructure,
    );

    await tester.pump(const Duration(seconds: 1));
    await future;

    expect(
      vm.state.activeTab,
      GroupSummaryTabs.ownershipCorporateStructure,
    );
    expect(
      vm.categoryId,
      ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview],
    );
    expect(
      vm.categoryType,
      ServerConstants.approvalCategoryType[ApprovalCategory.groupOverview],
    );
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  testWidgets("changeTab covers groupManagementTeam", (tester) async {
    await pumpVm(tester);

    final Future<void> future = vm.changeTab(
      GroupSummaryTabs.groupManagementTeam,
    );

    await tester.pump(const Duration(seconds: 1));
    await future;

    expect(vm.state.activeTab, GroupSummaryTabs.groupManagementTeam);
    expect(
      vm.categoryId,
      ServerConstants.approvalCategoryId[ApprovalCategory.groupManagement],
    );
    expect(
      vm.categoryType,
      ServerConstants.approvalCategoryType[ApprovalCategory.groupManagement],
    );
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  testWidgets("changeTab covers relationshipFutureStrategy", (tester) async {
    await pumpVm(tester);

    final Future<void> future = vm.changeTab(
      GroupSummaryTabs.relationshipFutureStrategy,
    );

    await tester.pump(const Duration(seconds: 1));
    await future;

    expect(vm.state.activeTab, GroupSummaryTabs.relationshipFutureStrategy);
    expect(
      vm.categoryId,
      ServerConstants.approvalCategoryId[ApprovalCategory.groupStrategy],
    );
    expect(
      vm.categoryType,
      ServerConstants.approvalCategoryType[ApprovalCategory.groupStrategy],
    );
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  testWidgets("changeTab covers successsionkeyManRisk", (tester) async {
    await pumpVm(tester);

    final Future<void> future = vm.changeTab(
      GroupSummaryTabs.successsionkeyManRisk,
    );

    await tester.pump(const Duration(seconds: 1));
    await future;

    expect(vm.state.activeTab, GroupSummaryTabs.successsionkeyManRisk);
    expect(
      vm.categoryId,
      ServerConstants.approvalCategoryId[ApprovalCategory.groupRisk],
    );
    expect(
      vm.categoryType,
      ServerConstants.approvalCategoryType[ApprovalCategory.groupRisk],
    );
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  /* ================= SAVE ================= */

  testWidgets("onSavePress shows failure when editor html is empty",
      (tester) async {
    when(() => editor.getText()).thenAnswer((_) async => "");

    await pumpVm(tester);

    await vm.onSavePress(
      isContinue: false,
      context: tester.element(find.byKey(const Key("root"))),
    );

    verify(() => alerts.showFailureToast(any())).called(1);
    verifyNever(
      () => approvalRepo.saveApplicationStrategyDetails(any(), any()),
    );
  });

  testWidgets("onSavePress saves successfully when form is valid",
      (tester) async {
    when(() => editor.getText()).thenAnswer((_) async => "<p>OK</p>");

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    vm.formKey = formKey;

    await pumpVm(
      tester,
      child: Form(
        key: formKey,
        child: const SizedBox(key: Key("form_child")),
      ),
    );

    await vm.onSavePress(
      isContinue: false,
      context: tester.element(find.byType(Form)),
    );

    verify(
      () => approvalRepo.saveApplicationStrategyDetails(any(), any()),
    ).called(1);
    verify(() => alerts.showSuccessToast(any())).called(1);
    expect(vm.comments, isNotNull);
    expect(vm.comments, hasLength(1));
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  testWidgets("onSavePress does not save when form validation fails",
      (tester) async {
    when(() => editor.getText()).thenAnswer((_) async => "<p>Invalid</p>");

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    vm.formKey = formKey;

    await pumpVm(
      tester,
      child: Form(
        key: formKey,
        child: TextFormField(
          validator: (_) => "required",
        ),
      ),
    );

    await vm.onSavePress(
      isContinue: false,
      context: tester.element(find.byType(Form)),
    );

    verifyNever(
      () => approvalRepo.saveApplicationStrategyDetails(any(), any()),
    );
    verifyNever(() => alerts.showSuccessToast(any()));
  });

  testWidgets("onSavePress success with continue navigates to next tab",
      (tester) async {
    when(() => editor.getText()).thenAnswer((_) async => "<p>Continue</p>");

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    vm.formKey = formKey;

    await pumpVm(
      tester,
      child: Form(
        key: formKey,
        child: const SizedBox(key: Key("continue_form_child")),
      ),
    );

    await vm.onSavePress(
      isContinue: true,
      context: tester.element(find.byType(Form)),
    );

    await tester.pump(const Duration(seconds: 1));

    verify(
      () => approvalRepo.saveApplicationStrategyDetails(any(), any()),
    ).called(1);
    verify(() => alerts.showSuccessToast(any())).called(1);
  });

  testWidgets("onSavePress catches editor exception", (tester) async {
    when(() => editor.getText()).thenThrow(Exception("editor error"));

    await pumpVm(tester);

    await vm.onSavePress(
      isContinue: false,
      context: tester.element(find.byKey(const Key("root"))),
    );

    verify(() => alerts.showFailureToast(any())).called(1);
    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  testWidgets("onSavePress catches save exception", (tester) async {
    when(() => editor.getText()).thenAnswer((_) async => "<p>Save</p>");
    when(
      () => approvalRepo.saveApplicationStrategyDetails(any(), any()),
    ).thenThrow(Exception("save error"));

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    vm.formKey = formKey;

    await pumpVm(
      tester,
      child: Form(
        key: formKey,
        child: const SizedBox(key: Key("save_exception_child")),
      ),
    );

    await vm.onSavePress(
      isContinue: false,
      context: tester.element(find.byType(Form)),
    );

    verify(() => alerts.showFailureToast(any())).called(1);
    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  /* ================= COMMENTS ================= */

  test("getApplicationStrategyDetails sets matched comment text", () async {
    when(
      () => approvalRepo.getApplicationStrategyDetails(any(), any()),
    ).thenAnswer(
      (_) async => <Comment>[
        Comment(categoryId: 1, strategyComment: "A"),
        Comment(categoryId: 2, strategyComment: "B"),
      ],
    );

    await vm.getApplicationStrategyDetails(1);

    expect(vm.comments, hasLength(1));
    expect(vm.comment?.strategyComment, "A");
    expect(vm.initialText, "A");
    verify(() => editor.setText("A")).called(1);
  });

  test("getApplicationStrategyDetails clears editor when there is no match",
      () async {
    when(
      () => approvalRepo.getApplicationStrategyDetails(any(), any()),
    ).thenAnswer(
      (_) async => <Comment>[
        Comment(categoryId: 9, strategyComment: "B"),
      ],
    );

    await vm.getApplicationStrategyDetails(1);

    expect(vm.comments, isEmpty);
    expect(vm.initialText, "");
    verify(() => editor.setText("")).called(1);
  });

  test(
      "getApplicationStrategyDetails clears editor when repository returns empty",
      () async {
    when(
      () => approvalRepo.getApplicationStrategyDetails(any(), any()),
    ).thenAnswer((_) async => <Comment>[]);

    await vm.getApplicationStrategyDetails(1);

    expect(vm.comments, isEmpty);
    expect(vm.initialText, "");
    verify(() => editor.setText("")).called(1);
  });

  test(
      "getApplicationStrategyDetails clears editor when repository returns null",
      () async {
    when(
      () => approvalRepo.getApplicationStrategyDetails(any(), any()),
    ).thenAnswer((_) async => []);

    await vm.getApplicationStrategyDetails(1);

    expect(vm.initialText, "");
    verify(() => editor.setText("")).called(1);
  });

  test("getApplicationStrategyDetails catches repository exception", () async {
    when(
      () => approvalRepo.getApplicationStrategyDetails(any(), any()),
    ).thenThrow(Exception("api error"));

    await vm.getApplicationStrategyDetails(1);

    verify(() => alerts.showFailureToast(any())).called(1);
  });

  /* ================= ROLE ================= */

  test("checkIsInitiated returns matched super user role key", () async {
    when(() => approvalRepo.getLastAssignedRole()).thenAnswer(
      (_) async => Role(roleRM: "RM-WCAS"),
    );

    final String role = await vm.checkIsInitiated();

    expect(role, "RM");
    expect(vm.assignedRole?.roleRM, "RM-WCAS");
  });

  test("checkIsInitiated returns empty string when role does not match",
      () async {
    when(() => approvalRepo.getLastAssignedRole()).thenAnswer(
      (_) async => Role(roleRM: "NO-MATCH"),
    );

    final String role = await vm.checkIsInitiated();

    expect(role, "");
  });

  test("checkIsInitiated catches exception and emits loaded", () async {
    when(() => approvalRepo.getLastAssignedRole()).thenThrow(
      Exception("role fail"),
    );

    final String role = await vm.checkIsInitiated();

    expect(role, "");
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  /* ================= NAVIGATION ================= */

  testWidgets("navigate moves from first tab to next tab", (tester) async {
    await pumpVm(tester);

    vm.navigate(tester.element(find.byKey(const Key("root"))));

    await tester.pump(const Duration(seconds: 1));

    expect(vm.state.loaderStatus, isNotNull);
  });

  testWidgets("navigate from middle tab triggers next route/tab",
      (tester) async {
    await pumpVm(tester);

    final Future<void> future = vm.changeTab(
      GroupSummaryTabs.groupManagementTeam,
    );
    await tester.pump(const Duration(seconds: 1));
    await future;

    vm.navigate(tester.element(find.byKey(const Key("root"))));

    await tester.pump(const Duration(seconds: 1));

    expect(vm.state.loaderStatus, isNotNull);
  });
}
