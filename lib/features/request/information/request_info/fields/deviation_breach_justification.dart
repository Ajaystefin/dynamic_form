import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

class DeviationBreachJustification extends StatelessWidget {
  const DeviationBreachJustification({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.applicationDetails?.deviationBreachJustification ?? "";
    final bool isValid = viewModel.canEdit;
    //  bool isValid = viewModel.canEdit
    //     ? viewModel.viewAccessRolesCheck()
    //         ? true
    //         : false
    //     : false;
    return LabelWidget(
      label:
          "requestInformation.requestInformation.deviationBreachJustification"
              .tr(),
      showLabel: true,
      isRequired: true,
      child: CustomTextArea(
        controller: viewModel.deviationJustificationController,
        key: const ValueKey("deviationBreachJustification"),
        filled: !isValid,
        readOnly: !isValid,
        initialValue: initialValue,
        counterText: "",
        semanticLabel:
            "requestInformation.requestInformation.deviationBreachJustification"
                .tr(),
        maxLength: 2000,
        hintText: "requestInformation.requestInformation.typeHere".tr(),
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.applicationDetails?.deviationBreachJustification =
              value ?? "";
        },
      ),
    );
  }
}
