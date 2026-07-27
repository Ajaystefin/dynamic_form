import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for managing the facility conditions standard option.
class FacilityConditionsStandard extends StatelessWidget {
  /// Creates a facility conditions standard widget.
  const FacilityConditionsStandard({required this.viewModel, super.key});

  /// View model containing facility condition data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "",
      child: Row(
        children: [
          CustomCheckbox(
            semanticsLabel: "facilities.createFacility.conditionsStandard".tr(),
            value: viewModel.getFacility.isConditionsStandard,
            onChange: ({value}) {
              viewModel.changeConditionsStandard(value: value ?? false);
            },
          ),
          CustomSelectableText(
            text: "facilities.createFacility.conditionsStandard".tr(),
            style: AppStyle.boldLabel,
          ),
        ],
      ),
    );
  }
}
