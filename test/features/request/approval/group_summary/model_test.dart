import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/group_summary/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS ================= */

class MockRequestRepository extends Mock implements RequestRepository {}

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockEditorController extends Mock implements UnifiedEditorController {}

class MockAlertManager extends Mock implements AlertManager {}

class MockDraftRepository extends Mock implements DraftRepository {}

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

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(CommentsType.groupSummary);
    registerFallbackValue(EntityIdentifier.groupSummary);
  });

  setUp(() {
    requestRepo = MockRequestRepository();
    approvalRepo = MockApprovalRepository();
    commonRepo = MockCommonRepository();
    draftRepo = MockDraftRepository();
    editor = MockEditorController();
    alerts = MockAlertManager();

    RequestRepository.overrideInstance(requestRepo);
    ApprovalRepository.overrideInstance(approvalRepo);
    CommonRepository.overrideInstance(commonRepo);
    DraftRepository.overrideInstance(draftRepo);
    AlertManager.overrideInstance(alerts);

    when(
      () => draftRepo.deleteDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async {});

    Globals.superUserRoles = [
      {"RM": "RM-WCAS"},
    ];

    vm = GroupSummaryViewModel()
      ..repository = requestRepo
      ..approvalRepository = approvalRepo
      ..controller = editor;
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      home: BlocProvider.value(
        value: vm,
        child: Scaffold(body: child),
      ),
    );
  }

  /* ================= BASIC ================= */

  test("initial state", () {
    expect(vm.state.loaderStatus, LoadingStatus.loading);
    expect(vm.state.activeTab, GroupSummaryTabs.ownershipCorporateStructure);
  });

  /* ================= INIT ================= */

  testWidgets("init completes", (tester) async {
    when(() => requestRepo.getApplicationDetails())
        .thenAnswer((_) async => null);
    when(() => approvalRepo.fetchReference()).thenAnswer((_) async {});
    when(() => approvalRepo.getLastAssignedRole())
        .thenAnswer((_) async => Role(roleRM: "RM-WCAS"));
    when(() => approvalRepo.getApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(wrap(const SizedBox()));
    await tester.runAsync(() async {
      await vm.init(tester.element(find.byType(SizedBox)));
    });
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getTabLabel covers all tabs", () {
    for (final tab in GroupSummaryTabs.values) {
      expect(vm.getTabLabel(tab), isNotEmpty);
    }
  });

  /* ================= TEXT ================= */

  test("onTextChange both branches", () {
    vm.onTextChange("<p>&nbsp;</p>");
    expect(vm.canSubmit, false);

    vm.onTextChange("<p>Hello</p>");
    expect(vm.canSubmit, true);
  });

  /* ================= SAVE ================= */

  testWidgets("onSavePress empty", (tester) async {
    when(() => editor.getText()).thenAnswer((_) async => "");

    await tester.pumpWidget(wrap(const SizedBox()));
    await vm.onSavePress(false, context: tester.element(find.byType(SizedBox)));

    verify(() => alerts.showFailureToast(any())).called(1);
  });

  testWidgets("onSavePress success", (tester) async {
    when(() => requestRepo.getApplicationDetails())
        .thenAnswer((_) async => null);

    when(() => approvalRepo.fetchReference()).thenAnswer((_) async {});

    when(() => approvalRepo.getLastAssignedRole())
        .thenAnswer((_) async => Role(roleRM: "RM-WCAS"));

    when(() => approvalRepo.getApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async => []);

    when(() => editor.getText()).thenAnswer((_) async => "<p>OK</p>");

    when(() => approvalRepo.saveApplicationStrategyDetails(any(), any()))
        .thenAnswer((_) async {
      return null;
    });

    final formKey = GlobalKey<FormState>();
    vm.formKey = formKey;

    await tester.pumpWidget(
      wrap(
        Form(
          key: formKey,
          child: const SizedBox(),
        ),
      ),
    );

    await vm.onSavePress(
      false,
      context: tester.element(find.byType(Form)),
    );

    verify(() => alerts.showSuccessToast(any())).called(1);
  });

  testWidgets("onSavePress exception", (tester) async {
    when(() => editor.getText()).thenThrow(Exception("err"));

    await tester.pumpWidget(wrap(const SizedBox()));
    await vm.onSavePress(false, context: tester.element(find.byType(SizedBox)));

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });

  /* ================= COMMENTS ================= */

  testWidgets("getApplicationStrategyDetails match", (tester) async {
    when(() => approvalRepo.getApplicationStrategyDetails(any(), any()))
        .thenAnswer(
      (_) async => [Comment(categoryId: 1, strategyComment: "A")],
    );

    await vm.getApplicationStrategyDetails(1);
    verify(() => editor.setText("A")).called(1);
  });

  testWidgets("getApplicationStrategyDetails no match", (tester) async {
    when(() => approvalRepo.getApplicationStrategyDetails(any(), any()))
        .thenAnswer(
      (_) async => [Comment(categoryId: 9, strategyComment: "B")],
    );

    await vm.getApplicationStrategyDetails(1);
    verify(() => editor.setText("")).called(1);
  });

  testWidgets("getApplicationStrategyDetails exception", (tester) async {
    when(() => approvalRepo.getApplicationStrategyDetails(any(), any()))
        .thenThrow(Exception("api"));

    await vm.getApplicationStrategyDetails(1);
    verify(() => alerts.showFailureToast(any())).called(1);
  });

  /* ================= ROLE ================= */

  test("checkIsInitiated ok", () async {
    when(() => approvalRepo.getLastAssignedRole())
        .thenAnswer((_) async => Role(roleRM: "RM-WCAS"));

    expect(await vm.checkIsInitiated(), "RM");
  });

  test("checkIsInitiated exception", () async {
    when(() => approvalRepo.getLastAssignedRole()).thenThrow(Exception("fail"));

    expect(await vm.checkIsInitiated(), "");
  });

  /* ================= NAVIGATION ================= */

  testWidgets("navigate settles timers", (tester) async {
    await tester.pumpWidget(wrap(const SizedBox()));
    vm.navigate(tester.element(find.byType(SizedBox)));
    await tester.pump(const Duration(seconds: 2));
    expect(vm.state.loaderStatus, isNotNull);
  });
}
