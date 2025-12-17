import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FrequencyField extends StatelessWidget {
  const FrequencyField({
    super.key,
    required this.viewModel,
    this.isEnabled = true,
  });

  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final filteredItems = viewModel.filteredFrequencies;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.frequency".tr(),
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled &&  !viewModel.isReadOnly,
        semanticLabel: "covenantsConditions.covenantEditDialog.frequency".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: filteredItems,
        onSelected: (selectedValue) {
          viewModel.selectedFrequency = selectedValue.first;
          viewModel.covenant?.frequency = viewModel.selectedFrequency?.id;
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        selectedItems: viewModel.selectedFrequency?.id != null
            ? [viewModel.selectedFrequency!]
            : [],
      ),
    );
  }
}
