import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class LimitDescription extends StatelessWidget {
  final FacilitiesSummaryFiViewModel viewModel;

  const LimitDescription({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.facilitySummary.limitDescription".tr(),
      child: CustomDropdown<Reference>(
        items: viewModel.subLimitTypes,
        selectedItems: const [
          // viewModel.customerFacilities?.first.subLimitType,
        ],
        validationMessage: "validation.emptyField".tr(),
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            // viewModel.customerFacilities?.first.subLimitType =
            //     selectedValue.first;
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
    );
  }
}
