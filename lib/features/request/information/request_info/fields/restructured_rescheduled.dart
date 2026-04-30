import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class RestructuredRescheduled extends StatelessWidget {
  const RestructuredRescheduled({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final items = viewModel.restructuredRescheduledItems;
    final selectedItem = viewModel.selectedRestructuredRescheduled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.restructuredRescheduled"
              .tr(),
          isRequired: !viewModel.isFI,
          showLabel: true,
          child: CustomDropdown<Reference>(
            key: const ValueKey(
              "requestInformation.requestInformation.restructuredRescheduled",
            ),
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            semanticLabel:
                "requestInformation.requestInformation.restructuredRescheduled"
                    .tr(),
            validationMessage:
                (viewModel.isFI) ? null : "common.validation.emptyField".tr(),
            items: items,
            selectedItems: selectedItem == null ? null : [selectedItem],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel
                    .onRestructuredRescheduledSelected(selectedValue.first);
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
