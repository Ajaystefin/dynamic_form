import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing the limit allocation amount.
class LimitAllocationAmount extends StatelessWidget {
  /// Creates a limit allocation amount widget.
  const LimitAllocationAmount({
    required this.viewModel,
    super.key,
  });

  /// View model containing limit allocation amount data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitAllocationAmountAED".tr(),
      child: CustomTextField(
        semanticLabel:
            "facilities.createFacility.limitAllocationAmountAED".tr(),
        initialValue: viewModel.getFacility.limitAllocation,
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.getFacility.limitAllocation = value;
        },
      ),
    );
  }
}
