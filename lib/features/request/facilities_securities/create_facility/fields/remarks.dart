import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';

import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class FacilityRemarks extends StatelessWidget {
  const FacilityRemarks({super.key, required this.viewModel});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool hasRemarksData = viewModel.facility.remarks?.isNotEmpty ?? false;
    return LabelWidget(
      label: 'facilities.createFacility.remarks'.tr(),
      child: CustomTextArea(
        hintText: 'facilities.createFacility.typeHere'.tr(),
        maxLines: 15,
        // validator: hasRemarksData ? null : CustomValidator.requiredField,
        initialValue: viewModel.facility.remarks,
        onSaved: (String? value) {
          viewModel.facility.remarks = value;
        },
      ),
    );
  }
}
