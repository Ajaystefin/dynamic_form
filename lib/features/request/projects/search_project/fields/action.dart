import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/features/request/projects/search_project/model.dart';

class ActionButton extends StatelessWidget {
  final SearchProjectViewModel viewModel;
  const ActionButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 4,
      children: [
        CustomButton(
            label: "project.searchProject.submit".tr(), //Submit
            semanticLabel: "project.searchProject.submit".tr(),
            onPressed: () async {
              await viewModel.onSubmitPressed(context);
            }),
        CustomButton(
            label: "project.searchProject.reset".tr(), // reset
            semanticLabel: "project.searchProject.reset".tr(),
            onPressed: () async {
              await viewModel.onResetPressed(context);
            }),
      ],
    );
  }
}
