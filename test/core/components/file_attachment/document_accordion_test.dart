import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/file_attachment/document_accordion.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

class MockVM extends Mock implements AttachmentViewModel {}

void main() {
  late MockVM vm;

  setUp(() {
    vm = MockVM();

    when(
      () => vm.downloadDocument(any(), any(), any()),
    ).thenAnswer((_) async {});

    when(
      () => vm.toggleDocumentSelection(
        any(),
        isSelected: any(named: "isSelected"),
        any(),
      ),
    ).thenAnswer((_) async {});
  });

  Widget wrap(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 1200,
          child: widget,
        ),
      ),
    );
  }

  DocumentDetail buildDocument({
    required String type,
    required DocumentType? docTypeId,
  }) {
    return DocumentDetail(
      type: type,
      docYears: [],
    )..docTypeId = docTypeId;
  }

  DocumentDetail buildUnknownDocument() {
    return DocumentDetail(
      type: "unknown-document-type",
      docYears: [],
    )..docTypeId = null;
  }

  DocSubTypeDetail buildDocSubType({
    required int applicationId,
    required bool isChecked,
    String? fileName,
    String? docName,
    String? driveItemId,
    String? webUrl,
    Reference? subType,
    Reference? subSubType,
  }) {
    return DocSubTypeDetail(
      name: docName,
      data: DocSubTypeData(
        applicationID: applicationId,
        docName: docName,
        isChecked: isChecked,
        fileName: fileName,
        edmsDriveItemId: driveItemId,
        webUrl: webUrl,
        subType: subType,
        subSubType: subSubType,
      ),
    );
  }

  Future<void> pumpAccordion(
    WidgetTester tester, {
    required DocumentDetail document,
    required DocYearDetail year,
  }) async {
    await tester.pumpWidget(
      wrap(
        DocumentAccordionWidget(
          viewModel: vm,
          document: document,
          docYear: year,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ListView extractListViewFromOuterAccordion(WidgetTester tester) {
    final outerAccordionFinder = find.byType(CustomAccordion);
    expect(outerAccordionFinder, findsOneWidget);

    final outerAccordion =
        tester.widget<CustomAccordion>(outerAccordionFinder.first);

    expect(outerAccordion.children, isNotEmpty);

    final firstChild = outerAccordion.children.first;
    expect(firstChild, isA<Padding>());

    final padding = firstChild as Padding;
    expect(padding.child, isA<ListView>());

    return padding.child! as ListView;
  }

  Future<Widget> buildListItem(
    WidgetTester tester, {
    required DocumentDetail document,
    required DocYearDetail year,
    int index = 0,
  }) async {
    await pumpAccordion(
      tester,
      document: document,
      year: year,
    );

    final listView = extractListViewFromOuterAccordion(tester);
    final delegate = listView.childrenDelegate as SliverChildBuilderDelegate;

    final outerAccordionFinder = find.byType(CustomAccordion);
    final buildContext = tester.element(outerAccordionFinder.first);

    final builtChild = delegate.builder(buildContext, index);
    expect(builtChild, isNotNull);

    return builtChild!;
  }

  Future<void> pumpBuiltChild(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(wrap(child));
    await tester.pumpAndSettle();
  }

  Finder textFinder(String text) => find.text(text, skipOffstage: false);

  Finder checkboxFinder() => find.byType(Checkbox, skipOffstage: false);

  Finder iconFinder() =>
      find.byIcon(Icons.file_present_outlined, skipOffstage: false);

  group("DocumentAccordionWidget", () {
    testWidgets("renders year title", (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final year = DocYearDetail(
        docYear: 2024,
        docSubType: [],
      );

      await pumpAccordion(
        tester,
        document: doc,
        year: year,
      );

      expect(textFinder("2024"), findsOneWidget);
      expect(find.byType(CustomAccordion), findsOneWidget);
    });

    testWidgets("builds credit application list branch without crashing",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.creditApplication.toString(),
        docTypeId: DocumentType.creditApplication,
      );

      final year = DocYearDetail(
        docYear: 2025,
        docSubType: [],
        caDocTypeData: [],
      );

      await pumpAccordion(
        tester,
        document: doc,
        year: year,
      );

      expect(textFinder("2025"), findsOneWidget);

      final listView = extractListViewFromOuterAccordion(tester);
      expect(listView, isA<ListView>());
    });

    testWidgets("renders document row for other type using docName",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final row = buildDocSubType(
        applicationId: 1,
        isChecked: false,
        fileName: "other-file.pdf",
        docName: "Other Document Name",
        driveItemId: "drive-1",
        webUrl: "https://example.com/1",
      );

      final year = DocYearDetail(
        docYear: 2024,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("Other Document Name"), findsOneWidget);
      expect(checkboxFinder(), findsOneWidget);
      expect(iconFinder(), findsOneWidget);
    });

    testWidgets(
        "renders financial statements row using docName when subSubType id matches projection",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.financialStatements.toString(),
        docTypeId: DocumentType.financialStatements,
      );

      final row = buildDocSubType(
        applicationId: 2,
        isChecked: true,
        fileName: "financial-projection.pdf",
        docName: "Projected Financials",
        driveItemId: "drive-2",
        webUrl: "https://example.com/2",
        subType: Reference(name: "Statement Subtype"),
        subSubType: Reference(
          id: ServerConstants.subSubTypeFinancialProjection,
          name: "Projection",
        ),
      );

      final year = DocYearDetail(
        docYear: 2023,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("Projected Financials"), findsOneWidget);
      expect(textFinder("Projection"), findsOneWidget);
    });

    testWidgets(
        "renders financial statements row using subType name when projection does not match",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.financialStatements.toString(),
        docTypeId: DocumentType.financialStatements,
      );

      final row = buildDocSubType(
        applicationId: 3,
        isChecked: false,
        fileName: "statement.pdf",
        docName: "Ignored Document Name",
        driveItemId: "drive-3",
        webUrl: "https://example.com/3",
        subType: Reference(name: "Audited Statement"),
        subSubType: Reference(
          id: -999,
          name: "FY 2024",
        ),
      );

      final year = DocYearDetail(
        docYear: 2022,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("Audited Statement"), findsOneWidget);
      expect(textFinder("FY 2024"), findsOneWidget);
    });

    testWidgets("renders credit lens document row using subType name",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.creditLensDocument.toString(),
        docTypeId: DocumentType.creditLensDocument,
      );

      final row = buildDocSubType(
        applicationId: 4,
        isChecked: false,
        fileName: "credit-lens.pdf",
        docName: "Credit Lens Doc Name",
        driveItemId: "drive-4",
        webUrl: "https://example.com/4",
        subType: Reference(name: "Credit Lens Sub Type"),
      );

      final year = DocYearDetail(
        docYear: 2021,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("Credit Lens Sub Type"), findsOneWidget);
      expect(textFinder("Credit Lens Doc Name"), findsNothing);
    });

    testWidgets("renders external opinions row using docName", (tester) async {
      final doc = buildDocument(
        type: DocumentType.externalOpinions.toString(),
        docTypeId: DocumentType.externalOpinions,
      );

      final row = buildDocSubType(
        applicationId: 5,
        isChecked: true,
        fileName: "external.pdf",
        docName: "External Opinion",
        driveItemId: "drive-5",
        webUrl: "https://example.com/5",
      );

      final year = DocYearDetail(
        docYear: 2020,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("External Opinion"), findsOneWidget);
    });

    testWidgets("renders constitutional document row using docName",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.constitutionalDocument.toString(),
        docTypeId: DocumentType.constitutionalDocument,
      );

      final row = buildDocSubType(
        applicationId: 6,
        isChecked: false,
        fileName: "constitutional.pdf",
        docName: "Constitutional Document",
        driveItemId: "drive-6",
        webUrl: "https://example.com/6",
      );

      final year = DocYearDetail(
        docYear: 2019,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("Constitutional Document"), findsOneWidget);
    });

    testWidgets("falls back to empty subtype text for unknown type",
        (tester) async {
      final doc = buildUnknownDocument();

      final row = buildDocSubType(
        applicationId: 7,
        isChecked: false,
        fileName: "unknown.pdf",
        docName: "Unknown Doc",
        driveItemId: "drive-7",
        webUrl: "https://example.com/7",
      );

      final year = DocYearDetail(
        docYear: 2018,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(checkboxFinder(), findsOneWidget);
      expect(iconFinder(), findsOneWidget);
      expect(textFinder("Unknown Doc"), findsNothing);
    });

    testWidgets("uses docName when fileName is null during download tap",
        (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final row = buildDocSubType(
        applicationId: 8,
        isChecked: false,
        docName: "Fallback Document Name",
        driveItemId: "drive-8",
        webUrl: "https://example.com/8",
      );

      final year = DocYearDetail(
        docYear: 2027,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(iconFinder(), findsOneWidget);

      final iconGestureFinder = find.ancestor(
        of: iconFinder(),
        matching: find.byType(GestureDetector),
      );

      final iconGesture =
          tester.widget<GestureDetector>(iconGestureFinder.first);
      iconGesture.onTap?.call();
      await tester.pumpAndSettle();

      verify(
        () => vm.downloadDocument(
          "drive-8",
          "https://example.com/8",
          "Fallback Document Name",
        ),
      ).called(1);
    });

    testWidgets("tapping file icon downloads document", (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final row = buildDocSubType(
        applicationId: 9,
        isChecked: false,
        fileName: "icon-file.pdf",
        docName: "Icon File Name",
        driveItemId: "drive-9",
        webUrl: "https://example.com/9",
      );

      final year = DocYearDetail(
        docYear: 2028,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(iconFinder(), findsOneWidget);

      final iconGestureFinder = find.ancestor(
        of: iconFinder(),
        matching: find.byType(GestureDetector),
      );

      final iconGesture =
          tester.widget<GestureDetector>(iconGestureFinder.first);
      iconGesture.onTap?.call();
      await tester.pumpAndSettle();

      verify(
        () => vm.downloadDocument(
          "drive-9",
          "https://example.com/9",
          "icon-file.pdf",
        ),
      ).called(1);
    });

    testWidgets("tapping subtype text downloads document", (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final row = buildDocSubType(
        applicationId: 10,
        isChecked: false,
        fileName: "text-file.pdf",
        docName: "Text File Name",
        driveItemId: "drive-10",
        webUrl: "https://example.com/10",
      );

      final year = DocYearDetail(
        docYear: 2029,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(textFinder("Text File Name"), findsOneWidget);

      final textGestureFinder = find.ancestor(
        of: textFinder("Text File Name"),
        matching: find.byType(GestureDetector),
      );

      final textGesture =
          tester.widget<GestureDetector>(textGestureFinder.first);
      textGesture.onTap?.call();
      await tester.pumpAndSettle();

      verify(
        () => vm.downloadDocument(
          "drive-10",
          "https://example.com/10",
          "text-file.pdf",
        ),
      ).called(1);
    });

    testWidgets("toggling checkbox calls selection method", (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final row = buildDocSubType(
        applicationId: 11,
        isChecked: false,
        fileName: "checkbox-file.pdf",
        docName: "Checkbox File Name",
        driveItemId: "drive-11",
        webUrl: "https://example.com/11",
      );

      final year = DocYearDetail(
        docYear: 2030,
        docSubType: [row],
      );

      final builtChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, builtChild);

      expect(checkboxFinder(), findsOneWidget);

      final checkbox = tester.widget<Checkbox>(checkboxFinder().first);
      checkbox.onChanged?.call(true);
      await tester.pumpAndSettle();

      verify(
        () => vm.toggleDocumentSelection(
          "11",
          isSelected: true,
          any(),
        ),
      ).called(1);
    });

    testWidgets("renders multiple non-credit rows", (tester) async {
      final doc = buildDocument(
        type: DocumentType.other.toString(),
        docTypeId: DocumentType.other,
      );

      final first = buildDocSubType(
        applicationId: 12,
        isChecked: false,
        fileName: "first.pdf",
        docName: "First Document",
        driveItemId: "drive-12",
        webUrl: "https://example.com/12",
      );

      final second = buildDocSubType(
        applicationId: 13,
        isChecked: true,
        fileName: "second.pdf",
        docName: "Second Document",
        driveItemId: "drive-13",
        webUrl: "https://example.com/13",
      );

      final year = DocYearDetail(
        docYear: 2031,
        docSubType: [first, second],
      );

      final firstChild = await buildListItem(
        tester,
        document: doc,
        year: year,
      );
      await pumpBuiltChild(tester, firstChild);
      expect(textFinder("First Document"), findsOneWidget);

      final secondChild = await buildListItem(
        tester,
        document: doc,
        year: year,
        index: 1,
      );
      await pumpBuiltChild(tester, secondChild);
      expect(textFinder("Second Document"), findsOneWidget);
    });
  });
}
