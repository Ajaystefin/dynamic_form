import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Exposure Strategy field on the Request Information screen.
///
/// Allows users to view or select the exposure strategy
/// associated with the current request.
class ExposureStrategy extends StatelessWidget {
  /// Creates an [ExposureStrategy].
  const ExposureStrategy({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages exposure strategy-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.exposureStrategyItems;
    final selectedItem = viewModel.selectedExposureStrategy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.exposureStrategy".tr(),
          isRequired: !viewModel.isFI,
          child: CustomDropdown<Reference>(
            key: const ValueKey(
              "requestInformation.requestInformation.exposureStrategy",
            ),
            isEnabled: viewModel.canEdit,
            // isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            semanticLabel:
                "requestInformation.requestInformation.exposureStrategy".tr(),
            validationMessage:
                (viewModel.isFI) ? null : "common.validation.emptyField".tr(),
            items: items,
            selectedItems: selectedItem == null ? null : [selectedItem],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onExposureStrategySelected(selectedValue.first);
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
        ),
      ],
    );
  }
}
