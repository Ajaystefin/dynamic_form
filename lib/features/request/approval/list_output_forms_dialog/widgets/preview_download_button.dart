import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/model.dart";

/// Displays preview and download actions for selected output forms.
class PreviewDownloadButton extends StatelessWidget {
  /// Creates the preview and download button widget.
  const PreviewDownloadButton({required this.viewModel, super.key});

  /// View model used to preview or download selected output forms.
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
              isDownload: false,
              "pdf",
            );
          },
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomDropdownButton(
          label: "approval.listOutputForms.download".tr(),
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
                isDownload: true,
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
