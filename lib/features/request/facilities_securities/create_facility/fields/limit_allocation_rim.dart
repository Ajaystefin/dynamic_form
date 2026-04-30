import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class LimitAllocationCustomerRIM extends StatelessWidget {
  const LimitAllocationCustomerRIM({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitAllocationCustomerRIM".tr(),
      isRequired: false,
      showLabel: true,
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
