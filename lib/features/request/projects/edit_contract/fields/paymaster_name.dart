import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class PaymasterName extends StatelessWidget {
  final String? paymasterName;
  const PaymasterName({required this.paymasterName, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.paymasterName".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.paymasterName".tr(),
        initialValue: paymasterName,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
