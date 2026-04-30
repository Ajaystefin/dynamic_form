import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

class Capital extends StatelessWidget {
  const Capital({
    required this.viewModel,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.capital".tr(),
      isRequired: viewModel.canEdit,
      child: CustomTextField(
        semanticLabel: "ccsys.customerInformation.capital".tr(),
        initialValue: viewModel.customerInformation.capital != null ||
                viewModel.customerInformation.capital.toString() != "null"
            ? viewModel.customerInformation.capital.toString()
            : "",
        controller: viewModel.capitalController,
        onSaved: (String? capital) {
          viewModel.customerInformation.capital = capital ?? "0";
        },
        onChanged: (String? capital) {
          viewModel.customerInformation.capital = capital ?? "0";
        },
        validator: (!viewModel.canEdit) ? null : CustomValidator.requiredField,
        inputFormatters: [
          // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          DecimalInputFormatter(regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$")),
        ],
      ),
    );
  }
}
