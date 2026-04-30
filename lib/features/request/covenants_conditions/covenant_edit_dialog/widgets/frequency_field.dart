import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class FrequencyField extends StatelessWidget {
  const FrequencyField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
    this.row,
  });

  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;
  final Covenant? row;

  @override
  Widget build(BuildContext context) {
    final List<Reference> filteredItems = viewModel.filteredFrequencies;

    // final bool hasValidSelected = (viewModel.selectedFrequency?.id != null)
    // &&
    //     filteredItems.any((e) => e.id == viewModel.selectedFrequency!.id);

    final int? selectedId =
        (row != null) ? row!.frequency : viewModel.covenant?.frequency;
    final bool hasValidSelected =
        (selectedId != null) && filteredItems.any((e) => e.id == selectedId);

    final Reference? rowSelected = (row?.frequency != null)
        ? filteredItems.firstWhere(
            (r) => r.id == row!.frequency,
            orElse: Reference.new,
          )
        : null;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.frequency".tr(),
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel: "covenantsConditions.covenantEditDialog.frequency".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: filteredItems,
        onSelected: (selectedValue) {
          // viewModel.onFrequencySelected(selectedValue);

          if (row == null) {
            viewModel.onFrequencySelected(selectedValue);
          } else {
            viewModel.onRowFrequencySelected(row!, selectedValue);
          }
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        selectedItems: row == null
            ? (hasValidSelected && viewModel.selectedFrequency != null
                ? [viewModel.selectedFrequency]
                : const [])
            : (rowSelected?.id != null ? [rowSelected] : const []),

        // selectedItems: hasValidSelected ? [viewModel.selectedFrequency!] :
        // [],
      ),
    );
  }
}
