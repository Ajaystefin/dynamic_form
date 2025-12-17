import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class Auditor extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const Auditor({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.customerInformation.auditor'.tr(),
        isRequired: true,
        child: CustomTextField(
          semanticLabel: 'ccsys.customerInformation.auditor'.tr(),
          validator: CustomValidator.requiredField,
          onSaved: (String? auditor) {
            viewModel.customerInformation.auditor = auditor;
          },
        ));
  }
}
