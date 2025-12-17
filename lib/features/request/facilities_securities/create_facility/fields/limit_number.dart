import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class LimitNumber extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const LimitNumber({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: (!viewModel.showCreateFacilityForm) ? true : false,
      label: 'facilities.createFacility.limitNumber'.tr(),
      child: CustomTextField(
        readOnly: true,
        filled: true,
        maxLength: 7,
        semanticLabel: 'facilities.createFacility.limitNumber'.tr(),
        // initialValue: (!viewModel.showCreateFacilityForm)
        //     ? viewModel.facilityDetail.first.limitNo
        //     : "",

        initialValue: (!viewModel.showCreateFacilityForm)
            ? (
                !viewModel.isMainLimit!
                    ? (viewModel.parentControlliingNumber ?? "")
                    : (viewModel.facilityDetail.isNotEmpty
                        ? viewModel.facilityDetail.first.limitNo.toString()
                        : ""))
            : "",

        validator:
            !viewModel.showFacilityFi ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          viewModel.facility.limitNumber = value;
        },
      ),
    );
  }
}
