import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Industry SIC code field for the customer information screen.
class IndustrySICCodeField extends StatelessWidget {
  /// Creates an industry SIC code field.
  const IndustrySICCodeField({
    required this.viewModel,
    super.key,
  });

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.customerInformation.industrySicCode".tr(),
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.industrySicCode".tr(),
        key: const ValueKey(
          "customerInformation.customerInformation.industrySicCode",
        ),
        initialValue: viewModel.customerInformation?.industrySicCode,
        hintText: viewModel.customerInformation?.industrySicCode,
        maxLength: 70,
        filled: true,
        readOnly: true,
        onSaved: (value) {
          viewModel.customerInformation?.industrySicCode = value;
        },
      ),
    );
  }
}
