import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class ProjectFinanceRelatedActivity extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const ProjectFinanceRelatedActivity({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.projectFinanceRelatedActivity'.tr(),
      isRequired: true,
      child: CustomRadioButton(
        isEnabled: viewModel.isProjectFinanceActivityEnabled,
        options: viewModel.projectFinanceRelatedActivityOptions,
        selectedValue: viewModel.projectFinanceSelectedOrDefault,
        onChanged: (value) => viewModel.onProjectFinanceChanged(value),
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ''),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
