import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class ContractCode extends StatelessWidget {
  final String? contractCode;
  const ContractCode({required this.contractCode, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.contractCode".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.contractCode".tr(),
        initialValue: "$contractCode",
        readOnly: true,
        filled: true,
      ),
    );
  }
}
