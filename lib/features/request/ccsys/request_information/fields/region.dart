import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";

/// Read-only field widget that displays the region value.
class Region extends StatelessWidget {
  /// Creates a [Region] widget.
  const Region({required this.viewModel, super.key});

  /// View model used to read and save region data.
  final RequestInformationViewModel viewModel;

  /// Builds the region field.
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.requestInformation.region".tr(),
      child: CustomTextField(
        filled: true,
        semanticLabel: "requestInformation.requestInformation.region".tr(),
        readOnly: true,
        initialValue:
            viewModel.applicationDetails?.region ?? Globals.request?.region,
        onSaved: (String? value) {
          viewModel.applicationDetails?.region = value;
        },
      ),
    );
  }
}
