import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/other_widget.dart';
import 'package:wcas_frontend/models/request/file_attachment/legacy_files.dart';

class LegacyFilesWidget extends StatelessWidget {
  final List<LegacyFiles>? legacyFiles;
  final DigitalEfilingViewModel viewModel;

  const LegacyFilesWidget({
    super.key,
    required this.legacyFiles,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: legacyFiles?.length,
        itemBuilder: (BuildContext context, int index1) {
          final legacyFile = legacyFiles?[index1];
          return CustomAccordion(
            title: "${legacyFile?.years?[index1].docYear}",
            children: [
              (legacyFile?.docType == DocumentType.creditApplication)
                  ? const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text("constitutional doc type"),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            legacyFile?.years?[index1].docSubType?.length,
                        itemBuilder: (BuildContext context, int index3) {
                          final doc = legacyFile
                              ?.years?[index1].docSubType?[index3]?.data;
                          final key = "${doc?.applicationID}_${doc?.docName}";
                          final isChecked = viewModel.isDocumentSelected(key);

                          return Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: OtherDocumentList(
                              viewModel: viewModel,
                              documentName: doc?.docName ?? "-",
                              subType: "",
                              isChecked: isChecked,
                              onChanged: (value) {
                                viewModel.toggleDocumentSelection(
                                    key, value ?? false, doc);
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
