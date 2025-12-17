import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

class ProjectName extends StatelessWidget {
  final String? prjectName;
  const ProjectName({required this.prjectName, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.projectName".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.projectName".tr(),
        initialValue: prjectName,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
