import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class LimitAvailabilityDate extends StatelessWidget {
  const LimitAvailabilityDate({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isCreate = viewModel.showCreateFacilityForm;

    final bool showTextField = [
      ServerConstants.facilityTypeId[FacilityType.termLoanCommercial],
      ServerConstants.facilityTypeId[FacilityType.shortTermLoan],
      ServerConstants.facilityTypeId[FacilityType.moveableAssets],
      ServerConstants.facilityTypeId[FacilityType.immoveableAssets],
    ].contains(viewModel.getFacility.facilityDescription?.id);

    final String apiLimitPeriod = viewModel.facilityDetail.isNotEmpty
        ? (viewModel.facilityDetail.first.limitAvailabilityPeriod)
        : (viewModel.getFacility.limitAvailabilityPeriod ?? "").toString();

    final String apiLimitDateIso = viewModel.facilityDetail.isNotEmpty
        ? viewModel.facilityDetail.first.limitAvailabilityDate.toString()
        : (viewModel.getFacility.limitAvailabilityDate ?? "").toString();

    final DateTime? dt = DateTime.tryParse(apiLimitDateIso);
    final String dateOnlyApiLimitDateIso = dt != null
        ? DateFormat("yyyy-MM-dd").format(dt)
        : apiLimitDateIso; // fallback

    final DateTime? parsed = apiLimitDateIso.trim().isNotEmpty
        ? DateTime.tryParse(apiLimitDateIso.trim())
        : null;

    return LabelWidget(
      isEnabled: !viewModel.isFIFlow,
      label: showTextField
          ? "facilities.createFacility.limitAvailabilityPeriod".tr()
          : "facilities.createFacility.limitAvailabilityDate".tr(),
      isRequired: !viewModel.isFIFlow,
      child: showTextField
          ? CustomTextField(
              readOnly: dateOnlyApiLimitDateIso.isNotEmpty && isCreate,
              maxLength: 20,
              semanticLabel:
                  "facilities.createFacility.limitAvailabilityPeriod".tr(),
              initialValue:
                  isCreate ? dateOnlyApiLimitDateIso : (apiLimitPeriod),
              onChanged: (value) {
                viewModel.getFacility.limitAvailabilityPeriod = value;
              },
            )
          : CustomDatePicker(
              isEnabled: !viewModel.isFIFlow,
              initialDateTime: //isCreate ? '' :
                  parsed,
              semanticLabel:
                  "facilities.createFacility.limitAvailabilityDate".tr(),
              blockedDates: const [],
              onSubmit2: (date) {
                debugPrint(date.toString());
                viewModel.getFacility.limitAvailabilityDate = date;
              },
              validator: viewModel.isFIFlow ? null : CustomValidator.date,
            ),
    );
  }
}
