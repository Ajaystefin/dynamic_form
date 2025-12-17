import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class CommitmentAccountNumber extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const CommitmentAccountNumber({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.commitmentAccountNumber'.tr(),
      isRequired: !viewModel.showFacilityFi,
      child: CustomDropdown<String>(
        validationMessage:
            !viewModel.showFacilityFi ? "common.validation.emptyField".tr() : null,
        semanticLabel: 'facilities.createFacility.commitmentAccountNumber'.tr(),
        items: viewModel.commitmentAccountNumberItems,
         selectedItems: viewModel.commitmentAccSelectedForUi,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            final accNo = selectedValue.first.trim();
            viewModel.facility.commitmentAccountNumber = Reference(name: accNo);
            viewModel.setControllingLimitByAccount(accNo);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item,
            isSelected: isSelected,
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
