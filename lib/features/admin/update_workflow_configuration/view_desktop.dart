import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/application_category_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/application_type_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/customer_segment_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/new_application_name_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/status_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/fields/workflow_type_field.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/state.dart";

/// Desktop view for the update workflow configuration screen.
class ViewDesktop extends StatefulWidget {
  /// Creates a desktop view for workflow configuration.
  const ViewDesktop({super.key});

  /// Creates the mutable state for this desktop view.
  @override
  State<ViewDesktop> createState() => _ViewDesktopState();
}

class _ViewDesktopState extends State<ViewDesktop> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UpdateWorkflowConfigViewModel>();

    return BlocBuilder<UpdateWorkflowConfigViewModel,
        UpdateWorkflowConfigurationState>(
      builder: (context, state) {
        return _buildBody(context, state, viewModel);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    UpdateWorkflowConfigurationState state,
    UpdateWorkflowConfigViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    UpdateWorkflowConfigurationState state,
    UpdateWorkflowConfigViewModel viewModel,
  ) {
    return Focus(
      focusNode: viewModel.formFocusNode,
      child: SingleChildScrollView(
        child: BoxLayout(
          extraPadding: true,
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(),

                // ── Row 1: Workflow Type | Customer Segment | [empty] ──
                FormRow(
                  children: [
                    WorkflowTypeField(viewModel: viewModel),
                    CustomerSegmentField(viewModel: viewModel),
                    const SizedBox.shrink(),
                  ],
                ),

                const Gap(),

                // ── Row 2: Request Type | Existing App Type | New App Name
                FormRow(
                  children: [
                    ApplicationCategoryField(viewModel: viewModel),
                    ApplicationTypeField(viewModel: viewModel),
                    NewApplicationNameField(viewModel: viewModel),
                  ],
                ),

                const Gap(),

                // ── Row 3: Status | [empty] | [empty] ─────────────────
                FormRow(
                  children: [
                    WorkflowStatusField(viewModel: viewModel),
                    const SizedBox.shrink(),
                    const SizedBox.shrink(),
                  ],
                ),

                const Gap(),

                // ── Save / Cancel ──────────────────────────────────────
                _buildSaveCancelButtons(context, state, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildSaveCancelButtons(
    BuildContext context,
    UpdateWorkflowConfigurationState state,
    UpdateWorkflowConfigViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "common.save".tr(),
          semanticLabel: "common.save".tr(),
          isLoading: state.loaderStatus == LoadingStatus.loading,
          onPressed: () {
            viewModel.onSave(context);
          },
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "common.cancel".tr(),
          semanticLabel: "common.cancel".tr(),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
