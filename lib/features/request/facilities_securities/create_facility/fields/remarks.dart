import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing facility remarks.
class FacilityRemarks extends StatelessWidget {
  /// Creates a facility remarks widget.
  const FacilityRemarks({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility remarks data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool hasRemarksData = viewModel.facility.remarks?.isNotEmpty ??
    // false;
    return LabelWidget(
      label: "facilities.createFacility.remarks".tr(),
      child: CustomTextArea(
        hintText: "facilities.createFacility.typeHere".tr(),
        maxLines: 15,
        maxLength: 1000,
        initialValue: viewModel.getFacility.remarks ??
            (viewModel.facilityDetail.isNotEmpty
                ? viewModel.facilityDetail.first.remarks ?? ""
                : ""),
        onSaved: (String? value) {
          viewModel.getFacility.remarks = value;
        },
      ),
    );
  }
}
