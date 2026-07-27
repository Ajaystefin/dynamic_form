import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and editing the facility title.
class FacilityTitle extends StatelessWidget {
  /// Creates a facility title widget.
  const FacilityTitle({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility title data and actions.
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
