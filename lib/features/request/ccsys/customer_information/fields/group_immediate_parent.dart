import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";

/// Displays the group immediate parent field for CCSYS customer information.
class GroupImmediateParent extends StatelessWidget {
  /// Creates the group immediate parent field widget.
  const GroupImmediateParent({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage group immediate parent information and edit access.
  final CustomerInformationViewModel viewModel;

  /// Current customer information state used to control borrower subsidiary behavior.
  final CustomerInformationState state;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message:
          "ccsys.customerInformation.tooltip.groupImmediateParentTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.groupImmediateParent".tr(),
        isRequired: viewModel.canEdit && state.borrowerSubsidiary,
        isEnabled: viewModel.canEdit && state.borrowerSubsidiary,
        child: CustomTextField(
          semanticLabel: "ccsys.customerInformation.groupImmediateParent".tr(),
          controller: viewModel.controllerGroupImmediate,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
            ),
          ],
          initialValue: state.borrowerSubsidiary
              ? "NA"
              : viewModel.customerInformation.groupImmediateParent != null ||
                      viewModel.customerInformation.groupImmediateParent
                              .toString() !=
                          "null"
                  ? viewModel.customerInformation.groupImmediateParent
                              .toString() !=
                          "NA"
                      ? viewModel.customerInformation.groupImmediateParent
                          .toString()
                      : "NA"
                  : "NA",
          filled: !state.borrowerSubsidiary,
          validator:
              state.borrowerSubsidiary ? CustomValidator.requiredField : null,
          onSaved: (String? groupImmediateParent) {
            viewModel.customerInformation.groupImmediateParent =
                groupImmediateParent;
          },
        ),
      ),
    );
  }
}
