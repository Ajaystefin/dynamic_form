import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Actions widget for create project.
class Actions extends StatelessWidget {
  /// Creates actions widget.
  const Actions(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "project.createNewProject.save".tr(),
          semanticLabel: "project.createNewProject.save".tr(),
          onPressed: viewModel.canEdit
              ?
              // viewModel.viewAccessRolesCheck()
              //     ? null
              //     :
              () => viewModel.onSave(
                    context,
                    isValidate: viewModel.formKey.currentState!.validate(),
                  )
              : null,
        ),
        if (viewModel.isCreateProject) ...[
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "project.createNewProject.create".tr(),
            semanticLabel: "project.createNewProject.create".tr(),
            onPressed: viewModel.canEdit
                ?
                // viewModel.viewAccessRolesCheck()
                //     ? null
                //     :
                () {
                    final isValid =
                        viewModel.formKey.currentState?.validate() ?? false;
                    viewModel.onCreate(context, isValidate: isValid);
                  }
                : null,
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "project.createNewProject.discard".tr(),
            semanticLabel: "project.createNewProject.discard".tr(),
            onPressed: viewModel.onDiscard,
          ),
        ],
        if (!viewModel.isCreateProject) ...[
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "project.createNewProject.linkContract".tr(),
            semanticLabel: "project.createNewProject.linkContract".tr(),
            onPressed: viewModel.canEdit
                ?
                //  viewModel.viewAccessRolesCheck()
                //     ? null
                //     :
                viewModel.onPressedLinkContract
                : null,
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          if (viewModel.canEdit)
            CustomDropdownButton(
              label: "project.createNewProject.generateSummary".tr(),
              isSearchable: false,
              initialOption: CustomDropdownItem(
                isHeader: true,
                value: "",
                onPressed: () async {
                  viewModel.selectedDoctype = "pdf";
                },
              ),
              options: [
                CustomDropdownItem(
                  value: "pdf",
                  onPressed: () => {viewModel.selectedDoctype = "pdf"},
                ),
                CustomDropdownItem(
                  value: "word",
                  onPressed: () => {viewModel.selectedDoctype = "word"},
                ),
                CustomDropdownItem(
                  value: "excel",
                  onPressed: () => {viewModel.selectedDoctype = "xlxs"},
                ),
              ],
              callBack: (value) async {
                viewModel.selectedDoctype = value;
              },
              onButtonPressed: () async {
                await viewModel.onGenerateSummary(viewModel.selectedDoctype);
              },
            ),
        ],
      ],
    );
  }
}
