import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Industry description field for the customer information screen.
class IndustryDescriptionField extends StatelessWidget {
  /// Creates an industry description field.
  const IndustryDescriptionField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isValid = !viewModel.canEdit;
    return LabelWidget(
      label: "customerInformation.customerInformation.industryDescription".tr(),
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.industryDescription".tr(),
        key: ValueKey(viewModel.selectedProposedSicCode?.description),
        initialValue: viewModel.customerInformation?.industryDescription,
        hintText: viewModel.customerInformation?.industryDescription,
        maxLength: 50,
        filled: isValid,
        readOnly: isValid,
        onSaved: (value) {
          viewModel.customerInformation?.industryDescription = value;
        },
      ),
    );
  }
}
