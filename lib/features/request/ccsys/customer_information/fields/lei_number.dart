import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";

/// Displays the LEI number field for CCSYS customer information.
class LeiNumber extends StatelessWidget {
  /// Creates the LEI number field widget.
  const LeiNumber({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage LEI number information and edit access.
  final CustomerInformationViewModel viewModel;

  /// Current customer information state used to control legal entity behavior.
  final CustomerInformationState state;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message: "ccsys.customerInformation.tooltip.leiNumberTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.leiNumber".tr(),
        isRequired: viewModel.canEdit && state.legalEntityIdentifier,
        child: CustomTextField(
          readOnly: !viewModel.canEdit || !state.legalEntityIdentifier,
          filled: !viewModel.canEdit || !state.legalEntityIdentifier,
          maxLength: 20,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
            ),
            LengthLimitingTextInputFormatter(20), // limit to 20 chars
          ],
          semanticLabel: "ccsys.customerInformation.leiNumber".tr(),
          initialValue: !state.legalEntityIdentifier
              ? "NA"
              : viewModel.customerInformation.leiNumber != null ||
                      viewModel.customerInformation.leiNumber.toString() !=
                          "null"
                  ? viewModel.customerInformation.leiNumber.toString() != "NA"
                      ? viewModel.customerInformation.leiNumber.toString()
                      : "NA"
                  : "NA",
          controller: viewModel.leiController,
          validator: state.legalEntityIdentifier
              ? CustomValidator.requiredField
              : null,
          onSaved: (String? value) {
            viewModel.customerInformation.leiNumber = value;
          },
        ),
      ),
    );
  }
}
