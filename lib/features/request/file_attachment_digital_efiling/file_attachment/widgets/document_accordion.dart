import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/credit_application_table.dart';

class DocumentAccordionWidget extends StatelessWidget {
  final dynamic viewModel;
  final dynamic document;
  final dynamic docYear;

  const DocumentAccordionWidget(
      {super.key,
      required this.viewModel,
      required this.document,
      required this.docYear});

  @override
  Widget build(BuildContext context) {
    return CustomAccordion(
      title: "${docYear.docYear}",
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 15),
          child: _buildDocumentChildren(context),
        ),
      ],
    );
  }

  Widget _buildDocumentChildren(BuildContext context) {
    switch (document.docTypeId) {
      case DocumentType.constitutionalDocument:
      case DocumentType.creditLensDocument:
      case DocumentType.externalOpinions:
      case DocumentType.other:
        return ListView.builder(
            shrinkWrap: true,
            itemCount: docYear.docSubType.length,
            itemBuilder: (context, index) {
              final docSubType = docYear.docSubType[index];
              return constitutionalDocumentList(viewModel, docSubType);
            });

      case DocumentType.financialStatements:
        return ListView.builder(
            shrinkWrap: true,
            itemCount: docYear.docSubType.length,
            itemBuilder: (context, index) {
              final docSubType = docYear.docSubType[index];
              return otherDocumentList(viewModel, docSubType);
            });

      case DocumentType.creditApplication:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: docYear.docSubType.length,
          itemBuilder: (context, index) {
            final subType = docYear.docSubType[index];
            return CustomAccordion(
              title: subType.docSubTypeName,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 15),
                  child: creditApplicationTable(viewModel, subType.data),
                ),
              ],
            );
          },
        );

      default:
        return ListView.builder(
            shrinkWrap: true,
            itemCount: docYear.docSubType.length,
            itemBuilder: (context, index) {
              final docSubType = docYear.docSubType[index];
              return otherDocumentList(viewModel, docSubType);
            });
    }
  }

  Widget otherDocumentList(
      FileAttachmentViewModel viewModel, dynamic docSubType) {
    IconData icon = Icons.file_present_outlined;
    final String key = docSubType.data?.applicationID.toString() ?? '';
    final bool isChecked = viewModel.isDocumentSelected(key);
    String documentName = docSubType.data?.docName ?? "Unnamed Document";
    String subType = docSubType.data?.decision ?? "Unknown";

    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(key, value ?? false);
          },
        ),
        Icon(icon, size: 18.0),
        const SizedBox(width: 10),
        Text(
          documentName,
          style: AppStyle.documentNameStyle,
        ),
        const SizedBox(width: 50),
        Text(
          subType,
          style: AppStyle.documentSubTypeStyle,
        ),
      ],
    );
  }

  Widget constitutionalDocumentList(
      FileAttachmentViewModel viewModel, dynamic docSubType) {
    IconData icon = Icons.file_present_outlined;
    final String key = docSubType.data?.applicationID.toString() ?? '';
    final bool isChecked = viewModel.isDocumentSelected(key);
    String documentName = docSubType.data?.docName ?? "Unnamed Document";

    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(key, value ?? false);
          },
        ),
        Icon(icon, size: 18.0),
        const SizedBox(width: 10),
        Text(
          documentName,
          style: AppStyle.documentNameStyle,
        ),
      ],
    );
  }
}
