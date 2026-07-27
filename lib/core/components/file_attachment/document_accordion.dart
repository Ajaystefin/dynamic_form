import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/credit_application_table.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

/// Displays documents grouped by year within an accordion structure.
class DocumentAccordionWidget extends StatelessWidget {
  /// Creates a [DocumentAccordionWidget].
  const DocumentAccordionWidget({
    required this.viewModel,
    required this.document,
    required this.docYear,
    super.key,
  });

  /// Attachment view model.
  final AttachmentViewModel viewModel;

  /// Document details.
  final DocumentDetail document;

  /// Document year details.
  final DocYearDetail docYear;

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
      title: "${docYear.docYear}",
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25, bottom: 1),
          child: _buildDocumentChildren(context),
        ),
      ],
    );
  }

  /// Builds the document content for the selected year.
  Widget _buildDocumentChildren(BuildContext context) {
    if (document.docTypeId == DocumentType.creditApplication) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: docYear.caDocTypeData?.length ?? 0,
        itemBuilder: (context, index) {
          final caSubType = docYear.caDocTypeData?[index];
          return CustomAccordion(
            title: caSubType?.caSubTypeName ?? "",
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 1),
                child: creditApplicationTable(
                  context,
                  viewModel,
                  caSubType?.docSubType,
                ),
              ),
            ],
          );
        },
      );
    }

    // - For all other types
    return ListView.builder(
      shrinkWrap: true,
      itemCount: docYear.docSubType?.length ?? 0,
      itemBuilder: (context, index) {
        final docSubType = docYear.docSubType![index];
        return _buildDocumentRow(docSubType!);
      },
    );
  }

  /// Builds a row representing a document subtype.
  Widget _buildDocumentRow(DocSubTypeDetail docSubType) {
    final String key = docSubType.data!.applicationID.toString();
    final bool isChecked = docSubType.data!.isChecked;
    final String documentName =
        docSubType.data?.fileName ?? docSubType.data?.docName ?? "";
    final docData = docSubType.data;

    // ✅ Determine subtype text dynamically
    String subtypeText = "";
    switch (document.docTypeId) {
      case DocumentType.financialStatements:
        {
          if (docSubType.data?.subSubType?.id ==
              ServerConstants.subSubTypeFinancialProjection) {
            subtypeText = docSubType.data?.docName ?? "";
          } else {
            subtypeText = docSubType.data?.subType?.name ?? "";
          }

          break;
        }
      case DocumentType.creditLensDocument:
        subtypeText = docSubType.data?.subType?.name ?? "";
      case DocumentType.other:
      case DocumentType.externalOpinions:
      case DocumentType.constitutionalDocument:
        subtypeText = docSubType.data?.docName ?? "";
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
              docSubType.data,
            );
          },
        ),
        Semantics(
          button: true,
          label: "common.downloadDocumentWithName".tr(
            namedArgs: {
              "name": documentName,
            },
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              viewModel.downloadDocument(
                docSubType.data?.edmsDriveItemId ?? "",
                docSubType.data?.webUrl ?? "",
                documentName,
              );
            },
            child: const Icon(Icons.file_present_outlined, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: "common.downloadDocumentWithName".tr(
            namedArgs: {
              "name": documentName,
            },
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              viewModel.downloadDocument(
                docSubType.data?.edmsDriveItemId ?? "",
                docSubType.data?.webUrl ?? "",
                documentName,
              );
            },
            child: Text(subtypeText, style: AppStyle.documentNameStyle),
          ),
        ),
        if (subtypeText.isNotEmpty &&
            document.docTypeId == DocumentType.financialStatements) ...[
          const SizedBox(width: 50),
          Text(
            docData?.subSubType?.name ?? "",
            style: AppStyle.documentSubTypeStyle,
          ),
        ],
      ],
    );
  }
}
