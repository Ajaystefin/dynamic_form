import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class PassportNumber extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const PassportNumber({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.passportNumber'.tr(),
      isRequired: viewModel
          .isLegalNpAndResidencyRE(), //only if Residency status is NR and Legal Status is NP
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.passportNumber'.tr(),
        validator: viewModel.isLegalNpAndResidencyRE()
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        ],
        onSaved: (String? passportNumber) {
          viewModel.customerInformation.passportNumber = passportNumber;
        },
      ),
    );
  }
}
