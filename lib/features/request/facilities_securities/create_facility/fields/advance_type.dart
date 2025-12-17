import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class AdvanceType extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const AdvanceType({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.advanceType'.tr(),
      isRequired: !viewModel.showFacilityFi,
      child: CustomDropdown<Reference>(
        semanticLabel: 'facilities.createFacility.advanceType'.tr(),
        validationMessage: 
        // !viewModel.showFacilityFi
            // ?
             "common.validation.emptyField".tr(),
            // : null,
        items: viewModel.advanceTypes,
        selectedItems: !viewModel.showCreateFacilityForm &&
                viewModel.facility.advanceTypeValue != null
            ? [viewModel.facility.advanceTypeValue!]
            : null,

        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facility.advanceTypeValue = selectedValue.first;
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
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
