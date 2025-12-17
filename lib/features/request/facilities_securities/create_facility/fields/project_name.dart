import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityProjectName extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityProjectName({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final List<Reference> items = viewModel.projectNames;

    return LabelWidget(
      label: 'facilities.createFacility.projectName'.tr(),
      isRequired:
          (viewModel.limitGroup == 11317 && viewModel.subLimit!) ? true : false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        validationMessage:
            (viewModel.limitGroup == 11317 && viewModel.subLimit!)
                ? "common.validation.emptyField".tr()
                : null,
        showClearIcon: false,
        isEnabled: true,
        items: items,
        selectedItems: viewModel.projectNameSelectedForUi,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.onProjectNameSelected(selectedValue);
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
