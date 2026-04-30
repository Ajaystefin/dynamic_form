import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

// ── Mocks
// ─────────────────────────────────────────────────────────────────────

class MockAdminRepository extends Mock implements AdminRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class FakeReference extends Fake implements Reference {}

// ── Shared test data
// ──────────────────────────────────────────────────────────

Map<String, List<Reference>> _referenceData() {
  return {
    ReferenceDataKeys.applicationType: [
      Reference(name: "NTB", reference1: "NW", isActive: true),
      Reference(name: "Annual Review", reference1: "AR", isActive: true),
    ],
    ReferenceDataKeys.workflowVariants: [
      Reference(
        name: "MyWorkflow",
        reference1: "Corporate",
        reference2: "FULL",
        reference3: "NW,AR",
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
  WorkflowConfigViewModel vm,
) async {
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
  await tester.runAsync(() async => vm.init(captured));
  await tester.pump();
}

// ── Tests
// ─────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAdminRepository repo;
  late MockReferenceDataService refSvc;

  setUpAll(() {
    registerFallbackValue(FakeReference());
  });

  setUp(() {
    repo = MockAdminRepository();
    refSvc = MockReferenceDataService();

    when(() => refSvc.referenceTypeIds).thenReturn({
      ReferenceDataKeys.customApplicationType: 123,
    });
    when(() => refSvc.getReferenceData(any()))
        .thenAnswer((_) async => _referenceData());
    when(() => refSvc.clearCache(any())).thenAnswer((_) async {});
  });

  WorkflowConfigViewModel createVm() => WorkflowConfigViewModel(
        adminRepository: repo,
        referenceDataServiceFactory: () => refSvc,
      );

  testWidgets("init() loads workflowConfigs from customApplicationType",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.workflowConfigs.length, 1);
    expect(vm.workflowConfigs.first.id, 10);
  });

  testWidgets("resolveAppTypeName returns display name for known code",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.resolveAppTypeName("NW"), "NTB");
    expect(vm.resolveAppTypeName("AR"), "Annual Review");
  });

  testWidgets("resolveAppTypeName falls back to raw code when unknown",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.resolveAppTypeName("UNKNOWN"), "UNKNOWN");
  });

  testWidgets("resolveWorkflowTypeName returns correct workflow for config",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    final Reference config = Reference(
      reference1: "NW",
      reference2: "C",
      reference3: "FULL",
    );
    expect(vm.resolveWorkflowTypeName(config), "MyWorkflow");
  });

  testWidgets(
      "resolveWorkflowTypeName returns empty string when no match found",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    final Reference config = Reference(
      reference1: "UNKNOWN",
      reference2: "C",
      reference3: "FULL",
    );
    expect(vm.resolveWorkflowTypeName(config), "");
  });

  testWidgets("formatCustomerSegment converts codes to labels", (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.formatCustomerSegment("C"), "Corporate");
    expect(vm.formatCustomerSegment("F"), "FI");
    expect(vm.formatCustomerSegment("C,F"), "Corporate, FI");
    expect(vm.formatCustomerSegment(null), "");
    expect(vm.formatCustomerSegment(""), "");
  });

  testWidgets("refreshTable clears cache and reloads workflowConfigs",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    vm.workflowConfigs = [];
    await tester.runAsync(() async => vm.refreshTable());
    await tester.pump();

    expect(vm.workflowConfigs.length, 1);
  });

  testWidgets("getColumnNames returns 7 column headers", (tester) async {
    final WorkflowConfigViewModel vm = createVm();
    await _initVm(tester, vm);

    expect(vm.getColumnNames().length, 7);
  });

  testWidgets("init() emits error state when reference data fetch fails",
      (tester) async {
    final WorkflowConfigViewModel vm = createVm();

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

    when(() => refSvc.getReferenceData(any()))
        .thenThrow(Exception("network error"));

    await tester.runAsync(() async => vm.init(captured));
    await tester.pump();

    expect(vm.state.loaderStatus, LoadingStatus.error);
  });
}
