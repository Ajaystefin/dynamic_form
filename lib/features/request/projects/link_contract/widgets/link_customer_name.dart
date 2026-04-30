import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

class LinkCustomerName extends StatelessWidget {
  const LinkCustomerName({required this.viewModel, super.key});
  final LinkContractViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.customerName".tr(),
      child: CustomTextField(
        key: const ValueKey("LinkCustomerName"),
        semanticLabel: "project.linkContract.customerName".tr(),
        readOnly: true,
        filled: true,
        fillColor: AppColors.tableActivatedColor,
        controller: viewModel.customerNameController,
        initialValue: viewModel.contract.customerName ?? "",
        onChanged: (v) => viewModel.contract.customerName = v,
        onSaved: (v) {
          viewModel.contract.customerRimNo = int.tryParse(v.toString());
        },
      ),
    );
  }
}
