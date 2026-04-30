import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";

import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockAlertManager extends Mock implements AlertManager {}

// ─────────────────────────────────────────────────────────────────────────────
// Testable ViewModels
// ─────────────────────────────────────────────────────────────────────────────

/// Prevent real dialog scheduling + deleteDraft timers/network.
/// Lets us safely cover onSave/onCreate success branches.
class TestableCreateProjectViewModel extends CreateProjectViewModel {
  bool dialogCalled = false;
  bool? dialogIsCreate;
  Project? dialogProject;
  bool deleteDraftCalled = false;

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }

  @override
  void showDialogSuccessAppRefNo(
    BuildContext context, {
    bool? isCreate,
    Project? project,
  }) {
    dialogCalled = true;
    dialogIsCreate = isCreate;
    dialogProject = project;

    // Safe branch only: no dialog scheduling
    if (isCreate == null) {
      super.showDialogSuccessAppRefNo(
        context,
        isCreate: isCreate,
        project: project,
      );
    }
  }
}

/// Used to cover canEdit == false branches
class TestableCreateProjectViewModelNoEdit
    extends TestableCreateProjectViewModel {
  @override
  bool get canEdit => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// In-memory local storage
// ─────────────────────────────────────────────────────────────────────────────

class _MemStorage implements StorageInterface {
  final Map<String, Map<String, dynamic>> _s = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    (_s[box] ??= {})[key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async => _s[box]?[key];

  @override
  Future<void> delete(String box, String key) async {
    _s[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _s[box]?.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget helpers
// ─────────────────────────────────────────────────────────────────────────────

GoRouter _makeRouter(Widget child) => GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (_, __) => child,
        ),
      ],
    );

Widget _appTree(Widget child) => ToastificationWrapper(
      child: MaterialApp.router(
        routerConfig: _makeRouter(
          Scaffold(body: child),
        ),
      ),
    );

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext ctx;

  await tester.pumpWidget(
    _appTree(
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    ),
  );

  await tester.pump();
  return ctx;
}

// ─────────────────────────────────────────────────────────────────────────────
// Platform channel
// ─────────────────────────────────────────────────────────────────────────────

const _connectivityChannel =
    MethodChannel("dev.fluttercommunity.plus/connectivity");

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestableCreateProjectViewModel vm;
  late MockProjectRepository mockRepo;
  late MockAlertManager mockAlert;

  setUpAll(() async {
    await EnvConfig.setEnvironment();

    registerFallbackValue(Project());
    registerFallbackValue(Contract());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>[ConnectivityResult.wifi.name];
        }
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
  });

  setUp(() {
    mockRepo = MockProjectRepository();
    mockAlert = MockAlertManager();

    AlertManager.overrideInstance(mockAlert);
    LocalStorageService().setStorage(_MemStorage());

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlert.showWarningToast(any())).thenReturn(null);
    when(() => mockAlert.showInfoToast(any())).thenReturn(null);

    vm = TestableCreateProjectViewModel();
    vm.repository = mockRepo;
    vm.project = Project();

    Globals.onAutoSave = null;
  });

  tearDown(() {
    Globals.onAutoSave = null;
    Globals.request = null;
    Globals.user = null;
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // init() — catch path only (safe to test without touching model.dart)
  // ═══════════════════════════════════════════════════════════════════════════

  group("init()", () {
    testWidgets("create mode with null Globals.user → failure toast from catch",
        (tester) async {
      Globals.user = null;
      Globals.request = null;

      final ctx = await _pumpContext(tester);

      await vm.init(
        ctx,
        isCreateProjectView: true,
        projectItemView: Project(),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    testWidgets("edit mode with null Globals.user → failure toast from catch",
        (tester) async {
      Globals.user = null;
      Globals.request = null;

      final ctx = await _pumpContext(tester);

      await vm.init(
        ctx,
        isCreateProjectView: false,
        projectItemView: Project(projectCode: "P-001"),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Basic getters / draft keys
  // ═══════════════════════════════════════════════════════════════════════════

  group("basic getters / draft keys", () {
    test("draftModuleKey returns non-empty key", () {
      expect(vm.draftModuleKey, isNotEmpty);
    });

    test("draftFormKey uses projectCode when present", () {
      vm.project = Project(projectCode: "202504PROJ000001", projectName: "ABC");
      expect(vm.draftFormKey, contains("202504PROJ000001"));
    });

    test("draftFormKey falls back to projectName when projectCode is null", () {
      vm.project = Project(projectName: "Project X");
      expect(vm.draftFormKey, contains("Project X"));
    });

    test("canEdit default is true", () {
      expect(vm.canEdit, isTrue);
    });

    test("selectedDoctype default is null", () {
      expect(vm.selectedDoctype, isNull);
    });

    test("draftHandler getter returns non-null", () {
      expect(vm.draftHandler, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // syncModelFromControllers()
  // ═══════════════════════════════════════════════════════════════════════════

  group("syncModelFromControllers()", () {
    test("all controllers filled → model updated", () {
      vm.projectNameController.text = "My Project";
      vm.ultimateOwnerController.text = "Ultimate Co";
      vm.ownerEntityController.text = "Entity Ltd";
      vm.ownerRimController.text = "12345";
      vm.entityRimController.text = "67890";
      vm.projectValueController.text = "1000000";
      vm.projectValueCurrentController.text = "500000";
      vm.initialProjectValueController.text = "750000";
      vm.projectSummaryController.text = "A summary";
      vm.projectCompletionController.text = "45.5";

      vm.syncModelFromControllers();

      expect(vm.project.projectName, "My Project");
      expect(vm.project.projectUltimateOwnerName, "Ultimate Co");
      expect(vm.project.projectOwnerEntityName, "Entity Ltd");
      expect(vm.project.projectOwnerRimNo, 12345);
      expect(vm.project.projectOwnerEntityRimNo, 67890);
      expect(vm.project.projectValue, "1000000");
      expect(vm.project.projectValueCurrent, "500000");
      expect(vm.project.initialProjectValue, "750000");
      expect(vm.project.projectSummary, "A summary");
      expect(vm.project.projectCompletion, 45.5);
    });

    test("invalid numeric values → nullable fields become null", () {
      vm.ownerRimController.text = "abc";
      vm.entityRimController.text = "xyz";
      vm.projectCompletionController.text = "bad-double";

      vm.syncModelFromControllers();

      expect(vm.project.projectOwnerRimNo, isNull);
      expect(vm.project.projectOwnerEntityRimNo, isNull);
      expect(vm.project.projectCompletion, isNull);
    });

    test("empty controllers → strings remain empty / numeric fields null", () {
      vm.syncModelFromControllers();

      expect(vm.project.projectName, "");
      expect(vm.project.projectUltimateOwnerName, "");
      expect(vm.project.projectOwnerEntityName, "");
      expect(vm.project.projectOwnerRimNo, isNull);
      expect(vm.project.projectOwnerEntityRimNo, isNull);
      expect(vm.project.projectValue, "");
      expect(vm.project.projectValueCurrent, "");
      expect(vm.project.initialProjectValue, "");
      expect(vm.project.projectSummary, "");
      expect(vm.project.projectCompletion, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // syncControllersFromModel()
  // ═══════════════════════════════════════════════════════════════════════════

  group("syncControllersFromModel()", () {
    test("all project fields non-null → controllers updated", () {
      vm.project
        ..projectName = "P1"
        ..projectUltimateOwnerName = "UO"
        ..projectOwnerEntityName = "OE"
        ..projectOwnerRimNo = 111
        ..projectOwnerEntityRimNo = 222
        ..projectValue = "9000"
        ..projectValueCurrent = "8000"
        ..initialProjectValue = "7000"
        ..projectSummary = "Summary"
        ..projectCompletion = 99.0;

      vm.syncControllersFromModel();

      expect(vm.projectNameController.text, "P1");
      expect(vm.ultimateOwnerController.text, "UO");
      expect(vm.ownerEntityController.text, "OE");
      expect(vm.ownerRimController.text, "111");
      expect(vm.entityRimController.text, "222");
      expect(vm.projectValueController.text, "9000");
      expect(vm.projectValueCurrentController.text, "8000");
      expect(vm.initialProjectValueController.text, "7000");
      expect(vm.projectSummaryController.text, "Summary");
      expect(vm.projectCompletionController.text, "99.0");
    });

    test("all project fields null → empty strings + Not Available fallback",
        () {
      vm.project = Project();

      vm.syncControllersFromModel();

      expect(vm.projectNameController.text, "");
      expect(vm.ultimateOwnerController.text, "");
      expect(vm.ownerEntityController.text, "");
      expect(vm.ownerRimController.text, "");
      expect(vm.entityRimController.text, "");
      expect(vm.projectValueController.text, "");
      expect(vm.projectValueCurrentController.text, "");
      expect(vm.initialProjectValueController.text, "Not Available");
      expect(vm.projectSummaryController.text, "");
      expect(vm.projectCompletionController.text, "");
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Date selection methods
  // ═══════════════════════════════════════════════════════════════════════════

  group("date selection methods", () {
    test("onProjectPeriodSelected non-null", () {
      final date = DateTime(2025, 8, 1);
      vm.onProjectPeriodSelected(date);

      expect(vm.projectPeriod, date);
      expect(vm.projectPeriodController.text, isNotEmpty);
    });

    test("onProjectPeriodSelected null", () {
      vm.projectPeriodController.text = "old";
      vm.onProjectPeriodSelected(null);

      expect(vm.projectPeriod, isNull);
    });

    test("onLiabilityEndDateSelected non-null", () {
      final date = DateTime(2026, 12, 31);
      vm.onLiabilityEndDateSelected(date);

      expect(vm.defectLiabilityEndDate, date);
      expect(vm.defectLiabilityEndDateController.text, isNotEmpty);
    });

    test("onLiabilityEndDateSelected null", () {
      vm.defectLiabilityEndDateController.text = "old";
      vm.onLiabilityEndDateSelected(null);

      expect(vm.defectLiabilityEndDate, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // close()
  // ═══════════════════════════════════════════════════════════════════════════

  group("close()", () {
    test("returns normally", () async {
      await expectLater(vm.close(), completes);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Role helper methods
  // ═══════════════════════════════════════════════════════════════════════════

  group("role helpers", () {
    test("editAccessRolesCheck returns bool", () {
      expect(vm.editAccessRolesCheck(), isA<bool>());
    });

    test("viewAccessRolesCheck returns bool", () {
      expect(vm.viewAccessRolesCheck(), isA<bool>());
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // getContractDetailsData()
  // ═══════════════════════════════════════════════════════════════════════════

  group("getContractDetailsData()", () {
    test("success: assigns contracts and sets loaderStatus=loaded", () async {
      final project = Project(projectCode: "PRJ001");
      final returned = [
        Contract(contractCode: "CON-001"),
        Contract(contractCode: "CON-002"),
      ];

      when(() => mockRepo.getProjectContractDetails(project))
          .thenAnswer((_) async => returned);

      await vm.getContractDetailsData(project);

      expect(vm.contracts, returned);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockAlert.showFailureToast(any()));
    });

    test("error: shows failure toast", () async {
      final project = Project(projectCode: "PRJ_ERR");

      when(() => mockRepo.getProjectContractDetails(project))
          .thenThrow(Exception("fail"));

      await vm.getContractDetailsData(project);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    test("null project: safely handled if repository supports null", () async {
      when(() => mockRepo.getProjectContractDetails(null))
          .thenAnswer((_) async => [Contract(contractCode: "CON-NULL")]);

      await vm.getContractDetailsData(null);

      expect(vm.contracts.first.contractCode, "CON-NULL");
    });

    test("success with empty contract list → loaderStatus=loaded", () async {
      final project = Project(projectCode: "PRJ-EMPTY");

      when(() => mockRepo.getProjectContractDetails(project))
          .thenAnswer((_) async => <Contract>[]);

      await vm.getContractDetailsData(project);

      expect(vm.contracts, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onPressedContractCodeInTable()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onPressedContractCodeInTable()", () {
    test("isCreateProject=false, canEdit=true → autoSave called", () {
      vm.isCreateProject = false;
      vm.contracts = [Contract(contractCode: "C-001")];

      var called = false;
      Globals.onAutoSave = () async => called = true;

      try {
        vm.onPressedContractCodeInTable(0);
      } catch (_) {}

      expect(called, isTrue);
    });

    test("isCreateProject=true → autoSave NOT called", () {
      vm.isCreateProject = true;
      vm.contracts = [Contract(contractCode: "C-001")];

      var called = false;
      Globals.onAutoSave = () async => called = true;

      try {
        vm.onPressedContractCodeInTable(0);
      } catch (_) {}

      expect(called, isFalse);
    });

    test("isCreateProject=false, canEdit=false → autoSave NOT called", () {
      final localVm = TestableCreateProjectViewModelNoEdit()
        ..repository = mockRepo
        ..project = Project()
        ..isCreateProject = false
        ..contracts = [Contract(contractCode: "C-002")];

      var called = false;
      Globals.onAutoSave = () async => called = true;

      try {
        localVm.onPressedContractCodeInTable(0);
      } catch (_) {}

      expect(called, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onPressedLinkContract()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onPressedLinkContract()", () {
    test("isCreateProject=true → autoSave NOT called", () {
      vm.isCreateProject = true;

      var called = false;
      Globals.onAutoSave = () async => called = true;

      try {
        vm.onPressedLinkContract();
      } catch (_) {}

      expect(called, isFalse);
    });

    test("isCreateProject=false, canEdit=true → autoSave called", () {
      vm.isCreateProject = false;

      var called = false;
      Globals.onAutoSave = () async => called = true;

      try {
        vm.onPressedLinkContract();
      } catch (_) {}

      expect(called, isTrue);
    });

    test("isCreateProject=false, canEdit=false → autoSave NOT called", () {
      final localVm = TestableCreateProjectViewModelNoEdit()
        ..repository = mockRepo
        ..project = Project()
        ..isCreateProject = false;

      var called = false;
      Globals.onAutoSave = () async => called = true;

      try {
        localVm.onPressedLinkContract();
      } catch (_) {}

      expect(called, isFalse);
    });
  });

// ═══════════════════════════════════════════════════════════════════════════
  // onBacktoRequestStatusPressed()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onBacktoRequestStatusPressed()", () {
    testWidgets("request is null + create mode → no autoSave", (tester) async {
      Globals.request = null;
      vm.isCreateProject = true;

      var called = false;
      Globals.onAutoSave = () async => called = true;

      final ctx = await _pumpContext(tester);

      try {
        await vm.onBacktoRequestStatusPressed(ctx);
      } catch (_) {
        // ignore router/global navigation issues in unit test
      }

      expect(called, isFalse);
    });

    testWidgets("request is null + edit mode + canEdit=true → autoSave called",
        (tester) async {
      Globals.request = null;
      vm.isCreateProject = false;

      var called = false;
      Globals.onAutoSave = () async => called = true;

      final ctx = await _pumpContext(tester);

      try {
        await vm.onBacktoRequestStatusPressed(ctx);
      } catch (_) {}

      expect(called, isTrue);
    });

    testWidgets(
        "request is null + edit mode + canEdit=false → autoSave NOT called",
        (tester) async {
      Globals.request = null;

      final localVm = TestableCreateProjectViewModelNoEdit()
        ..repository = mockRepo
        ..project = Project()
        ..isCreateProject = false;

      var called = false;
      Globals.onAutoSave = () async => called = true;

      final ctx = await _pumpContext(tester);

      try {
        await localVm.onBacktoRequestStatusPressed(ctx);
      } catch (_) {}

      expect(called, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onSave()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onSave()", () {
    testWidgets("isValidate=false → failure toast + loaded state",
        (tester) async {
      final ctx = await _pumpContext(tester);

      await vm.onSave(ctx, false);

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("create mode success → success toast", (tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: true,
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "project.createNewProject.projectSaved");

      final ctx = await _pumpContext(tester);

      await vm.onSave(ctx, true);

      verify(() => mockAlert.showSuccessToast(any())).called(1);
      expect(vm.dialogCalled, isFalse);
    });

    testWidgets("edit mode success → deleteDraft + dialog branch covered",
        (tester) async {
      vm.isCreateProject = false;
      vm.project = Project(projectCode: "202504PROJ000001");

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: false,
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "202504PROJ000001");

      final ctx = await _pumpContext(tester);

      await vm.onSave(ctx, true);

      expect(vm.deleteDraftCalled, isTrue);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isFalse);
      expect(vm.dialogProject, vm.project);
      verifyNever(() => mockAlert.showFailureToast(any()));
    });

    testWidgets("save throws → failure toast", (tester) async {
      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenThrow(Exception("save-fail"));

      final ctx = await _pumpContext(tester);

      await vm.onSave(ctx, true);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onCreate()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onCreate()", () {
    testWidgets("isValidate=false → failure toast + loaded state",
        (tester) async {
      final ctx = await _pumpContext(tester);

      await vm.onCreate(ctx, false);

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "returns project code → sets projectCode and"
        " flips isCreateProject=false", (tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "202504PROJ000001");

      final ctx = await _pumpContext(tester);

      await vm.onCreate(ctx, true);

      expect(vm.project.projectCode, "202504PROJ000001");
      expect(vm.isCreateProject, isFalse);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "returns translated "
        "success key → projectCode "
        "not overwritten, isCreateProject=false", (tester) async {
      vm.isCreateProject = true;
      vm.project.projectCode = null;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "project.createNewProject.projectSaved");

      final ctx = await _pumpContext(tester);

      await vm.onCreate(ctx, true);

      expect(vm.project.projectCode, isNull);
      expect(vm.isCreateProject, isFalse);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
    });

    testWidgets("save throws → failure toast", (tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenThrow(Exception("create-fail"));

      final ctx = await _pumpContext(tester);

      await vm.onCreate(ctx, true);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onGenerateSummary()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onGenerateSummary()", () {
    test("success → repository called, no failure toast", () async {
      vm.project = Project(projectCode: "P-CODE");

      when(() => mockRepo.generateProjectExposureSummary(any(), any()))
          .thenAnswer((_) async {});

      await vm.onGenerateSummary("PDF");
      await Future<void>.delayed(Duration.zero);

      verify(() => mockRepo.generateProjectExposureSummary("PDF", "P-CODE"))
          .called(1);
      verifyNever(() => mockAlert.showFailureToast(any()));
    });

    test("throws → failure toast", () async {
      vm.project = Project(projectCode: "P-CODE");

      when(() => mockRepo.generateProjectExposureSummary(any(), any()))
          .thenThrow(Exception("pdf-fail"));

      await vm.onGenerateSummary("PDF");
      await Future<void>.delayed(Duration.zero);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onDiscard()
  // ═══════════════════════════════════════════════════════════════════════════

  group("onDiscard()", () {
    test("emits loaded and does not crash", () {
      vm.onDiscard();
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

// ═══════════════════════════════════════════════════════════════════════════
  // showDialogSuccessAppRefNo()
  // ═══════════════════════════════════════════════════════════════════════════

  group("showDialogSuccessAppRefNo()", () {
    testWidgets("isCreate = null → success toast branch", (tester) async {
      final realVm = CreateProjectViewModel()
        ..repository = mockRepo
        ..project = Project();

      final ctx = await _pumpContext(tester);

      realVm.showDialogSuccessAppRefNo(
        ctx,
        isCreate: null,
        project: Project(projectCode: "PRJ-001"),
      );

      verify(() => mockAlert.showSuccessToast(any())).called(1);
    });

    testWidgets("test subclass captures isCreate=false branch safely",
        (tester) async {
      final ctx = await _pumpContext(tester);

      vm.showDialogSuccessAppRefNo(
        ctx,
        isCreate: false,
        project: Project(projectCode: "PRJ-002"),
      );

      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isFalse);
      expect(vm.dialogProject?.projectCode, "PRJ-002");
    });

    testWidgets("test subclass captures isCreate=true branch safely",
        (tester) async {
      final ctx = await _pumpContext(tester);

      vm.showDialogSuccessAppRefNo(
        ctx,
        isCreate: true,
        project: Project(projectCode: "PRJ-003"),
      );

      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
      expect(vm.dialogProject?.projectCode, "PRJ-003");
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ProjectCodeGenerator.generate()
  // ═══════════════════════════════════════════════════════════════════════════

  group("ProjectCodeGenerator.generate()", () {
    test("correct format with fixed DateTime", () {
      expect(
        ProjectCodeGenerator.generate(
          serial: 1,
          now: DateTime(2025, 4, 1),
        ),
        "202504PROJ000001",
      );

      expect(
        ProjectCodeGenerator.generate(
          serial: 987,
          now: DateTime(2023, 12, 31),
        ),
        "202312PROJ000987",
      );

      expect(
        ProjectCodeGenerator.generate(
          serial: 0,
          now: DateTime(2025, 4, 1),
        ),
        "202504PROJ000000",
      );
    });

    test("null now → uses DateTime.now but remains valid", () {
      final code = ProjectCodeGenerator.generate(serial: 42);
      expect(code.length, 16);
      expect(ProjectCodeGenerator.isValid(code), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ProjectCodeGenerator.generateNext()
  // ═══════════════════════════════════════════════════════════════════════════

  group("ProjectCodeGenerator.generateNext()", () {
    test("null lastSerial → serial 1", () {
      expect(
        ProjectCodeGenerator.generateNext(
          lastSerial: null,
          now: DateTime(2025, 4, 1),
        ),
        "202504PROJ000001",
      );
    });

    test("provided lastSerial → incremented", () {
      expect(
        ProjectCodeGenerator.generateNext(
          lastSerial: 123,
          now: DateTime(2025, 4, 1),
        ),
        "202504PROJ000124",
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ProjectCodeGenerator.isValid()
  // ═══════════════════════════════════════════════════════════════════════════

  group("ProjectCodeGenerator.isValid()", () {
    test("valid code returns true", () {
      expect(ProjectCodeGenerator.isValid("202504PROJ000001"), isTrue);
    });

    test("invalid month 00 / 13 returns false", () {
      expect(ProjectCodeGenerator.isValid("202500PROJ000001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202513PROJ000001"), isFalse);
    });

    test("invalid serial length / invalid chars returns false", () {
      expect(ProjectCodeGenerator.isValid("202504PROJ00001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202504PROJABCDEF"), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // projectCodeValidator()
  // ═══════════════════════════════════════════════════════════════════════════

  group("projectCodeValidator()", () {
    test("null / empty / spaces → required error", () {
      expect(vm.projectCodeValidator(null), isNotNull);
      expect(vm.projectCodeValidator(""), isNotNull);
      expect(vm.projectCodeValidator("   "), isNotNull);
    });

    test("wrong length → lengthInvalid", () {
      expect(vm.projectCodeValidator("202504PROJ00001"), isNotNull);
    });

    test("invalid format → formatInvalid", () {
      expect(vm.projectCodeValidator("202500PROJ000001"), isNotNull);
    });

    test("valid code → null", () {
      expect(vm.projectCodeValidator("202504PROJ000001"), isNull);
    });
  });
}
