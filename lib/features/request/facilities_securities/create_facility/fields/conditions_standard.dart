import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class FacilityConditionsStandard extends StatelessWidget {
  const FacilityConditionsStandard({required this.viewModel, super.key});
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
            onChange: (value) {
              viewModel.changeConditionsStandard(value ?? false);
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
