import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/legacy_files.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/document_accordion.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/facility_valuation_table.dart';

import '../../../../../models/request/file_attachment/file_upload.dart';

Widget rimListAccordian(FileAttachmentViewModel viewModel) {
  List<FileDetail> fileUploadList = viewModel.fileUploadDatas;

  return ListView.builder(
      shrinkWrap: true,
      itemCount: fileUploadList.length,
      itemBuilder: (BuildContext context, int index1) {
        return CustomAccordion(
          title: (fileUploadList[index1].name ?? ""), //company name/rim no
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 25.0, bottom: 15),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fileUploadList[index1].documents?.length,
                    itemBuilder: (BuildContext context, int index2) {
                      return CustomAccordion(
                        title: fileUploadList[index1].documents?[index2].name ??
                            "", //document type(Financial Statement, Creditlens Document, Constitutional Document)
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, bottom: 15),
                            child: Column(
                              children: [
                                fileUploadList[index1]
                                                .documents?[index2]
                                                .docTypeId ==
                                            DocumentType.facilityDocuments ||
                                        fileUploadList[index1]
                                                .documents?[index2]
                                                .docTypeId ==
                                            DocumentType.valuationReports
                                    ? FacilityValuationWidget(
                                        documentData: fileUploadList[index1]
                                                .documents?[index2]
                                                .docYears ??
                                            []
                                                .expand((year) =>
                                                    year.docSubType.map((sub) {
                                                      final data =
                                                          sub.docSubTypeData;
                                                      return {
                                                        "refNo":
                                                            data.applicationID,
                                                        "acNo": data.subType,
                                                        "docType": data.docName,
                                                        "scanDate": DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(data.date),
                                                        "status": data.decision,
                                                        "remarks": data.summary,
                                                        "fileLink":
                                                            data.docName,
                                                      };
                                                    }))
                                                .toList(),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: (fileUploadList[index1]
                                                    .documents?[index2]
                                                    .docYears ??
                                                [])
                                            .length,
                                        itemBuilder:
                                            (BuildContext context, int index3) {
                                          return DocumentAccordionWidget(
                                              viewModel: viewModel,
                                              document: fileUploadList[index1]
                                                  .documents?[index2],
                                              docYear: fileUploadList[index1]
                                                  .documents?[index2]
                                                  .docYears?[index3]);
                                        }),
                                createLegacyFolder(viewModel,
                                    fileUploadList[index1].documents?[index2])
                              ],
                            ),
                          ),
                        ],
                      );
                    })),
          ],
        );
      });
}

Widget createLegacyFolder(viewModel, documents) {
  bool hasLegacyFiles =
      documents.legacyFiles != null && documents.legacyFiles!.isNotEmpty;

  bool isEligibleDocType = [
    DocumentType.financialStatements,
    DocumentType.creditLensDocument,
    DocumentType.constitutionalDocument,
    DocumentType.externalOpinions,
    DocumentType.other,
    DocumentType.creditApplication,
  ].contains(documents.docTypeId);

  if (hasLegacyFiles && isEligibleDocType) {
    return CustomAccordion(
      title: "eDigitalFilingFileAttachments.digitalEfiling.legacyFiles".tr(),
      children: [
        LegacyFilesWidget(
          legacyFiles: documents.legacyFiles!,
          viewModel: viewModel,
        ),
      ],
    );
  } else {
    return const SizedBox();
  }
}
