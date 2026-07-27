import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing limit allocation customer RIM details.
class LimitAllocationCustomerRIM extends StatelessWidget {
  /// Creates a limit allocation customer RIM widget.
  const LimitAllocationCustomerRIM({
    required this.viewModel,
    super.key,
  });

  /// View model containing limit allocation customer RIM data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitAllocationCustomerRIM".tr(),
      child: CustomTextField(
        semanticLabel:
            "facilities.createFacility.limitAllocationCustomerRIM".tr(),
        initialValue: viewModel.getFacility.limitAllocationCustomerRIM,
        onSaved: (String? value) {
          viewModel.getFacility.limitAllocationCustomerRIM = value;
        },
      ),
    );
  }
}
