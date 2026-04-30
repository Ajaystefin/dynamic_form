import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

class Auditor extends StatelessWidget {
  const Auditor({
    required this.viewModel,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.auditor".tr(),
      isRequired: viewModel.canEdit,
      child: CustomTextField(
        semanticLabel: "ccsys.customerInformation.auditor".tr(),
        initialValue: viewModel.customerInformation.auditor ?? "",
        maxLength: 100,
        validator: (!viewModel.canEdit) ? null : CustomValidator.requiredField,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp("[a-zA-Z0-9 ]"),
          ),
        ],
        controller: viewModel.auditorController,
        onChanged: (String? value) {
          viewModel.customerInformation.auditor = value ?? "";
        },
        onSaved: (String? value) {
          viewModel.customerInformation.auditor = value ?? "";
        },
      ),
    );
  }
}
