import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class LocationAddressTitle extends StatelessWidget {
  const LocationAddressTitle({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.isFI) ? false : true,
            showLabel: true,
            infoContent:
                "customerInformation.customerInformation.locationAddressTool"
                    .tr(),
            label:
                "customerInformation.customerInformation.locationAddress".tr(),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
}
