import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/view.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/state.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/widgets/workflow_config_table.dart";
import "package:wcas_frontend/features/layout/view.dart";

/// Mobile view for displaying and managing workflow configurations.
class ViewMobile extends StatelessWidget {
  /// Creates a [ViewMobile] widget.
  const ViewMobile({super.key});

  /// Builds the mobile workflow configuration view.
  @override
  Widget build(BuildContext context) {
    final WorkflowConfigViewModel viewModel =
        context.read<WorkflowConfigViewModel>();
    return BlocBuilder<WorkflowConfigViewModel, WorkflowConfigurationState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    WorkflowConfigurationState state,
    WorkflowConfigViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return Center(child: Text("common.emptyState".tr()));
      default:
        return Layout(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "admin.workflowConfig.sideMenu".tr(),
                  ),
                  const Gap(),

                  // Table
                  WorkflowConfigTable(viewModel: viewModel),

                  const Gap(),

                  // Bottom action row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        tooltip: "admin.workflowConfig.addNew".tr(),
                        onPressed: () async {
                          final bool? result =
                              await DialogHelper.showCustomDialog(
                            barrierDismissible: false,
                            title: "admin.workflowConfig.dialog.title".tr(),
                            content: const UpdateWorkflowConfigurationView(),
                            context: context,
                          );
                          if (result ?? false) {
                            await viewModel.refreshTable();
                          }
                        },
                      ),
                      CustomButton(
                        onPressed: () => viewModel.onSave(),
                        label: "common.continue".tr(),
                        semanticLabel: "common.continue".tr(),
                      ),
                    ],
                  ),

                  const Gap(),
                ],
              ),
            ),
          ),
        );
    }
  }
}
