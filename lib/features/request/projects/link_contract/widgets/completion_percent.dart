import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/percentage_input_formatter.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

class CompletionPercent extends StatelessWidget {
  const CompletionPercent({required this.viewModel, super.key});
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
            double.tryParse(val.toString()),
        onSaved: (val) {
          viewModel.contract.completionPercentage =
              double.tryParse(val.toString());
        },
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
          v,
          "project.linkContract.pleaseEnterCompletion".tr(),
        ),
        maxLength: 7,
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          PercentageInputFormatter(), //reusable
        ],
      ),
    );
  }
}
