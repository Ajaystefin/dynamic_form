import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class FacilityTitle extends StatelessWidget {
  const FacilityTitle({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final fallbackTitle = viewModel.getFacility.facilityTitle ?? "";

    final initialValue = viewModel.getFacility.facilityTitle ??
        ((!viewModel.showCreateFacilityForm &&
                viewModel.facilityDetail.isNotEmpty)
            ? (viewModel.facilityDetail.first.facilityTitle)
            : fallbackTitle);

    return LabelWidget(
      label: "facilities.createFacility.facilityTitle".tr(),
      child: CustomTextArea(
        maxLines: 15,
        maxLength: 500,
        initialValue: initialValue,
        onSaved: (String? value) {
          viewModel.getFacility.facilityTitle = value;
        },
      ),
    );
  }
}
