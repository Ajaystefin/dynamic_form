import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/completion.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/current_project_value.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/end_date.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/entity_rim.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/initial_project_value.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/owner_entity.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/owner_rim.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/project_code.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/project_name.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/project_period.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/project_value.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/summary.dart";
import "package:wcas_frontend/features/request/projects/create_project/fields/ultimate_owner.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/features/request/projects/create_project/state.dart";
import "package:wcas_frontend/features/request/projects/create_project/widgets/actions.dart"
    as actions;
import "package:wcas_frontend/features/request/projects/create_project/widgets/contractors_table.dart";

/// Mobile view for create or edit project.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile view for create or edit project.
  const ViewMobile({required this.isCreateProject, super.key});

  /// Indicates whether the screen is in create project mode.
  final bool isCreateProject;

  @override
  Widget build(BuildContext context) {
    final CreateProjectViewModel viewModel =
        context.read<CreateProjectViewModel>();
    return BlocBuilder<CreateProjectViewModel, CreateProjectState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    CreateProjectState state,
    CreateProjectViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.serverError".tr()),
        );
      default:
        return SingleChildScrollView(
          child: BoxLayout(
            extraPadding: true,
            child: Focus(
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionHeader(
                      title: isCreateProject
                          ? "project.createNewProject.createProject".tr()
                          : "project.createNewProject.editViewProject".tr(),
                    ),
                    const Gap(),
                    CustomButton(
                      leadingIcon:
                          const Icon(Icons.arrow_back, color: AppColors.white),
                      label: "project.linkContract.backToRequestStatus".tr(),
                      semanticLabel:
                          "project.linkContract.backToRequestStatus".tr(),
                      onPressed: () async {
                        await viewModel.onBacktoRequestStatusPressed(context);
                      },
                    ),
                    ProjectCode(viewModel),
                    const Gap(),
                    ProjectName(viewModel),
                    const Gap(),
                    UltimateOwner(viewModel),
                    const Gap(),
                    OwnerEntity(viewModel),
                    const Gap(),
                    OwnerRim(viewModel),
                    const Gap(),
                    EntityRim(viewModel),
                    const Gap(),
                    ProjectValue(viewModel),
                    const Gap(),
                    ProjectPeriod(viewModel),
                    const Gap(),
                    Completion(viewModel),
                    const Gap(),
                    LiabilityEndDate(viewModel),
                    const Gap(),
                    Summary(viewModel),
                    const Gap(),
                    if (!isCreateProject) ...[
                      InitialProjectValue(viewModel),
                      const Gap(),
                      CurrentProjectValue(viewModel),
                      const Gap(),
                      BoxLayout(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSectionHeader(
                              title:
                                  "project.createNewProject.contractors".tr(),
                            ),
                            const Gap(),
                            CustomSelectableText(
                              text: "groupInformation."
                                      "facilitiesWithOtherBanks.aed"
                                  .tr(),
                              style: AppStyle.tableSuffixHeaderStyle,
                              semanticsLabel: "groupInformation."
                                      "facilitiesWithOtherBanks.aed"
                                  .tr(),
                            ),
                            const Gap(),
                            ContractorsTable(viewModel),
                          ],
                        ),
                      ),
                    ],
                    const Gap(),
                    actions.Actions(viewModel),
                    const Gap(),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
