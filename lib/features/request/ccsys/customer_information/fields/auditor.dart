import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

/// Displays the auditor name field for CCSYS customer information.
class Auditor extends StatelessWidget {
  /// Creates the auditor field widget.
  const Auditor({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage auditor information and edit access.
  final CustomerInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message: "ccsys.customerInformation.tooltip.auditorTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.auditorName".tr(),
        isRequired: viewModel.canEdit,
        child: CustomTextField(
          semanticLabel: "ccsys.customerInformation.auditorName".tr(),
          initialValue: viewModel.customerInformation.auditor ?? "",
          maxLength: 100,
          readOnly: !viewModel.canEdit,
          filled: !viewModel.canEdit,
          validator:
              (!viewModel.canEdit) ? null : CustomValidator.requiredField,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"),
            ),
          ],
          controller: viewModel.auditorController,
          onChanged: (String? value) {
            viewModel.customerInformation.auditor = value ?? "";
          },
          onSaved: (String? value) {
            viewModel.customerInformation.auditor = value ?? "";
          },
        ),
      ),
    );
  }
}
