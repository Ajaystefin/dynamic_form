import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// CountryNameField stateless widget
class CountryNameField extends StatelessWidget {
  /// Creates [CountryNameField] instance
  const CountryNameField({required this.viewModel, super.key});

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.countryName".tr(),
      isRequired: true,
      isEnabled: !viewModel.isAppendixReadOnly,
      child: CustomTextField(
        key: ValueKey(viewModel.appendix.countryName ?? ""),
        initialValue: viewModel.appendix.countryName,
        readOnly: viewModel.isAppendixReadOnly,
        maxLength: 100,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
        ],
        onSaved: (value) {
          viewModel.countryName = value;
        },
        onChanged: (value) {
          viewModel.countryName = value;
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.countryName".tr();
          }
          return null;
        },
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
