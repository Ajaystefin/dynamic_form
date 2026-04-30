import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class IndustrySICCodeField extends StatelessWidget {
  const IndustrySICCodeField({
    required this.viewModel,
    super.key,
  });
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.customerInformation.industrySicCode".tr(),
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.industrySicCode".tr(),
        key: ValueKey(viewModel.selectedProposedSicCode?.name),
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
