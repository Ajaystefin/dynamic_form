import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityEmirates extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityEmirates({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.emirates'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.isEmiratesEnabled,
        // validationMessage: "validation.emptyField".tr(),
        semanticLabel: 'facilities.createFacility.emirates'.tr(),
        items: viewModel.emirates,
        selectedItems: !viewModel.showCreateFacilityForm &&
                viewModel.facility.emirates != null
            ? [viewModel.facility.emirates!]
            : null,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facility.emirates = selectedValue.first;
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
