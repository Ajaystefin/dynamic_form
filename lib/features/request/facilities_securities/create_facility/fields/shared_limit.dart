import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SharedLimit extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const SharedLimit({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    
    return LabelWidget(
      label: 'facilities.createFacility.sharedLimit'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isEnabled: Utils.isGroupApplication() && viewModel.isAnnualReview ? true : false,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.sharedLimits,
        selectedItems: !viewModel.showCreateFacilityForm
            ? (viewModel.facility.sharedLimit != null
                ? [viewModel.facility.sharedLimit!]
                : null)
            : [viewModel.facility.sharedLimit ?? viewModel.sharedLimits.first],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.selectSharedLimit(selectedValue.first);
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
