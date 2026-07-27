import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

/// Displays the turnover amount field for CCSYS customer information.
class Turnover extends StatelessWidget {
  /// Creates the turnover field widget.
  const Turnover({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage turnover information and edit access.
  final CustomerInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message: "ccsys.customerInformation.tooltip.turnoverInAEDTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.turnover".tr(),
        isRequired: viewModel.canEdit,
        child: CustomTextField(
          semanticLabel: "ccsys.customerInformation.turnover".tr(),
          readOnly: !viewModel.canEdit,
          filled: !viewModel.canEdit,
          initialValue: viewModel.customerInformation.turnover != null ||
                  viewModel.customerInformation.turnover.toString() != "null"
              ? viewModel.customerInformation.turnover.toString()
              : "",
          validator:
              (!viewModel.canEdit) ? null : CustomValidator.requiredField,
          inputFormatters: [
            // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            DecimalInputFormatter(
              regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
            ),
          ],
          controller: viewModel.turnoverController,
          onChanged: (String? value) {
            viewModel.customerInformation.turnover = value ?? "";
          },
          onSaved: (String? value) {
            viewModel.customerInformation.turnover = value ?? "";
          },
        ),
      ),
    );
  }
}
