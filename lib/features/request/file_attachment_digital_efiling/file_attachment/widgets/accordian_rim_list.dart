import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/document_accordion.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/facility_valuation_table.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";

Widget rimListAccordian(FileAttachmentViewModel viewModel) {
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
          // Case-insensitive, trimmed comparison; nulls go last
          final an = a.name?.trim().toLowerCase();
          final bn = b.name?.trim().toLowerCase();
          if (an == null && bn == null) return 0;
          if (an == null) return 1;
          if (bn == null) return -1;
          return an.compareTo(bn);
        });

      return CustomAccordion(
        title: title,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 15),
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
                      padding: const EdgeInsets.only(left: 25, bottom: 15),
                      child: Column(
                        children: [
                          // If facility or valuation -> FacilityValuationWidget
                          (documentData.docTypeId ==
                                      DocumentType.facilityDocuments ||
                                  documentData.docTypeId ==
                                      DocumentType.valuationReports)
                              ? FacilityValuationWidget(
                                  viewModel: viewModel,
                                  documentData: documentData.documents,
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      (documentData.docYears ?? const <int>[])
                                          .length,
                                  itemBuilder:
                                      (BuildContext context, int index3) {
                                    return DocumentAccordionWidget(
                                      viewModel: viewModel,
                                      document: documentData,
                                      docYear: documentData.docYears![index3],
                                    );
                                  },
                                ),
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
