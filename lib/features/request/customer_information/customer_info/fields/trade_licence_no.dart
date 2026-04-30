import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class TradeLicenceNoField extends StatelessWidget {
  const TradeLicenceNoField({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.tradeLicenseNumber ?? "";
    final bool isValid =
        !viewModel.canEdit; // && initialValue.trim().isNotEmpty;
    return LabelWidget(
      label: "customerInformation.customerInformation.tradeLicenseNumber".tr(),
      child: CustomTextField(
        key: const ValueKey("tradeLicenseNumber"),
// controller: viewModel.controller(
//           CustomerInfoFields.tradeLicenseNo,
//         ),
        semanticLabel:
            "customerInformation.customerInformation.tradeLicenseNumber".tr(),
        onSaved: (value) {
          viewModel.customerInformation?.tradeLicenseNumber = value;
        },
        maxLength: 15,
        initialValue: initialValue,
        filled: isValid,
        readOnly: isValid,
      ),
    );
  }
}
