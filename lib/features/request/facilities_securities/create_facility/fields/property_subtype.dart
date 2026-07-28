import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting and managing the facility property subtype.
class FacilityPropertySubType extends StatelessWidget {
  /// Creates a facility property subtype widget.
  const FacilityPropertySubType({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility property subtype data and actions.
  final CreateFacilityViewModel viewModel;
  
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.propertySubType".tr(),
      child: CustomDropdown<Reference>(
        isEnabled:
            viewModel.getFacility.propertyType?.name?.isNotEmpty ?? false,
        items: viewModel.propertySubTypesForSelectedType,
        selectedItems: viewModel.getFacility.propertySubType != null
            ? [viewModel.getFacility.propertySubType]
            : null,
        onSelected: viewModel.onPropertySubTypeSelected,
        onClear: viewModel.onPropertySubTypeSelected,
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
