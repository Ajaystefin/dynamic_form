import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the facility project name.
class FacilityProjectName extends StatelessWidget {
  /// Creates a facility project name widget.
  const FacilityProjectName({
    required this.viewModel,
    this.isEnabled = true,
    super.key,
  });

  /// View model containing facility project name data and actions.
  final CreateFacilityViewModel viewModel;
  final bool isEnabled;
  @override
  Widget build(BuildContext context) {
    final List<Reference> items = viewModel.projectNames;

    return LabelWidget(
      isEnabled: isEnabled,
      label: "facilities.createFacility.projectName".tr(),
      isRequired: viewModel.limitGroup == 11315,
      child: CustomDropdown<Reference>(
        isSearchable: true,
        validationMessage: (viewModel.limitGroup == 11315)
            ? "common.validation.emptyField".tr()
            : null,
        showClearIcon: false,
        isEnabled: viewModel.isProjectNameEnabled,
        items: items,
        selectedItems: viewModel.projectNameSelectedForUi,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.onProjectNameSelected(selectedValue);
          }
        },
        filterFn: (Reference item, String filter) {
          return (item.name ?? "").toLowerCase().contains(filter.toLowerCase());
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
