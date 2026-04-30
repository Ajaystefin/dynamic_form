import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class ProjectFinanceRelatedActivity extends StatelessWidget {
  const ProjectFinanceRelatedActivity({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.projectFinanceRelatedActivity".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomRadioButton(
        isEnabled:
            !viewModel.isFIFlow && viewModel.isProjectFinanceActivityEnabled,
        options: viewModel.projectFinanceRelatedActivityOptions,
        selectedValue: viewModel.projectFinanceSelectedOrDefault,
        onChanged: viewModel.onProjectFinanceChanged,
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ""),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
