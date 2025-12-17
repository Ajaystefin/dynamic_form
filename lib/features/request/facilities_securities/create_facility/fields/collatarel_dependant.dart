import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class CollateralDepandant extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const CollateralDepandant({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.collateralDependant'.tr(),
      isRequired: (!viewModel.showFacilityFi),
      child: CustomRadioButton(
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ''),
        options: viewModel.collateralDepantantoptions,
        selectedValue: viewModel.facility.selectedCollateralDepantantValue ??
            viewModel.collateralDepantantoptions[1],
        onChanged: (value) {
          viewModel.changeCollateralDependant(value);
        },
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
