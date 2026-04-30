import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class ConsolidatedCBRDField extends StatelessWidget {
  const ConsolidatedCBRDField({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.cbrbClassification ?? "";
    //final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return LabelWidget(
      label: "customerInformation.customerInformation.consolidatedCBRD".tr(),
      child: CustomTextField(
        key: const ValueKey("consolidatedCBRD"),
        semanticLabel:
            "customerInformation.customerInformation.consolidatedCBRD".tr(),
        initialValue: initialValue,
        filled: true,
        readOnly: true,
        onSaved: (value) {
          viewModel.customerInformation?.cbrbClassification = value;
        },
      ),
    );
  }
}
