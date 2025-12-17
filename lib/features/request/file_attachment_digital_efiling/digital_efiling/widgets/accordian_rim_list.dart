import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/document_accordion.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/facility_valuation_table.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/legacy_files.dart';
import 'package:wcas_frontend/models/request/file_attachment/document_data.dart';

import '../../../../../models/request/file_attachment/file_upload.dart';

Widget rimListAccordian(DigitalEfilingViewModel viewModel) {
  List<FileDetail> fileUploadList = viewModel.fileUploadDatas;

  return ListView.builder(
      shrinkWrap: true,
      itemCount: fileUploadList.length,
      itemBuilder: (BuildContext context, int index1) {
        return CustomAccordion(
          title: fileUploadList[index1].name ?? "", //company name/rim no
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 25.0, bottom: 15),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fileUploadList[index1].documents?.length,
                    itemBuilder: (BuildContext context, int index2) {
                      final documentData =
                          fileUploadList[index1].documents?[index2];
                      return CustomAccordion(
                        title: fileUploadList[index1].documents?[index2].name ??
                            "", //document type(Financial Statement, Creditlens Document, Constitutional Document)
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, bottom: 15),
                            child: Column(
                              children: [
                                documentData?.docTypeId ==
                                            DocumentType.facilityDocuments ||
                                        documentData?.docTypeId ==
                                            DocumentType.valuationReports
                                    ? FacilityValuationWidget(
                                        viewModel: viewModel,
                                        documentData:
                                            (documentData?.documents ?? [])
                                                .map((sub) {
                                          final data = sub?.data;
                                          final date = data?.date;
                                          return {
                                            "refNo": data?.appRefNo,
                                            "acNo": data?.acNo,
                                            "docType": data?.docType?.name,
                                            "scanDate": date == null
                                                ? ''
                                                : DateFormat('dd-MM-yyyy')
                                                    .format(date),
                                            "status": data?.decision,
                                            "remarks": data?.summary,
                                            "fileLink": data?.edmsDriveItemId,
                                            "fileName": data?.fileName
                                          };
                                        }).toList(),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            (documentData?.docYears ?? [])
                                                .length,
                                        itemBuilder:
                                            (BuildContext context, int index3) {
                                          return DocumentAccordionWidget(
                                              viewModel: viewModel,
                                              document: documentData!,
                                              docYear: documentData
                                                  .docYears![index3]);
                                        }),
                                documentData?.docTypeId !=
                                            DocumentType.facilityDocuments ||
                                        documentData?.docTypeId !=
                                            DocumentType.valuationReports
                                    ? createLegacyFolder(
                                        documentData, viewModel)
                                    : const SizedBox.shrink()
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

Widget createLegacyFolder(
    DocumentDetail? documents, DigitalEfilingViewModel viewModel) {
  bool hasLegacyFiles = documents?.legacyFiles?.isNotEmpty ?? false;

  bool isEligibleDocType = [
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
