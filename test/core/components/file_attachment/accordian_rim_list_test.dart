import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/file_attachment/accordian_rim_list.dart";
import "package:wcas_frontend/core/components/file_attachment/document_accordion.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/legacy_files.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

class FakeAttachmentViewModel extends Fake implements AttachmentViewModel {
  FakeAttachmentViewModel({
    required this.fileUploadDatas,
  });

  @override
  final List<FileDetail> fileUploadDatas;
}

class FakeLegacyFile extends Fake implements LegacyFiles {}

class FakeDocYearDetail extends Fake implements DocYearDetail {}

class FakeDocumentDetail extends Fake implements DocumentDetail {
  FakeDocumentDetail({
    this.name,
    this.docTypeId,
    this.docYears,
    this.legacyFiles,
  });

  @override
  final String? name;

  @override
  final DocumentType? docTypeId;

  @override
  final List<DocYearDetail>? docYears;

  @override
  final List<LegacyFiles>? legacyFiles;
}

class FakeFileDetail extends Fake implements FileDetail {
  FakeFileDetail({
    this.name,
    this.documents,
  });

  @override
  final String? name;

  @override
  final List<DocumentDetail>? documents;
}

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SizedBox.shrink(),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return tester.element(find.byType(SizedBox).first);
}

ListView _rootListViewFromWidget(Widget widget) {
  expect(widget, isA<ListView>());
  return widget as ListView;
}

SliverChildBuilderDelegate _delegateFromListView(ListView listView) {
  expect(listView.childrenDelegate, isA<SliverChildBuilderDelegate>());
  return listView.childrenDelegate as SliverChildBuilderDelegate;
}

CustomAccordion _outerAccordionAt({
  required WidgetTester tester,
  required BuildContext context,
  required AttachmentViewModel viewModel,
  required int index,
}) {
  final Widget root = rimListAccordian(viewModel);
  final ListView listView = _rootListViewFromWidget(root);
  final SliverChildBuilderDelegate delegate = _delegateFromListView(listView);

  final Widget? built = delegate.builder(context, index);
  expect(built, isA<CustomAccordion>());

  return built! as CustomAccordion;
}

ListView _documentListViewFromOuterAccordion(CustomAccordion accordion) {
  expect(accordion.children.length, 1);

  final Padding outerPadding = accordion.children.first as Padding;
  expect(outerPadding.child, isA<ListView>());

  return outerPadding.child! as ListView;
}

CustomAccordion _documentAccordionAt({
  required BuildContext context,
  required CustomAccordion outerAccordion,
  required int index,
}) {
  final ListView innerList =
      _documentListViewFromOuterAccordion(outerAccordion);
  final SliverChildBuilderDelegate delegate = _delegateFromListView(innerList);

  final Widget? built = delegate.builder(context, index);
  expect(built, isA<CustomAccordion>());

  return built! as CustomAccordion;
}

Column _columnFromDocumentAccordion(CustomAccordion accordion) {
  expect(accordion.children.length, 1);

  final Padding padding = accordion.children.first as Padding;
  expect(padding.child, isA<Column>());

  return padding.child! as Column;
}

void main() {
  group("createLegacyFolder", () {
    testWidgets(
      "returns CustomAccordion when doc type is eligible and legacy files exist",
      (WidgetTester tester) async {
        await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[],
        );

        final FakeDocumentDetail document = FakeDocumentDetail(
          docTypeId: DocumentType.financialStatements,
          legacyFiles: <LegacyFiles>[FakeLegacyFile()],
        );

        final Widget result = createLegacyFolder(document, viewModel);

        expect(result, isA<CustomAccordion>());

        final CustomAccordion accordion = result as CustomAccordion;
        expect(accordion.children.length, 1);
        expect(accordion.children.first, isA<LegacyFilesWidget>());
      },
    );

    testWidgets(
      "returns SizedBox when legacy files are empty",
      (WidgetTester tester) async {
        await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[],
        );

        final FakeDocumentDetail document = FakeDocumentDetail(
          docTypeId: DocumentType.financialStatements,
          legacyFiles: <LegacyFiles>[],
        );

        final Widget result = createLegacyFolder(document, viewModel);

        expect(result, isA<SizedBox>());
      },
    );

    testWidgets(
      "returns SizedBox when doc type is not eligible",
      (WidgetTester tester) async {
        await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[],
        );

        final FakeDocumentDetail document = FakeDocumentDetail(
          docTypeId: DocumentType.facilityDocuments,
          legacyFiles: <LegacyFiles>[FakeLegacyFile()],
        );

        final Widget result = createLegacyFolder(document, viewModel);

        expect(result, isA<SizedBox>());
      },
    );

    testWidgets(
      "returns SizedBox when document is null",
      (WidgetTester tester) async {
        await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[],
        );

        final Widget result = createLegacyFolder(null, viewModel);

        expect(result, isA<SizedBox>());
      },
    );

    testWidgets(
      "returns SizedBox when legacy files are null",
      (WidgetTester tester) async {
        await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[],
        );

        final FakeDocumentDetail document = FakeDocumentDetail(
          docTypeId: DocumentType.financialStatements,
        );

        final Widget result = createLegacyFolder(document, viewModel);

        expect(result, isA<SizedBox>());
      },
    );
  });

  group("rimListAccordian", () {
    testWidgets(
      "uses trimmed file title",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "  ABC Company  ",
              documents: <DocumentDetail>[],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        expect(outer.title, "ABC Company");
      },
    );

    testWidgets(
      "uses N/A when file name is blank",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "   ",
              documents: <DocumentDetail>[],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        expect(outer.title, "N/A");
      },
    );

    testWidgets(
      "uses N/A when file name is null",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              documents: <DocumentDetail>[],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        expect(outer.title, "N/A");
      },
    );

    testWidgets(
      "sorts document names case-insensitively",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "RIM 1",
              documents: <DocumentDetail>[
                FakeDocumentDetail(
                  name: "beta",
                  docTypeId: DocumentType.other,
                  docYears: <DocYearDetail>[],
                  legacyFiles: <LegacyFiles>[],
                ),
                FakeDocumentDetail(
                  name: "Alpha",
                  docTypeId: DocumentType.other,
                  docYears: <DocYearDetail>[],
                  legacyFiles: <LegacyFiles>[],
                ),
              ],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        final CustomAccordion firstDoc = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 0,
        );

        final CustomAccordion secondDoc = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 1,
        );

        expect(firstDoc.title, "Alpha");
        expect(secondDoc.title, "beta");
      },
    );

    testWidgets(
      "puts null document names after non-null names",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "RIM 8",
              documents: <DocumentDetail>[
                FakeDocumentDetail(
                  docTypeId: DocumentType.other,
                  docYears: <DocYearDetail>[],
                  legacyFiles: <LegacyFiles>[],
                ),
                FakeDocumentDetail(
                  name: "Alpha",
                  docTypeId: DocumentType.other,
                  docYears: <DocYearDetail>[],
                  legacyFiles: <LegacyFiles>[],
                ),
              ],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        final CustomAccordion firstDoc = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 0,
        );

        final CustomAccordion secondDoc = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 1,
        );

        expect(firstDoc.title, "Alpha");
        expect(secondDoc.title, "-");
      },
    );

    testWidgets(
      "uses - when document name is null",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "RIM 9",
              documents: <DocumentDetail>[
                FakeDocumentDetail(
                  docTypeId: DocumentType.other,
                  docYears: <DocYearDetail>[],
                  legacyFiles: <LegacyFiles>[],
                ),
              ],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        final CustomAccordion docAccordion = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 0,
        );

        expect(docAccordion.title, "-");
      },
    );

    testWidgets(
      "builds DocumentAccordionWidget list for normal document types",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "RIM 4",
              documents: <DocumentDetail>[
                FakeDocumentDetail(
                  name: "Other Docs",
                  docTypeId: DocumentType.other,
                  docYears: <DocYearDetail>[
                    FakeDocYearDetail(),
                    FakeDocYearDetail(),
                  ],
                  legacyFiles: <LegacyFiles>[],
                ),
              ],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        final CustomAccordion docAccordion = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 0,
        );

        expect(docAccordion.title, "Other Docs");

        final Column column = _columnFromDocumentAccordion(docAccordion);

        expect(column.children.first, isA<ListView>());
        expect(column.children[1], isA<SizedBox>());

        final ListView yearList = column.children.first as ListView;
        final SliverChildBuilderDelegate delegate =
            _delegateFromListView(yearList);

        expect(delegate.childCount, 2);
        expect(delegate.builder(context, 0), isA<DocumentAccordionWidget>());
        expect(delegate.builder(context, 1), isA<DocumentAccordionWidget>());
      },
    );

    testWidgets(
      "adds legacy folder for eligible document types with legacy files",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "RIM 5",
              documents: <DocumentDetail>[
                FakeDocumentDetail(
                  name: "Financial Statements",
                  docTypeId: DocumentType.financialStatements,
                  docYears: <DocYearDetail>[],
                  legacyFiles: <LegacyFiles>[FakeLegacyFile()],
                ),
              ],
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        final CustomAccordion docAccordion = _documentAccordionAt(
          context: context,
          outerAccordion: outer,
          index: 0,
        );

        final Column column = _columnFromDocumentAccordion(docAccordion);

        expect(column.children.first, isA<ListView>());
        expect(column.children[1], isA<CustomAccordion>());

        final CustomAccordion legacyAccordion =
            column.children[1] as CustomAccordion;
        expect(legacyAccordion.children.first, isA<LegacyFilesWidget>());
      },
    );

    testWidgets(
      "handles null documents list safely",
      (WidgetTester tester) async {
        final BuildContext context = await _pumpHost(tester);

        final FakeAttachmentViewModel viewModel = FakeAttachmentViewModel(
          fileUploadDatas: <FileDetail>[
            FakeFileDetail(
              name: "RIM 7",
            ),
          ],
        );

        final CustomAccordion outer = _outerAccordionAt(
          tester: tester,
          context: context,
          viewModel: viewModel,
          index: 0,
        );

        expect(outer.title, "RIM 7");

        final ListView documentList =
            _documentListViewFromOuterAccordion(outer);
        final SliverChildBuilderDelegate delegate =
            _delegateFromListView(documentList);

        expect(delegate.childCount, 0);
      },
    );
  });
}
