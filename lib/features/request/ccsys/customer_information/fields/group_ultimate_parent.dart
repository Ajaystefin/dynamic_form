import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";

class GroupUltimateParent extends StatelessWidget {
  const GroupUltimateParent({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  final CustomerInformationState state;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.groupUltimateParent".tr(),
      isRequired: (!viewModel.canEdit) ? false : state.borrowerSubsidiary,
      isEnabled: (!viewModel.canEdit) ? false : state.borrowerSubsidiary,
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
    );
  }
}
