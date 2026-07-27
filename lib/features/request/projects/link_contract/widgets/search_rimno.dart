import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Search RIM number field for the link contract screen.
class SearchRimno extends StatelessWidget {
  /// Creates a search RIM number field.
  const SearchRimno({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.rimNo".tr(),
      isRequired: true,
      child: CustomTextField(
        key: const ValueKey("SearchRimno"),
        semanticLabel: "project.linkContract.rimNo".tr(),
        keyboardType: TextInputType.number,
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        controller: viewModel.searchRimController,
        onSaved: (value) {
          viewModel.searchRimController.text = value.toString();
        },
      ),
    );
  }
}
