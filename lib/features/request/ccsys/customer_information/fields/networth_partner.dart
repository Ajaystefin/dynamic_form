import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class NetworkPartner extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const NetworkPartner({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.networkPartner'.tr(),
      isRequired: true,
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.networkPartner'.tr(),
        validator: CustomValidator.requiredField,
        inputFormatters: [
          NumericFloatingPointFormatter()
        ],
        onSaved: (String? networkPartner) {
          viewModel.customerInformation.networkPartner = networkPartner;
        },
      ),
    );
  }
}
