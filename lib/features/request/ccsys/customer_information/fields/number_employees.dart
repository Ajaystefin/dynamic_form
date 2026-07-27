import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

/// Displays the number of employees field for CCSYS customer information.
class NumberEmployees extends StatelessWidget {
  /// Creates the number of employees field widget.
  const NumberEmployees({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage number of employees information and edit access.
  final CustomerInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message:
          "ccsys.customerInformation.tooltip.numberofEmployeesTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.numberEmployees".tr(),
        isRequired: viewModel.canEdit,
        child: CustomTextField(
          maxLength: 10,
          semanticLabel: "ccsys.customerInformation.numberEmployees".tr(),
          readOnly: !viewModel.canEdit,
          filled: !viewModel.canEdit,
          validator:
              (!viewModel.canEdit) ? null : CustomValidator.requiredField,
          initialValue: viewModel.customerInformation.numberOfEmployee !=
                      null ||
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
      ),
    );
  }
}
