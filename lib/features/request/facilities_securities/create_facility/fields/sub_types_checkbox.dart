// ignore: file_names
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class SubtypesCheckbox extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  final FacilitySubTypes facilitySubType;
  const SubtypesCheckbox({
    super.key,
    required this.viewModel,
    required this.facilitySubType,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCheckbox(
      semanticsLabel: "facilities.createFacility.subtypes".tr(),
      value: facilitySubType.subTypeSelected,
      onChange: (value) {
        viewModel.changeSubtypes(value ?? false, facilitySubType);
      },
      child: Text(facilitySubType.subType ?? "",
          style: const TextStyle(fontSize: AppStyle.fontSizeSmall)),
    );
  }
}
