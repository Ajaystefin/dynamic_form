import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

// ── Mocks
// ─────────────────────────────────────────────────────────────────────

class MockAdminRepository extends Mock implements AdminRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeReference extends Fake implements Reference {}

class FakeRoute extends Fake implements Route<dynamic> {}

// ── Shared test data
// ──────────────────────────────────────────────────────────

Map<String, List<Reference>> _referenceData() {
  return {
    ReferenceDataKeys.applicationType: [
      Reference(name: "NTB", reference1: "NW", isActive: true),
      Reference(name: "Annual Review", reference1: "AR", isActive: true),
    ],
    ReferenceDataKeys.workflowVariants: [
      // Single category → auto-lock
      Reference(
        name: "MyWorkflow",
        reference1: "Corporate",
        reference2: "FULL",
        reference3: "NW,AR",
        isActive: true,
      ),
      // Multi-category workflow
      Reference(
        name: "MultiCatWorkflow",
        reference1: "Corporate",
        reference2: "FULL",
        reference3: "NW",
        isActive: true,
      ),
      Reference(
        name: "MultiCatWorkflow",
        reference1: "Corporate",
        reference2: "MEMO",
        reference3: "AR",
        isActive: true,
      ),
    ],
    ReferenceDataKeys.customApplicationType: [
      Reference(
        id: 10,
        name: "Existing Custom",
        reference1: "NW",
        reference2: "C",
        reference3: "FULL",
        reference5: "N",
        isActive: true,
        typeId: 123,
      ),
    ],
  };
}

// ── Helper
// ────────────────────────────────────────────────────────────────────

Future<void> _initVm(
  WidgetTester tester,
  UpdateWorkflowConfigViewModel vm, {
  Reference? config,
}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) {
          captured = ctx;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() async => vm.init(captured, config));
  await tester.pump();
}

// ── Tests
// ─────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAdminRepository repo;
  late MockReferenceDataService refSvc;
  late MockAlertManager alertManager;

  setUpAll(() {
    registerFallbackValue(FakeReference());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    repo = MockAdminRepository();
    refSvc = MockReferenceDataService();
    alertManager = MockAlertManager();

    when(() => alertManager.showSuccessToast(any())).thenReturn(null);
    when(() => alertManager.showFailureToast(any())).thenReturn(null);
    when(() => refSvc.referenceTypeIds).thenReturn({
      ReferenceDataKeys.customApplicationType: 123,
    });
    when(() => refSvc.getReferenceData(any()))
        .thenAnswer((_) async => _referenceData());
    when(() => refSvc.clearCache(any())).thenAnswer((_) async {});
  });

  UpdateWorkflowConfigViewModel createVm() => UpdateWorkflowConfigViewModel(
        adminRepository: repo,
        referenceDataServiceFactory: () => refSvc,
        alertManager: alertManager,
        trFn: (k) => k,
      );

  // ── init ──────────────────────────────────────────────────────────────────

  testWidgets("init() builds availableWorkflowTypes from variants",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(
      vm.availableWorkflowTypes,
      containsAll(["MyWorkflow", "MultiCatWorkflow"]),
    );
  });

  testWidgets("init() with null config stays in add mode", (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.isEditMode, isFalse);
    expect(vm.selectedWorkflowType, isNull);
  });

  testWidgets("init() with config enters edit mode and restores selections",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    final Reference config = Reference(
      id: 10,
      name: "Existing Custom",
      reference1: "NW",
      reference2: "C",
      reference3: "FULL",
      reference5: "N",
      isActive: true,
      typeId: 123,
    );
    await _initVm(tester, vm, config: config);

    expect(vm.isEditMode, isTrue);
    expect(vm.selectedWorkflowType, "MyWorkflow");
    expect(vm.selectedCustomerSegment, "Corporate");
    expect(vm.selectedCategory, "Full CA");
    expect(vm.selectedApplicationType, "NTB");
    expect(vm.newApplicationTypeName, "Existing Custom");
    expect(vm.selectedStatus, ServerConstants.active);
  });

  // ── selection cascade ─────────────────────────────────────────────────────

  testWidgets(
      "onWorkflowTypeSelected populates"
      " availableSegments and clears downstream", (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm.onWorkflowTypeSelected("MyWorkflow");

    expect(vm.selectedWorkflowType, "MyWorkflow");
    expect(vm.availableSegments, contains("Corporate"));
    expect(vm.selectedCustomerSegment, isNull);
    expect(vm.availableCategoryOptions, isEmpty);
    expect(vm.availableApplicationTypes, isEmpty);
    expect(vm.showCategorySelection, isFalse);
    expect(vm.showApplicationTypeDropdown, isFalse);
    expect(vm.showNewApplicationNameField, isFalse);
  });

  testWidgets(
      "onWorkflowTypeSelected clears all downstream state when changed again",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm
      ..onWorkflowTypeSelected("MyWorkflow")
      ..onCustomerSegmentSelected("Corporate")
      ..onApplicationTypeSelected("NTB")
      // Change workflow — everything downstream must reset
      ..onWorkflowTypeSelected("MultiCatWorkflow");

    expect(vm.selectedCustomerSegment, isNull);
    expect(vm.selectedCategory, isNull);
    expect(vm.selectedApplicationType, isNull);
    expect(vm.availableCategoryOptions, isEmpty);
    expect(vm.availableApplicationTypes, isEmpty);
    expect(vm.showApplicationTypeDropdown, isFalse);
    expect(vm.showNewApplicationNameField, isFalse);
  });

  testWidgets(
      "onCustomerSegmentSelected auto-locks category when only one exists",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm
      ..onWorkflowTypeSelected("MyWorkflow")
      ..onCustomerSegmentSelected("Corporate");

    expect(vm.selectedCategory, "FULL");
    expect(vm.showCategorySelection, isFalse);
    expect(vm.showApplicationTypeDropdown, isTrue);
    expect(
      vm.availableApplicationTypes,
      containsAll(["NTB", "Annual Review"]),
    );
  });

  testWidgets(
      "onCustomerSegmentSelected shows category dropdown when multiple exist",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm
      ..onWorkflowTypeSelected("MultiCatWorkflow")
      ..onCustomerSegmentSelected("Corporate");

    expect(vm.showCategorySelection, isTrue);
    expect(vm.availableCategoryOptions, containsAll(["FULL", "MEMO"]));
    expect(vm.selectedCategory, isNull);
    expect(vm.showApplicationTypeDropdown, isFalse);
  });

  testWidgets(
      "onCategorySelected populates application types for that category",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm
      ..onWorkflowTypeSelected("MultiCatWorkflow")
      ..onCustomerSegmentSelected("Corporate")
      ..onCategorySelected("FULL");

    expect(vm.selectedCategory, "FULL");
    expect(vm.availableApplicationTypes, contains("NTB"));
    expect(vm.showApplicationTypeDropdown, isTrue);
  });

  testWidgets("onApplicationTypeSelected sets showNewApplicationNameField",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm
      ..onWorkflowTypeSelected("MyWorkflow")
      ..onCustomerSegmentSelected("Corporate")
      ..onApplicationTypeSelected("NTB");

    expect(vm.selectedApplicationType, "NTB");
    expect(vm.showNewApplicationNameField, isTrue);
  });

  testWidgets("onNewApplicationTypeNameChanged updates draft name",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm.onNewApplicationTypeNameChanged("  My App  ");

    expect(vm.newApplicationTypeName, "  My App  ");
  });

  testWidgets("onStatusChanged updates selectedStatus", (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm.onStatusChanged(ServerConstants.inactive);
    expect(vm.selectedStatus, ServerConstants.inactive);

    vm.onStatusChanged(ServerConstants.active);
    expect(vm.selectedStatus, ServerConstants.active);
  });

  // ── validation ────────────────────────────────────────────────────────────

  testWidgets("validateNewApplicationTypeName returns error for empty value",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(
      vm.validateNewApplicationTypeName(null),
      "admin.workflowConfig.validation.newApplicationTypeNameRequired",
    );
    expect(
      vm.validateNewApplicationTypeName(""),
      "admin.workflowConfig.validation.newApplicationTypeNameRequired",
    );
    expect(
      vm.validateNewApplicationTypeName("   "),
      "admin.workflowConfig.validation.newApplicationTypeNameRequired",
    );
  });

  testWidgets(
      "validateNewApplicationTypeName returns error when over 100 chars",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(
      vm.validateNewApplicationTypeName("a" * 101),
      "admin.workflowConfig.validation.newApplicationTypeNameMaxLength",
    );
  });

  testWidgets("validateNewApplicationTypeName returns null for valid value",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.validateNewApplicationTypeName("Valid Name"), isNull);
  });

  // ── edit mode ─────────────────────────────────────────────────────────────

  testWidgets("onEditConfig restores inactive status correctly",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    final Reference config = Reference(
      id: 10,
      name: "Test",
      reference1: "AR",
      reference2: "C",
      reference3: "FULL",
      isActive: false,
      typeId: 123,
    );
    vm.onEditConfig(config);

    expect(vm.selectedStatus, ServerConstants.inactive);
    expect(vm.isEditMode, isTrue);
  });

  testWidgets("onEditConfig falls back gracefully when subtype not in variants",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    final Reference config = Reference(
      id: 99,
      name: "Ghost",
      reference1: "GHOST",
      reference2: "C",
      reference3: "FULL",
      isActive: true,
    );
    vm.onEditConfig(config);

    expect(vm.selectedWorkflowType, isNull);
    expect(vm.selectedCustomerSegment, isNull);
    expect(vm.selectedApplicationType, "GHOST");
  });

  // ── save ──────────────────────────────────────────────────────────────────

  testWidgets("onSave sends correct payload with fields set by handlers",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    when(() => repo.saveReferenceDataInformation(any(), any()))
        .thenAnswer((_) async => "OK");

    final MockNavigatorObserver navObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [navObserver],
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => Scaffold(
                    body: Form(
                      key: vm.formKey,
                      child: Builder(
                        builder: (formCtx) => ElevatedButton(
                          onPressed: () => vm.onSave(formCtx),
                          child: const Text("save"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text("open"),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    // Simulate user interactions — each handler sets _draft fields
    vm
      ..onWorkflowTypeSelected("MyWorkflow")
      ..onCustomerSegmentSelected(
        "Corporate",
      ) // auto-locks FULL, sets reference2=C
      ..onApplicationTypeSelected("NTB") // sets reference1=NW
      ..onNewApplicationTypeNameChanged("  My New App  ");

    await tester.tap(find.text("save"));
    await tester.pumpAndSettle();

    final List<dynamic> captured = verify(
      () => repo.saveReferenceDataInformation(captureAny(), captureAny()),
    ).captured;

    final int? typeId = captured[0] as int?;
    final Reference payload = captured[1] as Reference;

    expect(typeId, 123);
    expect(payload.name, "My New App"); // trimmed
    expect(payload.reference1, "NW"); // NTB → NW
    expect(payload.reference2, "C"); // Corporate → C
    expect(payload.reference3, "FULL"); // auto-locked Full CA → FULL
    expect(payload.reference5, "N");
    expect(payload.isActive, isTrue);
    expect(payload.typeId, 123);

    verify(() => navObserver.didPop(any(), any()))
        .called(greaterThanOrEqualTo(1));
  });

  testWidgets("onSave shows failure toast and preserves state on error",
      (tester) async {
    final UpdateWorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    when(() => repo.saveReferenceDataInformation(any(), any()))
        .thenThrow(Exception("server error"));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: vm.formKey,
            child: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => vm.onSave(ctx),
                child: const Text("save"),
              ),
            ),
          ),
        ),
      ),
    );

    vm
      ..onWorkflowTypeSelected("MyWorkflow")
      ..onCustomerSegmentSelected("Corporate")
      ..onApplicationTypeSelected("NTB")
      ..onNewApplicationTypeNameChanged("App Name");

    await tester.tap(find.text("save"));
    await tester.pumpAndSettle();

    verify(() => alertManager.showFailureToast(any())).called(1);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    // Form state must not be reset after error
    expect(vm.selectedWorkflowType, "MyWorkflow");
  });
}
