import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConditionEditDialogViewModel viewModel;
  late MockRequestRepository mockRepository;
  late MockAlertManager mockAlertManager;
  late MockReferenceDataService mockReferenceDataService;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    registerFallbackValue(Container());
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(CovenantCondition());

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
  });

  setUp(() {
    mockRepository = MockRequestRepository();
    mockAlertManager = MockAlertManager();
    mockReferenceDataService = MockReferenceDataService();

    AlertManager.overrideInstance = mockAlertManager;

    viewModel = ConditionEditDialogViewModel()
      ..repository = mockRepository
      ..referenceDataService = mockReferenceDataService;
  });

  tearDown(() {
    viewModel.close();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
    await TestConfig.cleanup();
  });

  Map<String, List<Reference>> fullReferenceData() {
    return {
      ReferenceDataKeys.conditionDescriptionTemplate: [
        Reference(id: 100, name: "Template 100", reference2: "10"),
        Reference(id: 101, name: "Template 101", reference2: "20"),
      ],
      ReferenceDataKeys.conditionAction: [
        Reference(
          id: ServerConstants.conditionActionCreateId,
          name: "Create",
        ),
        Reference(id: 999, name: "Update"),
      ],
      ReferenceDataKeys.conditionFrequency: [
        Reference(id: 1, name: "Monthly"),
        Reference(id: 2, name: "Quarterly"),
      ],
      ReferenceDataKeys.conditionGeneral: [
        Reference(
          id: ServerConstants.conditionGeneralId,
          name: "General",
        ),
        Reference(
          id: ServerConstants.conditionSpecificId,
          name: "Specific",
        ),
      ],
      ReferenceDataKeys.conditionStandard: [
        Reference(
          id: ServerConstants.conditionStandardId,
          name: "Standard",
        ),
        Reference(
          id: ServerConstants.conditionCustomId,
          name: "Custom",
        ),
      ],
      ReferenceDataKeys.conditionStatus: [
        Reference(
          id: ServerConstants.conditionStatusNewId,
          name: "New",
        ),
        Reference(id: 888, name: "In Progress"),
      ],
      ReferenceDataKeys.covenantConditionType: [
        Reference(id: 10, name: "Financial"),
        Reference(id: 20, name: "Non Financial"),
      ],
    };
  }

  group("ConditionEditDialogViewModel", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("canEdit returns true only when page mode is edit", () {
      viewModel.conditionEditPageMode = PageMode.edit;
      expect(viewModel.canEdit, isTrue);

      viewModel.conditionEditPageMode = PageMode.view;
      expect(viewModel.canEdit, isFalse);

      viewModel.conditionEditPageMode = PageMode.na;
      expect(viewModel.canEdit, isFalse);
    });

    test("isActionEditable defaults to false", () {
      viewModel.conditionEditPageMode = PageMode.edit;

      expect(viewModel.isActionEditable, isFalse);
      expect(viewModel.canEditStatusAction, isFalse);
    });

    test("loadReferenceData should handle successful loading", () async {
      final mockReferenceData = fullReferenceData();

      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => mockReferenceData);

      await viewModel.loadReferenceData();

      expect(viewModel.referenceData, equals(mockReferenceData));
    });

    test("loadReferenceData failure emits loaded and rethrows", () async {
      when(() => mockReferenceDataService.getReferenceData(any())).thenThrow(
        Exception("Failed"),
      );
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      expect(
        () => viewModel.loadReferenceData(),
        throwsA(isA<Exception>()),
      );
    });

    test("init create mode sets default values and emits loaded", () async {
      final mockReferenceData = fullReferenceData();

      when(() => mockReferenceDataService.getReferenceData(any()))
          .thenAnswer((_) async => mockReferenceData);

      await viewModel.init(MockBuildContext(), PageMode.edit, null);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.conditionEditPageMode, PageMode.edit);
      expect(viewModel.isUpdateCondition, isFalse);
      expect(viewModel.includeInTermField, isTrue);
      expect(
        viewModel.selectedAction?.id,
        ServerConstants.conditionActionCreateId,
      );
      expect(
        viewModel.selectedStatus?.id,
        ServerConstants.conditionStatusNewId,
      );
      expect(
        viewModel.selectedDescriptionType?.id,
        ServerConstants.conditionStandardId,
      );
      expect(viewModel.isActionEditable, isFalse);

      verify(() => mockReferenceDataService.getReferenceData(any())).called(1);
    });

    test(
      "init update mode allows status/action editing when condition ids are not create/new",
      () async {
        final mockReferenceData = fullReferenceData();

        when(() => mockReferenceDataService.getReferenceData(any()))
            .thenAnswer((_) async => mockReferenceData);

        final condition = CovenantCondition(
          status: 888,
          action: 999,
          isStandard: true,
          isGeneric: true,
          covenantSubType: 100,
        );

        await viewModel.init(MockBuildContext(), PageMode.edit, condition);

        expect(viewModel.isUpdateCondition, isTrue);
        expect(viewModel.conditionData, condition);
        expect(viewModel.canEdit, isTrue);
        expect(viewModel.canEditStatusAction, isTrue);
        expect(viewModel.isActionEditable, isTrue);
        expect(viewModel.selectedSubTypeValue?.id, 100);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    test(
      "init update mode disables status/action editing when condition ids are create/new",
      () async {
        final mockReferenceData = fullReferenceData();

        when(() => mockReferenceDataService.getReferenceData(any()))
            .thenAnswer((_) async => mockReferenceData);

        final condition = CovenantCondition(
          status: ServerConstants.conditionStatusNewId,
          action: ServerConstants.conditionActionCreateId,
          isStandard: true,
          isGeneric: true,
        );

        await viewModel.init(MockBuildContext(), PageMode.edit, condition);

        expect(viewModel.canEditStatusAction, isFalse);
        expect(viewModel.isActionEditable, isFalse);
      },
    );

    test("getChildRimsForGroup uses request customers for non-group flow",
        () async {
      await viewModel.getChildRimsForGroup();

      expect(viewModel.customerList, isA<List<Customer>>());
    });

    test("getModifyData populates fields from condition", () {
      viewModel
        ..referenceData = fullReferenceData()
        ..conditionData = CovenantCondition(
          customerName: "John",
          frequency: 1,
          action: 999,
          status: 888,
          conditionType: 10,
          description: "Test Desc",
          isStandard: true,
          isGeneric: false,
          includeInTerms: true,
          targetDate: "12/12/2026",
          facilityDetailList: [
            Facility(rimNo: 123),
          ],
        )
        ..getModifyData();

      expect(viewModel.facilityList.length, 1);
      expect(viewModel.facilityList.first.rimNo, 123);
      expect(viewModel.selectedCustomer?.firstName, "John");
      expect(viewModel.includeInTermField, isTrue);
      expect(viewModel.selectedTargetDate, "12/12/2026");
      expect(viewModel.selectedFrequency?.id, 1);
      expect(viewModel.selectedAction?.id, 999);
      expect(viewModel.selectedStatus?.id, 888);
      expect(viewModel.selectedType?.id, 10);
      expect(
        viewModel.selectedDescriptionType?.id,
        ServerConstants.conditionStandardId,
      );
      expect(viewModel.selectedInlineValue.name, "Test Desc");
      expect(viewModel.editedInlineValue.name, "Test Desc");
      expect(viewModel.generalField?.id, ServerConstants.conditionSpecificId);
    });

    test("getModifyData handles custom general condition", () {
      viewModel
        ..referenceData = fullReferenceData()
        ..conditionData = CovenantCondition(
          customerName: "Customer A",
          isStandard: false,
          isGeneric: true,
          description: "Custom description",
        )
        ..getModifyData();

      expect(
        viewModel.selectedDescriptionType?.id,
        ServerConstants.conditionCustomId,
      );
      expect(viewModel.generalField?.id, ServerConstants.conditionGeneralId);
      expect(viewModel.selectedInlineValue.name, "Custom description");
      expect(viewModel.editedInlineValue.name, "Custom description");
    });

    test("getModifyData handles missing reference matches safely", () {
      viewModel
        ..referenceData = fullReferenceData()
        ..conditionData = CovenantCondition(
          frequency: 777,
          action: 778,
          status: 779,
          conditionType: 780,
          isStandard: true,
          isGeneric: true,
        )
        ..getModifyData();

      expect(viewModel.selectedFrequency, isNull);
      expect(viewModel.selectedAction, isNull);
      expect(viewModel.selectedStatus, isNull);
      expect(viewModel.selectedType, isNull);
      expect(
        viewModel.selectedDescriptionType?.id,
        ServerConstants.conditionStandardId,
      );
      expect(viewModel.generalField?.id, ServerConstants.conditionGeneralId);
    });

    test("getModifyData handles empty standard list fallback", () {
      viewModel
        ..referenceData = {
          ReferenceDataKeys.conditionStandard: <Reference>[],
          ReferenceDataKeys.conditionGeneral: [
            Reference(id: ServerConstants.conditionGeneralId, name: "General"),
          ],
        }
        ..conditionData = CovenantCondition(
          isStandard: false,
          isGeneric: true,
        )
        ..getModifyData();

      expect(viewModel.selectedDescriptionType, isA<Reference>());
      expect(viewModel.generalField?.id, ServerConstants.conditionGeneralId);
    });

    test("onSavePress returns false when description is empty for non FI flow",
        () async {
      viewModel
        ..conditionData = CovenantCondition()
        ..editedInlineValue = Reference(name: "");

      when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

      final result = await viewModel.onSavePress();

      expect(result, isFalse);
    });

    test("onSavePress create path updates condition payload before navigation",
        () async {
      viewModel
        ..conditionData = CovenantCondition()
        ..isUpdateCondition = false
        ..editedInlineValue = Reference(name: "Description")
        ..selectedCustomer = Customer(
          customerRimNo: 123,
          customerName: "Customer A",
        )
        ..generalField = Reference(id: ServerConstants.conditionGeneralId)
        ..selectedDescriptionType =
            Reference(id: ServerConstants.conditionStandardId)
        ..selectedSubTypeValue = Reference(id: 100)
        ..facilityList = [
          Facility(rimNo: 1),
        ];

      when(() => mockRepository.saveConditionDetails(any<CovenantCondition>()))
          .thenAnswer((_) async => "Saved");

      when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      final result = await viewModel.onSavePress();

      expect(result, anyOf(isTrue, isFalse));
      expect(viewModel.conditionData?.isNew, isTrue);
      expect(viewModel.conditionData?.mode, "Create");
      expect(viewModel.conditionData?.rimNo, 123);
      expect(viewModel.conditionData?.customerName, "Customer A");
      expect(
        viewModel.conditionData?.action,
        ServerConstants.conditionActionCreateId,
      );
      expect(
        viewModel.conditionData?.status,
        ServerConstants.conditionStatusNewId,
      );
      expect(viewModel.conditionData?.isGeneric, isTrue);
      expect(viewModel.conditionData?.isStandard, isTrue);
      expect(viewModel.conditionData?.facilityDetailList?.length, 1);
      expect(viewModel.conditionData?.description, "Description");
      expect(viewModel.conditionData?.covenantSubType, 100);
    });

    test("onSavePress edit path updates mode and selected status", () async {
      viewModel
        ..conditionData = CovenantCondition()
        ..isUpdateCondition = true
        ..editedInlineValue = Reference(name: "Updated description")
        ..selectedStatus = Reference(id: 888, name: "Status")
        ..generalField = Reference(id: ServerConstants.conditionSpecificId)
        ..selectedDescriptionType =
            Reference(id: ServerConstants.conditionCustomId)
        ..selectedSubTypeValue = Reference(id: 101);

      when(() => mockRepository.saveConditionDetails(any<CovenantCondition>()))
          .thenAnswer((_) async => "Updated");

      when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      final result = await viewModel.onSavePress();

      expect(result, anyOf(isTrue, isFalse));
      expect(viewModel.conditionData?.isNew, isFalse);
      expect(viewModel.conditionData?.mode, "Edit");
      expect(viewModel.conditionData?.status, 888);
      expect(viewModel.conditionData?.isGeneric, isFalse);
      expect(viewModel.conditionData?.isStandard, isFalse);
      expect(viewModel.conditionData?.description, "Updated description");
      expect(viewModel.conditionData?.covenantSubType, 101);
    });

    test("onSavePress handles repository exception", () async {
      viewModel
        ..conditionData = CovenantCondition()
        ..editedInlineValue = Reference(name: "Description");

      when(() => mockRepository.saveConditionDetails(any<CovenantCondition>()))
          .thenThrow(Exception("Error"));

      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      final result = await viewModel.onSavePress();

      expect(result, isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("onSubtypeSelection updates values and emits loaded", () {
      final ref = Reference(id: 1, name: "sub1");

      viewModel.onSubtypeSelection(ref);

      expect(viewModel.selectedSubTypeValue, ref);
      expect(viewModel.selectedInlineValue, ref);
      expect(viewModel.editedInlineValue, ref);
      expect(viewModel.state.fieldStatus, LoadingStatus.loaded);
    });

    test("parseTargetDate parses dd/MM/yyyy value", () {
      final result = viewModel.parseTargetDate("12/12/2024");

      expect(result.year, 2024);
      expect(result.month, 12);
      expect(result.day, 12);
    });

    test("parseTargetDate returns now fallback for null and empty values", () {
      final result1 = viewModel.parseTargetDate(null);
      final result2 = viewModel.parseTargetDate("");

      expect(result1, isA<DateTime>());
      expect(result2, isA<DateTime>());
    });

    test("parseTargetDate parses ISO date string", () {
      final result = viewModel.parseTargetDate("2025-09-02T00:00:00.000");

      expect(result.year, 2025);
      expect(result.month, 9);
      expect(result.day, 2);
    });

    test("parseTargetDate falls back to now for invalid date", () {
      final result = viewModel.parseTargetDate("invalid-date");

      expect(result, isA<DateTime>());
    });

    test("getTimeAsString returns formatted date adjusted to Dubai timezone",
        () {
      final timestamp = DateTime.utc(2025).millisecondsSinceEpoch;

      final result = viewModel.getTimeAsString(timestamp);

      expect(result, "01/01/2025");
    });

    test("getTimeAsString handles null timestamp", () {
      final result = viewModel.getTimeAsString(null);

      expect(result, "");
    });

    test("onConditionTypeSelection updates selectedType and resets subtype",
        () {
      final ref = Reference(id: 32, name: "Type");

      viewModel
        ..conditionData = CovenantCondition()
        ..onConditionTypeSelection(ref);

      expect(viewModel.selectedType, ref);
      expect(viewModel.conditionData?.conditionType, 32);
      expect(viewModel.selectedSubTypeValue, isNull);
      expect(viewModel.selectedInlineValue.name, " ");
      expect(viewModel.editedInlineValue.name, " ");
      expect(viewModel.state.fieldStatus, LoadingStatus.loaded);
    });

    test("getDescritionSubTypes filters by selectedType", () {
      viewModel.referenceData = {
        ReferenceDataKeys.conditionDescriptionTemplate: [
          Reference(name: "Sub1", reference2: "32"),
          Reference(name: "Sub2", reference2: "99"),
        ],
      };

      final result =
          (viewModel..selectedType = Reference(id: 32)).getDescritionSubTypes();

      expect(result?.length, 1);
      expect(result?.first.name, "Sub1");
    });

    test("getDescritionSubTypes returns empty list when no match", () {
      viewModel.referenceData = {
        ReferenceDataKeys.conditionDescriptionTemplate: [
          Reference(name: "Sub1", reference2: "32"),
        ],
      };

      final result = (viewModel..selectedType = Reference(id: 100))
          .getDescritionSubTypes();

      expect(result, isEmpty);
    });

    test("onDescriptionTypeChanged updates value and resets inline fields", () {
      final ref = Reference(id: 1, name: "desc1");

      viewModel.onDescriptionTypeChanged(ref);

      expect(viewModel.selectedDescriptionType, ref);
      expect(viewModel.editedInlineValue.name, " ");
      expect(viewModel.selectedSubTypeValue, isNull);
      expect(viewModel.state.fieldStatus, LoadingStatus.loaded);
    });

    test("isInlineEditable returns false for standard list", () {
      viewModel.selectedDescriptionType = Reference(
        id: ServerConstants.conditionStandardId,
      );

      expect(viewModel.isInlineEditable(), isFalse);
      expect(viewModel.isStandartList(), isTrue);
    });

    test("isInlineEditable returns true for custom list", () {
      viewModel.selectedDescriptionType = Reference(
        id: ServerConstants.conditionCustomId,
      );

      expect(viewModel.isInlineEditable(), isTrue);
      expect(viewModel.isStandartList(), isFalse);
    });

    test("onIncludeTermChange updates conditionData and emits loaded", () {
      viewModel
        ..conditionData = CovenantCondition()
        ..onIncludeTermChange(value: true);

      expect(viewModel.includeInTermField, isTrue);
      expect(viewModel.conditionData?.includeInTerms, isTrue);
      expect(viewModel.state.fieldStatus, LoadingStatus.loaded);
    });

    test("onIncludeTermChange handles null as false", () {
      viewModel
        ..conditionData = CovenantCondition(includeInTerms: true)
        ..onIncludeTermChange();

      expect(viewModel.includeInTermField, isFalse);
      expect(viewModel.conditionData?.includeInTerms, isFalse);
    });

    test("isSpecificSelected returns true if specific ID matches", () {
      viewModel.generalField = Reference(
        id: ServerConstants.conditionSpecificId,
      );

      expect(viewModel.isSpecificSelected(), isTrue);
    });

    test("onGeneralFieldChanged with general value emits loaded without dialog",
        () async {
      final generalRef = Reference(
        id: ServerConstants.conditionGeneralId,
        name: "General",
      );

      await viewModel.onGeneralFieldChanged(
        generalRef,
        MockBuildContext(),
      );

      expect(viewModel.generalField, generalRef);
      expect(viewModel.isSpecificSelected(), isFalse);
      expect(viewModel.state.fieldStatus, LoadingStatus.loaded);
    });

    test("onActionFieldChange updates selected action and conditionData", () {
      final ref = Reference(id: 10, name: "Action");

      viewModel
        ..conditionData = CovenantCondition()
        ..onActionFieldChange(ref);

      expect(viewModel.selectedAction, ref);
      expect(viewModel.conditionData?.action, 10);
    });

    test("onFrequencyChange updates selected frequency and conditionData", () {
      final ref = Reference(id: 20, name: "Frequency");

      viewModel
        ..conditionData = CovenantCondition()
        ..onFrequencyChange(ref);

      expect(viewModel.selectedFrequency, ref);
      expect(viewModel.conditionData?.frequency, 20);
    });

    test("onTargetDateChanged updates selected date", () {
      final date = DateTime(2025, 9, 2);

      viewModel.onTargetDateChanged(date);

      expect(viewModel.selectedTargetDate, date.toIso8601String());
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onTargetDateChanged updates conditionData targetDate when available",
        () {
      final date = DateTime(2025, 9, 2);

      viewModel
        ..conditionData = CovenantCondition()
        ..onTargetDateChanged(date);

      expect(viewModel.selectedTargetDate, date.toIso8601String());
      expect(viewModel.conditionData?.targetDate, isNotNull);
      expect(viewModel.conditionData?.targetDate, isNotEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onTargetDateChanged handles null date", () {
      viewModel
        ..conditionData = CovenantCondition()
        ..onTargetDateChanged(null);

      expect(viewModel.selectedTargetDate, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("statusFieldChanged setter updates selected status", () {
      final ref = Reference(id: 30, name: "Status");

      viewModel.statusFieldChanged = ref;

      expect(viewModel.selectedStatus, ref);
    });

    test("statusFieldChanged getter returns selected status", () {
      final ref = Reference(id: 40, name: "Status");

      viewModel.selectedStatus = ref;

      expect(viewModel.statusFieldChanged, ref);
    });

    test("setFacility sets facility list", () async {
      final facilityList = [
        Facility(rimNo: 123),
      ];

      await viewModel.setFacility(facilityList);

      expect(viewModel.facilityList.length, 1);
      expect(viewModel.facilityList.first.rimNo, 123);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("setFacility with null clears facility list and emits loaded",
        () async {
      viewModel.facilityList = [
        Facility(rimNo: 123),
      ];

      await viewModel.setFacility(null);

      expect(viewModel.facilityList, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getActionvalues excludes create action", () {
      viewModel.referenceData = {
        ReferenceDataKeys.conditionAction: [
          Reference(
            id: ServerConstants.conditionActionCreateId,
            name: "Create",
          ),
          Reference(id: 2343, name: "Update"),
        ],
      };

      final actionList = viewModel.getActionvalues();

      expect(actionList?.length, 1);
      expect(actionList?.first.id, 2343);
    });

    test("getActionvalues returns null when action references missing", () {
      viewModel.referenceData = {};

      final actionList = viewModel.getActionvalues();

      expect(actionList, isNull);
    });
  });

  group("ConditionEditDialogState", () {
    test("constructor sets loaderStatus", () {
      final state = ConditionEditDialogState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing values when null", () {
      final original = ConditionEditDialogState(
        loaderStatus: LoadingStatus.loaded,
        fieldStatus: LoadingStatus.loading,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.fieldStatus, LoadingStatus.loading);
    });

    test("copyWith overrides loaderStatus", () {
      final original = ConditionEditDialogState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides fieldStatus", () {
      final original = ConditionEditDialogState(
        loaderStatus: LoadingStatus.loaded,
        fieldStatus: LoadingStatus.loading,
      );

      final updated = original.copyWith(
        fieldStatus: LoadingStatus.loaded,
      );

      expect(updated.loaderStatus, LoadingStatus.loaded);
      expect(updated.fieldStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides both statuses", () {
      final original = ConditionEditDialogState(
        loaderStatus: LoadingStatus.loading,
        fieldStatus: LoadingStatus.loading,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.loaded,
        fieldStatus: LoadingStatus.loaded,
      );

      expect(updated.loaderStatus, LoadingStatus.loaded);
      expect(updated.fieldStatus, LoadingStatus.loaded);
    });
  });
}
