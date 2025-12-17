import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class TradeLicenceNumberPartner extends StatelessWidget {
  final CustomerInformationViewModel viewModel;
  const TradeLicenceNumberPartner({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    bool isRequired = viewModel.customerInformation.legalStatusPartners ==
        viewModel.legalStatusPartners[0];
    return LabelWidget(
      label: 'ccsys.customerInformation.tradeLicenseNumber'.tr(),
      isRequired: isRequired, //-	Mandatory only if Legal Status = JP
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.tradeLicenseNumber'.tr(),
        validator: isRequired ? CustomValidator.requiredField : null,
        onSaved: (String? value) {
          viewModel.customerInformation.tradeLicenseNumber = value;
        },
      ),
    );
  }
}
