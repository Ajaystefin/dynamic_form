import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// General or specific field for the covenant edit dialog.
class GeneralField extends StatelessWidget {
  /// Creates a general field.
  const GeneralField({
    required this.viewModel,
    super.key,
    this.row,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant row data.
  final Covenant? row;

  @override
  Widget build(BuildContext context) {
    final List<Reference> items =
        viewModel.referenceData[ReferenceDataKeys.covenantGeneralSpecific] ??
            [];

    final List<Reference> selectedItems = row == null
        ? (viewModel.generalField?.id != null ? [viewModel.generalField!] : [])
        : viewModel.getSelectedGeneralForRow(row!);

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.generalSpecific".tr(),
      child: CustomDropdown<Reference>(
        isEnabled: !viewModel.isReadOnly,
        hintText: "common.selectValue".tr(),
        semanticLabel:
            "covenantsConditions.covenantEditDialog.generalSpecific".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: items,
        onSelected: (values) {
          final Reference selected = values.first;
          if (row == null) {
            // desktop path (current behavior)
            viewModel.onGeneralFieldChanged(selected, context);
          } else {
            // row path (new)
            viewModel.onLinkedGeneralFieldChanged(row!, selected, context);
          }
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) =>
            dropdownItemBuildWidget(
          item.name,
          isSelected: isSelected ?? false,
        ),
        selectedItems: selectedItems,
      ),
    );
  }
}
