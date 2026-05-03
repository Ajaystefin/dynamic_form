import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class LimitNumber extends StatelessWidget {
  const LimitNumber({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool groupRequires = !(ServerConstants.fixedIncomeGroup ==
    // viewModel.getFacility.limitGroup ||
    //     ServerConstants.corporateCrossBorderGroup ==
    // viewModel.getFacility.limitGroup ||
    //     ServerConstants.treasuryGroup == viewModel.getFacility.limitGroup);
    return LabelWidget(
      isRequired:
          true, // !(viewModel.showCreateFacilityForm) ? false : groupRequires,
      label: "facilities.createFacility.limitNumber".tr(),
      child: CustomTextField(
        readOnly: true,
        filled: true,
        maxLength: 7,
        semanticLabel: "facilities.createFacility.limitNumber".tr(),
        initialValue: (!viewModel.showCreateFacilityForm)
            ? viewModel.facilityDetail.first.limitNo
            : "",
        validator: !viewModel.isFIFlow ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          viewModel.getFacility.limitNumber = value;
        },
      ),
    );
  }
}
