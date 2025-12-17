import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class CancellationReason extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const CancellationReason({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final items = viewModel.cancellationReason;
    final selectedItem = viewModel.selectedCancellationReason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label:
              'requestInformation.requestInformation.cancellationReason'.tr(),
          isRequired: true,
          showLabel: true,
          child: CustomDropdown<Reference>(
            isEnabled: viewModel.canEdit
                ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false
                : false,
            validationMessage: "validation.emptyField".tr(),
            semanticLabel:
                'requestInformation.requestInformation.cancellationReason'.tr(),
            items: items,
            selectedItems: selectedItem == null ? null : [selectedItem],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onCancellationSelected(selectedValue.first);
              }
            },
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownItemBuildWidget(item.name,
                  isListTile: true, isSelected: isSelected);
            },
            dropdownBuilder: (context, data) {
              return Text(
                data?.name ?? "",
                style: const TextStyle(fontSize: 14),
              );
            },
          ),
        )
      ],
    );
  }
}
