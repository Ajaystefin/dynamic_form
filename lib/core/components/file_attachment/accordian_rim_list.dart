import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/file_attachment/document_accordion.dart";
import "package:wcas_frontend/core/components/file_attachment/facility_valuation_table.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/legacy_files.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/legacy_uncategorized_files.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

/// Builds the RIM-based document accordion hierarchy.
Widget rimListAccordian(AttachmentViewModel viewModel) {
  final List<FileDetail> fileUploadList = viewModel.fileUploadDatas;

  return ListView.builder(
    shrinkWrap: true,
    itemCount: fileUploadList.length,
    itemBuilder: (BuildContext context, int index1) {
      final fileDetail = fileUploadList[index1];

      final title = (fileDetail.name?.trim().isNotEmpty ?? false)
          ? fileDetail.name!.trim()
          : "N/A"; // company name / rim no

      // Create a sorted, non-null list of documents (copy to avoid mutating the
      // model)
      final List<DocumentDetail> sortedDocuments = List<DocumentDetail>.from(
        fileDetail.documents ?? const <DocumentDetail>[],
      )..sort((a, b) {
          // Keep id 14999 at the end
          if (a.docTypeId == DocumentType.legacy &&
              b.docTypeId != DocumentType.legacy) {
            return 1;
          }
          if (b.docTypeId == DocumentType.legacy &&
              a.docTypeId != DocumentType.legacy) {
            return -1;
          }

          // Case-insensitive, trimmed comparison; nulls go last
          final an = a.name?.trim().toLowerCase();
          final bn = b.name?.trim().toLowerCase();

          if (an == null && bn == null) {
            return 0;
          }
          if (an == null) {
            return 1;
          }
          if (bn == null) {
            return -1;
          }

          return an.compareTo(bn);
        });

      return CustomAccordion(
        title: title,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 5),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedDocuments.length,
              itemBuilder: (BuildContext context, int index2) {
                final documentData = sortedDocuments[index2];

                return CustomAccordion(
                  title: documentData.name ?? "-", // document type
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, bottom: 1),
                      child: Column(
                        children: [
                          // If facility or valuation -> FacilityValuationWidget
                          if (documentData.docTypeId ==
                                  DocumentType.facilityDocuments ||
                              documentData.docTypeId ==
                                  DocumentType.valuationReports)
                            FacilityValuationWidget(
                              viewModel: viewModel,
                              documentData: documentData.documents,
                            )
                          else if (documentData.docTypeId ==
                              DocumentType.legacy)
                            LegacyUncategorizedFilesWidget(
                              viewModel: viewModel,
                              legacyFiles: documentData.legacyFiles,
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  (documentData.docYears ?? const <int>[])
                                      .length,
                              itemBuilder: (BuildContext context, int index3) {
                                return DocumentAccordionWidget(
                                  viewModel: viewModel,
                                  document: documentData,
                                  docYear: documentData.docYears![index3],
                                );
                              },
                            ),

                          // Show legacy folder only if NOT facility AND NOT
                          // valuation
                          if (documentData.docTypeId !=
                                  DocumentType.facilityDocuments &&
                              documentData.docTypeId !=
                                  DocumentType.valuationReports)
                            createLegacyFolder(documentData, viewModel)
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

/// Builds the legacy files accordion for supported document types.
Widget createLegacyFolder(
  DocumentDetail? documents,
  AttachmentViewModel viewModel,
) {
  final bool hasLegacyFiles = documents?.legacyFiles?.isNotEmpty ?? false;

  final bool isEligibleDocType = [
    DocumentType.financialStatements,
    DocumentType.creditLensDocument,
    DocumentType.constitutionalDocument,
    DocumentType.externalOpinions,
    DocumentType.other,
    DocumentType.creditApplication,
  ].contains(documents?.docTypeId);

  if (hasLegacyFiles && isEligibleDocType) {
    return CustomAccordion(
      title: "eDigitalFilingFileAttachments.digitalEfiling.legacyFiles".tr(),
      children: [
        LegacyFilesWidget(
          legacyFiles: documents?.legacyFiles,
          viewModel: viewModel,
        ),
      ],
    );
  } else {
    return const SizedBox();
  }
}
