import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class CaDate extends StatelessWidget {
  final String? ca;
  const CaDate({super.key, required this.ca});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.requestInformation.caDate'.tr(),
      child: CustomTextField(
        filled: true,
        readOnly: true,
        semanticLabel: 'ccsys.requestInformation.caDate'.tr(),
        initialValue: "", //ca,
      ),
    );
  }
}
