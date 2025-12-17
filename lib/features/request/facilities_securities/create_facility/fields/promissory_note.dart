import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PromissoryNote extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const PromissoryNote({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.promissoryNote'.tr(),
      isRequired: (!viewModel.showFacilityFi),
      child: CustomRadioButton<Reference>(
        options: viewModel.promissoryNoteOptions,
        selectedValue: viewModel.facility.selectedpromissoryNoteValue ??
            viewModel.promissoryNoteOptions[1],
        onChanged: (value) {
          viewModel.changePromissoryNote(value);
        },
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ''),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
