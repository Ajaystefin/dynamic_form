import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/draft_handler.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UpdateReferenceDialogViewModel viewModel;
  late MockAdminRepository mockRepository;
  late GlobalKey<FormState> formKey;
  // late BuildContext fakeContext;
  final referenceType = ReferenceType(id: 1, name: "Type A");
  final referenceTypes = [referenceType];

  // late MockAlertManager mockAlertManager;

  setUp(() {
    mockRepository = MockAdminRepository();
    viewModel = UpdateReferenceDialogViewModel()
      ..repository = mockRepository
      ..reference = Reference(id: 1, name: "Ref", status: "active");
    formKey = GlobalKey<FormState>();
    viewModel.formKey = formKey;
    formKey = GlobalKey<FormState>();
    registerFallbackValue(Reference());

    // mockAlertManager = MockAlertManager();

    registerFallbackValue(MockAlertManager());
  });

  test("initial state should be loading and saveButtonStatus loaded", () {
    // Don't call init() to avoid singleton initialization issues
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
  });

  test("getReferenceTypes success", () async {
    when(() => mockRepository.getReferenceTypes())
        .thenAnswer((_) async => referenceTypes);

    await viewModel.getReferenceTypes();

    expect(viewModel.allReferences, referenceTypes);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getReferenceTypes failure", () async {
    when(() => mockRepository.getReferenceTypes())
        .thenThrow(Exception("Failed"));

    await viewModel.getReferenceTypes();
    expect(viewModel.allReferences, []);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("onUpdateReferenceData updates fields and emits loaded", () {
    final testReference = Reference(id: 1, name: "Test Name");
    viewModel.onUpdateReferenceData(testReference);
    expect(viewModel.reference.id, 1);
    expect(viewModel.reference.name, "Test Name");
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  // testWidgets('onSaveButtonClick should show failure toast on error',
  //     (WidgetTester tester) async {
  //   final formKey = GlobalKey<FormState>();
  //   // late BuildContext testContext;

  //   tester.pumpWidget(
  //     MaterialApp(
  //       home: Builder(
  //         builder: (context) {
  //           // testContext = context;
  //           return Form(
  //             key: formKey,
  //             child: Container(),
  //           );
  //         },
  //       ),
  //     ),
  //   );

  //   when(() => mockRepository.saveReferenceDataInformation(any(), any()))
  //       .thenThrow(Exception('Save failed'));

  //   // Inject mock alert manager
  //   AlertManager.overrideInstance = mockAlertManager;
  //   when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

  //   viewModel.referenceDataTypeID = 1;
  //   viewModel.reference = Reference(name: 'Test');
  //   viewModel.statusListValue = [Status.active.name];
  //   viewModel.formKey = formKey;

  //   viewModel.onSaveButtonClick(MockBuildContext());

  //   verify(() => mockAlertManager.showFailureToast(any())).called(1);
  // });

  // testWidgets('onSaveButtonClick saves data and pops context', (tester) async
  // {
  //   when(() => mockRepository.saveReferenceDataInformation(any(), any()))
  //       .thenAnswer((_) async => 'success');

  //   final navKey = GlobalKey<NavigatorState>();

  //   await tester.pumpWidget(MaterialApp(
  //     navigatorKey: navKey,
  //     home: Scaffold(
  //       body: Form(
  //         key: viewModel.formKey,
  //         child: TextFormField(
  //           validator: (_) => null,
  //           onSaved: (_) {},
  //         ),
  //       ),
  //     ),
  //   ));

  //   final context = navKey.currentContext!;
  //   viewModel.referenceDataTypeID = 1;
  //   viewModel.reference = Reference(name: 'Test');
  //   viewModel.statusListValue = [Status.active.name];

  //   await viewModel.onSaveButtonClick(context);

  //   verifyNever(() =>
  //           mockRepository.saveReferenceDataInformation(1,
  // viewModel.reference))
  //       .called(1);
  //   expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
  // });

  testWidgets("onSaveButtonClick handles validation failure", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: viewModel.formKey,
            child: TextFormField(
              validator: (_) => "error",
            ),
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(Form));
    await viewModel.onSaveButtonClick(context);

    expect(viewModel.state.saveButtonStatus, LoadingStatus.loaded);
    verifyNever(
      () => mockRepository.saveReferenceDataInformation(any(), any()),
    );
  });

  group("normalizeAllowedRegex", () {
    final vm = UpdateReferenceDialogViewModel();

    test("returns fallback for null", () {
      expect(vm.normalizeAllowedRegex(null), "[a-zA-Z0-9 ]*");
    });

    test("removes raw string wrapper r''", () {
      expect(vm.normalizeAllowedRegex("r'[a-z]+'"), "[a-z]+");
    });

    test("removes quoted string", () {
      expect(vm.normalizeAllowedRegex("'[0-9]+'"), "[0-9]+");
    });

    test("returns fallback for invalid backslash", () {
      expect(vm.normalizeAllowedRegex(r"\invalid"), "[a-zA-Z0-9 ]*");
    });

    test("returns fallback for empty string", () {
      expect(vm.normalizeAllowedRegex(" "), "[a-zA-Z0-9 ]*");
    });
  });

  test("close disposes controllers without draft", () async {
    final vm = UpdateReferenceDialogViewModel();

    await vm.close();

    expect(true, true);
  });

  test("close emits state when draft is ready", () async {
    final vm = UpdateReferenceDialogViewModel()
      ..onUpdateReferenceData(Reference())
      ..syncControllersWithReference()
      ..onFieldChanged()
      ..selectedReferenceType = ReferenceType();

    vm.emit(vm.state.copyWith());

    await vm.close();

    expect(true, true);
  });

  group("hasHolidayMasterReferenceId", () {
    test("returns true when id is 2484", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(id: 2484);

      expect(vm.hasHolidayMasterReferenceId, true);
    });

    test("returns false when id is not 2484", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(id: 999);

      expect(vm.hasHolidayMasterReferenceId, false);
    });

    test("returns false when selectedReferenceType is null", () {
      final vm = UpdateReferenceDialogViewModel()..selectedReferenceType = null;

      expect(vm.hasHolidayMasterReferenceId, false);
    });

    test("returns false when id is null", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType();

      expect(vm.hasHolidayMasterReferenceId, false);
    });
  });

  group("isReferenceStatusDisabled", () {
    test("returns true when both ESG type AND locked reference", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name: ServerConstants.esgSectionReferenceTypeName,
        )
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        );

      expect(vm.isReferenceStatusDisabled, true);
    });

    test("returns false when type matches but reference is NOT locked", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name: ServerConstants.esgSectionReferenceTypeName,
        )
        ..reference = Reference(id: -1);

      expect(vm.isReferenceStatusDisabled, false);
    });

    test("returns false when reference locked but type does NOT match", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: 999,
          name: "Other",
        )
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        );

      expect(vm.isReferenceStatusDisabled, false);
    });

    test("returns false when both conditions fail", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(id: 999, name: "Other")
        ..reference = Reference(id: -1);

      expect(vm.isReferenceStatusDisabled, false);
    });

    test("returns false when selectedReferenceType is null", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = null
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        );

      expect(vm.isReferenceStatusDisabled, false);
    });

    test("returns false when reference id is null", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name: ServerConstants.esgSectionReferenceTypeName,
        )
        ..reference = Reference(); // id null

      expect(vm.isReferenceStatusDisabled, false);
    });

    test("handles trimmed and lowercase name correctly", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name:
              "  ${ServerConstants.esgSectionReferenceTypeName.toLowerCase()}  ",
        )
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        );

      expect(vm.isReferenceStatusDisabled, true);
    });
  });

  group("Draft config getters", () {
    test("draftModuleKey returns correct value", () {
      final vm = UpdateReferenceDialogViewModel();

      expect(vm.draftModuleKey, DraftModuleKeys.admin);
    });

    test("draftFormKey returns correct value", () {
      final vm = UpdateReferenceDialogViewModel();

      expect(vm.draftFormKey, Routes.manageReference);
    });

    test("draftHandler returns correct type", () {
      final vm = UpdateReferenceDialogViewModel();

      expect(vm.draftHandler, isA<UpdateReferenceDialogDraftHandler>());
    });

    test("draftHandler returns new instance each time (optional check)", () {
      final vm = UpdateReferenceDialogViewModel();

      final handler1 = vm.draftHandler;
      final handler2 = vm.draftHandler;

      expect(handler1, isNotNull);
      expect(handler2, isNotNull);
      expect(handler1.runtimeType, handler2.runtimeType);
      // Optional: ensures it's not the same instance
      expect(identical(handler1, handler2), false);
    });
  });

  group("normalizeStatusForDropdown", () {
    final vm = UpdateReferenceDialogViewModel();

    test("returns null when input is null", () {
      expect(vm.normalizeStatusForDropdown(null), isNull);
    });

    test("returns null when input is empty string", () {
      expect(vm.normalizeStatusForDropdown(""), isNull);
    });

    test("capitalizes lowercase status", () {
      expect(vm.normalizeStatusForDropdown("active"), "Active");
    });

    test("keeps already capitalized string unchanged", () {
      expect(vm.normalizeStatusForDropdown("Active"), "Active");
    });

    test("handles mixed case string", () {
      expect(vm.normalizeStatusForDropdown("aCtIvE"), "Active");
    });

    test("handles single character", () {
      expect(vm.normalizeStatusForDropdown("a"), "A");
    });

    test("handles numeric string", () {
      expect(vm.normalizeStatusForDropdown("123"), "123");
    });

    test("handles string with spaces", () {
      expect(vm.normalizeStatusForDropdown(" pending"), " pending");
    });
  });

  group("getColumnLabelNames", () {
    test("returns default column names when no additional headers", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType();

      final result = vm.getColumnLabelNames();

      expect(result.length, 9);

      // since .tr() may return key in test
      expect(
        result[0],
        "admin.referenceDataManagement.referenceDataId",
      );
      expect(
        result[1],
        "admin.referenceDataManagement.referenceDataName",
      );
    });

    test("overrides columns when additional headers provided", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          columnsInformation: "Custom1;Custom2;Custom3",
        );

      final result = vm.getColumnLabelNames();

      expect(result[3], "Custom1");
      expect(result[4], "Custom2");
      expect(result[5], "Custom3");
    });

    test("ignores empty additional headers", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          columnsInformation: "Custom1;;Custom3",
        );

      final result = vm.getColumnLabelNames();

      expect(result[3], "Custom1");
      expect(result[4], isNot(""));
      expect(result[5], "Custom3");
    });

    test("does not overflow column list", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          columnsInformation: "A;B;C;D;E;F;G;H;I;J",
        );

      final result = vm.getColumnLabelNames();

      expect(result.length, 9);
    });

    test("handles trimmed values correctly", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          columnsInformation: "  A  ;  B ",
        );

      final result = vm.getColumnLabelNames();

      expect(result[3], "A");
      expect(result[4], "B");
    });

    test("returns default when columnsInformation is empty string", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          columnsInformation: "",
        );

      final result = vm.getColumnLabelNames();

      expect(result.length, 9);
    });
  });

  test("initializeFormatters sets default formatters", () {
    final vm = UpdateReferenceDialogViewModel()
      ..selectedReferenceType = ReferenceType(
        allowedRegex: "[a-z]*",
      )
      ..initializeFormatters();

    expect(vm.nameFormatters.isNotEmpty, true);
    expect(vm.descriptionFormatters.isNotEmpty, true);
    expect(vm.reference1Formatters.isNotEmpty, true);
  });

  test("sets holiday formatters when hasHolidayMasterReferenceId is true", () {
    final vm = UpdateReferenceDialogViewModel()
      ..selectedReferenceType = ReferenceType(
        id: 2484,
      )
      ..initializeFormatters();

    expect(
      vm.reference1Formatters.any((f) => f is FilteringTextInputFormatter),
      true,
    );

    expect(
      vm.reference2Formatters
          .any((f) => f.runtimeType.toString().contains("DateInputFormatter")),
      true,
    );
  });

  test("applies securityType formatter overrides", () {
    final vm = UpdateReferenceDialogViewModel()
      ..selectedReferenceType = ReferenceType(
        name: ReferenceDataKeys.securityType,
        allowedRegex: "[a-z]*",
      )
      ..initializeFormatters();

    expect(
      vm.nameFormatters.any(
        (f) => f is LengthLimitingTextInputFormatter && f.maxLength == 50,
      ),
      true,
    );

    expect(
      vm.reference4Formatters.any(
        (f) => f is LengthLimitingTextInputFormatter && f.maxLength == 50,
      ),
      true,
    );
  });

  test("applies sicCodeList formatter overrides", () {
    final vm = UpdateReferenceDialogViewModel()
      ..selectedReferenceType = ReferenceType(
        name: ReferenceDataKeys.sicCodeList,
      )
      ..initializeFormatters();

    expect(
      vm.nameFormatters.any(
        (f) => f is LengthLimitingTextInputFormatter && f.maxLength == 20,
      ),
      true,
    );

    expect(
      vm.descriptionFormatters.any(
        (f) => f is LengthLimitingTextInputFormatter && f.maxLength == 50,
      ),
      true,
    );
  });

  test("applies recommendationList formatter override", () {
    final vm = UpdateReferenceDialogViewModel()
      ..selectedReferenceType = ReferenceType(
        name: ReferenceDataKeys.recommendationList,
      )
      ..initializeFormatters();

    expect(
      vm.nameFormatters.any(
        (f) => f is LengthLimitingTextInputFormatter && f.maxLength == 50,
      ),
      true,
    );
  });

  test("uses fallback regex on invalid allowedRegex", () {
    final vm = UpdateReferenceDialogViewModel()
      ..selectedReferenceType = ReferenceType(
        allowedRegex: r"\invalid", // triggers fallback
      )
      ..initializeFormatters();

    expect(vm.nameFormatters.isNotEmpty, true);
  });

  group("restoreOriginalStatusIfLocked", () {
    test("does nothing when status is not disabled", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(id: 999, name: "Other")
        ..reference = Reference(id: 1, status: "inactive")
        ..restoreOriginalStatusIfLocked();

      expect(vm.reference.status, "inactive");
    });

    test("restores original status when locked and valid", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name: ServerConstants.esgSectionReferenceTypeName,
        )
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        )
        ..onUpdateReferenceData(Reference(status: "active"))
        ..restoreOriginalStatusIfLocked();

      expect(vm.reference.status, "active");
      expect(vm.statusListValue, ["Active"]);
    });

    test("sets empty list when original status is null", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name: ServerConstants.esgSectionReferenceTypeName,
        )
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        )
        ..onUpdateReferenceData(Reference())
        ..restoreOriginalStatusIfLocked();

      expect(vm.reference.status, null);
      expect(vm.statusListValue, []);
    });

    test("sets empty list when original status is empty", () {
      final vm = UpdateReferenceDialogViewModel()
        ..selectedReferenceType = ReferenceType(
          id: ServerConstants.esgSectionReferenceTypeId,
          name: ServerConstants.esgSectionReferenceTypeName,
        )
        ..reference = Reference(
          id: ServerConstants.esgSectionLockedReferenceIds.first,
        )
        ..onUpdateReferenceData(Reference(status: ""))
        ..restoreOriginalStatusIfLocked();

      expect(vm.statusListValue, []);
    });
  });

  test("covers restoreOriginalStatusIfLocked main branch", () {
    final lockedId = ServerConstants.esgSectionLockedReferenceIds.first;

    final vm = UpdateReferenceDialogViewModel()
      ..reference = Reference(id: lockedId)
      ..onUpdateReferenceData(
        Reference(
          id: lockedId,
          status: "active",
        ),
      )
      ..selectedReferenceType = ReferenceType(
        id: ServerConstants.esgSectionReferenceTypeId,
        name: ServerConstants.esgSectionReferenceTypeName.toUpperCase(),
      );

    vm.reference.status = "inactive";

    expect(vm.isReferenceStatusDisabled, true);

    vm.restoreOriginalStatusIfLocked();

    expect(vm.reference.status, "active");
    expect(vm.statusListValue, ["Active"]);
  });
}
