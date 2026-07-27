import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Location address title for the customer information screen.
class LocationAddressTitle extends StatelessWidget {
  /// Creates a location address title.
  const LocationAddressTitle({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: !viewModel.isFI,
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
