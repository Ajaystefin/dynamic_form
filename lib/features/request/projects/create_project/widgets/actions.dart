import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class Actions extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const Actions(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "project.createNewProject.save".tr(),
          semanticLabel: "project.createNewProject.save".tr(),
          onPressed: () =>
              viewModel.onSave(viewModel.formKey.currentState!.validate()),
        ),
        if (viewModel.isCreateProject) ...[
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "project.createNewProject.create".tr(),
            semanticLabel: "project.createNewProject.create".tr(),
            onPressed: () {
              final isValid =
                  viewModel.formKey.currentState?.validate() ?? false;
              viewModel.onCreate(context, isValid);
            },
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "project.createNewProject.discard".tr(),
            semanticLabel: "project.createNewProject.discard".tr(),
            onPressed: () => viewModel.onDiscard(),
          ),
        ],
        if (!viewModel.isCreateProject) ...[
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "project.createNewProject.linkContract".tr(),
            semanticLabel: "project.createNewProject.linkContract".tr(),
            onPressed: () => viewModel.onPressedLinkContract(),
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomDropdownButton(
            label: "project.createNewProject.generateSummary".tr(),
            isSearchable: false,
            options: [
              CustomDropdownItem(
                  value: "project.createNewProject.generatePdf".tr(),
                  onPressed: () => viewModel.onGeneratePdf()),
              CustomDropdownItem(
                  value: "project.createNewProject.generateWord".tr(),
                  onPressed: () => viewModel.onGenerateWord()),
            ],
          ),
        ]
      ],
    );
  }
}
