import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FacilitySeniority extends StatelessWidget {
  const FacilitySeniority({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.seniority".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<Reference>(
        validationMessage:
            viewModel.isFIFlow ? null : "validation.emptyField".tr(),
        items: viewModel.seniorities,
        selectedItems: viewModel.getFacility.seniorityValue != null
            ? [viewModel.getFacility.seniorityValue]
            : [viewModel.seniorities.first],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.getFacility.seniorityValue = selectedValue.first;
          }
        },
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
