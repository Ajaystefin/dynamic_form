import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';

class ProjectCompletion extends StatelessWidget {
  final DateTime? projectCompletion;
  const ProjectCompletion({required this.projectCompletion, super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.projectCompletion".tr(),
      child: CustomDatePicker(
        semanticLabel: "project.viewEditContractDetails.projectCompletion".tr(),
        initialDateTime: projectCompletion,
        isEnabled: false,
      ),
    );
  }
}
