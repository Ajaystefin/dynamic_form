import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class FiTenor extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FiTenor({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: 'facilities.createFacility.tenor'.tr(),
      child: CustomTextField(
        initialValue: viewModel.facility.presentLimitValue?.description,
        onSaved: (String? value) {
          viewModel.facility.presentLimitValue?.description = value;
        },
      ),
    );
  }
}
