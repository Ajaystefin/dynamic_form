import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/application_category_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/application_type_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/customer_segment_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/new_application_name_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/status_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/workflow_type_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/state.dart";

/// Mobile view for the update workflow configuration screen.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile view for workflow configuration.
  const ViewMobile({super.key});

  /// Builds the mobile workflow configuration view.
  @override
  Widget build(BuildContext context) {
    final UpdateWorkflowConfigViewModel viewModel =
        context.read<UpdateWorkflowConfigViewModel>();
    return BlocBuilder<UpdateWorkflowConfigViewModel,
        UpdateWorkflowConfigurationState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    UpdateWorkflowConfigurationState state,
    UpdateWorkflowConfigViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return Center(child: Text("common.emptyState".tr()));
      default:
        return Focus(
          focusNode: viewModel.formFocusNode,
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Row 1: Workflow Type | Customer Segment ────
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: WorkflowTypeField(viewModel: viewModel),
                            ),
                            Expanded(
                              child: CustomerSegmentField(viewModel: viewModel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Row 2: Request Type | App Type ─────────────
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ApplicationCategoryField(
                                viewModel: viewModel,
                              ),
                            ),
                            Expanded(
                              child: ApplicationTypeField(viewModel: viewModel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Row 3: New App Name | Status ───────────────
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: NewApplicationNameField(
                                viewModel: viewModel,
                              ),
                            ),
                            Expanded(
                              child: WorkflowStatusField(viewModel: viewModel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        _buildSaveCancelButtons(context, state, viewModel),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Row _buildSaveCancelButtons(
    BuildContext context,
    UpdateWorkflowConfigurationState state,
    UpdateWorkflowConfigViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10,
      children: [
        CustomButton(
          label: "common.save".tr(),
          isLoading: state.loaderStatus == LoadingStatus.loading,
          onPressed: () => viewModel.onSave(context),
        ),
        CustomButton(
          label: "common.cancel".tr(),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
