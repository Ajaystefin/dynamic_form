import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Customer RIM field for the link contract screen.
class LinkCustomerRim extends StatelessWidget {
  /// Creates a customer RIM field.
  const LinkCustomerRim({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.rimNo".tr(),
      child: CustomTextField(
        key: const ValueKey("LinkCustomerRim"),
        semanticLabel: "project.linkContract.rimNo".tr(),
        readOnly: true,
        filled: true,
        fillColor: AppColors.tableActivatedColor,
        controller: viewModel.customerRimController,
        initialValue: viewModel.contract.customerRimNo?.toString() ?? "",
        onChanged: (v) => viewModel.contract.customerRimNo = int.tryParse(v),
        onSaved: (v) {
          viewModel.contract.customerRimNo = int.tryParse(v.toString());
        },
      ),
    );
  }
}
