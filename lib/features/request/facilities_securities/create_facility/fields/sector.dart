import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilitySector extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilitySector({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.sector'.tr(),
      isRequired: (!viewModel.showFacilityFi),
      child: CustomDropdown<Reference>(
        validationMessage: (!viewModel.showFacilityFi)
            ? "common.validation.emptyField".tr()
            : null,
        items: viewModel.sectors,
        selectedItems: !viewModel.showCreateFacilityForm &&
                viewModel.facility.sector != null
            ? [viewModel.facility.sector!]
            : null,

        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.selectSector(selectedValue.first);
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
