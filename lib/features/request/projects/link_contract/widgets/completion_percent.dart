import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/percentage_input_formatter.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Completion percentage field for link contract.
class CompletionPercent extends StatelessWidget {
  /// Creates a completion percentage field.
  const CompletionPercent({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "project.linkContract.completionpercent".tr(),
      child: CustomTextField(
        initialValue: viewModel.contract.completionPercentage != null
            ? viewModel.contract.completionPercentage.toString()
            : "",
        semanticLabel: "project.linkContract.completionpercent".tr(),
        onChanged: (val) => viewModel.contract.completionPercentage =
            double.tryParse(val),
        onSaved: (val) {
          viewModel.contract.completionPercentage =
              double.tryParse(val.toString());
        },
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
          v,
          "project.linkContract.pleaseEnterCompletion".tr(),
        ),
        maxLength: 7,
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          PercentageInputFormatter(), //reusable
        ],
      ),
    );
  }
}
