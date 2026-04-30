import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class TresholdTypeField extends StatelessWidget {
  const TresholdTypeField({
    required this.viewModel,
    super.key,
    this.isEnabled = false,
    this.selectedItem,
    this.forceEmptySelection = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;
  final Reference? selectedItem;
  final bool forceEmptySelection;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.thresholdType".tr(),
      isRequired: viewModel.isThresholdTypeTextFieldRequired ? true : false,
      child: viewModel.isThresholdTypeTextFieldRequired
          ? CustomDropdown<Reference>(
              hintText: "common.selectValue".tr(),
              isEnabled: isEnabled,
              semanticLabel:
                  "covenantsConditions.covenantEditDialog.thresholdType".tr(),
              validationMessage: "common.validation.emptyField".tr(),
              items: viewModel.referenceData[ReferenceDataKeys.thresholdType] ??
                  [],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel.selectedThreshold = selectedValue.first;
                  viewModel.covenant?.thresholdType =
                      viewModel.selectedThreshold?.id;
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
              selectedItems: viewModel.getSelectedThreshold(
                selectedItem,
                forceEmptySelection,
              ),
            )
          : CustomDropdown<Reference>(
              hintText: "common.selectValue".tr(),
              isEnabled: isEnabled && !viewModel.isReadOnly,
              semanticLabel:
                  "covenantsConditions.covenantEditDialog.thresholdType".tr(),
              validationMessage: "common.validation.emptyField".tr(),
              items: viewModel.referenceData[ReferenceDataKeys.thresholdType] ??
                  [],
              onSelected: (selectedValue) {
                viewModel.selectedThreshold = selectedValue.first;
                viewModel.covenant?.thresholdType =
                    viewModel.selectedThreshold?.id;
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
              selectedItems: viewModel.getSelectedThreshold(
                selectedItem,
                forceEmptySelection,
              ),
            ),
    );
  }
}
