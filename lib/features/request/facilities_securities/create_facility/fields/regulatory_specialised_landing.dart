import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class RegulatorySpecialisedLanding extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const RegulatorySpecialisedLanding({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.regulatorySpecialisedLending'.tr(),
      isRequired: true,
      child: CustomRadioButton<Reference>(
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ''),
        options: viewModel.regulatorySpecialisedLandingOptions,
        selectedValue: viewModel
                .facility.selectedRegulatorySpecialisedLandingValue ??
            viewModel
                .regulatorySpecialisedLandingOptions[1], 
        onChanged: (value) {
          viewModel.changeRegulatorySpecialisedLanding(value);
        },
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
