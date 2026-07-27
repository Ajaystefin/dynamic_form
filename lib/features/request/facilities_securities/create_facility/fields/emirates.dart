import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting the facility emirate.
class FacilityEmirates extends StatelessWidget {
  /// Creates a facility emirates selector.
  const FacilityEmirates({required this.viewModel, super.key});

  /// View model containing emirate data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.emirates".tr(),
      child: CustomDropdown<Reference>(
        isEnabled:
            viewModel.getFacility.propertyType?.name?.isNotEmpty ?? false,
        semanticLabel: "facilities.createFacility.emirates".tr(),
        items: viewModel.emirates,
        key: ValueKey(
          "${viewModel.getFacility.emirates}-"
          "${viewModel.getFacility.propertyType?.name}",
        ),
        selectedItems: viewModel.getFacility.emirates != null
            ? [viewModel.getFacility.emirates]
            : [],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.getFacility.emirates = selectedValue.first;
          }
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
