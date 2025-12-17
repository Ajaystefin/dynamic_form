import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class CustomerName extends StatelessWidget {
  final String? customerName;
  const CustomerName({required this.customerName, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.customerName".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.customerName".tr(),
        initialValue: customerName,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
