import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

class NumberEmployees extends StatelessWidget {
  const NumberEmployees({
    required this.viewModel,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.numberEmployees".tr(),
      isRequired: viewModel.canEdit,
      child: CustomTextField(
        maxLength: 10,
        semanticLabel: "ccsys.customerInformation.numberEmployees".tr(),
        validator: (!viewModel.canEdit) ? null : CustomValidator.requiredField,
        initialValue: viewModel.customerInformation.numberOfEmployee != null ||
                viewModel.customerInformation.numberOfEmployee.toString() !=
                    "null"
            ? viewModel.customerInformation.numberOfEmployee.toString()
            : "",
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: viewModel.numberOfEmployeeController,
        keyboardType: TextInputType.number,
        onChanged: (String? value) {
          viewModel.customerInformation.numberOfEmployee =
              int.tryParse(value ?? "");
        },
        onSaved: (String? value) {
          viewModel.customerInformation.numberOfEmployee =
              int.tryParse(value ?? "");
        },
      ),
    );
  }
}
