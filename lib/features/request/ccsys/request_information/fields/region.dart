import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class Region extends StatelessWidget {
  final String? region;
  const Region({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.requestInformation.region'.tr(),
      child: CustomTextField(
        filled: true,
        readOnly: true,
        semanticLabel: 'ccsys.requestInformation.region'.tr(),
        initialValue: region,
      ),
    );
  }
}
