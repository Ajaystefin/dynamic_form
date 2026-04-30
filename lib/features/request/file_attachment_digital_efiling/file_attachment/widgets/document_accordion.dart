import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/credit_application_table.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";

class DocumentAccordionWidget extends StatelessWidget {
  const DocumentAccordionWidget({
    required this.viewModel,
    required this.document,
    required this.docYear,
    super.key,
  });
  final FileAttachmentViewModel viewModel;
  final DocumentDetail? document;
  final DocYearDetail? docYear;

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
      title: "${docYear?.docYear}",
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25, bottom: 15),
          child: _buildDocumentChildren(context),
        ),
      ],
    );
  }

  Widget _buildDocumentChildren(BuildContext context) {
    if (document?.docTypeId == DocumentType.creditApplication) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: docYear?.caDocTypeData?.length ?? 0,
        itemBuilder: (context, index) {
          final caSubType = docYear?.caDocTypeData?[index];
          return CustomAccordion(
            title: caSubType?.caSubTypeName ?? "",
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 15),
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
      itemCount: docYear?.docSubType?.length ?? 0,
      itemBuilder: (context, index) {
        final docSubType = docYear?.docSubType![index];
        return _buildDocumentRow(docSubType!);
      },
    );
  }

  Widget _buildDocumentRow(DocSubTypeDetail docSubType) {
    final String key = docSubType.data!.applicationID.toString();
    final bool isChecked = docSubType.data!.isChecked;
    final String documentName =
        docSubType.data?.fileName ?? docSubType.data?.docName ?? "";
    final docData = docSubType.data;

    // ✅ Determine subtype text dynamically
    String subtypeText = "";
    switch (document?.docTypeId) {
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
              value ?? false,
              docSubType.data,
            );
          },
        ),
        const Icon(Icons.file_present_outlined, size: 18),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              docSubType.data?.edmsDriveItemId,
              docSubType.data?.webUrl,
              documentName,
            );
          },
          child: Text(subtypeText, style: AppStyle.documentNameStyle),
        ),
        if (subtypeText.isNotEmpty &&
            document?.docTypeId == DocumentType.financialStatements) ...[
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
