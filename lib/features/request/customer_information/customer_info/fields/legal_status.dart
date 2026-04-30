import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class LegalStatusField extends StatelessWidget {
  const LegalStatusField({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.legalStatus ?? "";
    //final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;
    return LabelWidget(
      label: "customerInformation.customerInformation.legalStatus".tr(),
      child: CustomTextField(
        key: const ValueKey("legalStatus"),
        semanticLabel:
            "customerInformation.customerInformation.legalStatus".tr(),
        initialValue: initialValue,
        filled: true,
        readOnly: true,
        onSaved: (value) {
          viewModel.customerInformation?.legalStatus = value;
        },
      ),
    );
  }
}
