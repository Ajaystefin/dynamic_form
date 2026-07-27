import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";

import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockAlertManager extends Mock implements AlertManager {}

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

    // Only call real method for safe success-toast branch.
    // Real dialog branch schedules post-frame DialogHelper and can break widget tests.
    if (isCreate == null) {
      super.showDialogSuccessAppRefNo(
        context,
        isCreate: isCreate,
        project: project,
      );
    }
  }
}

class TestableCreateProjectViewModelNoEdit
    extends TestableCreateProjectViewModel {
  @override
  bool get canEdit => false;
}

class _MemStorage implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    (_storage[box] ??= <String, dynamic>{})[key] = value;
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

GoRouter _makeRouter(Widget child) {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        builder: (_, __) => child,
      ),
      GoRoute(
        path: "/facility-summary-view",
        builder: (_, __) => const Scaffold(
          body: Text("Facility Summary"),
        ),
      ),
      GoRoute(
        path: "/home",
        builder: (_, __) => const Scaffold(
          body: Text("Home"),
        ),
      ),
    ],
  );
}

Widget _appTree(Widget child) {
  return ToastificationWrapper(
    child: MaterialApp.router(
      routerConfig: _makeRouter(
        Scaffold(body: child),
      ),
    ),
  );
}

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext ctx;

  await tester.pumpWidget(
    _appTree(
      Builder(
        builder: (context) {
          ctx = context;
          return const SizedBox();
        },
      ),
    ),
  );

  await tester.pump();
  return ctx;
}

Future<BuildContext> _pumpFormContext(
  WidgetTester tester,
  CreateProjectViewModel viewModel, {
  required void Function(String?) onSaved,
}) async {
  late BuildContext ctx;

  await tester.pumpWidget(
    _appTree(
      Builder(
        builder: (context) {
          ctx = context;
          return Form(
            key: viewModel.formKey,
            child: TextFormField(
              initialValue: "value",
              validator: (_) => null,
              onSaved: onSaved,
            ),
          );
        },
      ),
    ),
  );

  await tester.pump();
  return ctx;
}

const MethodChannel _connectivityChannel = MethodChannel(
  "dev.fluttercommunity.plus/connectivity",
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestableCreateProjectViewModel vm;
  late MockProjectRepository mockRepo;
  late MockAlertManager mockAlert;

  setUpAll(() {
    registerFallbackValue(Project());
    registerFallbackValue(Contract());
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue("");
    registerFallbackValue(false);

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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async {
        if (call.method == "check") {
          return "wifi";
        }
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _connectivityChannel,
      null,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      null,
    );
  });

  setUp(() {
    mockRepo = MockProjectRepository();
    mockAlert = MockAlertManager();

    AlertManager.overrideInstance = mockAlert;
    AlertManager.instance = mockAlert;
    LocalStorageService().getStorage = _MemStorage();

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);
    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlert.showWarningToast(any())).thenReturn(null);
    when(() => mockAlert.showInfoToast(any())).thenReturn(null);

    vm = TestableCreateProjectViewModel()
      ..repository = mockRepo
      ..project = Project();

    Globals.onAutoSave = null;
  });

  tearDown(() {
    Globals.onAutoSave = null;
    Globals.request = null;
    Globals.user = null;
  });

  group("constructor and draft getters", () {
    test("initial state and fields are correct", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.project, isA<Project>());
      expect(vm.contracts, isEmpty);
      expect(vm.isCreateProject, isTrue);
      expect(vm.pageMode, PageMode.na);
      expect(vm.canEdit, isFalse);
      expect(vm.selectedDoctype, isNull);
    });

    test("draftModuleKey returns projects key", () {
      expect(vm.draftModuleKey, isNotEmpty);
    });

    test("draftFormKey uses projectCode when present", () {
      vm.project = Project(
        projectCode: "202504PROJ000001",
        projectName: "Project ABC",
      );

      expect(vm.draftFormKey, contains("202504PROJ000001"));
    });

    test("draftFormKey uses projectName when projectCode is null", () {
      vm.project = Project(projectName: "Project X");

      expect(vm.draftFormKey, contains("Project X"));
    });

    test("draftFormKey handles null project name when projectCode is null", () {
      vm.project = Project();

      expect(vm.draftFormKey, contains("null"));
    });

    test("draftHandler returns non-null handler", () {
      expect(vm.draftHandler, isNotNull);
    });

    test("canEdit returns true when pageMode is edit", () {
      vm.pageMode = PageMode.edit;

      expect(vm.canEdit, isTrue);
    });

    test("canEdit returns false when pageMode is not edit", () {
      vm.pageMode = PageMode.na;

      expect(vm.canEdit, isFalse);
    });
  });

  group("init()", () {
    testWidgets("create mode with null Globals.user shows failure toast",
        (WidgetTester tester) async {
      Globals.user = null;
      Globals.request = null;

      final context = await _pumpContext(tester);

      await vm.init(
        context,
        isCreateProjectView: true,
        projectItemView: Project(),
      );

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    testWidgets("edit mode with null Globals.user shows failure toast",
        (WidgetTester tester) async {
      Globals.user = null;
      Globals.request = null;

      final context = await _pumpContext(tester);

      await vm.init(
        context,
        isCreateProjectView: false,
        projectItemView: Project(projectCode: "P-001"),
      );

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("syncModelFromControllers()", () {
    test("filled controllers update project model", () {
      vm
        ..projectNameController.text = "My Project"
        ..ultimateOwnerController.text = "Ultimate Owner"
        ..ownerEntityController.text = "Owner Entity"
        ..ownerRimController.text = "12345"
        ..entityRimController.text = "67890"
        ..projectValueController.text = "1000000"
        ..projectValueCurrentController.text = "500000"
        ..initialProjectValueController.text = "750000"
        ..projectSummaryController.text = "Summary"
        ..projectCompletionController.text = "45.5"
        ..syncModelFromControllers();

      expect(vm.project.projectName, "My Project");
      expect(vm.project.projectUltimateOwnerName, "Ultimate Owner");
      expect(vm.project.projectOwnerEntityName, "Owner Entity");
      expect(vm.project.projectOwnerRimNo, 12345);
      expect(vm.project.projectOwnerEntityRimNo, 67890);
      expect(vm.project.projectValue, "1000000");
      expect(vm.project.projectValueCurrent, "500000");
      expect(vm.project.initialProjectValue, "750000");
      expect(vm.project.projectSummary, "Summary");
      expect(vm.project.projectCompletion, 45.5);
    });

    test("invalid numeric controllers set nullable model fields to null", () {
      vm
        ..ownerRimController.text = "abc"
        ..entityRimController.text = "xyz"
        ..projectCompletionController.text = "bad"
        ..syncModelFromControllers();

      expect(vm.project.projectOwnerRimNo, isNull);
      expect(vm.project.projectOwnerEntityRimNo, isNull);
      expect(vm.project.projectCompletion, isNull);
    });

    test("empty controllers set empty strings and null numeric fields", () {
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

    test("numeric parsing supports negative and decimal completion", () {
      vm
        ..ownerRimController.text = "-10"
        ..entityRimController.text = "-20"
        ..projectCompletionController.text = "12.75"
        ..syncModelFromControllers();

      expect(vm.project.projectOwnerRimNo, -10);
      expect(vm.project.projectOwnerEntityRimNo, -20);
      expect(vm.project.projectCompletion, 12.75);
    });

    test("numeric parsing supports integer completion", () {
      vm.projectCompletionController.text = "100";

      vm.syncModelFromControllers();

      expect(vm.project.projectCompletion, 100);
    });
  });

  group("syncControllersFromModel()", () {
    test("non-null project fields update controllers", () {
      vm.project
        ..projectName = "P1"
        ..projectUltimateOwnerName = "Owner"
        ..projectOwnerEntityName = "Entity"
        ..projectOwnerRimNo = 111
        ..projectOwnerEntityRimNo = 222
        ..projectValue = "9000"
        ..projectValueCurrent = "8000"
        ..initialProjectValue = "7000"
        ..projectSummary = "Project summary"
        ..projectCompletion = 99.0;

      vm.syncControllersFromModel();

      expect(vm.projectNameController.text, "P1");
      expect(vm.ultimateOwnerController.text, "Owner");
      expect(vm.ownerEntityController.text, "Entity");
      expect(vm.ownerRimController.text, "111");
      expect(vm.entityRimController.text, "222");
      expect(vm.projectValueController.text, "9000");
      expect(vm.projectValueCurrentController.text, "8000");
      expect(vm.initialProjectValueController.text, "7000");
      expect(vm.projectSummaryController.text, "Project summary");
      expect(vm.projectCompletionController.text, "99.0");
    });

    test("null project fields update controllers with empty/default values", () {
      vm
        ..project = Project()
        ..syncControllersFromModel();

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

    test("initialProjectValue fallback works independently", () {
      vm.project = Project()
        ..projectName = null
        ..initialProjectValue = null;

      //
      // ignore: cascade_invocations
      vm.syncControllersFromModel();

      expect(vm.projectNameController.text, "");
      expect(vm.initialProjectValueController.text, "Not Available");
    });
  });

  group("date selections", () {
    test("onProjectPeriodSelected sets date and text", () {
      final date = DateTime(2025, 8);

      vm.onProjectPeriodSelected(date);

      expect(vm.projectPeriod, date);
      expect(vm.projectPeriodController.text, isNotEmpty);
    });

    test("onProjectPeriodSelected handles null", () {
      vm.projectPeriodController.text = "old";

      vm.onProjectPeriodSelected(null);

      expect(vm.projectPeriod, isNull);
    });

    test("onLiabilityEndDateSelected sets date and text", () {
      final date = DateTime(2026, 12, 31);

      vm.onLiabilityEndDateSelected(date);

      expect(vm.defectLiabilityEndDate, date);
      expect(vm.defectLiabilityEndDateController.text, isNotEmpty);
    });

    test("onLiabilityEndDateSelected handles null", () {
      vm.defectLiabilityEndDateController.text = "old";

      vm.onLiabilityEndDateSelected(null);

      expect(vm.defectLiabilityEndDate, isNull);
    });
  });

  group("getContractDetailsData()", () {
    test("success assigns contracts and emits loaded", () async {
      final project = Project(projectCode: "PRJ001");
      final contracts = <Contract>[
        Contract(contractCode: "CON-001"),
        Contract(contractCode: "CON-002"),
      ];

      when(() => mockRepo.getProjectContractDetails(project))
          .thenAnswer((_) async => contracts);

      await vm.getContractDetailsData(project);

      expect(vm.contracts, contracts);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockAlert.showFailureToast(any()));
    });

    test("success with empty list", () async {
      final project = Project(projectCode: "PRJ-EMPTY");

      when(() => mockRepo.getProjectContractDetails(project))
          .thenAnswer((_) async => <Contract>[]);

      await vm.getContractDetailsData(project);

      expect(vm.contracts, isEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("null project success", () async {
      when(() => mockRepo.getProjectContractDetails(null)).thenAnswer(
        (_) async => <Contract>[
          Contract(contractCode: "CON-NULL"),
        ],
      );

      await vm.getContractDetailsData(null);

      expect(vm.contracts.first.contractCode, "CON-NULL");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("error shows failure toast", () async {
      final project = Project(projectCode: "ERR");

      when(() => mockRepo.getProjectContractDetails(project))
          .thenThrow(Exception("fail"));

      await vm.getContractDetailsData(project);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("onSave()", () {
    testWidgets("form save is called before validation", (tester) async {
      var saved = false;

      final context = await _pumpFormContext(
        tester,
        vm,
        onSaved: (_) {
          saved = true;
        },
      );

      await vm.onSave(context, isValidate: false);

      expect(saved, isTrue);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    testWidgets("isValidate=false shows failure toast and emits loaded",
        (WidgetTester tester) async {
      final context = await _pumpContext(tester);

      await vm.onSave(context, isValidate: false);

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("create success updates projectCode and shows success toast",
        (WidgetTester tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: true,
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "202504PROJ000777");

      final context = await _pumpContext(tester);

      await vm.onSave(context, isValidate: true);

      expect(vm.project.projectCode, "202504PROJ000777");
      verify(() => mockAlert.showSuccessToast(any())).called(1);
      expect(vm.dialogCalled, isFalse);
    });

    testWidgets("edit success updates projectCode, deletes draft, and dialog",
        (WidgetTester tester) async {
      vm
        ..isCreateProject = false
        ..project = Project(projectCode: "OLD-CODE");

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: false,
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "202504PROJ000888");

      final context = await _pumpContext(tester);

      await vm.onSave(context, isValidate: true);

      expect(vm.project.projectCode, "202504PROJ000888");
      expect(vm.deleteDraftCalled, isTrue);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isFalse);
      verifyNever(() => mockAlert.showFailureToast(any()));
    });

    testWidgets("save throws shows failure toast", (WidgetTester tester) async {
      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenThrow(Exception("save failed"));

      final context = await _pumpContext(tester);

      await vm.onSave(context, isValidate: true);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("onCreate()", () {
    testWidgets("form save is called before validation", (tester) async {
      var saved = false;

      final context = await _pumpFormContext(
        tester,
        vm,
        onSaved: (_) {
          saved = true;
        },
      );

      await vm.onCreate(context, isValidate: false);

      expect(saved, isTrue);
      verify(() => mockAlert.showFailureToast(any())).called(1);
    });

    testWidgets("isValidate=false shows failure toast and emits loaded",
        (WidgetTester tester) async {
      final context = await _pumpContext(tester);

      await vm.onCreate(context, isValidate: false);

      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("returns project code and flips isCreateProject false",
        (WidgetTester tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "202504PROJ000001");

      final context = await _pumpContext(tester);

      await vm.onCreate(context, isValidate: true);

      expect(vm.project.projectCode, "202504PROJ000001");
      expect(vm.isCreateProject, isFalse);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("returns null message and flips isCreateProject false",
        (tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => null);

      final context = await _pumpContext(tester);

      await vm.onCreate(context, isValidate: true);

      expect(vm.project.projectCode, isNull);
      expect(vm.isCreateProject, isFalse);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("returns saved key and does not overwrite projectCode",
        (WidgetTester tester) async {
      vm
        ..isCreateProject = true
        ..project.projectCode = null;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenAnswer((_) async => "project.createNewProject.projectSaved");

      final context = await _pumpContext(tester);

      await vm.onCreate(context, isValidate: true);

      expect(vm.project.projectCode, isNull);
      expect(vm.isCreateProject, isFalse);
      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
    });

    testWidgets("save throws shows failure toast", (WidgetTester tester) async {
      vm.isCreateProject = true;

      when(
        () => mockRepo.saveProjectDetails(
          isCreateProject: any(named: "isCreateProject"),
          project: any(named: "project"),
        ),
      ).thenThrow(Exception("create failed"));

      final context = await _pumpContext(tester);

      await vm.onCreate(context, isValidate: true);

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("navigation methods", () {
    test("onPressedLinkContract create mode does not call autoSave", () {
      vm.isCreateProject = true;

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      try {
        vm.onPressedLinkContract();
      } on Object {
        return;
      }

      expect(called, isFalse);
    });

    test("onPressedLinkContract edit mode canEdit true calls autoSave", () {
      vm
        ..isCreateProject = false
        ..pageMode = PageMode.edit;

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      try {
        vm.onPressedLinkContract();
      } on Object {
        return;
      }

      expect(called, isTrue);
    });

    test("onPressedLinkContract edit mode canEdit false does not call autoSave",
        () {
      final localVm = TestableCreateProjectViewModelNoEdit()
        ..repository = mockRepo
        ..project = Project()
        ..isCreateProject = false;

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      try {
        localVm.onPressedLinkContract();
      } on Object {
        return;
      }

      expect(called, isFalse);
    });

    test("onPressedContractCodeInTable create mode does not autoSave", () {
      vm
        ..isCreateProject = true
        ..contracts = <Contract>[Contract(contractCode: "C-001")];

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      try {
        vm.onPressedContractCodeInTable(0);
      } on Object {
        return;
      }

      expect(called, isFalse);
    });

    test("onPressedContractCodeInTable edit mode canEdit true calls autoSave",
        () {
      vm
        ..isCreateProject = false
        ..pageMode = PageMode.edit
        ..contracts = <Contract>[Contract(contractCode: "C-001")];

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      try {
        vm.onPressedContractCodeInTable(0);
      } on Object {
        return;
      }

      expect(called, isTrue);
    });

    test(
        "onPressedContractCodeInTable edit mode canEdit false does not autoSave",
        () {
      final localVm = TestableCreateProjectViewModelNoEdit()
        ..repository = mockRepo
        ..project = Project()
        ..isCreateProject = false
        ..contracts = <Contract>[Contract(contractCode: "C-002")];

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      try {
        localVm.onPressedContractCodeInTable(0);
      } on Object {
        return;
      }

      expect(called, isFalse);
    });

    testWidgets("onBacktoRequestStatusPressed request null create mode",
        (WidgetTester tester) async {
      Globals.request = null;
      vm.isCreateProject = true;

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      final context = await _pumpContext(tester);

      try {
        await vm.onBacktoRequestStatusPressed(context);
      } on Object {
        return;
      }

      expect(called, isFalse);
    });

    testWidgets("onBacktoRequestStatusPressed request null edit canEdit true",
        (WidgetTester tester) async {
      Globals.request = null;
      vm
        ..isCreateProject = false
        ..pageMode = PageMode.edit;

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      final context = await _pumpContext(tester);

      try {
        await vm.onBacktoRequestStatusPressed(context);
      } on Object {
        return;
      }

      expect(called, isTrue);
    });

    testWidgets("onBacktoRequestStatusPressed request null edit canEdit false",
        (WidgetTester tester) async {
      Globals.request = null;

      final localVm = TestableCreateProjectViewModelNoEdit()
        ..repository = mockRepo
        ..project = Project()
        ..isCreateProject = false;

      var called = false;
      Globals.onAutoSave = () async {
        called = true;
      };

      final context = await _pumpContext(tester);

      try {
        await localVm.onBacktoRequestStatusPressed(context);
      } on Object {
        return;
      }

      expect(called, isFalse);
    });

    testWidgets(
        "onBacktoRequestStatusPressed with request app ref no covers context.go branch",
        (WidgetTester tester) async {
      Globals.request = Request(applicationRefNo: "APP-001");

      final context = await _pumpContext(tester);

      try {
        await vm.onBacktoRequestStatusPressed(context);
      } on Object {
        return;
      }

      expect(Globals.request?.applicationRefNo, "APP-001");
    });
  });

  group("onGenerateSummary()", () {
    test("success calls repository", () async {
      vm.project = Project(projectCode: "P-CODE");

      when(() => mockRepo.generateProjectExposureSummary(any(), any()))
          .thenAnswer((_) async {});

      await vm.onGenerateSummary("PDF");

      verify(
        () => mockRepo.generateProjectExposureSummary("PDF", "P-CODE"),
      ).called(1);
      verifyNever(() => mockAlert.showFailureToast(any()));
    });

    test("null document type calls repository", () async {
      vm.project = Project(projectCode: "P-CODE");

      when(() => mockRepo.generateProjectExposureSummary(any(), any()))
          .thenAnswer((_) async {});

      await vm.onGenerateSummary(null);

      verify(
        () => mockRepo.generateProjectExposureSummary(null, "P-CODE"),
      ).called(1);
    });

    test("throws shows failure toast", () async {
      vm.project = Project(projectCode: "P-CODE");

      when(() => mockRepo.generateProjectExposureSummary(any(), any()))
          .thenThrow(Exception("summary failed"));

      await vm.onGenerateSummary("PDF");

      verify(() => mockAlert.showFailureToast(any())).called(1);
    });
  });

  group("onDiscard()", () {
    testWidgets("form reset path and loaded state", (tester) async {
      final context = await _pumpFormContext(
        tester,
        vm,
        onSaved: (_) {},
      );

      expect(context.mounted, isTrue);

      try {
        vm.onDiscard();
      } on Object {
        return;
      }

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("emits loaded before navigation", () {
      try {
        vm.onDiscard();
      } on Object {
        return;
      }

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("showDialogSuccessAppRefNo()", () {
    testWidgets("isCreate null shows success toast", (WidgetTester tester) async {
      final realVm = CreateProjectViewModel()
        ..repository = mockRepo
        ..project = Project();

      final context = await _pumpContext(tester);

      realVm.showDialogSuccessAppRefNo(
        context,
        project: Project(projectCode: "PRJ-001"),
      );

      verify(() => mockAlert.showSuccessToast(any())).called(1);
    });

    testWidgets("subclass captures isCreate=false branch",
        (WidgetTester tester) async {
      final context = await _pumpContext(tester);

      vm.showDialogSuccessAppRefNo(
        context,
        isCreate: false,
        project: Project(projectCode: "PRJ-002"),
      );

      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isFalse);
      expect(vm.dialogProject?.projectCode, "PRJ-002");
    });

    testWidgets("subclass captures isCreate=true branch",
        (WidgetTester tester) async {
      final context = await _pumpContext(tester);

      vm.showDialogSuccessAppRefNo(
        context,
        isCreate: true,
        project: Project(projectCode: "PRJ-003"),
      );

      expect(vm.dialogCalled, isTrue);
      expect(vm.dialogIsCreate, isTrue);
      expect(vm.dialogProject?.projectCode, "PRJ-003");
    });
  });

  group("role helpers", () {
    test("editAccessRolesCheck returns bool", () {
      expect(vm.editAccessRolesCheck(), isA<bool>());
    });

    test("viewAccessRolesCheck returns bool", () {
      expect(vm.viewAccessRolesCheck(), isA<bool>());
    });
  });

  group("close()", () {
    test("completes normally", () async {
      await expectLater(vm.close(), completes);
    });
  });

  group("ProjectCodeGenerator.generate()", () {
    test("generates expected fixed-date codes", () {
      expect(
        ProjectCodeGenerator.generate(
          serial: 1,
          now: DateTime(2025, 4),
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
          now: DateTime(2025, 4),
        ),
        "202504PROJ000000",
      );
    });

    test("handles serial with more than six digits", () {
      expect(
        ProjectCodeGenerator.generate(
          serial: 1234567,
          now: DateTime(2025),
        ),
        "202501PROJ1234567",
      );
    });

    test("null now uses current date and valid suffix", () {
      final code = ProjectCodeGenerator.generate(serial: 42);

      expect(code, contains("PROJ000042"));
      expect(code.length, 16);
      expect(ProjectCodeGenerator.isValid(code), isTrue);
    });
  });

  group("ProjectCodeGenerator.generateNext()", () {
    test("null lastSerial generates serial 1", () {
      expect(
        ProjectCodeGenerator.generateNext(
          now: DateTime(2025, 4),
        ),
        "202504PROJ000001",
      );
    });

    test("increments provided lastSerial", () {
      expect(
        ProjectCodeGenerator.generateNext(
          lastSerial: 123,
          now: DateTime(2025, 4),
        ),
        "202504PROJ000124",
      );
    });

    test("null now still generates valid code", () {
      final code = ProjectCodeGenerator.generateNext(lastSerial: 9);

      expect(code, contains("PROJ000010"));
      expect(code.length, 16);
    });
  });

  group("ProjectCodeGenerator.isValid()", () {
    test("valid code returns true", () {
      expect(ProjectCodeGenerator.isValid("202504PROJ000001"), isTrue);
    });

    test("invalid month returns false", () {
      expect(ProjectCodeGenerator.isValid("202500PROJ000001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202513PROJ000001"), isFalse);
    });

    test("invalid length returns false", () {
      expect(ProjectCodeGenerator.isValid("202504PROJ00001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202504PROJ0000011"), isFalse);
    });

    test("invalid middle text returns false", () {
      expect(ProjectCodeGenerator.isValid("202504XXXX000001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202504ABCD000001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202504proj000001"), isFalse);
      expect(ProjectCodeGenerator.isValid("202504PROX000001"), isFalse);
    });

    test("invalid serial chars returns false", () {
      expect(ProjectCodeGenerator.isValid("202504PROJABCDEF"), isFalse);
    });

    test("empty string returns false", () {
      expect(ProjectCodeGenerator.isValid(""), isFalse);
    });
  });

  group("projectCodeValidator()", () {
    test("null, empty, spaces return required error", () {
      expect(vm.projectCodeValidator(null), isNotNull);
      expect(vm.projectCodeValidator(""), isNotNull);
      expect(vm.projectCodeValidator("   "), isNotNull);
    });

    test("wrong length returns error", () {
      expect(vm.projectCodeValidator("202504PROJ00001"), isNotNull);
    });

    test("invalid format returns error", () {
      expect(vm.projectCodeValidator("202500PROJ000001"), isNotNull);
      expect(vm.projectCodeValidator("202513PROJ000001"), isNotNull);
      expect(vm.projectCodeValidator("202504XXXX000001"), isNotNull);
      expect(vm.projectCodeValidator("202504ABCD000001"), isNotNull);
    });

    test("valid code returns null", () {
      expect(vm.projectCodeValidator("202504PROJ000001"), isNull);
    });

    test("valid code with spaces is trimmed and returns null", () {
      expect(vm.projectCodeValidator(" 202504PROJ000001 "), isNull);
    });
  });
}
