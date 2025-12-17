import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityAccountType extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityAccountType({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.accountType'.tr(),
      isRequired: (!viewModel.showFacilityFi),
      child: CustomDropdown<Reference>(
        semanticLabel: 'facilities.createFacility.accountType'.tr(),
        validationMessage:
            (!viewModel.showFacilityFi) ? "common.validation.emptyField".tr() : null,
        items: viewModel.accountTypes,
        // selectedItems: [viewModel.facility.accountTypeValue],
         selectedItems: !viewModel.showCreateFacilityForm &&
                viewModel.facility.accountTypeValue != null
            ? [viewModel.facility.accountTypeValue!]
            : null,

        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facility.accountTypeValue = selectedValue.first;
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
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
