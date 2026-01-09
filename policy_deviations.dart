import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PolicyDeviations extends StatelessWidget {
  const PolicyDeviations({super.key, required this.viewModel});
  final CreateFacilityViewModel viewModel;
  final double amount = 1000000; // Example amount
  final double percentage = 0.25; // Example percentage (25%)

  @override
  Widget build(BuildContext context) {
    double largeExposureLimit = amount * percentage;
    return LabelWidget(
      label: 'customerInformation.customerInformation.policyDeviations'.tr(),
      child: CustomMultiSelectDropdown<Reference>(
          isSearchable: true,
          isEnabled: viewModel.canEdit,
          items: viewModel.policyDeviations,
          dropdownBuilder: (context, data) {
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(data!.length, (index) {
                return (data[index].id == ServerConstants.largeExposureBreachId)
                    ? CustomTooltip(
                        message:
                            '${'customerInformation.customerInformation.largeExposureLimit'.tr()} \$${largeExposureLimit.toStringAsFixed(2)}',
                        child: Chip(
                          label: Row(
                            spacing: 5,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(data[index].name.toString()),
                              const Icon(
                                color: AppColors.primary,
                                Icons.info_rounded,
                                size: 18,
                              )
                            ],
                          ),
                        ))
                    : Chip(
                        label: Text(data[index].name.toString()),
                      );
              }),
            );
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownMultiItemBuildWidget(
              item.name,
              isSelected: isSelected,
            );
          },
          onSelected: (selectedValue) {
            viewModel.onPolicyDeviationSelected(selectedValue);
          },
          selectedItems: viewModel.facility.policyDeviation ?? []),
    );
  }
}
