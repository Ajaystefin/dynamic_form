import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

/// LegacyFilesWidget stateless widget
class LegacyFilesWidget extends StatelessWidget {
  /// Creates [LegacyFilesWidget] instance
  const LegacyFilesWidget({
    required this.legacyFiles,
    required this.viewModel,
    super.key,
  });

  /// List of LegacyFiles
  final List<LegacyFiles>? legacyFiles;

  /// AttachmentViewModel view model
  final AttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final legacyYears = (legacyFiles != null && legacyFiles!.isNotEmpty)
        ? legacyFiles!.first.years ?? []
        : [];

    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: legacyYears.length,
        itemBuilder: (context, index1) {
          final legacyFile1 = legacyYears[index1];

          return CustomAccordion(
            title: "${legacyFile1.docYear}",
            children: [
              if (legacyFiles?.first.docType == DocumentType.creditApplication)
                _buildCreditApplicationSection(legacyFile1)
              else
                _buildDefaultSection(legacyFile1),
            ],
          );
        },
      ),
    );
  }

  /// CREDIT APPLICATION FLOW
  Widget _buildCreditApplicationSection(DocYearDetail legacyFile1) {
    final caLegacyList = legacyFile1.caLegacy ?? [];

    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Column(
        children: List.generate(caLegacyList.length, (index2) {
          final legacyFile2 = caLegacyList[index2];

          return CustomAccordion(
            title: "${legacyFile2.appRefNo}",
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Column(
                  children: List.generate(
                    legacyFile2.caDocCategory?.length ?? 0,
                    (index4) => innerAccordion(
                      legacyFile1,
                      index2,
                      index4,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// DEFAULT FLOW (non-credit application)
  Widget _buildDefaultSection(DocYearDetail legacyFile1) {
    final docs = legacyFile1.docSubType ?? [];

    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Column(
        children: List.generate(docs.length, (index3) {
          final doc = docs[index3]?.data;

          return Padding(
            padding: const EdgeInsets.only(left: 25),
            child: _buildDocumentRow(doc),
          );
        }),
      ),
    );
  }

  /// INNER CATEGORY ACCORDION
  Widget innerAccordion(
    DocYearDetail legacyFile,
    int index2,
    int index4,
  ) {
    final category = legacyFile.caLegacy?[index2].caDocCategory?[index4];

    return CustomAccordion(
      title: category?.categoryName ?? "",
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Column(
            children: List.generate(
              category?.docSubType?.length ?? 0,
              (index6) {
                final doc = category?.docSubType?[index6].data;

                return Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: _buildDocumentRow(doc),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// DOCUMENT ROW
  Widget _buildDocumentRow(DocSubTypeData? docSubType) {
    final String key =
        docSubType?.applicationID.toString() ?? UniqueKey().toString();

    final bool isChecked = docSubType?.isChecked ?? false;

    String subtypeText = "";

    switch (docSubType?.docTypeId) {
      case DocumentType.financialStatements:
        subtypeText = docSubType?.subType?.name ?? "";

      case DocumentType.creditLensDocument:
        subtypeText = docSubType?.subType?.name ?? "";

      case DocumentType.other:
      case DocumentType.externalOpinions:
      case DocumentType.constitutionalDocument:
      case DocumentType.creditApplication:
        subtypeText = docSubType?.fileName ?? "";

      default:
        subtypeText = "";
    }

    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(
              key,
              isSelected: value ?? false,
              docSubType,
            );
          },
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _download(docSubType),
          child: const Icon(Icons.file_present_outlined, size: 18),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _download(docSubType),
          child: Text(
            subtypeText,
            style: AppStyle.documentNameStyle,
          ),
        ),
        if (subtypeText.isNotEmpty &&
            docSubType?.docTypeId == DocumentType.financialStatements) ...[
          const SizedBox(width: 50),
          Text(
            docSubType?.subSubType?.name ?? "",
            style: AppStyle.documentSubTypeStyle,
          ),
        ],
      ],
    );
  }

  void _download(DocSubTypeData? docSubType) {
    viewModel.downloadDocument(
      docSubType?.edmsDriveItemId ?? "",
      docSubType?.webUrl ?? "",
      docSubType?.fileName ?? "",
    );
  }
}
