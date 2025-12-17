import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class LeiNumberPartner extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const LeiNumberPartner({
    super.key,
    required this.viewModel,
  });
  
  @override
  Widget build(BuildContext context) {
    bool isMantatory = viewModel.customerInformation.legalStatusPartners ==
        viewModel.legalStatusPartners[0];
    return LabelWidget(
      label: 'ccsys.customerInformation.leiNumberPartner'.tr(),
      isRequired:
          isMantatory, //Mandatory only if Legal Status = JP and LEI option above is 'Y'
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.leiNumberPartner'.tr(),
        validator: isMantatory ? CustomValidator.requiredField : null,
        onSaved: (String? leiNumberPartner) {
          viewModel.customerInformation.leiNumberPartner = leiNumberPartner;
        },
      ),
    );
  }
}
