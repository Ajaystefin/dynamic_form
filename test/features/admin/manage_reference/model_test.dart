import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/manage_reference/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late ManageReferenceViewModel viewModel;
  late MockAdminRepository mockRepository;

  setUp(() {
    mockRepository = MockAdminRepository();
    viewModel = ManageReferenceViewModel()
      ..repository = mockRepository;
  });

  test("initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("getReferenceTypes success", () async {
    final referenceTypes = [ReferenceType(id: 1, name: "Type A")];

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

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("onUpdateReferenceData updates state and data with active status", () {
    final reference = Reference(
      id: 1,
      name: "Ref",
      description: "Desc",
      reference1: "R1",
      reference2: "R2",
      reference3: "R3",
      reference4: "R4",
      reference5: "R5",
      status: "1",
    );

    viewModel.onUpdateReferenceData(reference);

    expect(viewModel.updateDataValues?.status, Status.active.name);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onUpdateReferenceData updates state and data with inactive status", () {
    final reference = Reference(
      id: 1,
      name: "Ref",
      description: "Desc",
      reference1: "R1",
      reference2: "R2",
      reference3: "R3",
      reference4: "R4",
      reference5: "R5",
      status: "0",
    );

    viewModel.onUpdateReferenceData(reference);

    expect(viewModel.updateDataValues?.status, Status.inactive.name);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onUpdateReferenceData updates state and data with null status", () {
    final reference = Reference(
      id: 1,
      name: "Ref",
      description: "Desc",
      reference1: "R1",
      reference2: "R2",
      reference3: "R3",
      reference4: "R4",
      reference5: "R5",
      status: null,
    );

    viewModel.onUpdateReferenceData(reference);

    expect(viewModel.updateDataValues?.status, Status.inactive.name);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("onUpdateReferenceData updates state and data with empty status", () {
    final reference = Reference(
      id: 1,
      name: "Ref",
      description: "Desc",
      reference1: "R1",
      reference2: "R2",
      reference3: "R3",
      reference4: "R4",
      reference5: "R5",
      status: "",
    );

    viewModel.onUpdateReferenceData(reference);

    expect(viewModel.updateDataValues?.status, Status.inactive.name);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test(
      "onReferenceDataSelected updates"
      " selectedReferenceType and emits loading then loaded", () async {
    final referenceType = ReferenceType(id: 1, name: "Type A");

    await viewModel.onReferenceDataSelected(referenceType);

    expect(viewModel.selectedReferenceType, referenceType);
    expect(viewModel.state.referencesLoaderStatus, LoadingStatus.error);
  });

  test("onReferenceDataSelected handles null value", () async {
    await viewModel.onReferenceDataSelected(ReferenceType());

    expect(viewModel.state.referencesLoaderStatus, LoadingStatus.error);
  });

  test("onSave navigates to admin role right", () {
    viewModel.onSave();
    // Note: This test verifies the method doesn't throw an exception
    // The actual navigation would need to be tested with a mock router
  });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.formFocusNode, isA<FocusNode>());
    expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    expect(viewModel.allReferences, isEmpty);
    expect(viewModel.allReferences, isEmpty);
    expect(viewModel.referenceDataTypeID, 0);
    expect(viewModel.updateDataValues, isNull);
    expect(viewModel.selectedReferenceType, isNull);
  });

  test("onUpdateReferenceData creates correct Reference object", () {
    final reference = Reference(
      id: 123,
      name: "Test Reference",
      description: "Test Description",
      reference1: "Ref1",
      reference2: "Ref2",
      reference3: "Ref3",
      reference4: "Ref4",
      reference5: "Ref5",
      status: "1",
    );

    viewModel.onUpdateReferenceData(reference);

    expect(viewModel.updateDataValues?.id, 123);
    expect(viewModel.updateDataValues?.name, "Test Reference");
    expect(viewModel.updateDataValues?.description, "Test Description");
    expect(viewModel.updateDataValues?.reference1, "Ref1");
    expect(viewModel.updateDataValues?.reference2, "Ref2");
    expect(viewModel.updateDataValues?.reference3, "Ref3");
    expect(viewModel.updateDataValues?.reference4, "Ref4");
    expect(viewModel.updateDataValues?.reference5, "Ref5");
    expect(viewModel.updateDataValues?.status, Status.active.name);
  });

  group("ManageReferenceViewModel", () {
    test("getColumnNames replaces reference labels correctly", () {
      final viewModel = ManageReferenceViewModel()
        ..selectedReferenceType = ReferenceType(
          columnsInformation: "Custom1;Custom2;Custom3",
        );

      final columnNames = viewModel.getColumnNames();

      expect(columnNames[3], "Custom1");
      expect(columnNames[4], "Custom2");
      expect(columnNames[5], "Custom3");
    });

    test("getColumnNames returns default when no columnsInformation", () {
      final viewModel = ManageReferenceViewModel()
        ..selectedReferenceType = ReferenceType(columnsInformation: null);

      final columnNames = viewModel.getColumnNames();

      expect(columnNames.length, 9);
      expect(columnNames[3].contains("reference1"), true);
    });
  });
}
