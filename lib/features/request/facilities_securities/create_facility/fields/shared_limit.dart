import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing shared limit information.
class SharedLimit extends StatelessWidget {
  /// Creates a shared limit widget.
  const SharedLimit({
    required this.viewModel,
    super.key,
  });

  /// View model containing shared limit data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.sharedLimit".tr(),
      child: CustomDropdown<Reference>(
        isEnabled: Utils.isGroupApplication() && viewModel.isAnnualReview,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.sharedLimits,
        selectedItems: !viewModel.showCreateFacilityForm
            ? (viewModel.getFacility.sharedLimit != null
                ? [viewModel.getFacility.sharedLimit]
                : null)
            : [
                viewModel.getFacility.sharedLimit ??
                    viewModel.sharedLimits.first,
              ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.selectSharedLimit(selectedValue.first);
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
