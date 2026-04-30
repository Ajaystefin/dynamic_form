import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

class PopulationField extends StatelessWidget {
  const PopulationField({required this.viewModel, super.key});
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.population".tr(),
      showLabel: true,
      isRequired: true,
      isEnabled: !viewModel.isAppendixReadOnly,
      child: CustomTextField(
        readOnly: viewModel.isAppendixReadOnly,

        initialValue: viewModel.appendix.populationText,

        maxLength: 15,
        counterText: "",
        keyboardType: TextInputType.number, // optional but recommended
        onSaved: (value) {
          // save digits-only
          viewModel
              .setPopulation((value ?? "").replaceAll(RegExp("[^0-9]"), ""));
        },
        onChanged: (value) {
          // store raw digits in VM on every keystroke
          viewModel.setPopulation(value.replaceAll(RegExp("[^0-9]"), ""));
        },

        inputFormatters: [
          // allow digits & commas; commas will be reinserted by formatter
          FilteringTextInputFormatter.allow(RegExp(r"[\d,]")),
          // EITHER use intl (uncomment if you prefer):
          TextInputFormatter.withFunction((oldValue, newValue) {
            final digits = newValue.text.replaceAll(RegExp("[^0-9]"), "");
            if (digits.isEmpty) {
              return const TextEditingValue(
                text: "",
                selection: TextSelection.collapsed(offset: 0),
              );
            }
            final formatted = NumberFormat("#,###").format(int.parse(digits));
            return TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(
                offset: formatted.length,
              ), // caret at end
            );
          }),
        ],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.population".tr();
          }
          return null;
        },
        filled: false,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
