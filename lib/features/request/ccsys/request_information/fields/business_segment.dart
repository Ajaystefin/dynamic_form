import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class BusinessSegmentField extends StatelessWidget {
  final String? businessSegment;
  const BusinessSegmentField({super.key, required this.businessSegment});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.requestInformation.businessSegment'.tr(),
      child: CustomTextField(
        filled: true,
        semanticLabel: 'ccsys.requestInformation.businessSegment'.tr(),
        readOnly: true,
        initialValue: businessSegment,
      ),
    );
  }
}
