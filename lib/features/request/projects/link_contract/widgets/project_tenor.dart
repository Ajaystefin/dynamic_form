import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class ProjectTenor extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ProjectTenor({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.projectTenor".tr(),
      child: CustomTextField(
        semanticLabel: "project.linkContract.projectTenor".tr(),
        controller: viewModel.projectTenorController,
        readOnly: true,
        filled: true,
        fillColor: AppColors.tableActivatedColor,
      ),
    );
  }
}
