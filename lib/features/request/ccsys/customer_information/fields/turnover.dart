import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class Turnover extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const Turnover({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.customerInformation.turnover'.tr(),
        isRequired: true,
        child: CustomTextField(
          semanticLabel: 'ccsys.customerInformation.turnover'.tr(),
          validator: CustomValidator.requiredField,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onSaved: (String? turnOver) {
            viewModel.customerInformation.turnOver =
                double.tryParse(turnOver ?? "");
          },
        ));
  }
}
