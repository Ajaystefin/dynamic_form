import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// PO Box field for the customer information screen.
class PoBox extends StatelessWidget {
  /// Creates a PO Box field.
  const PoBox({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue = viewModel.customerInformation?.poBox ?? "";
    final bool isValid =
        !viewModel.canEdit; // && initialValue.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: !viewModel.isFI,
            label: "customerInformation.customerInformation.pOBoxNo".tr(),
            child: CustomTextField(
              key: const ValueKey("pOBoxNo"),
              semanticLabel:
                  "customerInformation.customerInformation.pOBoxNo".tr(),
              initialValue: initialValue,
              // controller: viewModel.controller(
              //   CustomerInfoFields.poBox,
              // ),
              filled: isValid,
              maxLength: 50,
              inputFormatters: [viewModel.freeTextFormatter],
              readOnly: isValid,
              validator:
                  (viewModel.isFI) ? null : CustomValidator.requiredField,
              onSaved: (value) {
                viewModel.customerInformation?.poBox = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
