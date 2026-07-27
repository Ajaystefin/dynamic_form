import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing the facility limit number.
class LimitNumber extends StatelessWidget {
  /// Creates a limit number widget.
  const LimitNumber({required this.viewModel, super.key});

  /// View model containing limit number data and actions.
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
        readOnly: !(Globals.request?.applicationSubType ==
            ServerConstants.manualEntry),
        // filled: true,
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
