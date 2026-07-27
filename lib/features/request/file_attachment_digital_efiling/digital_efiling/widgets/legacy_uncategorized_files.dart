import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

class LegacyUncategorizedFilesWidget extends StatelessWidget {
  /// Creates [LegacyUncategorizedFilesWidget] instance
  const LegacyUncategorizedFilesWidget({
    required this.legacyFiles,
    required this.viewModel,
    super.key,
  });

  /// List of LegacyFiles
  final List<LegacyFiles?>? legacyFiles;

  /// AttachmentViewModel view model
  final AttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: legacyFiles?[0]?.apps?.length ?? 0,
      itemBuilder: (context, index) {
        final yearObj = legacyFiles?[0]?.apps?[index];
        return CustomAccordion(
          title: yearObj.appRefNo ?? "",
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 1),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: yearObj.docSubType?.length ?? 0,
                itemBuilder: (context, index) {
                  final docSubType = yearObj.docSubType![index];
                  return _buildDocumentRow(docSubType);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentRow(DocSubTypeDetail docSubType) {
    final String key = docSubType.data!.applicationID.toString();
    final bool isChecked = docSubType.data!.isChecked;
    final String documentName =
        docSubType.data?.fileName ?? docSubType.data?.docName ?? "";
    final docData = docSubType.data;
    final createdDate =
        DateFormat("dd-MM-yyyy").format(docData?.date ?? DateTime.now());

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
            child: Text(documentName, style: AppStyle.documentNameStyle),
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
            child: Text(createdDate, style: AppStyle.documentSubTypeStyle),
          ),
        ),
      ],
    );
  }
}
