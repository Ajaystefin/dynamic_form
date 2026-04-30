import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/model.dart";

class PreviewDownloadButton extends StatelessWidget {
  const PreviewDownloadButton({required this.viewModel, super.key});
  final ListOutputFormsDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "approval.listOutputForms.preview".tr(),
          semanticLabel: "approval.listOutputForms.preview".tr(),
          onPressed: () {
            viewModel.downloadOutputForm(
              false,
              "pdf",
            );
          },
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomDropdownButton(
          label: "approval.listOutputForms.download".tr(),
          showValueWithLabel: true,
          isSearchable: false,
          initialOption: CustomDropdownItem(
            isHeader: true,
            value: ServerConstants.pdf,
            onPressed: () async {
              viewModel.selectedDownloadDoctype = ServerConstants.pdf;
            },
          ),
          options: [
            CustomDropdownItem(
              value: ServerConstants.pdf,
              onPressed: () =>
                  {viewModel.selectedDownloadDoctype = ServerConstants.pdf},
            ),
            CustomDropdownItem(
              value: ServerConstants.word,
              onPressed: () =>
                  {viewModel.selectedDownloadDoctype = ServerConstants.word},
            ),
          ],
          callBack: (value) async {
            viewModel.selectedDownloadDoctype = value;
          },
          onButtonPressed: () async {
            unawaited(
              viewModel.downloadOutputForm(
                true,
                viewModel.selectedDownloadDoctype,
              ),
            );
            // viewModel.onGenerateSummary(viewModel.selectedDoctype);
          },
        ),
      ],
    );
  }
}
