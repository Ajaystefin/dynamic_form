import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class Shareholding extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const Shareholding({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.shareholding'.tr(),
      isRequired: true,
      child: CustomTextField(
        semanticLabel: 'ccsys.customerInformation.shareholding'.tr(),
        validator: CustomValidator.requiredField,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        onSaved: (String? value) {
          viewModel.customerInformation.shareholding =
              double.tryParse(value ?? "");
        },
      ),
    );
  }
}
