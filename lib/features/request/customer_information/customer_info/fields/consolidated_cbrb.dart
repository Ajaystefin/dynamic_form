import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Consolidated CBRD field for the customer information screen.
class ConsolidatedCBRDField extends StatelessWidget {
  /// Creates a consolidated CBRD field.
  const ConsolidatedCBRDField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        (viewModel.customerInformation?.cbrbClassification?.trim().isNotEmpty ??
                false)
            ? viewModel.customerInformation!.cbrbClassification!
            : ""; //NA

    return LabelWidget(
      label: "customerInformation.customerInformation.consolidatedCBRD".tr(),
      infoContent:
          "customerInformation.customerInformation.consolidatedCBRDInfo".tr(),
      child: CustomTextField(
        key: const ValueKey("consolidatedCBRD"),
        semanticLabel:
            "customerInformation.customerInformation.consolidatedCBRD".tr(),
        initialValue: initialValue,
        filled: true,
        readOnly: true,
        onSaved: (value) {
          if (value != "") {
            //NA
            viewModel.customerInformation?.cbrbClassification = value;
          }
        },
      ),
    );
  }
}
