import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for managing the cross-border corporate exposure selection.
class CrossBoarderCorporateExposure extends StatelessWidget {
  /// Creates a cross-border corporate exposure widget.
  const CrossBoarderCorporateExposure({
    required this.viewModel,
    super.key,
  });

  /// View model containing cross-border corporate exposure data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isUAE = viewModel.isUAECountryOfRisk;

    return CustomCheckbox(
      value: viewModel.getFacility.isCrossBoarderExposure,
      isEnabled: !isUAE,
      onChange: ({value}) {
        if (!isUAE) {
          viewModel.changeCrossBoarderExposure(value: value ?? false);
        }
      },
      child: CustomSelectableText(
        text: "facilities.createFacility.crossBoarder".tr(),
        style: AppStyle.boldLabel,
      ),
    );
  }
}
