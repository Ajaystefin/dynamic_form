import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ActionField extends StatelessWidget {
  const ActionField({
    super.key,
    required this.viewModel,
    this.forceEmptySelection = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final bool forceEmptySelection;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.action".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: !viewModel.isNewCovenant && !viewModel.isReadOnly,
        validationMessage: "common.validation.emptyField".tr(),
        semanticLabel: "covenantsConditions.covenantEditDialog.action".tr(),
        items: viewModel
                .referenceData[ReferenceDataKeys.covenantConditionAction] ??
            [],
        onSelected: (selectedValue) =>
            viewModel.setSelectedAction(selectedValue.first),
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        selectedItems: viewModel.getSelectedActionItems(forceEmptySelection),
      ),
    );
  }
}
