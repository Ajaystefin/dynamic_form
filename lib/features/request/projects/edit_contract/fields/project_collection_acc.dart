import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';

class ProjectCollectionAcc extends StatelessWidget {
  const ProjectCollectionAcc({super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.projectCollectionAmount".tr(),
      child: CustomMultiSelectDropdown(
          semanticLabel:
              "project.viewEditContractDetails.projectCollectionAmount".tr(),
          items: const []),
    );
  }
}
