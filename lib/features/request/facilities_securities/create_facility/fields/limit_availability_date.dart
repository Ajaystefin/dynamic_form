import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class LimitAvailabilityDate extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const LimitAvailabilityDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bool isCreate = viewModel.showCreateFacilityForm;

    final bool hasDetails = viewModel.facilityDetail.isNotEmpty;

    final String apiLimitDateIso = hasDetails
        ? (viewModel.facilityDetail.first.limitAvailabilityDate ?? '')
            .toString()
        : '';

    final bool showTextField = viewModel.selectedDescriptionId == 11576 ||
        viewModel.selectedDescriptionId == 36;

    final DateTime? parsed = apiLimitDateIso.trim().isNotEmpty
        ? DateTime.tryParse(apiLimitDateIso.trim())
        : null;

    final String? apiLimitPeriod = hasDetails
        ? viewModel
            .facilityDetail.first.limitAvailabilityPeriod // if your DTO has it
        : null;

    return LabelWidget(
      label: showTextField
          ? 'facilities.createFacility.limitAvailabilityPeriod'.tr()
          : 'facilities.createFacility.limitAvailabilityDate'.tr(),
      isRequired: false,
      child: showTextField
          ? CustomTextField(
              maxLength: 20,
              semanticLabel:
                  'facilities.createFacility.limitAvailabilityDate'.tr(),
              initialValue: isCreate ? '' : (apiLimitPeriod ?? ''),
              onChanged: (value) {
                viewModel.facility.limitAvailabilityPeriod = value;
              },
            )
          : CustomDatePicker(
              isEnabled: viewModel.showCreateFacilityForm ? true : false,
              initialDateTime: isCreate ? null : parsed,
              semanticLabel:
                  'facilities.createFacility.limitAvailabilityDate'.tr(),
              blockedDates: const [],
              onSubmit2: (date) {
                viewModel.facility.limitAvailabilityDate = date;
              },
              validator: CustomValidator.date,
            ),
    );
  }
}