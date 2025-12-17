import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class RimNo extends StatelessWidget {
  final int? rimNO;
  const RimNo({required this.rimNO, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.rimNo".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.rimNo".tr(),
        initialValue: "$rimNO",
        readOnly: true,
        filled: true,
      ),
    );
  }
}
