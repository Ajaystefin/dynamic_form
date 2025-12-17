import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ApplicationTypeDropdown extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const ApplicationTypeDropdown({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    final items = viewModel.applicationTypeItems();
    final selectedItem = viewModel.selectedApplicationType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.applicationType'.tr(),
          isRequired: false,
          showLabel: true,
          child: CustomDropdown<Reference>(
            key: const ValueKey( 
                'requestInformation.requestInformation.applicationType'),
            //Globals.request?.isCreateRequest ??
            isEnabled: false,
            validationMessage: "validation.emptyField".tr(),
            semanticLabel:
                'requestInformation.requestInformation.applicationType'.tr(),
            items: items,
            selectedItems: selectedItem == null ? null : [selectedItem],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onApplicationTypeSelected(selectedValue.first);
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
