import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

/// Displays the capital amount field for CCSYS customer information.
class Capital extends StatelessWidget {
  /// Creates the capital field widget.
  const Capital({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage capital information and edit access.
  final CustomerInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message: "ccsys.customerInformation.tooltip.capitalInAEDTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.capital".tr(),
        isRequired: viewModel.canEdit,
        child: CustomTextField(
          semanticLabel: "ccsys.customerInformation.capital".tr(),
          readOnly: !viewModel.canEdit,
          filled: !viewModel.canEdit,
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
          validator:
              (!viewModel.canEdit) ? null : CustomValidator.requiredField,
          inputFormatters: [
            // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            DecimalInputFormatter(
              regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
            ),
          ],
        ),
      ),
    );
  }
}
