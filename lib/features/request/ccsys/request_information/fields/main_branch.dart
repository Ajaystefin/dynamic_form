import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";

class MainBranch extends StatelessWidget {
  const MainBranch({required this.viewModel, super.key});
  final RequestInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.requestInformation.mainBranch".tr(),
      isRequired: false,
      showLabel: true,
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
