import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";

class LegacyFilesWidget extends StatelessWidget {
  const LegacyFilesWidget({
    required this.legacyFiles,
    required this.viewModel,
    super.key,
  });
  final List<LegacyFiles>? legacyFiles;
  final DigitalEfilingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final legacyYears = legacyFiles?.first.years ?? [];
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: legacyYears.length,
        itemBuilder: (BuildContext context, int index1) {
          final legacyFile = legacyYears[index1];
          if (legacyYears.isNotEmpty) {
            return CustomAccordion(
              title: "${legacyFile.docYear}",
              children: [
                (legacyFiles?.first.docType == DocumentType.creditApplication)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: legacyFile.caLegacy?.length,
                          itemBuilder: (BuildContext context, int index3) {
                            return CustomAccordion(
                              title: "${legacyFile.caLegacy?[index3].appRefNo}",
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: legacyFile.caLegacy?[index3]
                                        .caDocCategory?.length,
                                    itemBuilder:
                                        (BuildContext context, int index4) {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: legacyFile.caLegacy?[index4]
                                            .caDocCategory?.length,
                                        itemBuilder:
                                            (BuildContext context, int index5) {
                                          return innerAccordion(
                                            legacyFile,
                                            index4,
                                            index5,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: legacyFile.docSubType?.length,
                          itemBuilder: (BuildContext context, int index3) {
                            final doc = legacyFile.docSubType?[index3]?.data;

                            return Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: _buildDocumentRow(doc),
                            );
                          },
                        ),
                      ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  CustomAccordion innerAccordion(
    DocYearDetail legacyFile,
    int index4,
    int index5,
  ) {
    return CustomAccordion(
      title:
          "${legacyFile.caLegacy?[index4].caDocCategory?[index5].categoryName}",
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 25,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: legacyFile
                .caLegacy?[index4].caDocCategory?[index5].docSubType?.length,
            itemBuilder: (
              BuildContext context,
              int index6,
            ) {
              final doc = legacyFile.caLegacy?[index4].caDocCategory?[index5]
                  .docSubType?[index6].data;
              return Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                ),
                child: _buildDocumentRow(
                  doc,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentRow(DocSubTypeData? docSubType) {
    final String key =
        docSubType?.applicationID.toString() ?? UniqueKey().toString();
    final bool isChecked = docSubType?.isChecked ?? false;

    // ✅ Determine subtype text dynamically
    String subtypeText = "";
    switch (docSubType?.docTypeId) {
      case DocumentType.financialStatements:
        {
          subtypeText = docSubType?.subType?.name ?? "";
          break;
        }
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
            viewModel.toggleDocumentSelection(key, value ?? false, docSubType);
          },
        ),
        const Icon(Icons.file_present_outlined, size: 18),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              docSubType?.edmsDriveItemId,
              docSubType?.webUrl,
              docSubType?.fileName,
            );
          },
          child: Text(subtypeText, style: AppStyle.documentNameStyle),
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
}
