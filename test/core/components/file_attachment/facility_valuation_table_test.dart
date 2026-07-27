import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/file_attachment/facility_valuation_table.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

class MockAttachmentViewModel extends Mock implements AttachmentViewModel {}

void main() {
  late MockAttachmentViewModel mockViewModel;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockViewModel = MockAttachmentViewModel();

    when(
      () => mockViewModel.toggleDocumentSelection(
        any(),
        any(),
        isSelected: any(named: "isSelected"),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockViewModel.downloadDocument(
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildWidget({
    required List<DocSubTypeDetail?>? documentData,
  }) {
    return EasyLocalization(
      supportedLocales: const [Locale("en")],
      fallbackLocale: const Locale("en"),
      path: "assets/translations",
      child: MaterialApp(
        home: Scaffold(
          body: FacilityValuationWidget(
            documentData: documentData,
            viewModel: mockViewModel,
          ),
        ),
      ),
    );
  }

  group("FacilityValuationWidget", () {
    testWidgets("renders table rows with document details", (tester) async {
      final documents = [
        createDoc(
          referenceNo: "REF001",
          acNo: "ACC001",
          remarks: "Valuation Report",
          date: DateTime(2024, 1, 10),
        ),
        createDoc(
          referenceNo: "REF002",
          acNo: "ACC002",
          remarks: "Facility Document",
          date: DateTime(2024, 2, 20),
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      expect(find.text("REF001"), findsOneWidget);
      expect(find.text("ACC001"), findsOneWidget);
      expect(find.text("Valuation Report"), findsOneWidget);

      expect(find.text("REF002"), findsOneWidget);
      expect(find.text("ACC002"), findsOneWidget);
      expect(find.text("Facility Document"), findsOneWidget);
    });

    testWidgets("filters rows by document type remarks", (tester) async {
      final documents = [
        createDoc(
          referenceNo: "REF001",
          acNo: "ACC001",
          remarks: "Valuation Report",
          date: DateTime(2024, 1, 10),
        ),
        createDoc(
          referenceNo: "REF002",
          acNo: "ACC002",
          remarks: "Security Document",
          date: DateTime(2024, 2, 20),
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText).at(2), "Security");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text("Security Document"), findsOneWidget);
      expect(find.text("Valuation Report"), findsNothing);
    });

    testWidgets("toggles sort order by scan date", (tester) async {
      final documents = [
        createDoc(
          referenceNo: "OLD_REF",
          acNo: "ACC001",
          remarks: "Old Document",
          date: DateTime(2023),
        ),
        createDoc(
          referenceNo: "NEW_REF",
          acNo: "ACC002",
          remarks: "New Document",
          date: DateTime(2024),
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      expect(find.text("OLD_REF"), findsOneWidget);
      expect(find.text("NEW_REF"), findsOneWidget);
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      expect(find.text("OLD_REF"), findsOneWidget);
      expect(find.text("NEW_REF"), findsOneWidget);
    });

    testWidgets("calls toggleDocumentSelection when checkbox is tapped",
        (tester) async {
      final documents = [
        createDoc(
          referenceNo: "REF001",
          acNo: "ACC001",
          remarks: "Valuation Report",
          date: DateTime(2024, 1, 10),
          edmsDriveItemId: "drive-id-1",
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      verify(
        () => mockViewModel.toggleDocumentSelection(
          any(),
          any(),
          isSelected: true,
        ),
      ).called(1);
    });

    testWidgets("shows checked checkbox when document is already selected",
        (tester) async {
      final documents = [
        createDoc(
          referenceNo: "REF001",
          acNo: "ACC001",
          remarks: "Valuation Report",
          date: DateTime(2024, 1, 10),
          isChecked: true,
          edmsDriveItemId: "drive-id-1",
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets("renders empty date when document date is null",
        (tester) async {
      final documents = [
        createDoc(
          referenceNo: "REF001",
          acNo: "ACC001",
          remarks: "Valuation Report",
          date: null,
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      expect(find.text("REF001"), findsOneWidget);
      expect(find.text("ACC001"), findsOneWidget);
      expect(find.text("Valuation Report"), findsOneWidget);
    });

    testWidgets("renders fallback hyphen for null document fields",
        (tester) async {
      final documents = [
        createDoc(
          referenceNo: null,
          acNo: null,
          remarks: null,
          date: DateTime(2024, 1, 10),
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      expect(find.text("-"), findsWidgets);
    });

    testWidgets("renders widget with empty document list", (tester) async {
      await tester.pumpWidget(buildWidget(documentData: []));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityValuationWidget), findsOneWidget);
      expect(find.byType(EditableText), findsWidgets);
    });

    testWidgets("unchecking selected checkbox sends false selection",
        (tester) async {
      final documents = [
        createDoc(
          referenceNo: "REF_SELECTED",
          acNo: "ACC001",
          remarks: "Selected Document",
          date: DateTime(2024, 1, 10),
          isChecked: true,
          edmsDriveItemId: "drive-id-selected",
        ),
      ];

      await tester.pumpWidget(buildWidget(documentData: documents));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      verify(
        () => mockViewModel.toggleDocumentSelection(
          any(),
          any(),
          isSelected: false,
        ),
      ).called(1);
    });
  });
}

DocSubTypeDetail createDoc({
  required String? referenceNo,
  required String? acNo,
  required String? remarks,
  required DateTime? date,
  bool isChecked = false,
  String edmsDriveItemId = "",
  String webUrl = "",
  String fileName = "",
}) {
  final data = DocSubTypeData(date: date)
    ..referenceNo = referenceNo
    ..acNo = acNo
    ..remarks = remarks
    ..isChecked = isChecked
    ..edmsDriveItemId = edmsDriveItemId
    ..webUrl = webUrl
    ..fileName = fileName;

  return DocSubTypeDetail(data: data);
}
