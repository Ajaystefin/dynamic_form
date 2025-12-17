import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/credit_application_table.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_year.dart';
import 'package:wcas_frontend/models/request/file_attachment/document_data.dart';

class DocumentAccordionWidget extends StatelessWidget {
  final DigitalEfilingViewModel viewModel;
  final DocumentDetail document;
  final DocYearDetail docYear;

  const DocumentAccordionWidget({
    super.key,
    required this.viewModel,
    required this.document,
    required this.docYear,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
      title: "${docYear.docYear}",
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 15),
          child: _buildDocumentChildren(),
        ),
      ],
    );
  }

  Widget _buildDocumentChildren() {
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
                padding: const EdgeInsets.only(left: 25.0, bottom: 15),
                child: creditApplicationTable(viewModel, caSubType?.docSubType),
              ),
            ],
          );
        },
      );
    }

    // ✅ For all other types
    return ListView.builder(
      shrinkWrap: true,
      itemCount: docYear.docSubType?.length ?? 0,
      itemBuilder: (context, index) {
        final docSubType = docYear.docSubType![index];
        return _buildDocumentRow(docSubType!);
      },
    );
  }

  Widget _buildDocumentRow(DocSubTypeDetail docSubType) {
    final String key = docSubType.data!.applicationID.toString();
    final bool isChecked = docSubType.data!.isChecked;
    final String documentName = docSubType.data?.docName ?? "Unnamed Document";
    final docData = docSubType.data;

    // ✅ Determine subtype text dynamically
    String subtypeText = "";
    switch (document.docTypeId) {
      case DocumentType.financialStatements:
        {
          subtypeText = docSubType.data?.docName ?? "";

          break;
        }
      case DocumentType.creditLensDocument:
        subtypeText = docSubType.data?.docName ?? "";
        break;
      case DocumentType.other:
      case DocumentType.externalOpinions:
      case DocumentType.constitutionalDocument:
        subtypeText = docSubType.data?.docName ?? "";
        break;
      default:
        subtypeText = "";
    }

    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(
                key, value ?? false, docSubType.data!);
          },
        ),
        const Icon(Icons.file_present_outlined, size: 18.0),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
                docSubType.data?.edmsDriveItemId, documentName);
          },
          child: Text(subtypeText, style: AppStyle.documentNameStyle),
        ),
        if (subtypeText.isNotEmpty &&
            document.docTypeId == DocumentType.financialStatements) ...[
          const SizedBox(width: 50),
          Text(docData?.subSubType?.name ?? "",
              style: AppStyle.documentSubTypeStyle),
        ],
      ],
    );
  }
}
