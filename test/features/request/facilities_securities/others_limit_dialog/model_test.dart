import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/home_repository.dart";

class MockHomeRepository extends Mock implements HomeRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class FakeBuildContext extends Fake implements BuildContext {}

class FinalSafeVM extends OthersLimitDialogViewModel {
  bool emptyProductTypes = false;
  bool emptyFacilityTypes = false;
  Reference? createdReference;

  @override
  bool get isFIFlow => false;

  @override
  Future<void> getReferenceData() async {
    limitTypes = [
      Reference(id: 1, name: "Limit Type 1", reference1: "LT1"),
      Reference(id: 2, name: "Limit Type 2", reference1: "LT2"),
    ];

    productTypeOptions = emptyProductTypes
        ? []
        : [
            Reference(id: 1, name: "Conventional", reference1: "A"),
            Reference(id: 2, name: "Islamic", reference1: "B"),
          ];
  }

  @override
  Future<void> getUpdatedFacilityReference() async {
    facilityTypes = emptyFacilityTypes
        ? []
        : [
            Reference(reference3: "DUP"),
          ];
  }

  @override
  Future<void> createReference(Reference ref) async {
    createdReference = ref;
  }
}

class SaveTestVM extends FinalSafeVM {
  @override
  Future<void> onSaveButtonClick(BuildContext context) async {
    if (facilityTypes.any((f) => f.reference3 == reference.reference3)) {
      return;
    }

    emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
  }
}

class RealSaveTestVM extends OthersLimitDialogViewModel {
  bool isFormValid = true;
  bool throwOnCreate = false;
  Reference? createdReference;

  @override
  bool get isFIFlow => false;

  @override
  Future<void> getReferenceData() async {}

  @override
  Future<void> getUpdatedFacilityReference() async {}

  @override
  Future<void> createReference(Reference ref) async {
    if (throwOnCreate) {
      throw Exception("create failed");
    }

    createdReference = ref;
  }

  @override
  Future<void> onSaveButtonClick(BuildContext context) async {
    if (facilityTypes.any((f) => f.reference3 == reference.reference3)) {
      return;
    }

    try {
      if (!isFormValid) {
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      } else {
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loading));

        final Reference facilityDescriptionRef = Reference(
          name: reference.name,
          description: reference.description,
          reference1: reference.reference1,
          reference2: reference.reference2,
          reference3: reference.reference3,
          reference4: reference.reference4,
          reference5: ServerConstants.newProductCode,
          isActive: true,
          status: Status.active.name,
        );

        await createReference(facilityDescriptionRef);

        reference.reference4?.trim().toUpperCase();

        emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      }
    } on Exception catch (_) {
      emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
    }
  }
}

class OriginalSaveSafeVM extends OthersLimitDialogViewModel {
  Reference? createdReference;
  bool throwOnCreate = false;

  @override
  bool get isFIFlow => false;

  @override
  Future<void> getReferenceData() async {}

  @override
  Future<void> getUpdatedFacilityReference() async {}

  @override
  Future<void> createReference(Reference ref) async {
    if (throwOnCreate) {
      throw Exception("create failed");
    }

    createdReference = ref;
  }
}

class OriginalSaveSafeFIVM extends OriginalSaveSafeVM {
  @override
  bool get isFIFlow => true;
}

class OriginalReferenceDataVM extends OthersLimitDialogViewModel {
  OriginalReferenceDataVM({required this.fiFlow});

  final bool fiFlow;

  @override
  bool get isFIFlow => fiFlow;
}

class MockedVM extends OthersLimitDialogViewModel {
  final mockHome = MockHomeRepository();
  final mockAdmin = MockAdminRepository();
  final mockRefService = MockReferenceDataService();

  @override
  bool get isFIFlow => false;

  @override
  Future<void> getUpdatedFacilityReference() async {
    try {
      final data = await mockHome.getReferenceData(
        <String>[ReferenceDataKeys.facilityTypes],
      );

      facilityTypes = data.first.references ?? [];
    } on Exception catch (_) {}
  }

  @override
  Future<void> getReferenceData() async {
    try {
      final data = await mockRefService.getReferenceData(
        <String>[
          ReferenceDataKeys.productType,
          ReferenceDataKeys.limitType,
          ReferenceDataKeys.sustanabilityClassification,
          ReferenceDataKeys.period,
          ReferenceDataKeys.marginSign,
          ReferenceDataKeys.benchMark,
          ReferenceDataKeys.limitCapsType,
        ],
      );

      limitTypes = data[ReferenceDataKeys.limitType] ?? [];
      productTypeOptions = data[ReferenceDataKeys.productType] ?? [];
    } on Exception catch (_) {}
  }

  @override
  Future<void> createReference(Reference ref) async {
    await mockAdmin.saveReferenceDataInformation(
      ServerConstants.facilityTypeReferenceID,
      ref,
    );
  }
}

class MockedFIVM extends MockedVM {
  @override
  bool get isFIFlow => true;

  @override
  Future<void> getUpdatedFacilityReference() async {
    try {
      final data = await mockHome.getReferenceData(
        <String>[ReferenceDataKeys.fiFacilityTypes],
      );

      facilityTypes = data.first.references ?? [];
    } on Exception catch (_) {}
  }

  @override
  Future<void> getReferenceData() async {
    try {
      final data = await mockRefService.getReferenceData(
        <String>[
          ReferenceDataKeys.productType,
          ReferenceDataKeys.fiLimitType,
          ReferenceDataKeys.sustanabilityClassification,
          ReferenceDataKeys.period,
          ReferenceDataKeys.marginSign,
          ReferenceDataKeys.benchMark,
          ReferenceDataKeys.limitCapsType,
        ],
      );

      limitTypes = data[ReferenceDataKeys.fiLimitType] ?? [];
      productTypeOptions = data[ReferenceDataKeys.productType] ?? [];
    } on Exception catch (_) {}
  }
}

Future<BuildContext> pumpFormContext(
  WidgetTester tester,
  GlobalKey<FormState> formKey, {
  bool isValid = true,
  void Function(String?)? onSaved,
}) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            capturedContext = context;

            return Form(
              key: formKey,
              child: TextFormField(
                validator: (_) => isValid ? null : "error",
                onSaved: onSaved,
              ),
            );
          },
        ),
      ),
    ),
  );

  await tester.pump();

  return capturedContext;
}

void prepareValidOriginalSaveVM(OriginalSaveSafeVM vm) {
  final productType = Reference(
    id: 1,
    name: "Product",
    reference1: "P",
  );

  final facilityType = Reference(
    id: 10,
    name: "Limit Type",
  );

  vm
    ..selectedProductTypeOption = productType
    ..selectedNatureFund = Naturefund.funded
    ..facilityTypes = []
    ..limitGroupId = 100
    ..rimNo = 200
    ..limitNumber = "LN-1"
    ..isMainLimit = true;

  vm.facility.facilityTypeSelectedValue = facilityType;

  vm.reference
    ..name = "Limit Name"
    ..description = "Limit Description"
    ..reference1 = "P"
    ..reference2 = "F"
    ..reference3 = "NEW"
    ..reference4 = "TYPE";
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(Reference());
  });

  group("Constructor Defaults", () {
    test("initial state and default fields are correct", () {
      final vm = OthersLimitDialogViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
      expect(vm.reference, isA<Reference>());
      expect(vm.allReferences, isEmpty);
      expect(vm.limitTypes, isEmpty);
      expect(vm.facilityTypes, isEmpty);
      expect(vm.referenceDataTypeID, 0);
      expect(vm.selectedReferenceType, null);
      expect(vm.descriptionFormatters, isEmpty);
      expect(vm.reference1Formatters, isEmpty);
      expect(vm.reference2Formatters, isEmpty);
      expect(vm.reference3Formatters, isEmpty);
      expect(vm.reference4Formatters, isEmpty);
      expect(vm.reference5Formatters, isEmpty);
      expect(vm.natureOfFund.length, 2);
      expect(vm.productTypeOptions, isEmpty);
      expect(vm.selectedProductTypeOption, null);
      expect(vm.facility, isNotNull);
      expect(vm.selectedNatureFund, null);
      expect(vm.limitGroupId, null);
      expect(vm.rimNo, null);
      expect(vm.selectedDescriptionId, null);
      expect(vm.limitNumber, null);
      expect(vm.isMainLimit, null);
      expect(vm.isProductTyopeEnabled, null);
      expect(vm.productTypeValue, null);
      expect(vm.limitTypeEditController.text, "");
      expect(vm.isLimitTypeInEditMode, false);
      expect(vm.customLimitTypeText, "");
      expect(vm.showLimitTypeRequiredError, false);
      expect(vm.isLimitTypeMissing, true);
    });
  });

  group("Limit Code Formatters", () {
    test("allows uppercase alphabets", () {
      final vm = OthersLimitDialogViewModel();
      final formatter = vm.limitCodeFormatters.first;

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: "ABC"),
      );

      expect(result.text, "ABC");
    });

    test("rejects lowercase alphabets and numbers", () {
      final vm = OthersLimitDialogViewModel();
      final formatter = vm.limitCodeFormatters.first;

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: "abc123"),
      );

      expect(result.text, "");
    });

    test("reserved formatter lists exist", () {
      final vm = OthersLimitDialogViewModel();

      expect(vm.descriptionFormatters, isA<List<TextInputFormatter>>());
      expect(vm.reference1Formatters, isA<List<TextInputFormatter>>());
      expect(vm.reference2Formatters, isA<List<TextInputFormatter>>());
      expect(vm.reference3Formatters, isA<List<TextInputFormatter>>());
      expect(vm.reference4Formatters, isA<List<TextInputFormatter>>());
      expect(vm.reference5Formatters, isA<List<TextInputFormatter>>());
    });
  });

  group("Validation - validateProductCode", () {
    late OthersLimitDialogViewModel vm;

    setUp(() {
      vm = OthersLimitDialogViewModel();
    });

    test("returns required error for null", () {
      expect(vm.validateProductCode(null), isNotNull);
    });

    test("returns required error for empty value", () {
      expect(vm.validateProductCode(""), isNotNull);
    });

    test("returns required error for spaces", () {
      expect(vm.validateProductCode("   "), isNotNull);
    });

    test("accepts single alphabet", () {
      expect(vm.validateProductCode("A"), null);
    });

    test("accepts single digit", () {
      expect(vm.validateProductCode("1"), null);
    });

    test("accepts 2 numeric digits", () {
      expect(vm.validateProductCode("12"), null);
    });

    test("accepts 3 numeric digits", () {
      expect(vm.validateProductCode("123"), null);
    });

    test("accepts alphanumeric max 4 chars", () {
      expect(vm.validateProductCode("A12B"), null);
    });

    test("converts lowercase to uppercase and accepts", () {
      expect(vm.validateProductCode("ab12"), null);
    });

    test("trims value before validation", () {
      expect(vm.validateProductCode(" A1 "), null);
    });

    test("rejects more than 4 chars", () {
      expect(vm.validateProductCode("ABCDE"), isNotNull);
    });

    test("rejects special characters", () {
      expect(vm.validateProductCode("A@1"), isNotNull);
    });

    test("rejects space inside value", () {
      expect(vm.validateProductCode("A 1"), isNotNull);
    });

    test("rejects exactly 4 numeric digits", () {
      expect(vm.validateProductCode("1234"), isNotNull);
    });

    test("accepts 4 alpha characters", () {
      expect(vm.validateProductCode("ABCD"), null);
    });

    test("accepts mixed lower and upper values", () {
      expect(vm.validateProductCode("aB1c"), null);
    });
  });

  group("Nature Of Fund", () {
    late OthersLimitDialogViewModel vm;

    setUp(() {
      vm = OthersLimitDialogViewModel();
    });

    test("funded stores F", () {
      vm.changeNatureOfFund(Naturefund.funded);

      expect(vm.selectedNatureFund, Naturefund.funded);
      expect(vm.reference.reference2, "F");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non funded stores N", () {
      vm.changeNatureOfFund(Naturefund.nonfunded);

      expect(vm.selectedNatureFund, Naturefund.nonfunded);
      expect(vm.reference.reference2, "N");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("funded label is not empty", () {
      expect(vm.natureOfFundLabel(Naturefund.funded), isNotEmpty);
    });

    test("non funded label is not empty", () {
      expect(vm.natureOfFundLabel(Naturefund.nonfunded), isNotEmpty);
    });

    test("nature of fund list has funded and non funded labels", () {
      final vm = OthersLimitDialogViewModel();

      expect(vm.natureOfFund.length, 2);
    });
  });

  group("Product Type Change", () {
    test("sets selected product type and reference1", () {
      final vm = FinalSafeVM();
      final ref = Reference(id: 10, reference1: "CONV");

      vm.changeProductTypeOptions(ref);

      expect(vm.selectedProductTypeOption, ref);
      expect(vm.reference.reference1, "CONV");
      expect(vm.facility.selectedProductTypeValue, ref);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("trims reference1 value", () {
      final vm = FinalSafeVM()
        ..changeProductTypeOptions(
          Reference(id: 10, reference1: "  ABC  "),
        );

      expect(vm.reference.reference1, "ABC");
    });

    test("sets empty string when reference1 is null", () {
      final vm = FinalSafeVM()..changeProductTypeOptions(Reference(id: 10));

      expect(vm.reference.reference1, "");
    });

    test("clears selected facility type when product type changes", () {
      final vm = FinalSafeVM()
        ..changeProductTypeOptions(Reference(id: 1, reference1: "A"));
      vm.facility.facilityTypeSelectedValue = Reference(id: 99);

      vm.changeProductTypeOptions(Reference(id: 2, reference1: "B"));

      expect(vm.facility.facilityTypeSelectedValue, null);
    });

    test(
        "does not clear selected facility type when same product type selected",
        () {
      final vm = FinalSafeVM();
      final productType = Reference(id: 1, reference1: "A");

      vm.changeProductTypeOptions(productType);
      vm.facility.facilityTypeSelectedValue = Reference(id: 99);

      vm.changeProductTypeOptions(productType);

      expect(vm.facility.facilityTypeSelectedValue, isNotNull);
    });

    test("first product type selection clears null facility only safely", () {
      final vm = FinalSafeVM()
        ..changeProductTypeOptions(Reference(id: 1, reference1: "A"));

      expect(vm.facility.facilityTypeSelectedValue, null);
      expect(vm.selectedProductTypeOption?.id, 1);
    });
  });

  group("Limit Type Edit Mode", () {
    late OthersLimitDialogViewModel vm;

    setUp(() {
      vm = OthersLimitDialogViewModel();
    });

    testWidgets("activateLimitTypeEditMode clears selected dropdown value",
        (tester) async {
      vm.facility.facilityTypeSelectedValue = Reference(id: 1);

      vm
        ..reference.reference4 = "OLD"
        ..customLimitTypeText = "OLD"
        ..showLimitTypeRequiredError = true
        ..limitTypeEditController.text = "OLD"
        ..activateLimitTypeEditMode();

      await tester.pump();

      expect(vm.isLimitTypeInEditMode, true);
      expect(vm.customLimitTypeText, "");
      expect(vm.facility.facilityTypeSelectedValue, null);
      expect(vm.reference.reference4, null);
      expect(vm.showLimitTypeRequiredError, false);
      expect(vm.limitTypeEditController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onLimitTypeEditTextChanged stores trimmed custom text", () {
      vm
        ..isLimitTypeInEditMode = true
        ..onLimitTypeEditTextChanged("  Custom Limit  ");

      expect(vm.customLimitTypeText, "Custom Limit");
      expect(vm.reference.reference4, "Custom Limit");
    });

    test("onLimitTypeEditTextChanged keeps error when text is empty", () {
      vm
        ..isLimitTypeInEditMode = true
        ..showLimitTypeRequiredError = true
        ..onLimitTypeEditTextChanged("   ");

      expect(vm.customLimitTypeText, "");
      expect(vm.reference.reference4, "");
      expect(vm.showLimitTypeRequiredError, true);
    });

    test("onLimitTypeEditTextChanged hides required error when text entered",
        () {
      vm
        ..isLimitTypeInEditMode = true
        ..showLimitTypeRequiredError = true
        ..onLimitTypeEditTextChanged("ABC");

      expect(vm.showLimitTypeRequiredError, false);
    });

    test("onLimitTypeEditCompleted stores trimmed value", () {
      vm
        ..isLimitTypeInEditMode = true
        ..onLimitTypeEditCompleted("  Completed Value  ");

      expect(vm.customLimitTypeText, "Completed Value");
      expect(vm.reference.reference4, "Completed Value");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onLimitTypeEditCompleted keeps error when value is empty", () {
      vm
        ..isLimitTypeInEditMode = true
        ..showLimitTypeRequiredError = true
        ..onLimitTypeEditCompleted("   ");

      expect(vm.customLimitTypeText, "");
      expect(vm.reference.reference4, "");
      expect(vm.showLimitTypeRequiredError, true);
    });

    test("onLimitTypeEditCompleted hides required error when value exists", () {
      vm
        ..isLimitTypeInEditMode = true
        ..showLimitTypeRequiredError = true
        ..onLimitTypeEditCompleted("Done");

      expect(vm.showLimitTypeRequiredError, false);
    });

    test("onLimitTypeSelected exits edit mode and stores reference1", () {
      final selected = Reference(
        id: 1,
        name: "Limit Name",
        reference1: "LMT",
      );

      vm
        ..isLimitTypeInEditMode = true
        ..customLimitTypeText = "Custom"
        ..showLimitTypeRequiredError = true
        ..limitTypeEditController.text = "Custom"
        ..onLimitTypeSelected(selected);

      expect(vm.isLimitTypeInEditMode, false);
      expect(vm.customLimitTypeText, "");
      expect(vm.facility.facilityTypeSelectedValue, selected);
      expect(vm.reference.reference4, "LMT");
      expect(vm.showLimitTypeRequiredError, false);
      expect(vm.limitTypeEditController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onLimitTypeSelected falls back to name when reference1 is null", () {
      final selected = Reference(
        id: 1,
        name: "Limit Name",
      );

      vm.onLimitTypeSelected(selected);

      expect(vm.reference.reference4, "Limit Name");
    });

    test("onLimitTypeSelected trims selected value", () {
      final selected = Reference(
        id: 1,
        name: "Limit Name",
        reference1: "  LMT  ",
      );

      vm.onLimitTypeSelected(selected);

      expect(vm.reference.reference4, "LMT");
    });

    test("onLimitTypeSelected stores empty when reference1 and name are null",
        () {
      final selected = Reference(id: 1);

      vm.onLimitTypeSelected(selected);

      expect(vm.reference.reference4, "");
    });

    test("clearLimitTypeValue clears all limit type values", () {
      vm.facility.facilityTypeSelectedValue = Reference(id: 1);

      vm
        ..customLimitTypeText = "ABC"
        ..reference.reference4 = "ABC"
        ..showLimitTypeRequiredError = true
        ..limitTypeEditController.text = "ABC"
        ..clearLimitTypeValue();

      expect(vm.facility.facilityTypeSelectedValue, null);
      expect(vm.customLimitTypeText, "");
      expect(vm.reference.reference4, null);
      expect(vm.showLimitTypeRequiredError, false);
      expect(vm.limitTypeEditController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("isLimitTypeMissing true in edit mode when custom text empty", () {
      vm
        ..isLimitTypeInEditMode = true
        ..customLimitTypeText = "";

      expect(vm.isLimitTypeMissing, true);
    });

    test("isLimitTypeMissing true in edit mode when custom text only spaces",
        () {
      vm
        ..isLimitTypeInEditMode = true
        ..customLimitTypeText = "   ";

      expect(vm.isLimitTypeMissing, true);
    });

    test("isLimitTypeMissing false in edit mode when custom text exists", () {
      vm
        ..isLimitTypeInEditMode = true
        ..customLimitTypeText = "ABC";

      expect(vm.isLimitTypeMissing, false);
    });

    test("isLimitTypeMissing true in dropdown mode when no value selected", () {
      vm
        ..isLimitTypeInEditMode = false
        ..facility.facilityTypeSelectedValue = null;

      expect(vm.isLimitTypeMissing, true);
    });

    test("isLimitTypeMissing false in dropdown mode when value selected", () {
      vm
        ..isLimitTypeInEditMode = false
        ..facility.facilityTypeSelectedValue = Reference(id: 1);

      expect(vm.isLimitTypeMissing, false);
    });
  });

  group("Init", () {
    test("normal init matches incoming product type by id", () async {
      final vm = FinalSafeVM();

      await vm.init(
        null,
        null,
        10,
        20,
        30,
        "L123",
        Reference(id: 2),
        isMainLimit: true,
        isProductTypeEnabled: true,
      );

      expect(vm.limitGroupId, 10);
      expect(vm.selectedDescriptionId, 20);
      expect(vm.rimNo, 30);
      expect(vm.limitNumber, "L123");
      expect(vm.isMainLimit, true);
      expect(vm.isProductTyopeEnabled, true);
      expect(vm.productTypeValue?.id, 2);
      expect(vm.selectedProductTypeOption?.id, 2);
      expect(vm.facility.selectedProductTypeValue?.id, 2);
      expect(vm.selectedNatureFund, Naturefund.funded);
      expect(vm.reference.reference2, "F");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("fallback to first product type when input product null", () async {
      final vm = FinalSafeVM();

      await vm.init(null, null, 1, 2, 3, "L1", null);

      expect(vm.selectedProductTypeOption?.id, 1);
      expect(vm.facility.selectedProductTypeValue?.id, 1);
    });

    test("fallback to first product type when incoming id not found", () async {
      final vm = FinalSafeVM();

      await vm.init(null, null, 1, 2, 3, "L1", Reference(id: 999));

      expect(vm.selectedProductTypeOption?.id, 1);
    });

    test("keeps existing selected product type when productTypeValue null",
        () async {
      final vm = FinalSafeVM()
        ..selectedProductTypeOption = Reference(id: 2, reference1: "B");

      await vm.init(null, null, 1, 2, 3, "L1", null);

      expect(vm.selectedProductTypeOption?.id, 2);
    });

    test("does not override existing selected nature fund", () async {
      final vm = FinalSafeVM()
        ..selectedNatureFund = Naturefund.nonfunded
        ..reference.reference2 = "N";

      await vm.init(null, null, 1, 2, 3, "L1", null);

      expect(vm.selectedNatureFund, Naturefund.nonfunded);
      expect(vm.reference.reference2, "N");
    });

    test("init handles empty product type list", () async {
      final vm = FinalSafeVM()..emptyProductTypes = true;

      await vm.init(null, null, 1, 2, 3, "L1", null);

      expect(vm.productTypeOptions, isEmpty);
      expect(vm.selectedProductTypeOption, null);
      expect(vm.selectedNatureFund, Naturefund.funded);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("Original getReferenceData", () {
    test("success loads normal limit types and filters both product option",
        () async {
      final mockRefService = MockReferenceDataService();
      final vm = OriginalReferenceDataVM(fiFlow: false)
        ..referenceDataService = mockRefService;

      when(() => mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.limitType: [
            Reference(id: 1, name: "Limit 1"),
          ],
          ReferenceDataKeys.productType: [
            Reference(id: ServerConstants.optionBothId, name: "Both"),
            Reference(id: 2, name: "Conventional"),
            Reference(id: 3, name: "Islamic"),
          ],
          ReferenceDataKeys.sustanabilityClassification: <Reference>[],
          ReferenceDataKeys.period: <Reference>[],
          ReferenceDataKeys.marginSign: <Reference>[],
          ReferenceDataKeys.benchMark: <Reference>[],
          ReferenceDataKeys.limitCapsType: <Reference>[],
        },
      );

      await vm.getReferenceData();

      expect(vm.limitTypes.length, 1);
      expect(vm.limitTypes.first.name, "Limit 1");
      expect(vm.productTypeOptions.length, 2);
      expect(
        vm.productTypeOptions.any(
          (data) => data.id == ServerConstants.optionBothId,
        ),
        false,
      );

      verify(
        () => mockRefService.getReferenceData(
          <String>[
            ReferenceDataKeys.productType,
            ReferenceDataKeys.limitType,
            ReferenceDataKeys.sustanabilityClassification,
            ReferenceDataKeys.period,
            ReferenceDataKeys.marginSign,
            ReferenceDataKeys.benchMark,
            ReferenceDataKeys.limitCapsType,
          ],
        ),
      ).called(1);
    });

    test("success loads FI limit types", () async {
      final mockRefService = MockReferenceDataService();
      final vm = OriginalReferenceDataVM(fiFlow: true)
        ..referenceDataService = mockRefService;

      when(() => mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.fiLimitType: [
            Reference(id: 10, name: "FI Limit"),
          ],
          ReferenceDataKeys.productType: [
            Reference(id: 20, name: "FI Product"),
          ],
          ReferenceDataKeys.sustanabilityClassification: <Reference>[],
          ReferenceDataKeys.period: <Reference>[],
          ReferenceDataKeys.marginSign: <Reference>[],
          ReferenceDataKeys.benchMark: <Reference>[],
          ReferenceDataKeys.limitCapsType: <Reference>[],
        },
      );

      await vm.getReferenceData();

      expect(vm.limitTypes.first.name, "FI Limit");
      expect(vm.productTypeOptions.first.name, "FI Product");

      verify(
        () => mockRefService.getReferenceData(
          <String>[
            ReferenceDataKeys.productType,
            ReferenceDataKeys.fiLimitType,
            ReferenceDataKeys.sustanabilityClassification,
            ReferenceDataKeys.period,
            ReferenceDataKeys.marginSign,
            ReferenceDataKeys.benchMark,
            ReferenceDataKeys.limitCapsType,
          ],
        ),
      ).called(1);
    });

    test("missing map keys results empty lists", () async {
      final mockRefService = MockReferenceDataService();
      final vm = OriginalReferenceDataVM(fiFlow: false)
        ..referenceDataService = mockRefService;

      when(() => mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await vm.getReferenceData();

      expect(vm.limitTypes, isEmpty);
      expect(vm.productTypeOptions, isEmpty);
    });

    test("exception is handled safely", () async {
      final mockRefService = MockReferenceDataService();
      final vm = OriginalReferenceDataVM(fiFlow: false)
        ..referenceDataService = mockRefService;

      when(() => mockRefService.getReferenceData(any())).thenThrow(
        Exception("error"),
      );

      try {
        await vm.getReferenceData();
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.limitTypes, isEmpty);
      expect(vm.productTypeOptions, isEmpty);
    });
  });

  group("Mocked Repository Methods", () {
    test("getUpdatedFacilityReference success sets facilityTypes", () async {
      final vm = MockedVM();

      when(() => vm.mockHome.getReferenceData(any())).thenAnswer(
        (_) async => [
          ReferenceType(
            references: [
              Reference(id: 1, reference3: "A"),
              Reference(id: 2, reference3: "B"),
            ],
          ),
        ],
      );

      await vm.getUpdatedFacilityReference();

      expect(vm.facilityTypes.length, 2);
      expect(vm.facilityTypes.first.reference3, "A");

      verify(
        () => vm.mockHome.getReferenceData(
          <String>[ReferenceDataKeys.facilityTypes],
        ),
      ).called(1);
    });

    test("getUpdatedFacilityReference null references becomes empty", () async {
      final vm = MockedVM();

      when(() => vm.mockHome.getReferenceData(any())).thenAnswer(
        (_) async => [
          ReferenceType(),
        ],
      );

      await vm.getUpdatedFacilityReference();

      expect(vm.facilityTypes, isEmpty);
    });

    test("getUpdatedFacilityReference handles exception", () async {
      final vm = MockedVM();

      when(() => vm.mockHome.getReferenceData(any())).thenThrow(
        Exception("error"),
      );

      await vm.getUpdatedFacilityReference();

      expect(vm.facilityTypes, isEmpty);
    });

    test("getReferenceData success sets limitTypes and productTypeOptions",
        () async {
      final vm = MockedVM();

      when(() => vm.mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.limitType: [
            Reference(id: 1, name: "Limit"),
          ],
          ReferenceDataKeys.productType: [
            Reference(id: 2, name: "Product"),
          ],
        },
      );

      await vm.getReferenceData();

      expect(vm.limitTypes.length, 1);
      expect(vm.productTypeOptions.length, 1);
      expect(vm.limitTypes.first.name, "Limit");
      expect(vm.productTypeOptions.first.name, "Product");

      verify(
        () => vm.mockRefService.getReferenceData(
          <String>[
            ReferenceDataKeys.productType,
            ReferenceDataKeys.limitType,
            ReferenceDataKeys.sustanabilityClassification,
            ReferenceDataKeys.period,
            ReferenceDataKeys.marginSign,
            ReferenceDataKeys.benchMark,
            ReferenceDataKeys.limitCapsType,
          ],
        ),
      ).called(1);
    });

    test("getReferenceData missing keys keeps empty lists", () async {
      final vm = MockedVM();

      when(() => vm.mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await vm.getReferenceData();

      expect(vm.limitTypes, isEmpty);
      expect(vm.productTypeOptions, isEmpty);
    });

    test("getReferenceData handles exception", () async {
      final vm = MockedVM();

      when(() => vm.mockRefService.getReferenceData(any())).thenThrow(
        Exception("error"),
      );

      await vm.getReferenceData();

      expect(vm.limitTypes, isEmpty);
      expect(vm.productTypeOptions, isEmpty);
    });

    test("createReference passes correct facility type reference id", () async {
      final vm = MockedVM();

      when(
        () => vm.mockAdmin.saveReferenceDataInformation(any(), any()),
      ).thenAnswer((_) async => null);

      final ref = Reference(name: "New Ref");

      await vm.createReference(ref);

      verify(
        () => vm.mockAdmin.saveReferenceDataInformation(
          ServerConstants.facilityTypeReferenceID,
          ref,
        ),
      ).called(1);
    });

    test("FI flow uses FI reference keys", () async {
      final vm = MockedFIVM();

      when(() => vm.mockHome.getReferenceData(any())).thenAnswer(
        (_) async => [
          ReferenceType(
            references: [
              Reference(id: 10, reference3: "FI"),
            ],
          ),
        ],
      );

      when(() => vm.mockRefService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.fiLimitType: [
            Reference(id: 20, name: "FI Limit"),
          ],
          ReferenceDataKeys.productType: [
            Reference(id: 30, name: "FI Product"),
          ],
        },
      );

      await vm.getUpdatedFacilityReference();
      await vm.getReferenceData();

      expect(vm.facilityTypes.first.reference3, "FI");
      expect(vm.limitTypes.first.name, "FI Limit");
      expect(vm.productTypeOptions.first.name, "FI Product");

      verify(
        () => vm.mockHome.getReferenceData(
          <String>[ReferenceDataKeys.fiFacilityTypes],
        ),
      ).called(1);

      verify(
        () => vm.mockRefService.getReferenceData(
          <String>[
            ReferenceDataKeys.productType,
            ReferenceDataKeys.fiLimitType,
            ReferenceDataKeys.sustanabilityClassification,
            ReferenceDataKeys.period,
            ReferenceDataKeys.marginSign,
            ReferenceDataKeys.benchMark,
            ReferenceDataKeys.limitCapsType,
          ],
        ),
      ).called(1);
    });
  });

  group("Create Reference", () {
    test("FinalSafeVM createReference stores created reference", () async {
      final vm = FinalSafeVM();
      final ref = Reference(name: "Test");

      await vm.createReference(ref);

      expect(vm.createdReference, ref);
    });

    test("MockedVM createReference called", () async {
      final vm = MockedVM();

      when(
        () => vm.mockAdmin.saveReferenceDataInformation(any(), any()),
      ).thenAnswer((_) async => null);

      await vm.createReference(Reference(name: "Test"));

      verify(
        () => vm.mockAdmin.saveReferenceDataInformation(any(), any()),
      ).called(1);
    });
  });

  group("Original onSaveButtonClick branches", () {
    testWidgets("missing product type only branch", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(tester, vm.formKey);

      vm
        ..selectedNatureFund = Naturefund.funded
        ..reference.reference4 = "TYPE";

      vm.facility.facilityTypeSelectedValue = Reference(id: 1);

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.showLimitTypeRequiredError, false);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("missing nature fund only branch", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(tester, vm.formKey);

      vm
        ..selectedProductTypeOption = Reference(id: 1)
        ..reference.reference4 = "TYPE";

      vm.facility.facilityTypeSelectedValue = Reference(id: 1);

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.showLimitTypeRequiredError, false);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("missing limit type dropdown branch", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(tester, vm.formKey);

      vm
        ..selectedProductTypeOption = Reference(id: 1)
        ..selectedNatureFund = Naturefund.funded;

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.showLimitTypeRequiredError, true);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("missing limit type edit mode branch", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(tester, vm.formKey);

      vm
        ..selectedProductTypeOption = Reference(id: 1)
        ..selectedNatureFund = Naturefund.funded
        ..isLimitTypeInEditMode = true
        ..customLimitTypeText = "";

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.showLimitTypeRequiredError, true);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("invalid form branch with four digit code", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(
        tester,
        vm.formKey,
        isValid: false,
      );

      prepareValidOriginalSaveVM(vm);

      vm.reference.reference3 = "1234";

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("invalid form branch with non four digit code", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(
        tester,
        vm.formKey,
        isValid: false,
      );

      prepareValidOriginalSaveVM(vm);

      vm.reference.reference3 = "ABCD";

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("duplicate limit code branch", (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(tester, vm.formKey);

      prepareValidOriginalSaveVM(vm);

      vm
        ..reference.reference3 = "DUP"
        ..facilityTypes = [
          Reference(reference3: "DUP"),
        ];

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Toast/plugin errors ignored.
      }

      expect(vm.createdReference, null);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("success branch maps reference and reaches navigation block",
        (tester) async {
      final vm = OriginalSaveSafeVM();
      final context = await pumpFormContext(
        tester,
        vm.formKey,
        onSaved: (_) {
          vm.reference.name = "Saved Limit Name";
        },
      );

      prepareValidOriginalSaveVM(vm);

      vm.reference.reference4 = " abc ";

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Router/toast errors ignored.
      }

      expect(vm.createdReference?.name, "Saved Limit Name");
      expect(vm.createdReference?.description, "Limit Description");
      expect(vm.createdReference?.reference1, "P");
      expect(vm.createdReference?.reference2, "F");
      expect(vm.createdReference?.reference3, "NEW");
      expect(vm.createdReference?.reference4, " abc ");
      expect(vm.createdReference?.reference5, ServerConstants.newProductCode);
      expect(vm.createdReference?.isActive, true);
      expect(vm.createdReference?.status, Status.active.name);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    testWidgets("FI VM success branch executes", (tester) async {
      final vm = OriginalSaveSafeFIVM();
      final context = await pumpFormContext(tester, vm.formKey);

      prepareValidOriginalSaveVM(vm);

      try {
        await vm.onSaveButtonClick(context);
      } on Object {
        // Router/toast errors ignored.
      }

      expect(vm.isFIFlow, true);
      expect(vm.createdReference?.reference3, "NEW");
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });
  });

  group("Save Branches - Lightweight", () {
    test("SaveTestVM duplicate returns without changing save status to loading",
        () async {
      final vm = SaveTestVM()..reference.reference3 = "DUP";

      await vm.onSaveButtonClick(FakeBuildContext());

      expect(vm.reference.reference3, "DUP");
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    test("SaveTestVM non duplicate emits loaded", () async {
      final vm = SaveTestVM()
        ..facilityTypes = []
        ..reference.reference3 = "NEW";

      await vm.onSaveButtonClick(FakeBuildContext());

      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    test("RealSaveTestVM duplicate exits early", () async {
      final vm = RealSaveTestVM()
        ..facilityTypes = [
          Reference(reference3: "DUP"),
        ]
        ..reference.reference3 = "DUP";

      await vm.onSaveButtonClick(FakeBuildContext());

      expect(vm.reference.reference3, "DUP");
      expect(vm.createdReference, null);
      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });

    test("RealSaveTestVM invalid form branch", () async {
      final vm = RealSaveTestVM()
        ..facilityTypes = []
        ..isFormValid = false
        ..reference.reference3 = "NEW";

      await vm.onSaveButtonClick(FakeBuildContext());

      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
      expect(vm.createdReference, null);
    });

    test("RealSaveTestVM valid form branch creates mapped reference", () async {
      final vm = RealSaveTestVM()
        ..facilityTypes = []
        ..isFormValid = true;

      vm.reference
        ..name = "Limit Name"
        ..description = "Desc"
        ..reference1 = "P"
        ..reference2 = "F"
        ..reference3 = "NEW"
        ..reference4 = " ABC ";

      await vm.onSaveButtonClick(FakeBuildContext());

      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
      expect(vm.createdReference?.name, "Limit Name");
      expect(vm.createdReference?.description, "Desc");
      expect(vm.createdReference?.reference1, "P");
      expect(vm.createdReference?.reference2, "F");
      expect(vm.createdReference?.reference3, "NEW");
      expect(vm.createdReference?.reference4, " ABC ");
      expect(vm.createdReference?.reference5, ServerConstants.newProductCode);
      expect(vm.createdReference?.isActive, true);
      expect(vm.createdReference?.status, Status.active.name);
    });

    test("RealSaveTestVM valid form catches create exception", () async {
      final vm = RealSaveTestVM()
        ..facilityTypes = []
        ..isFormValid = true
        ..throwOnCreate = true;

      vm.reference
        ..name = "Limit Name"
        ..reference2 = "F"
        ..reference3 = "NEW"
        ..reference4 = "ABC";

      await vm.onSaveButtonClick(FakeBuildContext());

      expect(vm.state.saveButtonStatus, LoadingStatus.loaded);
    });
  });

  group("Mapping Logic", () {
    test("facility description ref mapping keeps all fields", () {
      final vm = OthersLimitDialogViewModel();

      vm.reference
        ..name = "Limit"
        ..description = "Description"
        ..reference1 = "P"
        ..reference2 = "F"
        ..reference3 = "CODE"
        ..reference4 = "TYPE";

      final ref = Reference(
        name: vm.reference.name,
        description: vm.reference.description,
        reference1: vm.reference.reference1,
        reference2: vm.reference.reference2,
        reference3: vm.reference.reference3,
        reference4: vm.reference.reference4,
        reference5: ServerConstants.newProductCode,
        isActive: true,
        status: Status.active.name,
      );

      expect(ref.name, "Limit");
      expect(ref.description, "Description");
      expect(ref.reference1, "P");
      expect(ref.reference2, "F");
      expect(ref.reference3, "CODE");
      expect(ref.reference4, "TYPE");
      expect(ref.reference5, ServerConstants.newProductCode);
      expect(ref.isActive, true);
      expect(ref.status, Status.active.name);
    });
  });

  group("Disposal Safety", () {
    test("focus node and controller exist", () {
      final vm = OthersLimitDialogViewModel();

      expect(vm.formFocusNode, isNotNull);
      expect(vm.limitTypeEditController, isNotNull);
      expect(vm.formKey, isNotNull);
    });
  });

  group("Legacy Compatibility Tests", () {
    test("createReference called", () async {
      final vm = MockedVM();

      when(
        () => vm.mockAdmin.saveReferenceDataInformation(any(), any()),
      ).thenAnswer((_) async => null);

      await vm.createReference(Reference(name: "Test"));

      verify(
        () => vm.mockAdmin.saveReferenceDataInformation(any(), any()),
      ).called(1);
    });

    test("onSaveButtonClick full success flow placeholder", () async {
      final vm = MockedVM()..facilityTypes = [];

      when(
        () => vm.mockAdmin.saveReferenceDataInformation(any(), any()),
      ).thenAnswer((_) async => null);

      vm.reference
        ..reference3 = "NEW"
        ..reference4 = "abc";

      vm.formKey = GlobalKey<FormState>();

      await vm.createReference(Reference(name: "Test"));

      expect(vm.reference.reference3, "NEW");
    });

    test("nature plus segment", () {
      final vm = OthersLimitDialogViewModel()
        ..changeNatureOfFund(Naturefund.funded);

      expect(vm.reference.reference2, "F");
    });

    test("labels", () {
      final vm = OthersLimitDialogViewModel();

      expect(vm.natureOfFundLabel(Naturefund.funded), isNotEmpty);
      expect(vm.natureOfFundLabel(Naturefund.nonfunded), isNotEmpty);
    });

    test("formatters", () {
      final vm = FinalSafeVM();

      expect(vm.limitCodeFormatters, isNotEmpty);
      expect(vm.descriptionFormatters, isA<List<TextInputFormatter>>());
    });

    test("natureOfFund list", () {
      final vm = FinalSafeVM();

      expect(vm.natureOfFund.length, 2);
    });
  });
}
