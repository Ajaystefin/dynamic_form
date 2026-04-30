import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FacilityPropertyType extends StatelessWidget {
  const FacilityPropertyType({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.propertyType".tr(),
      isRequired: false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isEnabled: (viewModel.getFacility.purpose?.reference1 ?? "")
                    .trim()
                    .toUpperCase() ==
                "Y" ||
            (viewModel.getFacility.propertyType?.name?.isNotEmpty ?? false),
        items: viewModel.propertyTypes,
        selectedItems: viewModel.getFacility.propertyType != null
            ? [viewModel.getFacility.propertyType]
            : null,
        onSelected: viewModel.onPropertyTypeSelected,
        onClear: viewModel.onPropertyTypeSelected,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected,
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
