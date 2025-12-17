import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityPropertySubType extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityPropertySubType({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.propertySubType'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.facility.propertyType != null,
        // validationMessage: "validation.emptyField".tr(),
        items: viewModel.propertySubTypesForSelectedType,
        selectedItems: viewModel.facility.propertySubType != null
            ? [viewModel.facility.propertySubType!]
            : null,
        onSelected: viewModel.onPropertySubTypeSelected,

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
