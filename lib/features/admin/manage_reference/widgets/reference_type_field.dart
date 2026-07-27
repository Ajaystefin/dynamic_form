import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/admin/manage_reference/model.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

/// Displays the reference type dropdown field.
class ReferenceTypeField extends StatelessWidget {
  /// Creates a [ReferenceTypeField].
  const ReferenceTypeField({
    required this.viewModel,
    super.key,
    this.width,
  });

  /// View model containing reference type data.
  final ManageReferenceViewModel viewModel;

  /// Optional width for the field.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "admin.referenceDataManagement.referenceDataType".tr(),
      child: CustomDropdown<ReferenceType>(
        items: viewModel.allReferences,
        semanticLabel: "admin.referenceDataManagement.referenceDataType".tr(),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        isSearchable: true,
        filterFn: (ReferenceType item, String filter) {
          return (item.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        onSelected: (selectedValue) {
          viewModel.onReferenceDataSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        selectedItems: viewModel.selectedReferenceType != null
            ? [viewModel.selectedReferenceType]
            : [
                ReferenceType(
                  name: "admin.roleRightMapping.selectValue".tr(),
                ),
              ],
      ),
    );
  }
}
