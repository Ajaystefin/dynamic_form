import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class LeiNumber extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const LeiNumber({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.leiNumber'.tr(),
      isRequired: viewModel.isLegalEntityIdentifier,
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.leiNumber'.tr(),
        validator: viewModel.isLegalEntityIdentifier
            ? CustomValidator.requiredField
            : null,
        onSaved: (String? value) {
          viewModel.customerInformation.leiNumber = value;
        },
      ),
    );
  }
}
