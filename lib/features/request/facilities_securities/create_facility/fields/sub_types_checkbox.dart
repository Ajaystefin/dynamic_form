import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// Widget for displaying and managing facility subtype selection.
class SubtypesCheckbox extends StatelessWidget {
  /// Creates a facility subtype checkbox widget.
  const SubtypesCheckbox({
    required this.viewModel,
    required this.facilitySubType,
    super.key,
  });

  /// View model containing facility subtype data and actions.
  final CreateFacilityViewModel viewModel;

  /// Facility subtype represented by this checkbox.
  final FacilitySubTypes facilitySubType;

  @override
  Widget build(BuildContext context) {
    return CustomCheckbox(
      semanticsLabel: "facilities.createFacility.subtypes".tr(),
      value: (facilitySubType.subTypeSelected ?? false) ||
          (facilitySubType.alreadyExistingSubType ?? false),
      onChange: ({value}) {
        viewModel.changeSubtypes(
          subTypeSelected: value ?? false,
          facilitySubType,
          alreadyExistingSubType: value ?? false,
        );
      },
      child: Tooltip(
        message: facilitySubType.subType ?? "",
        child: Text(
          facilitySubType.subType ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: AppStyle.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}
