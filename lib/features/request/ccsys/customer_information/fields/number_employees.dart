import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class NumberEmployees extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const NumberEmployees({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.numberEmployees'.tr(),
      isRequired: true,
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.numberEmployees'.tr(),
        validator: CustomValidator.requiredField,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSaved: (String? value) {
          viewModel.customerInformation.numberEmployees =
              int.tryParse(value ?? "");
        },
      ),
    );
  }
}
