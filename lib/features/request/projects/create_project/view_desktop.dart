import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
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

class ViewDesktop extends StatelessWidget {
  const ViewDesktop(this.isCreateProject, {super.key});
  final bool isCreateProject;

  @override
  Widget build(BuildContext context) {
    final CreateProjectViewModel viewModel =
        context.read<CreateProjectViewModel>();
    return BlocBuilder<CreateProjectViewModel, CreateProjectState>(
      builder: (context, state) {
        return Layout(
          hideSideMenu: true,
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
            child: Focus(
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomSectionHeader(
                          title: isCreateProject
                              ? "project.createNewProject.createProject".tr()
                              : "project.createNewProject.editViewProject".tr(),
                        ),
                        CustomButton(
                          leadingIcon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                          label:
                              "project.linkContract.backToRequestStatus".tr(),
                          semanticLabel:
                              "project.linkContract.backToRequestStatus".tr(),
                          onPressed: () async {
                            await viewModel
                                .onBacktoRequestStatusPressed(context);
                          },
                        ),
                      ],
                    ),
                    const Gap(),
                    BoxLayout(
                      extraPadding: true,
                      child: Column(
                        children: [
                          FormRow(
                            children: [
                              ProjectCode(viewModel),
                              ProjectName(viewModel),
                              UltimateOwner(viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              OwnerEntity(viewModel),
                              OwnerRim(viewModel),
                              EntityRim(viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              ProjectValue(viewModel),
                              Completion(viewModel),
                              ProjectPeriod(viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              LiabilityEndDate(viewModel),
                            ],
                          ),
                          const Gap(),
                          Summary(viewModel),
                          const Gap(),
                          if (!isCreateProject) ...[
                            FormRow(
                              children: [
                                InitialProjectValue(viewModel),
                                CurrentProjectValue(viewModel),
                                const SizedBox(),
                              ],
                            ),
                            const Gap(),
                            BoxLayout(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomSectionHeader(
                                        title: "project.createNewProject."
                                                "contractors"
                                            .tr(),
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
                                    ],
                                  ),
                                  const Gap(),
                                  ContractorsTable(viewModel),
                                ],
                              ),
                            ),
                          ],
                          const Gap(),
                          actions.Actions(viewModel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
