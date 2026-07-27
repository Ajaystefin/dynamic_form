import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the facility purpose.
class FacilityPurpose extends StatelessWidget {
  /// Creates a facility purpose widget.
  const FacilityPurpose({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility purpose data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.purpose".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.isPurposeEnabled,
        validationMessage:
            viewModel.isFIFlow ? null : "common.validation.emptyField".tr(),
        items: viewModel.purposes,
        selectedItems: viewModel.getFacility.purpose == null
            ? null
            : [
                viewModel.purposes.firstWhere(
                  (s) => s.id == viewModel.getFacility.purpose?.id,
                  orElse: () => viewModel.purposes.first,
                ),
              ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.selectPurpose(selectedValue.first);
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
