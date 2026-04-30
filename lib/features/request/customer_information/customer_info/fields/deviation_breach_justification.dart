import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class DeviationBreachJustification extends StatelessWidget {
  const DeviationBreachJustification({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    //bool isVisible = viewModel.state.isPolicyDeviation == true;
    return LabelWidget(
      label: (viewModel.isFI)
          ? "customerInformation.customerInformation.remarksJustification".tr()
          : "customerInformation.customerInformation."
                  "deviationBreachJustification"
              .tr(),
      showLabel: true,
      isRequired: true,
      child: CustomTextArea(
        key: ValueKey(
          (viewModel.isFI)
              ? "customerInformation.customerInformation.remarksJustification"
                  .tr()
              : "customerInformation.customerInformation."
                      "deviationBreachJustification"
                  .tr(),
        ),
        semanticLabel: (viewModel.isFI)
            ? "customerInformation.customerInformation.remarksJustification"
                .tr()
            : "customerInformation.customerInformation."
                    "deviationBreachJustification"
                .tr(),
        maxLength: 2000,
        hintText: "",
        counterText: "",
        validator: CustomValidator.requiredField,
        initialValue:
            viewModel.customerInformation?.deviationBreachJustification ?? "",
        onSaved: (String? value) {
          viewModel.customerInformation?.deviationBreachJustification =
              value ?? "";
        },
      ),
    );
  }
}
