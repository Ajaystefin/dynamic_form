import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Primary business activity field for the customer information screen.
class PrimaryBusinessActivity extends StatelessWidget {
  /// Creates a primary business activity field.
  const PrimaryBusinessActivity({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.primaryBusinessActivity ?? "";
    final bool isValid =
        !viewModel.canEdit; // && initialValue.trim().isNotEmpty;
    return LabelWidget(
      isRequired: !viewModel.isFI,
      label: "customerInformation.customerInformation.primaryBusinessActivity"
          .tr(),
      child: CustomTextField(
        key: const ValueKey("primaryBusinessActivity"),
        semanticLabel:
            "customerInformation.customerInformation.primaryBusinessActivity"
                .tr(),
        initialValue: initialValue,
        maxLength: 50,
        filled: isValid,
        readOnly: isValid,
        onSaved: (value) {
          viewModel.customerInformation?.primaryBusinessActivity = value;
        },
        validator: (viewModel.isFI) ? null : CustomValidator.requiredField,
      ),
    );
  }
}
