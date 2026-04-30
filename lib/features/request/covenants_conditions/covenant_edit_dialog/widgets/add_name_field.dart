import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class AddCustomerNameField extends StatelessWidget {
  const AddCustomerNameField({required this.viewModel, super.key});
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.customerName".tr(),
      child: CustomTextField(
        semanticLabel:
            "covenantsConditions.covenantEditDialog.customerName".tr(),
        key: UniqueKey(),
        controller: viewModel.customerNameController,
        filled: true,
        readOnly: viewModel.isReadOnly,
      ),
    );
  }
}
