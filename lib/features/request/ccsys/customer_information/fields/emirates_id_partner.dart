import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class EmiratesIdPartner extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const EmiratesIdPartner({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.EmiratesIdPartner'.tr(),
      isRequired: viewModel
          .isLegalNpAndResidencyRE(), //conditional: Mandatory only if Residency status is RE and Legal Status is NP.
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.EmiratesIdPartner'.tr(),
        validator:
            viewModel.isLegalNpAndResidencyRE() ? CustomValidator.requiredField : null,
        onSaved: (String? emiratesIdPartner) =>
            viewModel.setEmiratesId(emiratesIdPartner),
      ),
    );
  }
}
