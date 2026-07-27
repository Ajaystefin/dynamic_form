import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";

/// Displays the group ultimate parent field for CCSYS customer information.
class GroupUltimateParent extends StatelessWidget {
  /// Creates the group ultimate parent field widget.
  const GroupUltimateParent({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage group ultimate parent information and edit access.
  final CustomerInformationViewModel viewModel;

  /// Current customer information state used to control borrower subsidiary behavior.
  final CustomerInformationState state;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message:
          "ccsys.customerInformation.tooltip.groupUltimateParentTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.groupUltimateParent".tr(),
        isRequired: viewModel.canEdit && state.borrowerSubsidiary,
        isEnabled: viewModel.canEdit && state.borrowerSubsidiary,
        child: CustomTextField(
          semanticLabel: "ccsys.customerInformation.groupUltimateParent".tr(),
          filled: !state.borrowerSubsidiary,
          controller: viewModel.controllerGroupUltimate,
          initialValue: state.borrowerSubsidiary
              ? "NA"
              : viewModel.customerInformation.groupUltimateParent != null ||
                      viewModel.customerInformation.groupUltimateParent
                              .toString() !=
                          "null"
                  ? viewModel.customerInformation.groupUltimateParent
                              .toString() !=
                          "NA"
                      ? viewModel.customerInformation.groupUltimateParent
                          .toString()
                      : "NA"
                  : "NA",
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
            ),
          ],
          validator:
              state.borrowerSubsidiary ? CustomValidator.requiredField : null,
          onSaved: (String? groupUltimateParent) {
            viewModel.customerInformation.groupUltimateParent =
                groupUltimateParent;
          },
        ),
      ),
    );
  }
}
