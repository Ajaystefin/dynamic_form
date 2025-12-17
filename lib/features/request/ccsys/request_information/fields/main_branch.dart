import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class MainBranch extends StatelessWidget {
  final String? mainBranch;
  const MainBranch({super.key, required this.mainBranch});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.requestInformation.mainBranch'.tr(),
        child: CustomTextField(
          filled: true,
          readOnly: true,
          semanticLabel: 'ccsys.requestInformation.mainBranch'.tr(),
          initialValue: mainBranch,
        ));
  }
}
