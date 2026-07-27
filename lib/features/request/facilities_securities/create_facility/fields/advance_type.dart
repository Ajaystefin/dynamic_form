import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting the advance type.
class AdvanceType extends StatelessWidget {
  /// Creates an advance type selector.
  const AdvanceType({required this.viewModel, super.key});

  /// View model used to manage advance type data and state.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.advanceType".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<Reference>(
        semanticLabel: "facilities.createFacility.advanceType".tr(),
        validationMessage:
            viewModel.isFIFlow ? null : "common.validation.emptyField".tr(),
        items: viewModel.advanceTypes,
        selectedItems: viewModel.getFacility.advanceTypeValue != null
            ? [viewModel.getFacility.advanceTypeValue]
            : null,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.getFacility.advanceTypeValue = selectedValue.first;
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
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
