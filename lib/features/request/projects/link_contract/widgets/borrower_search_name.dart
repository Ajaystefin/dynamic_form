import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Borrower search name field.
class BorrowerSearchName extends StatelessWidget {
  /// Creates a borrower search name field.
  const BorrowerSearchName({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.name".tr(),
      isRequired: true,
      child: CustomTextField(
        key: const ValueKey("BorrowerSearchName"),
        semanticLabel: "project.linkContract.name".tr(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9 ]")),
          LengthLimitingTextInputFormatter(50),
        ],
        maxLength: 50,
        controller: viewModel.searchNameController,
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        onSaved: (value) {
          viewModel.searchNameController.text = value.toString();
        },
      ),
    );
  }
}
