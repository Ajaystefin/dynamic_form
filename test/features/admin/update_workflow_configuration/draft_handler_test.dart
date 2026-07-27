import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/draft_handler.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class MockUpdateWorkflowConfigViewModel extends Mock
    implements UpdateWorkflowConfigViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UpdateWorkflowConfigDraftHandler handler;
  late MockUpdateWorkflowConfigViewModel vm;

  setUpAll(() {
    registerFallbackValue(Reference());
    registerFallbackValue("");
  });

  setUp(() {
    handler = UpdateWorkflowConfigDraftHandler();
    vm = MockUpdateWorkflowConfigViewModel();
  });

  Reference ref({
    int? id,
    int? typeId,
    String? name,
    String? reference1,
    String? reference2,
    String? reference3,
    String? reference4,
    String? reference5,
    String? status,
    bool? isActive,
  }) {
    return Reference()
      ..id = id
      ..typeId = typeId
      ..name = name
      ..reference1 = reference1
      ..reference2 = reference2
      ..reference3 = reference3
      ..reference4 = reference4
      ..reference5 = reference5
      ..status = status
      ..isActive = isActive;
  }

  void stubVm({
    required bool isDraftReady,
    required Reference draftReference,
    Reference? editingConfig,
    int? customAppTypeId,
    bool isEditMode = true,
    String selectedWorkflowType = "",
    String selectedCustomerSegment = "",
    String selectedCategory = "",
    String selectedApplicationType = "",
    String newApplicationTypeName = "",
    String selectedStatus = "",
  }) {
    when(() => vm.isDraftReady).thenReturn(isDraftReady);
    when(() => vm.draftReference).thenReturn(draftReference);
    when(() => vm.isEditMode).thenReturn(isEditMode);
    when(() => vm.formKey).thenReturn(GlobalKey<FormState>());

    if (editingConfig != null) {
      when(() => vm.editingConfig).thenReturn(editingConfig);
    }

    if (customAppTypeId != null) {
      when(() => vm.customAppTypeId).thenReturn(customAppTypeId);
    }

    when(() => vm.selectedWorkflowType).thenReturn(selectedWorkflowType);
    when(() => vm.selectedCustomerSegment).thenReturn(selectedCustomerSegment);
    when(() => vm.selectedCategory).thenReturn(selectedCategory);
    when(() => vm.selectedApplicationType).thenReturn(selectedApplicationType);
    when(() => vm.newApplicationTypeName).thenReturn(newApplicationTypeName);
    when(() => vm.selectedStatus).thenReturn(selectedStatus);
  }

  group("UpdateWorkflowConfigDraftHandler resolveDraftKey", () {
    test("uses editing config id and custom app type id", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 10, typeId: 20),
        editingConfig: ref(id: 99),
        customAppTypeId: 88,
      );

      expect(handler.resolveDraftKey(vm), "update_workflow_config_88_99");
    });

    test("uses draft reference id and type id when edit and custom ids absent",
        () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 11, typeId: 22),
      );

      expect(handler.resolveDraftKey(vm), "update_workflow_config_22_11");
    });

    test("uses fallback new and na when ids are absent", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(),
      );

      expect(handler.resolveDraftKey(vm), "update_workflow_config_na_new");
    });
  });

  group("UpdateWorkflowConfigDraftHandler buildDraftData", () {
    test("returns skip draft when draft is not ready", () {
      stubVm(
        isDraftReady: false,
        draftReference: ref(id: 1, typeId: 2),
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      final data = handler.buildDraftData(vm);

      expect(data, {"__skip_draft__": true});
    });

    test("returns skip draft when editing config is null", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 1, typeId: 2),
        customAppTypeId: 20,
      );

      final data = handler.buildDraftData(vm);

      expect(data, {"__skip_draft__": true});
    });

    test("builds complete draft data in edit mode", () {
      final draft = ref(
        id: 1,
        typeId: 2,
        name: "Draft Name",
        reference1: "Workflow",
        reference2: "Segment",
        reference3: "Category",
        reference4: "Application",
        reference5: "Y",
        status: "ACTIVE",
        isActive: true,
      );

      stubVm(
        isDraftReady: true,
        draftReference: draft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
        selectedWorkflowType: "Workflow",
        selectedCustomerSegment: "Corporate",
        selectedCategory: "Category A",
        selectedApplicationType: "Application A",
        newApplicationTypeName: "New App Name",
        selectedStatus: "ACTIVE",
      );

      final data = handler.buildDraftData(vm);

      expect(data["customAppTypeId"], 20);
      // expect(data["draft"], draft.toJson());
      expect(data["isEditMode"], true);
      expect(data["editingConfigId"], 10);
      expect(data["selectedWorkflowType"], "Workflow");
      expect(data["selectedCustomerSegment"], "Corporate");
      expect(data["selectedCategory"], "Category A");
      expect(data["selectedApplicationType"], "Application A");
      expect(data["newApplicationTypeName"], "New App Name");
      expect(data["selectedStatus"], "ACTIVE");
    });
  });

  group("UpdateWorkflowConfigDraftHandler applyDraft", () {
    test("does nothing when skip key exists", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 1, typeId: 2),
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {"__skip_draft__": true});

      verifyNever(() => vm.onWorkflowTypeSelected(any<String>()));
      verifyNever(() => vm.draftReference = any<Reference>());
    });

    test("does nothing when editing config is null", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 1, typeId: 2),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "draft": ref(id: 1, typeId: 2).toJson(),
      });

      verifyNever(() => vm.onWorkflowTypeSelected(any<String>()));
      verifyNever(() => vm.draftReference = any<Reference>());
    });

    test("does nothing when draft payload is missing", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 1, typeId: 2),
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 10,
      });

      verifyNever(() => vm.onWorkflowTypeSelected(any<String>()));
      verifyNever(() => vm.draftReference = any<Reference>());
    });

    test("ignores draft when custom app type id mismatches", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 1, typeId: 20),
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 99,
        "editingConfigId": 10,
        "draft": ref(id: 1, typeId: 99).toJson(),
      });

      verifyNever(() => vm.onWorkflowTypeSelected(any<String>()));
      verifyNever(() => vm.draftReference = any<Reference>());
    });

    test("ignores draft when editing config id mismatches", () {
      stubVm(
        isDraftReady: true,
        draftReference: ref(id: 1, typeId: 20),
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 999,
        "draft": ref(id: 1, typeId: 20).toJson(),
      });

      verifyNever(() => vm.onWorkflowTypeSelected(any<String>()));
      verifyNever(() => vm.draftReference = any<Reference>());
    });

    test("applies dropdowns, name, status and merged draft successfully", () {
      final existingDraft = ref(
        id: 1,
        typeId: 20,
        name: "Existing Name",
        reference1: "Existing Workflow",
        reference2: "Existing Segment",
        reference3: "Existing Category",
        reference4: "Existing Application",
        reference5: "Existing Flag",
        status: "OLD",
        isActive: false,
      );

      final savedDraft = ref(
        id: 2,
        typeId: 20,
        name: "Saved Name",
        reference1: "Saved Workflow",
        reference2: "Saved Segment",
        reference3: "Saved Category",
        reference4: "Saved Application",
        reference5: "Y",
        status: "ACTIVE",
        isActive: true,
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
        "selectedWorkflowType": "Workflow Type A",
        "selectedCustomerSegment": "Corporate",
        "selectedCategory": "Category A",
        "selectedApplicationType": "Application A",
        "newApplicationTypeName": "Restored Name",
        "selectedStatus": "ACTIVE",
      });

      verify(() => vm.onWorkflowTypeSelected("Workflow Type A")).called(1);
      verify(() => vm.onCustomerSegmentSelected("Corporate")).called(1);
      verify(() => vm.onCategorySelected("Category A")).called(1);
      verify(() => vm.onApplicationTypeSelected("Application A")).called(1);
      verify(() => vm.onNewApplicationTypeNameChanged("Restored Name"))
          .called(1);
      verify(() => vm.onStatusChanged("ACTIVE")).called(1);

      final captured = verify(
        () => vm.draftReference = captureAny<Reference>(),
      ).captured;

      final merged = captured.single as Reference;

      expect(merged.id, 2);
      expect(merged.typeId, 20);
      expect(merged.name, "Saved Name");
      expect(merged.reference1, "Saved Workflow");
      expect(merged.reference2, "Saved Segment");
      expect(merged.reference3, "Saved Category");
      expect(merged.reference4, "Saved Application");
      expect(merged.reference5, "Y");
      expect(merged.status, "active");
      expect(merged.isActive, true);
    });

    test("does not call cascade methods for blank dropdown values", () {
      final existingDraft = ref(
        id: 1,
        typeId: 20,
        name: "Existing Name",
        reference1: "Existing Workflow",
        reference2: "Existing Segment",
        reference3: "Existing Category",
        reference4: "Existing Application",
        reference5: "N",
        status: "OLD",
        isActive: false,
      );

      final savedDraft = ref(
        id: 2,
        typeId: 20,
        name: "Saved Name",
        reference1: "Saved Workflow",
        reference2: "Saved Segment",
        reference3: "Saved Category",
        reference4: "Saved Application",
        reference5: "Y",
        status: "ACTIVE",
        isActive: true,
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
        "selectedWorkflowType": " ",
        "selectedCustomerSegment": "",
        "selectedCategory": "   ",
        "selectedApplicationType": "",
        "newApplicationTypeName": " ",
        "selectedStatus": " ",
      });

      verifyNever(() => vm.onWorkflowTypeSelected(any<String>()));
      verifyNever(() => vm.onCustomerSegmentSelected(any<String>()));
      verifyNever(() => vm.onCategorySelected(any<String>()));
      verifyNever(() => vm.onApplicationTypeSelected(any<String>()));
      verifyNever(() => vm.onNewApplicationTypeNameChanged(any<String>()));
      verifyNever(() => vm.onStatusChanged(any<String>()));

      verify(() => vm.draftReference = any<Reference>()).called(1);
    });

    test("uses saved draft name when newApplicationTypeName is absent", () {
      final existingDraft = ref(
        id: 1,
        typeId: 20,
        name: "Existing Name",
      );

      final savedDraft = ref(
        id: 2,
        typeId: 20,
        name: "Saved Draft Name",
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
      });

      verify(() => vm.onNewApplicationTypeNameChanged("Saved Draft Name"))
          .called(1);
      verify(() => vm.draftReference = any<Reference>()).called(1);
    });

    test("keeps fallback values when saved draft string fields are blank", () {
      final existingDraft = ref(
        id: 1,
        typeId: 20,
        name: "Existing Name",
        reference1: "Existing Reference 1",
        reference2: "Existing Reference 2",
        reference3: "Existing Reference 3",
        reference4: "Existing Reference 4",
        reference5: "Existing Reference 5",
        status: "EXISTING_STATUS",
        isActive: false,
      );

      final savedDraft = ref(
        name: " ",
        reference1: "",
        reference2: "   ",
        reference3: "",
        reference4: " ",
        status: " ",
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
        "newApplicationTypeName": "",
        "selectedStatus": "",
      });

      final captured = verify(
        () => vm.draftReference = captureAny<Reference>(),
      ).captured;

      final merged = captured.single as Reference;

      expect(merged.id, 1);
      expect(merged.typeId, 20);
      expect(merged.name, "Existing Name");
      expect(merged.reference1, "Existing Reference 1");
      expect(merged.reference2, "Existing Reference 2");
      expect(merged.reference3, "Existing Reference 3");
      expect(merged.reference4, "Existing Reference 4");
      expect(merged.reference5, "Existing Reference 5");
      expect(merged.status, "inactive");
      expect(merged.isActive, false);
    });

    test(
        "uses default reference5 N when saved and fallback reference5 are null",
        () {
      final existingDraft = ref(
        id: 1,
        typeId: 20,
      );

      final savedDraft = ref(
        id: 2,
        typeId: 20,
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 20,
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
      });

      final captured = verify(
        () => vm.draftReference = captureAny<Reference>(),
      ).captured;

      final merged = captured.single as Reference;

      expect(merged.reference5, "N");
    });

    test("uses customAppTypeId when saved draft typeId is null", () {
      final existingDraft = ref(
        id: 1,
      );

      final savedDraft = ref(
        id: 2,
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 55,
      );

      handler.applyDraft(vm, {
        "customAppTypeId": 55,
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
      });

      final captured = verify(
        () => vm.draftReference = captureAny<Reference>(),
      ).captured;

      final merged = captured.single as Reference;

      expect(merged.typeId, 55);
    });

    test("uses existing draftReference typeId when saved and custom are absent",
        () {
      final existingDraft = ref(
        id: 1,
        typeId: 77,
      );

      final savedDraft = ref(
        id: 2,
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
      );

      handler.applyDraft(vm, {
        "editingConfigId": 10,
        "draft": savedDraft.toJson(),
      });

      final captured = verify(
        () => vm.draftReference = captureAny<Reference>(),
      ).captured;

      final merged = captured.single as Reference;

      expect(merged.typeId, 77);
    });

    test("catches exception and does not rethrow", () {
      final existingDraft = ref(
        id: 1,
        typeId: 20,
      );

      final savedDraft = ref(
        id: 2,
        typeId: 20,
      );

      stubVm(
        isDraftReady: true,
        draftReference: existingDraft,
        editingConfig: ref(id: 10),
        customAppTypeId: 20,
      );

      when(() => vm.onWorkflowTypeSelected(any<String>()))
          .thenThrow(Exception("Selection failed"));

      expect(
        () => handler.applyDraft(vm, {
          "customAppTypeId": 20,
          "editingConfigId": 10,
          "draft": savedDraft.toJson(),
          "selectedWorkflowType": "Workflow Type A",
        }),
        returnsNormally,
      );

      verifyNever(() => vm.draftReference = any<Reference>());
    });
  });
}
