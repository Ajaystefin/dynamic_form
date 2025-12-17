import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class LimitsDropDownField extends StatelessWidget {
  final FacilitiesSummaryFiViewModel viewModel;

  const LimitsDropDownField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.facilitySummary.limit".tr(),
      child: CustomDropdown<Reference>(
        items: viewModel.limitTypes,
        // selectedItems: [viewModel.customerFacilities?.first.subLimitType],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            // viewModel.customerFacilities?.first.subLimitType =
            //     selectedValue.first;
          }
        },
        validationMessage: "validation.emptyField".tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.reference4 ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
