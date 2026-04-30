import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

class Turnover extends StatelessWidget {
  const Turnover({
    required this.viewModel,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.turnover".tr(),
      isRequired: viewModel.canEdit,
      child: CustomTextField(
        semanticLabel: "ccsys.customerInformation.turnover".tr(),
        initialValue: viewModel.customerInformation.turnover != null ||
                viewModel.customerInformation.turnover.toString() != "null"
            ? viewModel.customerInformation.turnover.toString()
            : "",
        validator: (!viewModel.canEdit) ? null : CustomValidator.requiredField,
        inputFormatters: [
          // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          DecimalInputFormatter(regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$")),
        ],
        controller: viewModel.turnoverController,
        onChanged: (String? value) {
          viewModel.customerInformation.turnover = value ?? "";
        },
        onSaved: (String? value) {
          viewModel.customerInformation.turnover = value ?? "";
        },
      ),
    );
  }
}
