import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ExposureStrategy extends StatelessWidget {
  const ExposureStrategy({required this.viewModel, super.key});
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
          showLabel: true,
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
                (viewModel.isFI) ? null : "validation.emptyField".tr(),
            items: items,
            selectedItems: selectedItem == null ? null : [selectedItem],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onExposureStrategySelected(selectedValue.first);
              }
            },
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(
                item.name,
                isListTile: true,
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
        ),
      ],
    );
  }
}
