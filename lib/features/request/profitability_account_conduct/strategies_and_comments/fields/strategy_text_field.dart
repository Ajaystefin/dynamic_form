import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

/// A reusable widget that displays a required label followed by a text area.
class StrategyTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const StrategyTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * .8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(label: label, labelStyle: AppStyle.boldLabel),
        CustomTextArea(
          semanticLabel: label,
          width: fieldWidth,
          hintText:
              "profitabilityAccountConduct.strategiesComments.typeHere".tr(),
          autoFocus: false,
          maxLength: 5000,
          initialValue: initialValue,
          onChanged: onChanged,
        ),
        const Gap(size: GapSize.small),
      ],
    );
  }
}
