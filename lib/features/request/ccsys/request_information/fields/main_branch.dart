import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";

/// Read-only field widget that displays the main branch value.
class MainBranch extends StatelessWidget {
  /// Creates a [MainBranch] widget.
  const MainBranch({required this.viewModel, super.key});

  /// View model used to read and save main branch data.
  final RequestInformationViewModel viewModel;

  /// Builds the main branch field.
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.requestInformation.mainBranch".tr(),
      child: CustomTextField(
        filled: true,
        semanticLabel: "requestInformation.requestInformation.mainBranch".tr(),
        readOnly: true,
        initialValue:
            viewModel.applicationDetails?.branch ?? Globals.request?.branch,
        onSaved: (String? value) {
          viewModel.applicationDetails?.branch = value;
        },
      ),
    );
  }
}
