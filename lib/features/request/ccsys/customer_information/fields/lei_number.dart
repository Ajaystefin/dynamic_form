import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";

class LeiNumber extends StatelessWidget {
  const LeiNumber({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  final CustomerInformationState state;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.leiNumber".tr(),
      isRequired: (!viewModel.canEdit) ? false : state.legalEntityIdentifier,
      child: CustomTextField(
        readOnly: (!viewModel.canEdit) ? true : !state.legalEntityIdentifier,
        filled: (!viewModel.canEdit) ? true : !state.legalEntityIdentifier,
        maxLength: 20,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
          ),
          LengthLimitingTextInputFormatter(20), // limit to 20 chars
        ],
        semanticLabel: "ccsys.customerInformation.leiNumber".tr(),
        initialValue: !state.legalEntityIdentifier
            ? "NA"
            : viewModel.customerInformation.leiNumber != null ||
                    viewModel.customerInformation.leiNumber.toString() != "null"
                ? viewModel.customerInformation.leiNumber.toString() != "NA"
                    ? viewModel.customerInformation.leiNumber.toString()
                    : "NA"
                : "NA",
        controller: viewModel.leiController,
        validator:
            state.legalEntityIdentifier ? CustomValidator.requiredField : null,
        onSaved: (String? value) {
          viewModel.customerInformation.leiNumber = value;
        },
      ),
    );
  }
}
