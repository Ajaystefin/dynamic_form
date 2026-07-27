import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting the facility committed status.
class FacilityCommitted extends StatelessWidget {
  /// Creates a facility committed status selector.
  const FacilityCommitted({required this.viewModel, super.key});

  /// View model containing committed status data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.committed".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<Reference>(
        validationMessage:
            viewModel.isFIFlow ? null : "common.validation.emptyField".tr(),
        semanticLabel: "facilities.createFacility.committed".tr(),
        items: viewModel.committedValues,
        compareFn: (item1, item2) => item1.id == item2.id,
        selectedItems: viewModel.getFacility.committedValues != null
            ? [viewModel.getFacility.committedValues]
            : (viewModel.committedValues.isNotEmpty
                ? [
                    viewModel.committedValues.firstWhere(
                      (e) => e.id == ServerConstants.optionNOid,
                      orElse: () => viewModel.committedValues.first,
                    ),
                  ]
                : []),
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.changeCommitted(selectedValue.first);
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
