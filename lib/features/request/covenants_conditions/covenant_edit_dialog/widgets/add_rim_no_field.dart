import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Customer RIM field for the covenant edit dialog.
class AddCustomerRimField extends StatelessWidget {
  /// Creates an add customer RIM field.
  const AddCustomerRimField({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.customerRIM".tr(),
      child: CustomTextField(
        readOnly: viewModel.isReadOnly,
        filled: viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.customerRIM".tr(),
        key: UniqueKey(),
        initialValue: viewModel.rimNoSearch,
        suffixIcon: IconButton(
          onPressed: () async {
            await viewModel.searchByRim(viewModel.rimNoSearch.trim());
          },
          icon: const Icon(Icons.search),
        ),
        onSubmitted: (data) async {
          await viewModel.searchByRim(data.trim());
        },
        onChanged: (value) {
          viewModel.rimNoSearch = value;
        },
      ),
    );
  }
}
