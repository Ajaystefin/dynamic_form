import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityPropertyType extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityPropertyType({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.propertyType'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.isPropertyTypeEnabled,
        items: viewModel.propertyTypes,
        selectedItems: viewModel.facility.propertyType != null
            ? [viewModel.facility.propertyType!]
            : null,
        onSelected: viewModel.onPropertyTypeSelected,
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
