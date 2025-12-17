import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class LimitType extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const LimitType({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    final bool isMain = viewModel.subLimit ?? false;

    return LabelWidget(
      label: 'facilities.createFacility.limitType'.tr(),
      isRequired: true,
      showLabel: true,
      child: CustomDropdown<String>(
        isEnabled: false,
        semanticLabel: 'facilities.createFacility.limitType'.tr(),
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.limitTypeFacility, // ["Main Limit", "Sub Limit"]
        selectedItems: [
          isMain ? "Main Limit" : "Sub Limit",
        ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.setLimitTypeByLabel(selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item,
            isSelected: isSelected,
            isListTile: true,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
