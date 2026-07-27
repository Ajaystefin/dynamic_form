import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// CBD CBRB classification field for the customer information screen.
class CbdCbrbClassificationField extends StatelessWidget {
  /// Creates a CBD CBRB classification field.
  const CbdCbrbClassificationField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue = (viewModel
                .customerInformation?.cbdCBRBClassification
                ?.trim()
                .isNotEmpty ??
            false)
        ? viewModel.customerInformation!.cbdCBRBClassification!
        : "NA";
    return LabelWidget(
      label:
          "customerInformation.customerInformation.cbdCbrbClassification".tr(),
      child: CustomTextField(
        key: const ValueKey("cbdCbrbClassification"),
        semanticLabel:
            "customerInformation.customerInformation.cbdCbrbClassification"
                .tr(),
        initialValue: initialValue,
        filled: true,
        readOnly: true,
        onSaved: (value) {
          // keep DB value NULL, do not save "NA" back
          if (value != "NA") {
            viewModel.customerInformation?.cbdCBRBClassification = value;
          }
        },
      ),
    );
  }
}
